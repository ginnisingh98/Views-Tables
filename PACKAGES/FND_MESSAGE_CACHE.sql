--------------------------------------------------------
--  DDL for Package FND_MESSAGE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MESSAGE_CACHE" AUTHID DEFINER as
/* $Header: AFNCMSGS.pls 120.2 2005/10/26 03:26:19 skghosh noship $ */
    /* The record to hold the cached data */
    TYPE  MessageRec IS RECORD  (
        MESSAGE_NAME   VARCHAR2(30) ,
        MESSAGE_TEXT   VARCHAR2(2000)
     );
     TYPE MessageTAB IS TABLE OF MessageRec index by binary_integer;


    /*
    ** SET_NAME - sets the message name
    */
    procedure SET_NAME(APPLICATION in varchar2, NAME in varchar2);

    /*
    ** SET_TOKEN - defines a message token with a value
    */
    procedure SET_TOKEN(TOKEN     in varchar2,
                        VALUE     in varchar2,
                        TRANSLATE in boolean default false);

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
                             VALUE in varchar2);

    /*
    ** RETRIEVE - gets the message and token data, clears message buffer
    */
    procedure RETRIEVE(MSGOUT OUT NOCOPY varchar2);

    /*
    ** CLEAR - clears the message buffer
    */
    procedure CLEAR;

    /*
    **	GET_STRING- get a particular translated message
    **       from the message dictionary database.
    **
    **  This is a one-call interface for when you just want to get a
    **  message without doing any token substitution.
    **  Returns NULL if the message cannot be found.
    */
    function GET_STRING(APPIN in varchar2,
	      NAMEIN in varchar2) return varchar2;

    /*
    **  FETCH_SQL_TOKEN- get the value for a SQL Query token
    **     This procedure is only to be called by the ATG
    **     not for external use
    */
    function FETCH_SQL_TOKEN(TOK_VAL in varchar2) return varchar2;
    pragma restrict_references(FETCH_SQL_TOKEN, WNDS);

    /*
    **	GET_NUMBER- get the message number of a particular message.
    **
    **  Returns 0 if the message has no message number,
    **         or if its message number is zero.
    **       NULL if the message can't be found.
    */
    function GET_NUMBER(APPIN in varchar2,
	      NAMEIN in varchar2) return NUMBER;

    /*
    **	GET- get a translated and token substituted message
    **       from the message dictionary database.
    **       Returns NULL if the message cannot be found.
    */
    function GET return varchar2;

    /*
    ** GET_ENCODED- Get an encoded message from the message stack.
    */
    function GET_ENCODED return varchar2;

    /*
    ** PARSE_ENCODED- Parse the message name and application short name
    **                out of a message in "encoded" format.
    */
    procedure PARSE_ENCODED(ENCODED_MESSAGE IN varchar2,
			APP_SHORT_NAME  OUT NOCOPY varchar2,
			MESSAGE_NAME    OUT NOCOPY varchar2);

    /*
    ** SET_ENCODED- Set an encoded message onto the message stack
    */
    procedure SET_ENCODED(ENCODED_MESSAGE IN varchar2);

    /*
    ** raise_error - raises the error to the calling entity
    **               via raise_application_error() prodcedure
    */
    procedure RAISE_ERROR;

    /*
    **  GET_TOKEN- Obtains the value of a named token from the
    **             current message.
    **         IN: TOKEN- the name of the token that was passed to SET_TOKEN
    **             REMOVE_FROM_MESSAGE- default NULL means 'N'
    **              'Y'- Remove the token value from the current message
    **              'N'- Leave the token value on the current message
    **    RETURNs: the token value that was set previously with SET_TOKEN
    */
    function GET_TOKEN(TOKEN IN VARCHAR2
            ,REMOVE_FROM_MESSAGE IN VARCHAR2 default NULL /* NULL means 'N'*/
            ) return varchar2;

end fnd_message_cache;

 

/
