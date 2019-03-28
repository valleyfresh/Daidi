\p 1234
\d .backend

//Connection logic
connections:flip `dateTime`user`host`ipAddress`handle`playerNo`turn!"ZSS*IIB"$\:();

.z.po:{[w] $[4>=a:1+exec count i from .backend.connections;
	(`.backend.connections insert .z.Z,.z.u,(.Q.host .z.a;"." sv string "h"$0x0 vs .z.a),w,a,0b;
	0N!"Connection Established by ",string .z.u);
	neg[w]@"Lobby is full"]};

.z.pc:{[w] delete from `.backend.connections where handle = w;0N!(string .z.u)," has left the Lobby"};


//Card Dealing and Turn logic
cardDeck:til[52]!((string 2+til[9]),"JQKA")cross"DCHS";

shuffle:{system"S ",string`long$.z.t;flip(0N;4)#0N?52};

deal:{h::exec handle from .backend.connections;{neg[x](`showHand;y)}'[h;hand::shuffle[]]};

startTurn:{update turn:max each 3=.backend.hand from `.backend.connections};

nextTurn:{update turn:-1 rotate turn from `.backend.connections};

//Validations
//runJob:{if[52=count raze .backend.hand;firstHand[x]};

//General Validation
checkTurn:{if[first 0=exec turn from .backend.connections where handle=.z.w;neg[.z.w]@"It is not your turn"]};
checkCardInHand:{[cards] if[not min .backend.cardDeck?cards in .backend.hand[exec playerNo from .backend.connections where handle=.z.w];neg[.z.w]@"Card is not in your hand"]};

//First hand validation - run if .backend.hand has 52 cards
check3D:{[cards] if[not max 4=.backend.cardDeck?cards;neg[.z.w]@"First hand needs to have 3D"]};

//Play type validations
singlePlay:{[cards] if[not 1=count .backend.cardDeck?cards;neg[.z.w]@"Wrong play"]};
doublesPlay:{[cards] if[not ((2=count .backend.cardDeck?cards)&(min a=first a:cards[::;0]));neg[.z.w]@"Wrong Play"]};
fiveCardPlay:{[cards] if[not 5=count .backend.cardDeck?cards;neg[.z.w]@"Wrong Play"]};
