--------------------------------------------------------
--  DDL for Package PV_PARTNER_PROGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_PROGRAM_PKG" AUTHID CURRENT_USER as
/* $Header: pvxtprgs.pls 115.9 2003/08/27 19:45:54 pukken ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PARTNER_PROGRAM_PKG
-- Purpose
--
-- History
--         28-FEB-2002    Ravi.Mikkilineni     Created
--          1-APR-2002    Peter.Nixon          Modified
--                   -    MEMBERSHIP columns (4) made nullable
--                   -    removed SOURCE_LANG column
--         22-APR-2002    Peter.Nixon          Modified
--                   -    restored SOURCE_LANG column
--                   -    removed PROGRAM_SHORT_NAME column
--                   -    changed PROGRAM_SETUP_TYPE column to PROGRAM_TYPE_ID
--                   -    added CUSTOM_SETUP_ID column
--                   -    added ENABLED_FLAG column
--                   -    added ATTRIBUTE_CATEGORY column
--                   -    added ATTRIBUTE1 thru ATTRIBUTE15 columns
--       26-Jun-2002 -    pukken: added user_status_id column.
--       28-Jun-2002 -    added submit_child_nodes column
--       09-Sep-2002 -    added columns  inventory_item_id ,inventory_item_org_id,
--                        bus_user_resp_id ,admin_resp_id,no_fee_flag,qsnr_ttl_all_page_dsp_flag  ,
--                        qsnr_hdr_all_page_dsp_flag ,qsnr_ftr_all_page_dsp_flag ,allow_enrl_wout_chklst_flag,
--                        qsnr_title ,qsnr_header,qsnr_footer
--      10-Sep-2002 -     removed columns membership_fees and membership_currency_names
--      06/27/2003  pukken    Code changes for 3 new columns for 11.5.10 enhancements
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


PROCEDURE Insert_Row(
           px_program_id                IN OUT NOCOPY  NUMBER
          ,p_PROGRAM_TYPE_ID                    NUMBER
          ,p_custom_setup_id                    NUMBER
          ,p_program_level_code                 VARCHAR2
          ,p_program_parent_id                  NUMBER
          ,p_program_owner_resource_id          NUMBER
          ,p_program_start_date                 DATE
          ,p_program_end_date                   DATE
	  ,p_allow_enrl_until_date              DATE
	  ,p_citem_version_id                   NUMBER
          ,p_membership_valid_period            NUMBER
          ,p_membership_period_unit             VARCHAR2
          ,p_process_rule_id                    NUMBER
          ,p_prereq_process_rule_Id             NUMBER
          ,p_program_status_code                VARCHAR2
          ,p_submit_child_nodes                 VARCHAR2
          ,p_inventory_item_id                  NUMBER
          ,p_inventory_item_org_id              NUMBER
          ,p_bus_user_resp_id                   NUMBER
          ,p_admin_resp_id                      NUMBER
          ,p_no_fee_flag                        VARCHAR2
          ,p_vad_invite_allow_flag              VARCHAR2
          ,p_global_mmbr_reqd_flag              VARCHAR2
          ,p_waive_subsidiary_fee_flag          VARCHAR2
          ,p_qsnr_ttl_all_page_dsp_flag        VARCHAR2
          ,p_qsnr_hdr_all_page_dsp_flag      VARCHAR2
          ,p_qsnr_ftr_all_page_dsp_flag      VARCHAR2
          ,p_allow_enrl_wout_chklst_flag     VARCHAR2
          ,p_user_status_id                     NUMBER
          ,p_enabled_flag                       VARCHAR2
          ,p_attribute_category                 VARCHAR2
          ,p_attribute1                         VARCHAR2
          ,p_attribute2                         VARCHAR2
          ,p_attribute3                         VARCHAR2
          ,p_attribute4                         VARCHAR2
          ,p_attribute5                         VARCHAR2
          ,p_attribute6                         VARCHAR2
          ,p_attribute7                         VARCHAR2
          ,p_attribute8                         VARCHAR2
          ,p_attribute9                         VARCHAR2
          ,p_attribute10                        VARCHAR2
          ,p_attribute11                        VARCHAR2
          ,p_attribute12                        VARCHAR2
          ,p_attribute13                        VARCHAR2
          ,p_attribute14                        VARCHAR2
          ,p_attribute15                        VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          ,p_program_name                       VARCHAR2
          ,p_program_description                VARCHAR2
          ,p_source_lang                        VARCHAR2
          ,p_qsnr_title                         VARCHAR2
          ,p_qsnr_header                        VARCHAR2
          ,p_qsnr_footer                        VARCHAR2
          );

PROCEDURE Update_Row(
           p_program_id                         NUMBER
          ,p_PROGRAM_TYPE_ID              NUMBER
          ,p_custom_setup_id                    NUMBER
          ,p_program_level_code                 VARCHAR2
          ,p_program_parent_id                  NUMBER
          ,p_program_owner_resource_id          NUMBER
          ,p_program_start_date                 DATE
          ,p_program_end_date                   DATE
	  ,p_allow_enrl_until_date              DATE
 	  ,p_citem_version_id                   NUMBER
          ,p_membership_valid_period            NUMBER
          ,p_membership_period_unit             VARCHAR2
          ,p_process_rule_id                    NUMBER
          ,p_prereq_process_rule_Id             NUMBER
          ,p_program_status_code                VARCHAR2
          ,p_submit_child_nodes                 VARCHAR2
          ,p_inventory_item_id                  NUMBER
          ,p_inventory_item_org_id              NUMBER
          ,p_bus_user_resp_id                   NUMBER
          ,p_admin_resp_id                      NUMBER
          ,p_no_fee_flag                        VARCHAR2
          ,p_vad_invite_allow_flag              VARCHAR2
          ,p_global_mmbr_reqd_flag              VARCHAR2
          ,p_waive_subsidiary_fee_flag          VARCHAR2
          ,p_qsnr_ttl_all_page_dsp_flag        VARCHAR2
          ,p_qsnr_hdr_all_page_dsp_flag      VARCHAR2
          ,p_qsnr_ftr_all_page_dsp_flag      VARCHAR2
          ,p_allow_enrl_wout_chklst_flag     VARCHAR2
          ,p_user_status_id                     NUMBER
          ,p_enabled_flag                       VARCHAR2
          ,p_attribute_category                 VARCHAR2
          ,p_attribute1                         VARCHAR2
          ,p_attribute2                         VARCHAR2
          ,p_attribute3                         VARCHAR2
          ,p_attribute4                         VARCHAR2
          ,p_attribute5                         VARCHAR2
          ,p_attribute6                         VARCHAR2
          ,p_attribute7                         VARCHAR2
          ,p_attribute8                         VARCHAR2
          ,p_attribute9                         VARCHAR2
          ,p_attribute10                        VARCHAR2
          ,p_attribute11                        VARCHAR2
          ,p_attribute12                        VARCHAR2
          ,p_attribute13                        VARCHAR2
          ,p_attribute14                        VARCHAR2
          ,p_attribute15                        VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          ,p_program_name                       VARCHAR2
          ,p_program_description                VARCHAR2
          ,p_qsnr_title                         VARCHAR2
          ,p_qsnr_header                        VARCHAR2
          ,p_qsnr_footer                        VARCHAR2
          );

PROCEDURE Delete_Row(
           p_program_id                         NUMBER
          ,p_object_version_number              NUMBER
          );

PROCEDURE Lock_Row(
           px_program_id                IN OUT NOCOPY  NUMBER
          ,p_PROGRAM_TYPE_ID              NUMBER
          ,p_custom_setup_id                    NUMBER
          ,p_program_level_code                 VARCHAR2
          ,p_program_parent_id                  NUMBER
          ,p_program_owner_resource_id          NUMBER
          ,p_program_start_date                 DATE
          ,p_program_end_date                   DATE
	  ,p_allow_enrl_until_date              DATE
	  ,p_citem_version_id                   NUMBER
          ,p_membership_valid_period            NUMBER
          ,p_membership_period_unit             VARCHAR2
          ,p_process_rule_id                    NUMBER
          ,p_prereq_process_rule_Id             NUMBER
          ,p_program_status_code                VARCHAR2
          ,p_submit_child_nodes                 VARCHAR2
          ,p_inventory_item_id                  NUMBER
          ,p_inventory_item_org_id              NUMBER
          ,p_bus_user_resp_id                   NUMBER
          ,p_admin_resp_id                      NUMBER
          ,p_no_fee_flag                        VARCHAR2
          ,p_vad_invite_allow_flag              VARCHAR2
          ,p_global_mmbr_reqd_flag              VARCHAR2
          ,p_waive_subsidiary_fee_flag          VARCHAR2
          ,p_qsnr_ttl_all_page_dsp_flag        VARCHAR2
          ,p_qsnr_hdr_all_page_dsp_flag      VARCHAR2
          ,p_qsnr_ftr_all_page_dsp_flag      VARCHAR2
          ,p_allow_enrl_wout_chklst_flag     VARCHAR2
          ,p_user_status_id                     NUMBER
          ,p_enabled_flag                       VARCHAR2
          ,p_attribute_category                 VARCHAR2
          ,p_attribute1                         VARCHAR2
          ,p_attribute2                         VARCHAR2
          ,p_attribute3                         VARCHAR2
          ,p_attribute4                         VARCHAR2
          ,p_attribute5                         VARCHAR2
          ,p_attribute6                         VARCHAR2
          ,p_attribute7                         VARCHAR2
          ,p_attribute8                         VARCHAR2
          ,p_attribute9                         VARCHAR2
          ,p_attribute10                        VARCHAR2
          ,p_attribute11                        VARCHAR2
          ,p_attribute12                        VARCHAR2
          ,p_attribute13                        VARCHAR2
          ,p_attribute14                        VARCHAR2
          ,p_attribute15                        VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,px_object_version_number     IN OUT NOCOPY  NUMBER
          );

PROCEDURE Add_Language;

PROCEDURE Translate_Row(
          px_program_id                 IN      VARCHAR2
         ,p_program_name                IN      VARCHAR2
         ,p_program_description         IN      VARCHAR2
         ,p_owner                       IN      VARCHAR2
         ,p_qsnr_title                  IN      VARCHAR2
         ,p_qsnr_header                 IN      VARCHAR2
         ,p_qsnr_footer                 IN      VARCHAR2
         );


END PV_PARTNER_PROGRAM_PKG;

 

/
