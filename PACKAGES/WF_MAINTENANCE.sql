--------------------------------------------------------
--  DDL for Package WF_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MAINTENANCE" AUTHID CURRENT_USER as
 /* $Header: wfmtns.pls 120.3.12010000.5 2012/05/17 14:37:48 alsosa ship $ */

g_CommitFrequency NUMBER := 500;


-- procedure PropagateChangedName
--   Locates all occurrences of an old username and changes to
--   the new username.
--
-- IN:
--   OldName - Old Username we are changing from.
--   NewName - New Username we are changing to.
--   docommit - boolean default false.
--
procedure PropagateChangedName(
  OldName in varchar2,
  NewName in varchar2,
  docommit in BOOLEAN default FALSE);

------------------------------------------------------------------------------
/*
** ValidateUserRoles - Validates and corrects denormalized user and role
**                     information in user/role relationships.
*/
PROCEDURE ValidateUserRoles(p_BatchSize in NUMBER default null,
                            p_username in varchar2 default null,
                            p_rolename in varchar2 default null,
                            p_check_dangling in BOOLEAN default null,
                            p_check_missing_ura in BOOLEAN default null,
                            p_UpdateWho in BOOLEAN default null,
                            p_parallel_processes in number default null);

  TYPE wfcount_type IS RECORD (table_name USER_TABLES.TABLE_NAME%TYPE,
                               user_name WF_LOCAL_ROLES.NAME%TYPE,
                               rec_cnt NUMBER);
  TYPE wfcount_tab IS TABLE OF wfcount_type;
  /*
  ** GetUsernameChangeCounts
  **   This procedure is created off bug 12365810 which is used by FND
  **   team to assess the processing required to change the name of a user.
  **   It will read the WFDS and WF Runtime tables to determine these counts.
  */
  function GetUsernameChangeCounts(p_name VARCHAR2) RETURN wfcount_tab pipelined;

end WF_MAINTENANCE;

/
