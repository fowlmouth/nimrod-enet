## This module contains an interface for reading/writing to a packet in 
## big endian (Big Endian Best Endian) 

import endians

proc swapEndian16*(outp, inp: pointer) = 
  ## copies `inp` to `outp` swapping bytes. Both buffers are supposed to
  ## contain at least 2 bytes.
  var
    i = cast[cstring](inp)
    o = cast[cstring](outp)
  o[0] = i[1]
  o[1] = i[0]

when cpuEndian == bigEndian:
  proc bigEndian16*(outp, inp: pointer) {.inline.} = copyMem(outp, inp, 2)
  proc littleEndian16*(outp, inp: pointer) {.inline.} = swapEndian16(outp, inp)
else:
  proc bigEndian16*(outp, inp: pointer) {.inline.} = swapEndian16(outp, inp)
  proc littleEndian16*(outp, inp: pointer){.inline.} = copyMem(outp, inp, 2)

type
  PBuffer* = var TBuffer
  TBuffer* = object
    data: string
    pos*: int

proc newBuffer* (initialSize: int): TBuffer = 
 result.data = newStringOfCap(initialSize)
 result.data.setLen 0
 result.pos = 0
proc setLen* (b: PBuffer; len: int) {.inline.} = b.data.setLen(len)

import enet
export enet

proc toPacket* (some: PBuffer, flag: TPacketFlag): PPacket = 
  enet.createPacket(some.data.cstring, (some.data.len+1).cint, flag and NoAllocate)


type 
  T_1byte =  int8| uint8|byte|bool|char
  T_2byte = int16|uint16
  T_4byte = int32|uint32|float32
  T_8byte = int64|uint64|float64 
export T_1byte, T_2byte, T_4byte, T_8byte


proc curPos (pkt: PPacket): var char = pkt.data[pkt.referenceCount]
template incPpos (pkt; by; body: stmt): stmt =
  body
  inc pkt.referenceCount, by

proc readLE* [T: int8|uint8|byte|bool|char] (packet: PPacket; outp: var T) =
  incPpos(packet, 1):
    copyMem outp.addr, packet.curPos.addr, 1
proc readLE* [U: int16|uint16] (packet: PPacket; outp: var U) =
  incPpos(packet, 2):
    littleEndian16 outp.addr, packet.curPos.addr, 2
proc readLE* [V: int32|uint32|float32] (packet: PPacket; outp: var V) =
  incPpos(packet, 4):
    littleEndian32 outp.addr, packet.curPos.addr, 4
proc readLE* [W: int64|uint64|float64] (packet: PPacket; outp: var W) =
  incPpos(packet, 8):
    littleEndian64 outp.addr, packet.curPos.addr, 8

proc readBE*[T:   int8| uint8|byte|bool|char](packet: PPacket; outp: var T) =
  copyMem(addr outp, addr packet.data[packet.referenceCount], 1)
  inc packet.referenceCount, 1
proc readBE*[U: int16|uint16](packet: PPacket; outp: var U) =
  bigEndian16(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 2
proc readBE* [V: int32|uint32|float32] (packet: PPacket; outp: var V) =
  bigEndian32(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 4
proc readBE*[W: int64|uint64|float64](packet: PPacket; outp: var W) =
  bigEndian64(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 8

proc readInt16* (packet: PPacket): int16

proc readBE * (packet: PPacket; outp: var string) =
  let len = packet.readInt16.int
  outp = newString(len)
  copyMem(outp[0].addr, packet.data[packet.referenceCount].addr, len)
  inc packet.referenceCount, len

proc readBE* [X] (packet: PPacket; result: var seq[X]) =
  let len = packet.readInt16
  if result.isNil:
    newSeq result, len.int
  else:
    result.setLen len.int
  
  for i in 0 .. < len:
    packet.readBE result[i]


proc curPos* (some: PBuffer): var char = some.data[some.pos]

template incBuffer (buffer, by; body: stmt): stmt =
  setLen buffer, buffer.pos + by
  body
  inc buffer.pos, by

proc writeLE*[T: int8|uint8|byte|bool|char] (buf: PBuffer; val: var T) =
  incBuffer(buf, 1): copyMem(buf.curPos.addr, val.addr, 1)
proc writeLE*[U: int16|uint16] (buf: PBuffer; val: var U) = 
  incBuffer(buf, 2): littleEndian16(buf.curPos.addr, val.addr)
proc writeLE*[V: int32|uint32|float32] (buf: PBuffer; val: var V) =
  incBuffer(buf, 4): littleEndian32(buf.curPos.addr, val.addr)
proc writeLE* (buf: PBuffer; val: string) =
  var L = val.len.int16
  buf.writeLE L
  incBuffer(buf, val.len): copyMem buf.curPos.addr, val.cstring, val.len 

proc writeBE*[T:   int8| uint8|byte|bool|char](buffer: PBuffer; val: var T) =
  setLen buffer, buffer.pos + 1
  copyMem(addr buffer.data[buffer.pos], addr val, 1)
  inc buffer.pos, 1

proc writeBE*[U: int16|uint16](buffer: PBuffer; val: var U) =
  setLen buffer, buffer.pos + 2
  bigEndian16(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 2

proc writeBE*[V: int32|uint32|float32](buffer: PBuffer; val: var V) =
  setLen buffer, buffer.pos + 4
  bigEndian32(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 4
  
proc writeBE*[W: int64|uint64|float64](buffer: PBuffer; val: var W) =
  setLen buffer, buffer.pos + 8
  bigEndian64(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 8


proc writeCopy*[T: TNumber|bool|char|byte](buffer: PBuffer; val: T) =
  var v = val # a shallow copy
  #shallowCopy v, val
  buffer.writeBE v

proc writeBE* (buffer: PBuffer; valString: string) =
  if valString.isNIL:
    buffer.writeCopy 0'i16
    return
  
  var length = valString.len.int16
  buffer.writeBE length
  setLen buffer, buffer.pos + length.int
  copyMem buffer.data[buffer.pos].addr, valString.cstring, length.int
  inc buffer.pos, length.int

import typetraits
proc writeBE* [X] (buffer: PBuffer; val: var seq[X]) =
  if val.isNIL:
    buffer.writeCopy 0'i16
    return
  
  var len = val.len.int16
  buffer.writeBE len
  for i in 0 .. < len:
    buffer.writeBE val[i]



proc writeCopy* (buffer: PBuffer; val: string) {.inline.}=
  buffer.writeBE val


proc readInt8*(packet: PPacket): int8 =
  readBE packet, result
proc readInt16*(packet: PPacket): int16 =
  readBE packet, result
proc readInt32*(packet: PPacket): int32 =
  readBE packet, result
proc readInt64*(packet: PPacket): int64 =
  readBE packet, result
proc readFloat32*(packet: PPacket): float32 =
  readBE packet, result
proc readFloat64*(packet: PPacket): float64 =
  readBE packet, result

proc readStr*(packet: PPacket): string =
  packet.readBE result

proc readChar*(packet: PPacket): char {.inline.} = readInt8(packet).char
proc readBool*(packet: PPacket): bool {.inline.} = readInt8(packet).bool

proc readSeq* (packet: PPacket; T: typedesc): seq[T] {.inline.} = packet.readBE(result)

