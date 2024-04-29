--------------------------------------------------------
--  DDL for Package ZPB_BUSAREA_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_BUSAREA_VAL" AUTHID CURRENT_USER AS
/* $Header: ZPBVBAVS.pls 120.3 2007/12/04 14:37:44 mbhat noship $ */


------------------------------------------------------------------------------------------------------
/*

LOCK_OUT_USER

This procedure updates ZPB_ACCOUNT_STATES.READ_SCOPE
                                          WRITE_SCOPE
                                          OWNERSHIP
setting these columns to 2 (locked) as needed.

Also inserts the invalid query's name and path details into the ZPB_VALIDATION_TEMP_DATA table for
later retrieval in java layer.

--  p_baId           -- Business Area Id
--  p_user_id        -- User id pulled from query
--  p_queryName      -- The Invalid Query Object Name
--  p_queryPath	     -- The Invalid Query object path
--  p_queryType      -- G_READ_RULE,G_WRITE_RULE,G_OWNER_RULE
--  p_queryErrorType -- Tells whether the query is to be fixed + marked as Invalid ("F")
--                      OR Just Refrshed ("R"). "R" only if a dimension has been removed
--                   -- in which case fixing is not going to work.
--  p_init_fix       -- Flag to confirm whether MD fixing should be done or not
                     -- We do not fix for real-time validation from UI.
*/
------------------------------------------------------------------------------------------------------
 PROCEDURE LOCK_OUT_USER(p_baId           IN NUMBER,
                         p_userid         IN FND_USER.USER_ID%type,
                         p_queryName      IN VARCHAR2,
                         p_queryPath      IN ZPB_STATUS_SQL.QUERY_PATH%type,
                         p_queryType      IN VARCHAR2,
                         p_queryErrorType IN VARCHAR2,
                         p_init_fix       IN VARCHAR2,
                         p_statusSqlId    IN ZPB_STATUS_SQL.STATUS_SQL_ID%type);


-------------------------------------------------------------------------
-- VAL_AGAINST_EPF - Validates the Business Area version against EPF, to
--                   ensure all metadata exists and is enabled in EPF
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_msg_list - Whether to initialize the message list
--
-- OUT: x_return_status - The return status
--      x_msg_count     - The message count
--      x_msg_data      - The message data
-------------------------------------------------------------------------
PROCEDURE VAL_AGAINST_EPF (p_version_id    IN      NUMBER);

-------------------------------------------------------------------------
-- VAL_DEFINITION - Validates the Business Area version against itself, to
--                   ensure there are no internal inconsistencies
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_msg_list - Whether to initialize the message list
--
-- OUT: x_return_status - The return status
--      x_msg_count     - The message count
--      x_msg_data      - The message data
-------------------------------------------------------------------------
PROCEDURE VAL_DEFINITION (p_version_id    IN      NUMBER);

-------------------------------------------------------------------------
-- VAL_AGAINST_EPB - Validates the Business Area version against EPB, to
--                   find any places where EPB will be adversely affected
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_msg_list - Whether to initialize the message list
--
-- OUT: x_return_status - The return status
--      x_msg_count     - The message count
--      x_msg_data      - The message data
-------------------------------------------------------------------------
PROCEDURE VAL_AGAINST_EPB (p_version_id    IN    NUMBER,
                           p_init_fix      IN    VARCHAR2 DEFAULT 'N');

END ZPB_BUSAREA_VAL;

/
