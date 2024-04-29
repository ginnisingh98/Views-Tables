--------------------------------------------------------
--  DDL for Package OE_DBG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DBG" AUTHID CURRENT_USER as
/* $Header: OEXUTDBS.pls 115.0 99/07/16 08:16:39 porting ship $ */

/*-------------------------------- ROUTINES ---------------------------------*/

  --
  -- NAME
  --   Set_Line
  --
  -- PURPOSE
  --   Writes a NON-TRANSLATED message to the message buffer
  --   for debugging purposes.
  --
  PROCEDURE Set_Line(Message_Text IN VARCHAR2);

  --
  -- NAME
  --   Get
  --
  -- PURPOSE
  --   Retrieves the next message on the message stack into
  --   Message_Line
  --
  --   When no message is retrieved, Status is set to 0.
  --   When a message is retreived, Status is set to the length
  --   of the message.
  --
  PROCEDURE Get(Message_Line   OUT VARCHAR2,
	      Status         OUT NUMBER);

  --
  -- NAME
  --   Get
  --
  -- ARGUMENTS
  --   Msg_Line1..Msg_Line10	The VARCHAR2 variables that
  --				messages should be copied into.
  --   Cnt			Cnt is populated with the number
  --				of messages retrieved from the
  --				message stack.
  --
  -- PURPOSE
  --   Retrieves up to 10 messages from the message stack and returns
  --   the actual number of messages retrieved in argument Cnt.
  --
  PROCEDURE Get(Msg_Line1	  OUT VARCHAR2,
	        Msg_Line2   OUT VARCHAR2,
	        Msg_Line3   OUT VARCHAR2,
	        Msg_Line4   OUT VARCHAR2,
	        Msg_Line5   OUT VARCHAR2,
	        Msg_Line6   OUT VARCHAR2,
	        Msg_Line7   OUT VARCHAR2,
	        Msg_Line8   OUT VARCHAR2,
	        Msg_Line9   OUT VARCHAR2,
	        Msg_Line10  OUT VARCHAR2,
	        Cnt	    OUT NUMBER);

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
  --   Messgae_Count
  --
  -- PURPOSE
  --   Returns the number of messages currently on the message stack.
  --
  FUNCTION Message_Count Return NUMBER;

END OE_DBG;

 

/
