--------------------------------------------------------
--  DDL for Package FA_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEBUG_PKG" AUTHID CURRENT_USER as
/* $Header: FADEBUGS.pls 120.3.12010000.2 2009/07/19 14:41:27 glchen ship $ */

-- Procedure  	Initialize
--
-- Usage	Used by server program to intialize the global
--		debug message table and set the debug flag
-- Desc		Clears the FA_DEBUG_TABLE and reset the index
--		and counter of debug table
--
PROCEDURE Initialize;


-- Function  	Print_Debug
--
-- Usage	Used by server program to check the debug flag
-- Desc		Returns TRUE if debug flag is 'YES'
--		otherwise returns FALSE
--
FUNCTION Print_Debug RETURN BOOLEAN;


-- Procedure	Add
--
-- Usage	Used by server programs to add debug message to
--		debug message table
--
-- Desc		This procedure is oeverloaded.
--		There are four datatypes differing in Value parameter:
--		   Base :
--			Value	VARCHAR2
--		   first overloaded procedure :
--			Value   NUMBER
--		   second overloaded procedure :
--			Value	DATE
--		   fourth overloaded procedure :
--			Value   BOOLEAN
--
-- Parameters 	fname  IN  Calling function name
--		elemen IN  variable name
--		value  IN  value of variable
--
PROCEDURE Add
( 	fname		in	varchar2,
  	element		in	varchar2,
  	value		in	varchar2,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null);

PROCEDURE Add
( 	fname		in 	varchar2,
  	element		in	varchar2,
  	value		in	number,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null);

PROCEDURE Add
(	fname		in 	varchar2,
  	element		in	varchar2,
  	value		in	date,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null);

PROCEDURE Add
(  	fname		in 	varchar2,
  	element		in	varchar2,
  	value		in	boolean,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null);


-- Procedure	Get_Debug_Messages
--
-- Usage	Used by client program to get debug messages from debug
--		table
--
-- Desc		Returns 10 messages at a time when the procedure is called
--		Also returns a flag to indicate the index is at the end
--		of debug table
--
PROCEDURE Get_Debug_Messages
(	d_mesg1	 out nocopy varchar2,
	d_mesg2	 out nocopy varchar2,
	d_mesg3	 out nocopy varchar2,
	d_mesg4	 out nocopy varchar2,
	d_mesg5	 out nocopy varchar2,
	d_mesg6	 out nocopy varchar2,
	d_mesg7	 out nocopy varchar2,
	d_mesg8	 out nocopy varchar2,
	d_mesg9	 out nocopy varchar2,
	d_mesg10 out nocopy varchar2,
	d_more_mesgs out nocopy boolean, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


-- Procedure  	Set_Debug_Flag
--
-- Usage	Used by internal deveoplers to set the debug flag
--		to 'YES'
--
PROCEDURE Set_Debug_Flag
(	debug_flag	in	varchar2 := 'YES', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


-- Procedure	Reset_Index
--
-- Usage	Used by internal developer to move the index
--		of debug table
--
PROCEDURE Reset_Index
(	d_index		in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


-- Procedure	Dump_Debug_Messages
--
-- Usage	Used by internal developers to print all messages
--		of debug table
--
PROCEDURE Dump_Debug_Messages
(	target_str	in	varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


-- Procedure    Dump_Debug_Messages
--
-- Usage        Used to add all messages to the fnd message stack
--              max_mesgs is not currently used
--
PROCEDURE Dump_Debug_Messages
(       max_mesgs       in      number := NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


-- Procedure    Write_Debug_Log
--
-- Usage        To get messages from debug message stack and write to log file.
--
PROCEDURE  Write_Debug_Log;


END FA_DEBUG_PKG;

/
