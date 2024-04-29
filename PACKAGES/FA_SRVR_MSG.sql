--------------------------------------------------------
--  DDL for Package FA_SRVR_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SRVR_MSG" AUTHID CURRENT_USER as
/* $Header: FASMESGS.pls 120.3.12010000.2 2009/07/19 11:47:03 glchen ship $ */

--  GLOBAL VARIABLES

--  Return Status
--
--  FA_RET_SUCCESS means that the program was successful in performing
--  all the operation requested by its caller.
--
--  FA_RET_ERROR means that the program failed to perform one or more
--  of the operations requested by its caller.
--
--  FA_RET_UNEXP_ERROR means that the program was not able to perform
--  any of the operations requested by its callers because of an
--  unexpected error.
--
FA_RET_SUCCESS     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
FA_RET_ERROR	   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
FA_RET_UNEXPECTED  CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

--  Error Exception
--
--  FA_EXC_ERROR       An known error and program can handle by setting defined
--	               error message
--  FA_EXC_UNEXPECTED  An unexpected error which usually is a database error
--                     and program return SQL error message
--
FA_EXC_ERROR		EXCEPTION;
FA_EXC_UNEXPECTED	EXCEPTION;

-- Message Level
--
-- FA_MSG_DEBUG		FA profile value of 'PRINT_DEBUG'
--
-- FA_ERROR_LEVEL 	Message level
--
FA_MSG_DEBUG		VARCHAR2(3)	:= 'NO';
FA_ERROR_LEVEL		NUMBER		:= 10;



--  Procedure	Init_Server_Message
--
--  Usage	Called by server side program to intialize the global API
--		message table and get the value of 'PRINT_DEBUG' user profile
--
PROCEDURE Init_Server_Message;


--  Procedure	Reset_Server_Message
--
--  Usage	Called by server side program to delete all messageds on
--		the global API message table
--
PROCEDURE Reset_Server_Message;


-- Procedure	Add_SQL_Error
--
-- Usage	Called from 'WHEN OTHER' exception to insert SQL error
--		message for unexcepted database error and calling function
--		name into message stack. Also, it resets the global message
--		level to 1.
--
-- Example
--		WHEN OTHERS then
--		   FA_SRVR_MSG.Add_SQL_Error
--			(calling_fn	=> 'ALEX_TEST_PKG.Check_Book_Status');
--
PROCEDURE Add_SQL_Error
(	calling_fn	in	varchar2,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null);


--  Procedure	Add_Message
--
--  Usage	Called by server side function to a pre-defined error message
--		and/or calling function name into message stack and global API
--              message table.
--
--  Desc	Add_Message inserts calling function name into message stack
--		only if the global FA_MSG_DEBUG is 'YES' or FA_ERROR_LEVEL is 1.
--
--  Example
--		a. insert function name to the stack:
--
--	    	   FA_SRVR_MSG.add_message
--		      (CALLING_FN	=> 'ALEX_TEST_PKG.Check_Book_Status');
--
--              b. insert pre-defined message to the stack:
--
--		   FA_SRVR_MSG.add_message
--			(CALLING_FN	=> 'ALEX_TEST_PKG.Check_Book_Status',
--		 	 NAME		=> 'FA_TFRINV_ZERO_TFR_COST');
--
--	        c. insert pre-defined message with token to the stack:
--
--	  	   FA_SRVR_MSG.add_message
--			(CALLING_FN	=> 'ALEX_TEST_PKG.Check_Book_Status',
--		 	 NAME		=> 'FA_ACCOUNT_CCID_CANNOT_UPGRADE',
--		 	 TOKEN1		=> 'BOOK',
--		 	 VALUE1		=> X_Book_TYpe_Code);
--
PROCEDURE Add_Message
(	calling_fn	in	varchar2,
	name		in 	varchar2 := null,
	token1 	 	in 	varchar2 := null,
	value1 	 	in 	varchar2 := null,
	token2 	 	in 	varchar2 := null,
	value2 	 	in 	varchar2 := null,
	token3 	 	in 	varchar2 := null,
	value3 	 	in 	varchar2 := null,
	token4 	 	in 	varchar2 := null,
	value4 	 	in 	varchar2 := null,
        token5 	 	in 	varchar2 := null,
	value5 	 	in 	varchar2 := null,
	translate  	in 	boolean  := FALSE,
        application     in      varchar2 := 'OFA',
        p_log_level_rec in      fa_api_types.log_level_rec_type default null,
        p_message_level in      number := FND_LOG.LEVEL_ERROR );


--  Prodedure  	Get_Message
--
--  Usage	Called by client side program to return the number of messages
--              table and messages text in decoded and translated mode on the
--		golbal API message table
--
--  Parameters  mesg_count IN OUT  NUMBER number of messages in message table
--		mesg1 - mesg7 IN OUT VARCHAR2 message text
--
PROCEDURE Get_Message
(       mesg_count      in out nocopy  number,
        mesg1           in out nocopy  varchar2,
        mesg2           in out nocopy  varchar2,
        mesg3           in out nocopy  varchar2,
        mesg4           in out nocopy  varchar2,
        mesg5           in out nocopy  varchar2,
        mesg6           in out nocopy  varchar2,
        mesg7           in out nocopy  varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


--  Procedure  Set_Message_Level
--
--  Usage      Called by server side program to set the global variable
--             FA_ERROR_LEVEL.
--
--  Desc       By default, the FA_ERROR_LEVEL is set to 10 and Add_Message
--             only inserts a pre-defined message into message stack and does
--             not insert the calling function name into stack.  You can call
--             Set_Message_Level to override the default setting to insert
--             calling function name into stack.
--
PROCEDURE  Set_Message_Level
(	message_level	in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


--  Prodedure  	Dump_API_Messages
--
--  Usage	Called by server program for debugging purpose.
--		It prints all messages on API message stack to screen.
--
PROCEDURE Dump_API_Messages;

-- Procedure 	Write_Msg_Log
--
-- Usage	To get messages from message stack and write to log file.
--
-- Parameters	msg_data -- this value is actually not in use, since we do not
--		want to rely on the data, which we are not sure whether it is
--		in encoded or translated format.
PROCEDURE  Write_Msg_Log
(	msg_count	in number,
        msg_data        in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


END FA_SRVR_MSG;

/
