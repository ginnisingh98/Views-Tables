--------------------------------------------------------
--  DDL for Package QA_JRAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_JRAD_PKG" AUTHID CURRENT_USER AS
/* $Header: qajrads.pls 120.1.12000000.1 2007/01/19 07:09:15 appldev ship $ */


g_element_prefix		CONSTANT VARCHAR2(10) := 'CHARID';
g_special_prefix		CONSTANT VARCHAR2(10) := 'QASP';

g_jrad_region_path		CONSTANT VARCHAR2(50)
				 := '/oracle/apps/qa/regions/';

g_jrad_lov_path			CONSTANT VARCHAR2(50)
				 := '/oracle/apps/qa/lov/webui/QaLovRN';

g_vqr_prefix			CONSTANT VARCHAR2(10) := 'QAVQR';

g_osp_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQROSP';
g_ship_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQRSHP';
g_om_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQROMP';

--Parent-Child
g_pc_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQRPCH';
g_pc_vqr_hdr_region		CONSTANT VARCHAR2(20) := 'QA_PC_RES_VQR_HDR';
g_child_url_attribute		CONSTANT VARCHAR2(20) := 'QASPCHILDURL';
g_pc_vqr_sin_prefix		CONSTANT VARCHAR2(10) := 'QAVQRSIN';
g_vqr_all_elements_url		CONSTANT VARCHAR2(30)
					:= 'QA_PC_STATIC_LINK';

g_txn_osp_prefix		CONSTANT VARCHAR2(10) := 'QAPLOSP';
g_txn_ship_prefix		CONSTANT VARCHAR2(10) := 'QAPLSHP';

g_eqr_top_region		CONSTANT VARCHAR2(20) := 'QAEQRHDR';
g_vqr_top_region		CONSTANT VARCHAR2(20) := 'QAVQRHDR';
g_lov_region			CONSTANT VARCHAR2(20) := 'QALOVREGION';

g_org_id_attribute		CONSTANT VARCHAR2(20) := 'QASPORGID';
g_org_code_attribute		CONSTANT VARCHAR2(20) := 'QASPORGCODE';
g_plan_id_attribute		CONSTANT VARCHAR2(20) := 'QASPPLANID';
g_plan_name_attribute		CONSTANT VARCHAR2(20) := 'QASPPLANNAME';
g_process_status_attribute	CONSTANT VARCHAR2(20) := 'QASPPROCSTATUS';
g_source_code_attribute		CONSTANT VARCHAR2(20) := 'QASPSOURCECODE';
g_source_line_id_attribute	CONSTANT VARCHAR2(20) := 'QASPSOURCELINEID';
g_po_agent_id_attribute		CONSTANT VARCHAR2(20) := 'QASPPOAGENTID';

g_qa_created_by_attribute	CONSTANT VARCHAR2(20) := 'QASPQACREATEDBY';
g_collection_id_attribute	CONSTANT VARCHAR2(20) := 'QASPCOLLECTIONID';
g_last_update_date_attribute	CONSTANT VARCHAR2(20) := 'QASPLASTUPDATEDATE';

g_lov_attribute_code		CONSTANT VARCHAR2(20) := 'QaLovCode';
g_lov_attribute_description	CONSTANT VARCHAR2(20) := 'QaLovDesc';
g_lov_attribute_org_id		CONSTANT VARCHAR2(20) := 'QaLovOrgId';
g_lov_attribute_plan_id		CONSTANT VARCHAR2(20) := 'QaLovPlanId';
g_lov_attribute_dependency	CONSTANT VARCHAR2(20) := 'DEPEN';
g_eqr_view_usage_name 		CONSTANT VARCHAR2(30) := 'QaResultsVO';

g_vqr_view_usage_name 		CONSTANT VARCHAR2(30) := 'ViewResultsVO';
g_hidden_element_increment	CONSTANT NUMBER       := 2000;
g_application_id		CONSTANT NUMBER       := 250;

g_single_row_attachment		CONSTANT VARCHAR2(20) := 'AK_ATTACHMENT_LINK';
g_multi_row_attachment		CONSTANT VARCHAR2(20) := 'AK_ATTACHMENT_IMAGE';
g_update_attribute		CONSTANT VARCHAR2(20) := 'QASPUPDATE';

g_txn_work_prefix		CONSTANT VARCHAR2(10) := 'QAPLWORK';
g_txn_asset_prefix		CONSTANT VARCHAR2(10) := 'QAPLASSET';
g_txn_op_prefix		CONSTANT VARCHAR2(10) := 'QAPLOP';
g_work_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQRWORK';
g_asset_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQRASSET';
g_op_vqr_prefix		CONSTANT VARCHAR2(10) := 'QAVQROP';
--dgupta: Start R12 EAM Integration. Bug 4345492
g_checkin_vqr_prefix		CONSTANT VARCHAR2(20) := 'QAVQRCHECKIN';
g_checkin_eqr_prefix		CONSTANT VARCHAR2(20) := 'QAEQRCHECKIN';
g_checkout_vqr_prefix		CONSTANT VARCHAR2(20) := 'QAVQRCHECKOUT';
g_checkout_eqr_prefix		CONSTANT VARCHAR2(20) := 'QAEQRCHECKOUT';
--dgupta: End R12 EAM Integration. Bug 4345492

g_eam_eqr_hdr_region		CONSTANT VARCHAR2(20) := 'QA_DDE_EQR_TOP';
g_eam_vqr_asset_hdr_region	CONSTANT VARCHAR2(20) := 'QA_VQR_DATA_HDR';
g_eam_vqr_work_hdr_region	CONSTANT VARCHAR2(20) := 'QA_VQR_TXN_HDR';






PROCEDURE map_plan (p_plan_id IN NUMBER,
		       p_jrad_doc_ver IN NUMBER DEFAULT NULL);

PROCEDURE map_on_demand (p_plan_id IN NUMBER,
			 x_jrad_doc_ver OUT NOCOPY NUMBER);



-- This function is temporarily residing in this package.  It will
-- get moved to qa_chars_api (qltcharb.pls and qltcharb.plb) very soon.

FUNCTION context_element (element_id IN NUMBER, txn_number IN NUMBER)
    RETURN BOOLEAN;

END qa_jrad_pkg;


 

/
