--------------------------------------------------------
--  DDL for Package Body FND_MESSAGE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MESSAGE_CACHE" as
/* $Header: AFNCMSGB.pls 120.2 2005/10/26 03:26:48 skghosh noship $ */


    TYPE MSG_TABLE      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    TYPE MSG_NAME_TABLE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE MSG_NUMBER_TABLE IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;

    MSGNAME varchar2(30);
    MSGDATA varchar2(32000);
    MSGSET  boolean := FALSE;
    MSGAPP  varchar2(50);

    CacheTab  MessageTAB ;
    TABLE_SIZE binary_integer :=0;
    MAX_TABLE_SIZE binary_integer :=10;

    procedure SET_NAME(APPLICATION in varchar2, NAME in varchar2) is
    begin
        FND_MESSAGE.SET_NAME(APPLICATION,NAME);
    end;

    /*
    **  ### OVERLOADED (original version) ###
    **
    **	SET_TOKEN - define a message token with a value,
    **              either constant or translated
    **  Public:  This procedure to be used by all
    */
    procedure SET_TOKEN(TOKEN in varchar2,
                        VALUE in varchar2,
                        TRANSLATE in boolean default false) is
    begin
       FND_MESSAGE.SET_TOKEN(TOKEN,VALUE,TRANSLATE);
    end set_token;

    /*
    ** SET_TOKEN_SQL - define a message token with a SQL query value
    **
    ** Description:
    **   Like SET_TOKEN, except here the value is a SQL statement which
    **   returns a single varchar2 value.  (e.g. A translated concurrent
    **   manager name.)  This statement is run when the message text is
    **   resolved, and the result is used in the token substitution.
    **
    ** Arguments:
    **   token - Token name
    **   value - Token value.  A SQL statement
    **
    */
    procedure SET_TOKEN_SQL (TOKEN in varchar2,
                             VALUE in varchar2) is
    begin
        FND_MESSAGE.SET_TOKEN_SQL(TOKEN,VALUE);
    end set_token_sql;

    /* This procedure is only to be called by the ATG; */
    /*  not for external use */
    procedure RETRIEVE(MSGOUT OUT NOCOPY varchar2) is
    begin
       FND_MESSAGE.RETRIEVE(MSGOUT);
    end;

    procedure CLEAR is
    begin
       FND_MESSAGE.CLEAR;
    end;

    procedure RAISE_ERROR is
    begin
       FND_MESSAGE.RAISE_ERROR;
    end;

    /*
    **	GET_STRING- get a particular translated message
    **       from the message dictionary database.
    **
    **  This is a one-call interface for when you just want to get a
    **  message without doing any token substitution.
    **  Returns NAMEIN (Msg name)  if the message cannot be found.
    */
    function GET_STRING(APPIN in varchar2,
	      NAMEIN in varchar2) return varchar2 is
     begin
       return FND_MESSAGE.GET_STRING(APPIN, NAMEIN);
     end;

    /*
    **	FETCH_SQL_TOKEN- get the value for a SQL Query token
    **     This procedure is only to be called by the ATG
    **     not for external use
    */
    function FETCH_SQL_TOKEN(TOK_VAL in varchar2) return varchar2 is
      token_text  varchar2(2000);
    begin
         return FND_MESSAGE.FETCH_SQL_TOKEN(TOK_VAL);
    end;

    /*
    **	GET_NUMBER- get the message number of a particular message.
    **
    **  This routine returns only the message number, given a message
    **  name.  This routine will be only used in rare cases; normally
    **  the message name will get displayed automatically by message
    **  dictionary when outputting a message on the client.
    **
    **  You should _not_ use this routine to construct a system for
    **  storing translated messages (along with numbers) on the server.
    **  If you need to store translated messages on a server for later
    **  display on a client, use the set_encoded/get_encoded routines
    **  to store the messages as untranslated, encoded messages.
    **
    **  If you don't know the name of the message on the stack, you
    **  can use get_encoded and parse_encoded to find it out.
    **
    **  Returns 0 if the message has no message number,
    **         or if its message number is zero.
    **       NULL if the message can't be found.
    */
    function GET_NUMBER(APPIN in varchar2,
	      NAMEIN in varchar2) return NUMBER is
    begin
	return  FND_MESSAGE.GET_NUMBER(APPIN,NAMEIN);
    end;



    /*
    **	GET- get a translated and token substituted message
    **       from the message dictionary database.
    **       Returns NULL if the message cannot be found.
    */
    function GET return varchar2 is
        MSG       varchar2(2000);
	TOK_NAM   varchar2(30);
	TOK_VAL   varchar2(2000);
	SRCH      varchar2(2000);
        TTYPE     varchar2(1);
        POS       NUMBER;
	NEXTPOS   NUMBER;
	DATA_SIZE NUMBER;
    begin
        return FND_MESSAGE.GET;
    end;

    function GET_ENCODED return varchar2 is
    begin
        return FND_MESSAGE.GET_ENCODED;
    end;


    /*
    ** SET_ENCODED- Set an encoded message onto the message stack
    */
    procedure SET_ENCODED(ENCODED_MESSAGE IN varchar2) is
    begin
         FND_MESSAGE.SET_ENCODED(ENCODED_MESSAGE);
    end;


    /*
    ** PARSE_ENCODED- Parse the message name and application short name
    **                out of a message in "encoded" format.
    */
    procedure PARSE_ENCODED(ENCODED_MESSAGE IN varchar2,
			APP_SHORT_NAME  OUT NOCOPY varchar2,
			MESSAGE_NAME    OUT NOCOPY varchar2) is
    begin
        FND_MESSAGE.PARSE_ENCODED(ENCODED_MESSAGE,
                                  APP_SHORT_NAME,
                                  MESSAGE_NAME);
    end;

    /*
    **	GET_TOKEN- Obtains the value of a named token from the
    **             current message.
    */
    function GET_TOKEN(TOKEN IN VARCHAR2
            ,REMOVE_FROM_MESSAGE IN VARCHAR2 default NULL /* NULL means 'N'*/
            ) return varchar2 is
    begin
          return FND_MESSAGE.GET_TOKEN(TOKEN,REMOVE_FROM_MESSAGE);
    end;

end fnd_message_cache;


/
