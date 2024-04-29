--------------------------------------------------------
--  DDL for Package QA_AK_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_AK_MAPPING_API" AUTHID CURRENT_USER AS
/* $Header: qltakmpb.pls 115.12 2002/11/27 19:21:23 jezheng ship $ */


g_element_appendix		CONSTANT VARCHAR2(10) := 'CHARID';
g_special_appendix		CONSTANT VARCHAR2(10) := 'QASP';

g_vqr_appendix			CONSTANT VARCHAR2(10) := 'QAVQR';

g_osp_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQROSP';
g_ship_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQRSHP';
g_om_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQROMP';

--Parent-Child
g_pc_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQRPCH';
g_pc_vqr_hdr_region		CONSTANT VARCHAR2(20) := 'QA_PC_RES_VQR_HDR';
g_child_url_attribute		CONSTANT VARCHAR2(20) := 'QASPCHILDURL';
g_pc_vqr_sin_appendix		CONSTANT VARCHAR2(10) := 'QAVQRSIN';
g_vqr_all_elements_url		CONSTANT VARCHAR2(30)
					:= 'QA_PC_STATIC_LINK';

g_txn_osp_appendix		CONSTANT VARCHAR2(10) := 'QAPLOSP';
g_txn_ship_appendix		CONSTANT VARCHAR2(10) := 'QAPLSHP';

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

g_lov_attribute_code		CONSTANT VARCHAR2(20) := 'QALOVCODE';
g_lov_attribute_description	CONSTANT VARCHAR2(20) := 'QALOVDESCRIPTION';
g_lov_attribute_org_id		CONSTANT VARCHAR2(20) := 'QALOVORGID';
g_lov_attribute_plan_id		CONSTANT VARCHAR2(20) := 'QALOVPLANID';
g_lov_attribute_dependency	CONSTANT VARCHAR2(20) := 'DEPEN';
g_eqr_view_usage_name 		CONSTANT VARCHAR2(30) := 'QaResultsVO';

g_vqr_view_usage_name 		CONSTANT VARCHAR2(30) := 'ViewResultsVO';
g_hidden_element_increment	CONSTANT NUMBER       := 2000;
g_application_id		CONSTANT NUMBER       := 250;

g_single_row_attachment		CONSTANT VARCHAR2(20) := 'AK_ATTACHMENT_LINK';
g_multi_row_attachment		CONSTANT VARCHAR2(20) := 'AK_ATTACHMENT_IMAGE';
g_update_attribute		CONSTANT VARCHAR2(20) := 'QASPUPDATE';

g_txn_work_appendix		CONSTANT VARCHAR2(10) := 'QAPLWORK';
g_txn_asset_appendix		CONSTANT VARCHAR2(10) := 'QAPLASSET';
g_txn_op_appendix		CONSTANT VARCHAR2(10) := 'QAPLOP';
g_work_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQRWORK';
g_asset_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQRASSET';
g_op_vqr_appendix		CONSTANT VARCHAR2(10) := 'QAVQROP';
g_eam_eqr_hdr_region		CONSTANT VARCHAR2(20) := 'QA_DDE_EQR_TOP';
g_eam_vqr_asset_hdr_region	CONSTANT VARCHAR2(20) := 'QA_VQR_DATA_HDR';
g_eam_vqr_work_hdr_region	CONSTANT VARCHAR2(20) := 'QA_VQR_TXN_HDR';




FUNCTION construct_ak_code (p_appendix IN VARCHAR2, p_id IN VARCHAR2)
    RETURN VARCHAR2;


FUNCTION retrieve_id (p_code IN VARCHAR2)
    RETURN NUMBER;


FUNCTION get_vo_attribute_name (p_char_id IN NUMBER, p_plan_id IN NUMBER)
    RETURN VARCHAR2;


PROCEDURE map_element (p_char_id IN NUMBER,  p_attribute_application_id IN
    NUMBER, p_appendix IN VARCHAR2);


PROCEDURE map_plan (p_plan_id IN NUMBER, p_region_application_id IN NUMBER,
    p_attribute_application_id IN NUMBER);


PROCEDURE delete_element_mapping (p_char_id IN NUMBER,
    p_attribute_application_id IN NUMBER);


PROCEDURE delete_plan_mapping (p_plan_id IN NUMBER, p_region_application_id
    IN NUMBER, p_attribute_application_id IN NUMBER);


-- This function is temporarily residing in this package.  It will
-- get moved to qa_chars_api (qltcharb.pls and qltcharb.plb) very soon.

FUNCTION context_element (element_id IN NUMBER, txn_number IN NUMBER)
    RETURN BOOLEAN;

END qa_ak_mapping_api;


 

/
