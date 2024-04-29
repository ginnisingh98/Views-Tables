--------------------------------------------------------
--  DDL for Package JTF_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: jtfgutls.pls 120.1 2005/07/02 00:44:57 appldev ship $ */

------------------------------------------------------------------------------
-- Comment
-- Package
--   JTF_Utility_PVT
-- File
--   jtfgutls.pls
-- Purpose
--   This package is a private API for some commom tasks.
-- Procedures
--   check_fk_exists
--   check_lookup_exists
--   check_uniqueness
--   debug_message
-- History
-- End of Comment

--SET VERIFY OFF
--WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

g_number         CONSTANT NUMBER := 1;  -- data type is number
g_varchar2       CONSTANT NUMBER := 2;  -- data type is varchar2

resource_locked EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);


/****************************************************************************/
-- FUNCTION
--   check_fk_exists
-- PURPOSE
--   This function checks if a foreign key is valid.
-- NOTES
--   1. It will return FND_API.g_true/g_false.
--   2. Exception encountered will be raised to the caller.
--   3. p_pk_data_type can be JTF_Global_PVT.g_number/g_varchar2.
--   4. Please don't put 'AND' at the beginning of your additional where clause.
------------------------------------------------------------------------------
FUNCTION check_fk_exists
(
  p_table_name                 IN VARCHAR2,
  p_pk_name                    IN VARCHAR2,
  p_pk_value                   IN VARCHAR2,
  p_pk_data_type               IN NUMBER := g_number,
  p_additional_where_clause    IN VARCHAR2 := NULL
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


/****************************************************************************/
-- FUNCTION
--   check_uniqueness
-- PURPOSE
--   This function is to check the uniqueness of the keys.
--   In order to make this function more flexible, you need to
--   pass in where clause of your unique keys check.
------------------------------------------------------------------------------
FUNCTION check_uniqueness
(
  p_table_name    IN VARCHAR2,
  p_where_clause  IN VARCHAR2
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


/****************************************************************************/
-- PROCEDURE
--   debug_message
-- PURPOSE
--   This procedure will check the message level and try to add a
--   debug message into the message table of FND_MSG_API package.
--   Note that this debug message won't be translated.
------------------------------------------------------------------------------
PROCEDURE debug_message
(
  p_message_text   IN  VARCHAR2,
  p_message_level  IN  NUMBER := FND_MSG_PUB.g_msg_lvl_debug_high
);

/****************************************************************************/
-- PROCEDURE
--    display_messages
-- PURPOSE
--    This procedure will display all messages in the message list
--    using DBMS_OUTPUT.put_line( ) .
------------------------------------------------------------------------------
PROCEDURE display_messages;

END JTF_Utility_PVT;

 

/
