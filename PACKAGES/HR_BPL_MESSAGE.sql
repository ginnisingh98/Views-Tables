--------------------------------------------------------
--  DDL for Package HR_BPL_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BPL_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: perbamsg.pkh 120.0 2005/05/31 16:40:39 appldev noship $ */
/*----------------------------------------------------*/
/* Function to return a MESSAGE in the Language of a  */
/* Business Group                                     */
/*----------------------------------------------------*/

FUNCTION GET_STRING_LNG_BG(APPIN in varchar2,
	                       NAMEIN in varchar2)
    return varchar2;

/*----------------------------------------------------*/
/* Updated version of the GET function, which allows  */
/* the setting of the language                        */
/*----------------------------------------------------*/
   function GET return varchar2;

/*----------------------------------------------------*/
/* New versiona of the SET_NAME function, which allow */
/* the passing of translation language.                */
/*----------------------------------------------------*/



/* Sets the message with the language the of the person_id */
    procedure SET_NAME_PSN(APPLICATION in varchar2,
                       NAME in varchar2,
                       p_person_id in number);

/* Sets the message with the language the of supervisor of the assignment id*/
    procedure SET_NAME_SUP(APPLICATION in varchar2,
                       NAME in varchar2,
                       p_assignment_id in number);

/* Sets the message with the language the of primary supervisor of the   */
/* assignment id                                                         */
     procedure SET_NAME_PSUP(APPLICATION in varchar2,
                       NAME in varchar2,
                       p_assignment_id in number);

/* Sets the message with the language the of a person_ids primary       */
/* supervisor                                                           */
     procedure SET_NAME_PSN_PSUP(APPLICATION in varchar2,
                       NAME in varchar2,
                       p_person_id in number);

/*    ** SET_NAME - sets the message name,  */
    procedure SET_NAME(APPLICATION in varchar2,
                       NAME in varchar2,
                       p_business_group_id in number);

/* --------------------------------------------------*/
/* Required unchanged FND_MESSAGE Functions          */
/*---------------------------------------------------*/


/* FETCH_SQL_TOKEN- get the value for a SQL Query token */
/* This procedure is only to be called by the ATG       */
/* not for external use                                 */

    function FETCH_SQL_TOKEN(TOK_VAL in varchar2) return varchar2;
    pragma restrict_references(FETCH_SQL_TOKEN, WNDS);


/*    ** SET_TOKEN - defines a message token with a value  */
    procedure SET_TOKEN(TOKEN     in varchar2,
                        VALUE     in varchar2,
                        TRANSLATE in boolean default false);
    pragma restrict_references(SET_TOKEN, WNDS);

/*                                                                  */
/* SET_TOKEN_SQL - define a message token with a SQL query value    */
/*                                                                  */
/* Description:                                                     */
/*   Like SET_TOKEN, except here the value is a SQL statement which */
/*   returns a single varchar2 value.  (e.g. A translated concurrent*/
/*   manager name.)  This statement is run when the message text is */
/*   resolved, and the result is used in the token substitution.    */
/*                                                                  */
/* Arguments:                                                       */
/*   token - Token name                                             */
/*   value - Token value.  A SQL statement                          */

    procedure SET_TOKEN_SQL (TOKEN in varchar2,
                             VALUE in varchar2);

/* RETRIEVE - gets the message and token data, clears message buffer    */

    procedure RETRIEVE(MSGOUT out NOCOPY varchar2);
    pragma restrict_references(RETRIEVE, WNDS);

/* CLEAR - clears the message buffer  */
    procedure CLEAR;
    pragma restrict_references(CLEAR, WNDS);


end HR_BPL_MESSAGE;

 

/
