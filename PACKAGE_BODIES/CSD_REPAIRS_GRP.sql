--------------------------------------------------------
--  DDL for Package Body CSD_REPAIRS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIRS_GRP" as
/* $Header: csdgdrab.pls 120.7.12010000.3 2010/05/06 01:28:00 takwong ship $ */
--
-- Package name     : CSD_REPAIRS_GRP
-- Purpose          : This package contains routines called by Repairs form.
-- History          :
-- Version       Date       Name        Description
-- 115.0         12/28/99   pkdas       Created.
-- 115.1         01/18/00   pkdas
-- 115.2         01/25/00   pkdas       Assigned l_repair_line_id to out parameter in Insert_From_Form
-- 115.3         02/21/00   pkdas       Changed the name of the procedure Insert_From_Form
--                                      to Create_Repairs and Update_From_Form to Update_Repairs.
--                                      Added p_REPAIR_LINE_ID and p_REPAIR_NUMBER as IN
--                                      parameters in the Create_Repairs procedure.
--                                      Added standard OUT parameter in the Create_Repairs
--                                      and Update_Repairs procedures. Added default values
--                                      to the parameters.
-- 115.4         02/29/00   pkdas       Changed the procedure name
--                                      Create_Repairs -> Create_Repair_Order
--                                      Update_Repairs -> Update_Repair_Order
-- 115.5         05/10/00   pkdas       Made changes to Update_Status procedure
-- 115.6         11/30/01   travi       Added Auto_Process_Rma, Object_Version_Number and Repair_Mode cols
-- 115.6         01/04/02   travi       Added Object_Version_Number to update_approval_status
--                                      and update_status procedure
-- 115.7         01/14/02   travi       Added Item_Revision column
-- 115.8         02/06/02   travi       Added Object_Version_Numbe column to validate_and_write call
-- 115.9         05/16/02   travi       Added Update_Group_Approval_Status and Update_Group_Reject_Status procedures
-- 115.28        08/06/02   saupadhy    Default input parameters for procedures were made consistent in package specifica
--                                      -tion and body. To fix bug 2497692
-- NOTE             :
--
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_REPAIRS_GRP';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdgdrab.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
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
   p_UNIT_NUMBER              IN         VARCHAR2,
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
   p_PROBLEM_DESCRIPTION        IN       VARCHAR2, -- swai: bug 4666344
   p_RO_PRIORITY_CODE           IN       VARCHAR2, -- swai: R12
   -- g_miss_date means default resolve_by_date during ro creation
   -- null means do not default resolve_by_date during ro creation
   p_RESOLVE_BY_DATE	       IN       DATE, -- rfieldma, bug 5355051, defaulted to g_miss_date in spec
   p_BULLETIN_CHECK_DATE        IN       DATE,-- := FND_API.G_MISS_DATE,
   p_ESCALATION_CODE            IN       VARCHAR2, -- := FND_API.G_MISS_CHAR,
   p_RO_WARRANTY_STATUS_CODE    IN       VARCHAR2,
   x_repair_line_id           OUT NOCOPY        NUMBER,
   x_repair_number            OUT NOCOPY        VARCHAR2,
   x_return_status            OUT NOCOPY        VARCHAR2,
   x_msg_count                OUT NOCOPY        NUMBER,
   x_msg_data                 OUT NOCOPY        VARCHAR2
        )
IS
--
  l_api_name                        CONSTANT VARCHAR2(30) := 'Create_Repair_Order';
  l_repln_rec                       csd_repairs_pub.repln_rec_type;
--
begin
--
-- Standard Start of API savepoint
  SAVEPOINT CREATE_REPAIR_ORDER_GRP;
--
-- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
if (g_debug) > 0 then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Create_Repair_Order  before CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type');
end if;
  CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
  (p_repair_number => p_repair_number,
   p_incident_id => p_incident_id,
   p_inventory_item_id => p_inventory_item_id,
   p_customer_product_id => p_customer_product_id,
   p_unit_of_measure => p_unit_of_measure,
   p_repair_type_id => p_repair_type_id,
-- RESOURCE_GROUP Added by Vijay 10/28/2004
   p_resource_group => p_resource_group,
   p_resource_id => p_resource_id,
   p_project_id => p_project_id,
   p_task_id => p_task_id,
   p_unit_number => p_unit_number, -- rfieldma, prj integration
   p_contract_line_id => p_contract_line_id,
   p_auto_process_rma => p_auto_process_rma,
   p_repair_mode => p_repair_mode,
   p_object_version_number => p_object_version_number,
   p_item_revision => p_item_revision,
   p_instance_id => p_instance_id,
   p_status => p_status,
   p_status_reason_code => p_status_reason_code,
   p_date_closed => p_date_closed,
   p_approval_required_flag => p_approval_required_flag,
   p_approval_status => p_approval_status,
   p_serial_number => p_serial_number,
   p_promise_date => p_promise_date,
   p_attribute_category => p_attribute_category,
   p_attribute1 => p_attribute1,
   p_attribute2 => p_attribute2,
   p_attribute3 => p_attribute3,
   p_attribute4 => p_attribute4,
   p_attribute5 => p_attribute5,
   p_attribute6 => p_attribute6,
   p_attribute7 => p_attribute7,
   p_attribute8 => p_attribute8,
   p_attribute9 => p_attribute9,
   p_attribute10 => p_attribute10,
   p_attribute11 => p_attribute11,
   p_attribute12 => p_attribute12,
   p_attribute13 => p_attribute13,
   p_attribute14 => p_attribute14,
   p_attribute15 => p_attribute15,
   -- additional DFF attributes, subhat(bug#7497907)
   p_attribute16 => p_attribute16,
   p_attribute17 => p_attribute17,
   p_attribute18 => p_attribute18,
   p_attribute19 => p_attribute19,
   p_attribute20 => p_attribute20,
   p_attribute21 => p_attribute21,
   p_attribute22 => p_attribute22,
   p_attribute23 => p_attribute23,
   p_attribute24 => p_attribute24,
   p_attribute25 => p_attribute25,
   p_attribute26 => p_attribute26,
   p_attribute27 => p_attribute27,
   p_attribute28 => p_attribute28,
   p_attribute29 => p_attribute29,
   p_attribute30 => p_attribute30,
   p_quantity => p_quantity,
   p_quantity_in_wip => p_quantity_in_wip,
   p_quantity_rcvd => p_quantity_rcvd,
   p_quantity_shipped => p_quantity_shipped,
   p_currency_code    => p_currency_code,
   p_default_po_num    => p_default_po_num,
   p_repair_group_id  => p_repair_group_id,
   p_ro_txn_status    => p_ro_txn_status,
   p_order_line_id    => p_order_line_id,
   p_original_source_reference  => p_original_source_reference,
   p_original_source_header_id  => p_original_source_header_id,
   p_original_source_line_id    => p_original_source_line_id,
   p_price_list_header_id       => p_price_list_header_id,
   p_inventory_org_id           => p_inventory_org_id,
   p_problem_description        => p_problem_description,  -- swai: bug 4666344
   p_ro_priority_code           => p_ro_priority_code,     -- swai: R12
   p_resolve_by_date            => p_resolve_by_date, -- rfieldma: 5355051
   p_bulletin_check_date       =>  p_bulletin_check_date,
   p_escalation_code           =>  p_escalation_code,
   p_ro_warranty_status_code   =>  p_ro_warranty_status_code,
   x_Repln_Rec => l_Repln_Rec);
--
if (g_debug > 0) then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Create_Repair_Order  before CSD_REPAIRS_PVT.Create_Repair_Order');
end if;
  -- travi fix to create call from RO not to validate for Group_id
  l_Repln_Rec.REPAIR_GROUP_ID := null;

  CSD_REPAIRS_PVT.Create_Repair_Order
  (p_API_version_number => 1.0,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_validation_level => null,
   p_repair_line_id => p_repair_line_id,
   p_Repln_Rec => l_Repln_Rec,
   x_repair_line_id => x_repair_line_id,
   x_repair_number => x_repair_number,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data
  );
--
-- Check return status from the above procedure call
  IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO CREATE_REPAIR_ORDER_GRP;
    return;
  END IF;
--
-- End of API body.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT WORK;
   END IF;
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN OTHERS THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
End Create_Repair_Order;

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
   p_UNIT_NUMBER              IN         VARCHAR2, -- rfieldma, prj integration
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
   p_PROBLEM_DESCRIPTION        IN       VARCHAR2, -- swai: bug 4666344
   p_RO_PRIORITY_CODE           IN       VARCHAR2, -- swai: R12
   -- g_miss_date means keep field in table handler
   -- null means clear field in table handler
   p_RESOLVE_BY_DATE	       IN       DATE, -- rfieldma, bug 5355051, defaulted to g_miss_date in spec
   p_BULLETIN_CHECK_DATE        IN       DATE, -- := FND_API.G_MISS_DATE,
   p_ESCALATION_CODE            IN       VARCHAR2, -- := FND_API.G_MISS_CHAR,
   p_RO_WARRANTY_STATUS_CODE    IN       VARCHAR2,
   x_return_status            OUT NOCOPY        VARCHAR2,
   x_msg_count                OUT NOCOPY        NUMBER,
   x_msg_data                 OUT NOCOPY        VARCHAR2
        )
IS
--
  l_api_name                        CONSTANT VARCHAR2(30) := 'Update_Repair_Order';
  l_repln_rec                       csd_repairs_pub.repln_rec_type;
--
begin
--
-- Standard Start of API savepoint
  SAVEPOINT UPDATE_REPAIR_ORDER_GRP;
--
-- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
if (g_debug > 0 ) then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Repair_Order  before CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type');
end if;
  CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
  (p_repair_number => p_repair_number,
   p_incident_id => p_incident_id,
   p_inventory_item_id => p_inventory_item_id,
   p_customer_product_id => p_customer_product_id,
   p_unit_of_measure => p_unit_of_measure,
   p_repair_type_id => p_repair_type_id,
   p_resource_group => p_resource_group,
   p_resource_id => p_resource_id,
   p_project_id => p_project_id,
   p_task_id => p_task_id,
   p_unit_number => p_unit_number, -- rfieldma, prj integration
   p_contract_line_id => p_contract_line_id,
   p_auto_process_rma => p_auto_process_rma,
   p_repair_mode => p_repair_mode,
   p_object_version_number => p_object_version_number,
   p_item_revision => p_item_revision,
   p_instance_id => p_instance_id,
   p_status => p_status,
   p_status_reason_code => p_status_reason_code,
   p_date_closed => p_date_closed,
   p_approval_required_flag => p_approval_required_flag,
   p_approval_status => p_approval_status,
   p_serial_number => p_serial_number,
   p_promise_date => p_promise_date,
   p_attribute_category => p_attribute_category,
   p_attribute1 => p_attribute1,
   p_attribute2 => p_attribute2,
   p_attribute3 => p_attribute3,
   p_attribute4 => p_attribute4,
   p_attribute5 => p_attribute5,
   p_attribute6 => p_attribute6,
   p_attribute7 => p_attribute7,
   p_attribute8 => p_attribute8,
   p_attribute9 => p_attribute9,
   p_attribute10 => p_attribute10,
   p_attribute11 => p_attribute11,
   p_attribute12 => p_attribute12,
   p_attribute13 => p_attribute13,
   p_attribute14 => p_attribute14,
   p_attribute15 => p_attribute15,
   -- additional DFF attributes, subhat(bug#7497907)
   p_attribute16 => p_attribute16,
   p_attribute17 => p_attribute17,
   p_attribute18 => p_attribute18,
   p_attribute19 => p_attribute19,
   p_attribute20 => p_attribute20,
   p_attribute21 => p_attribute21,
   p_attribute22 => p_attribute22,
   p_attribute23 => p_attribute23,
   p_attribute24 => p_attribute24,
   p_attribute25 => p_attribute25,
   p_attribute26 => p_attribute26,
   p_attribute27 => p_attribute27,
   p_attribute28 => p_attribute28,
   p_attribute29 => p_attribute29,
   p_attribute30 => p_attribute30,
   p_quantity => p_quantity,
   p_quantity_in_wip => p_quantity_in_wip,
   p_quantity_rcvd => p_quantity_rcvd,
   p_quantity_shipped => p_quantity_shipped,
   p_currency_code => p_currency_code,
   p_default_po_num    => p_default_po_num,
   p_repair_group_id  => p_repair_group_id,
   p_ro_txn_status    => p_ro_txn_status,
   p_order_line_id    => p_order_line_id,
   p_original_source_reference  => p_original_source_reference,
   p_original_source_header_id  => p_original_source_header_id,
   p_original_source_line_id    => p_original_source_line_id,
   p_price_list_header_id       => p_price_list_header_id,
   p_problem_description        => p_problem_description, -- swai: bug 4666344
   p_ro_priority_code           => p_ro_priority_code,    -- swai: R12
   p_resolve_by_date            => p_resolve_by_date, -- rfieldma: 5355051
   p_bulletin_check_date       =>  p_bulletin_check_date,
   p_escalation_code           =>  p_escalation_code,
   p_ro_warranty_status_code   =>  p_ro_warranty_status_code,
   x_Repln_Rec => l_Repln_Rec);
--
if (g_debug > 0) then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Repair_Order  before CSD_REPAIRS_PUB.Update_Repair_Order');
end if;
  CSD_REPAIRS_PUB.Update_Repair_Order
  (p_API_version_number => 1.0,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_repair_line_id => p_repair_line_id,
   p_Repln_Rec => l_Repln_Rec,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data
  );
--
-- Check return status from the above procedure call
  IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO UPDATE_REPAIR_ORDER_GRP;
    return;
  END IF;
--
-- End of API body.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN OTHERS THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
End Update_Repair_Order;

-- travi 01/04/02 change
Procedure Update_Approval_Status(
        p_repair_line_id       IN   NUMBER,
        p_new_approval_status  IN   VARCHAR2,
        p_old_approval_status  IN   VARCHAR2,
        p_quantity             IN   NUMBER,
        p_org_contact_id       IN   NUMBER,
        p_reason               IN   VARCHAR2,
        p_object_version_number IN OUT NOCOPY   NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2
        )
IS
-- CONSTANTS --
 lc_debug_level           CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 lc_stat_level            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 lc_proc_level            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 lc_event_level           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 lc_excep_level           CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 lc_error_level           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 lc_unexp_level           CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.csd_repairs_grp.update_approval_status';
--
  l_api_name                        CONSTANT VARCHAR2(30) := 'Update_Approval_Status';
  l_repln_rec                       CSD_REPAIRS_PUB.repln_rec_type;
  l_repair_history_id               number;
  l_event_code                      varchar2(30);
  -- swai 11.5.10 new variables
  l_return_status                   varchar2(1);
  l_estimate_total                  number;
  -- end swai 11.5.10


--
BEGIN
--
-- Standard Start of API savepoint
  SAVEPOINT UPDATE_APPROVAL_STATUS_GRP;
--
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API Body
--
  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Calling CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type');
  end if;
-- travi 01/04/02 change
  CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
  (p_approval_status => p_new_approval_status,
   p_object_version_number => p_object_version_number,
   x_repln_rec => l_repln_rec
  );
--
  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Returned from CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type');
  end if;
  --
  -- swai 11.5.10
  -- update event code will always be ESU if status is changed
  --
  if nvl(p_new_approval_status, 'x') <> nvl(p_old_approval_status, 'x') then
      l_event_code := 'ESU';
  end if;
  -- if p_new_approval_status = 'A' then
  --   l_event_code := 'ESU';
  -- elsif p_new_approval_status = 'R' then
  --   l_event_code := 'R';
  -- end if;
  if (lc_stat_level >= lc_debug_level) then
      FND_LOG.STRING(lc_stat_level, lc_mod_name,
            'p_new_approval_status = ' || p_new_approval_status);
      FND_LOG.STRING(lc_stat_level, lc_mod_name,
            'p_old_approval_status = ' || p_old_approval_status);
      FND_LOG.STRING(lc_stat_level, lc_mod_name,
            'l_event_code = ' || l_event_code);
  end if;

--
  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Calling CSD_REPAIRS_PVT.Update_Repair_Order ');
  end if;
  CSD_REPAIRS_PVT.Update_Repair_Order
  (p_API_version_number => 1.0,
   p_init_msg_list => FND_API.G_TRUE,
   p_commit => FND_API.G_FALSE,
   p_validation_level => null,
   p_repair_line_id => p_repair_line_id,
   p_Repln_Rec => l_Repln_Rec,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data
  );
--
  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Returned from CSD_REPAIRS_PVT.Update_Repair_Order. x_return_status='|| x_return_status);
  end if;

-- Check return status from the above procedure call
  IF (x_return_status <> 'S') then
    ROLLBACK TO UPDATE_APPROVAL_STATUS_GRP;
    return;
  ELSIF (x_return_status = 'S') then
    p_object_version_number := l_Repln_Rec.object_version_number;
  END IF;
--
if (g_debug > 0) then
csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Approval_Status before api CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call');
end if;

-- swai 11.5.10
-- check for event code before:
-- (1) getting estimate total   (new for 11.5.10)
-- (2) logging event            (modified for 11.5.10)
--
if (l_event_code is not null) then

  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Calling CSD_REPAIR_ESTIMATE_PVT.get_total_estimated_charge ');
  end if;
  -- get estimate_total sum of charge from csd_repair_estimates_v
  CSD_REPAIR_ESTIMATE_PVT.get_total_estimated_charge (
    p_repair_line_id    => p_repair_line_id,
    x_estimated_charge  => l_estimate_total,
    x_return_status     => l_return_status
  );
  IF (x_return_status <> 'S') then
      l_estimate_total := null;
  END IF;


  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Returned from CSD_REPAIR_ESTIMATE_PVT.get_total_estimated_charge.  l_estimate_total=' || l_estimate_total);
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write ');
  end if;
  CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
  (p_Api_Version_Number => 1.0 ,
   p_init_msg_list => 'F',
   p_commit => 'F',
   p_validation_level => NULL,
   p_action_code => 0,
   px_REPAIR_HISTORY_ID => l_repair_history_id,
   p_OBJECT_VERSION_NUMBER       => null,                     -- travi ovn validation
   p_REQUEST_ID    => null,
   p_PROGRAM_ID    => null,
   p_PROGRAM_APPLICATION_ID    => null,
   p_PROGRAM_UPDATE_DATE   => null,
   p_CREATED_BY    => FND_GLOBAL.USER_ID,
   p_CREATION_DATE => sysdate,
   p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
   p_LAST_UPDATE_DATE => sysdate,
   p_repair_line_id => p_repair_line_id,
   p_EVENT_CODE => l_event_code,
   p_EVENT_DATE => sysdate,
   p_QUANTITY  => p_quantity,
   p_PARAMN1     =>  p_org_contact_id,
   p_PARAMN2    =>   l_estimate_total,
   p_PARAMN3    => null,
   p_PARAMN4    => null,
   p_PARAMN5    => null,
   p_PARAMN6    => null,
   p_PARAMN7    => null,
   p_PARAMN8    => null,
   p_PARAMN9    => null,
   p_PARAMN10   => FND_GLOBAL.USER_ID,
   p_PARAMC1    => p_new_approval_status,
   p_PARAMC2    => p_old_approval_status,
   p_PARAMC3    => p_reason,
   p_PARAMC4    => null,
   p_PARAMC5    => null ,
   p_PARAMC6    => null,
   p_PARAMC7    => null,
   p_PARAMC8    => null,
   p_PARAMC9    => null,
   p_PARAMC10   => null,
   p_PARAMD1    => null,
   p_PARAMD2    => null,
   p_PARAMD3    => null,
   p_PARAMD4    => null,
   p_PARAMD5    => null,
   p_PARAMD6    => null,
   p_PARAMD7    => null,
   p_PARAMD8    => null,
   p_PARAMD9    => null,
   p_PARAMD10   => null,
   p_ATTRIBUTE_CATEGORY  => null,
   p_ATTRIBUTE1    => null,
   p_ATTRIBUTE2    => null,
   p_ATTRIBUTE3    => null,
   p_ATTRIBUTE4    => null,
   p_ATTRIBUTE5    => null,
   p_ATTRIBUTE6    => null,
   p_ATTRIBUTE7    => null,
   p_ATTRIBUTE8   => null,
   p_ATTRIBUTE9   => null,
   p_ATTRIBUTE10    => null,
   p_ATTRIBUTE11    => null,
   p_ATTRIBUTE12    =>null,
   p_ATTRIBUTE13    => null,
   p_ATTRIBUTE14    => null,
   p_ATTRIBUTE15    => null,
   p_LAST_UPDATE_LOGIN    => FND_GLOBAL.CONC_LOGIN_ID,
   X_Return_Status              => x_return_status,
   X_Msg_Count                  => x_msg_count,
   X_Msg_Data                   => x_msg_data
  );
end if;
--
  if (lc_proc_level >= lc_debug_level) then
      FND_LOG.STRING(lc_proc_level, lc_mod_name,
            'Returned from CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write.  x_return_status='||x_return_status);
  end if;
-- Check return status from the above procedure call
  IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO UPDATE_APPROVAL_STATUS_GRP;
    return;
  END IF;
--
-- End of API body.
--
  -- travi commit;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN OTHERS THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
END Update_Approval_Status;

Procedure Update_Status(
        p_repair_line_id   IN   NUMBER,
        p_new_status       IN   VARCHAR2,
        p_old_status       IN   VARCHAR2,
        p_quantity         IN   NUMBER,
        p_reason           IN   VARCHAR2,
          p_status_reason_code IN         VARCHAR2,
        p_object_version_number IN   NUMBER,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2
        )
IS
--
  l_api_name                        CONSTANT VARCHAR2(30) := 'Update_Status';
  l_repln_rec                       CSD_REPAIRS_PUB.repln_rec_type;
  l_repair_history_id               number;

--
BEGIN
--
-- Standard Start of API savepoint
  SAVEPOINT UPDATE_STATUS_GRP;
--
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API Body
--
  if p_new_status = p_old_status then

    -- old return;
    -- travi 010902 new
    CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
    (p_date_closed => sysdate,
     p_status => p_new_status,
     p_status_reason_code => p_status_reason_code,
     p_object_version_number => p_object_version_number,
     x_repln_rec => l_repln_rec
    );

  end if;
  if p_new_status = 'C' then

    CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
    (p_date_closed => sysdate,
     p_status => p_new_status,
     p_status_reason_code => p_status_reason_code,
     p_object_version_number => p_object_version_number,
     x_repln_rec => l_repln_rec
    );

  elsif p_old_status = 'C' then

    CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
    (p_date_closed => null,
     p_status => p_new_status,
     p_status_reason_code => p_status_reason_code,
     p_object_version_number => p_object_version_number,
     x_repln_rec => l_repln_rec
    );

  else

    CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
    (p_status => p_new_status,
     p_status_reason_code => p_status_reason_code,
     p_object_version_number => p_object_version_number,
     x_repln_rec => l_repln_rec
    );

  end if;
--
if (g_debug > 0) then
csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Status before CSD_REPAIRS_PVT.Update_Repair_Order');
end if;
  CSD_REPAIRS_PVT.Update_Repair_Order
  (p_API_version_number => 1.0,
   p_init_msg_list => FND_API.G_TRUE,
   p_commit => FND_API.G_FALSE,
   p_validation_level => null,
   p_repair_line_id => p_repair_line_id,
   p_Repln_Rec => l_Repln_Rec,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data
  );
if (g_debug > 0) then
csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Status after CSD_REPAIRS_PVT.Update_Repair_Order status : '||x_return_status);
end if;
--
-- Check return status from the above procedure call
  IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO UPDATE_STATUS_GRP;
    return;
  END IF;
--
 /*Fixed for bug#3232547 sangigup
  Condition "if p_new_status <> p_old_status then" has been removed
   to log the activity for changes in repair order status reason.
 */
 -- travi 010902 change added if cond
 --if p_new_status <> p_old_status then
if (g_debug > 0) then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Status before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write');
end if;

  CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
  (p_Api_Version_Number => 1.0 ,
   p_init_msg_list => 'F',
   p_commit => 'F',
   p_validation_level => NULL,
   p_action_code => 0,
   px_REPAIR_HISTORY_ID => l_repair_history_id,
   p_OBJECT_VERSION_NUMBER       => null,                     -- travi ovn validation
   p_REQUEST_ID    => null,
   p_PROGRAM_ID    => null,
   p_PROGRAM_APPLICATION_ID    => null,
   p_PROGRAM_UPDATE_DATE   => null,
   p_CREATED_BY    => FND_GLOBAL.USER_ID,
   p_CREATION_DATE => sysdate,
   p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
   p_LAST_UPDATE_DATE => sysdate,
   p_repair_line_id => p_repair_line_id,
   p_EVENT_CODE => 'SC',
   p_EVENT_DATE => sysdate,
   p_QUANTITY  => p_quantity,
   p_PARAMN1     =>   null,
   p_PARAMN2    =>    null,
   p_PARAMN3    => null,
   p_PARAMN4    => null,
   p_PARAMN5    => null,
   p_PARAMN6    => null,
   p_PARAMN7    => null,
   p_PARAMN8    => null,
   p_PARAMN9    => null,
   p_PARAMN10   => FND_GLOBAL.USER_ID,
   p_PARAMC1    => p_new_status,
   p_PARAMC2    => p_old_status,
   p_PARAMC3    => p_reason,
   p_PARAMC4    => null,
   p_PARAMC5    => null,
   p_PARAMC6    => null,
   p_PARAMC7    => null,
   p_PARAMC8    => null,
   p_PARAMC9    => null,
   p_PARAMC10   => null,
   p_PARAMD1    => null,
   p_PARAMD2    => null,
   p_PARAMD3    => null,
   p_PARAMD4    => null,
   p_PARAMD5    => null,
   p_PARAMD6    => null,
   p_PARAMD7    => null,
   p_PARAMD8    => null,
   p_PARAMD9    => null,
   p_PARAMD10   => null,
   p_ATTRIBUTE_CATEGORY  => null,
   p_ATTRIBUTE1    => null,
   p_ATTRIBUTE2    => null,
   p_ATTRIBUTE3    => null,
   p_ATTRIBUTE4    => null,
   p_ATTRIBUTE5    => null,
   p_ATTRIBUTE6    => null,
   p_ATTRIBUTE7    => null,
   p_ATTRIBUTE8   => null,
   p_ATTRIBUTE9   => null,
   p_ATTRIBUTE10    => null,
   p_ATTRIBUTE11    => null,
   p_ATTRIBUTE12    =>null,
   p_ATTRIBUTE13    => null,
   p_ATTRIBUTE14    => null,
   p_ATTRIBUTE15    => null,
   p_LAST_UPDATE_LOGIN    => FND_GLOBAL.CONC_LOGIN_ID,
   X_Return_Status              => x_return_status,
   X_Msg_Count                  => x_msg_count,
   X_Msg_Data                   => x_msg_data
  );
if (g_debug > 0) then
  csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Status before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write status : '||x_return_status);
end if;
 --end if; -- only for changed status codes sangigup 3232547
--
-- Check return status from the above procedure call
  IF not (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK TO UPDATE_STATUS_GRP;
    return;
  END IF;
--
  -- travi commit;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
  WHEN OTHERS THEN
    JTF_PLSQL_API.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => '_GRP'
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
--
END Update_Status;

-- travi 051002 code
Procedure Update_Group_Approval_Status(
  p_api_version               IN       NUMBER,
  p_commit                    IN       VARCHAR2  := fnd_api.g_false,
  p_init_msg_list             IN       VARCHAR2  := fnd_api.g_false,
  p_validation_level          IN       NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id           IN       NUMBER,
  p_object_version_number     IN OUT NOCOPY   NUMBER,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2
)
IS
--
  l_api_name      CONSTANT VARCHAR2(30) := 'Update_Group_Approval_Status';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_repair_group_id        NUMBER;
  l_count                  NUMBER;
  l_tot_approved           NUMBER;
  l_tot_no_approval        NUMBER;
  l_tot_rejected           NUMBER;

  l_repair_history_id      NUMBER;
  l_repair_line_id         NUMBER;
  l_rep_ovn                NUMBER;
  l_rep_quantity           NUMBER;
  l_repair_estimate_id     NUMBER;
  l_est_ovn                NUMBER;
  l_group_quantity         NUMBER;
  l_group_ovn              NUMBER;

  l_approval_status        VARCHAR2(1);
  l_rep_approval_status    VARCHAR2(30);
  l_estimate_status        VARCHAR2(30);
  l_event_code             VARCHAR2(30);

  l_rep_ord_rec            CSD_REPAIRS_PUB.REPLN_REC_TYPE;
  l_rep_est_rec            CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_REC;
  l_rep_group_rec          CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC;

  Cursor  c_repairs_for_approval ( p_repair_group_id number) is
  Select  rep.repair_line_id
        , rep.approval_status
        , rep.quantity
        , rep.object_version_number rep_ovn
        , est.repair_estimate_id
        , est.object_version_number est_ovn
    from  csd_repairs rep
        , csd_repair_estimate est
   where  rep.repair_group_id = p_repair_group_id
     and  rep.repair_line_id  = est.repair_line_id
     and  est.estimate_status = 'BID';

--
BEGIN
--
   -----------------------------------
   -- Standard Start of API savepoint
   -----------------------------------
   SAVEPOINT UPDATE_GRP_APPV_STATUS;

   -----------------------------------------------------
   -- Standard call to check for call compatibility.
   -----------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ---------------------------------------------------------------
   -- Initialize message list if p_init_msg_list is set to TRUE.
   ---------------------------------------------------------------
   IF FND_API.to_Boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;

   --------------------------------------------
   -- Initialize API return status to success
   --------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --------------------
   -- Api body starts
   --------------------
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );

   ---------------------------------
   -- Check the required parameter
   ---------------------------------
   if (g_debug > 0) then
   csd_gen_utility_pvt.ADD('Check reqd parameter: Repair Group Id ');
end if;
   CSD_PROCESS_UTIL.Check_Reqd_Param
    ( p_param_value => p_repair_group_id,
      p_param_name  => 'REPAIR_GROUP_ID',
      p_api_name    => l_api_name);

   ----------------------------------
   -- Validate the Repair Group  Id
   ----------------------------------
   if (g_debug > 0) then
   csd_gen_utility_pvt.ADD('Repair Group Id');
end if;
   IF NOT( CSD_PROCESS_UTIL.Validate_repair_group_id
        ( p_repair_group_id  => p_repair_group_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- get all repair lines having estimates with status as BID for the given Repair Group
   FOR r1 in c_repairs_for_approval (p_repair_group_id)

   LOOP

       -- initialize
       l_repair_line_id := null;

       l_repair_line_id        := r1.repair_line_id;
       l_rep_approval_status   := r1.approval_status;
       l_rep_quantity          := r1.quantity;
       l_rep_ovn               := r1.rep_ovn;
       l_repair_estimate_id    := r1.repair_estimate_id;
       l_est_ovn               := r1.est_ovn;

      if ( l_repair_line_id is not null ) then

        l_approval_status  := 'A';
        l_estimate_status  := 'ACCEPTED';
        l_event_code       := 'A';

        ----------------------------------
        -- API Body
        ----------------------------------
      if (g_debug > 0) then
        csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status convert repairs rec call');
end if;
        CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
        (p_approval_status       => l_approval_status,
         p_object_version_number => l_rep_ovn,
         x_repln_rec             => l_rep_ord_rec
        );
if (g_debug > 0) then
        csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status Update repairs call');
end if;
        CSD_REPAIRS_PVT.Update_Repair_Order
        (p_API_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_TRUE,
         p_commit                => FND_API.G_FALSE,
       p_validation_level      => null,
         p_repair_line_id        => l_repair_line_id,
         p_Repln_Rec             => l_rep_ord_rec,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
        );

if (g_debug > 0) then
       csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status Update_Repair_Order :'||x_return_status);
end if;
       -- Check return status from the update RO  call
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     if (g_debug > 0) then
         csd_gen_utility_pvt.ADD('CSD_REPAIRS_PVT.Update_Repair_Order failed ');
        end if;
       RAISE FND_API.G_EXC_ERROR;
         --ROLLBACK TO UPDATE_GRP_APPV_STATUS;
         --return;
       ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS) then
if (g_debug > 0) then
         csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status Update RO hist call');
end if;
           CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
           (p_Api_Version_Number     => 1.0 ,
            p_init_msg_list          => 'F',
            p_commit                 => 'F',
            p_validation_level       => NULL,
            p_action_code            => 0,
            px_REPAIR_HISTORY_ID     => l_repair_history_id,
            p_OBJECT_VERSION_NUMBER  => null,
            p_REQUEST_ID             => null,
            p_PROGRAM_ID             => null,
            p_PROGRAM_APPLICATION_ID => null,
            p_PROGRAM_UPDATE_DATE    => null,
            p_CREATED_BY             => FND_GLOBAL.USER_ID,
            p_CREATION_DATE          => sysdate,
            p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_DATE       => sysdate,
            p_repair_line_id         => l_repair_line_id,
            p_EVENT_CODE             => l_event_code,
            p_EVENT_DATE             => sysdate,
            p_QUANTITY               => l_rep_quantity,
            p_PARAMN1                => null,
            p_PARAMN2                => null,
            p_PARAMN3                => null,
            p_PARAMN4                => null,
            p_PARAMN5                => null,
            p_PARAMN6                => null,
            p_PARAMN7                => null,
            p_PARAMN8                => null,
            p_PARAMN9                => null,
            p_PARAMN10               => FND_GLOBAL.USER_ID,
            p_PARAMC1                => l_approval_status,                -- new status
            p_PARAMC2                => l_rep_approval_status,            -- old status
            p_PARAMC3                => 'Repair Group Estimate Approval', -- travi new
            p_PARAMC4                => null,
            p_PARAMC5                => null ,
            p_PARAMC6                => null,
            p_PARAMC7                => null,
            p_PARAMC8                => null,
            p_PARAMC9                => null,
            p_PARAMC10               => null,
            p_PARAMD1                => null,
            p_PARAMD2                => null,
            p_PARAMD3                => null,
            p_PARAMD4                => null,
            p_PARAMD5                => null,
            p_PARAMD6                => null,
            p_PARAMD7                => null,
            p_PARAMD8                => null,
            p_PARAMD9                => null,
            p_PARAMD10               => null,
            p_ATTRIBUTE_CATEGORY     => null,
            p_ATTRIBUTE1             => null,
            p_ATTRIBUTE2             => null,
            p_ATTRIBUTE3             => null,
            p_ATTRIBUTE4             => null,
            p_ATTRIBUTE5             => null,
            p_ATTRIBUTE6             => null,
            p_ATTRIBUTE7             => null,
            p_ATTRIBUTE8             => null,
            p_ATTRIBUTE9             => null,
            p_ATTRIBUTE10            => null,
            p_ATTRIBUTE11            => null,
            p_ATTRIBUTE12            =>null,
            p_ATTRIBUTE13            => null,
            p_ATTRIBUTE14            => null,
            p_ATTRIBUTE15            => null,
            p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
            X_Return_Status          => x_return_status,
            X_Msg_Count              => x_msg_count,
            X_Msg_Data               => x_msg_data
           );
if (g_debug > 0) then
         csd_gen_utility_pvt.add('Update_Group_Approval_Status Validate_And_Write :'||x_return_status);
end if;
         -- Check return status from the above procedure call
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           if (g_debug > 0) then
        csd_gen_utility_pvt.ADD('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write failed ');
           end if;
        RAISE FND_API.G_EXC_ERROR;
            --ROLLBACK TO UPDATE_GRP_APPV_STATUS;
            --return;
         END IF;

          l_rep_est_rec.repair_estimate_id    := l_repair_estimate_id;
          l_rep_est_rec.repair_line_id        := l_repair_line_id;
          l_rep_est_rec.object_version_number := l_est_ovn;
          l_rep_est_rec.estimate_status       := l_estimate_status;
if (g_debug > 0) then
          csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status Update RO estimate call');
end if;
           csd_repair_estimate_pvt.update_repair_estimate
           (p_api_version      => 1.0,
            p_commit           => 'F',
            p_init_msg_list    => 'T',
            p_validation_level => fnd_api.g_valid_level_full,
            x_estimate_rec     => l_rep_est_rec,
            x_return_status    => x_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);
if (g_debug > 0) then
          csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Approval_Status update_repair_estimate :'||x_return_status);
end if;
    -- Check return status from the above procedure call
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           if (g_debug > 0) then
        csd_gen_utility_pvt.ADD('csd_repair_estimate_pvt.update_repair_estimate failed ');
           end if;
        RAISE FND_API.G_EXC_ERROR;
            --ROLLBACK TO UPDATE_GRP_APPV_STATUS;
            --return;
         END IF;

       END IF;
       -- End of Check return status from the update RO  call

      end if; -- repair_line_id is null

   END LOOP;
   -- End of API body.

   -- update to group is done in the call csd_repair_estimate_pvt.update_repair_estimate
   -- repair group object version number is not returned in this case

   -------------------------------
   -- Standard check for p_commit
   -------------------------------
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

   ---------------------------------------------------------------------------
   -- Standard call to get message count and if count is 1, get message info.
   ---------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data);

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO UPDATE_GRP_APPV_STATUS;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO UPDATE_GRP_APPV_STATUS;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO UPDATE_GRP_APPV_STATUS;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

END Update_Group_Approval_Status;

-- travi 051702 code
Procedure Update_Group_Reject_Status(
  p_api_version               IN       NUMBER,
  p_commit                    IN       VARCHAR2  := fnd_api.g_false,
  p_init_msg_list             IN       VARCHAR2  := fnd_api.g_false,
  p_validation_level          IN       NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id           IN       NUMBER,
  p_object_version_number     IN OUT NOCOPY   NUMBER,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2
)
IS
--
  l_api_name      CONSTANT VARCHAR2(30) := 'Update_Group_Reject_Status';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_repair_group_id        NUMBER;
  l_count                  NUMBER;
  l_tot_approved           NUMBER;
  l_tot_rejected           NUMBER;
  l_tot_no_approval        NUMBER;

  l_repair_history_id      NUMBER;
  l_repair_line_id         NUMBER;
  l_rep_ovn                NUMBER;
  l_rep_quantity           NUMBER;
  l_repair_estimate_id     NUMBER;
  l_est_ovn                NUMBER;
  l_group_quantity         NUMBER;
  l_group_ovn              NUMBER;

  l_Reject_status          VARCHAR2(1);
  l_rep_Reject_status      VARCHAR2(30);
  l_estimate_status        VARCHAR2(30);
  l_event_code             VARCHAR2(30);

  l_rep_ord_rec            CSD_REPAIRS_PUB.REPLN_REC_TYPE;
  l_rep_est_rec            CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_REC;
  l_rep_group_rec          CSD_REPAIR_GROUPS_PVT.REPAIR_ORDER_GROUP_REC;

  Cursor  c_repairs_for_Reject ( p_repair_group_id number) is
  Select  rep.repair_line_id
        , rep.approval_status
        , rep.quantity
        , rep.object_version_number rep_ovn
        , est.repair_estimate_id
        , est.object_version_number est_ovn
    from  csd_repairs rep
        , csd_repair_estimate est
   where  rep.repair_group_id = p_repair_group_id
     and  rep.repair_line_id  = est.repair_line_id;


--
BEGIN
--
   -----------------------------------
   -- Standard Start of API savepoint
   -----------------------------------
   SAVEPOINT UPDATE_GRP_REJT_STATUS;

   -----------------------------------------------------
   -- Standard call to check for call compatibility.
   -----------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ---------------------------------------------------------------
   -- Initialize message list if p_init_msg_list is set to TRUE.
   ---------------------------------------------------------------
   IF FND_API.to_Boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;

   --------------------------------------------
   -- Initialize API return status to success
   --------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --------------------
   -- Api body starts
   --------------------
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );

   ---------------------------------
   -- Check the required parameter
   ---------------------------------
  if (g_debug > 0) then
   csd_gen_utility_pvt.ADD('Check reqd parameter: Repair Group Id ');
end if;
   CSD_PROCESS_UTIL.Check_Reqd_Param
    ( p_param_value => p_repair_group_id,
      p_param_name  => 'REPAIR_GROUP_ID',
      p_api_name    => l_api_name);

   ----------------------------------
   -- Validate the Repair Group  Id
   ----------------------------------
 if (g_debug > 0) then
  csd_gen_utility_pvt.ADD('Repair Group Id');
end if;
   IF NOT( CSD_PROCESS_UTIL.Validate_repair_group_id
        ( p_repair_group_id  => p_repair_group_id )) THEN
         RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- get all repair lines having estimates for the given Repair Group
   FOR r1 in c_repairs_for_Reject (p_repair_group_id)

   LOOP

       -- initialize
       l_repair_line_id := null;

       l_repair_line_id        := r1.repair_line_id;
       l_rep_Reject_status     := r1.approval_status;
       l_rep_quantity          := r1.quantity;
       l_rep_ovn               := r1.rep_ovn;
       l_repair_estimate_id    := r1.repair_estimate_id;
       l_est_ovn               := r1.est_ovn;

      if ( l_repair_line_id is not null ) then

        l_Reject_status    := 'R';
        l_estimate_status  := 'REJECTED';
        l_event_code       := 'R';

        ----------------------------------
        -- API Body
        ----------------------------------

     if (g_debug > 0) then
      csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status convert repairs rec call');
end if;
        CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
        (p_approval_status       => l_Reject_status,
         p_object_version_number => l_rep_ovn,
         x_repln_rec             => l_rep_ord_rec
        );
if (g_debug > 0) then
        csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status Update repairs call');
end if;
        CSD_REPAIRS_PVT.Update_Repair_Order
        (p_API_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_TRUE,
         p_commit                => FND_API.G_FALSE,
       p_validation_level      => null,
         p_repair_line_id        => l_repair_line_id,
         p_Repln_Rec             => l_rep_ord_rec,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
        );

if (g_debug > 0) then
       csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status Update_Repair_Order :'||x_return_status);
end if;
       -- Check return status from the update RO  call
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     if (g_debug > 0) then
    csd_gen_utility_pvt.ADD('CSD_REPAIRS_PVT.Update_Repair_Order failed ');
    end if;
            RAISE FND_API.G_EXC_ERROR;
            --ROLLBACK TO UPDATE_GRP_REJT_STATUS;
            --return;
       ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS) then
if (g_debug > 0) then
         csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status Update RO hist call');
end if;
           CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
           (p_Api_Version_Number     => 1.0 ,
            p_init_msg_list          => 'F',
            p_commit                 => 'F',
            p_validation_level       => NULL,
            p_action_code            => 0,
            px_REPAIR_HISTORY_ID     => l_repair_history_id,
            p_OBJECT_VERSION_NUMBER  => null,
            p_REQUEST_ID             => null,
            p_PROGRAM_ID             => null,
            p_PROGRAM_APPLICATION_ID => null,
            p_PROGRAM_UPDATE_DATE    => null,
            p_CREATED_BY             => FND_GLOBAL.USER_ID,
            p_CREATION_DATE          => sysdate,
            p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_DATE       => sysdate,
            p_repair_line_id         => l_repair_line_id,
            p_EVENT_CODE             => l_event_code,
            p_EVENT_DATE             => sysdate,
            p_QUANTITY               => l_rep_quantity,
            p_PARAMN1                => null,
            p_PARAMN2                => null,
            p_PARAMN3                => null,
            p_PARAMN4                => null,
            p_PARAMN5                => null,
            p_PARAMN6                => null,
            p_PARAMN7                => null,
            p_PARAMN8                => null,
            p_PARAMN9                => null,
            p_PARAMN10               => FND_GLOBAL.USER_ID,
            p_PARAMC1                => l_Reject_status,                -- new status
            p_PARAMC2                => l_rep_Reject_status,            -- old status
            p_PARAMC3                => 'Repair Group Estimate Reject', -- travi new
            p_PARAMC4                => null,
            p_PARAMC5                => null ,
            p_PARAMC6                => null,
            p_PARAMC7                => null,
            p_PARAMC8                => null,
            p_PARAMC9                => null,
            p_PARAMC10               => null,
            p_PARAMD1                => null,
            p_PARAMD2                => null,
            p_PARAMD3                => null,
            p_PARAMD4                => null,
            p_PARAMD5                => null,
            p_PARAMD6                => null,
            p_PARAMD7                => null,
            p_PARAMD8                => null,
            p_PARAMD9                => null,
            p_PARAMD10               => null,
            p_ATTRIBUTE_CATEGORY     => null,
            p_ATTRIBUTE1             => null,
            p_ATTRIBUTE2             => null,
            p_ATTRIBUTE3             => null,
            p_ATTRIBUTE4             => null,
            p_ATTRIBUTE5             => null,
            p_ATTRIBUTE6             => null,
            p_ATTRIBUTE7             => null,
            p_ATTRIBUTE8             => null,
            p_ATTRIBUTE9             => null,
            p_ATTRIBUTE10            => null,
            p_ATTRIBUTE11            => null,
            p_ATTRIBUTE12            =>null,
            p_ATTRIBUTE13            => null,
            p_ATTRIBUTE14            => null,
            p_ATTRIBUTE15            => null,
            p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
            X_Return_Status          => x_return_status,
            X_Msg_Count              => x_msg_count,
            X_Msg_Data               => x_msg_data
           );
if (g_debug > 0) then
         csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status Validate_And_Write :'||x_return_status);
end if;
         -- Check return status from the above procedure call
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     if (g_debug > 0) then
    csd_gen_utility_pvt.ADD('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write failed ');
      end if;
       RAISE FND_API.G_EXC_ERROR;
            --ROLLBACK TO UPDATE_GRP_REJT_STATUS;
            --return;
         END IF;

          l_rep_est_rec.repair_estimate_id    := l_repair_estimate_id;
          l_rep_est_rec.repair_line_id        := l_repair_line_id;
          l_rep_est_rec.object_version_number := l_est_ovn;
          l_rep_est_rec.estimate_status       := l_estimate_status;
if (g_debug > 0) then
          csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status Update RO estimate call');
end if;
           csd_repair_estimate_pvt.update_repair_estimate
           (p_api_version      => 1.0,
            p_commit           => 'F',
            p_init_msg_list    => 'T',
            p_validation_level => fnd_api.g_valid_level_full,
            x_estimate_rec     => l_rep_est_rec,
            x_return_status    => x_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);
if (g_debug > 0) then
          csd_gen_utility_pvt.add('CSD_REPAIRS_GRP.Update_Group_Reject_Status update_repair_estimate :'||x_return_status);
end if;
     -- Check return status from the above procedure call
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     if (g_debug > 0) then
    csd_gen_utility_pvt.ADD('csd_repair_estimate_pvt.update_repair_estimate failed ');
           end if;
        RAISE FND_API.G_EXC_ERROR;
            --ROLLBACK TO UPDATE_GRP_REJT_STATUS;
            --return;
         END IF;

       END IF;
       -- End of Check return status from the update RO  call

      end if; -- repair_line_id is null

   END LOOP;
   -- End of API body.

   -- update to group is done in the call csd_repair_estimate_pvt.update_repair_estimate
   -- repair group object version number is not returned in this case

   -------------------------------
   -- Standard check for p_commit
   -------------------------------
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT;
   END IF;

   ---------------------------------------------------------------------------
   -- Standard call to get message count and if count is 1, get message info.
   ---------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO UPDATE_GRP_REJT_STATUS;
        FND_MSG_PUB.Count_And_Get
            (p_count  =>  x_msg_count,
             p_data   =>  x_msg_data );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO UPDATE_GRP_REJT_STATUS;
        FND_MSG_PUB.Count_And_Get
              ( p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO UPDATE_GRP_REJT_STATUS;
            IF  FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME ,
                 l_api_name  );
            END IF;
                FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

--
END Update_Group_Reject_Status;

End CSD_REPAIRS_GRP;

/
