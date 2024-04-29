--------------------------------------------------------
--  DDL for Package Body OE_STRING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_STRING_UTIL" as
/* $Header: oexustrb.pls 115.1 99/07/16 08:30:23 porting shi $ */
PROCEDURE Get_Substring (String IN OUT VARCHAR2,
			   Sub_string IN OUT VARCHAR2,
			   Delim VARCHAR2) IS
  Pos1 	NUMBER;
  Temp_sub_string VARCHAR2(200) := NULL;
  BEGIN
    Pos1 := INSTR(String,Delim,1);
    IF Pos1 > 0 THEN
      Temp_sub_string := SUBSTR(String,1,Pos1 - 1);
      String := SUBSTR(String,Pos1 + 1);
    END IF;
    Sub_string := Temp_sub_string;
  END;
FUNCTION Parse_String (String VARCHAR2, Delim VARCHAR2, Delim_cnt NUMBER) RETURN
 VARCHAR2 IS

Return_string VARCHAR2(2000) := NULL;
Pos1 NUMBER;
Pos2 NUMBER;
String_len NUMBER;
BEGIN
  IF Delim_cnt =1 THEN
    Pos1 := 1;
  ELSE
    IF Delim_cnt > 1 THEN
      Pos1 := INSTR(String,Delim,1,Delim_cnt-1);
      IF Pos1 > 0 THEN
        Pos1 := Pos1 + 1;
      ELSE
        Return(Return_string);
      END IF;
    ELSE /* string count is null or zero */
      Return(Return_string);
    END IF;
  END IF;
  Pos2 := INSTR(String,Delim,1,Delim_cnt);
  IF Pos2 > 1 THEN
    NULL;
  ELSE
    Pos2 := LENGTH(String)+1;
  END IF;
  String_len := Pos2 - Pos1;
  Return_string := SUBSTR(String,Pos1,string_len);
  Return(Return_string);
END;
END OE_STRING_UTIL;

/
