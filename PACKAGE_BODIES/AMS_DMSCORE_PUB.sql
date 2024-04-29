--------------------------------------------------------
--  DDL for Package Body AMS_DMSCORE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMSCORE_PUB" as
/* $Header: amspdmsb.pls 115.11 2003/12/03 03:33:24 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMScore_PUB
-- Purpose
--
-- History
-- 12-Feb-2001 choang   Removed rollback and savepoints in create_score
--                      for ODM Accelerator, and changed to call table
--                      handler instead of private api.
-- 12-Feb-2001 choang   Added new columns.
-- 19-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 27-Feb-2001 choang   1) Added custom_setup_id, country_id. 2) Added
--                      call to validation in odm create_score. 3) Replaced
--                      call to private create api in odm create_score with
--                      table handler.
-- 01-May-2001 choang   Added wf_itemkey to create_score.
-- 16-Sep-2001 choang   Added custom_setup_id in pvt call to create api.
-- 02-Dec-2003 choang   Originally created for Darwin and ODM Accelerator
--                      integration, but no longer used; stubbed out.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

END AMS_DMScore_PUB;

/
