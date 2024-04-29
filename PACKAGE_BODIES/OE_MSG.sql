--------------------------------------------------------
--  DDL for Package Body OE_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MSG" AS
/* $Header: OEXUTMGB.pls 115.1 99/07/16 08:16:42 porting shi $ */

------------------------------------------------------------------------
--1. Added message name to message table in the order
--   of the index value increase by 1 (start with 1).
--2. Return TRUE if successful, otherwise, return FALSE.
------------------------------------------------------------------------
function SET_MESSAGE_NAME(
   MSG_NAME          IN VARCHAR2 DEFAULT NULL
                          )
   return BOOLEAN
IS
   RetCode BOOLEAN := TRUE;
begin

  if  ( (MSG_NAME is NULL ) or (OE_Msg_Last_Msg_Count >=100) )
  then
     retCode := FALSE;
     GOTO ExitPoint;
  end if;

  -- next available slot
  OE_Msg_Last_Msg_Count := OE_Msg_Last_Msg_Count +1;
  OE_Msg_Message_Name_Buffer(OE_Msg_Last_Msg_Count)      := MSG_NAME;

<<ExitPoint>>
  OE_Msg_Token_Count(OE_Msg_Last_Msg_Count) := 0;
  return(RetCode);
end ;



------------------------------------------------------------------------
--1. Added message name , token name and token value to table in the order
--   of the index value increase by 1 (start with 1).
--2. Return TRUE if successful, otherwise, return FALSE.
------------------------------------------------------------------------
function SET_BUFFER_MESSAGE(
   MSG_NAME         IN VARCHAR2 DEFAULT NULL
,  TOKEN_NAME       IN VARCHAR2 DEFAULT NULL
,  TOKEN_VALUE      IN VARCHAR2 DEFAULT NULL
                            )
   return BOOLEAN
IS
   RetCode BOOLEAN := TRUE;
begin

  if  (MSG_NAME is NULL )  -- message name can't be NULL
  then
     retCode := FALSE;
     GOTO ExitPoint;
  end if;

  if ((OE_Msg_Last_Msg_Count = 0) or
      (MSG_NAME <> OE_Msg_Message_Name_Buffer(OE_Msg_Last_Msg_Count)) )
  then
     retCode := SET_MESSAGE_NAME(MSG_NAME);
     if ( retCode = FALSE )
     then
        GOTO ExitPoint;
     end if;
  end if;

  if ( TOKEN_NAME is not NULL )
  then
     OE_Msg_Last_Token_Count := OE_Msg_Last_Token_Count + 1;

     if ( OE_Msg_Token_Count(OE_Msg_Last_Msg_Count) = 0 )
     then                            -- first token of this message
        OE_Msg_Token_Count(OE_Msg_Last_Msg_Count) := OE_Msg_Last_Token_Count;
     elsif ( (OE_Msg_Last_Token_Count - OE_Msg_Token_Count(OE_Msg_Last_Msg_Count)) >10 )
     then                            -- Can't over 10 tokens in one message
        OE_Msg_Last_Token_Count := OE_Msg_Last_Token_Count -1;
        retCode := FALSE;
        GOTO ExitPoint;
     end if;

     OE_Msg_Token_Name_Buffer(OE_Msg_Last_Token_Count)    := TOKEN_NAME;
     OE_Msg_Token_Value_Buffer(OE_Msg_Last_Token_Count)   := TOKEN_VALUE;

  end if;

<<ExitPoint>>
  return(RetCode);
end ;


--
-- NAME
--  Set_Buffer_Message
--
PROCEDURE Set_Buffer_Message(Msg_Name    IN VARCHAR2,
			     Token_Name	 IN VARCHAR2 Default NULL,
			     Token_Value IN VARCHAR2 Default NULL) is
 result BOOLEAN;
begin
  result := Set_Buffer_Message(Msg_Name, Token_Name, Token_Value);
end;

--
-- NAME
--   Internal_Exception
--
PROCEDURE Internal_Exception(Routine    VARCHAR2,
			     Operation  VARCHAR2,
			     Object     VARCHAR2,
			     Message    VARCHAR2 Default NULL) is
  Delimiter VARCHAR2(1);
begin

    Delimiter := '
';

  Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION', 'ROUTINE', Routine);
  Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION', 'OPERATION', Operation);
  Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION', 'OBJECT', Object);
  Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION', 'MESSAGE',
		     Substrb(sqlerrm || Delimiter || Message, 1, 255));
end;


------------------------------------------------------------------------
--1. Get message name and all tokens' name and tokens' value according to
--   the input index value.
--2. Return TRUE if successful, otherwise, return FALSE.
------------------------------------------------------------------------
procedure Get_Message_Name(
   MSG_NAME          OUT VARCHAR2
,  LAST_MESSAGE      OUT NUMBER
                           )
IS
begin
   -- Get next message name
   OE_Msg_Show_Msg_Count := OE_Msg_Show_Msg_Count + 1;
   if ( OE_Msg_Last_Msg_Count >= OE_Msg_Show_Msg_Count )
   then
       MSG_NAME  := OE_Msg_Message_Name_Buffer(OE_Msg_Show_Msg_Count);
   end if ;

   if ( ( OE_Msg_Last_Msg_Count = 0 )or
        ( OE_Msg_Last_Msg_Count = OE_Msg_Show_Msg_Count) )
   then
      LAST_MESSAGE := 1;  -- TRUE : no more message
   else
      LAST_MESSAGE := 0;  -- FALSE
   end if;
end ;



------------------------------------------------------------------------
--1. Get message name and all tokens' name and tokens' value according to
--   the input index value.
--2. Return TRUE if successful, otherwise, return FALSE.
------------------------------------------------------------------------
procedure Get_Buffer_Message(
   TOKEN_NAME        OUT VARCHAR2
,  TOKEN_VALUE       OUT VARCHAR2
,  LAST_TOKEN        IN OUT NUMBER
                           )
IS
  No_Token_Flag      boolean := FALSE;
begin

   if ( OE_Msg_Last_Msg_Count <= 0 )
   then                 --no message available
       LAST_TOKEN := 1; --TRUE
       TOKEN_NAME := '';
       No_Token_Flag:= TRUE;
   else
       if ( OE_Msg_Token_Count(OE_Msg_Show_Msg_Count) = 0 )
       then
           TOKEN_NAME := '';  -- no token belongs to this message
           No_Token_Flag := TRUE;
           LAST_TOKEN := 1; --TRUE
       else
           TOKEN_NAME := OE_Msg_Token_Name_Buffer(OE_Msg_Show_Token_Count);
           TOKEN_VALUE:= OE_Msg_Token_Value_Buffer(OE_Msg_Show_Token_Count);
       end if;

       if (  No_Token_Flag = FALSE )
       then
           if ( OE_Msg_Show_Token_Count = Get_Last_Token_Of_This_Msg )
           then                  --no token or last token
                LAST_TOKEN := 1; --TRUE
           else
                LAST_TOKEN := 0;  --FALSE
           end if;
           OE_Msg_Show_Token_Count := OE_Msg_Show_Token_Count + 1;
       end if;
    end if;

    if ( (LAST_TOKEN = 1 ) AND
         (OE_Msg_Last_Msg_Count <= OE_Msg_Show_Msg_Count ) )
    then
         CLEAN_BUFFER_MESSAGE;
    end if;
end ;


------------------------------------------------------------------------
--1. Get the last token's index of the current message.
--2. Return last token's index number.
------------------------------------------------------------------------
function Get_Last_Token_Of_This_Msg
   return NUMBER
IS
   Last_Token_Count   NUMBER := 0;
   TempIndex           NUMBER;
begin

   if ( OE_Msg_Show_Msg_Count < OE_Msg_Last_Msg_Count )
   then

        FOR TempIndex in OE_Msg_Show_Msg_Count .. OE_Msg_Last_Msg_Count-1 LOOP
            if ( OE_Msg_Token_Count(TempIndex+1) <> 0 )
            then
               Last_Token_Count := OE_Msg_Token_Count(TempIndex+1) -1;
            end if;
        END LOOP;
   end if;

   if ( Last_Token_Count = 0 )
   then
       Last_Token_Count := OE_Msg_Last_Token_Count;
   end if;

   return (Last_Token_Count);
end;  -- Get_Last_Token_Of_This_Msg


------------------------------------------------------------------------
--1.Clean all the Token name and Token Value tables.
--2.Reset Message Count to 0 .
--3.Clean Message Name and Token Count table.
------------------------------------------------------------------------
procedure CLEAN_BUFFER_MESSAGE is
Empty_Buffer                 MESSAGE_TABLE_TYPE;  -- Empty Message stack
Empty_Token_Count_Buffer     TOKEN_COUNT_TABLE_TYPE ;
begin
    OE_Msg_Message_Name_Buffer := Empty_Buffer;
    OE_Msg_Token_Name_Buffer   := Empty_Buffer;
    OE_Msg_Token_Value_Buffer  := Empty_Buffer;
    OE_Msg_Token_Count         := Empty_Token_Count_Buffer;
    OE_Msg_Last_Msg_Count      := 0;
    OE_Msg_Last_Token_Count    := 0;
    OE_Msg_Show_Msg_Count      := 0;
    OE_Msg_Show_Token_Count    := 1;

end;


------------------------------------------------------------------------
--Append debug info. to the OE_Debug_Info_Buffer and use carriage return
--as seperator.
------------------------------------------------------------------------
procedure Set_Debug_Info(
   Debug_Info      IN VARCHAR2 DEFAULT NULL
                        )
IS
begin
   OE_Debug_Info_Buffer := OE_Debug_Info_Buffer||'\n'|| Debug_Info;
end ; -- Set_Debug_Info


------------------------------------------------------------------------
--1. copy Debug_Info_Buffer to the Debug_Info
--2. Clear out the Debug_Info_Buffer.
------------------------------------------------------------------------
procedure Get_Debug_Info(
   Debug_Info        OUT VARCHAR2
                         )
IS
begin
    Debug_Info := OE_Debug_Info_Buffer;
    Clean_Debug_Info;
end ;

------------------------------------------------------------------------
-- Set OE_Debug_Info_Buffer as empty
------------------------------------------------------------------------
procedure Clean_Debug_Info
IS
begin
    OE_Debug_Info_Buffer := NULL;
end ;


END OE_MSG;

/
