--------------------------------------------------------
--  DDL for Package AMS_DMSOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMSOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdsrs.pls 115.8 2003/12/03 06:42:17 choang ship $ */
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
-- 30-Jan-2001 choang   Changed rec type to have rule_id instead of tree_node.
-- 12-Feb-2001 choang   Added p_target_value to create_source for odm.
-- 07-Jan-2002 choang   Removed security group id
-- 02-Dec-2003 choang   Stubbed out.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

END AMS_DMSource_PUB;

 

/
