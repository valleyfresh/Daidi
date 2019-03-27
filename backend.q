system"p 1234";

.log.connections:flip `dateTime`user`host`ipAddress`connection`handle`duration!"ZSS*SIV"$\:();

.z.po:{[w] `.log.connections insert .z.Z,.z.u,(.Q.host .z.a;"." sv string "h"$0x0 vs .z.a),`opened,w,0Nv;0N!"Connection Established"};
.z.pc:{[w] update connection:`closed,duration:"v"$80000*.z.Z-dateTime from `.log.connections where handle = w};

shuffle:{system"S ",string`long$.z.t;flip(0N;4)#0N?52};

deal:{h::exec handle from .log.connections;{neg[x](`showHand;y)}'[h;shuffle[]]};
