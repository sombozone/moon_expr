enum Kind {
    Identifier 
	Number     
	String     
	Operator   
	Bracket    
	EOF       
}

struct Location  {
	from : Int 
	to : Int 
}

struct Token {
    location : Location
    kind : Kind
	value : String
}

struct Lexer{
    source : String
    tokens : @queue.Queue[Token]
    err : Error
    start : Int
    end : Int
    eof : Bool
}

