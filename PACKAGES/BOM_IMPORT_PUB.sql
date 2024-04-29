--------------------------------------------------------
--  DDL for Package BOM_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_IMPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMSIMPS.pls 120.19.12010000.3 2009/05/14 22:49:51 mshirkol ship $ */
/*#  This package provides APIs for importing structure and its related entities
 * through open interface or through web-adi interface.  The supported entities
 * are structure header, components, substitute components, reference
 * designators and component operations.  Each import batch is identified by
 * a batch identifier.
 *   The APIs in this package supports external items and structure import
 * for product data hub support along with support for creation of structures
 * for existing PDH Items. It also includes Change control on data for
 * objects that have change policies defined at object level or at batch
 * level (for information about Change functionality, refer to the
 * Change Management documentation).

 *
 *                          ------------------
 *                          -- Object Types --
 *                          ------------------
 *
 * Each of the following data types is defined as an Oracle object type
 * or recodrd type that exists independently in the database.  These these
 * types were created for use by this package.
 *
 * --------------------------
 * BATCH_OPTIONS - used to store batch options in a session
 * --------------------------
 *<code><pre>

 * Type batch_options as object
 *   SOURCE_SYSTEM_ID           EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_ID%TYPE
 * , BATCH_TYPE                 EGO_IMPORT_BATCHES_B.BATCH_TYPE%TYPE
 * , ASSIGNEE                   EGO_IMPORT_BATCHES_B.ASSIGNEE%TYPE
 * , BATCH_STATUS               EGO_IMPORT_BATCHES_B.BATCH_STATUS%TYPE
 * , MATCH_ON_DATA_LOAD         EGO_IMPORT_OPTION_SETS.MATCH_ON_DATA_LOAD%TYPE
 * , IMPORT_ON_DATA_LOAD        EGO_IMPORT_OPTION_SETS.IMPORT_ON_DATA_LOAD%TYPE
 * , IMPORT_XREF_ONLY           EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE
 * , STRUCTURE_TYPE_ID          EGO_IMPORT_OPTION_SETS.STRUCTURE_TYPE_ID%TYPE
 * , STRUCTURE_NAME             EGO_IMPORT_OPTION_SETS.STRUCTURE_NAME%TYPE
 * , STRUCTURE_EFFECTIVITY_TYPE EGO_IMPORT_OPTION_SETS.STRUCTURE_EFFECTIVITY_TYPE%TYPE
 * , EFFECTIVITY_DATE           EGO_IMPORT_OPTION_SETS.EFFECTIVITY_DATE%TYPE
 * , FROM_END_ITEM_UNIT_NUMBER  EGO_IMPORT_OPTION_SETS.FROM_END_ITEM_UNIT_NUMBER%TYPE
 * , STRUCTURE_CONTENT          EGO_IMPORT_OPTION_SETS.STRUCTURE_CONTENT%TYPE
 * , CHANGE_NOTICE              EGO_IMPORT_OPTION_SETS.CHANGE_NOTICE%TYPE
 * , CHANGE_ORDER_CREATION      EGO_IMPORT_OPTION_SETS.CHANGE_ORDER_CREATION%TYPE
 * , PDH_BATCH                  varchar2(1)
 *</pre></code>
* ----------------
 *   Parameters
 * ----------------
 * <pre>
 * Object_Name                -- BATCH_OPTIONS
 * SOURCE_SYSTEM_ID           -- Source System Id for the batch
 * BATCH_TYPE                 -- Batch Type, Item Batch or Structure Batch
 * ASSIGNEE                  -- Assignee for the batch
 * BATCH_STATUS              -- Status like pending, completed etc.
 * MATCH_ON_DATA_LOAD        -- Run match on data load  (Y/N)
 * IMPORT_ON_DATA_LOAD       -- Run import on Data Load (Y/N)
 * IMPORT_XREF_ONLY          -- Import only Croosreferenced Items
 * STRUCTURE_TYPE_ID         -- Structure Type ID
 * STRUCTURE_NAME            -- Alternate BOM Designator/Structure Name
 * STRUCTURE_EFFECTIVITY_TYPE -- Effectivity Control
 * EFFECTIVITY_DATE           -- Effectivity Date for Date Effectivity Structures
 * FROM_END_ITEM_UNIT_NUMBER  -- From End Item Unit Number for Unit Effectivity
 * STRUCTURE_CONTENT          -- Complete Structure (Y/N)
 * CHANGE_NOTICE              -- Change Notice
 * CHANGE_ORDER_CREATION      -- N - New, E - Existing , I - None/Ignore Change
 * PDH_BATCH                  -- Y - yes, N - NO
 </pre>
 * @rep:scope public
 * @rep:product BOM
 * @rep:displayname Structure Import
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSIMPS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Import_Pub
--
--  NOTES
--
--  HISTORY
--
-- 04-May-2005    Sreejith Nelloliyil   Initial Creation
-- 05-May-2005    Dinu Krishnan         Created the APIs
--                                      1.RESOLVE_XREFS_FOR_BATCH
--                                      2.Update Match Data
--                                      3.Update Bill Info
--                                      4.Check Component Exist
***************************************************************************/


  TYPE BATCH_OPTIONS  IS RECORD
  ( SOURCE_SYSTEM_ID           EGO_IMPORT_BATCHES_B.SOURCE_SYSTEM_ID%TYPE
  , BATCH_TYPE                 EGO_IMPORT_BATCHES_B.BATCH_TYPE%TYPE
  , ASSIGNEE                   EGO_IMPORT_BATCHES_B.ASSIGNEE%TYPE
  , BATCH_STATUS               EGO_IMPORT_BATCHES_B.BATCH_STATUS%TYPE
  , MATCH_ON_DATA_LOAD         EGO_IMPORT_OPTION_SETS.MATCH_ON_DATA_LOAD%TYPE
  , IMPORT_ON_DATA_LOAD        EGO_IMPORT_OPTION_SETS.IMPORT_ON_DATA_LOAD%TYPE
  , IMPORT_XREF_ONLY           EGO_IMPORT_OPTION_SETS.IMPORT_XREF_ONLY%TYPE
  , STRUCTURE_TYPE_ID          EGO_IMPORT_OPTION_SETS.STRUCTURE_TYPE_ID%TYPE
  , STRUCTURE_NAME             EGO_IMPORT_OPTION_SETS.STRUCTURE_NAME%TYPE
  , STRUCTURE_EFFECTIVITY_TYPE EGO_IMPORT_OPTION_SETS.STRUCTURE_EFFECTIVITY_TYPE%TYPE
  , EFFECTIVITY_DATE           EGO_IMPORT_OPTION_SETS.EFFECTIVITY_DATE%TYPE
  , FROM_END_ITEM_UNIT_NUMBER  EGO_IMPORT_OPTION_SETS.FROM_END_ITEM_UNIT_NUMBER%TYPE
  , STRUCTURE_CONTENT          EGO_IMPORT_OPTION_SETS.STRUCTURE_CONTENT%TYPE
  , CHANGE_NOTICE              EGO_IMPORT_OPTION_SETS.CHANGE_NOTICE%TYPE
  , CHANGE_ORDER_CREATION      EGO_IMPORT_OPTION_SETS.CHANGE_ORDER_CREATION%TYPE
  , PDH_BATCH                  varchar2(1)
  , ADD_ALL_TO_CHANGE_FLAG    EGO_IMPORT_OPTION_SETS.ADD_ALL_TO_CHANGE_FLAG%TYPE
  );

  --TYPE VARCHAR2_VARRAY is VARRAY(3) OF VARCHAR2(25); we have an xdf for this


  --
  --  Global Constants
  --
--G_PDH_SRCSYS_ID NUMBER  := 20202;
G_PDH_SRCSYS_ID NUMBER  := EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID; --Bom_Common_Definitions.Get_Pdh_Srcsys_Code;
--EGO_IMPORT_PVT.G_PDH_SOURCE_SYSTEM_ID;
G_APP_SHORT_NAME VARCHAR2(3)  := 'BOM';

  -- PIM for Telco Validations
  -- Telco Library validation is commented as it was
  -- decided not to provide/support validations for this attributes.
  -- G_COM_VALDN_FAIL  CONSTANT NUMBER := 3.65;

/************************************************************************
* Procedure: Populate_Struct_Interface_Rows
* Purpose  : This method will populate the Structure and Component Interface
*            tables from EGO_BULKLOAD_INTF Table.  This API will be invoked
*            by EGO-WEBADI program.  API queries the display format metadata
*            and populates the interface columns accordingly.  The table
*            EGO_BULKLOAD_INTF stores the data uploaded by XL WEB-ADI interface.



* Parameters:
*    p_batch_id                   IN
*    p_result_format_usageId      IN
*    x_error_msg                  OUT
*    x_return_code                OUT
**************************************************************************/
/*#
* This method will populate the structure and component Interface tables
* from EGO_BULKLOAD_INTF Table.  This table holds the data loaded by
* XL (WEB-ADI) Interface by users.
* @param p_batch_id batch identifier
* @param p_resultfmt_usage_id result format usage id
* @param p_user_id   User Id
* @param p_conc_request_id Concurrent Request Id
* @param p_language_code  Language Code
* @param p_start_upload - This could have values 'T' - yes, 'F' - no, 'J' - from JCP
* @param x_errbuff OUT Error Message.
* @param x_retcode Return code holding return status
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Perform Attribute Rollup on a BOM/Product Structure
*/
  PROCEDURE Process_Structure_Data
  (  p_batch_id              IN  NUMBER  ,
     p_resultfmt_usage_id    IN         NUMBER,
     p_user_id               IN         NUMBER,
     p_conc_request_id       IN         NUMBER,
     p_language_code         IN         VARCHAR2,
     p_start_upload          IN         VARCHAR2,
     x_errbuff               IN OUT NOCOPY VARCHAR2,
     x_retcode               IN OUT NOCOPY VARCHAR2
  );


/*#
 *  This procedure will  update the Bom Structure and Components
 *  Interface tables with the cross reference data obtained from
 *  Mtl_Cross_References.This API will update the Cross Referenced data
 *  for record in a batch which have matching entries in Mtl_Cross_References
 *  tabele.
 *  @param p_batch_id Batch Identifier for the batch being Imported
 *  @param x_Mesg_Token_Tbl Error handler Message Token
 *  @param x_Return_Status Return code holding return status
 *  @rep:scope private
 *  @rep:lifecycle active
 *  @rep:displayname Resolve Cross References
 */

  PROCEDURE RESOLVE_XREFS_FOR_BATCH
  (
    p_batch_id           IN NUMBER
  , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_Status      IN OUT NOCOPY VARCHAR2
  );

/*#
 * This procedure will  update the Bom Structure and Components
 * Interface tables with the PDH matched data fro Ego_Item_Matches table
 * This API will will update the Matched PDH Data
 * for record in a batch which have matching entries
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param p_source_system_id Source System Identifier for the Batch
 * @param x_Mesg_Token_Tbl Error handler Message Token
 * @param x_Return_Status Return code holding return status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update Match Data
 */
  PROCEDURE UPDATE_MATCH_DATA
 (
   p_batch_id   IN NUMBER
 , p_source_system_id   IN NUMBER
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
 );


/*#
 * This procedure will Update the Bom Structure and Components Interface
 * tables with Bill Sequence Id,Component Sequence Id and Transaction Type
 * Info based on the matched or cross referenced data that the record in the
 * Interface table will have.If the Header interface table record has a valid
 * Structure Header information in PDH then the Bill Squence Id for that existing
 * Structure will be populated in the Header Interface table record.The transaction
 * type will be changed to UPDATE only if the user entered value is 'SYNC'.If the
 * target bill doesnt exist then the transaction type will be updated to CREATE.


 * Also for all the component records for each Header this API will update the
 * Component Sequence Id,Bill Sequence Id and the Transaction Type if the Component

 * specified by data in the interface table record exist in the target Structure.
 * If the Target Structure has any component that doesnt match with any of the
 * source Components then that will be entered into the Interface table with a
 * transaction type of Delete.
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_Mesg_Token_Tbl Error handler Message Token
 * @param x_Return_Status Return code holding return status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update Bill Info
 */
  PROCEDURE UPDATE_BILL_INFO
  (
    p_batch_id         IN NUMBER
  , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_Status      IN OUT NOCOPY VARCHAR2
  );

  /**
   * This procedure is used by the EGO team to notify that
   * matching of all the uploaded records is over and
   * further processing can be continued.
   * @param p_batch_id Batch Identifier
   * @param p_init_msg_list Message List Initializer Flag
   * @param x_return_status Return Status of the API
   * @param x_Error_Mesg Error Message
   * @param p_debug Debug Flag
   * @param p_output_dir Output Directory
   * @param p_debug_filename Debug File Name
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Matching Complete
  */
  PROCEDURE Matching_Complete
  (
    p_batch_id IN NUMBER
  , p_init_msg_list           IN VARCHAR2
  , x_return_status           IN OUT NOCOPY VARCHAR2
  , x_Error_Mesg              IN OUT NOCOPY VARCHAR2
  , p_debug                   IN  VARCHAR2
  , p_output_dir              IN  VARCHAR2
  , p_debug_filename          IN  VARCHAR2
  );

  /**
   * This procedure is used by the EGO team to notify that
   * matching of all the uploaded records is over and
   * further processing can be continued.
   * @param p_batch_id Batch Identifier
   * @param x_return_status Return Status of the API
   * @param x_Error_Mesg Error Message
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Matching Complete
  */
   PROCEDURE Matching_Complete
  (
    p_batch_id IN NUMBER
  , x_return_status           IN OUT NOCOPY VARCHAR2
  , x_Error_Mesg              IN OUT NOCOPY VARCHAR2
  );

   /**
    * This is the Function for getting the attribute difference.
    * This returns the User Attribute Values for both Source System
    * item and Pdh Item.This function will retrieve the values for
    * both Component Base and Component Extended Attributes.
    * If any of source item or pdh item is null it returns null as
    * attribute values for that item.
    * @param p_batch_id Batch Identifier for the Batch Imported
    * @param p_ss_record_id Source System Reference for the Source System Item/Component
    * @param p_comp_seq_id Component Sequence Id for the Pdh Component if any.
    * @param p_str_type_id Structure Type Id from the Batch Options.
    * @param p_effec_date  Effectivity Date for the component
    * @param p_op_seq_num Operation Sequence Number for the Component
    * @param p_item_id Component Item Id
    * @param p_org_id Organization Id
    * @rep:scope private
    * @rep:lifecycle active
    * @rep:displayname Get Component Attributes Difference
    */

  FUNCTION BOM_GET_COMP_ATTR_DATA
  (
   p_batch_id    NUMBER,
   p_ss_record_id    VARCHAR2,
   p_comp_seq_id   NUMBER,
   p_str_type_id   NUMBER,
   p_effec_date    DATE,
   p_op_seq_num    NUMBER,
   p_item_id       NUMBER,
   p_org_id        NUMBER,
   p_intf_uniq_id  NUMBER
  ) RETURN Bom_Attr_Diff_Table_Type;


FUNCTION get_ref_desgs
  (
    p_batch_id    IN NUMBER
  , p_comp_rec_id IN VARCHAR2
  , p_comp_seq_id IN NUMBER
  , p_mode        IN NUMBER
  , p_effec_date  IN DATE
  , p_op_seq_num  IN NUMBER
  , p_item_id     IN NUMBER
  , p_org_id      IN NUMBER
  )RETURN VARCHAR2;


  /**
   * This procedure does the Value updation for User Attributes.
   * Based on the process_status of the component this API will
   * update the corresponding User Attribute Rows with the component
   * sequence ids and Bill Sequence Ids and set process_flag depending on that
   * of Component.After setting the values it calls the Ext API for User
   * Attribute Bulk Load.
   * @param p_batch_id Batch Identifier for the Batch Imported
   * @param p_transaction_id Transaction Id for the Component
   * @param p_comp_seq_id Component Sequence Id of the Component
   * @param p_bill_seq_id Bill Sequence Id for the Header
   * @param p_call_Ext_Api Flag to check whether to call the Ext API
   * @param x_Mesg_Token_Tbl Error Handlers Message Token Table
   * @param x_Return_Status Return Status after processing
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Update User Attribute Data

   */
 PROCEDURE Update_User_Attr_Data
  (
    p_batch_id           IN NUMBER
  , p_transaction_id     IN NUMBER
  , p_comp_seq_id        IN NUMBER
  , p_bill_seq_id        IN NUMBER
  , p_call_Ext_Api       IN VARCHAR2
  , p_parent_id          IN NUMBER
  , p_org_id             IN NUMBER
  , x_Return_Status      IN OUT NOCOPY VARCHAR2
  , x_Error_Text         IN OUT NOCOPY VARCHAR2
  );

/**
 * This procedure is the starting point for the existing open interface
 * tables being used to create batches.
 * Users will call this API once the data load for a batch is done in the
 * bom interface tables.
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Data Upload Complete
 */

  PROCEDURE DATA_UPLOAD_COMPLETE
  (
    p_batch_id         IN NUMBER
  , x_error_message      OUT NOCOPY VARCHAR2
  , x_return_code        OUT NOCOPY VARCHAR2

  );

 /**
 *This procedure is the starting point for the existing open interface
 *tables being used to create batches.Users will call this API once the data load for a batch is
 *done in the bom interface tables.
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param p_init_msg_list Init Message List Flag
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @param p_output_dir Out Put directory for logging
 * @param p_debug_filename Debug File name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Data Upload Complete
 */
PROCEDURE DATA_UPLOAD_COMPLETE
    (
    p_batch_id               IN NUMBER
    , p_init_msg_list        IN VARCHAR2
    , x_return_status        IN OUT NOCOPY VARCHAR2
    , x_Error_Mesg           IN OUT NOCOPY VARCHAR2
    , p_debug                IN  VARCHAR2
    , p_output_dir           IN  VARCHAR2
    , p_debug_filename       IN  VARCHAR2
    );



/**
 * This procedure is called for importing the structure entities for a batch
 * This API will import data from interface tables and update the
 * production tables.  This API will launch BOM Java Concurrent Program.
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Import Structure Data
 */


  PROCEDURE IMPORT_STRUCTURE_DATA
  (
    p_batch_id              IN NUMBER
  , p_items_import_complete IN VARCHAR2
  , p_callFromJCP           IN VARCHAR2
  , p_request_id            IN NUMBER
  , x_error_message         OUT NOCOPY VARCHAR2
  , x_return_code           OUT NOCOPY VARCHAR2
  );



/**
 * This procedure is called for pre-processing the rows prior to
 * calling the BOM Java Concurrent Program.
 * This API will set the row status to a process_flag value of 5
 * based on batch options for change management to process
 * The pre-process will resolve all the source system to id
 * conversion for batch records.
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Pre-Process Import Rows

 */

  PROCEDURE PRE_PROCESS_IMPORT_ROWS
  (
    p_batch_id         IN NUMBER
  , p_items_import_complete IN VARCHAR2
  , x_error_message      OUT NOCOPY VARCHAR2
  , x_return_code        OUT NOCOPY VARCHAR2
  , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  );

/**
 * This procedure propagates the confirmation status to various structure

 * entities based on item interface tables confirmation status.
 * The match_status could be confirmed, unconfirmed or excluded
 * The transaction boundary for a structure is considered to be
 * structure, first level of its components and the child entities for
 * that level of components.  Unconfirmed rows for any component result
 * in not processing the whole structure.  However exclusion of a component
 * will result in processing
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Pre-Process Import Rows

 */

  PROCEDURE PROPAGATE_CONFIRMATION_STATUS
  (
    p_batch_id         IN NUMBER
  , x_error_message      OUT NOCOPY VARCHAR2
  , x_return_code        OUT NOCOPY VARCHAR2
  );

  /**
 * Concurrent Program Replacement for BMCOIN
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return Code Success or Error
 * @p_organization_id Organization Id for which the import program will run
 * @param p_all_organization All Organizations Option
 * @param p_import_routings Import Routings Option
 * @param p_import_bills Import Bills Option
 * @param p_delete_rows Delete the Processed Rows from Interface Tables Option
 * @param p_batch_id Batch Identifier for processing a set of records
 * @rep:lifecycle active
 * @rep:displayname Pre-Process Import Rows
 */
  PROCEDURE Import_Interface_Rows
  (
    x_err_buffer             OUT NOCOPY      VARCHAR2,
    x_return_code            OUT NOCOPY      VARCHAR2,
    p_organization_id       IN      NUMBER,
    p_all_organization      IN      VARCHAR2,
    p_import_routings       IN      VARCHAR2,
    p_import_bills          IN      VARCHAR2,
    p_delete_rows           IN      VARCHAR2,
    p_batch_id              IN      NUMBER
  );

 /**
  * This is the procedure for updating the Bill with item names
  * for a Pdh Batch Import.If it is a Pdh Batch Import this
  * API will be called and this API will do the id to val
  * conversion  if needed.This will also populate the
  * source_system_reference with the Item Names or Component
  * names.This is for the Structure Import UI to show the
  * details of the batch even for a Pdh Batch Import which will
  * not have any source_system_reference.

  * @param p_batch_id Batch Identifier for the Pdh Batch
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Update Bill for Pdh Import
  */
 PROCEDURE Update_Bill_Val_Id
  (
  p_batch_id               IN NUMBER
, x_return_status            IN OUT NOCOPY VARCHAR2
, x_Error_Mesg              IN OUT NOCOPY VARCHAR2
);

 /*
  * The following functions are used for getting the
  * values of FND_API.G_MISS_NUM,FND_API.G_MISS_CHAR and
  * FND_API.G_MISS_DATE in the SQL query used in
  * Bom Attributes Diff VO Query
  */
 FUNCTION get_G_MISS_NUM RETURN NUMBER;

 FUNCTION get_G_MISS_CHAR RETURN VARCHAR;


 FUNCTION get_G_MISS_DATE RETURN DATE;

  /**
   * This is the procedure for updating the BOM interface
   * tables with the newly confirmed pdh item ids.This API will
   * be called by EGO when the user confirms any source item in a
   * batch and when they propagate the confirmed pdh item ids to
   * subsequent tables.
   * Do We Need This For BOM if the newly confirmed source item
   * is a header item then we need to update Header Interface table with
   * the bill sequence id of the structure of the newly confirmed pdh item
   * We also need to update Bom Components Interface table with this
   * new bill sequence id for all the components of the confirmed source item.

   * If the newly confirmed source item is a component then we need to check whe
ther

   * the corresponding pdh item exist as a component in the target bill,if not t
hen add it

   * as a new component to the target pdh strcuture.
   * @param p_batch_id Batch Identifier for the Imported Batch
   * @param p_ssRef_varray Source System Refence Array for all the source items
confirmed

   * @param p_item_id_varray Item Id array containing the Ids of the confirmed P
DH items


   * @param x_error_message Error Message
   * @param x_return_code Return code holding return status
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Update Confirmed Items
   */

 PROCEDURE Update_Confirmed_Items
  (
    p_batch_id IN NUMBER
  , p_ssRef_varray IN VARCHAR2_VARRAY
  , x_Error_Message IN OUT NOCOPY VARCHAR2
  , x_Return_Status IN OUT NOCOPY VARCHAR2
  );


/****************** Local Procedures Section Ends ******************/
/*
 * The  Method that willl be invoked by JCP
 */

  PROCEDURE Process_Structure_Data
  (
    p_batch_id              IN         NUMBER
  );

/*
* The  Method will return the Primay display name is the internal
* name is *NULL* - used in the UI
* @param p_struct_Internal_Name Structure Internal Name
* @param Returns Structure Name
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Primary Structure name
*/
  FUNCTION Get_Primary_StructureName
  (p_struct_Internal_Name     IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE Check_Change_Options
  (
  p_batch_id    IN NUMBER,
  x_error_code IN OUT NOCOPY VARCHAR2,
  x_Mesg_Token_Tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  );

  PROCEDURE PROCESS_ALL_COMPS_BATCH
  (
     p_batch_id IN NUMBER
   , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_Return_Status         IN OUT NOCOPY VARCHAR2
  );

/*
* The  Method will return the BATCHID sequence to be used for OI Process
* @param Returns Batch ID
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Batch ID
*/
  FUNCTION Get_BatchId
  RETURN NUMBER;

/*
 * This API will delete all the records from all the
 * BOM interface tables for the given batch id.
 * @param p_batch_id  Batch Id for which data is to be deleted
 * @param x_error_mesg Error Message
 * @param x_ret_code Return Code
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Delete Interface Records
 */

 PROCEDURE Delete_Interface_Records
 (
    p_batch_id     IN NUMBER
  , x_Error_Mesg   IN OUT NOCOPY VARCHAR2
  , x_Ret_Code     IN OUT NOCOPY VARCHAR2
 );

 /**
 * Procedure to merge the duplicate records starting with the
 * components and then propagating to the child entities.
 * @param p_batch_id  Batch Id for which data is to be deleted
 * @param x_Ret_Status Return Code
 * @param x_Error_Mesg Error Message
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Merge Duplicate Rows
 */
PROCEDURE Merge_Duplicate_Rows
 (
  p_batch_id    IN NUMBER,
  x_Ret_Status  IN OUT NOCOPY VARCHAR2,
  x_Error_Mesg  IN OUT NOCOPY VARCHAR2
 );
/*
 * Procedure to merge Reference Designators
 * @param p_batch_id  Batch Id for which data is to be deleted
 * @p_comp_seq_id Component Sequence Id
 * @p_comp_name   Component Name
 * @p_comp_ref    Component Source System Reference
 * @p_effec_date  Effectivity Date for the component
 * @p_op_seq      Operation Sequence Number for the component
 * @p_new_effec_date New Effectivity Date for a changed component
 * @p_new_op_seq  New Operation Sequence Number
 * @p_from_unit   From end item unit number
 * @p_from_item_id From end item revision id
 * @p_parent_name Parent Name
 * @p_parent_ref  Parent Source System Reference
 * @x_Ret_Status  Return Status
 * @x_Error_Mesg  Error Message
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Merge Reference Designators
 */

  PROCEDURE Merge_Ref_Desgs
(
 p_batch_id    IN NUMBER,
 p_comp_seq_id IN NUMBER,
 p_comp_name   IN VARCHAR2,
 p_comp_ref    IN VARCHAR2,
 p_effec_date  IN DATE,
 p_op_seq      IN NUMBER,
 p_new_effec_date IN DATE,
 p_new_op_seq  IN NUMBER,
 p_from_unit   IN VARCHAR2,
 p_from_item_id IN NUMBER,
 p_parent_name IN VARCHAR2,
 p_parent_ref  IN VARCHAR2,
 x_Ret_Status  IN OUT NOCOPY VARCHAR2,
 x_Error_Mesg  IN OUT NOCOPY VARCHAR2
);

/*
 * Procedure to merge user attributes duplicate rows
 * @p_batch_id  Batch Id
 * @p_comp_seq  Component Sequence Id
 * @p_comp_name Component Name
 * @p_comp_ref  Component Source System Reference
 * @p_txn_id    Transaction Id
 * @x_Ret_Status Return Status
 * @x_Error_Mesg Error Message
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Merge Component Attributes
 */
PROCEDURE Merge_User_Attrs
(
  p_batch_id    IN NUMBER,
  p_comp_seq IN NUMBER,
  p_comp_name IN VARCHAR2,
  p_comp_ref    IN VARCHAR2,
  p_txn_id      IN NUMBER,
  p_par_name    IN VARCHAR2,
  p_par_ref     IN VARCHAR2,
  p_org_id      IN NUMBER,
  p_org_code    IN VARCHAR2,
  x_Ret_Status  IN OUT NOCOPY VARCHAR2,
  x_Error_Mesg  IN OUT NOCOPY VARCHAR2
);
/*
 * Procedure to update the interface records
 * with process_flag = 5 when change options are
 * set in the batch or there are change policy for the
 * structure
 * @param p_batch_id Batch Identifier
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Porcess CM Options
 */
PROCEDURE Process_CM_Options(p_batch_id IN NUMBER);

PROCEDURE Get_Item_Security_Predicate
   (
    p_object_name IN   VARCHAR2,
    p_party_id    IN   VARCHAR2,
    p_privilege_name  IN   VARCHAR2,
    p_table_alias     IN   VARCHAR2,
    x_security_predicate  OUT NOCOPY VARCHAR2
   );
FUNCTION Get_Item_Matches
    (
     p_batch_id     IN NUMBER,
     p_ss_ref       IN VARCHAR2
    )
RETURN VARCHAR2;

END Bom_Import_Pub; -- Package spec

/
