--------------------------------------------------------
--  DDL for Package WSH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_UTIL" AUTHID CURRENT_USER AS
/* $Header: WSHUUTLS.pls 115.0 99/07/16 08:24:36 porting ship $ */


  --
  -- Package Types
  --
	TYPE logTyp IS RECORD (
		token		VARCHAR2(15),
		text_line	VARCHAR2(80)
	);

	TYPE logTabTyp IS TABLE OF logTyp INDEX BY BINARY_INTEGER;

	TYPE logCharTyp IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  --
  -- This function initializes the package. Should only be called if
  -- you care about the flush variable which is set to 'N' by default.
  -- Arguments:
  --   p_flush -> 'Y' or 'N' depending on whether the line is to be
  --              written to the file immediately or not.
  --

  FUNCTION Init (
	p_flush		IN	VARCHAR2 DEFAULT 'N'
  	) RETURN NUMBER;

  --
  -- This function returns if 'u' if calleWSHUOPNS.plsd form form or 'c' for
  -- concurrent program
  --

  FUNCTION Wshsrc RETURN VARCHAR2;

  --
  -- This procedure writes a line of text to the log file.
  -- Arguments:
  --   p_text		-> text to be logged, must be less that 50 chars per line
  --   p_debug-level	-> If set to 1,2,3 lok at debug flag, 0 always write
  --   p_token		-> if you want a token string to be attched to the line
  -- 		           for retrieveing specific lines in the log file
  --

  PROCEDURE Write_Log (
  	p_text		IN	VARCHAR2,
	p_debug_level	IN	NUMBER DEFAULT 0,
	p_token		IN	VARCHAR2 DEFAULT ''
  	);

  --
  -- This function will fetch the table which has all the lines
  -- added into the log file
  -- Arguments:
  --   p_log	-> log structure (cannot be used from forms, currently)
  --

  PROCEDURE Get_Log (
  	p_log		OUT	logCharTyp
  	);

  --
  -- This function gets the number of lines entered as log information
  --

  FUNCTION Get_Size RETURN NUMBER;

  --
  -- This procedure gets a specific line form the log file specified by
  -- the line number
  -- Arguments:
  --   p_line	-> Line number in the log file, if you know it
  --

  PROCEDURE Get_Line (
  	p_line		IN	NUMBER,
  	p_text		OUT	VARCHAR2,
  	p_status	OUT	NUMBER
  	);

  --
  -- This procedure gets a specific line form the log file specified by
  -- the token
  -- Arguments:
  --   p_token	-> Token associated with the line in the Log file
  --

  PROCEDURE Get_Line (
  	p_token		IN	VARCHAR2,
  	p_text		OUT	VARCHAR2,
  	p_status	OUT	NUMBER
  	);

  --
  -- This function will clear the logged information for the session
  --

  FUNCTION Clear_Log RETURN NUMBER;

/*
  --
  -- This function will flush the log information to a log file in the
  -- server denoted by l<request_id>.log or l<time>.log. Your DBA can
  -- assist you with the location of the log file.
  --

  FUNCTION Flush_Log (
	p_close		IN	VARCHAR2
	) RETURN NUMBER;
*/

  --
  -- This is the generic server side exception handler for shipping.
  -- It should be called in the WHEN OTHERS clause.
  -- Arguments:
  --   function_name	-> package_name.proc/func_name
  --   msg_txt		-> useful debugging text for exception
  --

  PROCEDURE Default_Handler (
	function_name	IN	VARCHAR2,
	msg_txt		IN	VARCHAR2 DEFAULT ''
	);

  --
  -- Access to internal variables for debugging purposes
  --

  FUNCTION Get_Var (
	var_name	IN	VARCHAR2
	) RETURN VARCHAR2;

  PROCEDURE Set_Var (
	var_name	IN	VARCHAR2,
	var_val		IN	VARCHAR2
	);

  -- update the subinventory_code of the table mtl_item_locations
  -- before update it, we check this combination is not used by
  -- some other subinventory.
  -- return value	: TRUE  if update successfully
  -- 			: FALSE if this locator is used for
  --				other subinventory

  FUNCTION update_locator_flex( organization_id 	IN NUMBER,
			        locator_id		IN NUMBER,
				subinventory		IN VARCHAR2)
  RETURN BOOLEAN;

  -- calling transaction manager for porcess online
  -- please change cursor style before and after calling this function
  FUNCTION sc_online( departure_id 	IN NUMBER,
		      delivery_id	IN NUMBER,
		      so_reservations	IN VARCHAR2) RETURN BOOLEAN;

END WSH_UTIL;

 

/
