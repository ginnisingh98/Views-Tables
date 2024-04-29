--------------------------------------------------------
--  DDL for Package Body APP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APP_UTILS" as
/* $Header: AFUTILSB.pls 115.1 99/07/16 23:32:27 porting sh $ */


  --
  -- PUBLIC FUNCTIONS
  --

  -- SET_CHAR: STRING[POSITION] := RCHAR;
  procedure set_char(string in out varchar2,
                     position      number,
                     rchar         varchar2) is
  begin

    -- Check for valid arguments
    if ((position is null) or (position < 1)) then
      app_exception.invalid_argument('app_exceptions.set_char',
                                      'position', to_char(position));
    elsif (rchar is null) then
      app_exception.invalid_argument('app_exceptions.set_char', 'rchar', null);
    end if;

    -- Init string if necessary
    if (string is null) then
      string := ' ';
    end if;

    -- Pad string if necessary
    if (position > length(string)) then
      string := string||rpad(' ',position-length(string),' ');
    end if;

    -- Set char
    -- Handles the boundary cases automatically:
    -- If position=1,      then position-1=0      and substr=null
    -- If position=length, then position+1>length and substr=null
    string := substr(string, 1, position-1) || rchar ||
              substr(string, position+1);
  end set_char;

  -- Behavior of substr:
  --
  -- start	length		substr('karen', start, length)
  -- -----	------		------------------------------
  -- 0 or 1	null		karen
  -- 0 or 1	>= 6		karen
  -- 0 or 1	<= 0		null
  -- >= 6	null		null
  -- -1...-5	null		n...k
  -- -6		null		null

end app_utils;

/
