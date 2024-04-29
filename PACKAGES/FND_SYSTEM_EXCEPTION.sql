--------------------------------------------------------
--  DDL for Package FND_SYSTEM_EXCEPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SYSTEM_EXCEPTION" AUTHID CURRENT_USER as
/* $Header: AFCPFSES.pls 115.3 2002/02/08 19:44:26 nbhambha noship $ */

-- Package -   FND_SYSTEM_EXCEPTION

-- Name : Set_Name
-- Description:
--       This call names the exception event
--       By associating a message name (from Fnd_Messages)with the exception
--       we will be able to present the System Administrator with
--       translated description of the exception condition instead
--       of showing it in the language of the session where it
--       occurred .
-- Arguments:
--
--    Message_Appl_Short_Name
--                - Application short name of the message
--    Name        - Message name
--    Module name     -
--    Severity    - ERROR/WARNING/FATAL
--
--    Returns Event_Id that you need to use with Set_Token calls .

FUNCTION Set_Name (Message_Appl_Short_Name In Varchar2,
			   Message_Name    In Varchar2,
                           Module          In Varchar2 Default Null,
                           Severity    	   In Varchar2  Default 'Warning')
                  return number;

-- Name : Set_Token
-- Description:
--     Sets token name and value.
--     Call this procedure for everey 'token' in the set message.
--     Set_Name has to be called before calling Set_Token
-- Arguments:
--     Event_Id - event value for which you are setting the token.
--     Token    - token name
--     Value    - token value  (** Maximum allowed size is 2000**)
--     Type     - 'C' = Constant. Value is used directly in the token
--                       substitution.
--                'S' = Select. Value is a SQL statement which
--                      returns a single varchar2 value.
--                      (e.g. A translated concurrent manager name.)
--                      This statement is run when the
--                      even is retrieved, and the result is used in
--                      the token substitution.
--                      (SQL statement cannot be more than 2000 in
--                       length)
--                'T' = Translate.  Value is a message name.
--                      This message must belong to the same
--                      application as the message specified
--                      in the Set_Name function.
--                      The message text will be used in the token
--                      substitution.


PROCEDURE set_token(Event_Id In Number,
	Token    In Varchar2,
	Value    In Varchar2 Default Null,
	Type     In Varchar2 Default 'C');

-- Name : Post
-- Description:
--     Call this function after calling Set_Name and optionally
--     Set_Token.
--     This call also captures the context in which the
--     exception occurred.
--     If successfull it returns TRUE else returns FALSE.
-- Arguments: Event_Id - event_id for which you want to post events.


FUNCTION Post (Event_Id In Number ) return boolean;


end FND_SYSTEM_EXCEPTION;

 

/
