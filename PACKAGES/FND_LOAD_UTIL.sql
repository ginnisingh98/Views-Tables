--------------------------------------------------------
--  DDL for Package FND_LOAD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOAD_UTIL" AUTHID CURRENT_USER as
/* $Header: AFLDUTLS.pls 120.2.12010000.1 2008/07/25 14:15:57 appldev ship $ */

-- NULL_VALUE CONSTANT VARCHAR2(6) := '*NULL*';
--
-- OWNER_NAME
--   Return owner tag to be used in FNDLOAD data file
-- IN
--   p_id - user_id of last_updated_by column
-- RETURNS
--   OWNER attribute value for FNDLOAD data file
--
function OWNER_NAME(
  p_id in number)
return varchar2;

--
-- OWNER_ID
--   Return the user_id of the OWNER attribute
-- IN
--   p_name - OWNER attribute value from FNDLOAD data file
-- RETURNS
--   user_id of owner to use in who columns
--
function OWNER_ID(
  p_name in varchar2)
return number;

--
-- UPLOAD_TEST
--   Test whether or not to over-write database row when uploading
--   data from FNDLOAD data file, based on owner attributes of both
--   database row and row in file being uploaded.
-- IN
--   p_file_id - FND_LOAD_UTIL.OWNER_ID(<OWNER attribute from data file>)
--   p_file_lud - LAST_UPDATE_DATE attribute from data file
--   p_db_id - LAST_UPDATED_BY of db row
--   p_db_lud - LAST_UPDATE_DATE of db row
--   p_custom_mode - CUSTOM_MODE FNDLOAD parameter value
-- RETURNS
--   TRUE if safe to over-write.
--
function UPLOAD_TEST(
  p_file_id     in number,
  p_file_lud    in date,
  p_db_id       in number,
  p_db_lud      in date,
  p_custom_mode in varchar2)
return boolean;

-- Bug 2438503 - Routine to return NULL value.
function NULL_VALUE return varchar2;
PRAGMA restrict_references(NULL_VALUE, WNDS, RNDS, WNPS, RNPS);

NLS_MODE BOOLEAN :=FALSE;

procedure SET_NLS_MODE;
end FND_LOAD_UTIL;

/
