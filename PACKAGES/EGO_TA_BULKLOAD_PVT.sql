--------------------------------------------------------
--  DDL for Package EGO_TA_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_TA_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVTABS.pls 120.0.12010000.3 2010/04/26 13:31:19 ccsingh noship $ */
-- This is the package which will get called from Concurent program
-- In this we have API Import_TA_Intf which will do :
-- 1.BULK_VALIDATION and set the process flags in interface table accordingly.
--   Here we have to do all the validation which we can do at table level to
--   restrict the records IN PL-SQL TABLE.
-- 2.Load the relevant records in PL-SQL Table.
-- 3.Call to main API PROCESS_TA(PL-SQL table).

------------------------------------------------------------------------------------
          --  Declaration of associated array for TA Interface Table   --
------------------------------------------------------------------------------------
SUBTYPE TA_Intf_Tbl is ego_metadata_pub.TA_Intf_Tbl;

---------------------------------------------------------------
   -- Global Variables and Constants --
---------------------------------------------------------------
 G_BO_IDENTIFIER      CONSTANT VARCHAR2(30) := 'ICC';
 G_ENTITY_IDENTIFIER  CONSTANT VARCHAR2(30) := 'ICC_TA';
 G_TABLE_NAME         CONSTANT VARCHAR2(30) := 'EGO_TRANS_ATTRS_VERS_INTF';
 G_TOKEN_TBL    	           Error_Handler.Token_Tbl_Type;

 G_PKG_NAME           CONSTANT VARCHAR2(30)   := 'EGO_TA_BULKLOAD_PVT';
 G_APP_NAME           CONSTANT VARCHAR2(3)   := 'EGO';


---------------------------------------------------------------
   -- Transaction Type.  --
---------------------------------------------------------------

 G_CREATE                       CONSTANT  VARCHAR2(10) := 'CREATE';
 G_UPDATE                       CONSTANT  VARCHAR2(10) := 'UPDATE';
 G_DELETE                       CONSTANT  VARCHAR2(10) := 'DELETE';
 G_SYNC                         CONSTANT  VARCHAR2(10) := 'SYNC';

---------------------------------------------------------------
   -- API Return statuses. --
---------------------------------------------------------------

 G_RET_STS_SUCCESS              CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
 G_RET_STS_ERROR                CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
 G_RET_STS_UNEXP_ERROR          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
 G_MISS_CHAR                    CONSTANT  VARCHAR2(1)  := FND_API.G_MISS_CHAR;
 G_MISS_NUM                     CONSTANT  NUMBER       := FND_API.G_MISS_NUM;

---------------------------------------------------------------
   -- WHO Columns   --
---------------------------------------------------------------

 G_USER_ID                                NUMBER       :=  FND_GLOBAL.User_Id;
 G_LOGIN_ID                               NUMBER       :=  FND_GLOBAL.Login_Id;
 G_APPLICATION_ID                         NUMBER;
 G_PROG_APPL_ID                 CONSTANT  NUMBER       :=  FND_GLOBAL.PROG_APPL_ID;
 G_PROGRAM_ID                   CONSTANT  NUMBER       :=  FND_GLOBAL.CONC_PROGRAM_ID;
 G_REQUEST_ID                   CONSTANT  NUMBER       :=  FND_GLOBAL.CONC_REQUEST_ID;

---------------------------------------------------------------
   -- Data Types for Attribute--
---------------------------------------------------------------

 G_CHAR_DATA_TYPE               CONSTANT  VARCHAR2(1)  := 'C';
 G_NUMBER_DATA_TYPE             CONSTANT  VARCHAR2(1)  := 'N';
 G_DATE_DATA_TYPE               CONSTANT  VARCHAR2(1)  := 'X';
 G_DATE_TIME_DATA_TYPE          CONSTANT  VARCHAR2(1)  := 'Y';

---------------------------------------------------------------
   -- Process Status flags--
---------------------------------------------------------------
 G_PROCESS_RECORD               CONSTANT  NUMBER       := 1;
 G_ERROR_RECORD                 CONSTANT  NUMBER       := 3;
 G_SUCCESS_RECORD               CONSTANT  NUMBER       := 7;

 G_EGO_MD_API                   CONSTANT  NUMBER       := 1;
 G_EGO_MD_INTF                  CONSTANT  NUMBER       := 2;
 G_FLOW_TYPE                              NUMBER       := G_EGO_MD_API;

---------------------------------------------------------------
   -- ERROR Handling--
---------------------------------------------------------------
 G_MESSAGE_NAME                           VARCHAR2(100);
 G_MESSAGE_TEXT                           VARCHAR2(2000);


--  ============================================================================
--  Name        : Import_TA_intf
--  Description : This is the main API which will do above tasks and make a call
--                to EGO_TRANS_ATTR_PVT.Process_TA.
--  Parameters  :
--  Parameters:
--        IN    :
--                p_api_version                IN           NUMBER
--                Active API version number
--
--                p_set_process_id             IN           NUMBER
--                Batch Id to be processed
--
--				        p_item_catalog_group_id      IN           NUMBER
--                ICC id for which the import has to process.
--
--                p_icc_version_number_intf    IN           NUMBER
--                ICC version number which user is providing in interface table
--
--                p_icc_version_number_act     IN           NUMBER
--                After resolving sync what is the actual version number in targer sys
--
--        OUT    :
--                x_return_status              OUT NOCOPY   VARCHAR2
--                Used to get status of a procedure,Successful or not
--
--                x_return_msg                 OUT NOCOPY VARCHAR2
--                Error Message to be return.

--  ============================================================================

PROCEDURE Import_TA_Intf(
        p_api_version             IN         NUMBER,
        p_set_process_id          IN         NUMBER,
        p_item_catalog_group_id   IN         NUMBER,
        p_icc_version_number_intf IN         NUMBER,
        p_icc_version_number_act  IN         NUMBER,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_return_msg              OUT NOCOPY VARCHAR2);

--  ============================================================================
--  Name        : Initialize
--  Description : This will intialize values in interface table Transaction_id
--                and set transaction_name to UPPER.
--                Addtion to that set G_APPLICATION_ID also
--
--  Parameters  :
--        IN    :
--                p_set_process_id     IN      Number
--                Batch Id to be processed
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.


--  ============================================================================

PROCEDURE Initialize(
        p_set_process_id IN         NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2);

--  ============================================================================
--  Name        : Bulk_Validate_Trans_Attrs
--  Description : This will Validate common things at table level to restrict
--                the no of records from loading in pl-sql table
--  Parameters  :
--        IN    :
--                p_set_process_id     IN      Number
--                Batch Id to be processed

--  ============================================================================

PROCEDURE Bulk_Validate_Trans_Attrs (
        p_set_process_id   IN         NUMBER);

--  ============================================================================
--  Name        : Bulk_Validate_Trans_Attrs_ICC
--  Description : This validate things specific to ICC ID and ICC version
--                only.
--  Parameters  :
--        IN    :
--                p_set_process_id     IN      Number
--                Batch Id to be processed
--
--                p_item_catalog_group_id      IN            NUMBER
--                ICC id for which the import has to process.
--
--                p_item_catalog_group_name    IN            VARCHAR2
--                ICC name for value to ID conversion.
--
--  ============================================================================

PROCEDURE Bulk_Validate_Trans_Attrs_ICC (
        p_set_process_id          IN         NUMBER,
        p_item_catalog_group_id   IN         NUMBER,
        p_item_catalog_group_name IN         VARCHAR2);



--  ============================================================================
--  Name        : Value_to_Id
--  Description : This will convert value to id at table level.
--
--  Parameters  :
--        IN    :
--                p_set_process_id     IN      Number
--                Batch Id to be processed
--  ============================================================================
PROCEDURE Value_to_Id(
        p_set_process_id  IN            NUMBER);


--  ============================================================================
--  Name        : Load_Trans_Attrs_recs
--  Description : This procedure will be used to load the PL-SQL records
--
--  Parameters  :
--        IN    :
--                p_set_process_id             IN            Number
--                Batch Id to be processed
--
--                x_ta_intf_tbl                IN OUT NOCOPY TA_Intf_Tbl
--                inft type table after loading the records.
--
--				  p_item_catalog_group_id      IN            NUMBER
--                ICC id for which the import has to process.
--
--                p_icc_version_number_intf    IN            NUMBER
--                ICC version number which user is providing in interface table
--
--                p_icc_version_number_act     IN            NUMBER
--                After resolving sync what is the actual version number in targer sys
--
--        OUT    :
--                x_return_status              OUT NOCOPY    VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--                x_return_msg                 OUT NOCOPY    VARCHAR2
--
--  ============================================================================

PROCEDURE Load_Trans_Attrs_recs(
        p_set_process_id          IN            NUMBER,
        p_item_catalog_group_id   IN            NUMBER,
        p_icc_version_number_intf IN            NUMBER,
        p_icc_version_number_act  IN            NUMBER,
        x_ta_intf_tbl             IN OUT NOCOPY TA_Intf_Tbl,
        x_return_status           OUT    NOCOPY VARCHAR2,
        x_return_msg              OUT    NOCOPY VARCHAR2) ;

--  ============================================================================
--  Name        : Convert_intf_rec_to_api_rec
--  Description : This procedure will be used to convet interface table  type
--                to production table type for calling create/upd/del/rel api's
--  Parameters  :
--       IN     : p_ta_intf_tbl       IN      TA_Intf_Tbl
--                Inteface table pl-sql record  which needs to be
--                converted to prod rec type to call create/update/del API's.
--
--        OUT    :
--                x_ego_ta_tbl         OUT     EGO_TRAN_ATTR_tbl
--                Original production type pl-sql recrod
--  ============================================================================


PROCEDURE Convert_intf_rec_to_api_rec (
        p_ta_intf_tbl      IN            TA_Intf_Tbl ,
        x_ego_ta_tbl       OUT NOCOPY    EGO_TRAN_ATTR_TBL) ;


--  =================================================================================
--  Name        : Process_Trans_Attrs
--  Description : This is the main API which will call transact_TA for final transaciton.
--                This will get called from public api as well.
--
--  Parameters:
--        IN    :
--                p_api_version                IN                 NUMBER
--                Active API version number
--
--                p_ta_intf_tbl                IN OUT NOCOPY      TA_Intf_Tbl
--                Table instance having record of the type TA_Intf_Tbl
--
--				        p_item_catalog_group_id      IN                 NUMBER
--                ICC id for which the import has to process.
--
--                p_icc_version_number_intf    IN                 NUMBER
--                ICC version number which user is providing in interface table
--
--                p_icc_version_number_act     IN                 NUMBER
--                After resolving sync what is the actual version number in targer sys
--
--
--
--
--        OUT    :
--                x_return_status              OUT NOCOPY         VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_return_msg                 OUT NOCOPY         VARCHAR2
--
--  =================================================================================

PROCEDURE Process_Trans_Attrs (
           p_api_version             IN                  NUMBER,
           p_ta_intf_tbl             IN OUT NOCOPY       TA_Intf_Tbl,
           p_item_catalog_group_id   IN                  NUMBER,
           p_icc_version_number_intf IN                  NUMBER,
           p_icc_version_number_act  IN                  NUMBER,
           x_return_status           OUT NOCOPY          VARCHAR2,
           x_return_msg              OUT NOCOPY          VARCHAR2) ;


--  =================================================================================
--  Name        : Construct_Trans_Attrs
--  Description : This is same as value to id conversion with Initialize. This
--                is for those who are coming with public API
--
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_ta_intf_tbl       IN OUT NOCOPY      TA_Intf_Tbl
--                Table instance having record of the type TA_Intf_Tbl

--
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.

--                x_return_msg           OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE Construct_Trans_Attrs(
           p_api_version      IN               NUMBER,
           p_ta_intf_tbl      IN OUT NOCOPY    TA_Intf_Tbl,
           x_return_status    OUT NOCOPY       VARCHAR2,
           x_return_msg       OUT NOCOPY       VARCHAR2) ;

--  =================================================================================
--  Name        : Validate_Trans_Attrs
--  Description : This has same validation which we are doing in  bulk validation.
--                Again this is for those who are coming with public API
--
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_ta_intf_tbl       IN OUT NOCOPY      TA_Intf_Tbl
--                Table instance having record of the type TA_Intf_Tbl

--
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--                x_return_msg         OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE  Validate_Trans_Attrs(
           p_api_version      IN               NUMBER,
           p_ta_intf_tbl      IN OUT NOCOPY    TA_Intf_Tbl,
           x_return_status    OUT NOCOPY       VARCHAR2,
           x_return_msg       OUT NOCOPY       VARCHAR2);

--  =================================================================================
--  Name        : Transact_Trans_Attrs
--  Description : This will handle the main transactions, Create, Update Delete.
--
--  Parameters:
--        IN    :
--                p_api_version        IN      NUMBER
--                Active API version number
--
--                p_ta_intf_rec       IN OUT NOCOPY      ego_trans_attrs_vers_intf%ROWTYPE
--                Table instance having record of the type TA_Intf_Tbl
--
--
--
--
--        OUT    :
--                x_return_status      OUT NOCOPY VARCHAR2
--                Used to get status of a procedure, whether it executed
--                Successfully or not.
--
--
--                x_return_msg         OUT NOCOPY VARCHAR2
--
--  =================================================================================

PROCEDURE  Transact_Trans_Attrs(
           p_api_version      IN               NUMBER,
           p_ta_intf_rec      IN OUT NOCOPY    ego_trans_attrs_vers_intf%ROWTYPE,
           x_return_status    OUT NOCOPY       VARCHAR2,
           x_return_msg       OUT NOCOPY       VARCHAR2);

--  ============================================================================
--  Name        : Update_Intf_Trans_Attrs
--  Description : This is responsible for updating the status as error or success,
--                after transact_ta
--  Parameters  :
--       IN     : p_ta_intf_tbl       IN OUT NOCOPY      TA_Intf_Tbl
--                Inteface table pl-sql record  which will update the status of
--                records after transact_ta.
--
--
--        OUT    :
--                x_return_status     OUT     VARCHAR2
--                Successfully or not.
--
--                x_return_msg     OUT     VARCHAR2
--                return message for status.
--
--  ============================================================================

PROCEDURE Update_Intf_Trans_Attrs(
           p_ta_intf_tbl      IN OUT NOCOPY TA_Intf_Tbl,
           x_return_status    OUT NOCOPY    VARCHAR2,
           x_return_msg       OUT NOCOPY    VARCHAR2);

--  ============================================================================
--  Name        : Update_Intf_Err_Recs_Trans_Attrs
--  Description : This is responsible for updating the status as error or success,
--                after transact_ta
--  Parameters  :
--       IN     : p_set_process_id              IN      NUMBER
--                Batch Id.
--
--                p_item_catalog_group_id       IN      NUMBER
--                ICC id
--
--                p_icc_version_number_intf     IN      NUMBER
--                Interface table version number
--
--
--        OUT    :
--                x_return_status               OUT NOOCOPY      VARCHAR2
--                Successfully or not.
--
--               x_return_msg                   OUT NOCOPY          VARCHAR2
--               return message for status.
--
--  ============================================================================


PROCEDURE Update_Intf_Err_Trans_Attrs(
           p_set_process_id          IN                  NUMBER,
           p_item_catalog_group_id   IN                  NUMBER,
           p_icc_version_number_intf IN                  NUMBER,
           x_return_status           OUT NOCOPY          VARCHAR2,
           x_return_msg              OUT NOCOPY          VARCHAR2);

--  ============================================================================
--  Name        : Delete_Processed_Trans_Attrs
--  Description : This will be called by main API of concurrent program for deleting,
--                processed recrods
--  Parameters  :
--       IN     : p_set_process_id       IN       NUMBER
--                Batch Id
--
--        OUT    :
--                x_return_status        OUT NOOCOPY      VARCHAR2
--                Successfully or not.
--
--                x_return_msg           OUT NOOCOPY      VARCHAR2
--                message for return status.
--
--  ============================================================================


PROCEDURE Delete_Processed_Trans_Attrs(
           p_set_process_id          IN                  NUMBER,
           x_return_status           OUT NOCOPY          VARCHAR2,
	   x_return_msg              OUT NOCOPY          VARCHAR2
           ) ;

--  ============================================================================
--  Name        : Check_TA_IS_INVALID
--  Description : This is the same Function written in EGO_TRANSACTION_ATTR_PVT
--                but there they are only handling Draft versions and here
--                we are creating released TA.
--  Parameters  :
--       IN     : p_item_cat_group_id       IN       NUMBER
--                ICC Id
--
--                p_icc_version_number      IN       NUMBER
--                ICC version number
--
--                p_attr_id                 IN       NUMBER
--                Attribute Id
--
--                p_attr_name               IN       VARCHAR2
--                Attribute Internal Name
--
--                p_attr_disp_name          IN       VARCHAR2
--                Attribute Display Name
--
--                p_attr_sequence           IN       NUMBER
--                Attribute Sequence

--  ============================================================================


FUNCTION Check_TA_IS_INVALID (
        p_item_cat_group_id  IN NUMBER,
        p_icc_version_number IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_name          IN VARCHAR2  DEFAULT NULL ,
        p_attr_disp_name     IN VARCHAR2  DEFAULT NULL ,
        p_attr_sequence      IN NUMBER    DEFAULT NULL
)
RETURN BOOLEAN;

END EGO_TA_BULKLOAD_PVT ;

/
