--------------------------------------------------------
--  DDL for Package APP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APP_UTILS" AUTHID CURRENT_USER as
/* $Header: AFUTILSS.pls 115.1 99/07/16 23:32:31 porting sh $ */

--
-- Package
--   app_utils
-- Purpose
--   General utilities
-- History
--   00/00/00	K Brodersen	Created
--

  --
  -- Name
  --   set_char
  -- Purpose
  --   Sets a character in a string at position POSITION to a new character.
  --   Primarily used to set characters in a string on and off to act as a bit
  --   flag.
  -- Arguments
  --   string		String to modify
  --   position		Position in string to modify
  --   rchar		Replacement character
  -- Notes
  --   1. If STRING is null, STRING is initialized to ' '
  --   2. If POSITION > LENGTH(STRING), STRING is padded out

  procedure set_char(string in out varchar2,
                     position      number,
                     rchar         varchar2);

end app_utils;

 

/
