--------------------------------------------------------
--  DDL for Package Body AMS_DMSOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMSOURCE_PUB" as
/* $Header: amspdsrb.pls 115.9 2003/12/03 06:42:16 choang ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMSource_PUB
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 27-Jan-2001 choang   Removed target_value from create_source used by
--                      ODM Accelerator.
-- 30-Jan-2001 choang   Changed api's published for ODM accelerator to
--                      pass rule_id to private api given a tree_node.
-- 12-Feb-2001 choang   Removed savepoint and rollback in create_source
--                      and update_score for odm, and use table handler
--                      instead of pvt api.
-- 16-Sep-2001 choang   removed rule_id - currently, pub api's not req'd
--                      but included in the build accidentally.
-- 07-Jan-2002 choang   Removed security group id
-- 02-Dec-2003 choang   Stubbed out for compile errors.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

END AMS_DMSource_PUB;

/
