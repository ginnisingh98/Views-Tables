--------------------------------------------------------
--  DDL for Package Body WSH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_UTIL" AS
/* $Header: WSHUUTLB.pls 115.5 99/08/18 12:37:18 porting ship   $ */


  --
  -- Package Variables
  --
	initialized			VARCHAR2(1) := 'N';
	log_buffer			logTabTyp;
	log_char_buffer			logCharTyp;
	current_line			NUMBER := 1;
	request_id			NUMBER := -1;
	debug_flag			VARCHAR2(1) := 'N';
	debug_level			NUMBER := 0;
	flush				VARCHAR2(1) := 'N';
	source				VARCHAR2(1) := 'u';
	log_file_handle			UTL_FILE.FILE_TYPE;
	log_file_name			VARCHAR2(20);
	file_location			VARCHAR2(20) := '/home/rshivram/temp';
	last_flush_record		NUMBER := 1;

  --
  -- PACKAGE CONSTANTS
  --

	SUCCESS		CONSTANT  NUMBER := 0;
	FAILURE		CONSTANT  NUMBER := -1;
	MAX_LINES	CONSTANT  NUMBER := 1000;
	MAX_LENGTH	CONSTANT  NUMBER := 2000;

  --
  -- This function initializes the package. Should only be called if
  -- you care about the flush variable which is set to 'N' by default.
  -- Arguments:
  --   p_flush -> 'Y' or 'N' depending on whether the line is to be
  --              written to the file immediately or not.
  --

  FUNCTION Init (
	p_flush		IN	VARCHAR2 DEFAULT 'N'
  	) RETURN NUMBER IS

  BEGIN
	flush := 'N';
	initialized := 'Y';
	RETURN SUCCESS;

	EXCEPTION
	  WHEN OTHERS THEN
	    RETURN FAILURE;
  END Init;

  --
  -- This function creates a new log file and opens it for writing log
  -- information
  --

  FUNCTION Open_File RETURN NUMBER IS
  today		VARCHAR2(8);
  BEGIN
	IF wshsrc = 'u' THEN
	  SELECT to_char(SYSDATE,'DDHHMISS')
	  INTO   today
	  FROM   dual;
	  log_file_name := 'l' || today || '.req';
	ELSE
	  log_file_name := 'l' || to_char(request_id) || '.req';
	END IF;
	log_file_handle := UTL_FILE.FOPEN(file_location, log_file_name, 'w');
  END Open_File;

  --
  -- This function returns 'u' if called from form etc or 'c' for
  -- concurrent program
  --

  FUNCTION Wshsrc RETURN VARCHAR2 IS
  ret_code	NUMBER;
  BEGIN
	RETURN source;
  END Wshsrc;

  --
  -- This function writes a line of text to the log file always
  -- Arguments:
  --   p_text	-> text to be logged, must be less that 80 chars per line
  --               otherwise, is truncated
  --   p_token	-> if you want a token string to be attched to the line
  -- 		   for retrieveing specific lines in the log file
  --

  PROCEDURE Write_Line (
  	p_text		IN	VARCHAR2,
	p_token		IN	VARCHAR2
  	) IS
  ret_code 	NUMBER;
  BEGIN

	IF current_line >= MAX_LINES THEN
	  RETURN;
	END IF;
	IF p_token IS NOT NULL THEN
	   log_buffer(current_line).token := SUBSTR(p_token,1,80);
	END IF;
	log_buffer(current_line).text_line := p_text;
	current_line := current_line + 1;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Write_Line','Error in Write_Line');
  END Write_Line;

  --
  -- This function writes a line of text to the log file (less than
  -- MAX_LENGTH characters), if debug level set to p_debug_level or lower
  -- (and debug flag is 'Y').
  -- It uses Write_Line, there fore it splices the text into lines
  -- of characters at most 80 characters long.
  --
  -- If p_debug_level is 0 then always write the line.
  -- Otherwise, similar to Write_Line.
  --

  PROCEDURE Write_Log (
  	p_text		IN	VARCHAR2,
	p_debug_level	IN	NUMBER DEFAULT 0,
	p_token		IN	VARCHAR2 DEFAULT ''
  	) IS
  ret_code	   NUMBER;
  p_insert_text    VARCHAR2(80);
  p_remainder_text VARCHAR2(2000);
  i                BINARY_INTEGER;
  BEGIN
    i := 0;
    IF LENGTH(p_text) > MAX_LENGTH THEN
      p_remainder_text := SUBSTR(p_text,1,MAX_LENGTH);
    ELSE
      p_remainder_text := p_text;
    END IF;

    LOOP
      p_insert_text := SUBSTR(p_remainder_text,1,80);
      p_remainder_text := SUBSTR(p_remainder_text,81);

      IF p_debug_level = 0 THEN
	   Write_Line(p_insert_text, p_token);
      ELSIF debug_flag = 'Y' AND p_debug_level >= debug_level THEN   -- Bug 930902:  Should be >= instead of <=
	   Write_Line(p_insert_text, p_token);
      END IF;

      EXIT WHEN p_remainder_text IS NULL;
      i := i + 1;
      EXIT WHEN i = 25;
    END LOOP;

  END Write_Log;

  --
  -- This function will fetch the table which has all the lines
  -- added into the log file
  -- Arguments:
  --   p_log	-> log structure (cannot be used from forms, currently)
  --

  PROCEDURE Get_Log (
  	p_log		OUT	logCharTyp
  	) IS
  i	NUMBER;
  BEGIN
	IF log_buffer.COUNT > 0 THEN
	  FOR i IN 1..log_buffer.COUNT LOOP
	    log_char_buffer(i) := log_buffer(i).text_line;
	  END LOOP;
	END IF;
	p_log := log_char_buffer;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Get_Log','Error in Get_Log');
  END Get_Log;

  --
  -- This function gets the number of lines entered as log information
  --

  FUNCTION Get_Size RETURN NUMBER IS
  BEGIN
	RETURN log_buffer.COUNT;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Get_Size','Error in Get_Size');
	     RETURN FAILURE;
  END Get_Size;

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
  	) IS
  BEGIN
	IF (p_line > 0) AND (p_line < current_line) THEN
	   p_text := log_buffer(p_line).text_line;
	   p_status := SUCCESS;
	ELSE
	   p_text := 'WSH_UTIL: Invalid Index ' || to_char(p_line);
	   p_status := FAILURE;
	END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Get_Line','Error in Get_Line');
	     p_status := FAILURE;
  END Get_Line;

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
  	) IS
  found NUMBER := 0;
  i	NUMBER;
  BEGIN
	FOR i IN 1..log_buffer.COUNT LOOP
	  IF log_buffer(i).token = p_token THEN
	     found := 1;
	     p_text := log_buffer(i).text_line;
	     p_status := SUCCESS;
	  END IF;
	END LOOP;
	IF found = 0 THEN
	   p_text := 'WSH_UTIL: Token (' || p_token || ') not found';
	   p_status := FAILURE;
	END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Get_Line','Error in Get_Line');
	     p_status := FAILURE;
  END Get_Line;

  --
  -- This function will clear the logged information for the session
  --

  FUNCTION Clear_Log RETURN NUMBER IS
  BEGIN
	log_buffer.DELETE(1,log_buffer.COUNT);
	log_char_buffer.DELETE(1,log_char_buffer.COUNT);
	current_line := 1;
	RETURN SUCCESS;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Clear_Log','Error in Clear_Log');
	     RETURN FAILURE;
  END Clear_Log;

  --
  -- This function will flush the log information to a log file in the
  -- server denoted by l<request_id>.log or l<time>.log. Your DBA can
  -- assist you with the location of the log file.
  --

  FUNCTION Flush_Log (
	p_close		IN	VARCHAR2
	) RETURN NUMBER IS
  buffer 	VARCHAR2(80);
  ret_code	NUMBER;
  i		NUMBER;
  BEGIN
	IF flush = 'N' THEN
	   IF log_file_name IS NULL THEN
		ret_code := Open_File;
		IF ret_code = FAILURE THEN
		   RETURN FAILURE;
		END IF;
	   END IF;
	   FOR i IN current_line..log_buffer.COUNT LOOP
	     buffer := log_buffer(i).text_line;
	     UTL_FILE.PUT_LINE(log_file_handle, buffer);
	   END LOOP;
	   last_flush_record := log_buffer.COUNT - 1;
	   IF p_close = 'Y' THEN
	     UTL_FILE.FCLOSE(log_file_handle);
	   END IF;
	END IF;
	RETURN SUCCESS;

	EXCEPTION
	   WHEN OTHERS THEN
	     Default_Handler('WSH_UTIL.Flush_Log','Error in Flush_Log');
	     RETURN FAILURE;
  END Flush_Log;

  --
  -- This is the generic server side exception handler for shipping.
  -- It should be called in the WHEN OTHERS clause.
  -- Arguments:
  --   function_name	-> package_name.proc/func_name
  --   msg_txt		-> useful debugging text for exception
  --

  PROCEDURE Default_Handler(
	function_name	IN	VARCHAR2,
	msg_txt		IN	VARCHAR2 DEFAULT ''
	) IS
  theMessage 	VARCHAR2(2000);
  tempMessage	VARCHAR2(2000);
  firstBlock    VARCHAR2(2000);
  nextBlock	VARCHAR2(2000);
  i             BINARY_INTEGER;
  BEGIN
        i := 0;
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE',function_name);
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',msg_txt);
	IF Wshsrc = 'u' THEN
	   APP_EXCEPTION.Raise_Exception;
	ELSE
	   theMessage := FND_MESSAGE.Get;
	   tempMessage := theMessage;

	   LOOP
             firstBlock := SUBSTR(tempMessage,1,80);
	     nextBlock := SUBSTR(tempMessage,81);
	     log_buffer(current_line).text_line := firstBlock;
	     current_line := current_line + 1;
	     tempMessage := nextBlock;
	     EXIT WHEN tempMessage IS NULL;
             i := i + 1;
	     EXIT WHEN i = 100;
	   END LOOP;

	END IF;
  END Default_Handler;


  --
  -- Internal access to variables for debugging purposes
  --

  FUNCTION Get_Var (
	var_name	IN	VARCHAR2
	) RETURN VARCHAR2 IS
  BEGIN
	IF 	var_name = 'initialized'	THEN RETURN initialized;
	ELSIF	var_name = 'current_line'	THEN RETURN to_char(current_line);
	ELSIF	var_name = 'request_id'		THEN RETURN to_char(request_id);
	ELSIF	var_name = 'debug_flag'		THEN RETURN debug_flag;
	ELSIF	var_name = 'debug_level'	THEN RETURN to_char(debug_level);
	ELSIF	var_name = 'flush'		THEN RETURN flush;
	ELSIF	var_name = 'source'		THEN RETURN source;
	ELSE	RETURN 'BAD TOKEN';
	END IF;
  END Get_Var;

  PROCEDURE Set_Var (
	var_name	IN	VARCHAR2,
	var_val		IN	VARCHAR2
	) IS
  BEGIN
	IF 	var_name = 'initialized'	THEN initialized := var_val;
	ELSIF	var_name = 'current_line'	THEN current_line := to_number(var_val);
	ELSIF	var_name = 'request_id'		THEN request_id := to_number(var_val);
	ELSIF	var_name = 'debug_flag'		THEN debug_flag := var_val;
	ELSIF	var_name = 'debug_level'	THEN debug_level := to_number(var_val);
	ELSIF	var_name = 'flush'		THEN flush := var_val;
	ELSIF	var_name = 'source'		THEN source := var_val;
	END IF;
  END Set_Var;


  FUNCTION update_locator_flex( organization_id 	IN NUMBER,
			        locator_id		IN NUMBER,
				subinventory		IN VARCHAR2)
  RETURN BOOLEAN IS
    CURSOR c1 ( x_org_id NUMBER, x_loc_id NUMBER, x_subinv VARCHAR2) IS
    SELECT 'Exist'
    FROM mtl_item_locations
    WHERE organization_id = x_org_id
    AND   inventory_location_id = x_loc_id
    AND   subinventory_code IS NOT NULL
    AND   subinventory_code <> x_subinv;
    temp  	VARCHAR2(10);
    x_org_id 	NUMBER;
    x_loc_id 	NUMBER;
  BEGIN

    OPEN c1( organization_id, locator_id, subinventory);
    FETCH c1 INTO temp;

    IF ( c1%FOUND) THEN
      IF (c1%ISOPEN) THEN
        CLOSE c1;
      END IF;

      RETURN FALSE;
    END IF;

    IF (c1%ISOPEN) THEN
      CLOSE c1;
    END IF;

    x_org_id := organization_id;
    x_loc_id := locator_id;

    UPDATE mtl_item_locations a
    SET a.subinventory_code = subinventory
    WHERE a.organization_id = x_org_id
    AND   a.inventory_location_id = x_loc_id;

    RETURN TRUE;

  EXCEPTION
    WHEN others THEN
      Default_Handler('WSH_UTIL.update_locator_flex',SQLERRM);
  END update_locator_flex;

  FUNCTION sc_online( departure_id 	IN NUMBER,
		      delivery_id	IN NUMBER,
		    so_reservations	IN VARCHAR2) RETURN BOOLEAN IS
    x_status       VARCHAR2(30);
    x_return_msg   VARCHAR2(128);
    x_return_val   NUMBER;
    x_check_failure VARCHAR2(50);
    x_dummy	   VARCHAR2(50);
BEGIN
-- Call the TM to run Update Shipping Program

     IF   (delivery_id IS NULL and departure_id IS NULL)
        OR
          (delivery_id = 0 AND departure_id = 0 ) THEN
         FND_MESSAGE.Set_Name('OE','WSH_UTL_INVALID_PARA');
         return FALSE;
     END IF;

      x_return_val:= FND_TRANSACTION.Synchronous(1000,
				  x_status,
				  x_return_msg,
				  'OE',
				  'OEBSCO',
				  TO_CHAR(delivery_id),
				  TO_CHAR(departure_id),
				  so_reservations,
				  FND_PROFILE.VALUE('USER_ID'),
				  FND_PROFILE.VALUE('LOGIN_ID'),
				  TO_CHAR(0),
				  NULL);

      IF (x_return_val = 2) THEN
         FND_MESSAGE.Set_Name('OE','SHP_ONLINE_NO_MANAGER');
         return FALSE;
      ELSIF (x_return_val <> 0) THEN
         FND_MESSAGE.Set_Name('OE','SHP_AOL_ONLINE_FAILED');
	 FND_MESSAGE.Set_Token('PROGRAM','Update Shipping Information');
         return FALSE;
      ELSE
	 IF (x_return_msg = 'FAILURE') THEN
		x_return_val := FND_TRANSACTION.get_values(x_check_failure,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy,
							   x_dummy);
		IF (x_check_failure = 'SUCCESS') THEN
	    	   FND_MESSAGE.Set_Name('OE','WSH_INVENTORY_INTERFACE_FAILED');
		   RETURN FALSE;
		ELSE
	           FND_MESSAGE.Set_Name('OE','WSH_UPDATE_SHIPPING_FAILED');
                   RETURN FALSE;
		END IF;
	ELSE
	-- Transaction manager went through and successfully closed the pick slip
	   RETURN TRUE;
	END IF;
      END IF;
  EXCEPTION

  WHEN OTHERS THEN
        FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
        FND_MESSAGE.Set_Token('PACKAGE','WSH_UTIL.sc_online');
        FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT','Unexpected exception');
        RETURN FALSE;

END sc_online;

  BEGIN

  IF initialized = 'N' THEN
	request_id := to_number(FND_PROFILE.VALUE('CONC_REQUEST_ID'));
	IF request_id IS NULL THEN
	   source := 'u';
	   request_id := -1;
	ELSE
	   source := 'c';
	END IF;
	debug_flag := FND_PROFILE.VALUE('SO_DEBUG');
	IF debug_flag = 'Y' THEN
	   debug_level := to_number(FND_PROFILE.VALUE('OE_DEBUG_LEVEL'));
	END IF;
	initialized := 'Y';
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_UTIL');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT','Failure initializing package');
	APP_EXCEPTION.Raise_Exception;

END WSH_UTIL;

/
