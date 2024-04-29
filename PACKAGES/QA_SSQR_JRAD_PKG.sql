--------------------------------------------------------
--  DDL for Package QA_SSQR_JRAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SSQR_JRAD_PKG" AUTHID CURRENT_USER AS
/* $Header: qajrmps.pls 120.4.12010000.1 2008/07/25 09:19:47 appldev ship $ */


-- 12.1 Inline Region in MES
-- saugupta Mon, 20 Aug 2007 03:07:40 -0700 PDT
g_pkg_name                CONSTANT varchar2(100) := 'QA_SSQR_JRAD_PKG.';
/* g_debug_mode could be FND_LOG or QA_LOCAL default is FND_LOG */
g_debug_mode              varchar2(10) := 'FND_LOG';
g_eqr_advtable_layout     CONSTANT varchar2(100) := 'EQR_ADV_TABLE';
g_eqr_adv_table_prefix    CONSTANT VARCHAR2(25)  := 'QA_SSQR_ADV_TABLE_';

    --
    -- MOAC Project. 4637896
    -- New constants.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
g_jrad_lov_dir_path             CONSTANT VARCHAR2(50)
                                 := '/oracle/apps/qa/ssqr/lov/webui/';

-- jrad paths
g_jrad_region_path		CONSTANT VARCHAR2(50)
				 := '/oracle/apps/qa/regions/';
g_jrad_lov_path			CONSTANT VARCHAR2(50)
				 := '/oracle/apps/qa/ssqr/lov/webui/QaLovRN';
g_vo_name	 		CONSTANT VARCHAR2(30) := 'QualityResultsVO';



-- special items added to a plan data region
   -- for EQR
g_org_id_attribute		CONSTANT VARCHAR2(20) := 'QASPORGID';
g_plan_id_attribute		CONSTANT VARCHAR2(20) := 'QASPPLANID';
   -- for VQR
g_qa_created_by_attribute	CONSTANT VARCHAR2(20) := 'QASPQACREATEDBY';
g_collection_id_attribute	CONSTANT VARCHAR2(20) := 'QASPCOLLECTIONID';
g_last_update_date_attribute	CONSTANT VARCHAR2(20) := 'QASPLASTUPDATEDATE';
   -- Attachments
g_multi_row_attachment		CONSTANT VARCHAR2(20) := 'AK_ATTACHMENT_IMAGE';
g_attachment_entity		CONSTANT VARCHAR2(20) := 'QA_RESULTS';


-- Layout modes
g_eqr_single_layout		CONSTANT VARCHAR2(20) := 'EQR_SINGLE';
g_vqr_single_layout		CONSTANT VARCHAR2(20) := 'VQR_SINGLE';
g_eqr_multiple_layout		CONSTANT VARCHAR2(20) := 'EQR_MULTIPLE';



-- LOV and PopList
g_lov_attribute_code		CONSTANT VARCHAR2(20) := 'QaLovCode';
g_lov_attribute_description	CONSTANT VARCHAR2(20) := 'QaLovDesc';
g_lov_attribute_org_id		CONSTANT VARCHAR2(20) := 'QaLovOrgId';
g_lov_attribute_plan_id		CONSTANT VARCHAR2(20) := 'QaLovPlanId';
g_lov_attribute_dependency	CONSTANT VARCHAR2(20) := 'DEPEN';

g_pop_vo_prefix                 CONSTANT VARCHAR2(20) := 'QaPoplist';
g_pop_display_column            CONSTANT VARCHAR2(20) := 'DESCRIPTION';
g_pop_value_column              CONSTANT VARCHAR2(20) := 'SHORT_CODE';


-- long comments
g_comments_height		CONSTANT NUMBER       := 5;
g_comments_width		CONSTANT NUMBER       := 80;
g_comments_max_len		CONSTANT NUMBER       := 2000;


-- Char datatypes
g_char_datatype			CONSTANT NUMBER       := 1;
g_num_datatype			CONSTANT NUMBER       := 2;
g_date_datatype			CONSTANT NUMBER       := 3;
g_comments_datatype		CONSTANT NUMBER       := 4;
g_seq_datatype			CONSTANT NUMBER       := 5;
g_datetime_datatype		CONSTANT NUMBER       := 6;


-- Data entry hints
g_tip_type			CONSTANT VARCHAR2(20)       := 'longMessage';
g_tip_message_name		CONSTANT VARCHAR2(20)       := 'QA_DATA_HINT_CHARID';
g_app_short_name		CONSTANT VARCHAR2(20)       := 'QA';
g_long_tip_region               CONSTANT VARCHAR2(200)       := '/oracle/apps/qa/ssqr/webui/QaLongTipRN';


-- prefixes for SSQR regions

g_element_prefix		CONSTANT VARCHAR2(10) := 'CHARID';
g_dtl_element_prefix		CONSTANT VARCHAR2(10) := 'DTLCHARID';

g_eqr_single_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_E_SING_';
g_eqr_data_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_E_DATA_';
g_eqr_comments_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_E_CMNT_';

g_vqr_single_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_V_SING_';
g_vqr_data_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_V_DATA_';
g_vqr_comments_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_V_CMNT_';

g_eqr_multiple_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_E_MULT_';
g_eqr_mult_dtl_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_E_MDTL_';

g_ncm				CONSTANT VARCHAR2(25) := 'N_';
g_car				CONSTANT VARCHAR2(25) := 'C_';
g_ora_data_text                 CONSTANT VARCHAR2(25) := 'OraDataText';

-- 12.1 Device Integration Project
-- Global Constants.
-- bhsankar Wed Oct 24 04:45:16 PDT 2007
g_eqr_device_prefix             CONSTANT VARCHAR2(25) := 'QA_SSQR_E_DEVI_';
g_device_element_suffix         CONSTANT VARCHAR2(25) := 'CHK';
g_eqr_mult_data_prefix          CONSTANT VARCHAR2(25) := 'QA_SSQR_E_MDAT_';

-- 12.1 QWB Usability Project
-- Global Constants for Export Page
g_vqr_multiple_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_V_MULT_';
g_vqr_mult_dtl_prefix		CONSTANT VARCHAR2(25) := 'QA_SSQR_V_MDTL_';
g_export_vo_name            CONSTANT VARCHAR2(30) := 'ResultExportVO';
g_vqr_multiple_layout		CONSTANT VARCHAR2(20) := 'VQR_MULTIPLE';


PROCEDURE map_plan (p_plan_id IN NUMBER);

PROCEDURE map_on_demand (p_plan_id IN NUMBER);

--
-- Bug 4697145
-- MOAC upgrade needs to delete JRad region.  But this procedure
-- is generic to be used by other projects.
-- No longer used by MOAC.  But this is generic, therefore leaving.
-- bso Sun Nov  6 16:53:56 PST 2005
--
PROCEDURE delete_plan_jrad_region(p_plan_id IN NUMBER);

--
-- Tracking Bug 4697145
-- MOAC Upgrade feature to indicate this plan has
-- been regenerated and on demand mapping can skip.
-- bso Sun Nov  6 16:52:53 PST 2005
--
PROCEDURE jrad_upgraded(p_plan_id IN NUMBER);

END qa_ssqr_jrad_pkg;


/
