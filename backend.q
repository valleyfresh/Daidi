system"p 1234";

\d .backend

connections:flip `dateTime`user`host`ipAddress`handle`playerNo!"ZSS*II"$\:();

.z.po:{[w] $[4>=a:1+exec count i from .backend.connections;
	(`.backend.connections insert .z.Z,.z.u,(.Q.host .z.a;"." sv string "h"$0x0 vs .z.a),w,a;
	0N!"Connection Established by ",string .z.u);
	neg[w]@"Lobby is full"]};

.z.pc:{[w] delete from `.backend.connections where handle = w;0N!(string .z.u)," has left the Lobby"};

shuffle:{system"S ",string`long$.z.t;flip(0N;4)#0N?52};

deal:{h::exec handle from .backend.connections;{neg[x](`showHand;y)}'[h;shuffle[]]};
