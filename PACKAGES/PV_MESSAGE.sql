--------------------------------------------------------
--  DDL for Package PV_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_MESSAGE" AUTHID CURRENT_USER as
/* $Header: pvxvmsgs.pls 115.6 2002/12/11 10:41:48 anubhavk ship $ */


    /*
    ** SET_NAME - sets the message name
    */
    procedure SET_NAME(APPLICATION in varchar2, NAME in varchar2);
    pragma restrict_references(SET_NAME, WNDS);

    /*
    ** SET_TOKEN - defines a message token with a value
    */
    procedure SET_TOKEN(TOKEN     in varchar2,
                        VALUE     in varchar2,
                        TRANSLATE in boolean default false);
    pragma restrict_references(SET_TOKEN, WNDS);

    /*
    ** RETRIEVE - gets the message and token data, clears message buffer
    */
    procedure RETRIEVE(MSGOUT out nocopy varchar2);
    pragma restrict_references(RETRIEVE, WNDS);

    /*
    ** CLEAR - clears the message buffer
    */
    procedure CLEAR;
    pragma restrict_references(CLEAR, WNDS);

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
    pragma restrict_references(GET_STRING, WNDS, WNPS);

    /*
    **	GET_NUMBER- get the message number of a particular message.
    **
    **  Returns 0 if the message has no message number,
    **         or if its message number is zero.
    **       NULL if the message can't be found.
    */
    function GET_NUMBER(APPIN in varchar2,
	      NAMEIN in varchar2) return NUMBER;
    pragma restrict_references(GET_NUMBER, WNDS, WNPS);

    /*
    **	GET- get a translated and token substituted message
    **       from the message dictionary database.
    **       Returns NULL if the message cannot be found.
    */
    function GET return varchar2;
    pragma restrict_references(GET, WNDS);

    /*
    ** GET_ENCODED- Get an encoded message from the message stack.
    */
    function GET_ENCODED return varchar2;
    pragma restrict_references(GET_ENCODED, WNDS);

    /*
    ** PARSE_ENCODED- Parse the message name and application short name
    **                out nocopy of a message in "encoded" format.
    */
    procedure PARSE_ENCODED(ENCODED_MESSAGE IN varchar2,
			APP_SHORT_NAME  OUT NOCOPY varchar2,
			MESSAGE_NAME    OUT NOCOPY varchar2);
    pragma restrict_references(PARSE_ENCODED, WNDS, WNPS);

    /*
    ** SET_ENCODED- Set an encoded message onto the message stack
    */
    procedure SET_ENCODED(ENCODED_MESSAGE IN varchar2);
    pragma restrict_references(SET_ENCODED, WNDS);

    /*
    ** raise_error - raises the error to the calling entity
    **               via raise_application_error() prodcedure
    */
    procedure RAISE_ERROR;
    pragma restrict_references(RAISE_ERROR, WNDS, WNPS);

end pv_message;

 

/
