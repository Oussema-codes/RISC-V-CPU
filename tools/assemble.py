#!/usr/bin/env python3
"""
assemble.py -- a small assembler for the RV32I subset used by this CPU.

Supports labels and pseudo-instructions such as li and nop.

Usage:
    python3 tools/assemble.py input.s output.hex

Output: one 8-digit hex word per line, suitable for Verilog $readmemh.
Instruction at address 0 is on line 1, address 4 on line 2, and so on.
"""
import sys, re

REG = {f"x{i}": i for i in range(32)}
# common ABI names -> x-number
ABI = {
    "zero":0,"ra":1,"sp":2,"gp":3,"tp":4,"t0":5,"t1":6,"t2":7,
    "s0":8,"fp":8,"s1":9,"a0":10,"a1":11,"a2":12,"a3":13,"a4":14,
    "a5":15,"a6":16,"a7":17,"s2":18,"s3":19,"s4":20,"s5":21,"s6":22,
    "s7":23,"s8":24,"s9":25,"s10":26,"s11":27,"t3":28,"t4":29,"t5":30,"t6":31,
}
REG.update(ABI)

def reg(tok):
    tok = tok.strip().lower()
    if tok not in REG:
        raise ValueError(f"bad register: {tok}")
    return REG[tok]

def imm(tok, labels=None, pc=None, rel=False):
    tok = tok.strip()
    if labels is not None and tok in labels:
        return (labels[tok] - pc) if rel else labels[tok]
    return int(tok, 0)

# funct3/funct7 tables
R = {  # name -> (funct7, funct3)
    "add":(0x00,0x0),"sub":(0x20,0x0),"sll":(0x00,0x1),"slt":(0x00,0x2),
    "sltu":(0x00,0x3),"xor":(0x00,0x4),"srl":(0x00,0x5),"sra":(0x20,0x5),
    "or":(0x00,0x6),"and":(0x00,0x7),
}
I = {  # name -> funct3 (OP-IMM)
    "addi":0x0,"slti":0x2,"sltiu":0x3,"xori":0x4,"ori":0x6,"andi":0x7,
}
ISH = {"slli":(0x00,0x1),"srli":(0x00,0x5),"srai":(0x20,0x5)}  # shift-imm
LOAD = {"lw":0x2}
STORE = {"sw":0x2}
BR = {"beq":0x0,"bne":0x1,"blt":0x4,"bge":0x5,"bltu":0x6,"bgeu":0x7}

def enc_r(f7,rs2,rs1,f3,rd):
    return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33
def enc_i(im,rs1,f3,rd,op):
    return ((im&0xFFF)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def enc_ish(f7,sh,rs1,f3,rd):
    return (f7<<25)|((sh&0x1F)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x13
def enc_s(im,rs2,rs1,f3):
    im&=0xFFF
    return ((im>>5)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|((im&0x1F)<<7)|0x23
def enc_b(im,rs2,rs1,f3):
    im&=0x1FFF
    b12=(im>>12)&1; b11=(im>>11)&1; b10_5=(im>>5)&0x3F; b4_1=(im>>1)&0xF
    return (b12<<31)|(b10_5<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(b4_1<<8)|(b11<<7)|0x63
def enc_u(im,rd,op):
    return ((im&0xFFFFF)<<12)|(rd<<7)|op
def enc_j(im,rd):
    im&=0x1FFFFF
    b20=(im>>20)&1; b10_1=(im>>1)&0x3FF; b11=(im>>11)&1; b19_12=(im>>12)&0xFF
    return (b20<<31)|(b10_1<<21)|(b11<<20)|(b19_12<<12)|(rd<<7)|0x6F

def clean(line):
    line = line.split('#',1)[0]
    return line.strip()

def parse_ops(s):
    return [t for t in re.split(r'[,\s]+', s.strip()) if t]

def assemble(text):
    # pass 1: collect labels and a flat list of (pc, tokens)
    lines, pc = [], 0
    for raw in text.splitlines():
        s = clean(raw)
        if not s: continue
        while ':' in s:                    # label(s) at line start
            lbl, s = s.split(':',1)
            LABELS[lbl.strip()] = pc
            s = s.strip()
        if not s: continue
        lines.append((pc, s))
        pc += 4
    # pass 2: encode
    words = []
    for pc, s in lines:
        toks = parse_ops(s)
        op = toks[0].lower()
        a = toks[1:]
        if op == "nop":
            words.append(enc_i(0,0,0,0,0x13)); continue
        if op == "li":                      # pseudo: addi rd, x0, imm (12-bit)
            words.append(enc_i(imm(a[1]),0,0x0,reg(a[0]),0x13)); continue
        if op == "mv":                      # pseudo: addi rd, rs, 0
            words.append(enc_i(0,reg(a[1]),0x0,reg(a[0]),0x13)); continue
        if op in R:
            f7,f3 = R[op]; words.append(enc_r(f7,reg(a[2]),reg(a[1]),f3,reg(a[0]))); continue
        if op in I:
            words.append(enc_i(imm(a[2]),reg(a[1]),I[op],reg(a[0]),0x13)); continue
        if op in ISH:
            f7,f3 = ISH[op]; words.append(enc_ish(f7,imm(a[2]),reg(a[1]),f3,reg(a[0]))); continue
        if op in LOAD:                      # lw rd, imm(rs1)
            m = re.match(r'(-?\w+)\((\w+)\)', a[1]); off=imm(m.group(1)); rs1=reg(m.group(2))
            words.append(enc_i(off,rs1,LOAD[op],reg(a[0]),0x03)); continue
        if op in STORE:                     # sw rs2, imm(rs1)
            m = re.match(r'(-?\w+)\((\w+)\)', a[1]); off=imm(m.group(1)); rs1=reg(m.group(2))
            words.append(enc_s(off,reg(a[0]),rs1,STORE[op])); continue
        if op in BR:                        # beq rs1, rs2, label
            off = imm(a[2],LABELS,pc,rel=True)
            words.append(enc_b(off,reg(a[1]),reg(a[0]),BR[op])); continue
        if op == "lui":
            words.append(enc_u(imm(a[1]),reg(a[0]),0x37)); continue
        if op == "auipc":
            words.append(enc_u(imm(a[1]),reg(a[0]),0x17)); continue
        if op == "jal":                     # jal rd, label   (or 'jal label' -> ra)
            if len(a)==1: rd,tgt=1,a[0]
            else: rd,tgt=reg(a[0]),a[1]
            words.append(enc_j(imm(tgt,LABELS,pc,rel=True),rd)); continue
        if op == "jalr":                    # jalr rd, rs1, imm  (or jalr rs1)
            if len(a)==1: rd,rs1,off=1,reg(a[0]),0
            else: rd,rs1,off=reg(a[0]),reg(a[1]),(imm(a[2]) if len(a)>2 else 0)
            words.append(enc_i(off,rs1,0x0,rd,0x67)); continue
        raise ValueError(f"unknown instruction: {op}")
    return words

LABELS = {}

def main():
    if len(sys.argv) != 3:
        print("usage: assemble.py in.s out.hex"); sys.exit(1)
    global LABELS; LABELS = {}
    with open(sys.argv[1]) as f: text = f.read()
    words = assemble(text)
    with open(sys.argv[2],'w') as f:
        for w in words: f.write(f"{w & 0xFFFFFFFF:08x}\n")
    print(f"assembled {len(words)} instructions -> {sys.argv[2]}")

if __name__ == "__main__":
    main()
