--------------------------------------------------------
--  DDL for Package CSD_REPAIRS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIRS_GRP" AUTHID CURRENT_USER as
/* $Header: csdgdras.pls 120.6.12010000.3 2010/05/06 01:29:08 takwong ship $ */
--
-- Package name     : CSD_REPAIRS_GRP
-- Purpose          : This package contains routines called by Repairs Form. The procedures convert the
--                    parameters into REPLN_REC_TYPE and call the Private APIs.
-- History          :
-- Version       Date       Name        Description
-- 115.0         12/28/99   pkdas       Created.
-- 115.1         01/18/00   pkdas
-- 115.2         02/21/00   pkdas       Changed the name of the procedure Insert_From_Form
--                                      to Create_Repairs and Update_From_Form to Update_Repairs.
--                                      Added p_REPAIR_LINE_ID and p_REPAIR_NUMBER as IN
--                                      parameters in the Create_Repairs procedure.
--                                      Added standard OUT parameter in the Create_Repairs
--                                      and Update_Repairs procedures. Added default values
--                                      to the parameters.
-- 115.3         02/29/00   pkdas       Changed the procedure name
--                                      Create_Repairs -> Create_Repair_Order
--                                      Update_Repairs -> Update_Repair_Order
-- 115.4         11/30/01   travi       Added Auto_Process_Rma, Object_Version_Number and Repair_Mode columns
-- 115.5         01/04/02   travi       Added Object_Version_Number to update_approval_status
--                                      and update_status procedures
-- 115.6         01/14/02   travi       Added Item_Revision
-- 115.7         05/16/02   travi       Added Update_Group_Approval_Status and Update_Group_Reject_Status procedures
-- 115.28        08/06/02   saupadhy    Default input parameters for procedures were made consistent in package specifica
--                                      -tion and body. To fix bug 2497692

--
--
-- NOTE             :
--


PROCEDURE Create_Repair_Order(
   p_Init_Msg_List            IN         VARCHAR2 := 'F',
   p_Commit                   IN         VARCHAR2 := 'F',
   p_REPAIR_LINE_ID           IN         NUMBER,
   p_REPAIR_NUMBER            IN         VARCHAR2,
   p_INCIDENT_ID              IN         NUMBER,
   p_INVENTORY_ITEM_ID        IN         NUMBER,
   p_CUSTOMER_PRODUCT_ID      IN         NUMBER,
   p_UNIT_OF_MEASURE          IN         VARCHAR2,
   p_REPAIR_TYPE_ID           IN         NUMBER,
-- RESOURCE_GROUP Added by Vijay 10/28/2004
   p_RESOURCE_GROUP           IN         NUMBER,
   p_RESOURCE_ID              IN         NUMBER,
   p_PROJECT_ID               IN         NUMBER,
   p_TASK_ID                  IN         NUMBER,
   p_UNIT_NUMBER              IN         VARCHAR2 := FND_API.G_MISS_CHAR, -- rfieldma, prj intergration
   p_CONTRACT_LINE_ID         IN         NUMBER,
   p_AUTO_PROCESS_RMA         IN         VARCHAR2,
   p_REPAIR_MODE              IN         VARCHAR2,
   p_OBJECT_VERSION_NUMBER    IN         NUMBER,
   p_ITEM_REVISION            IN         VARCHAR2,
   p_INSTANCE_ID              IN         NUMBER,
   p_STATUS                   IN         VARCHAR2 := 'O',
   p_STATUS_REASON_CODE       IN         VARCHAR2,
   p_DATE_CLOSED              IN         DATE,
   p_APPROVAL_REQUIRED_FLAG   IN         VARCHAR2,
   p_APPROVAL_STATUS          IN         VARCHAR2,
   p_SERIAL_NUMBER            IN         VARCHAR2,
   p_PROMISE_DATE             IN         DATE,
   p_ATTRIBUTE_CATEGORY       IN         VARCHAR2,
   p_ATTRIBUTE1               IN         VARCHAR2,
   p_ATTRIBUTE2               IN         VARCHAR2,
   p_ATTRIBUTE3               IN         VARCHAR2,
   p_ATTRIBUTE4               IN         VARCHAR2,
   p_ATTRIBUTE5               IN         VARCHAR2,
   p_ATTRIBUTE6               IN         VARCHAR2,
   p_ATTRIBUTE7               IN         VARCHAR2,
   p_ATTRIBUTE8               IN         VARCHAR2,
   p_ATTRIBUTE9               IN         VARCHAR2,
   p_ATTRIBUTE10              IN         VARCHAR2,
   p_ATTRIBUTE11              IN         VARCHAR2,
   p_ATTRIBUTE12              IN         VARCHAR2,
   p_ATTRIBUTE13              IN         VARCHAR2,
   p_ATTRIBUTE14              IN         VARCHAR2,
   p_ATTRIBUTE15              IN         VARCHAR2,
   -- additional DFF attributes, subhat(bug#7497907).
   P_ATTRIBUTE16               IN      VARCHAR2 ,
   P_ATTRIBUTE17               IN      VARCHAR2 ,
   P_ATTRIBUTE18               IN      VARCHAR2 ,
   P_ATTRIBUTE19               IN      VARCHAR2 ,
   P_ATTRIBUTE20               IN      VARCHAR2 ,
   P_ATTRIBUTE21               IN      VARCHAR2 ,
   P_ATTRIBUTE22               IN      VARCHAR2 ,
   P_ATTRIBUTE23               IN      VARCHAR2 ,
   P_ATTRIBUTE24               IN      VARCHAR2 ,
   P_ATTRIBUTE25               IN      VARCHAR2 ,
   P_ATTRIBUTE26               IN      VARCHAR2 ,
   P_ATTRIBUTE27               IN      VARCHAR2 ,
   P_ATTRIBUTE28               IN      VARCHAR2 ,
   P_ATTRIBUTE29               IN      VARCHAR2 ,
   P_ATTRIBUTE30               IN      VARCHAR2 ,
   p_QUANTITY                 IN         NUMBER := 1,
   p_QUANTITY_IN_WIP          IN         NUMBER,
   p_QUANTITY_RCVD            IN         NUMBER,
   p_QUANTITY_SHIPPED         IN         NUMBER,
   p_CURRENCY_CODE            IN         VARCHAR2,
   p_DEFAULT_PO_NUM           IN         VARCHAR2 := null,
   p_REPAIR_GROUP_ID          IN         NUMBER,
   p_RO_TXN_STATUS            IN         VARCHAR2,
   p_ORDER_LINE_ID              IN       NUMBER,
   p_ORIGINAL_SOURCE_REFERENCE  IN       VARCHAR2,
   p_ORIGINAL_SOURCE_HEADER_ID  IN       NUMBER,
   p_ORIGINAL_SOURCE_LINE_ID    IN       NUMBER,
   p_PRICE_LIST_HEADER_ID       IN       NUMBER,
   p_INVENTORY_ORG_ID           IN       NUMBER,
   p_PROBLEM_DESCRIPTION        IN       VARCHAR2 := null,   -- swai: bug 4666344
   p_RO_PRIORITY_CODE           IN       VARCHAR2 := null,   -- swai: R12
   -- G_MISS_DATE means default resolve_by_date during RO creation
   -- null means do not default resolve_by_date during RO creation
   p_RESOLVE_BY_DATE	       IN       DATE := FND_API.G_MISS_DATE, -- rfieldma, bug 5355051
   p_BULLETIN_CHECK_DATE       IN       DATE := FND_API.G_MISS_DATE,
   p_ESCALATION_CODE           IN       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_RO_WARRANTY_STATUS_CODE   IN       VARCHAR2 := FND_API.G_MISS_CHAR,
   x_repair_line_id           OUT NOCOPY        NUMBER,
   x_repair_number            OUT NOCOPY        VARCHAR2,
   x_return_status            OUT NOCOPY        VARCHAR2,
   x_msg_count                OUT NOCOPY        NUMBER,
   x_msg_data                 OUT NOCOPY        VARCHAR2
    );


PROCEDURE Update_Repair_Order(
   p_Init_Msg_List            IN         VARCHAR2 := 'F',
   p_Commit                   IN         VARCHAR2 := 'F',
   p_REPAIR_LINE_ID           IN         NUMBER,
   p_REPAIR_NUMBER            IN         VARCHAR2,
   p_INCIDENT_ID              IN         NUMBER,
   p_INVENTORY_ITEM_ID        IN         NUMBER,
   p_CUSTOMER_PRODUCT_ID      IN         NUMBER,
   p_UNIT_OF_MEASURE          IN         VARCHAR2,
   p_REPAIR_TYPE_ID           IN         NUMBER,
-- RESOURCE_GROUP Added by Vijay 10/28/2004
   p_RESOURCE_GROUP           IN         NUMBER,
   p_RESOURCE_ID              IN         NUMBER,
   p_PROJECT_ID               IN         NUMBER,
   p_TASK_ID                  IN         NUMBER,
   p_UNIT_NUMBER              IN         VARCHAR2 := FND_API.G_MISS_CHAR, -- rfieldma, prj intergration
   p_CONTRACT_LINE_ID         IN         NUMBER,
   p_AUTO_PROCESS_RMA         IN         VARCHAR2,
   p_REPAIR_MODE              IN         VARCHAR2,
   p_OBJECT_VERSION_NUMBER    IN         NUMBER,
   p_ITEM_REVISION            IN         VARCHAR2,
   p_INSTANCE_ID              IN         NUMBER,
   p_STATUS                   IN         VARCHAR2,
   p_STATUS_REASON_CODE       IN         VARCHAR2,
   p_DATE_CLOSED              IN         DATE,
   p_APPROVAL_REQUIRED_FLAG   IN         VARCHAR2,
   p_APPROVAL_STATUS          IN         VARCHAR2,
   p_SERIAL_NUMBER            IN         VARCHAR2,
   p_PROMISE_DATE             IN         DATE,
   p_ATTRIBUTE_CATEGORY       IN         VARCHAR2,
   p_ATTRIBUTE1               IN         VARCHAR2,
   p_ATTRIBUTE2               IN         VARCHAR2,
   p_ATTRIBUTE3               IN         VARCHAR2,
   p_ATTRIBUTE4               IN         VARCHAR2,
   p_ATTRIBUTE5               IN         VARCHAR2,
   p_ATTRIBUTE6               IN         VARCHAR2,
   p_ATTRIBUTE7               IN         VARCHAR2,
   p_ATTRIBUTE8               IN         VARCHAR2,
   p_ATTRIBUTE9               IN         VARCHAR2,
   p_ATTRIBUTE10              IN         VARCHAR2,
   p_ATTRIBUTE11              IN         VARCHAR2,
   p_ATTRIBUTE12              IN         VARCHAR2,
   p_ATTRIBUTE13              IN         VARCHAR2,
   p_ATTRIBUTE14              IN         VARCHAR2,
   p_ATTRIBUTE15              IN         VARCHAR2,
   -- additional DFF attributes, subhat(bug#7497907).
   P_ATTRIBUTE16               IN      VARCHAR2 ,
   P_ATTRIBUTE17               IN      VARCHAR2 ,
   P_ATTRIBUTE18               IN      VARCHAR2 ,
   P_ATTRIBUTE19               IN      VARCHAR2 ,
   P_ATTRIBUTE20               IN      VARCHAR2 ,
   P_ATTRIBUTE21               IN      VARCHAR2 ,
   P_ATTRIBUTE22               IN      VARCHAR2 ,
   P_ATTRIBUTE23               IN      VARCHAR2 ,
   P_ATTRIBUTE24               IN      VARCHAR2 ,
   P_ATTRIBUTE25               IN      VARCHAR2 ,
   P_ATTRIBUTE26               IN      VARCHAR2 ,
   P_ATTRIBUTE27               IN      VARCHAR2 ,
   P_ATTRIBUTE28               IN      VARCHAR2 ,
   P_ATTRIBUTE29               IN      VARCHAR2 ,
   P_ATTRIBUTE30               IN      VARCHAR2 ,
   p_QUANTITY                 IN         NUMBER,
   p_QUANTITY_IN_WIP          IN         NUMBER,
   p_QUANTITY_RCVD            IN         NUMBER,
   p_QUANTITY_SHIPPED         IN         NUMBER,
   p_CURRENCY_CODE            IN         VARCHAR2,
   p_DEFAULT_PO_NUM           IN         VARCHAR2 := null,
   p_REPAIR_GROUP_ID          IN         NUMBER,
   p_RO_TXN_STATUS            IN         VARCHAR2,
   p_ORDER_LINE_ID              IN       NUMBER,
   p_ORIGINAL_SOURCE_REFERENCE  IN       VARCHAR2,
   p_ORIGINAL_SOURCE_HEADER_ID  IN       NUMBER,
   p_ORIGINAL_SOURCE_LINE_ID    IN       NUMBER,
   p_PRICE_LIST_HEADER_ID       IN       NUMBER,
   p_PROBLEM_DESCRIPTION        IN       VARCHAR2 := FND_API.G_MISS_CHAR,   -- swai: bug 4666344
   p_RO_PRIORITY_CODE           IN       VARCHAR2 := FND_API.G_MISS_CHAR,   -- swai: R12
   -- g_miss_date means keep field in table handler
   -- null clear field in table handler
   p_RESOLVE_BY_DATE	       IN       DATE := FND_API.G_MISS_DATE, -- rfieldma, bug 5355051
   p_BULLETIN_CHECK_DATE       IN       DATE := FND_API.G_MISS_DATE,
   p_ESCALATION_CODE           IN       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ro_warranty_status_code   IN       VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status            OUT NOCOPY        VARCHAR2,
   x_msg_count                OUT NOCOPY        NUMBER,
   x_msg_data                 OUT NOCOPY        VARCHAR2
    );

Procedure Update_Approval_Status(
        p_repair_line_id       IN   NUMBER,
        p_new_approval_status  IN   VARCHAR2,
        p_old_approval_status  IN   VARCHAR2,
        p_quantity             IN   NUMBER,
        p_org_contact_id       IN   NUMBER,
        p_reason               IN   VARCHAR2,
        p_object_version_number IN OUT NOCOPY  NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2
        );


Procedure Update_Status(
        p_repair_line_id   IN   NUMBER,
        p_new_status       IN   VARCHAR2,
        p_old_status       IN   VARCHAR2,
        p_quantity         IN   NUMBER,
        p_reason           IN   VARCHAR2,
        p_status_reason_code  IN         VARCHAR2,
        p_object_version_number IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2
        );

Procedure Update_Group_Approval_Status(
    p_api_version           IN       NUMBER,
    p_commit                IN       VARCHAR2  := fnd_api.g_false,
    p_init_msg_list         IN       VARCHAR2  := fnd_api.g_false,
    p_validation_level      IN       NUMBER    := fnd_api.g_valid_level_full,
    p_repair_group_id       IN       NUMBER,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
        );

Procedure Update_Group_Reject_Status(
    p_api_version           IN       NUMBER,
    p_commit                IN       VARCHAR2  := fnd_api.g_false,
    p_init_msg_list         IN       VARCHAR2  := fnd_api.g_false,
    p_validation_level      IN       NUMBER    := fnd_api.g_valid_level_full,
    p_repair_group_id       IN       NUMBER,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
    );

--
--
End CSD_REPAIRS_GRP;

/
