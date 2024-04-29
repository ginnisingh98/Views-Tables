--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PROGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PROGRAM_PKG" as
/* $Header: pvxtprgb.pls 120.0 2005/05/27 16:12:37 appldev noship $ */
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
--         15-APR-2002    Peter.Nixon          Modified
--         19-APR-2002    Peter.Nixon          Modified
--                   -    restored SOURCE_LANG column
--                   -    removed PROGRAM_SHORT_NAME column
--                   -    changed PROGRAM_SETUP_TYPE column to PROGRAM_TYPE_ID
--                   -    added CUSTOM_SETUP_ID column
--                   -    added ENABLED_FLAG column
--                   -    added ATTRIBUTE_CATEGORY column
--                   -    added ATTRIBUTE1 thru ATTRIBUTE15 columns
--       26-Jun-2002 -    added user_status_id column.
--       28-Jun-2002 -    added submit_child_nodes column
--       09-Sep-2002 -    added columns  inventory_item_id ,inventory_item_org_id,
--                        bus_user_resp_id ,admin_resp_id,no_fee_flag,qsnr_ttl_all_page_dsp_flag  ,
--                        qsnr_hdr_all_page_dsp_flag ,qsnr_ftr_all_page_dsp_flag ,allow_enrl_wout_chklst_flag.
--                        qsnr_title ,qsnr_header,qsnr_footer
--   06/27/2003  pukken    Code changes for 3 new columns for 11.5.10 enhancements
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'PV_PARTNER_PROGRAM_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtprgb.pls';


--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
           px_program_id               IN OUT NOCOPY   NUMBER
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
          ,p_object_version_number              NUMBER
          ,p_program_name                       VARCHAR2
          ,p_program_description                VARCHAR2
          ,p_source_lang                        VARCHAR2
          ,p_qsnr_title                         VARCHAR2
          ,p_qsnr_header                        VARCHAR2
          ,p_qsnr_footer                        VARCHAR2
          )

 IS

BEGIN

   INSERT INTO PV_PARTNER_PROGRAM_B(
            program_id
           ,PROGRAM_TYPE_ID
           ,custom_setup_id
           ,program_level_code
           ,program_parent_id
           ,program_owner_resource_id
           ,program_start_date
           ,program_end_date
       	   ,allow_enrl_until_date
    	   ,citem_version_id
           ,membership_valid_period
           ,membership_period_unit
           ,process_rule_id
           ,prereq_process_rule_Id
           ,program_status_code
           ,submit_child_nodes
           ,inventory_item_id
           ,inventory_item_org_id
           ,bus_user_resp_id
           ,admin_resp_id
           ,no_fee_flag
           ,vad_invite_allow_flag
           ,global_mmbr_reqd_flag
           ,waive_subsidiary_fee_flag
           ,qsnr_ttl_all_page_dsp_flag
           ,qsnr_hdr_all_page_dsp_flag
           ,qsnr_ftr_all_page_dsp_flag
           ,allow_enrl_wout_chklst_flag
           ,user_status_id
           ,enabled_flag
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,object_version_number
         ) VALUES (
            DECODE( px_program_id, NULL, px_program_id, FND_API.g_miss_num, NULL, px_program_id)
           ,DECODE( p_PROGRAM_TYPE_ID, NULL, p_PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, p_PROGRAM_TYPE_ID)
           ,DECODE( p_custom_setup_id, NULL,p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id)
           ,DECODE( p_program_level_code, NULL, p_program_level_code, FND_API.g_miss_char, NULL, p_program_level_code)
           ,DECODE( p_program_parent_id, NULL, p_program_parent_id,FND_API.g_miss_num, NULL, p_program_parent_id)
           ,DECODE( p_program_owner_resource_id, NULL, p_program_owner_resource_id,FND_API.g_miss_num, NULL, p_program_owner_resource_id)
           ,DECODE( p_program_start_date, NULL, p_program_start_date, FND_API.g_miss_date, NULL, p_program_start_date)
           ,DECODE( p_program_end_date,  NULL, p_program_end_date,FND_API.g_miss_date, NULL, p_program_end_date)
           ,DECODE( p_allow_enrl_until_date,  NULL, p_allow_enrl_until_date,FND_API.g_miss_date, NULL, p_allow_enrl_until_date)
	   ,DECODE( p_citem_version_id , NULL, p_citem_version_id , FND_API.g_miss_num, NULL, p_citem_version_id)
       	   ,DECODE( p_membership_valid_period, NULL, p_membership_valid_period, FND_API.g_miss_num, NULL, p_membership_valid_period)
           ,DECODE( p_membership_period_unit, NULL, p_membership_period_unit,FND_API.g_miss_char, NULL, p_membership_period_unit)
           ,DECODE( p_process_rule_id, NULL, p_process_rule_id, FND_API.g_miss_num, NULL, p_process_rule_id)
           ,DECODE( p_prereq_process_rule_Id, NULL, p_prereq_process_rule_Id, FND_API.g_miss_num, NULL, p_prereq_process_rule_Id)
           ,DECODE( p_program_status_code, NULL, p_program_status_code,FND_API.g_miss_char, NULL, p_program_status_code)
           ,DECODE( p_submit_child_nodes, NULL, p_submit_child_nodes,FND_API.g_miss_char, NULL, p_submit_child_nodes)
           ,DECODE( p_inventory_item_id, NULL, p_inventory_item_id,FND_API.g_miss_num, NULL, p_inventory_item_id)
           ,DECODE( p_inventory_item_org_id, NULL, p_inventory_item_org_id,FND_API.g_miss_num, NULL, p_inventory_item_org_id)
           ,DECODE( p_bus_user_resp_id, NULL, p_bus_user_resp_id,FND_API.g_miss_num, NULL, p_bus_user_resp_id)
           ,DECODE( p_admin_resp_id, NULL, p_admin_resp_id,FND_API.g_miss_num, NULL, p_admin_resp_id)
           ,DECODE( p_no_fee_flag, NULL, p_no_fee_flag,FND_API.g_miss_char, NULL, p_no_fee_flag)
           ,DECODE( p_vad_invite_allow_flag, NULL, p_vad_invite_allow_flag,FND_API.g_miss_char, NULL, p_vad_invite_allow_flag)
           ,DECODE( p_global_mmbr_reqd_flag, NULL, p_global_mmbr_reqd_flag,FND_API.g_miss_char, NULL, p_global_mmbr_reqd_flag)
           ,DECODE( p_waive_subsidiary_fee_flag, NULL, p_waive_subsidiary_fee_flag,FND_API.g_miss_char, NULL, p_waive_subsidiary_fee_flag)
           ,DECODE( p_qsnr_ttl_all_page_dsp_flag , NULL, p_qsnr_ttl_all_page_dsp_flag ,FND_API.g_miss_char, NULL, p_qsnr_ttl_all_page_dsp_flag )
           ,DECODE( p_qsnr_hdr_all_page_dsp_flag , NULL, p_qsnr_hdr_all_page_dsp_flag ,FND_API.g_miss_char, NULL, p_qsnr_hdr_all_page_dsp_flag )
           ,DECODE( p_qsnr_ftr_all_page_dsp_flag, NULL, p_qsnr_ftr_all_page_dsp_flag,FND_API.g_miss_char, NULL, p_qsnr_ftr_all_page_dsp_flag)
           ,DECODE( p_allow_enrl_wout_chklst_flag, NULL, p_allow_enrl_wout_chklst_flag,FND_API.g_miss_char, NULL, p_allow_enrl_wout_chklst_flag)
           ,DECODE( p_user_status_id, NULL, p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id)
           ,DECODE( p_enabled_flag, NULL, p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)
           ,DECODE( p_attribute_category, NULL, p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category)
           ,DECODE( p_attribute1, NULL, p_attribute1, FND_API.g_miss_char, NULL, p_attribute1)
           ,DECODE( p_attribute2, NULL, p_attribute2, FND_API.g_miss_char, NULL, p_attribute2)
           ,DECODE( p_attribute3, NULL, p_attribute3,  FND_API.g_miss_char, NULL, p_attribute3)
           ,DECODE( p_attribute4, NULL, p_attribute4 , FND_API.g_miss_char, NULL, p_attribute4)
           ,DECODE( p_attribute5, NULL, p_attribute5, FND_API.g_miss_char, NULL, p_attribute5)
           ,DECODE( p_attribute6, NULL, p_attribute6, FND_API.g_miss_char, NULL, p_attribute6)
           ,DECODE( p_attribute7, NULL, p_attribute7, FND_API.g_miss_char, NULL, p_attribute7)
           ,DECODE( p_attribute8, NULL, p_attribute8, FND_API.g_miss_char, NULL, p_attribute8)
           ,DECODE( p_attribute9, NULL, p_attribute9, FND_API.g_miss_char, NULL, p_attribute9)
           ,DECODE( p_attribute10, NULL, p_attribute10, FND_API.g_miss_char, NULL, p_attribute10)
           ,DECODE( p_attribute11, NULL, p_attribute11, FND_API.g_miss_char, NULL, p_attribute11)
           ,DECODE( p_attribute12, NULL, p_attribute12, FND_API.g_miss_char, NULL, p_attribute12)
           ,DECODE( p_attribute13, NULL, p_attribute13, FND_API.g_miss_char, NULL, p_attribute13)
           ,DECODE( p_attribute14, NULL, p_attribute14, FND_API.g_miss_char, NULL, p_attribute14)
           ,DECODE( p_attribute15, NULL, p_attribute15, FND_API.g_miss_char, NULL, p_attribute15)
           ,DECODE( p_last_update_date, NULL, p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
           ,DECODE( p_last_updated_by, NULL, p_last_updated_by,  FND_API.g_miss_num, NULL, p_last_updated_by)
           ,DECODE( p_creation_date, NULL, p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
           ,DECODE( p_created_by, NULL, p_created_by, FND_API.g_miss_num, NULL, p_created_by)
           ,DECODE( p_last_update_login, NULL, p_last_update_login,  FND_API.g_miss_num, NULL, p_last_update_login)
           ,DECODE( p_object_version_number,NULL, p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)
           );

   INSERT INTO PV_PARTNER_PROGRAM_TL(
            program_id
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,language
           ,source_lang
           ,program_name
           ,program_description
           ,qsnr_title
           ,qsnr_header
           ,qsnr_footer

           )
   SELECT
           DECODE( px_program_id, NULL, px_program_id, FND_API.g_miss_num, NULL, px_program_id)
           --DECODE( px_program_id, FND_API.g_miss_num, NULL, px_program_id)
	   ,SYSDATE
      	   ,FND_GLOBAL.user_id
      	   ,SYSDATE
      	   ,FND_GLOBAL.user_id
           ,FND_GLOBAL.conc_login_id
           ,l.language_code
           ,USERENV('LANG')
           ,DECODE( p_program_name, NULL, p_program_name, FND_API.g_miss_char, NULL, p_program_name)
           ,DECODE( p_program_description,NULL, p_program_description, FND_API.g_miss_char, NULL, p_program_description)
           ,DECODE( p_qsnr_title, NULL, p_qsnr_title, FND_API.g_miss_char, NULL, p_qsnr_title)
           ,DECODE( p_qsnr_header,NULL, p_qsnr_header, FND_API.g_miss_char, NULL,p_qsnr_header)
           ,DECODE( p_qsnr_footer, NULL, p_qsnr_footer, FND_API.g_miss_char, NULL,p_qsnr_footer)
   FROM FND_LANGUAGES l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM PV_PARTNER_PROGRAM_TL t
         --WHERE t.program_id = DECODE( px_program_id, FND_API.g_miss_num, NULL, px_program_id)
         WHERE t.program_id = DECODE( px_program_id, NULL, px_program_id, FND_API.g_miss_num, NULL, px_program_id)
         AND t.language = l.language_code );

END Insert_Row;



--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
           p_program_id                         NUMBER
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
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          ,p_program_name                       VARCHAR2
          ,p_program_description                VARCHAR2
          ,p_qsnr_title                         VARCHAR2
          ,p_qsnr_header                        VARCHAR2
          ,p_qsnr_footer                        VARCHAR2
          )

 IS

 BEGIN

   IF (PV_DEBUG_HIGH_ON) THEN



   PVX_Utility_PVT.debug_message('Within PV_PARTNER_PROGRAM_PKG.UPDATE_ROW API: ');

   END IF;
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_Utility_PVT.debug_message('Within PV_PARTNER_PROGRAM_PKG.UPDATE_ROW API : object_version_number ' ||p_object_version_number );
   END IF;


   UPDATE PV_PARTNER_PROGRAM_B
   SET

               program_id                = DECODE( p_program_id, NULL ,program_id, FND_API.g_miss_num,  NULL , p_program_id)
              ,PROGRAM_TYPE_ID           = DECODE( p_PROGRAM_TYPE_ID, NULL ,PROGRAM_TYPE_ID,FND_API.g_miss_num,  NULL , p_PROGRAM_TYPE_ID)
              ,custom_setup_id           = DECODE( p_custom_setup_id, NULL ,custom_setup_id, FND_API.g_miss_num, NULL ,  p_custom_setup_id)
              ,program_level_code        = DECODE( p_program_level_code, NULL , program_level_code, FND_API.g_miss_char,  NULL , p_program_level_code)
              ,program_parent_id         = DECODE( p_program_parent_id, NULL , program_parent_id, FND_API.g_miss_num, NULL , p_program_parent_id)
              ,program_owner_resource_id = DECODE( p_program_owner_resource_id, NULL , program_owner_resource_id, FND_API.g_miss_num,  NULL ,p_program_owner_resource_id)
              ,program_start_date        = DECODE( p_program_start_date, NULL , program_start_date, FND_API.g_miss_date, NULL , p_program_start_date)
              ,program_end_date          = DECODE( p_program_end_date, NULL , program_end_date,  FND_API.g_miss_date, NULL ,p_program_end_date)
              ,allow_enrl_until_date     = DECODE( p_allow_enrl_until_date, NULL , allow_enrl_until_date,  FND_API.g_miss_date, NULL ,p_allow_enrl_until_date)
	      ,citem_version_id          = DECODE( p_citem_version_id,  NULL ,citem_version_id, FND_API.g_miss_num,  NULL , p_citem_version_id)
	      ,membership_valid_period   = DECODE( p_membership_valid_period,  NULL ,membership_valid_period, FND_API.g_miss_num,  NULL , p_membership_valid_period)
              ,membership_period_unit    = DECODE( p_membership_period_unit, NULL , membership_period_unit, FND_API.g_miss_char, NULL , p_membership_period_unit)
              ,process_rule_id           = DECODE( p_process_rule_id,  NULL ,process_rule_id, FND_API.g_miss_num, NULL ,  p_process_rule_id)
              ,prereq_process_rule_Id    = DECODE( p_prereq_process_rule_Id,  NULL ,prereq_process_rule_Id, FND_API.g_miss_num, NULL ,  p_prereq_process_rule_Id)
              ,program_status_code       = DECODE( p_program_status_code,  NULL ,program_status_code,FND_API.g_miss_char,  NULL , p_program_status_code)
              ,submit_child_nodes        = DECODE( p_submit_child_nodes,  NULL ,submit_child_nodes,FND_API.g_miss_char,  NULL , p_submit_child_nodes)
              ,inventory_item_id         = DECODE( p_inventory_item_id, NULL , inventory_item_id, FND_API.g_miss_num, NULL , p_inventory_item_id)
              ,inventory_item_org_id     = DECODE( p_inventory_item_org_id, NULL , inventory_item_org_id, FND_API.g_miss_num, NULL , p_inventory_item_org_id)
              ,bus_user_resp_id          = DECODE( p_bus_user_resp_id, NULL , bus_user_resp_id, FND_API.g_miss_num, NULL , p_bus_user_resp_id)
              ,admin_resp_id             = DECODE( p_admin_resp_id, NULL , admin_resp_id, FND_API.g_miss_num, NULL , p_admin_resp_id)
              ,no_fee_flag               = DECODE( p_no_fee_flag,  NULL ,no_fee_flag,FND_API.g_miss_char, NULL ,  p_no_fee_flag)
              ,vad_invite_allow_flag     = DECODE( p_vad_invite_allow_flag,  NULL ,vad_invite_allow_flag,FND_API.g_miss_char, NULL ,  p_vad_invite_allow_flag)
              ,global_mmbr_reqd_flag     = DECODE( p_global_mmbr_reqd_flag,  NULL ,global_mmbr_reqd_flag,FND_API.g_miss_char, NULL ,  p_global_mmbr_reqd_flag)
              ,waive_subsidiary_fee_flag = DECODE( p_waive_subsidiary_fee_flag,  NULL ,waive_subsidiary_fee_flag,FND_API.g_miss_char, NULL ,  p_waive_subsidiary_fee_flag)
              ,qsnr_ttl_all_page_dsp_flag = DECODE( p_qsnr_ttl_all_page_dsp_flag ,  NULL ,qsnr_ttl_all_page_dsp_flag ,FND_API.g_miss_char, NULL ,  p_qsnr_ttl_all_page_dsp_flag )
              ,qsnr_hdr_all_page_dsp_flag = DECODE( p_qsnr_hdr_all_page_dsp_flag,  NULL ,qsnr_hdr_all_page_dsp_flag,FND_API.g_miss_char, NULL ,  p_qsnr_hdr_all_page_dsp_flag)
              ,qsnr_ftr_all_page_dsp_flag = DECODE( p_qsnr_ftr_all_page_dsp_flag ,  NULL ,qsnr_ftr_all_page_dsp_flag ,FND_API.g_miss_char, NULL ,  p_qsnr_ftr_all_page_dsp_flag )
              ,allow_enrl_wout_chklst_flag= DECODE( p_allow_enrl_wout_chklst_flag,  NULL ,allow_enrl_wout_chklst_flag,FND_API.g_miss_char, NULL ,  p_allow_enrl_wout_chklst_flag)
              ,user_status_id            = DECODE( p_user_status_id,  NULL ,user_status_id, FND_API.g_miss_num, NULL , p_user_status_id)
              ,enabled_flag              = DECODE( p_enabled_flag,  NULL ,enabled_flag,FND_API.g_miss_char, NULL ,  p_enabled_flag)
              ,attribute_category        = DECODE( p_attribute_category, attribute_category, FND_API.g_miss_char, NULL , p_attribute_category)
              ,attribute1                = DECODE( p_attribute1,  NULL , attribute1,FND_API.g_miss_char, NULL , p_attribute1)
              ,attribute2                = DECODE( p_attribute2,  NULL ,attribute2, FND_API.g_miss_char, NULL ,  p_attribute2)
              ,attribute3                = DECODE( p_attribute3, NULL , attribute3, FND_API.g_miss_char, NULL ,  p_attribute3)
              ,attribute4                = DECODE( p_attribute4,  NULL ,attribute4, FND_API.g_miss_char, NULL ,  p_attribute4)
              ,attribute5                = DECODE( p_attribute5,  NULL , attribute5,  FND_API.g_miss_char, NULL ,p_attribute5)
              ,attribute6                = DECODE( p_attribute6,  NULL ,attribute6, FND_API.g_miss_char, NULL ,p_attribute6)
              ,attribute7                = DECODE( p_attribute7,  NULL ,attribute7, FND_API.g_miss_char, NULL ,  p_attribute7)
              ,attribute8                = DECODE( p_attribute8,  NULL ,attribute8, FND_API.g_miss_char, NULL ,  p_attribute8)
              ,attribute9                = DECODE( p_attribute9,  NULL ,attribute9, FND_API.g_miss_char, NULL , p_attribute9)
              ,attribute10               = DECODE( p_attribute10,  NULL ,attribute10, FND_API.g_miss_char, NULL , p_attribute10)
              ,attribute11               = DECODE( p_attribute11,  NULL ,attribute11,FND_API.g_miss_char, NULL , p_attribute11)
              ,attribute12               = DECODE( p_attribute12,  NULL ,attribute12, FND_API.g_miss_char, NULL ,  p_attribute12)
              ,attribute13               = DECODE( p_attribute13, NULL ,attribute13,  FND_API.g_miss_char, NULL ,  p_attribute13)
              ,attribute14               = DECODE( p_attribute14,  NULL ,attribute14, FND_API.g_miss_char, NULL , p_attribute14)
              ,attribute15               = DECODE( p_attribute15, NULL , attribute15, FND_API.g_miss_char, NULL , p_attribute15)
              ,last_update_date          = DECODE( p_last_update_date, NULL ,  last_update_date, FND_API.g_miss_date, NULL , p_last_update_date)
              ,last_updated_by           = DECODE( p_last_updated_by,  NULL ,last_updated_by, FND_API.g_miss_num, NULL ,  p_last_updated_by)
              ,last_update_login         = DECODE( p_last_update_login, NULL , last_update_login, FND_API.g_miss_num,  NULL , p_last_update_login)
              ,object_version_number     = DECODE( p_object_version_number, NULL ,object_version_number, FND_API.g_miss_num,  NULL , p_object_version_number+1)


   WHERE PROGRAM_ID = p_program_id
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
   END IF;

   Update PV_PARTNER_PROGRAM_TL
   SET
               last_update_date    = SYSDATE
              ,last_updated_by     = FND_GLOBAL.user_id
              ,last_update_login   = FND_GLOBAL.conc_login_id
              ,source_lang         = USERENV('LANG')
              ,program_name        = DECODE( p_program_name, NULL, program_name, FND_API.g_miss_char, NULL, p_program_name)
              ,program_description = DECODE( p_program_description, NULL, program_description, FND_API.g_miss_char, NULL, p_program_description)
              ,qsnr_title         = DECODE( p_qsnr_title, NULL, qsnr_title , FND_API.g_miss_char, NULL, p_qsnr_title )
              ,qsnr_header        = DECODE( p_qsnr_header, NULL, qsnr_header, FND_API.g_miss_char, NULL, p_qsnr_header)
              ,qsnr_footer        = DECODE( p_qsnr_footer, NULL,qsnr_footer, FND_API.g_miss_char, NULL, p_qsnr_footer)
   WHERE PROGRAM_ID = p_program_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
   END IF;

END Update_Row;



--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
     p_program_id            NUMBER
    ,p_object_version_number NUMBER
    )
 IS

 BEGIN

UPDATE PV_PARTNER_PROGRAM_B
   SET

               program_id                = DECODE( p_program_id, NULL ,program_id, FND_API.g_miss_num,  NULL , p_program_id)
              ,enabled_flag              ='N'
              ,last_update_date          = SYSDATE
              ,last_updated_by           = FND_GLOBAL.user_id
              ,last_update_login         = FND_GLOBAL.conc_login_id
              ,object_version_number     = DECODE( p_object_version_number, NULL ,object_version_number, FND_API.g_miss_num,  NULL , p_object_version_number+1)


   WHERE PROGRAM_ID = p_program_id
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
   END IF;

   Update PV_PARTNER_PROGRAM_TL
   SET
               last_update_date    = SYSDATE
              ,last_updated_by     = FND_GLOBAL.user_id
              ,last_update_login   = FND_GLOBAL.conc_login_id
              ,source_lang         = USERENV('LANG')
              --,program_name        = DECODE( p_program_name, NULL, program_name, FND_API.g_miss_char, NULL, p_program_name)
              --,program_description = DECODE( p_program_description, NULL, program_description, FND_API.g_miss_char, NULL, p_program_description)
   WHERE PROGRAM_ID = p_program_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
   END IF;


 END Delete_Row ;




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
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
          )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_PARTNER_PROGRAM_B
        WHERE PROGRAM_ID =  px_program_id
        FOR UPDATE of PROGRAM_ID NOWAIT;
   Recinfo C%ROWTYPE;

 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.program_id = px_program_id)
       AND (    ( Recinfo.PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID)
            OR (    ( Recinfo.PROGRAM_TYPE_ID IS NULL )
                AND (  p_PROGRAM_TYPE_ID IS NULL )))
       AND (    ( Recinfo.program_level_code = p_program_level_code)
            OR (    ( Recinfo.program_level_code IS NULL )
                AND (  p_program_level_code IS NULL )))
       AND (    ( Recinfo.program_parent_id = p_program_parent_id)
            OR (    ( Recinfo.program_parent_id IS NULL )
                AND (  p_program_parent_id IS NULL )))
       AND (    ( Recinfo.program_owner_resource_id = p_program_owner_resource_id)
            OR (    ( Recinfo.program_owner_resource_id IS NULL )
                AND (  p_program_owner_resource_id IS NULL )))
       AND (    ( Recinfo.program_start_date = p_program_start_date)
            OR (    ( Recinfo.program_start_date IS NULL )
                AND (  p_program_start_date IS NULL )))
       AND (    ( Recinfo.program_end_date = p_program_end_date)
            OR (    ( Recinfo.program_end_date IS NULL )
                AND (  p_program_end_date IS NULL )))
      AND (    ( Recinfo.allow_enrl_until_date = p_allow_enrl_until_date)
            OR (    ( Recinfo.allow_enrl_until_date IS NULL )
                AND (  p_allow_enrl_until_date IS NULL )))
						AND (    ( Recinfo.citem_version_id= p_citem_version_id)
            OR (    ( Recinfo.citem_version_id IS NULL )
                AND (  p_citem_version_id IS NULL )))
      AND (    ( Recinfo.membership_valid_period = p_membership_valid_period)
            OR (    ( Recinfo.membership_valid_period IS NULL )
                AND (  p_membership_valid_period IS NULL )))
       AND (    ( Recinfo.membership_period_unit = p_membership_period_unit)
            OR (    ( Recinfo.membership_period_unit IS NULL )
                AND (  p_membership_period_unit IS NULL )))
       AND (    ( Recinfo.process_rule_id = p_process_rule_id)
            OR (    ( Recinfo.process_rule_id IS NULL )
                AND (  p_process_rule_id IS NULL )))
       AND (    ( Recinfo.prereq_process_rule_Id = p_prereq_process_rule_Id)
            OR (    ( Recinfo.prereq_process_rule_Id IS NULL )
                AND (  p_prereq_process_rule_Id IS NULL )))
       AND (    ( Recinfo.program_status_code = p_program_status_code)
            OR (    ( Recinfo.program_status_code IS NULL )
                AND (  p_program_status_code IS NULL )))
       AND (    ( Recinfo.submit_child_nodes = p_submit_child_nodes)
            OR (    ( Recinfo.submit_child_nodes IS NULL )
                AND (  p_submit_child_nodes IS NULL )))
       AND (    ( Recinfo.inventory_item_id  = p_inventory_item_id )
            OR (    ( Recinfo.inventory_item_id IS NULL )
                AND (  p_inventory_item_id IS NULL )))
       AND (    ( Recinfo.inventory_item_org_id = p_inventory_item_org_id )
            OR (    ( Recinfo.inventory_item_org_id IS NULL )
                AND (  p_inventory_item_org_id IS NULL )))
       AND (    ( Recinfo.bus_user_resp_id = p_bus_user_resp_id)
            OR (    ( Recinfo.bus_user_resp_id IS NULL )
                AND (  p_bus_user_resp_id IS NULL )))
      AND (    ( Recinfo.admin_resp_id = p_admin_resp_id)
            OR (    ( Recinfo.admin_resp_id IS NULL )
                AND (  p_admin_resp_id IS NULL )))
      AND (    ( Recinfo.no_fee_flag = p_no_fee_flag)
            OR (    ( Recinfo.no_fee_flag IS NULL )
                AND (  p_no_fee_flag IS NULL )))
      AND (    ( Recinfo.vad_invite_allow_flag = p_vad_invite_allow_flag)
            OR (    ( Recinfo.vad_invite_allow_flag IS NULL )
                AND (  p_vad_invite_allow_flag IS NULL )))
      AND (    ( Recinfo.global_mmbr_reqd_flag = p_global_mmbr_reqd_flag)
            OR (    ( Recinfo.global_mmbr_reqd_flag IS NULL )
                AND (  p_global_mmbr_reqd_flag IS NULL )))
      AND (    ( Recinfo.waive_subsidiary_fee_flag = p_waive_subsidiary_fee_flag)
            OR (    ( Recinfo.waive_subsidiary_fee_flag IS NULL )
                AND (  p_waive_subsidiary_fee_flag IS NULL )))
     AND (    ( Recinfo.qsnr_ttl_all_page_dsp_flag = p_qsnr_ttl_all_page_dsp_flag )
            OR (    ( Recinfo.qsnr_ttl_all_page_dsp_flag IS NULL )
                AND (  p_qsnr_ttl_all_page_dsp_flag  IS NULL )))
     AND (    ( Recinfo.qsnr_hdr_all_page_dsp_flag = p_qsnr_hdr_all_page_dsp_flag)
            OR (    ( Recinfo.qsnr_hdr_all_page_dsp_flag IS NULL )
                AND (  p_qsnr_hdr_all_page_dsp_flag IS NULL )))
      AND (    ( Recinfo.qsnr_ftr_all_page_dsp_flag= p_qsnr_ftr_all_page_dsp_flag)
            OR (    ( Recinfo.qsnr_ftr_all_page_dsp_flag IS NULL )
                AND (  p_qsnr_ftr_all_page_dsp_flag IS NULL )))
     AND (    ( Recinfo.allow_enrl_wout_chklst_flag = p_allow_enrl_wout_chklst_flag)
            OR (    ( Recinfo.allow_enrl_wout_chklst_flag IS NULL )
                AND ( p_allow_enrl_wout_chklst_flag IS NULL )))
      AND (    ( Recinfo.user_status_id = p_user_status_id)
            OR (    ( Recinfo.user_status_id IS NULL )
                AND (  p_user_status_id IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = px_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  px_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

END Lock_Row;



--  ========================================================
--
--  NAME
--  Add_Language
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================


PROCEDURE Add_Language
IS
BEGIN
  -- changing by pukken as per performance team guidelines to fix performance issue
  -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
  INSERT /*+ append parallel(tt) */ INTO PV_PARTNER_PROGRAM_TL tt
  (
      PROGRAM_ID
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_LOGIN
     ,LANGUAGE
     ,SOURCE_LANG
     ,PROGRAM_NAME
     ,PROGRAM_DESCRIPTION
  )
  SELECT /*+ parallel(v) parallel(t) use_nl(t)  */ v.*
  FROM
     (
         SELECT /*+ no_merge ordered parallel(b) */
         B.PROGRAM_ID
        ,B.LAST_UPDATE_DATE
        ,B.LAST_UPDATED_BY
        ,B.CREATION_DATE
        ,B.CREATED_BY
        ,B.LAST_UPDATE_LOGIN
        ,L.LANGUAGE_CODE
        ,B.SOURCE_LANG
        ,B.PROGRAM_NAME
        ,B.PROGRAM_DESCRIPTION
        FROM  PV_PARTNER_PROGRAM_TL B , FND_LANGUAGES L
        WHERE L.INSTALLED_FLAG IN ( 'I','B' ) AND B.LANGUAGE = USERENV ( 'LANG' )
     ) v
     , PV_PARTNER_PROGRAM_TL t
  WHERE t.PROGRAM_ID(+) = v.PROGRAM_ID
  AND t.language(+) = v.language_code
  AND t.PROGRAM_ID IS NULL ;

END Add_Language;




--  ========================================================
--
--  NAME
--  Translate_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE Translate_Row(
      px_program_id            IN VARCHAR2
     ,p_program_name           IN VARCHAR2
     ,p_program_description    IN VARCHAR2
     ,p_owner                  IN VARCHAR2
     ,p_qsnr_title             IN VARCHAR2
     ,p_qsnr_header            IN VARCHAR2
     ,p_qsnr_footer            IN VARCHAR2
     )

 IS

 BEGIN
    UPDATE PV_PARTNER_PROGRAM_TL set
       PROGRAM_NAME        = NVL(p_program_name, program_name)
      ,PROGRAM_DESCRIPTION = NVL(p_program_description, program_description)
      ,SOURCE_LANG         = USERENV('LANG')
      ,LAST_UPDATE_DATE    = SYSDATE
      ,LAST_UPDATED_BY     = DECODE(p_owner, 'SEED', 1, 0)
      ,LAST_UPDATE_LOGIN   = 0
      ,qsnr_title          = NVL(p_qsnr_title, qsnr_title )
      ,qsnr_header         = NVL(p_qsnr_header,qsnr_header )
      ,qsnr_footer         = NVL(p_qsnr_footer,qsnr_footer )

      WHERE PROGRAM_ID = px_program_id
      AND USERENV('LANG') IN (language, source_lang);

END Translate_Row;


END PV_PARTNER_PROGRAM_PKG;

/
