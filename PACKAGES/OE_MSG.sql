--------------------------------------------------------
--  DDL for Package OE_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MSG" AUTHID CURRENT_USER AS
/* $Header: OEXUTMGS.pls 115.0 99/07/16 08:16:45 porting ship $ */

----------------------  Define Date Type -----------------------------
TYPE MESSAGE_TABLE_TYPE IS TABLE of VARCHAR2(255)
     Index By BINARY_INTEGER;

TYPE TOKEN_COUNT_TABLE_TYPE IS TABLE of NUMBER
     Index By BINARY_INTEGER;


---------------------- Global Variable ----------------------
OE_Msg_Message_Name_Buffer    MESSAGE_TABLE_TYPE;  -- Message stactk
OE_Msg_Token_Name_Buffer      MESSAGE_TABLE_TYPE;  -- Message stactk
OE_Msg_Token_Value_Buffer     MESSAGE_TABLE_TYPE;  -- Message stactk
OE_Msg_Token_Count            TOKEN_COUNT_TABLE_TYPE ; --Count Token number for
                                                       --each message
OE_Debug_Info_Buffer          VARCHAR2(1000);  -- Debug information

OE_Msg_Last_Msg_Count         NUMBER  :=0;
OE_Msg_Last_Token_Count       NUMBER  :=0;
OE_Msg_Show_Msg_Count         NUMBER  :=0;
OE_Msg_Show_Token_Count       NUMBER  :=1;
OE_Debug_Index                NUMBER  :=0;

--------------------- GLOBAL Function Specifications -----------------------

---------------------------------------------------------------------------
--Module Name   : OEXUTMGS.pls and OEXUTMGB.pls
--Package Name  : OE_MSG
--Function Name : Set_Buffer_Message
--Parameters    : MSG_NAME    IN VARCHAR2 --Message Name
--              : TOKEN_NAME  IN VARCHAR2 --Token Name
--              : TOKEN_VALUE IN VARCHAR2 --Token Value
--Return Value  : Boolean value.
--                TRUE - Successfaul
--                FALSE - Fail
--Requirement   : 1.Message name can't be NULL
--                2.One message can't have more than 10 tokens.
--                3.Can't put more than 100 messages in the table without issue
--                  them.
--Description   : This function will add the message name to message name table if
--                the input message name is different from the last messgae name of
--                message name table.  Also, if the token name is not NULL, added
--                token name and token value to the token table.
-------------------------------------------------------------------------------
function Set_Buffer_Message(
   MSG_NAME         IN VARCHAR2 DEFAULT NULL
,  TOKEN_NAME       IN VARCHAR2 DEFAULT NULL
,  TOKEN_VALUE      IN VARCHAR2 DEFAULT NULL
                           )
   return BOOLEAN;


--
-- NAME
--   Set_Buffer_Message
--
-- DESCRIPTION
--   Procedure version of function Set_Buffer_Message
--   (See FUNCTION Set_Buffer_Message)
--
PROCEDURE Set_Buffer_Message(Msg_Name     IN VARCHAR2,
			     Token_Name   IN VARCHAR2 Default NULL,
			     Token_Value  IN VARCHAR2 Default NULL);

--
-- NAME
--   Internal_Exception
--
-- ARGUMENTS
--   Routine		The name of the routine where the internal
--			execetion occured.  (Use the PACKAGE.Routine
--			convention.)
--   Operation		Name of the operation.
--   Object		Name of the exception object.
--   Message		Any additional message can be optional
--			included as part of the message to the user.
--			Message is not translated.
-- DESCRIPTION
--   Used to report internal exceptions from server plsql.
--   This sets a message to be displayed with the following
--   information: Routine, Operation, Object, last encountered
--   sql error (if any) and optionally Message.
--
PROCEDURE Internal_Exception(Routine    VARCHAR2,
			     Operation  VARCHAR2,
			     Object     VARCHAR2,
			     Message    VARCHAR2 Default NULL);

-----------------------Local function specification ----------------------
function Set_Message_Name(
   MSG_NAME          IN VARCHAR2 DEFAULT NULL
                           )
   return BOOLEAN;


procedure Get_Message_Name(
   MSG_NAME        OUT VARCHAR2
,  LAST_MESSAGE    OUT NUMBER
                           );

procedure Get_Buffer_Message(
   TOKEN_NAME        OUT VARCHAR2
,  TOKEN_VALUE       OUT VARCHAR2
,  LAST_TOKEN        IN OUT NUMBER
                           );

function Get_Last_Token_Of_This_Msg
   return NUMBER;

procedure Clean_Buffer_Message;


procedure Set_Debug_Info(
   Debug_Info      IN VARCHAR2 DEFAULT NULL
                           );

procedure Get_Debug_Info(
   Debug_Info        OUT VARCHAR2
                         );

procedure Clean_Debug_Info;

END OE_MSG;

 

/
