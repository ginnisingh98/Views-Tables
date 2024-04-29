--------------------------------------------------------
--  DDL for Package CSD_REPAIRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIRS_PUB" AUTHID CURRENT_USER as
    /* $Header: csdpdras.pls 120.22.12010000.4 2010/05/06 01:30:03 takwong ship $ */
    /*#
    * This is the public interface for managing a repair order. It allows
    * creation  of repair order for a service request.
    * @rep:scope public
    * @rep:product CSD
    * @rep:displayname  Repair Order
    * @rep:lifecycle active
    * @rep:category BUSINESS_ENTITY CSD_REPAIR_ORDER
    */

    --
    -- Package name     : CSD_REPAIRS_PUB
    -- Purpose          : This package contains the public APIs for creating,
    --                    updating repair orders.
    -- History          :
    -- Version       Date       Name        Description
    -- 115.0         11/17/99   pkdas       Created.
    -- 115.1         12/18/99   pkdas
    -- 115.2         01/04/00   pkdas
    -- 115.3         01/18/00   pkdas       Added DATE_CLOSED to REPLN_Rec_Type
    -- 115.4         02/09/00   pkdas       Added p_REPAIR_LINE_ID as IN parameter in the
    --                                      Create_Repairs procedure.
    --                                      Added p_REPAIR_NUMBER as OUT parameter in the
    --                                      Create_Repairs procedure.
    -- 115.5         02/29/00   pkdas       Changed the procedure name
    --                                      Create_Repairs -> Create_Repair_Order
    --                                      Update_Repairs -> Update_Repair_Order
    --                                      Added p_validation_level to Create_Repair_Order and
    --                                      Update_Repair_Order
    -- 115.6         11/30/01   travi       Added AUTO_PROCESS_RMA,OBJECT_VERSION_NUMBER and REPAIR_MODE
    -- 115.7         01/14/02   travi       Added Item_REVISION column
    -- 115.11        05/02/02   askumar     Added RO_GROUP_ID and RO_TXN_STATUS
    --                                      to REPLN_REC_type for 11.5.7.1
    --                                      development
    -- 115.10        04/28/2004 saupadhy    Added item supercession_inv_item_id to repln_rec_type
    --
    -- 115.23        05/20/2005 vparvath    R12 development: adding new api update_ro_status

    TYPE REPLN_Rec_Type IS RECORD(
        REPAIR_NUMBER       VARCHAR2(30) := FND_API.G_MISS_CHAR,
        INCIDENT_ID         NUMBER := FND_API.G_MISS_NUM,
        INVENTORY_ITEM_ID   NUMBER := FND_API.G_MISS_NUM,
        CUSTOMER_PRODUCT_ID NUMBER := FND_API.G_MISS_NUM,
        UNIT_OF_MEASURE     VARCHAR2(3) := FND_API.G_MISS_CHAR,
        REPAIR_TYPE_ID      NUMBER := FND_API.G_MISS_NUM,
        -- RESOURCE_GROUP Added by Vijay 10/28/2004
        RESOURCE_GROUP            NUMBER := FND_API.G_MISS_NUM,     -- swai: bug 7565999, revert change for FP bug#5197546
        RESOURCE_ID               NUMBER := FND_API.G_MISS_NUM,
        PROJECT_ID                NUMBER := FND_API.G_MISS_NUM,
        TASK_ID                   NUMBER := FND_API.G_MISS_NUM,
        UNIT_NUMBER               VARCHAR2(30) := FND_API.G_MISS_CHAR, -- rfieldma, prj integration
        CONTRACT_LINE_ID          NUMBER := FND_API.G_MISS_NUM,
        AUTO_PROCESS_RMA          VARCHAR2(1) := FND_API.G_MISS_CHAR,
        REPAIR_MODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
        OBJECT_VERSION_NUMBER     NUMBER := FND_API.G_MISS_NUM,
        ITEM_REVISION             VARCHAR2(3) := FND_API.G_MISS_CHAR,
        INSTANCE_ID               NUMBER := FND_API.G_MISS_NUM,
        STATUS                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
        STATUS_REASON_CODE        VARCHAR2(30) := FND_API.G_MISS_CHAR,
        DATE_CLOSED               DATE := FND_API.G_MISS_DATE,
        APPROVAL_REQUIRED_FLAG    VARCHAR2(1) := FND_API.G_MISS_CHAR,
        APPROVAL_STATUS           VARCHAR2(30) := FND_API.G_MISS_CHAR,
        SERIAL_NUMBER             VARCHAR2(30) := FND_API.G_MISS_CHAR,
        PROMISE_DATE              DATE := FND_API.G_MISS_DATE,
        ATTRIBUTE_CATEGORY        VARCHAR2(30) := FND_API.G_MISS_CHAR,
        ATTRIBUTE1                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE2                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE3                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE4                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE5                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE6                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE7                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE8                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE9                VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE10               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE11               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE12               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE13               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE14               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE15               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        QUANTITY                  NUMBER := FND_API.G_MISS_NUM,
        QUANTITY_IN_WIP           NUMBER := FND_API.G_MISS_NUM,
        QUANTITY_RCVD             NUMBER := FND_API.G_MISS_NUM,
        QUANTITY_SHIPPED          NUMBER := FND_API.G_MISS_NUM,
        CURRENCY_CODE             VARCHAR2(15) := FND_API.G_MISS_CHAR,
        DEFAULT_PO_NUM            VARCHAR2(80) := FND_API.G_MISS_CHAR,
        REPAIR_GROUP_ID           NUMBER := FND_API.G_MISS_NUM,
        RO_TXN_STATUS             VARCHAR2(30) := FND_API.G_MISS_CHAR,
        ORDER_LINE_ID             NUMBER := FND_API.G_MISS_NUM,
        ORIGINAL_SOURCE_REFERENCE VARCHAR2(30) := FND_API.G_MISS_CHAR,
        ORIGINAL_SOURCE_HEADER_ID NUMBER := FND_API.G_MISS_NUM,
        ORIGINAL_SOURCE_LINE_ID   NUMBER := FND_API.G_MISS_NUM,
        PRICE_LIST_HEADER_ID      NUMBER := FND_API.G_MISS_NUM,
        SUPERCESSION_INV_ITEM_ID  NUMBER := FND_API.G_MISS_NUM,
        FLOW_STATUS_ID            NUMBER := FND_API.G_MISS_NUM,
        FLOW_STATUS_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
        FLOW_STATUS               VARCHAR2(80) := FND_API.G_MISS_CHAR,
        INVENTORY_ORG_ID          NUMBER := FND_API.G_MISS_NUM,
        -- swai: bug 4666344 added problem description
        PROBLEM_DESCRIPTION       VARCHAR(240):= FND_API.G_MISS_CHAR,
        RO_PRIORITY_CODE          VARCHAR(80):= FND_API.G_MISS_CHAR, -- swai: R12
	    RESOLVE_BY_DATE           DATE := FND_API.G_MISS_DATE,        -- rfieldma: 5355051
        BULLETIN_CHECK_DATE       DATE  := FND_API.G_MISS_DATE,
        ESCALATION_CODE           VARCHAR(30) := FND_API.G_MISS_CHAR,
        RO_WARRANTY_STATUS_CODE   VARCHAR(30) := FND_API.G_MISS_CHAR,
        REPAIR_YIELD_QUANTITY     NUMBER := FND_API.G_MISS_NUM,       --bug#6692459
        ATTRIBUTE16               VARCHAR2(150) := FND_API.G_MISS_CHAR, -- SUBHAT, DFF CHANGES(bug#7497907)
	      ATTRIBUTE17               VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE18               VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE19               VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE20               VARCHAR2(150) := FND_API.G_MISS_CHAR,
        ATTRIBUTE21              	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE22              	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE23              	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE24              	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE25             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE26               VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE27             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE28             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE29             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
	      ATTRIBUTE30             	VARCHAR2(150) := FND_API.G_MISS_CHAR
      );
    --
    G_MISS_REPLN_REC REPLN_Rec_Type;
    --
    TYPE REPLN_Tbl_Type IS TABLE OF REPLN_Rec_Type INDEX BY BINARY_INTEGER;

    --
    G_MISS_REPLN_TBL REPLN_Tbl_Type;
    --
    --   *******************************************************
    --   API Name:  Create_Repair_Order
    --   Type    :  Public
    --   Pre-Req :  None
    --   Parameters:
    --   IN
    --     p_api_version_number      IN   NUMBER     Required
    --     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
    --     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
    --     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
    --     p_repair_line_id          IN   NUMBER     Optional  Default = FND_API.G_MISS_NUM
    --     P_REPLN_Rec               IN   CSD_REPAIRS_PUB.REPLN_Rec_Type  Required
    --     p_create_default_logistics IN  VARCHAR2   Optional  Default = N
    --
    --   OUT:
    --     x_return_status           OUT  VARCHAR2
    --     x_msg_count               OUT  NUMBER
    --     x_msg_data                OUT  VARCHAR2
    --     x_repair_line_id          OUT  NUMBER
    --     x_repair_number           OUT  NUMBER
    --
    --   Version : Current Version 1.0
    --             Initial Version 1.0
    --
    --   Notes: This API will create a Repair Order. User can pass REPAIR_LINE_ID.
    --          If passed, it will be validated
    --          for uniqueness and if valid, the same ID will be returned.
    --          User can pass REPAIR_NUMBER also. If passed, it will be validated
    --          for uniqueness and if valid, the same NUMBER will be returned.
    --
    /*#
    * Creates a new Repair Order for the given Service Request. The Repair Number
    * is generated if a unique number is not passed. Returns the Repair Number.
    * @param P_Api_Version_Number api version number
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param p_validation_level validation level, default to full level
    * @param p_repair_line_id repair line id is unique id
    * @param P_REPLN_Rec repiar line record
    * @param p_create_default_logistics flag to create logistics lines, default to N
    * @param X_REPAIR_LINE_ID repair line id of the created repair order
    * @param X_REPAIR_NUMBER repair number of the created repair order which display on Depot UI
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Repair Order
    */
    PROCEDURE Create_Repair_Order(P_Api_Version_Number IN NUMBER,
                                  P_Init_Msg_List      IN VARCHAR2 := FND_API.G_FALSE,
                                  P_Commit             IN VARCHAR2 := FND_API.G_FALSE,
                                  p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                  p_repair_line_id     IN NUMBER := FND_API.G_MISS_NUM,
                                  P_REPLN_Rec          IN CSD_REPAIRS_PUB.REPLN_Rec_Type,
                                  p_create_default_logistics   IN VARCHAR2 := 'N',
                                  X_REPAIR_LINE_ID     OUT NOCOPY NUMBER,
                                  X_REPAIR_NUMBER      OUT NOCOPY VARCHAR2,
                                  X_Return_Status      OUT NOCOPY VARCHAR2,
                                  X_Msg_Count          OUT NOCOPY NUMBER,
                                  X_Msg_Data           OUT NOCOPY VARCHAR2);
    --
    --   *******************************************************
    --   API Name:  Update_Repair_Order
    --   Type    :  Public
    --   Pre-Req :  None
    --   Parameters:
    --   IN
    --     p_api_version_number      IN   NUMBER     Required
    --     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
    --     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
    --     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
    --     p_repair_line_id          IN   NUMBER     Required
    --     P_REPLN_Rec               IN   CSD_REPAIRS_PUB.REPLN_Rec_Type  Required
    --
    --   OUT:
    --     x_return_status           OUT  VARCHAR2
    --     x_msg_count               OUT  NUMBER
    --     x_msg_data                OUT  VARCHAR2
    --
    --   Version : Current Version 1.0
    --             Initial Version 1.0
    --
    PROCEDURE Update_Repair_Order(P_Api_Version_Number IN NUMBER,
                                  P_Init_Msg_List      IN VARCHAR2 := FND_API.G_FALSE,
                                  P_Commit             IN VARCHAR2 := FND_API.G_FALSE,
                                  p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                  p_repair_line_id     IN NUMBER,
                                  P_REPLN_Rec          IN OUT NOCOPY CSD_REPAIRS_PUB.REPLN_Rec_Type,
                                  X_Return_Status      OUT NOCOPY VARCHAR2,
                                  X_Msg_Count          OUT NOCOPY NUMBER,
                                  X_Msg_Data           OUT NOCOPY VARCHAR2);
    --

    -- R12 development changes begin...
    TYPE REPAIR_STATUS_REC_TYPE IS RECORD(
        repair_line_id        NUMBER,
        repair_number         VARCHAR2(30),
        repair_status         VARCHAR2(30),
        repair_status_id      NUMBER,
        from_status_id        NUMBER,
        from_status           NUMBER,
        repair_state          VARCHAR2(30),
        reason_code           VARCHAR2(30),
        comments              VARCHAR2(2000),
        object_version_number NUMBER);
    TYPE STATUS_UPD_CONTROL_REC_TYPE IS RECORD(
        check_task_wip VARCHAR2(1));
    --   *******************************************************
    --   API Name:  update_ro_status
    --   Type    :  Public
    --   Pre-Req :  None
    --   Parameters:
    --   IN
    --     p_api_version               IN     NUMBER,
    --     p_commit                    IN     VARCHAR2,
    --     p_init_msg_list             IN     VARCHAR2,
    --     p_validation_level          IN     NUMBER,
    --     p_repair_line_id            IN     VARCHAR2,
    --     p_repair_status               IN     VARCHAR2,
    --     p_reason_code               IN     VARCHAR2,
    --     p_comments                  IN     VARCHAR2,
    --     p_check_task_wip             IN     VARCHAR2,
    --     p_object_version_number     IN     NUMBER
    --   OUT
    --     x_return_status
    --     x_msg_count
    --     x_msg_data
    --     x_object_version_number
    --
    --   Version : Current version 1.0
    --             Initial Version 1.0
    --
    --   Description : This API updates the repair status to a given value.
    --                 It checks for the open tasks/wipjobs based on the input
    --                 flag p_check_task_wip.
    --
    --
    -- ***********************************************************
    /*#
    * Updates a repair order status. If the status setup is done so that
    * it needs a reason, the reason is mandatory.
    *
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_Repair_status_rec repair order status record.
    * @param P_status_upd_control_rec repair order status update control record.
    *        Determines how the status record is updated, like any checks to be made etc...
    * @param X_OBJECT_VERSION_NUMBER updated object version number.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Repair Order Status
    */
    PROCEDURE UPDATE_RO_STATUS(p_api_version            IN NUMBER,
                               p_commit                 IN VARCHAR2,
                               p_init_msg_list          IN VARCHAR2,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_msg_count              OUT NOCOPY NUMBER,
                               x_msg_data               OUT NOCOPY VARCHAR2,
                               p_repair_status_rec      IN REPAIR_STATUS_REC_TYPE,
                               p_status_upd_control_rec IN STATUS_UPD_CONTROL_REC_TYPE,
                               x_object_version_number  OUT NOCOPY NUMBER);

-- R12 development changes End...

End CSD_REPAIRS_PUB;

/
