def combine(a,b,c):
    print a * 8 + b, hex(c)

u = 0
r = 1
d = 2
l = 4

combine(u,u, 0x85)
combine(u,r, 0x85)
combine(u,l, 0x84)

combine(r,u, 0x03)
combine(r,r, 0x03)
combine(r,d, 0x84)

combine(d,r, 0x02)
combine(d,d, 0x85)
combine(d,l, 0x03)

combine(l,u, 0x02)
combine(l,d, 0x85)
combine(l,l, 0x03)

w = 0x6f
v = w & 15
td = w & 16
ct = w & 32
cn = w & 64
dn = w & 128
print v,td,ct,cn,dn

# 01f6 019e 0178 013a
