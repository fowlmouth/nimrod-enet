when defined(Linux):
  const Lib = "libenet.so.1(|.0.3)"
else:
  {.error: "Your platform has not been accounted for."}

const 
  ENET_VERSION_MAJOR* = 1
  ENET_VERSION_MINOR* = 3
  ENET_VERSION_PATCH* = 3
template ENET_VERSION_CREATE(major, minor, patch: expr): expr = 
  (((major) shl 16) or ((minor) shl 8) or (patch))

const 
  ENET_VERSION* = ENET_VERSION_CREATE(ENET_VERSION_MAJOR, ENET_VERSION_MINOR, 
                                      ENET_VERSION_PATCH)
type 
  TVersion* = cuint
  TSocketType*{.size: sizeof(cint).} = enum 
    ENET_SOCKET_TYPE_STREAM = 1, ENET_SOCKET_TYPE_DATAGRAM = 2
  TSocketWait*{.size: sizeof(cint).} = enum 
    ENET_SOCKET_WAIT_NONE = 0, ENET_SOCKET_WAIT_SEND = (1 shl 0), 
    ENET_SOCKET_WAIT_RECEIVE = (1 shl 1)
  TSocketOption*{.size: sizeof(cint).} = enum 
    ENET_SOCKOPT_NONBLOCK = 1, ENET_SOCKOPT_BROADCAST = 2, 
    ENET_SOCKOPT_RCVBUF = 3, ENET_SOCKOPT_SNDBUF = 4, 
    ENET_SOCKOPT_REUSEADDR = 5
const 
  ENET_HOST_ANY* = 0
  ENET_HOST_BROADCAST* = 0xFFFFFFFF
  ENET_PORT_ANY* = 0
  
  ENET_PROTOCOL_MINIMUM_MTU* = 576
  ENET_PROTOCOL_MAXIMUM_MTU* = 4096
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS* = 32
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE* = 4096
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE* = 32768
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT* = 1
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT* = 255
  ENET_PROTOCOL_MAXIMUM_PEER_ID* = 0x00000FFF
type
  PAddress* = ptr TAddress
  TAddress*{.pure, final.} = object 
    host*: cuint
    port*: cushort
  
  TPacketFlag*{.size: sizeof(cint).} = enum 
    FlagReliable = (1 shl 0), 
    FlagUnsequenced = (1 shl 1), 
    NoAllocate = (1 shl 2), 
    UnreliableFragment = (1 shl 3)
  
  TENetListNode*{.pure, final.} = object 
      next*: ptr T_ENetListNode
      previous*: ptr T_ENetListNode

  PENetListIterator* = ptr TENetListNode
  TENetList*{.pure, final.} = object 
    sentinel*: TENetListNode
  
  T_ENetPacket*{.pure, final.} = object 
  TPacketFreeCallback* = proc (a2: ptr T_ENetPacket){.cdecl.}
  
  PPacket* = ptr TPacket
  TPacket*{.pure, final.} = object 
    referenceCount*: csize
    flags*: cuint
    data*: ptr cuchar
    dataLength*: csize
    freeCallback*: TPacketFreeCallback

  TAcknowledgement*{.pure, final.} = object 
    acknowledgementList*: TEnetListNode
    sentTime*: cuint
    command*: TEnetProtocol

  TOutgoingCommand*{.pure, final.} = object 
    outgoingCommandList*: TEnetListNode
    reliableSequenceNumber*: cushort
    unreliableSequenceNumber*: cushort
    sentTime*: cuint
    roundTripTimeout*: cuint
    roundTripTimeoutLimit*: cuint
    fragmentOffset*: cuint
    fragmentLength*: cushort
    sendAttempts*: cushort
    command*: TEnetProtocol
    packet*: ptr TPacket

  TIncomingCommand*{.pure, final.} = object 
    incomingCommandList*: TEnetListNode
    reliableSequenceNumber*: cushort
    unreliableSequenceNumber*: cushort
    command*: TEnetProtocol
    fragmentCount*: cuint
    fragmentsRemaining*: cuint
    fragments*: ptr cuint
    packet*: ptr TPacket

  TPeerState*{.size: sizeof(cint).} = enum 
    ENET_PEER_STATE_DISCONNECTED = 0, ENET_PEER_STATE_CONNECTING = 1, 
    ENET_PEER_STATE_ACKNOWLEDGING_CONNECT = 2, 
    ENET_PEER_STATE_CONNECTION_PENDING = 3, 
    ENET_PEER_STATE_CONNECTION_SUCCEEDED = 4, ENET_PEER_STATE_CONNECTED = 5, 
    ENET_PEER_STATE_DISCONNECT_LATER = 6, ENET_PEER_STATE_DISCONNECTING = 7, 
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8, ENET_PEER_STATE_ZOMBIE = 9
  
  TENetProtocolCommand*{.size: sizeof(cint).} = enum 
    ENET_PROTOCOL_COMMAND_NONE = 0, ENET_PROTOCOL_COMMAND_ACKNOWLEDGE = 1, 
    ENET_PROTOCOL_COMMAND_CONNECT = 2, 
    ENET_PROTOCOL_COMMAND_VERIFY_CONNECT = 3, 
    ENET_PROTOCOL_COMMAND_DISCONNECT = 4, ENET_PROTOCOL_COMMAND_PING = 5, 
    ENET_PROTOCOL_COMMAND_SEND_RELIABLE = 6, 
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE = 7, 
    ENET_PROTOCOL_COMMAND_SEND_FRAGMENT = 8, 
    ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9, 
    ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10, 
    ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11, 
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12, 
    ENET_PROTOCOL_COMMAND_COUNT = 13, ENET_PROTOCOL_COMMAND_MASK = 0x0000000F
  TENetProtocolFlag*{.size: sizeof(cint).} = enum 
    ENET_PROTOCOL_HEADER_SESSION_SHIFT = 12,
    ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 shl 6), 
    ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 shl 7), 
    ENET_PROTOCOL_HEADER_SESSION_MASK = (3 shl 12), 
    ENET_PROTOCOL_HEADER_FLAG_COMPRESSED = (1 shl 14), 
    ENET_PROTOCOL_HEADER_FLAG_SENT_TIME = (1 shl 15),
    ENET_PROTOCOL_HEADER_FLAG_MASK = ENET_PROTOCOL_HEADER_FLAG_COMPRESSED.cint or
        ENET_PROTOCOL_HEADER_FLAG_SENT_TIME.cint
  
  TENetProtocolHeader*{.pure, final.} = object 
    peerID*: cushort
    sentTime*: cushort

  TENetProtocolCommandHeader*{.pure, final.} = object 
    command*: cuchar
    channelID*: cuchar
    reliableSequenceNumber*: cushort

  TENetProtocolAcknowledge*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    receivedReliableSequenceNumber*: cushort
    receivedSentTime*: cushort

  TENetProtocolConnect*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    outgoingPeerID*: cushort
    incomingSessionID*: cuchar
    outgoingSessionID*: cuchar
    mtu*: cuint
    windowSize*: cuint
    channelCount*: cuint
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    connectID*: cuint
    data*: cuint

  TENetProtocolVerifyConnect*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    outgoingPeerID*: cushort
    incomingSessionID*: cuchar
    outgoingSessionID*: cuchar
    mtu*: cuint
    windowSize*: cuint
    channelCount*: cuint
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    connectID*: cuint

  TENetProtocolBandwidthLimit*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint

  TENetProtocolThrottleConfigure*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint

  TENetProtocolDisconnect*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    data*: cuint

  TENetProtocolPing*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader

  TENetProtocolSendReliable*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    dataLength*: cushort

  TENetProtocolSendUnreliable*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    unreliableSequenceNumber*: cushort
    dataLength*: cushort

  TENetProtocolSendUnsequenced*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    unsequencedGroup*: cushort
    dataLength*: cushort

  TENetProtocolSendFragment*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
    startSequenceNumber*: cushort
    dataLength*: cushort
    fragmentCount*: cuint
    fragmentNumber*: cuint
    totalLength*: cuint
    fragmentOffset*: cuint

  TENetProtocol*{.pure, final.} = object 
    header*: TENetProtocolCommandHeader
const 
  ENET_BUFFER_MAXIMUM* = (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
  ENET_HOST_RECEIVE_BUFFER_SIZE          = 256 * 1024
  ENET_HOST_SEND_BUFFER_SIZE             = 256 * 1024
  ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL  = 1000
  ENET_HOST_DEFAULT_MTU                  = 1400

  ENET_PEER_DEFAULT_ROUND_TRIP_TIME      = 500
  ENET_PEER_DEFAULT_PACKET_THROTTLE      = 32
  ENET_PEER_PACKET_THROTTLE_SCALE        = 32
  ENET_PEER_PACKET_THROTTLE_COUNTER      = 7
  ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2
  ENET_PEER_PACKET_THROTTLE_DECELERATION = 2
  ENET_PEER_PACKET_THROTTLE_INTERVAL     = 5000
  ENET_PEER_PACKET_LOSS_SCALE            = (1 shl 16)
  ENET_PEER_PACKET_LOSS_INTERVAL         = 10000
  ENET_PEER_WINDOW_SIZE_SCALE            = 64 * 1024
  ENET_PEER_TIMEOUT_LIMIT                = 32
  ENET_PEER_TIMEOUT_MINIMUM              = 5000
  ENET_PEER_TIMEOUT_MAXIMUM              = 30000
  ENET_PEER_PING_INTERVAL                = 500
  ENET_PEER_UNSEQUENCED_WINDOWS          = 64
  ENET_PEER_UNSEQUENCED_WINDOW_SIZE      = 1024
  ENET_PEER_FREE_UNSEQUENCED_WINDOWS     = 32
  ENET_PEER_RELIABLE_WINDOWS             = 16
  ENET_PEER_RELIABLE_WINDOW_SIZE         = 0x1000
  ENET_PEER_FREE_RELIABLE_WINDOWS        = 8

when defined(Linux):
  import posix
  const
    ENET_SOCKET_NULL*: cint = -1
  type 
    TENetSocket* = cint
    TENetBuffer*{.pure, final.} = object 
      data*: pointer
      dataLength*: csize
  template ENET_HOST_TO_NET_16*(value: expr): expr = 
    (htons(value))
  template ENET_HOST_TO_NET_32*(value: expr): expr = 
    (htonl(value))
  template ENET_NET_TO_HOST_16*(value: expr): expr = 
    (ntohs(value))
  template ENET_NET_TO_HOST_32*(value: expr): expr = 
    (ntohl(value))

  type 
    TENetSocketSet* = Tfd_set
  template ENET_SOCKETSET_EMPTY*(sockset: expr): expr = 
    FD_ZERO(addr((sockset)))
  template ENET_SOCKETSET_ADD*(sockset, socket: expr): expr = 
    FD_SET(socket, addr((sockset)))
  template ENET_SOCKETSET_REMOVE*(sockset, socket: expr): expr = 
    FD_CLEAR(socket, addr((sockset)))
  template ENET_SOCKETSET_CHECK*(sockset, socket: expr): expr = 
    FD_ISSET(socket, addr((sockset)))

when defined(Windows):
  ## put the content of win32.h in here


type 
  TChannel*{.pure, final.} = object 
    outgoingReliableSequenceNumber*: cushort
    outgoingUnreliableSequenceNumber*: cushort
    usedReliableWindows*: cushort
    reliableWindows*: array[0..ENET_PEER_RELIABLE_WINDOWS - 1, cushort]
    incomingReliableSequenceNumber*: cushort
    incomingUnreliableSequenceNumber*: cushort
    incomingReliableCommands*: TENetList
    incomingUnreliableCommands*: TENetList

  PPeer* = ptr TPeer
  TPeer*{.pure, final.} = object 
    dispatchList*: TEnetListNode
    host*: ptr THost
    outgoingPeerID*: cushort
    incomingPeerID*: cushort
    connectID*: cuint
    outgoingSessionID*: cuchar
    incomingSessionID*: cuchar
    address*: TAddress
    data*: pointer
    state*: TPeerState
    channels*: ptr TChannel
    channelCount*: csize
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    incomingBandwidthThrottleEpoch*: cuint
    outgoingBandwidthThrottleEpoch*: cuint
    incomingDataTotal*: cuint
    outgoingDataTotal*: cuint
    lastSendTime*: cuint
    lastReceiveTime*: cuint
    nextTimeout*: cuint
    earliestTimeout*: cuint
    packetLossEpoch*: cuint
    packetsSent*: cuint
    packetsLost*: cuint
    packetLoss*: cuint
    packetLossVariance*: cuint
    packetThrottle*: cuint
    packetThrottleLimit*: cuint
    packetThrottleCounter*: cuint
    packetThrottleEpoch*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    packetThrottleInterval*: cuint
    lastRoundTripTime*: cuint
    lowestRoundTripTime*: cuint
    lastRoundTripTimeVariance*: cuint
    highestRoundTripTimeVariance*: cuint
    roundTripTime*: cuint
    roundTripTimeVariance*: cuint
    mtu*: cuint
    windowSize*: cuint
    reliableDataInTransit*: cuint
    outgoingReliableSequenceNumber*: cushort
    acknowledgements*: TENetList
    sentReliableCommands*: TENetList
    sentUnreliableCommands*: TENetList
    outgoingReliableCommands*: TENetList
    outgoingUnreliableCommands*: TENetList
    dispatchedCommands*: TENetList
    needsDispatch*: cint
    incomingUnsequencedGroup*: cushort
    outgoingUnsequencedGroup*: cushort
    unsequencedWindow*: array[0..ENET_PEER_UNSEQUENCED_WINDOW_SIZE div 32 - 1, 
                              cuint]
    eventData*: cuint

  TCompressor*{.pure, final.} = object 
    context*: pointer
    compress*: proc (context: pointer; inBuffers: ptr TEnetBuffer; 
                     inBufferCount: csize; inLimit: csize; 
                     outData: ptr cuchar; outLimit: csize): csize{.cdecl.}
    decompress*: proc (context: pointer; inData: ptr cuchar; inLimit: csize; 
                       outData: ptr cuchar; outLimit: csize): csize{.cdecl.}
    destroy*: proc (context: pointer){.cdecl.}

  TChecksumCallback* = proc (buffers: ptr TEnetBuffer; bufferCount: csize): cuint{.
      cdecl.}
  
  PHost* = ptr THost
  THost*{.pure, final.} = object 
    socket*: TEnetSocket
    address*: TAddress
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    bandwidthThrottleEpoch*: cuint
    mtu*: cuint
    randomSeed*: cuint
    recalculateBandwidthLimits*: cint
    peers*: ptr TPeer
    peerCount*: csize
    channelLimit*: csize
    serviceTime*: cuint
    dispatchQueue*: TEnetList
    continueSending*: cint
    packetSize*: csize
    headerFlags*: cushort
    commands*: array[0..ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS - 1, 
                     TEnetProtocol]
    commandCount*: csize
    buffers*: array[0..ENET_BUFFER_MAXIMUM - 1, TEnetBuffer]
    bufferCount*: csize
    checksum*: TChecksumCallback
    compressor*: TCompressor
    packetData*: array[0..ENET_PROTOCOL_MAXIMUM_MTU - 1, 
                       array[0..2 - 1, cuchar]]
    receivedAddress*: TAddress
    receivedData*: ptr cuchar
    receivedDataLength*: csize
    totalSentData*: cuint
    totalSentPackets*: cuint
    totalReceivedData*: cuint
    totalReceivedPackets*: cuint
  
  TEventType*{.size: sizeof(cint).} = enum 
    EvtNone = 0, EvtConnect = 1, 
    EvtDisconnect = 2, EvtReceive = 3
  PEvent* = ptr TEvent
  TEvent*{.pure, final.} = object 
    kind*: TEventType
    peer*: ptr TPeer
    channelID*: cuchar
    data*: cuint
    packet*: ptr TPacket

  TENetCallbacks*{.pure, final.} = object 
    malloc*: proc (size: csize): pointer{.cdecl.}
    free*: proc (memory: pointer){.cdecl.}
    no_memory*: proc (){.cdecl.}

proc enet_malloc*(a2: csize): pointer{.
  cdecl, importc: "enet_malloc", dynlib: Lib.}
proc enet_free*(a2: pointer){.
  cdecl, importc: "enet_free", dynlib: Lib.}

proc enetInit*(): cint{.
  cdecl, importc: "enet_initialize", dynlib: Lib.}
proc enetInit*(version: TVersion; inits: ptr TENetCallbacks): cint{.
  cdecl, importc: "enet_initialize_with_callbacks", dynlib: Lib.}
proc enetDeinit*(){.
  cdecl, importc: "enet_deinitialize", dynlib: Lib.}
proc enet_time_get*(): cuint{.
  cdecl, importc: "enet_time_get", dynlib: Lib.}
proc enet_time_set*(a2: cuint){.
  cdecl, importc: "enet_time_set", dynlib: Lib.}
proc enet_socket_create*(a2: TSocketType): TEnetSocket{.
  cdecl, importc: "enet_socket_create", dynlib: Lib.}
proc enet_socket_bind*(a2: TEnetSocket; a3: ptr TAddress): cint{.cdecl, 
    importc: "enet_socket_bind", dynlib: Lib.}
proc enet_socket_listen*(a2: TEnetSocket; a3: cint): cint{.cdecl, 
    importc: "enet_socket_listen", dynlib: Lib.}
proc enet_socket_accept*(a2: TEnetSocket; a3: ptr TAddress): TEnetSocket{.
    cdecl, importc: "enet_socket_accept", dynlib: Lib.}
proc enet_socket_connect*(a2: TEnetSocket; a3: ptr TAddress): cint{.cdecl, 
    importc: "enet_socket_connect", dynlib: Lib.}
proc enet_socket_send*(a2: TEnetSocket; a3: ptr TAddress; 
                       a4: ptr TEnetBuffer; a5: csize): cint{.cdecl, 
    importc: "enet_socket_send", dynlib: Lib.}
proc enet_socket_receive*(a2: TEnetSocket; a3: ptr TAddress; 
                          a4: ptr TEnetBuffer; a5: csize): cint{.cdecl, 
    importc: "enet_socket_receive", dynlib: Lib.}
proc enet_socket_wait*(a2: TEnetSocket; a3: ptr cuint; a4: cuint): cint{.cdecl, 
    importc: "enet_socket_wait", dynlib: Lib.}
proc enet_socket_set_option*(a2: TEnetSocket; a3: TSocketOption; a4: cint): cint{.
    cdecl, importc: "enet_socket_set_option", dynlib: Lib.}
proc enet_socket_destroy*(a2: TEnetSocket){.cdecl, 
    importc: "enet_socket_destroy", dynlib: Lib.}
proc enet_socketset_select*(a2: TEnetSocket; a3: ptr TENetSocketSet; 
                            a4: ptr TENetSocketSet; a5: cuint): cint{.
  cdecl, importc: "enet_socketset_select", dynlib: Lib.}
proc setHost*(address: PAddress; hostName: cstring): cint{.
  cdecl, importc: "enet_address_set_host", dynlib: Lib.}
proc getHostIP*(address: PAddress; hostName: cstring; nameLength: csize): cint{.
  cdecl, importc: "enet_address_get_host_ip", dynlib: Lib.}
proc enet_address_get_host*(address: ptr TAddress; hostName: cstring; 
                            nameLength: csize): cint{.cdecl, 
    importc: "enet_address_get_host", dynlib: Lib.}

proc createPacket*(data: pointer; len: csize; flag: TPacketFlag): PPacket{.
  cdecl, importc: "enet_packet_create", dynlib: Lib.}
proc destroy*(a2: PPacket){.
  cdecl, importc: "enet_packet_destroy", dynlib: Lib.}
proc resize*(a2: ptr TPacket; a3: csize): cint{.
  cdecl, importc: "enet_packet_resize", dynlib: Lib.}

proc crc32*(a2: ptr TEnetBuffer; a3: csize): cuint{.cdecl, 
    importc: "enet_crc32", dynlib: Lib.}

proc createHost*(address: ptr TAddress; a3, a4: csize; a5, a6: cuint): ptr THost{.
  cdecl, importc: "enet_host_create", dynlib: Lib.}

proc destroy*(host: PHost){.
  cdecl, importc: "enet_host_destroy", dynlib: Lib.}
proc connect*(host: PHost; address: ptr TAddress; a4: csize; a5: cuint): PPeer{.
  cdecl, importc: "enet_host_connect", dynlib: Lib.}

proc enet_host_check_events*(a2: ptr THost; a3: ptr TEvent): cint{.
    cdecl, importc: "enet_host_check_events", dynlib: Lib.}
proc hostService*(host: PHost; event: PEvent; timeout: cuint): cint{.
  cdecl, importc: "enet_host_service", dynlib: Lib.}
proc enet_host_flush*(a2: ptr THost){.cdecl, importc: "enet_host_flush", 
    dynlib: Lib.}
proc broadcast*(a2: ptr THost; a3: cuchar; a4: ptr TPacket){.
  cdecl, importc: "enet_host_broadcast", dynlib: Lib.}
proc enet_host_compress*(a2: ptr THost; a3: ptr TCompressor){.cdecl, 
    importc: "enet_host_compress", dynlib: Lib.}
proc enet_host_compress_with_range_coder*(host: ptr THost): cint{.cdecl, 
    importc: "enet_host_compress_with_range_coder", dynlib: Lib.}
proc enet_host_channel_limit*(a2: ptr THost; a3: csize){.cdecl, 
    importc: "enet_host_channel_limit", dynlib: Lib.}
proc enet_host_bandwidth_limit*(a2: ptr THost; a3: cuint; a4: cuint){.
    cdecl, importc: "enet_host_bandwidth_limit", dynlib: Lib.}
proc enet_host_bandwidth_throttle*(a2: ptr THost){.cdecl, 
    importc: "enet_host_bandwidth_throttle", dynlib: Lib.}
proc send*(a2: PPeer; a3: cuchar; a4: PPacket): cint{.
  cdecl, importc: "enet_peer_send", dynlib: Lib.}
proc enet_peer_receive*(a2: ptr TPeer; channelID: ptr cuchar): ptr TPacket{.
    cdecl, importc: "enet_peer_receive", dynlib: Lib.}
proc enet_peer_ping*(a2: ptr TPeer){.cdecl, importc: "enet_peer_ping", 
    dynlib: Lib.}
proc enet_peer_reset*(a2: ptr TPeer){.cdecl, importc: "enet_peer_reset", 
    dynlib: Lib.}
proc enet_peer_disconnect*(a2: ptr TPeer; a3: cuint){.cdecl, 
    importc: "enet_peer_disconnect", dynlib: Lib.}
proc enet_peer_disconnect_now*(a2: ptr TPeer; a3: cuint){.cdecl, 
    importc: "enet_peer_disconnect_now", dynlib: Lib.}
proc enet_peer_disconnect_later*(a2: ptr TPeer; a3: cuint){.cdecl, 
    importc: "enet_peer_disconnect_later", dynlib: Lib.}
proc enet_peer_throttle_configure*(a2: ptr TPeer; a3: cuint; a4: cuint; 
                                   a5: cuint){.cdecl, 
    importc: "enet_peer_throttle_configure", dynlib: Lib.}
proc enet_peer_throttle*(a2: ptr TPeer; a3: cuint): cint{.cdecl, 
    importc: "enet_peer_throttle", dynlib: Lib.}
proc enet_peer_reset_queues*(a2: ptr TPeer){.cdecl, 
    importc: "enet_peer_reset_queues", dynlib: Lib.}
proc enet_peer_setup_outgoing_command*(a2: ptr TPeer; 
    a3: ptr TOutgoingCommand){.cdecl, importc: "enet_peer_setup_outgoing_command", 
                                   dynlib: Lib.}
proc enet_peer_queue_outgoing_command*(a2: ptr TPeer; 
    a3: ptr TEnetProtocol; a4: ptr TPacket; a5: cuint; a6: cushort): ptr TOutgoingCommand{.
    cdecl, importc: "enet_peer_queue_outgoing_command", dynlib: Lib.}
proc enet_peer_queue_incoming_command*(a2: ptr TPeer; 
    a3: ptr TEnetProtocol; a4: ptr TPacket; a5: cuint): ptr TIncomingCommand{.
    cdecl, importc: "enet_peer_queue_incoming_command", dynlib: Lib.}
proc enet_peer_queue_acknowledgement*(a2: ptr TPeer; a3: ptr TEnetProtocol; 
                                      a4: cushort): ptr TAcknowledgement{.
    cdecl, importc: "enet_peer_queue_acknowledgement", dynlib: Lib.}
proc enet_peer_dispatch_incoming_unreliable_commands*(a2: ptr TPeer; 
    a3: ptr TChannel){.cdecl, importc: "enet_peer_dispatch_incoming_unreliable_commands", 
                           dynlib: Lib.}
proc enet_peer_dispatch_incoming_reliable_commands*(a2: ptr TPeer; 
    a3: ptr TChannel){.cdecl, importc: "enet_peer_dispatch_incoming_reliable_commands", 
                           dynlib: Lib.}
proc enet_range_coder_create*(): pointer{.cdecl, 
    importc: "enet_range_coder_create", dynlib: Lib.}
proc enet_range_coder_destroy*(a2: pointer){.cdecl, 
    importc: "enet_range_coder_destroy", dynlib: Lib.}
proc enet_range_coder_compress*(a2: pointer; a3: ptr TEnetBuffer; a4: csize; 
                                a5: csize; a6: ptr cuchar; a7: csize): csize{.
    cdecl, importc: "enet_range_coder_compress", dynlib: Lib.}
proc enet_range_coder_decompress*(a2: pointer; a3: ptr cuchar; a4: csize; 
                                  a5: ptr cuchar; a6: csize): csize{.cdecl, 
    importc: "enet_range_coder_decompress", dynlib: Lib.}
proc enet_protocol_command_size*(a2: cuchar): csize{.cdecl, 
    importc: "enet_protocol_command_size", dynlib: Lib.}