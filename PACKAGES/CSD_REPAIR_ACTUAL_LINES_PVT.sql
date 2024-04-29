--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ACTUAL_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ACTUAL_LINES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvalns.pls 120.3 2008/05/14 05:00:23 swai ship $ csdvalns.pls */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ACTUALS_LINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvalns.pls';
g_debug              NUMBER       := csd_gen_utility_pvt.g_debug_level;

/*--------------------------------------------------------------------*/
/* Record name:  CSD_ACTUAL_LINES_REC_TYPE                            */
/* Description : Record used for Create/Update Repair Actuals         */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
TYPE CSD_ACTUAL_LINES_REC_TYPE IS RECORD
(
        REPAIR_ACTUAL_LINE_ID           NUMBER
,       OBJECT_VERSION_NUMBER           NUMBER
,       ESTIMATE_DETAIL_ID              NUMBER
,       REPAIR_ACTUAL_ID                NUMBER
,       REPAIR_LINE_ID                  NUMBER
,       CREATED_BY                      NUMBER
,       CREATION_DATE                   DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATE_LOGIN               NUMBER
,       ITEM_COST                       NUMBER
,       JUSTIFICATION_NOTES             VARCHAR2(240)
,       RESOURCE_ID                     NUMBER
,       OVERRIDE_CHARGE_FLAG            VARCHAR2(1)
,       ACTUAL_SOURCE_CODE              VARCHAR2(30)
,       ACTUAL_SOURCE_ID                NUMBER
,       WARRANTY_CLAIM_FLAG             VARCHAR2(1)  := FND_API.G_MISS_CHAR
,       WARRANTY_NUMBER                 VARCHAR2(80) := FND_API.G_MISS_CHAR
,       WARRANTY_STATUS_CODE            VARCHAR2(1)  := FND_API.G_MISS_CHAR
,       REPLACED_ITEM_ID                NUMBER       := FND_API.G_MISS_NUM
,       ATTRIBUTE_CATEGORY              VARCHAR2(30)
,       ATTRIBUTE1                      VARCHAR2(150)
,       ATTRIBUTE2                      VARCHAR2(150)
,       ATTRIBUTE3                      VARCHAR2(150)
,       ATTRIBUTE4                      VARCHAR2(150)
,       ATTRIBUTE5                      VARCHAR2(150)
,       ATTRIBUTE6                      VARCHAR2(150)
,       ATTRIBUTE7                      VARCHAR2(150)
,       ATTRIBUTE8                      VARCHAR2(150)
,       ATTRIBUTE9                      VARCHAR2(150)
,       ATTRIBUTE10                     VARCHAR2(150)
,       ATTRIBUTE11                     VARCHAR2(150)
,       ATTRIBUTE12                     VARCHAR2(150)
,       ATTRIBUTE13                     VARCHAR2(150)
,       ATTRIBUTE14                     VARCHAR2(150)
,       ATTRIBUTE15                     VARCHAR2(150)
,       LOCATOR_ID                      NUMBER
,       LOC_SEGMENT1                    VARCHAR2(40)
,       LOC_SEGMENT2                    VARCHAR2(40)
,       LOC_SEGMENT3                    VARCHAR2(40)
,       LOC_SEGMENT4                    VARCHAR2(40)
,       LOC_SEGMENT5                    VARCHAR2(40)
,       LOC_SEGMENT6                    VARCHAR2(40)
,       LOC_SEGMENT7                    VARCHAR2(40)
,       LOC_SEGMENT8                    VARCHAR2(40)
,       LOC_SEGMENT9                    VARCHAR2(40)
,       LOC_SEGMENT10                   VARCHAR2(40)
,       LOC_SEGMENT11                   VARCHAR2(40)
,       LOC_SEGMENT12                   VARCHAR2(40)
,       LOC_SEGMENT13                   VARCHAR2(40)
,       LOC_SEGMENT14                   VARCHAR2(40)
,       LOC_SEGMENT15                   VARCHAR2(40)
,       LOC_SEGMENT16                   VARCHAR2(40)
,       LOC_SEGMENT17                   VARCHAR2(40)
,       LOC_SEGMENT18                   VARCHAR2(40)
,       LOC_SEGMENT19                   VARCHAR2(40)
,       LOC_SEGMENT20                   VARCHAR2(40)
);


/*--------------------------------------------------------------------*/
/* Type to Return the Record Type for Creating / Updating the         */
/* Repair Actual Lines                                                */
/*                                                                    */
/* Called from : Depot Repair                                         */
/*--------------------------------------------------------------------*/
TYPE  CSD_ACTUAL_LINES_TBL_TYPE      IS TABLE OF CSD_ACTUAL_LINES_REC_TYPE
                                       INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------*/
/* procedure name: CREATE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Create Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE CREATE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_Charges_Rec          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    );

/*--------------------------------------------------------------------*/
/* procedure name: UPDATE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Update Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE UPDATE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_Charges_Rec          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    );



/*--------------------------------------------------------------------*/
/* procedure name: DELETE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Delete Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE DELETE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_Charges_Rec          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    );



/*--------------------------------------------------------------------*/
/* procedure name: LOCK_REPAIR_ACTUAL_LINES                           */
/* description : procedure used to Lock Repair Actuals                */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LOCK_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    );
/*------------------------------------------------------------------------------
TYPE CSD_ACTUAL_LINES_REC_TYPE IS RECORD
(
        REPAIR_ACTUAL_LINE_ID           NUMBER
,       OBJECT_VERSION_NUMBER           NUMBER
,       ESTIMATE_DETAIL_ID              NUMBER
,       REPAIR_ACTUAL_ID                NUMBER
,       REPAIR_LINE_ID                  NUMBER
,       CREATED_BY                      NUMBER
,       CREATION_DATE                   DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATE_LOGIN               NUMBER
,       ITEM_COST                       NUMBER
,       JUSTIFICATION_NOTES             VARCHAR2(240)
,       RESOURCE_ID                     NUMBER
,       OVERRIDE_CHARGE_FLAG            VARCHAR2(1)
,       ACTUAL_SOURCE_CODE              VARCHAR2(30)
,       ACTUAL_SOURCE_ID                NUMBER
,       ATTRIBUTE_CATEGORY              VARCHAR2(30)
,       ATTRIBUTE1                      VARCHAR2(150)
,       ATTRIBUTE2                      VARCHAR2(150)
,       ATTRIBUTE3                      VARCHAR2(150)
,       ATTRIBUTE4                      VARCHAR2(150)
,       ATTRIBUTE5                      VARCHAR2(150)
,       ATTRIBUTE6                      VARCHAR2(150)
,       ATTRIBUTE7                      VARCHAR2(150)
,       ATTRIBUTE8                      VARCHAR2(150)
,       ATTRIBUTE9                      VARCHAR2(150)
,       ATTRIBUTE10                     VARCHAR2(150)
,       ATTRIBUTE11                     VARCHAR2(150)
,       ATTRIBUTE12                     VARCHAR2(150)
,       ATTRIBUTE13                     VARCHAR2(150)
,       ATTRIBUTE14                     VARCHAR2(150)
,       ATTRIBUTE15                     VARCHAR2(150)
,       LOCATOR_ID                      NUMBER
,       LOC_SEGMENT1                    VARCHAR2(40)
,       LOC_SEGMENT2                    VARCHAR2(40)
,       LOC_SEGMENT3                    VARCHAR2(40)
,       LOC_SEGMENT4                    VARCHAR2(40)
,       LOC_SEGMENT5                    VARCHAR2(40)
,       LOC_SEGMENT6                    VARCHAR2(40)
,       LOC_SEGMENT7                    VARCHAR2(40)
,       LOC_SEGMENT8                    VARCHAR2(40)
,       LOC_SEGMENT9                    VARCHAR2(40)
,       LOC_SEGMENT10                   VARCHAR2(40)
,       LOC_SEGMENT11                   VARCHAR2(40)
,       LOC_SEGMENT12                   VARCHAR2(40)
,       LOC_SEGMENT13                   VARCHAR2(40)
,       LOC_SEGMENT14                   VARCHAR2(40)
,       LOC_SEGMENT15                   VARCHAR2(40)
,       LOC_SEGMENT16                   VARCHAR2(40)
,       LOC_SEGMENT17                   VARCHAR2(40)
,       LOC_SEGMENT18                   VARCHAR2(40)
,       LOC_SEGMENT19                   VARCHAR2(40)
,       LOC_SEGMENT20                   VARCHAR2(40)
,       INCIDENT_ID                     NUMBER           -- Begin For Charges Record
,       TRANSACTION_TYPE_ID             NUMBER
,       BUSINESS_PROCESS_ID             NUMBER
,       TXN_BILLING_TYPE_ID             NUMBER
,       ORIGINAL_SOURCE_ID              NUMBER
,       ORIGINAL_SOURCE_CODE            VARCHAR2(10)
,       SOURCE_ID                       NUMBER
,       SOURCE_CODE                     VARCHAR2(10)
,       LINE_TYPE_ID                    NUMBER
,       CUSTOMER_PRODUCT_ID             NUMBER
,       REFERENCE_NUMBER                NUMBER
,       ITEM_REVISION                   VARCHAR2(30)
,       ORDER_NUMBER                    VARCHAR2(30)
,       PURCHASE_ORDER_NUM              VARCHAR2(30)
,       SOURCE_NUMBER                   VARCHAR2(30)
,       STATUS                          VARCHAR2(30)
,       CURRENCY_CODE                   VARCHAR2(15)
,       LINE_CATEGORY_CODE              VARCHAR2(6)
,       UNIT_OF_MEASURE_CODE            VARCHAR2(3)
,       ORIGINAL_SOURCE_NUMBER          VARCHAR2(3)
,       ORDER_HEADER_ID                 NUMBER
,       ORDER_LINE_ID                   NUMBER
,       INVENTORY_ITEM_ID               NUMBER
,       AFTER_WARRANTY_COST             NUMBER
,       SELLING_PRICE                   NUMBER
,       ORIGINAL_SYSTEM_REFERENCE       VARCHAR2(30)
,       ESTIMATE_QUANTITY               NUMBER
,       SERIAL_NUMBER                   VARCHAR2(50)
,       LOT_NUMBER                      VARCHAR2(80) -- fix for bug#4625226
,       INSTANCE_ID                     NUMBER
,       INSTANCE_NUMBER                 NUMBER
,       PRICE_LIST_ID                   NUMBER
,       CONTRACT_ID                     NUMBER
,       CONTRACT_NUMBER                 VARCHAR2(30)
,       COVERAGE_ID                     NUMBER
,       CHARGE_LINE_TYPE                VARCHAR2(30)
,       APPLY_CONTRACT_DISCOUNT         VARCHAR2(1)
,       COVERAGE_TXN_GROUP_ID           NUMBER
,       COVERAGE_BILL_RATE_ID           NUMBER
,       SUB_INVENTORY                   VARCHAR2(30)
,       ORGANIZATION_ID                 NUMBER
,       INVOICE_TO_ORG_ID               NUMBER
,       SHIP_TO_ORG_ID                  NUMBER
,       NO_CHARGE_FLAG                  VARCHAR2(1)
,       INTERFACE_TO_OM_FLAG            VARCHAR2(1)
,       RETURN_REASON                   VARCHAR2(30)
,       RETURN_BY_DATE                  DATE
,       SECURITY_GROUP_ID               NUMBER
,       PRICING_CONTEXT                 VARCHAR2(30)
,       PRICING_ATTRIBUTE1              VARCHAR2(150)
,       PRICING_ATTRIBUTE2              VARCHAR2(150)
,       PRICING_ATTRIBUTE3              VARCHAR2(150)
,       PRICING_ATTRIBUTE4              VARCHAR2(150)
,       PRICING_ATTRIBUTE5              VARCHAR2(150)
,       PRICING_ATTRIBUTE6              VARCHAR2(150)
,       PRICING_ATTRIBUTE7              VARCHAR2(150)
,       PRICING_ATTRIBUTE8              VARCHAR2(150)
,       PRICING_ATTRIBUTE9              VARCHAR2(150)
,       PRICING_ATTRIBUTE10             VARCHAR2(150)
,       PRICING_ATTRIBUTE11             VARCHAR2(150)
,       PRICING_ATTRIBUTE12             VARCHAR2(150)
,       PRICING_ATTRIBUTE13             VARCHAR2(150)
,       PRICING_ATTRIBUTE14             VARCHAR2(150)
,       PRICING_ATTRIBUTE15             VARCHAR2(150)
,       PRICING_ATTRIBUTE16             VARCHAR2(150)
,       PRICING_ATTRIBUTE17             VARCHAR2(150)
,       PRICING_ATTRIBUTE18             VARCHAR2(150)
,       PRICING_ATTRIBUTE19             VARCHAR2(150)
,       PRICING_ATTRIBUTE20             VARCHAR2(150)
,       PRICING_ATTRIBUTE21             VARCHAR2(150)
,       PRICING_ATTRIBUTE22             VARCHAR2(150)
,       PRICING_ATTRIBUTE123             VARCHAR2(150)
,       PRICING_ATTRIBUTE24             VARCHAR2(150)
,       PRICING_ATTRIBUTE25             VARCHAR2(150)
,       PRICING_ATTRIBUTE26             VARCHAR2(150)
,       PRICING_ATTRIBUTE27             VARCHAR2(150)
,       PRICING_ATTRIBUTE28             VARCHAR2(150)
,       PRICING_ATTRIBUTE29             VARCHAR2(150)
,       PRICING_ATTRIBUTE30             VARCHAR2(150)
,       PRICING_ATTRIBUTE31             VARCHAR2(150)
,       PRICING_ATTRIBUTE32             VARCHAR2(150)
,       PRICING_ATTRIBUTE33             VARCHAR2(150)
,       PRICING_ATTRIBUTE34             VARCHAR2(150)
,       PRICING_ATTRIBUTE35             VARCHAR2(150)
,       PRICING_ATTRIBUTE36             VARCHAR2(150)
,       PRICING_ATTRIBUTE37             VARCHAR2(150)
,       PRICING_ATTRIBUTE38             VARCHAR2(150)
,       PRICING_ATTRIBUTE39             VARCHAR2(150)
,       PRICING_ATTRIBUTE40             VARCHAR2(150)
,       PRICING_ATTRIBUTE41             VARCHAR2(150)
,       PRICING_ATTRIBUTE42             VARCHAR2(150)
,       PRICING_ATTRIBUTE43             VARCHAR2(150)
,       PRICING_ATTRIBUTE44             VARCHAR2(150)
,       PRICING_ATTRIBUTE45             VARCHAR2(150)
,       PRICING_ATTRIBUTE46             VARCHAR2(150)
,       PRICING_ATTRIBUTE47             VARCHAR2(150)
,       PRICING_ATTRIBUTE48             VARCHAR2(150)
,       PRICING_ATTRIBUTE49             VARCHAR2(150)
,       PRICING_ATTRIBUTE50             VARCHAR2(150)
,       PRICING_ATTRIBUTE51             VARCHAR2(150)
,       PRICING_ATTRIBUTE52             VARCHAR2(150)
,       PRICING_ATTRIBUTE53             VARCHAR2(150)
,       PRICING_ATTRIBUTE54             VARCHAR2(150)
,       PRICING_ATTRIBUTE55             VARCHAR2(150)
,       PRICING_ATTRIBUTE56             VARCHAR2(150)
,       PRICING_ATTRIBUTE57             VARCHAR2(150)
,       PRICING_ATTRIBUTE58             VARCHAR2(150)
,       PRICING_ATTRIBUTE59             VARCHAR2(150)
,       PRICING_ATTRIBUTE60             VARCHAR2(150)
,       PRICING_ATTRIBUTE61             VARCHAR2(150)
,       PRICING_ATTRIBUTE62             VARCHAR2(150)
,       PRICING_ATTRIBUTE63             VARCHAR2(150)
,       PRICING_ATTRIBUTE64             VARCHAR2(150)
,       PRICING_ATTRIBUTE65             VARCHAR2(150)
,       PRICING_ATTRIBUTE66             VARCHAR2(150)
,       PRICING_ATTRIBUTE67             VARCHAR2(150)
,       PRICING_ATTRIBUTE68             VARCHAR2(150)
,       PRICING_ATTRIBUTE69             VARCHAR2(150)
,       PRICING_ATTRIBUTE70             VARCHAR2(150)
,       PRICING_ATTRIBUTE71             VARCHAR2(150)
,       PRICING_ATTRIBUTE72             VARCHAR2(150)
,       PRICING_ATTRIBUTE73             VARCHAR2(150)
,       PRICING_ATTRIBUTE74             VARCHAR2(150)
,       PRICING_ATTRIBUTE75             VARCHAR2(150)
,       PRICING_ATTRIBUTE76             VARCHAR2(150)
,       PRICING_ATTRIBUTE77             VARCHAR2(150)
,       PRICING_ATTRIBUTE78             VARCHAR2(150)
,       PRICING_ATTRIBUTE79             VARCHAR2(150)
,       PRICING_ATTRIBUTE80             VARCHAR2(150)
,       PRICING_ATTRIBUTE81             VARCHAR2(150)
,       PRICING_ATTRIBUTE82             VARCHAR2(150)
,       PRICING_ATTRIBUTE83             VARCHAR2(150)
,       PRICING_ATTRIBUTE84             VARCHAR2(150)
,       PRICING_ATTRIBUTE85             VARCHAR2(150)
,       PRICING_ATTRIBUTE86             VARCHAR2(150)
,       PRICING_ATTRIBUTE87             VARCHAR2(150)
,       PRICING_ATTRIBUTE88             VARCHAR2(150)
,       PRICING_ATTRIBUTE89             VARCHAR2(150)
,       PRICING_ATTRIBUTE90             VARCHAR2(150)
,       PRICING_ATTRIBUTE91             VARCHAR2(150)
,       PRICING_ATTRIBUTE92             VARCHAR2(150)
,       PRICING_ATTRIBUTE93             VARCHAR2(150)
,       PRICING_ATTRIBUTE94             VARCHAR2(150)
,       PRICING_ATTRIBUTE95             VARCHAR2(150)
,       PRICING_ATTRIBUTE96             VARCHAR2(150)
,       PRICING_ATTRIBUTE97             VARCHAR2(150)
,       PRICING_ATTRIBUTE98             VARCHAR2(150)
,       PRICING_ATTRIBUTE99             VARCHAR2(150)
,       PRICING_ATTRIBUTE100            VARCHAR2(150)      -- End For Charges Record
);
------------------------------------------------------------------------------*/
End CSD_REPAIR_ACTUAL_LINES_PVT;

/
