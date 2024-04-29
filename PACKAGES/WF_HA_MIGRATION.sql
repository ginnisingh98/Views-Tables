--------------------------------------------------------
--  DDL for Package WF_HA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_HA_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: WFHAMIGS.pls 120.2 2005/10/18 12:47:45 mfisher ship $ */


--
-- Procedure
--   RESET_HA_FLAGS
--
-- Purpose
--   Resets the Migration Flags on WF_ITEMS.  Performs Commit.
--
-- Arguments: None
--
Procedure RESET_HA_FLAGS(errbuf out nocopy varchar2, retcode out nocopy number);

--
-- Procedure
--   SET_HA_FLAG
--
-- Purpose
--   Sets the Migration Flag on WF_ITEMS for a particular item.
--
-- Arguments:
--   Item_Type, Item_Key
--
Procedure SET_HA_FLAG(x_item_type in varchar2, x_item_key in varchar2);


--
-- Function
--   GET_HA_MAINT_MODE
--
-- Purpose
--   Returns the Current High Availability Maintenance Mode.
--
-- Arguments: None
--
FUNCTION GET_HA_MAINT_MODE return varchar2;


--
-- Function
--   GET_CACHED_HA_MAINT_MODE
--
-- Purpose
--   Returns the Cacched High Availability Maintenance Mode if available,
--   other wise the current one.
--
-- Arguments: None
--
FUNCTION GET_CACHED_HA_MAINT_MODE return varchar2;


--
-- Procedure
--   Export Items
--
-- Purpose
--   Shipped updated items from WF_ITEMS and associated tables to the
--   maintanence system...continues until no more txns being processed on old
--   system, and no more backlog to process.
--
-- Arguments: None
--
PROCEDURE EXPORT_ITEMS(errbuf out nocopy varchar2, retcode out nocopy number);

--
-- Procedure
--   FixSubscriptions
--
-- Purpose
--   Shipped updated items from WF_ITEMS and associated tables to the
--   maintanence system...continues until no more txns being processed on old
--   system, and no more backlog to process.
--
-- Arguments:
--	WF_Schema in varchar2 - Schema for FND.
--	Clone_DBLink in varchar2 - DBLink for cloned DB.
--
PROCEDURE FixSubscriptions(WF_Schema in varchar2 default 'APPLSYS', Clone_DBLink in varchar2);

END WF_HA_MIGRATION;

 

/
