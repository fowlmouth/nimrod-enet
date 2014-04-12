
import unsigned, endians
when defined(useEnet):
  import enet
when defined(useLacewing):
  import lw

when not defined(useEnet) and not defined(useLacewing):
  {.error: "No networking for pkt_tools, compile with -d:useEnet or -d:useLacewing".}

when defined(networkBigEndian):
  template ne16 (a,b): expr = bigEndian16(a,b)
  template ne32 (a,b): expr = bigEndian32(a,b)
  template ne64 (a,b): expr = bigEndian64(a,b)
else:
  template ne16 (a,b): expr = littleEndian16(a,b)
  template ne32 (a,b): expr = littleEndian32(a,b)
  template ne64 (a,b): expr = littleEndian64(a,b)


type TScalar* = int8 | uint8 | byte | char | bool |
                int16| uint16| int32|uint32|
                float32|float64|int64|uint64

type
  PIpkt* = var Ipkt
  Ipkt*  = object
    data: cstring
    index, dataSize: int
proc to_ipkt* (dat:cstring,size:TInteger): IPkt =
  IPkt(data:dat, index:0, dataSize:size.int)
when defined(useEnet):
  proc to_ipkt* (P:PPacket): IPkt =
    to_ipkt(p.data, p.dataLength)

proc `>>`* [T: TScalar] (pkt:PIpkt; right:var T) = 
  template data: expr = pkt.data[pkt.index].addr
  const sizeT = sizeof(T)
  when sizeT == 2:
    ne16(right.addr, data)
  elif sizeT == 4:
    ne32(right.addr, data)
  elif sizeT == 8:
    ne64(right.addr, data)
  elif sizeT == 1:
    right = cast[ptr t](data)[]
  
  pkt.index.inc sizeof(T)

proc `>>`* (pkt:PIpkt; right:var string) = 
  var len: int16
  pkt >> len
  if right.isNil: right = newString(len)
  else:           right.setLen len.int
  copyMem(right.cstring, pkt.data[pkt.index].addr, len)
  pkt.index.inc len

proc `>>`* [T:TScalar] (pkt:PIpkt; right:var seq[T])=
  mixin `>>`
  var len: int16
  pkt >> len
  if right.isNil: right.newSeq len.int
  else:           right.setLen len.int
  for idx in 0 .. high(right):
    pkt >> right[idx]
proc `>>`* [T] (pkt:PIpkt; right:var openarray[T]) =
  mixin `>>`
  var len: int16
  pkt >> len
  assert len.int == right.len
  for idx in 0 .. high(right):
    pkt >> right[idx]


type
  OPkt* = object
    bytes: seq[char]
    index*: int
proc initOpkt* (size = 512): OPkt =
  Opkt(
    bytes: newseq[char](size)
  )

proc data*  (outp: var OPkt): ptr char = outp.bytes[outp.index].addr
proc data0* (outp: var OPkt): ptr char = outp.bytes[0].addr

when defined(useEnet):
  proc createPacket* (O:var OPKT; flags: cint): PPacket {.inline.} =
    createPacket( o.data0, o.index, flags or NoAllocate.cint ) 

proc ensureSize*(pkt:var Opkt; size: int) =
  if pkt.bytes.len < pkt.index+size:
    pkt.bytes.setLen pkt.index+size

proc `<<` * [T:TScalar] (outp: var OPkt; right: T) =
  const sizeT = sizeof(T)
  outp.ensureSize sizeT
  when sizeT == 2:
    var right = right
    ne16(outp.data, right.addr)
  elif sizeT == 4:
    var right = right
    ne32(outp.data, right.addr)
  elif sizeT == 8:
    var right = right
    ne64(outp.data, right.addr)
  elif sizeT == 1:
    data(outp)[] = cast[char](right)
  
  inc outp.index, sizeT
proc `<<` * (outp: var OPkt; right: string) =
  let strlen = right.len
  outp << strlen.int16
  outp.ensureSize strlen
  copyMem outp.data, right.cstring, strlen
  inc outp.index, strlen

proc `<<` * [T] (outp: var OPkt; right: openarray[T]) =
  mixin `<<`
  outp << right.len.int16
  outp.ensureSize right.len * sizeof(T)
  for idx in 0 .. high(right):
    outp << right[idx]


when defined(useLacewing):
  proc send* (udp:LW_UDP; address:LW_Addr; pkt:var OPkt){.inline.}=
    udp.send(address, pkt.data0, pkt.index.csize)


