\p 1234
testHands:til[3]!(("10S";"JS";"QS";"KS";"AS");("10H";"10S";"10D";"3S";"3D");("10H";"10S";"10D";"10C";"3D"));
\d .backend

//Connection logic
connections:flip `dateTime`user`host`ipAddress`handle`playerNo`turn!"ZSS*IIB"$\:();

.z.po:{[w] $[4>=a:1+exec count i from .backend.connections;
	(`.backend.connections insert .z.Z,.z.u,(.Q.host .z.a;"." sv string "h"$0x0 vs .z.a),w,a,0b;
	0N!"Connection Established by ",string .z.u);
	neg[w](0N!;"Lobby is full")];
	
	if[1=a:count[.z.W];
        neg[w](0N!;"Please wait for 3 more players to connect before the game commences")];
        
    if[(4>a)&1<a;
        neg[(key .z.W)except w]@\:(0N!;raze"Player ",(string count key[.z.W])," connected");
        $[1=b:4-a;
            neg[key .z.W]@\:(0N!;raze"Please wait for ",(string b)," more player to connect before the game commences");
            neg[key .z.W]@\:(0N!;raze"Please wait for ",(string b)," more players to connect before the game commences")];
        ]
    
    if[4=a;
        neg[key .z.W]@\:(0N!;"All players have connected, the game is commencing...");
	deal[];
	startTurn:[];
        ]
    };
	
.z.pc:{[w] delete from `.backend.connections where handle = w;0N!(string .z.u)," has left the Lobby"};

//Card Dealing and Turn logic
cardDeck:til[52]!((string 2+til[9]),"JQKA")cross"DCHS";
shuffle:{system"S ",string`long$.z.t;flip(0N;4)#0N?52};
deal:{h::exec handle from .backend.connections;{neg[x](`showHand;y)}'[h;hand::shuffle[]]};
startTurn:{update turn:max each 4=.backend.hand from `.backend.connections;neg[first exec handle from .backend.connections where turn=1b](0N!;"It is your turn")};
nextTurn:{update turn:-1 rotate turn from `.backend.connections};

//Card Ranking
suitRank:til[4]!"DCHS";
valueRank:til[13]!(string 2+til[9]),enlist each"JQKA";
fiveCardRank:til[6]!`straight`flush`fullHouse`quads`straightFlush`royalFlush;

//Validations
//runJob:{if[52=count raze .backend.hand;firstHand[x]};

//General Validation
checkTurn:{if[first 0=exec turn from .backend.connections where handle=.z.w;neg[.z.w](0N!;"It is not your turn")]};
checkCardInHand:{[cards] if[not min .backend.cardDeck?cards in .backend.hand[exec playerNo from .backend.connections where handle=.z.w];neg[.z.w](0N!;"Card is not in your hand")]};
pass:{[cards] $[(card=`pass)&(not 52=count raze .backend.hand);nextTurn[]]};

//First hand validation - run if .backend.hand has 52 cards
check3D:{[cards] if[not max 4=.backend.cardDeck?cards;neg[.z.w](0N!;"First hand needs to have 3D")]};

//Play type validations
singlePlay:{[cards] if[not 1=count cards;neg[.z.w](0N!;"Wrong number of cards")]};
doublesPlay:{[cards] $[2=count cards;
	$[min(a 0)=a:.backend.valueRank?-1_'cards);
	1b;
	neg[.z.w](0N!;"Invalid doubles pair")];
	neg[.z.w](0N!;"Wrong number of cards")]};
fiveCardPlay:{[cards] $[5=count cards;
	$[max a:(straightCheck[cards];
		flushCheck[cards];
		fullHouseCheck[cards];
		quadsCheck[cards];
		straightFlushCheck[cards];
		royalCheck[cards]);
	last (value .backend.fiveCardRank) where a;
	neg[.z.w](0N!;"Invalid 5 card combo")];
	neg[.z.w](0N!;"Wrong number of cards")]};

//Five card validations
straightCheck:{[cards] min 1=1_deltas .backend.valueRank?-1_'cards};
flushCheck:{[cards] min(first a)=a:last each cards};
straightFlushCheck:{[cards] .backend.straightCheck[cards]&.backend.flushCheck[cards]};
royalCheck:{[cards] .backend.straightCheck[cards]&.backend.flushCheck[cards]&50=sum .backend.valueRank?-1_'cards};
fullHouseCheck:{[cards] $[2=count distinct a:.backend.valueRank?-1_'cards;
	(max min each(3 2;2 3)=\:sum each(distinct a)=\:a);
	0b]};
quadsCheck:{[cards] $[2=count distinct a:.backend.valueRank?-1_'cards;
	(max min each(4 1;1 4)=\:sum each(distinct a)=\:a);
	0b]};
