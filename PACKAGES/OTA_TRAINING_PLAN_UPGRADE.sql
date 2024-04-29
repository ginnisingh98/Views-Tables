--------------------------------------------------------
--  DDL for Package OTA_TRAINING_PLAN_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRAINING_PLAN_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: ottplpupg.pkh 120.0 2005/05/29 07:59:23 appldev noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< populate_path_source_code >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE populate_path_source_code ;

-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_tp_to_lp >----------------------------|
-- ----------------------------------------------------------------------------
procedure upg_tp_for_lrnr_and_mgr_to_lp(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1);
-- ----------------------------------------------------------------------------
-- |---------------------< upg_tp_to_lp_for_talent_mgmt >---------------------|
-- ----------------------------------------------------------------------------
procedure upg_tp_to_lp_for_talent_mgmt(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
 p_update_id in number  default 1);
-- ----------------------------------------------------------------------------
-- |------------------------< remove_date_restrict >--------------------------|
-- ----------------------------------------------------------------------------
procedure remove_date_rest(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number  default 1);
-- ----------------------------------------------------------------------------
-- |------------------------< upg_cat_lp_to_section >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upg_cat_lp_to_section (
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number  default 1);
-- ----------------------------------------------------------------------------
-- |------------------------< upg_enrol_to_cat_lp >---------------------------|
-- ----------------------------------------------------------------------------
Procedure upg_enrol_to_cat_lp(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number  default 1);
End OTA_TRAINING_PLAN_UPGRADE ;



 

/
