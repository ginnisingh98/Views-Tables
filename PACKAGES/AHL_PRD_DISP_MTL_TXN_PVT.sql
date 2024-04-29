--------------------------------------------------------
--  DDL for Package AHL_PRD_DISP_MTL_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISP_MTL_TXN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVDMTS.pls 120.1 2005/06/10 13:53:36 appldev  $ */


---------------------------------
-- Define Record Type for Node --
---------------------------------
TYPE Disp_Mtl_Txn_Rec_Type IS RECORD (
      	DISP_MTL_TXN_ID  NUMBER,
	OBJECT_VERSION_NUMBER	NUMBER,
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATED_BY		NUMBER(15)	,
	CREATION_DATE		DATE		,
	CREATED_BY		NUMBER(15)	,
	LAST_UPDATE_LOGIN	NUMBER(15),
	DISPOSITION_ID          NUMBER   	,
	WO_MTL_TXN_ID	        NUMBER,
	QUANTITY          	NUMBER    ,
	UOM       		VARCHAR2(3)    ,
        ATTRIBUTE_CATEGORY      VARCHAR2(30)    ,
        ATTRIBUTE1              VARCHAR2(150)   ,
        ATTRIBUTE2              VARCHAR2(150)   ,
        ATTRIBUTE3              VARCHAR2(150)   ,
        ATTRIBUTE4              VARCHAR2(150)   ,
        ATTRIBUTE5              VARCHAR2(150)   ,
        ATTRIBUTE6              VARCHAR2(150)   ,
        ATTRIBUTE7              VARCHAR2(150)   ,
        ATTRIBUTE8              VARCHAR2(150)   ,
        ATTRIBUTE9              VARCHAR2(150)   ,
        ATTRIBUTE10             VARCHAR2(150)   ,
        ATTRIBUTE11             VARCHAR2(150)   ,
        ATTRIBUTE12             VARCHAR2(150)   ,
        ATTRIBUTE13             VARCHAR2(150)   ,
        ATTRIBUTE14             VARCHAR2(150)   ,
        ATTRIBUTE15             VARCHAR2(150)
        );

TYPE disp_mtxn_assoc_rec_type IS RECORD (
    DISPOSITION_ID	             NUMBER,
    INVENTORY_ITEM_ID	         NUMBER,
    ITEM_ORG_ID		             NUMBER,
    ITEM_NUMBER	                 VARCHAR(40),
    ITEM_GROUP_ID	             NUMBER,
    ITEM_GROUP_NAME	             VARCHAR(80),
    SERIAL_NUMBER	             VARCHAR2(30),
    LOT_NUMBER	                 MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
    IMMEDIATE_DISPOSITION_CODE	 VARCHAR2(30),
    IMMEDIATE_TYPE	             VARCHAR(150),
    SECONDARY_DISPOSITION_CODE	 VARCHAR2(30),
    SECONDARY_TYPE	             VARCHAR(150),
    STATUS_CODE	                 VARCHAR2(30),
    STATUS	                     VARCHAR(80),
    QUANTITY	                 NUMBER,
    UOM	                         VARCHAR2(3),
    ASSOC_QTY                    NUMBER,
    ASSOC_UOM                    VARCHAR2(3),
    UNTXNED_QTY                  NUMBER,
    UNTXNED_UOM                 VARCHAR2(3)
);
TYPE Disp_Mtl_Txn_Tbl_Type IS TABLE OF Disp_Mtl_Txn_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Disp_Mtxn_Assoc_Tbl_Type IS TABLE OF Disp_Mtxn_assoc_Rec_Type
   INDEX BY BINARY_INTEGER;
------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Process_Disp_Mtl_Txn
--  Type        : Private
--  Function    : Creates and updates the disposition material transactions.
--  Pre-reqs    :
--  Parameters  :
--
--  Process_Disp_Mtl_Txn Parameters:
--       p_x_disp_mtl_txn_tbl IN OUT NOCOPY the material transaction +
--   disposition records.
--
--  End of Comments.

PROCEDURE Process_Disp_Mtl_Txn (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_module		  IN           VARCHAR2 := 'JSP',
    p_x_disp_mtl_txn_tbl  IN OUT NOCOPY   AHL_PRD_DISP_MTL_TXN_PVT.Disp_Mtl_Txn_Tbl_Type);


------------------------
-- Start of Comments --
--  Procedure name    : Get_Disp_For_Mtl_Txn
--  Type        : Private
--  Function    : Fetch the matching dispositions for given material txn
--  Pre-reqs    :
--  Parameters  : p_wo_mtl_txn_id: The material transaction id
--                x_disp_list_tbl: returning list of dispositions
--
--
--  End of Comments.
PROCEDURE Get_Disp_For_Mtl_Txn (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_wo_mtl_txn_id       IN NUMBER,
    x_disp_list_tbl    OUT NOCOPY  disp_mtxn_assoc_tbl_type);

----------------------
--  Function name    : Calculate_Txned_Qty
--  Type        : Private
--  Function    : Calculates the mtl transactions qtys txned for a disposition.
--  Pre-reqs    :
--  Parameters  :
--
--  Calculate_Txned_Qty parameters:
--       p_disposition_id is the disposition_id
--    Returns: qty of the mtl transaction that's assoc to disp. can be
--  >0 or =0
--
--  End of Comments.

FUNCTION Calculate_Txned_Qty(
     p_disposition_id  IN NUMBER)
 RETURN NUMBER;
--Qty txned

End AHL_PRD_DISP_MTL_TXN_PVT;


 

/
