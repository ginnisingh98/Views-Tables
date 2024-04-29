--------------------------------------------------------
--  DDL for Package AHL_PRD_MTLTXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_MTLTXN_PVT" AUTHID CURRENT_USER AS
/*$Header: AHLVMTXS.pls 120.4.12010000.4 2008/11/26 11:28:43 jkjain ship $*/
G_AHL_SERVICEABLE_CONDITION CONSTANT NUMBER := FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_SERVICABLE');
G_AHL_UNSERVICEABLE_CONDITION   CONSTANT NUMBER := FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_UNSERVICABLE');
G_AHL_MRB_CONDITION         CONSTANT NUMBER := FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_MRB');

    Type Ahl_Mtltxn_Rec_Type Is Record (
        Ahl_mtltxn_Id                   NUMBER,
        Workorder_Id                    NUMBER,
        Workorder_Name                  VARCHAR2(80),
        Workorder_Status                VARCHAR2(80),
        Workorder_Status_Code                   VARCHAR2(30),
        Inventory_Item_Id               NUMBER,
        Inventory_Item_Segments             VARCHAR2(240),
        Inventory_Item_Description              VARCHAR2(240),
        Item_Instance_Number                    varchar2(80),
        Item_Instance_ID                        NUMBER,
        Revision                    VARCHAR2(3),
        Organization_Id                 NUMBER,
        Condition                   NUMBER,
        Condition_desc                  VARCHAR2(80),
        Subinventory_Name               VARCHAR2(10),
        Locator_Id                  NUMBER,
        Locator_Segments                VARCHAR2(240),
        Quantity                    NUMBER,
	    -- JKJAIN FP ER # 6436303 start
		Net_Total_qty                           NUMBER,
		-- JKJAIN FP ER # 6436303 ends
        Net_Quantity                            Number,
        Uom                     VARCHAR2(3),
        Uom_Desc                    VARCHAR2(25),
        Transaction_Type_Id             NUMBER,
        Transaction_Type_Name               varchar2(240),
        Transaction_Reference               VARCHAR2(240),
        Wip_Entity_Id                   NUMBER,
        Operation_Seq_Num               NUMBER,
        Serial_Number                   VARCHAR2(30),
        Lot_Number                  mtl_lot_numbers.lot_number%TYPE,
        Reason_Id                   NUMBER,
        Reason_Name                 VARCHAR2(240),
        Problem_Code                    VARCHAR2(30),
        Problem_Code_Meaning                VARCHAR2(80),
        Target_Visit_Id                 NUMBER,
        Sr_Summary                  VARCHAR2(80),
        Qa_Collection_Id                NUMBER,
        Workorder_operation_Id          NUMBER,
        Transaction_Date                DATE,
        recepient_id                    NUMBER,
        recepient_name                  VARCHAR2(60),
        disposition_id                  NUMBER,
        disposition_name                VARCHAR2(60),
        -- added for FP bug# 6032494.
        move_to_project_flag            VARCHAR2(1),
        visit_locator_flag              VARCHAR2(1),
        -- added for FP bug# 5903318.
        create_wo_option                        VARCHAR2(30),
        ATTRIBUTE_CATEGORY                      VARCHAR2(30),
        ATTRIBUTE1                              VARCHAR2(150),
        ATTRIBUTE2                              VARCHAR2(150),
        ATTRIBUTE3                              VARCHAR2(150),
        ATTRIBUTE4                              VARCHAR2(150),
        ATTRIBUTE5                              VARCHAR2(150),
        ATTRIBUTE6                              VARCHAR2(150),
        ATTRIBUTE7                              VARCHAR2(150),
        ATTRIBUTE8                              VARCHAR2(150),
        ATTRIBUTE9                              VARCHAR2(150),
        ATTRIBUTE10                             VARCHAR2(150),
        ATTRIBUTE11                             VARCHAR2(150),
        ATTRIBUTE12                             VARCHAR2(150),
        ATTRIBUTE13                             VARCHAR2(150),
        ATTRIBUTE14                             VARCHAR2(150),
        ATTRIBUTE15                             VARCHAR2(150)
        );

    Type  Prd_Mtltxn_Criteria_Rec Is Record
    (
        JOB_NUMBER                      ahl_workorders.WORKORDER_NAME%TYPE,
        PRIORITY                        varchar2(30),
        ORGANIZATION_NAME               ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME%TYPE,
        CONCATENATED_SEGMENTS           MTL_SYSTEM_ITEMS_B_KFV.CONCATENATED_SEGMENTS %TYPE,
        REQUESTED_DATE_FROM             DATE,
        REQUESTED_DATE_TO               DATE,
        INCIDENT_NUMBER                 CS_INCIDENTS_ALL.INCIDENT_NUMBER%TYPE,
        VISIT_NUMBER                    NUMBER,
        DEPARTMENT_NAME                 BOM_DEPARTMENTS.DESCRIPTION%TYPE,
        DISPOSITION_NAME                AHL_PRD_DISPOSITIONS_V.IMMEDIATE_TYPE%TYPE,
        TRANSACTION_TYPE                NUMBER
    );


    Type Ahl_Mtltxn_Tbl_Type Is Table of Ahl_Mtltxn_Rec_Type index by BINARY_INTEGER;


    Type Ahl_Mtl_Txn_Id_tbl is Table of NUMBER index by BINARY_INTEGER;


    PROCEDURE PERFORM_MTL_TXN
        (
        p_api_version        IN            NUMBER     := 1.0,
        p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
        p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
        p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
        p_default            IN            VARCHAR2   := FND_API.G_FALSE,
        p_module_type        IN            VARCHAR2   := NULL,
        p_create_sr          IN            VARCHAR2,
        p_x_ahl_mtltxn_tbl   IN OUT NOCOPY Ahl_Mtltxn_Tbl_Type,
        x_return_status      OUT NOCOPY           VARCHAR2,
        x_msg_count          OUT NOCOPY           NUMBER,
        x_msg_data           OUT NOCOPY           VARCHAR2
        );

    PROCEDURE VALIDATE_TXN_REC
        (
        p_x_ahl_mtltxn_rec       IN OUT NOCOPY Ahl_Mtltxn_Rec_Type,
        x_item_instance_id   OUT NOCOPY        NUMBER,
        x_eam_item_type_id   OUT NOCOPY        NUMBER,
        x_return_status      OUT NOCOPY           VARCHAR2,
        x_msg_count          OUT NOCOPY           NUMBER,
        x_msg_data           OUT NOCOPY           VARCHAR2
        );

    /*
    PROCEDURE INSERT_MTL_TXN_TEMP
        (
        p_api_version        IN            NUMBER     := 1.0,
        p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
        p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
        p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
        p_default            IN            VARCHAR2   := FND_API.G_FALSE,
        p_module_type        IN            VARCHAR2   := NULL,
        p_x_ahl_mtltxn_rec   IN OUT NOCOPY Ahl_Mtltxn_Rec_Type,
        x_txn_Hdr_Id         OUT NOCOPY        NUMBER,
        x_txn_Tmp_Id         OUT NOCOPY        NUMBER,
        x_return_status      OUT NOCOPY           VARCHAR2,
        x_msg_count          OUT NOCOPY           NUMBER,
        x_msg_data           OUT NOCOPY           VARCHAR2
        );
    */

        PROCEDURE GET_MTL_TRANS_RETURNS
        (
                p_api_version                   IN            NUMBER     := 1.0,
                p_init_msg_list                 IN            VARCHAR2   := FND_API.G_FALSE,
                p_commit                        IN            VARCHAR2   := FND_API.G_FALSE,
                p_validation_level              IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
                p_default                       IN            VARCHAR2   := FND_API.G_FALSE,
                p_module_type                   IN            VARCHAR2   := NULL,
                x_return_status                 OUT NOCOPY           VARCHAR2,
                x_msg_count                     OUT NOCOPY           NUMBER,
                x_msg_data                      OUT NOCOPY           VARCHAR2,
                P_prd_Mtltxn_criteria_rec       IN      Prd_Mtltxn_criteria_rec,
                x_ahl_mtltxn_tbl                IN OUT NOCOPY Ahl_Mtltxn_Tbl_Type
        );


    /* This funciton will get the issued quantity form the trnasactions table*/
    function GET_ISSUED_QTY(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER, P_WORKORDER_OP_ID IN NUMBER) RETURN NUMBER;

    /* This function will get the onhand quantity for and item */
    function GET_ONHAND(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER) RETURN NUMBER;

        /* This function will get the onhand quantity for and item */
    function GET_WORKORD_LEVEL_QTY(p_wid  IN NUMBER,p_item_id IN NUMBER,p_org_id IN NUMBER,p_lotnum IN VARCHAR2,p_rev IN VARCHAR2,p_serial_number IN VARCHAR2) RETURN NUMBER;
	 -- JKJAIN FP ER # 6436303 start
	 -- JKJAIN removed p_lotnum,p_rev,p_serial_number for Bug # 7587902
 	         --------------------------------------------------------------------------------------
 	         -- Function for returning net quantity of material available with
 	         -- a workorder.
 	         -- Net Total Quantity = Total Quantity Issued - Total quantity returned
 	         -- Balaji added this function for OGMA ER # 5948868.
 	         --------------------------------------------------------------------------------------
 	         function GET_WORKORD_NET_QTY(
 	                       p_wid  IN NUMBER,
 	                       p_item_id IN NUMBER,
 	                       p_org_id IN NUMBER
 	         ) RETURN NUMBER;
 	-- JKJAIN FP ER # 6436303 - end

END AHL_PRD_MTLTXN_PVT  ;

/
