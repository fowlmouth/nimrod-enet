import endians

proc swapEndian16*(outp, inp: pointer) = 
  ## copies `inp` to `outp` swapping bytes. Both buffers are supposed to
  ## contain at least 2 bytes.
  var i = cast[cstring](inp)
  var o = cast[cstring](outp)
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
 result.data = newString(initialSize)
 result.data.setLen 0
 result.pos = 0
proc setLen* (b: PBuffer; len: int) {.inline.} = b.data.setLen(len)

import enet
proc toPacket* (some: PBuffer, flag: TPacketFlag): PPacket = enet.createPacket(some.data, flag)

type 
  T_1byte = int8|uint8|byte|bool|char
  T_2byte = int16|uint16
  T_4byte = int32|uint32|float32
  T_8byte = int64|uint64|float64 

proc read*[T: int16|uint16](packet: PPacket; outp: var T) =
  bigEndian16(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 2
proc read*[T: float32|int32|uint32](packet: PPacket; outp: var T) =
  bigEndian32(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 4
proc read*[T: float64|int64|uint64](packet: PPacket; outp: var T) =
  bigEndian64(addr outp, addr packet.data[packet.referenceCount])
  inc packet.referenceCount, 8
proc read*[T: int8|uint8|byte|bool|char](packet: PPacket; outp: var T) =
  copyMem(addr outp, addr packet.data[packet.referenceCount], 1)
  inc packet.referenceCount, 1


proc writeBE*[T: int16|uint16](buffer: PBuffer; val: var T) =
  setLen buffer, buffer.pos + 2
  bigEndian16(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 2
proc writeBE*[T: int32|uint32|float32](buffer: PBuffer; val: var T) =
  setLen buffer, buffer.pos + 4
  bigEndian32(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 4
proc writeBE*[T: int64|uint64|float64](buffer: PBuffer; val: var T) =
  setLen buffer, buffer.pos + 8
  bigEndian64(addr buffer.data[buffer.pos], addr val)
  inc buffer.pos, 8
proc writeBE*[T: char|int8|uint8|byte|bool](buffer: PBuffer; val: var T) =
  setLen buffer, buffer.pos + 1
  copyMem(addr buffer.data[buffer.pos], addr val, 1)
  inc buffer.pos, 1


proc write* (buffer: PBuffer; val: string) =
  var length = len(val).uint16
  writeBE buffer, length
  setLen buffer, buffer.pos + length.int
  copyMem buffer.data[buffer.pos].addr, val.cstring, length.int
  inc buffer.pos, length.int
proc write*[T: TNumber|bool|char|byte](buffer: PBuffer; val: T) =
  var v: T
  shallowCopy v, val
  writeBE buffer, v

proc readInt8*(packet: PPacket): int8 =
  read packet, result
proc readInt16*(packet: PPacket): int16 =
  read packet, result
proc readInt32*(packet: PPacket): int32 =
  read packet, result
proc readInt64*(packet: PPacket): int64 =
  read packet, result
proc readFloat32*(packet: PPacket): float32 =
  read packet, result
proc readFloat64*(packet: PPacket): float64 =
  read packet, result
proc readStr*(packet: PPacket): string =
  let len = readInt16(packet).int
  result = ""
  if len > 0:
    result.setLen len
    copyMem(addr result[0], addr packet.data[packet.referenceCount], len)
    inc packet.referenceCount, len
proc readChar*(packet: PPacket): char {.inline.} = readInt8(packet).char
proc readBool*(packet: PPacket): bool {.inline.} = readInt8(packet).bool
