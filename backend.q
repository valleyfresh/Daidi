\p 1234
testHands:til[3]!(("10S";"JS";"QS";"KS";"AS");("10H";"10S";"10D";"3S";"3D");("10H";"10S";"10D";"10C";"3D"));

\d .backend

//////////////////////////////
////   Connection logic   ////
/////////////////////////////

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
	startTurn[];
        ]
    };
	
.z.pc:{[w] delete from `.backend.connections where handle = w;0N!(string .z.u)," has left the Lobby"};

//***Start game functions***//
cardDeck:til[53]!(enlist"pass"),(((string 3+til[8]),enlist each"JQKA2")cross"DCHS");
shuffle:{system"S ",string`long$.z.t;flip(0N;4)#1+0N?52};
deal:{h::exec handle from .backend.connections;{neg[x](`showHand;y)}'[h;hand::shuffle[]];.backend.turnTableInit[]};
startTurn:{update turn:max each 1=.backend.hand from `.backend.connections;neg[first exec handle from .backend.connections where turn=1b](0N!;"It is your turn")};

//***Card ranking***//
suitRank:til[4]!"DCHS";
valueRank:til[13]!(string 3+til[8]),enlist each"JQKA2";
fiveCardRank:til[6]!`straight`flush`fullHouse`quads`straightFlush`royalFlush;

//***Rank calculation***//
singlesRank:{[cards] .backend.cardDeck?cards};
doublesRank:{[cards] sum(.backend.cardDeck?cards),.backend.suitRank?last each cards};
fiveCardRank:{[cards] };

//Turn table - reinitialised every game and updated when a valid hand is played
turnTableInit:{turnTable::flip `player`handle`round`play`rank!"SIS*I"$\:()};

/////////////////////////
////   Validations  /////
////////////////////////

//***General validation***//
checkTurn:{$[first 0=exec turn from .backend.connections where handle=.z.w;
	neg[.z.w](0N!;"It is not your turn");
	1b]};

checkInHand:{[cards] $[min .backend.cardDeck?cards in .backend.hand[exec playerNo from .backend.connections where handle=.z.w];
	1b;
	neg[.z.w](0N!;"Card is not in your hand")]};

pass:{[cards] $[(cards=`pass)&(not 52=count raze .backend.hand);
	nextTurn[];
	neg[.z.w](0N!;"You cannot pass the first turn!")]};

//***First hand validation***//
check3D:{[cards] if[not max 1=.backend.cardDeck?cards;neg[.z.w](0N!;"First hand needs to have 3D")]};

//***Round type validations***//
singlePlay:{1b};

doublesPlay:{[cards] $[min(a 0)=a:.backend.valueRank?-1_'cards;
	1b;
	neg[.z.w](0N!;"Invalid doubles pair")]};

fiveCardPlay:{[cards] $[max a:(straightCheck[cards];
		flushCheck[cards];
		fullHouseCheck[cards];
		quadsCheck[cards];
		straightFlushCheck[cards];
		royalCheck[cards]);
	1b;	//last (value .backend.fiveCardRank) where a --> output fivecardplay symbol; to be used when checking rank 
	neg[.z.w](0N!;"Invalid 5 card combo")]};

roundDict:`single`double`fiveCard!1 2 5;
roundCheck:`single`double`fiveCard!(.backend.singlePlay;.backend.doublesPlay;.backend.fiveCardPlay);

roundPlay:{[cards] $[(0=count .backend.turnTable)|0=sum -3#exec rank from .backend.turnTable;
	$[(a:count cards) in value .backend.roundDict;
		(.backend.roundCheck .backend.roundDict?a)[cards]; 
		neg[.z.w](0N!"Invalid number of cards")];
	$[(count cards)=.backend.roundDict a:first -1#exec round from .backend.turnTable
		(.backend.roundCheck a)[cards];
		neg[.z.w](0N!"Invalid number of cards")]]};

//***Five card validations***//
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

//////////////////////////////
////   Value validation   ////
/////////////////////////////

singleCheck:{[cards] };

doublesCheck:{[cards] };

fiveCardCheck:{[cards] };

/////////////////////////////////////
////   Post-validation actions   ////
////////////////////////////////////

turnTableUpdate:{[round;cards;rankVal] `.backend.turnTable upsert (.z.u;.z.w;round;cards;rankVal)};

//***NOTE: Only run next turn after running remove card function***//
removeCard:{[cards] a:(a:.backend.hand[first exec i from .backend.connections where turn=1b])_/desc .backend.cardDeck?cards};

nextTurn:{update turn:-1 rotate turn from `.backend.connections;neg[first exec handle from .backend.connections where turn=1b](0N!;"It is your turn")};

//////////////////////////////////
////   Client Play Function   ////
/////////////////////////////////
\
//playHand:{[cards] $[.backend.checkTurn[];
	if[0=count .backend.turnTable;
		if[.backend.check3D[cards];
			if[.backend.roundVal[cards];
				];
/
