--------------------------------------------------------
--  DDL for Package Body BSC_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MESSAGE" AS
/* $Header: BSCUMSGB.pls 120.0 2005/06/01 16:02:21 appldev noship $ */

-- Global Variables
--
-- Message_Rec_Type
--
--	Type:	message type
--	Source:	calling funcation
--	Message: message string
--

Type Message_Rec_Type Is Record (
	Type		Number(3)	:= NULL,
	Source		Varchar2(80)	:= NULL,
	Message		Varchar2(2000)	:= NULL
);

--
-- Message_Tbl_Type: A global table type to store all messages
--
TYPE Message_Tbl_Type IS TABLE OF Message_Rec_Type
 INDEX BY BINARY_INTEGER;

G_Msg_Tbl		Message_Tbl_Type;

--
-- Global variables:
--
--   G_Msg_Count: holds number of all the messages on stack
--   G_T0_Count: number of type 0 messages on stack
--   G_T1_Count: number of type 1 messages on stack
--   G_T2_Count: number of type 2 messages on stack
--   G_T3_Count: number of type 3 messages on stack
--   G_Debug_Count: number of debug messages(type 4) on stack
--   G_session_id: database session_id
--   G_user_id: database user id
--
G_Msg_Count		Number := 0;
G_T0_Count		Number := 0;
G_T1_Count		Number := 0;
G_T2_Count		Number := 0;
G_T3_Count		Number := 0;
G_Debug_Count		Number := 0;
G_session_id		Number := -1;
G_user_id		Number := -1;
G_debug_flag		Varchar2(3) := 'NO';

Procedure Init (
	x_debug_flag	IN	Varchar2 := 'NO'
) Is
Begin
	G_Msg_Tbl.Delete;
 	G_Msg_Count := 0;
	G_T0_Count := 0;
	G_T1_Count := 0;
	G_T2_Count := 0;
	G_T3_Count := 0;
        -- Init deletes all the messages in the stack: g_msg_tbl.delete,
	-- and thus, debug message count goes down to zero as well.
	G_Debug_Count := 0;

        G_debug_flag := x_debug_flag;

        if (x_debug_flag = 'YES') then
	    bsc_utility.enable_debug;
        else
            bsc_utility.disable_debug;
        end if;

        -- Ref: bug#3482442 In corner cases this query can return more than one
        -- row and it will fail. AUDSID is not PK. After meeting with
        -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
        G_user_id := BSC_APPS.fnd_global_user_id;
        G_session_id := USERENV('SESSIONID');

End Init;

Procedure Reset (
	x_debug_flag	IN	Varchar2 := NULL
) Is
Begin

	BSC_Message.init(x_debug_flag);

End Reset;

Function Count (
	x_type		IN	Number := NULL
) Return Number Is
Begin
    if (x_type is null) then
	Return G_Msg_Count;
    elsif (x_type = 0) then
	return G_T0_Count;
    elsif (x_type = 1) then
	return G_T1_Count;
    elsif (x_type = 2) then
	return G_T2_Count;
    elsif (x_type = 3) then
	return G_T3_Count;
    elsif (x_type = 4) then
	return G_Debug_Count;
    end if;

    return (0); -- return zero for invalid type.

End Count;


Procedure Add (
	x_message	IN	Varchar2,
	x_source	IN	Varchar2,
	x_type		IN	Number := 0,
   	x_mode		IN	Varchar2 := 'N'
) Is
	l_msg_str	Varchar2(2000);
Begin

    if (x_type = 0) then
      l_msg_str := 'OBSC-1000: ' || x_source || ',  ' || x_message;
    else
	if (x_message = NULL) then
	    l_msg_str := 'OBSC-2000: ' || x_source;
	else
      	    l_msg_str := x_message;
	end if;
    end if;

    G_Msg_Count := G_Msg_Count + 1;

    G_Msg_Tbl(G_Msg_Count).Type := x_type;
    G_Msg_Tbl(G_Msg_Count).Source := x_source;
    G_Msg_Tbl(G_Msg_Count).Message := l_msg_str;

    if (x_type = 0) then
	G_T0_Count := G_T0_Count + 1;
    elsif (x_type = 1) then
	G_T1_Count := G_T1_Count + 1;
    elsif (x_type = 2) then
	G_T2_Count := G_T2_Count + 1;
    elsif (x_type = 3) then
	G_T3_Count := G_T3_Count + 1;
    elsif (x_type = 4) then
	G_Debug_Count := G_Debug_Count + 1;
    end if;

    if (x_mode = 'I') then

       Insert Into BSC_MESSAGE_LOGS(
		Source,
		Type,
		Message,
		Creation_Date, Created_By,
		Last_Update_Date, Last_Updated_By,
		Last_Update_Login)
       Values(x_source, x_type, l_msg_str,
              SYSDATE, G_user_id,
              SYSDATE, G_user_id, G_session_id
              );

    end if;

End Add;



Procedure Flush Is
Begin

     For i In 1 .. G_Msg_Count
     Loop

	Insert Into BSC_MESSAGE_LOGS(
		Source,
		Type,
		Message,
		Creation_Date, Created_By,
		Last_Update_Date, Last_Updated_By,
		Last_Update_Login)
       	Values (
    		G_Msg_Tbl(i).Source,
		G_Msg_Tbl(i).Type,
    		G_Msg_Tbl(i).Message,
		SYSDATE, G_user_id,
                SYSDATE, G_user_id, G_session_id
		);

     End Loop;

     BSC_Message.Reset(
		x_debug_flag 	=> G_debug_flag
		);

End Flush;

--
-- Name: Clean
-- Desc: Delete message from BSC_MESSAGE_LOGS if debug_flag is 'NO'
--
Procedure Clean Is
Begin

    if (G_debug_flag = 'NO') then

	delete
	from 	BSC_MESSAGE_LOGS
        where
               	last_update_login = G_session_id;
    end if;

Exception
    When Others Then
	BSC_MESSAGE.add(
		x_message => sqlerrm,
                x_source  => 'BSC_MESSAGE.Clean'
		);
End Clean;


Procedure Show Is
	l_count		Number;
Begin

    l_count := G_Msg_Tbl.Count;

    --dbms_output.put_line('OBSC Message Stacks: ' || to_char(l_count) || '/' ||
    --			  	to_char(G_Msg_Count) || ' Messages.');

    For i In 1 .. l_count
    Loop
        NULL;
	--dbms_output.put_line(to_char(i) || '-' ||
	--			To_Char(G_Msg_Tbl(i).Type) || ': ' ||
	--			G_Msg_Tbl(i).Source || ' - ' ||
	--			G_Msg_Tbl(i).Message
	--			);
    End Loop;

Exception
    When Others Then
        NULL;
	--dbms_output.put_line('Fatal Error - ' ||  SQLERRM);

End Show;

END BSC_MESSAGE;

/
