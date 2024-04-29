--------------------------------------------------------
--  DDL for Package Body OE_DBG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DBG" as
/* $Header: OEXUTDBB.pls 115.0 99/07/16 08:16:36 porting ship $ */
--
-- PURPOSE
--  This package allows debugging messages to be issued by server PL/SQL
--  that can be retrieved by the call client program.
--
-- HISTORY
--
--  18-APR-94	R Lee 		Created.
--
/*------------------------------ DATA TYPES ---------------------------------*/

  TYPE MESSAGE_TABLE_TYPE IS TABLE of
  VARCHAR2(500)
    INDEX BY BINARY_INTEGER;

/*---------------------------- PRIVATE VARIABLES ----------------------------*/

  G_Message_Buffer     MESSAGE_TABLE_TYPE;	-- Message Stack
  G_Empty_Msg_Buffer   MESSAGE_TABLE_TYPE;	-- Empty Stack used for
						-- clearing memory
						-- with Message Stack
  G_Msg_Count	     NUMBER := 0;		-- Num of Messages on stack
  G_Msg_Ptr	     NUMBER := 1;		-- Points to next Message
						-- on stack to retreive.
  G_Debug_Flag	     VARCHAR2(1) := 'N';	-- Flag to indicate debug mode


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

  --
  -- NONE
  --

/*---------------------------- PUBLIC ROUTINES ------------------------------*/

  --
  -- NAME
  --   Set_Line
  --
  -- PURPOSE
  --   Puts a char string to message stack
  --
  PROCEDURE Set_Line(Message_Text IN VARCHAR2) IS
  begin
    --
    -- If the number of messages is greater than 1000, don't store
    -- an more messages.  This could be removed, but developer's
    -- could potentially use up all their process memory if they store
    -- thousands and thousands of messages.
    --
    if (G_Msg_Count > 1000) then
      return;
    end if;
    --
    -- Increment message count, and put message on the stack.
    --
    G_Msg_Count := G_Msg_Count + 1;
    G_Message_Buffer(G_Msg_Count) := Message_Text;
  end;

  --
  -- NAME
  --   Get
  --
  -- PURPOSE
  --   Retrieves the next message on the message stack into
  --   Message_Buffer.
  --
  --   When no message is retrieved, Status is set to 0.
  --   When a message is retreived, Status is set to the length
  --   of the message.
  --
  PROCEDURE Get(Message_Line OUT VARCHAR2,
	        Status       OUT NUMBER) IS
  begin
    if (   (G_Msg_Ptr > G_Msg_Count)
        or (G_Msg_Count = 0)) then
      Status := 0;
      Clear;
    else
      Message_Line := G_Message_Buffer(G_Msg_Ptr);
      Status 	   := LengthB(G_Message_Buffer(G_Msg_Ptr));
      G_Msg_Ptr    := G_Msg_Ptr + 1;
    end if;
  end;

  --
  -- NAME
  --   Get
  --
  -- NOTES
  --   Ten arguments were added to improve network performance.
  --
  PROCEDURE Get(Msg_Line1   OUT VARCHAR2,
	        Msg_Line2   OUT VARCHAR2,
	        Msg_Line3   OUT VARCHAR2,
	        Msg_Line4   OUT VARCHAR2,
	        Msg_Line5   OUT VARCHAR2,
	        Msg_Line6   OUT VARCHAR2,
	        Msg_Line7   OUT VARCHAR2,
	        Msg_Line8   OUT VARCHAR2,
	        Msg_Line9   OUT VARCHAR2,
	        Msg_Line10  OUT VARCHAR2,
	        Cnt	    OUT NUMBER) IS
    Status NUMBER;
  begin
    Get(Msg_Line1, Status);
    if (Status = 0) then Cnt := 0; return; end if;
    Get(Msg_Line2, Status);
    if (Status = 0) then Cnt := 1; return; end if;
    Get(Msg_Line3, Status);
    if (Status = 0) then Cnt := 2; return; end if;
    Get(Msg_Line4, Status);
    if (Status = 0) then Cnt := 3; return; end if;
    Get(Msg_Line5, Status);
    if (Status = 0) then Cnt := 4; return; end if;
    Get(Msg_Line6, Status);
    if (Status = 0) then Cnt := 5; return; end if;
    Get(Msg_Line7, Status);
    if (Status = 0) then Cnt := 6; return; end if;
    Get(Msg_Line8, Status);
    if (Status = 0) then Cnt := 7; return; end if;
    Get(Msg_Line9, Status);
    if (Status = 0) then Cnt := 8; return; end if;
    Get(Msg_Line10, Status);
    if (Status = 0) then Cnt := 9; else Cnt := 10; end if;
  end;

  --
  -- NAME
  --   Clear
  --
  -- PURPOSE
  --   Frees memory used the the message stack and resets the
  --   the Message Stack counter and pointer variables.
  --
  PROCEDURE Clear IS
  begin
    G_Message_Buffer  := G_Empty_Msg_Buffer;
    G_Msg_Count       := 0;
    G_Msg_Ptr         := 1;
  end;


  FUNCTION Message_Count Return NUMBER IS
  begin
    Return(G_Msg_Count);
  end;

END OE_DBG;

/
