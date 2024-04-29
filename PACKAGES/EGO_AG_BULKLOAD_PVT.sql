--------------------------------------------------------
--  DDL for Package EGO_AG_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_AG_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVAGBS.pls 120.0.12010000.5 2010/04/27 06:09:35 jiabraha noship $ */
  ----------------------
  -- Global Constants --
  ----------------------
	/*Transaction Types*/
    G_OPR_CREATE CONSTANT VARCHAR2(30) := 'CREATE';
    G_OPR_UPDATE CONSTANT VARCHAR2(30) := 'UPDATE';
    G_OPR_DELETE CONSTANT VARCHAR2(30) := 'DELETE';
    G_OPR_SYNC CONSTANT VARCHAR2(30) := 'SYNC';

    /*Return Statuses*/
    G_RET_STS_SUCCESS CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

    /*Concurrent Program Parameters*/
    G_PROG_APPL_ID CONSTANT NUMBER := FND_GLOBAL.PROG_APPL_ID;
    G_PROGRAM_ID CONSTANT NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    G_REQUEST_ID CONSTANT NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    G_USER_ID            NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID           NUMBER := FND_GLOBAL.LOGIN_ID;
    G_SET_PROCESS_ID     NUMBER;
    G_COMMIT             BOOLEAN := TRUE;
    G_AG_COUNT			 NUMBER :=0;
    G_DL_COUNT			 NUMBER :=0;
    G_ATTR_COUNT		 NUMBER :=0;

    /*Process Status variables*/
    G_PROCESS_RECORD CONSTANT NUMBER := 1;
    G_ERROR_RECORD CONSTANT NUMBER := 3;
    G_SUCCESS_RECORD CONSTANT NUMBER := 7;

    G_EGO_APPLICATION_ID NUMBER;
    G_EGO_ITEMMGMT_GROUP CONSTANT VARCHAR2(30) := 'EGO_ITEMMGMT_GROUP';

    /*Error handler vairables*/
    G_MESSAGE_NAME       VARCHAR2(100);
    G_MESSAGE_TEXT       VARCHAR2(2000);
    G_BO_IDENTIFIER_AG CONSTANT VARCHAR2(30) := 'AG_BO';
    G_ENTITY_AG CONSTANT VARCHAR2(30) := 'AG';
    G_ENTITY_DL CONSTANT VARCHAR2(30) := 'AG_DATALEVEL';
    G_ENTITY_ATTR CONSTANT VARCHAR2(30) := 'AG_ATTRIBUTE';
    G_ENTITY_AG_TAB CONSTANT VARCHAR2(30) := 'EGO_ATTR_GROUPS_INTERFACE';
    G_ENTITY_DL_TAB CONSTANT VARCHAR2(30) := 'EGO_ATTR_GROUPS_DL_INTERFACE';
    G_ENTITY_ATTR_TAB CONSTANT VARCHAR2(30) := 'EGO_ATTR_GROUP_COLS_INTF';
    G_TOKEN_TABLE        ERROR_HANDLER.TOKEN_TBL_TYPE;

    /*Flow Type variables*/
    G_EGO_MD_API CONSTANT NUMBER := 1;
    G_EGO_MD_INTF CONSTANT NUMBER := 2;
    G_FLOW_TYPE          NUMBER := G_EGO_MD_API;

    /*Data Type variables*/
    G_TRANS_TEXT_DATA_TYPE CONSTANT VARCHAR2(1) := 'A';
    G_CHAR_DATA_TYPE CONSTANT VARCHAR2(1) := 'C';
    G_NUMBER_DATA_TYPE CONSTANT VARCHAR2(1) := 'N';
    G_DATE_DATA_TYPE CONSTANT VARCHAR2(1) := 'X';
    G_DATE_TIME_DATA_TYPE CONSTANT VARCHAR2(1) := 'Y';

    /*Display As variables*/
    G_ATTACH_DISP_TYPE CONSTANT VARCHAR2(1) := 'A';
    G_CHECKBOX_DISP_TYPE CONSTANT VARCHAR2(1) := 'C';
    G_DYN_URL_DISP_TYPE CONSTANT VARCHAR2(1) := 'D';
    G_HIDDEN_DISP_TYPE CONSTANT VARCHAR2(1) := 'H';
    G_RADIO_DISP_TYPE CONSTANT VARCHAR2(1) := 'R';
    G_STATIC_URL_DISP_TYPE CONSTANT VARCHAR2(1) := 'S';
    G_TEXT_FIELD_DISP_TYPE CONSTANT VARCHAR2(1) := 'T';
    G_TEXT_AREA_DISP_TYPE CONSTANT VARCHAR2(1) := 'L';

    /*Null variables*/
    G_NULL_NUM CONSTANT NUMBER := 9.99E125;
    G_NULL_CHAR CONSTANT VARCHAR2(1) := Chr(0);
    G_NULL_DATE CONSTANT DATE := To_date('1', 'j');

    /*Data Level variables*/
    G_DL_ITEM_LEVEL	CONSTANT VARCHAR2(30) := 'ITEM_LEVEL';
    G_DL_ITEM_REV_LEVEL CONSTANT VARCHAR2(30) := 'ITEM_REVISION_LEVEL';
    G_DL_ITEM_ORG CONSTANT VARCHAR2(30) := 'ITEM_ORG';
    G_DL_ITEM_SUP CONSTANT VARCHAR2(30) := 'ITEM_SUP';
    G_DL_ITEM_SUP_SITE CONSTANT VARCHAR2(30) := 'ITEM_SUP_SITE';
    G_DL_ITEM_SUP_SITE_ORG CONSTANT VARCHAR2(30) := 'ITEM_SUP_SITE_ORG';


  /*This Procedure is used to initialize certain column values in the interface table.
    Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE initialize(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to validate the transaction type for all the interface tables.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE validate_transaction_type(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attribute Groups.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_ag(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attribute Groups
    Data level.	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_dl(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attributes.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_attr(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used construct attribute group records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_attr_groups(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used construct attribute group data level records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_ag_data_level(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used construct attributes records.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_attribute(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attribute group plsql tables.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_ag_tbl(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attribute group
    data level plsql tables. Used in the API flow.
    p_agdl_tbl      IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_dl_tbl(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for Attributes plsql tables.
  	Used in the API flow.
  	p_attr_tbl      IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_attr_tbl(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to bulk validate attribute groups.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE bulk_validate_attr_groups(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to bulk validate attributes.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE bulk_validate_attribute(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do additional validations on attribute groups.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE additional_agdl_validations(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do additional validations on attributes.
  	Used in the API flow.
  	p_attr_tbl        IN OUT NOCOPY  Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE additional_attr_validations(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do Common validations on attribute groups.
  	Used in the Interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE common_ag_validations(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do Common validations on attribute group data level.
  	Used in the Interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE common_dl_validations(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do Common validations on attributes.
  	Used in the Interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY  Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE common_attr_validations(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This is the main procedure called to import attribute groups, data level and attributes
  	Used in the Interface flow.
  	p_set_process_id   IN   Set_Process_ID
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE import_ag_intf(
    p_set_process_id   IN VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_return_msg	   OUT NOCOPY VARCHAR2);

  /*This is the main procedure called to import attribute groups and data levels.
  	Used in the API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	p_agdl_tbl      IN OUT NOCOPY Data level plsql table
  	p_commit        IN Pass true to commit within the API
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_attr_groups(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    p_commit        IN BOOLEAN DEFAULT true,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This is the main procedure called to import attributes.
  	Used in the API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	p_commit        IN Pass true to commit within the API
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_attribute(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    p_commit        IN BOOLEAN DEFAULT true,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used in the update flow to handle null values for AG
  	Used in the interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_ag(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do final processing of the attribute group data level.
  	Used in the interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_dl(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do final processing of the attributes.
  	Used in the interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_attr(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do final processing of the attribute groups.
  	Used in the interface and API flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute groups plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_ag(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do final processing of the attribute group data level.
  	Used in the interface and API flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_dl(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to do final processing of the attributes.
  	Used in the interface and API flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_attr(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to update the attribute group interface table
  	Used in the interface flow.
  	p_ag_tbl        IN OUT NOCOPY Attribute group plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_attr_groups(
    p_ag_tbl        IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to update the attribute group data level interface table
  	Used in the interface flow.
  	p_agdl_tbl        IN OUT NOCOPY Attribute group data level plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_data_level(
    p_agdl_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_groups_dl_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to update the attributes interface table
  	Used in the Interface flow.
  	p_attr_tbl        IN OUT NOCOPY Attributes plsql table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_attribute(
    p_attr_tbl      IN OUT NOCOPY ego_metadata_pub.ego_attr_group_cols_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to delete processed records from the attribute group's interface table
  	Used in the interface flow.
  	x_set_process_id IN Set process id
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_attr_groups(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to delete processed records from the AG Data level's interface table
  	Used in the interface flow.
	x_set_process_id IN Set process id
	x_return_status OUT NOCOPY parameter that returns the status*/
  PROCEDURE delete_processed_data_level(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to delete processed records from the Attribute's interface table
  	Used in the Interface flow.
	x_set_process_id IN Set process id
	x_return_status OUT NOCOPY parameter that returns the status
	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_attributes(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

 /*This procedure is used to delete AG existing in the production table without a single DL associated
  	Used in the Interface flow and API flow.
	x_return_status OUT NOCOPY parameter that returns the status
	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_ag_none_dl(
  x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*Added for bug 9625957*/
  	------------------------------------------------------------------------------------------
	-- Function: To return the  pending base table name  for a given attribute group type
	--  an the application id
	--           If the table is not defined, NULL is returned
	--
	-- Parameters:
	--         IN
	--  p_attr_group_type:  attribute_group_type
	--  p_attr_group_type      application_id
	--        OUT
	--  l_table_name     : base table for attribute_changes
	------------------------------------------------------------------------------------------
	FUNCTION Get_Attr_Changes_B_Table (
	        p_application_id                IN   NUMBER
	       ,p_attr_group_type               IN   VARCHAR2
	)RETURN VARCHAR2;

	------------------------------------------------------------------------------------------
	-- Function: To return the  pending transalatable table name  for a given attribute group type
	--  an the application id
	--           If the table is not defined, NULL is returned
	--
	-- Parameters:
	--         IN
	--  p_attr_group_type:  attribute_group_type
	--  p_attr_group_type      application_id
	--        OUT
	--  l_table_name     : translatable table for attribute_changes
	------------------------------------------------------------------------------------------
	FUNCTION Get_Attr_Changes_TL_Table (
	        p_application_id                IN   NUMBER
	       ,p_attr_group_type               IN   VARCHAR2
	)RETURN VARCHAR2;

	/*This local procedure will return the table name based on the attribute group Type
    p_application_id  IN EGO Application ID
    p_attr_group_type IN Attribute group Type*/
	FUNCTION Get_Table_Name (
        p_application_id  IN   NUMBER
       ,p_attr_group_type IN   VARCHAR2
	)RETURN VARCHAR2;

	/*This local procedure will return the TL table name based on the attribute group Type
    p_application_id  IN EGO Application ID
    p_attr_group_type IN Attribute group Type*/
  FUNCTION Get_TL_Table_Name (
        p_application_id  IN   NUMBER
       ,p_attr_group_type IN   VARCHAR2
	)RETURN VARCHAR2;
  /*End of comment for bug 9625957*/
  /*This procedure will log debug messages
    x_msg IN Input message name*/
  Procedure write_debug(x_msg IN VARCHAR2);
END ego_ag_bulkload_pvt;

/
