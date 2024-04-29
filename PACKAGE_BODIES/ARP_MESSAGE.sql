--------------------------------------------------------
--  DDL for Package Body ARP_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MESSAGE" as
/* $Header: ARHAMSGB.pls 120.6 2006/05/24 07:23:48 vsegu noship $ */
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
--  31-MAR-94	W Smith		AR copies this package for its own use.
--
--  10-FEB-97   V Ahluwalia     When others then exception is raised into the
--				outer block in insert into
--				ar_conc_request_messages, as previous call
--				caused looping when table extents are full
--  29-MAR-01   J Huang         Bug 1706869: Modified procedure Insert_Row to
--                              make it as AUTONOMOUS_TRANSACTION.
--  02-14-02   Added one more procedure to get last few messages
--
-- 02-22-2002 Jyoti Pandey Moved all the logic from  arplbmsg.sql
--               at version 115.5 for new GSCC standards
-- 12-04-02   Jyoti Pandey     Added NOCOPY to Get procedure for GSCC warnings
-- 23-NOV-04  S V Sowjanya      Bug 3871056: Added global varible
--				G_Account_Merge_Logging, Assigned value to this
--                              variable in initialize procedure.
--                              Added if condition in procedure Set_line to log
--          			messages only if the profile HZ_ACCOUNT_MERGE_LOGGING
--                              is set.
-- 27-APR-06  S V Sowjanya      Bug 5010855. Replaced reference to arp_standard with
--				HZ_UTILITY_V2PUB
-- 24-APR-06  S V Sowjanya      Bug 5239180. Replaced MM with MI in date conversion
/*------------------------------ DATA TYPES ---------------------------------*/
TYPE MESSAGE_TABLE_TYPE IS TABLE of
  VARCHAR2(255)
    INDEX BY BINARY_INTEGER;

TYPE CODE_TABLE_TYPE IS TABLE of
  VARCHAR2(12)
    INDEX BY BINARY_INTEGER;

TYPE DATE_TABLE_TYPE IS TABLE of
  VARCHAR2(30)
    INDEX BY BINARY_INTEGER;


/*---------------------------- PRIVATE VARIABLES ----------------------------*/

G_TMessage_Buffer    MESSAGE_TABLE_TYPE;	-- Message Stack
G_TEmpty_Msg_Buffer  MESSAGE_TABLE_TYPE;	-- Empty Stack used for
						-- clearing memory
G_TMessage_Type	     CODE_TABLE_TYPE;		-- Message Type Stack in sync.
						-- with Message Stack
G_TEmpty_Type	     CODE_TABLE_TYPE;		-- Emtpy Type Stack

G_TDate_Buffer       DATE_TABLE_TYPE;           -- Creation Date Stack
G_TEmpty_Date        DATE_TABLE_TYPE;           -- Empty Date Stack

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
						-- AR_CONC_REQUEST_MESSAGES

G_User_Id	     NUMBER := FND_PROFILE.Value('USER_ID');
G_Conc_Request_Id    NUMBER;
G_Account_Merge_Logging VARCHAR2(1);

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE Insert_Row(X_Message_Text VARCHAR2,
		     X_Message_Type VARCHAR2,
		     X_Error_Number NUMBER) IS
BEGIN
  INSERT INTO ar_conc_request_messages(conc_request_message_id,
				       creation_date,
				       created_by,
				       request_id,
				       type,
				       error_number,
				       text)
		         VALUES(ar_conc_request_messages_s.nextval,
				SYSDATE,
				G_User_Id,
				G_Conc_Request_Id,
				X_Message_Type,
				X_Error_Number,
				X_Message_Text);
EXCEPTION
  When OTHERS then
    -- Set_Error('ARP_MESSAGE.Insert_Message');
  RAISE ;
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
-- Writes message either to the message stack or AR_CONC_REQUEST_MESSAGES
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
    G_TMessage_Buffer(G_Msg_Count) := substrb(Message_Text,1,255);
    G_TMessage_Type(G_Msg_Count) := Message_Type;
    G_TDate_Buffer(G_Msg_Count) := TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'); --bug 5239180 replaced MM with MI
  end if;

END;


-- NAME
--   Decode_Message
--
-- PURPOSE
--   Parse an encoded VARCHAR2 string that stores the information
--   necessary to a call the client Message Dictionary API, and
--   returns the translated message.
--
--   The encoded message will be of the following format.
--
--  NOTES
--    o An arbitrary number of tokens are supported (unless variable
--      Temp_Message is exceeded).
--    o Token values may contain spaces and quotes.
--    o One or more spaces is used to delimit components of the
--      encoded message.
--

FUNCTION Decode_Message(Encoded_Message VARCHAR2) Return VARCHAR2 IS
  Temp_Message	  VARCHAR2(500);
  Appl_Short_Name VARCHAR2(3);
  Translate	  BOOLEAN;
  Temp_Buf	  VARCHAR2(30);
  Token_Value	  VARCHAR2(50);
  Translate_Arg	  VARCHAR2(10);
  Pos1		  NUMBER;
  Pos2		  NUMBER;
BEGIN

  Temp_Message := Ltrim(Encoded_Message);
  --
  -- Extract the Application Short Name and Message Name
  --
  Pos1 := instrb(Temp_Message, ' ', 1);
  Appl_Short_Name := substrb(Temp_Message, 1, Pos1 - 1);
  Temp_Message := Ltrim(substrb(Temp_Message, Pos1 + 1));
  Pos1 := instrb(Temp_Message, ' ', 1);
  --
  -- Store the Message name in variable Temp_Buf
  --
  if (Pos1 = 0) then
    Temp_Buf := Temp_Message;
    Temp_Message := NULL;
  else
    Temp_Buf := substrb(Temp_Message, 1, Pos1 - 1);
    Temp_Message := Ltrim(substrb(Temp_Message, Pos1 + 1));
  end if;
  --
  --  Set the Message Name
  --

  FND_MESSAGE.Set_Name(Appl_Short_Name, Temp_Buf);

  --
  --  Extract the token information if necessary.
  --
  if (Temp_Message is not NULL) then
    LOOP
      --
      -- Store the token name in Temp_Buf
      --
      Pos1 := instrb(Temp_Message, ' ', 1);
      Temp_Buf := substrb(Temp_Message, 1, Pos1 - 1);
      --
      -- Locate the Token Value Delimiters and extract the token value.
      --
      Pos1 := instrb(Temp_Message, '\"', 1);
      Pos2 := instrb(Temp_Message, '\"', Pos1 + 2, 1);
      Token_Value := substrb(Temp_Message, Pos1 + 2, Pos2 - Pos1 - 2);
      Temp_Message := Ltrim(substrb(Temp_Message, Pos2 + 2));
      Pos1 := instrb(Temp_Message, ' ', 1);
      --
      -- Pos1 will equal 0 when Temp_Message is NULL which means that
      -- there are no more tokens to process.
      --
      if (Pos1 <> 0) then
        Translate_Arg := Upper(substrb(Temp_Message, 1, Pos1 - 1));
        Temp_Message := Ltrim(substrb(Temp_Message, Pos1 + 1));
      else
	Translate_Arg := Upper(Temp_Message);
        Temp_Message := NULL;
      end if;
      if (Translate_Arg = 'TRUE') then
        Translate := True;
      elsif (Translate_Arg = 'FALSE') then
	Translate := False;
   end if;

      FND_MESSAGE.Set_Token(Temp_Buf, Token_Value, Translate);

             Exit when (Temp_Message is NULL);
    end LOOP;
  end if;

  Temp_Message := FND_MESSAGE.Get;

  Return(Temp_Message);

RETURN NULL;
EXCEPTION
  When OTHERS then
  null;

RETURN NULL;

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
--        AR_CONC_REQUEST_MESSAGES.
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
		     Debug_Flag		VARCHAR2 ,
		     Debug_Output_Code  VARCHAR2 ) IS
BEGIN
  G_Conc_Request_Id := Conc_Request_Id;
  G_User_Id := HZ_UTILITY_V2PUB.user_id; --arp_standard.profile.user_id;
  G_Account_Merge_Logging := fnd_profile.value('HZ_ACCOUNT_MERGE_LOGGING');
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
--   inserted into AR_CONC_REQUEST_MESSAGES are inserted.
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
 IF NVL(G_Account_Merge_Logging,'N') = 'Y' THEN
  Set_Line(Message_Text, 'NO_TRANSLATE', NULL);
 END IF;
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
   if (    (G_Output_Code = 'TABLE')
       and (G_Ins_Message_Flag = 'Y')) then
--  if (G_Ins_Message_Flag = 'Y') then
    Insert_Row(G_TMessage_Buffer(G_Msg_Count),
	       G_TMessage_Type(G_Msg_Count),
	       NULL);
  end if;
  G_Msg_Count := G_Msg_Count + 1;
  G_TMessage_Buffer(G_Msg_Count) := Appl_Short_Name || ' ' || Message_Name;
  G_TMessage_Type(G_Msg_Count) := 'TRANSLATE';
  G_TDate_Buffer(G_Msg_Count) := TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'); --bug 5239180 replaced MM with MI
  G_Ins_Message_Flag := 'Y';
END;


--
-- NAME
--  DEBUG
--
-- PURPOSE
--   Writes a debugging message to the Message Stack only if
--   the profile option value for AR_DEBUG = 'Y'.

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
		    Translate   IN BOOLEAN ) IS
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

PROCEDURE Get(Message_Buf    OUT NOCOPY VARCHAR2,
	      Message_Type   OUT NOCOPY VARCHAR2,
	      Status         OUT NOCOPY NUMBER) IS
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

PROCEDURE Get(Message_Buf    OUT NOCOPY VARCHAR2,
              Message_Type   OUT NOCOPY VARCHAR2,
              Creation_Date  OUT NOCOPY VARCHAR2,
              Status         OUT NOCOPY NUMBER) IS
BEGIN
  if (   (G_Msg_Ptr > G_Msg_Count)
      or (G_Msg_Count = 0)) then
    Status := 0;
    Clear;
  else
    Message_Buf  := G_TMessage_Buffer(G_Msg_Ptr);
    Message_Type := G_TMessage_Type(G_Msg_Ptr);
    Creation_Date := G_TDate_Buffer(G_Msg_Ptr);
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
  G_TMessage_Buffer.Delete;
  G_TMessage_Type.Delete;
  G_TDate_Buffer.Delete;

--  G_TMessage_Buffer := G_TEmpty_Msg_Buffer;
--  G_TMessage_Type   := G_TEmpty_Type;
--  G_TDate_Buffer    := G_TEmpty_Date;
  G_Msg_Count       := 0;
  G_Msg_Ptr         := 1;
END;


--
--  Temporary function for backwards compatibility.
--  Use Set_Error instead.
--
PROCEDURE Put_DB_Error(Routine IN VARCHAR2 ,
		       Context IN VARCHAR2 ) IS
BEGIN
  Set_Error(Routine, Context);
END;

PROCEDURE Set_Error(Routine IN VARCHAR2 ,
		    Context IN VARCHAR2 ) IS
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
  DELETE from ar_conc_request_messages
  WHERE  request_id = X_Request_Id;
END;

FUNCTION Last_Message_Sequence Return NUMBER IS
  CURSOR C_Last_Seq IS
    SELECT max(conc_request_message_id)
    FROM   ar_conc_request_messages
    WHERE  request_id = G_Conc_Request_Id;

  Last_Msg_Seq NUMBER;

BEGIN
  OPEN C_Last_Seq;
  FETCH C_Last_Seq INTO Last_Msg_Seq;
  CLOSE C_Last_Seq;
  return(Last_Msg_Seq);

EXCEPTION
  When OTHERS then
    ARP_MESSAGE.Set_Error('Last_Message_Sequence');
    Raise;
END;

FUNCTION Get_Last_Few_Messages(num IN NUMBER)
RETURN VARCHAR2 IS

 buf VARCHAR2(2000);
 l_message_type  VARCHAR2(12);
 l_count  number;

BEGIN
  if (   (G_Msg_Ptr > G_Msg_Count)
      or (G_Msg_Count = 0)) then
    Clear;
  else

   if G_Msg_Count < num then
       l_count := G_Msg_Count;
    else
        l_count := num;
    end if;

     for I in 1..l_count LOOP
       l_message_type := G_TMessage_Type(G_Msg_Count-l_count+i);

      if   l_message_type = 'TRANSLATE' then
           buf := buf ||fnd_global.local_chr(10)||decode_message(G_TMessage_Buffer( (G_Msg_Count-l_count+i)) );
      else
          buf := buf ||fnd_global.local_chr(10)||G_TMessage_Buffer( (G_Msg_Count-l_count+i));
      end if;

   END LOOP;
  end if;

   RETURN BUF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;


END ARP_MESSAGE;

/
