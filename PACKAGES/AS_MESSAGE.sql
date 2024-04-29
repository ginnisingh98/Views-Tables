--------------------------------------------------------
--  DDL for Package AS_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_MESSAGE" AUTHID CURRENT_USER as
/* $Header: asxutmgs.pls 115.4 2002/11/06 00:57:21 appldev ship $ */

/*------------------------------- EXCEPTIONS --------------------------------*/
ABORT EXCEPTION;	-- Raise when server program should abort and
			-- return processing to the client.

/*-------------------------------- ROUTINES ---------------------------------*/

--
-- NAME
--   Initialize
--
-- PURPOSE
--   Initializes package AS_MESSAGE to control how messages are stored
--   (either in a db table or in memory) and sets the request_id of
--   the concurrent program using this package.
--
-- ARGUMENTS
--   Output_Code	Possible values are 'TABLE' and 'STACK'
--   			'TABLE' specifies that messages should be inserted
--			into the table AS_CONC_REQUEST_MESSAGES
--
--			'STACK' specifies that messages should be stored
--			in memory on the message stack.
--
--   Debug_Flag		Enables or Disables Debug Mode.  ('Y' or 'N')
--   Debug_Outut_Code	Same logic as above but applies to debugging
--			messages.
-- NOTES
--   Initialize should be the first call to package AS_MESSAGE.
--   Output_Code defaults to 'STACK' and Conc_Request_Id defaults to 0
--   if Initialize is not called.
--   References to 'Output Buffer' below refer to AS_CONC_REQUEST_MESSAGES or
--   the message stack depending on initialization.
--
PROCEDURE Initialize(Output_Code 	VARCHAR2,
		     Conc_Request_Id 	NUMBER,
		     Debug_Flag		VARCHAR2 Default 'N',
		     Debug_Output_Code 	VARCHAR2 Default 'STACK');
--
-- NAME
--   Put_Line
--
-- PURPOSE
--   Writes a NON-TRANSLATED message to the output buffer.
--
-- NOTES
--   Same as Set_Line.  This will be removed eventually.
--
--

PROCEDURE Set_Line(Message_Text IN VARCHAR2);
--
-- NAME
--   Set_Line
--
-- PURPOSE
--   Writes a NON-TRANSLATED message to the output buffer.
--

PROCEDURE Put_Line(Message_Text IN VARCHAR2);
--
-- NAME
--   Flush
--
-- PURPOSE
--   Flush is called to ensure that all translated messages that have
--   been set with Set_Name will be inserted in AS_CONC_REQUEST_MESSAGES
--   if Initialize has been called with Output_Code = 'TABLE'
--
-- USAGE
--   Flush is not applicable when Output_Code = 'STACK'.
--   Flush should be called after the last call to AS_MESSAGE before
--   program control is returned to the client calling program.
--
PROCEDURE Flush;

--
-- NAME
--   Debug
--
-- PURPOSE
--   Writes a non-translated message to the output buffer only when
--   the value for profile option AS_DEBUG = 'Y' or is NULL.
--
PROCEDURE Debug(Message_Text IN VARCHAR2);

--
-- NAME
--   Set_Name
--
-- PURPOSE
--   Puts a Message Dictionary message on the message stack.
--   (Same syntax as FND_MESSAGE.Set_Name)
--
PROCEDURE Set_Name(Appl_Short_Name IN VARCHAR2,
		   Message_Name    IN VARCHAR2);
--
-- NAME
--   Set_Token
--
-- PURPOSE
--   Sets the token of the current message on the message stack.
--   (Same syntax as FND_MESSAGE.Set_Token
--
PROCEDURE Set_Token(Token_Name 	IN VARCHAR2,
		    Token_Value IN VARCHAR2,
		    Translate   IN BOOLEAN Default False);
--
-- NAME
--   Get
--
-- PURPOSE
--   Gets the current message from the output buffer.
--
-- Arguments
--   Message_Buf	The target variable for the message.
--   Message_Type	The target variable for the message type.
--   Status 		The Target variable for the length of the message
--			retrieved.  If no more messages are stored in the
--			output buffer then Status = 0;
--
PROCEDURE Get(Message_Buf    OUT VARCHAR2,
	      Message_Type   OUT VARCHAR2,
	      Status         OUT NUMBER);
--
-- NAME
--   Set_Error
--
-- PURPOSE
--   Writes the error message of the most recently encountered
--   Oracle Error to the output buffer.
--
-- Arguments
--   Routine		The name of the routine where the Oracle Error
--			occured. (Optional)
--   Context		Any context information relating to the error
--			(e.g. Customer_Id) (Optional)
--
PROCEDURE Set_Error(Routine IN VARCHAR2 Default NULL,
		    Context IN VARCHAR2 Default NULL);
--
-- Obsolete.  This will be deleted shortely.
-- Use Set_Error instead.
--
PROCEDURE Put_DB_Error(Routine IN VARCHAR2 Default NULL,
		       Context IN VARCHAR2 Default NULL);
--
-- NAME
--   Clear
--
-- PURPOSE
--   Clears the message stack and frees memory used by it.
--
PROCEDURE Clear;

--
-- NAME
--
-- PURPOSE
--   Returns the number of messages currently on the message stack.
--
FUNCTION Message_Count Return NUMBER;

--
-- NAME
--   Purge_Messages
--
-- PURPOSE
--   When the output buffer is AS_CONC_REQUEST_MESSAGES, this procedure will
--   delete any messages from AS_CONC_REQUEST_MESSAGES for the current
--   request id.
--
-- USAGE
--   Call Purge_Messages after the client calling program has
--   completed writing a log file or displayed the appropriate messages
--   in a report.
--
PROCEDURE Purge_Messages(X_Request_Id IN NUMBER);

--
-- NAME
--   Last_Message_Sequence
--
-- PURPOSE
--   Returns the last value for
--   AS_CONC_REQUEST_MESSAGES.Conc_Request_Message_Id used by the current
--   session.
--
FUNCTION Last_Message_Sequence RETURN NUMBER;

END AS_MESSAGE;

 

/
