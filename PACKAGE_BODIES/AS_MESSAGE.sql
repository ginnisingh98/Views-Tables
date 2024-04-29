--------------------------------------------------------
--  DDL for Package Body AS_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_MESSAGE" as
/* $Header: asxutmgb.pls 115.6 2002/11/06 00:57:15 appldev ship $ */
--
-- PURPOSE
--  Allow messages (both for reporting and debugging) to be written to
--  database table or to memory by PL/SQL programs executed on the server.
--  When program control is returned to the client, messages can be
--  retrieved and used in a report or a log file, etc.
--
--
-- HISTORY
--
--  14-JAN-94	R Lee 		Created.
--  23-FEB-94   R Lee		Modified so that messages can be ouputed
--				to table AS_CONC_REQUEST_MESSAGES.
--  27-FEB-94   R Lee		Renamed Put_DB_Error to Set_Error
--  28-FEB-94   R Lee		Modified Initialize.  The output buffers
--				(db tables or memory) of normal messages
--				and debugging messages can now be controlled
--				independently.
--  17-MAR-94   R Lee		Added Set_Line to replace Put_Line.
--  31-MAR-94   R Lee		Changed references to AS_REPORT_ENTRIES to
--				AS_CONC_REQUEST_MESSAGES.
--  20-APR-94	R Lee		Added funtion Last_Message_Sequence()
--  05-OCT-94   J Lewis		Replaced calls to FND_PROFILE for who info
--				with calls to FND_GLOBAL
--
/*------------------------------ DATA TYPES ---------------------------------*/
TYPE MESSAGE_TABLE_TYPE IS TABLE of
  VARCHAR2(255)
    INDEX BY BINARY_INTEGER;

TYPE CODE_TABLE_TYPE IS TABLE of
  VARCHAR2(12)
    INDEX BY BINARY_INTEGER;

/*---------------------------- PRIVATE VARIABLES ----------------------------*/

G_TMessage_Buffer    MESSAGE_TABLE_TYPE;	-- Message Stack
G_TEmpty_Msg_Buffer  MESSAGE_TABLE_TYPE;	-- Empty Stack used for
						-- clearing memory
G_TMessage_Type	     CODE_TABLE_TYPE;		-- Message Type Stack in sync.
						-- with Message Stack
G_TEmpty_Type	     CODE_TABLE_TYPE;		-- Emtpy Type Stack
G_Msg_Count	     NUMBER := 0;		-- Num of Messages on stack
G_Msg_Ptr	     NUMBER := 1;		-- Points to next Message
						-- on stack to retreive.
G_Output_Code	     VARCHAR2(5) := 'STACK';	-- Determines whether messages
						-- will be stored in a table
						-- or in memory.
G_Debug_Flag	     VARCHAR2(1) := 'N';	-- Flag determines whether
						-- debug mode is on or off.
G_Debug_Output_Code  VARCHAR2(5) := 'STACK';	-- Determines how debugging
						-- messages will be stored.
G_Ins_Message_Flag   VARCHAR2(1) := 'N';	-- Flag to indicate whether
						-- the current message needs
						-- to be inserted into
						-- AS_CONC_REQUEST_MESSAGES

G_User_Id	     NUMBER := FND_GLOBAL.User_Id;
G_Conc_Request_Id    NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE Insert_Row(X_Message_Text VARCHAR2,
		     X_Message_Type VARCHAR2,
		     X_Error_Number NUMBER) IS
BEGIN
  INSERT INTO as_conc_request_messages(conc_request_message_id,
				       creation_date,
				       created_by,
				       request_id,
				       type,
				       error_number,
				       text)
		         VALUES(as_conc_request_messages_s.nextval,
				SYSDATE,
				G_User_Id,
				G_Conc_Request_Id,
				X_Message_Type,
				X_Error_Number,
				X_Message_Text);
EXCEPTION
  When OTHERS then
    Set_Error('AS_MESSAGE.Insert_Message');
END;


PROCEDURE Insert_Message(Message_Text VARCHAR2,
			 Message_Type VARCHAR2,
			 Error_Number NUMBER) IS
BEGIN
  if (    (G_Output_Code = 'TABLE')
      and (G_Ins_Message_Flag = 'Y')) then
     Insert_Row(G_TMessage_Buffer(G_Msg_Count),
		G_TMessage_Type(G_Msg_Count), NULL);
     G_Ins_Message_Flag := 'N';
  end if;
  Insert_Row(Message_Text, Message_Type, Error_Number);
END;

--
-- NAME
--   Set_Line
--
-- Writes message either to the message stack or AS_CONC_REQUEST_MESSAGES
--
--
PROCEDURE Set_Line(Message_Text   IN VARCHAR2,
		   Message_Type   IN VARCHAR2,
		   Error_Number   IN NUMBER) IS
BEGIN
  if (   (    (Message_Type = 'DEBUG')
          and (G_Debug_Output_Code = 'TABLE'))
      or (    (G_Output_Code = 'TABLE')
          and (Message_Type <> 'DEBUG'))) then
    Insert_Message(Message_Text, Message_Type, Error_Number);
  else
    G_Msg_Count := G_Msg_Count + 1;
    G_TMessage_Buffer(G_Msg_Count) := Message_Text;
    G_TMessage_Type(G_Msg_Count) := Message_Type;
  end if;
END;

/*---------------------------- PUBLIC ROUTINES ------------------------------*/
--
-- NAME
--   Initialize
--
-- PURPOSE
--   Controls whether output is stored in a DB table or in memory via the
--   message stack and sets the REQUEST_ID of the concurrent program if
--   applicabale.
--
-- USAGE
--   When Output_Code = 'TABLE' messages will be inserted into
--        AS_CONC_REQUEST_MESSAGES.
--
--   When Output_Code = 'STACK' messages will be written to memory on
--        the message stack.
--
--   Same logic applies to Debug_Output_Code
--
--   When Debug_Flag = 'Y', debug mode is turned on.
--
-- HISTORY
--   14-FEB-94	R Lee		Created.
--   28-FEB-94  R Lee		Added argument Debug_Output_Code
--   31-MAR-94  R Lee		Added argument Debug_Flag
--
PROCEDURE Initialize(Output_Code 	VARCHAR2,
		     Conc_Request_Id 	NUMBER,
		     Debug_Flag		VARCHAR2 Default 'N',
		     Debug_Output_Code  VARCHAR2 Default 'STACK') IS
BEGIN
  G_Conc_Request_Id := Conc_Request_Id;
  G_Debug_Flag := Debug_Flag;
  if (Upper(Debug_Output_Code) IN ('STACK', 'TABLE')) then
    G_Debug_Output_Code := Debug_Output_Code;
  else
    G_Debug_Output_Code := 'STACK';
  end if;
  if (Upper(Output_Code) IN ('STACK', 'TABLE')) then
    G_Output_Code := Output_Code;
  else
    --
    --  Hardcoded message for the moment
    --
    Set_Line('Invalid Argument to Set_Output. ' ||
	     'Messages will be written to memory by default.');
    G_Output_Code := 'STACK';
  end if;
END;

--
-- NAME
--   Flush
--
-- PURPOSE
--   Ensures that all messages on the message stack that need to be
--   inserted into AS_CONC_REQUEST_MESSAGES are inserted.
--
--
PROCEDURE Flush IS
BEGIN
   if (    (G_Output_Code = 'TABLE')
       and (G_Ins_Message_Flag = 'Y')) then
     Insert_Row(G_TMessage_Buffer(G_Msg_Count),
		G_TMessage_Type(G_Msg_Count),
		NULL);
     G_Ins_Message_Flag := 'N';
   end if;
END;

--
-- NAME
--   Put_Line
--
-- NOTES
--   Temporary function for backwards compatibility.
--   Use Set_Error instead.
--
PROCEDURE Put_Line(Message_Text IN VARCHAR2) IS
BEGIN
  Set_Line(Message_Text, 'NO_TRANSLATE', NULL);
END;

--
-- NAME
--   Set_Line
--
-- PURPOSE
--   Puts a char string to Message Stack
--
PROCEDURE Set_Line(Message_Text IN VARCHAR2) IS
BEGIN
  Set_Line(Message_Text, 'NO_TRANSLATE', NULL);
END;

--
-- NAME
--   Set_Name
--
-- PURPOSE
--   Puts an "encoded" message name on the Message Stack
--
PROCEDURE Set_Name(Appl_Short_Name IN VARCHAR2,
		   Message_Name    IN VARCHAR2) IS
BEGIN
  if (    (G_Ins_Message_Flag = 'Y')
      and (G_Output_Code = 'TABLE')) then
    Insert_Row(G_TMessage_Buffer(G_Msg_Count),
	       G_TMessage_Type(G_Msg_Count),
	       NULL);
  end if;
  G_Msg_Count := G_Msg_Count + 1;
  G_TMessage_Buffer(G_Msg_Count) := Appl_Short_Name || ' ' || Message_Name;
  G_TMessage_Type(G_Msg_Count) := 'TRANSLATE';
  G_Ins_Message_Flag := 'Y';
END;

--
-- NAME
--  DEBUG
--
-- PURPOSE
--   Writes a debugging message to the Message Stack only if
--   the profile option value for AS_DEBUG = 'Y'.

PROCEDURE Debug(Message_Text IN VARCHAR2) IS
BEGIN
    if (G_Debug_Flag = 'Y') then
      Set_Line(Message_Text, 'DEBUG', NULL);
  end if;
END;

--
-- NAME
--   Set_Token
--
-- PURPOSE
--   Add Token Information to the current message on the stack.
--   The current message must be of type 'TRANSLATE' for this
--   to work properly when the message is translated on the client,
--   although no serious errors will occur.
--
PROCEDURE Set_Token(Token_Name 	IN VARCHAR2,
		    Token_Value IN VARCHAR2,
		    Translate   IN BOOLEAN Default False) IS
  Trans_Label VARCHAR2(5);
BEGIN
  if (Translate) then
    Trans_Label := 'TRUE';
  else
    Trans_Label := 'FALSE';
  end if;
  G_TMessage_Buffer(G_Msg_Count)
	 := G_TMessage_Buffer(G_Msg_Count) || ' ' ||
   	    Token_Name   || ' \"' ||
	    Token_Value  || '\" ' || Trans_Label;
END;

PROCEDURE Get(Message_Buf    OUT VARCHAR2,
	      Message_Type   OUT VARCHAR2,
	      Status         OUT NUMBER) IS
BEGIN
  if (   (G_Msg_Ptr > G_Msg_Count)
      or (G_Msg_Count = 0)) then
    Status := 0;
    Clear;
  else
    Message_Buf  := G_TMessage_Buffer(G_Msg_Ptr);
    Message_Type := G_TMessage_Type(G_Msg_Ptr);
    Status := LengthB(G_TMessage_Buffer(G_Msg_Ptr));
    G_Msg_Ptr := G_Msg_Ptr + 1;
  end if;
END;

--
-- NAME
--   Clear
--
-- PURPOSE
--   Frees memory used the the Message Stack and resets the
--   the Message Stack counter and pointer variables.
--
PROCEDURE Clear IS
BEGIN
  G_TMessage_Buffer := G_TEmpty_Msg_Buffer;
  G_TMessage_Type   := G_TEmpty_Type;
  G_Msg_Count       := 0;
  G_Msg_Ptr         := 1;
END;

--
--  Temporary function for backwards compatibility.
--  Use Set_Error instead.
--
PROCEDURE Put_DB_Error(Routine IN VARCHAR2 Default NULL,
		       Context IN VARCHAR2 Default NULL) IS
BEGIN
  Set_Error(Routine, Context);
END;

PROCEDURE Set_Error(Routine IN VARCHAR2 Default NULL,
		    Context IN VARCHAR2 Default NULL) IS
  Delimiter1 VARCHAR2(3);
  Delimiter2 VARCHAR2(3);
BEGIN
  if (Routine is not NULL) then
    Delimiter1 := ' : ';
  end if;
  if (Context is not NULL) then
    Delimiter2 := ' : ';
  end if;
  Set_Line(Routine||Delimiter1||Context||Delimiter2||SQLERRM);
END;

FUNCTION Message_Count Return NUMBER IS
BEGIN
  Return(G_Msg_Count);
END;

PROCEDURE Purge_Messages(X_Request_Id IN NUMBER) IS
BEGIN
  DELETE from as_conc_request_messages
  WHERE  request_id = X_Request_Id;
  COMMIT;
END;

FUNCTION Last_Message_Sequence Return NUMBER IS
  CURSOR C_Last_Seq IS
    SELECT max(conc_request_message_id)
    FROM   as_conc_request_messages
    WHERE  request_id = G_Conc_Request_Id;

  Last_Msg_Seq NUMBER;

BEGIN
  OPEN C_Last_Seq;
  FETCH C_Last_Seq INTO Last_Msg_Seq;
  CLOSE C_Last_Seq;
  return(Last_Msg_Seq);

EXCEPTION
  When OTHERS then
    AS_MESSAGE.Set_Error('Last_Message_Sequence');
    Raise;
END;

END AS_MESSAGE;

/
