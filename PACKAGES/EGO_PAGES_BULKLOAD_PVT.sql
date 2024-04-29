--------------------------------------------------------
--  DDL for Package EGO_PAGES_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_PAGES_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVPGBS.pls 120.0.12010000.5 2010/04/27 06:10:22 jiabraha noship $ */
  ----------------------
  -- Global Constants --
  ----------------------
    /*Transaction Type variables*/
	G_OPR_CREATE CONSTANT VARCHAR2(30) := 'CREATE';
    G_OPR_UPDATE CONSTANT VARCHAR2(30) := 'UPDATE';
    G_OPR_DELETE CONSTANT VARCHAR2(30) := 'DELETE';
    G_OPR_SYNC CONSTANT VARCHAR2(30) := 'SYNC';

    /*Error status variables*/
    G_RET_STS_SUCCESS CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

    /*Concurrent Program variables*/
    G_PROG_APPL_ID CONSTANT NUMBER := FND_GLOBAL.PROG_APPL_ID;
    G_PROGRAM_ID CONSTANT NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    G_REQUEST_ID CONSTANT NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    G_USER_ID            NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID           NUMBER := FND_GLOBAL.LOGIN_ID;
    G_SET_PROCESS_ID     NUMBER;
    G_EGO_APPLICATION_ID NUMBER;
    G_COMMIT             BOOLEAN := TRUE;
    G_OBJECT_ID          NUMBER;
    G_PAGES_COUNT		 NUMBER :=0;
    G_PAGE_ENTRIES_COUNT NUMBER :=0;

    /*Process status variables*/
    G_PROCESS_RECORD CONSTANT NUMBER := 1;
    G_ERROR_RECORD CONSTANT NUMBER := 3;
    G_SUCCESS_RECORD CONSTANT NUMBER := 7;

    /*Flow Type variables*/
    G_FLOW_TYPE          NUMBER;
    G_EGO_MD_API CONSTANT NUMBER := 1;
    G_EGO_MD_INTF CONSTANT NUMBER := 2;

    /*Error Handling variables*/
    G_MESSAGE_NAME       VARCHAR2(100);
    G_MESSAGE_TEXT       VARCHAR2(2000);
    G_BO_IDENTIFIER_PG CONSTANT VARCHAR2(30) := 'ICC_BO';
    G_ENTITY_PG CONSTANT VARCHAR2(30) := 'ICC_PG';
    G_ENTITY_ENT CONSTANT VARCHAR2(30) := 'ICC_PG_ENTRIES';
    G_ENTITY_PG_TAB CONSTANT VARCHAR2(30) := 'EGO_PAGES_INTERFACE';
    G_ENTITY_ENT_TAB CONSTANT VARCHAR2(30) := 'EGO_PAGE_ENTRIES_INTERFACE';
    G_TOKEN_TABLE        ERROR_HANDLER.TOKEN_TBL_TYPE;

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

  /*This procedure is used for value to ID conversion for Pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_pages(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for the value to ID conversion for Page Entries.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_pg_entries(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for constructing the records for pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_pages(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for constrcting the records for page entries.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_pg_entries(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to construct the records for page pl/sql table.
    p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_page_tbl(
   p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
   x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used sed to construct the records for page entries pl/sql table.
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE construct_pg_entries_tbl(
   p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
   x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used for value to ID conversion for pages.
  	Used in the API flow.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_page_tbl(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for value to ID conversion for page entries.
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE value_to_id_pg_entries_tbl(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for bulk validation of the pages.
  	Used in the interface flow.
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE bulk_validate_pages(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used for the bulk validation for the page entries.
    Used in the interface flow.
    x_return_status OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE bulk_validate_pg_entries(
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to handle the additional validations for Pages.
  	Used in the API flow.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE additional_pg_validations(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to handle the additional validations for Page Entries
  	Used in the API flow.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE additional_ent_validations(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to handle the common validations pertaining to Pages.
  	Used in the both the flows.
  	p_pg_tbl        IN OUT NOCOPY Pages table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE common_pg_validations(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to handle the common validations pertaining to page entries.
  	Used in both flows.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
  	x_return_status OUT NOCOPY parameter that returns the status
  	x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE common_ent_validations(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This is the main procedure that is called by the interface flow.
    p_set_process_id   IN set_process_id
    x_return_status    OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE import_pg_intf(
    p_set_process_id   IN VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_return_msg	   OUT NOCOPY VARCHAR2);


  /*This the main procedure called by the public API to create pages.
    p_pg_tbl        IN OUT NOCOPY Pages table
    p_commit        IN  controls whether commit to be executed or not
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_pages(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    p_commit        IN BOOLEAN DEFAULT true,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This the main procedure called by the public API to create pages.
    p_ent_tbl        IN OUT NOCOPY Pages Entries table
    p_commit        IN  controls whether commit to be executed or not
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE Process_pg_entries(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    p_commit        IN BOOLEAN DEFAULT true,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to process the Pages.
  	Used by both the flows.
  	p_pg_tbl        IN OUT NOCOPY Pages table
    x_return_status OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_pg(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to process the page entries.
  	Used in both flows.
  	p_ent_tbl       IN OUT NOCOPY Page Entries table
    x_return_status OUT NOCOPY parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE process_ent(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to update the Pages interface table.
    Used in the interface flow.
    p_pg_tbl        IN OUT NOCOPY Pages table
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_pages(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to update the page entries interface table.
  	Used in the interface flow.
  	p_ent_tbl        IN OUT NOCOPY Page Entries table
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE update_intf_pg_entries(
    p_ent_tbl       IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure is used to delete processed records from the pages interface
    Used in the interface flow.
    x_set_process_id IN Set Process ID
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_pages(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);


  /*This procedure is used to deleted processed records from the page entries interface
  	Used in the interface flow.
  	x_set_process_id IN Set Process ID
    x_return_status OUT NOCOPY  parameter that returns the status
    x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE delete_processed_pg_entries(
    x_set_process_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

   /*This procedure is used in the update flow to handle null values for PG
        Used in the interface and API flow.
        p_pg_tbl        IN OUT NOCOPY Pages plsql table
        x_return_status OUT NOCOPY parameter that returns the status
        x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_pg(
    p_pg_tbl        IN OUT NOCOPY ego_metadata_pub.ego_pg_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

   /*This procedure is used in the update flow to handle null values for PG Entries
        Used in the interface and API flow.
        p_ent_tbl        IN OUT NOCOPY Page Entries plsql table
        x_return_status OUT NOCOPY parameter that returns the status
        x_return_msg OUT NOCOPY parameter that returns the error message*/
  PROCEDURE handle_null_pg_entries(
    p_ent_tbl        IN OUT NOCOPY ego_metadata_pub.ego_ent_tbl,
    x_return_status OUT NOCOPY VARCHAR2, x_return_msg OUT NOCOPY VARCHAR2);

  /*This procedure will log debug messages
    x_msg IN Input message name*/
  Procedure write_debug(x_msg IN VARCHAR2);

END ego_pages_bulkload_pvt;

/
