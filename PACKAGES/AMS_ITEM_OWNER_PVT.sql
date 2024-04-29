--------------------------------------------------------
--  DDL for Package AMS_ITEM_OWNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_OWNER_PVT" AUTHID CURRENT_USER as
/* $Header: amsvinvs.pls 120.1 2006/05/03 05:38:49 inanaiah noship $ */
-- Start of Comments
-- Package name     : AMS_ITEM_OWNER_PVT
-- Purpose          :

-- History          :
-- 09/20/2000   abhola    created.
-- 12/05/2000   musman    added two more record type for the
--                        wrapper of INV_Item_GRP pkg record types.
-- 01/21/2002   musman    Added three more attributes unit_weight,weight_uom_code and event_flag
-- 03/22/2002   musman    Added one more flag comms_nl_trackable_flag
-- 04/26/2002   musman    Added 6 more attributes
-- 12/17/2002   musman    Added one more flag so_transactions_flag
-- 05/03/2006   inanaiah  Bug 5191150 fix - Changed MESSAGE_TEXT from VARCHAR2(240) to VARCHAR2(2000)

-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:ITEM_OWNER_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    ITEM_OWNER_ID
--    OBJECT_VERSION_NUMBER
--    INVENTORY_ITEM_ID
--    ORGANIZATION_ID
--    ITEM_NUMBER
--    OWNER_ID
--    STATUS_CODE
--    EFFECTIVE_DATE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE ITEM_OWNER_Rec_Type IS RECORD
(
       ITEM_OWNER_ID                   NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       ITEM_NUMBER                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OWNER_ID                        NUMBER := FND_API.G_MISS_NUM,
       STATUS_CODE                     VARCHAR2(20) := FND_API.G_MISS_CHAR,
       EFFECTIVE_DATE                  DATE := FND_API.G_MISS_DATE,
       IS_MASTER_ITEM                  VARCHAR2(20) := FND_API.G_MISS_CHAR,
       ITEM_SETUP_TYPE                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       CUSTOM_SETUP_ID                 NUMBER := FND_API.G_MISS_NUM
);

G_MISS_ITEM_OWNER_REC          ITEM_OWNER_Rec_Type;
TYPE  ITEM_OWNER_Tbl_Type      IS TABLE OF ITEM_OWNER_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_ITEM_OWNER_TBL          ITEM_OWNER_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:ITEM_Rec_Type
--   -------------------------------------------------------
--    Description: This record type is to wrap the INV_Item_GRP.Item_rec_type
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments


TYPE ITEM_rec_type is RECORD (

     inventory_item_id        NUMBER    := FND_API.G_MISS_NUM,
     organization_id          NUMBER    := FND_API.G_MISS_NUM,
     item_number              VARCHAR2(2000)    :=  FND_API.g_MISS_CHAR,
     description                  VARCHAR2(240):= FND_API.G_MISS_CHAR,
     long_description         VARCHAR2(4000):=FND_API.G_MISS_CHAR,

     item_type                    VARCHAR2(30) := FND_API.G_MISS_CHAR,

     primary_uom_code         VARCHAR2(3)  :=  FND_API.G_MISS_CHAR,
     primary_unit_of_measure  VARCHAR2(25) :=  FND_API.G_MISS_CHAR,

     start_date_active                      DATE            :=  FND_API.g_MISS_DATE,
     end_date_active                        DATE            :=  FND_API.g_MISS_DATE ,

     inventory_item_status_codE             VARCHAR2(10)    :=  FND_API.g_MISS_CHAR,

     inventory_item_flag      VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
     stock_enabled_flag       VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
     mtl_transactions_enabled_flag  VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
     revision_qty_control_code              NUMBER          :=  FND_API.g_MISS_NUM,

     bom_enabled_flag         VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
     bom_item_type            NUMBER            := FND_API.G_MISS_NUM,

     costing_enabled_flag     VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,

     electronic_flag                 VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     downloadable_flag               VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,

     customer_order_flag            VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
     customer_order_enabled_flag    VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,

     internal_order_flag            VARCHAR2(1)     :=  FND_API.g_MISS_CHAR,
     internal_order_enabled_flag    VARCHAR2(1)     :=  FND_API.g_MISS_CHAR,

     shippable_item_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
     returnable_flag                    VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     comms_activation_reqd_flag         VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     replenish_to_order_flag            VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     invoiceable_item_flag              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     invoice_enabled_flag               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,

     service_item_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
     serviceable_product_flag           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
     vendor_warranty_flag               VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     coverage_schedule_id               NUMBER         :=  FND_API.g_MISS_NUM,
     service_duration                   NUMBER         :=  FND_API.g_MISS_NUM,
     service_duration_period_code       VARCHAR2(10)   :=  FND_API.g_MISS_CHAR,
     defect_tracking_on_flag            VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,

     orderable_on_web_flag           VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     back_orderable_flag             VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     collateral_flag                 VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     weight_uom_code                 VARCHAR2(3)    :=  FND_API.g_MISS_CHAR,
     unit_weight                     NUMBER         :=  FND_API.g_MISS_NUM,
     event_flag                      VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     comms_nl_trackable_flag         VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,

     subscription_depend_flag        VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     contract_item_type_code         VARCHAR2(30)   :=  FND_API.g_MISS_CHAR,
     web_status                      VARCHAR2(30)   :=  FND_API.g_MISS_CHAR,
     indivisible_flag                VARCHAR2(1)    :=  FND_API.g_MISS_CHAR,
     material_billable_flag          VARCHAR2(30)   :=  FND_API.g_MISS_CHAR,
     pick_components_flag            VARCHAR2(1)    :=  FND_API.g_MISS_CHAR
    ,so_transactions_flag            VARCHAR2(1)    :=  FND_API.g_MISS_CHAR

    ,attribute_category              VARCHAR2(30)    :=  FND_API.g_MISS_CHAR
    ,attribute1                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute2                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute3                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute4                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute5                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute6                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute7                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute8                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute9                      VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute10                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute11                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute12                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute13                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute14                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR
    ,attribute15                     VARCHAR2(150)   :=  FND_API.g_MISS_CHAR


     );

     G_MISS_ITEM_REC  ITEM_rec_type;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: Error_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    TRANSACTION_ID
--    UNIQUE_ID
--    MESSAGE_NAME
--    MESSAGE_TEXT
--    TABLE_NAME
--    COLUMN_NAME
--    ORGANIZATION_ID
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Error_rec_type IS RECORD(
   TRANSACTION_ID         NUMBER,
   UNIQUE_ID              NUMBER,
   MESSAGE_NAME           VARCHAR2(30),
   MESSAGE_TEXT           VARCHAR2(2000),
   TABLE_NAME             VARCHAR2(30),
   COLUMN_NAME            VARCHAR2(32),
   ORGANIZATION_ID        NUMBER
);

TYPE Error_tbl_type IS TABLE OF Error_rec_type
                       INDEX BY BINARY_INTEGER;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_item_owner
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_ITEM_OWNER_Rec     IN ITEM_OWNER_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_ITEM_OWNER_Rec     IN      ITEM_OWNER_Rec_Type  := G_MISS_ITEM_OWNER_REC,
    X_ITEM_OWNER_ID              OUT NOCOPY  NUMBER ,

    P_ITEM_REC_In        IN      ITEM_rec_type := G_MISS_ITEM_REC,  /*INV_Item_GRP.Item_rec_type := INV_Item_GRP.g_miss_Item_rec,*/
    P_ITEM_REC_Out       OUT NOCOPY     ITEM_rec_type,                         /*INV_Item_GRP.Item_rec_type,*/
    x_item_return_status OUT NOCOPY     VARCHAR2,
    x_error_tbl      OUT NOCOPY     Error_tbl_type                                 /*INV_Item_GRP.Error_tbl_type*/
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_item_owner
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_ITEM_OWNER_Rec     IN ITEM_OWNER_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_ITEM_OWNER_Rec     IN    ITEM_OWNER_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,

    P_ITEM_REC_In        IN      ITEM_rec_type := G_MISS_ITEM_REC, /*INV_Item_GRP.Item_rec_type := INV_Item_GRP.g_miss_Item_rec,*/
    P_ITEM_REC_Out       OUT NOCOPY     ITEM_rec_type ,/*INV_Item_GRP.Item_rec_type,*/
    x_item_return_status OUT NOCOPY     VARCHAR2,
    x_Error_tbl          OUT NOCOPY     Error_tbl_type/*INV_Item_GRP.Error_tbl_type*/
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_item_owner
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ITEM_OWNER_ID IN   NUMBER
--       p_object_version_number  IN   NUMBER     Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_ITEM_OWNER_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    );


-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

/*PROCEDURE Validate_ITEM_OWNER_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_ITEM_OWNER_Rec     IN    ITEM_OWNER_Rec_Type
    );
*/
-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_item_owner(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_ITEM_OWNER_Rec     IN    ITEM_OWNER_Rec_Type,
        P_ITEM_REC_In        IN    ITEM_rec_type := G_MISS_ITEM_REC,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
End AMS_ITEM_OWNER_PVT;

 

/
