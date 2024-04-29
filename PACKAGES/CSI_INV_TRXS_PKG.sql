--------------------------------------------------------
--  DDL for Package CSI_INV_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_TRXS_PKG" AUTHID CURRENT_USER as
-- $Header: csiivtxs.pls 120.4.12010000.1 2008/07/25 08:09:04 appldev ship $

x_csi_install        VARCHAR2(1) := NULL;
G_IN_PROCESS         CONSTANT VARCHAR2(30) := 'IN_PROCESS';
G_IN_INVENTORY       CONSTANT VARCHAR2(30) := 'IN_INVENTORY';
G_IN_SERVICE         CONSTANT VARCHAR2(30) := 'IN_SERVICE';
G_OUT_OF_SERVICE     CONSTANT VARCHAR2(30) := 'OUT_OF_SERVICE';
G_IN_TRANSIT         CONSTANT VARCHAR2(30) := 'IN_TRANSIT';
G_INSTALLED          CONSTANT VARCHAR2(30) := 'INSTALLED';
G_COMPLETE           CONSTANT VARCHAR2(30) := 'COMPLETE';
G_PENDING            CONSTANT VARCHAR2(30) := 'PENDING';
G_IB_UPDATE          CONSTANT VARCHAR2(30)  := 'IB_UPDATE';
G_TXN_ERROR          CONSTANT VARCHAR2(1)  := 'E';
G_IN_WIP             CONSTANT VARCHAR2(30) := 'IN_WIP';

  TYPE MTL_ITEM_REC_TYPE IS RECORD
  (   INVENTORY_ITEM_ID               NUMBER       := FND_API.G_MISS_NUM,
      ORGANIZATION_ID                 NUMBER       := FND_API.G_MISS_NUM,
      SUBINVENTORY_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR,
      REVISION                        VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      TRANSACTION_QUANTITY            NUMBER       := FND_API.G_MISS_NUM,
      PRIMARY_QUANTITY                NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_UOM                 VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      PRIMARY_UOM_CODE                VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      TRANSACTION_TYPE_ID             NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_ACTION_ID           NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_SOURCE_ID           NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_SOURCE_TYPE_ID      NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_LOCATOR_ID             NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_ORGANIZATION_ID        NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_SUBINVENTORY           VARCHAR2(10) := FND_API.G_MISS_CHAR,
      LOCATOR_ID                      NUMBER       := FND_API.G_MISS_NUM,
      SOURCE_PROJECT_ID               NUMBER       := FND_API.G_MISS_NUM,
      SOURCE_TASK_ID                  NUMBER       := FND_API.G_MISS_NUM,
      FROM_PROJECT_ID                 NUMBER       := FND_API.G_MISS_NUM,
      FROM_TASK_ID                    NUMBER       := FND_API.G_MISS_NUM,
      TO_PROJECT_ID                   NUMBER       := FND_API.G_MISS_NUM,
      TO_TASK_ID                      NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_DATE                DATE         := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY                 NUMBER       := FND_API.G_MISS_NUM,
      SERIAL_NUMBER                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
      LOT_NUMBER                      VARCHAR2(80) := FND_API.G_MISS_CHAR, --bnarayan
      HR_LOCATION_ID                  NUMBER       := FND_API.G_MISS_NUM,
      PO_DISTRIBUTION_ID              NUMBER       := FND_API.G_MISS_NUM,
      SUBINV_LOCATION_ID              NUMBER       := FND_API.G_MISS_NUM,
      SHIPMENT_NUMBER                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
      TRX_SOURCE_LINE_ID              NUMBER       := FND_API.G_MISS_NUM,
      MOVE_ORDER_LINE_ID              NUMBER       := FND_API.G_MISS_NUM,
      SERIAL_NUMBER_CONTROL_CODE      NUMBER       := FND_API.G_MISS_NUM,
      SHIP_TO_LOCATION_ID             NUMBER       := FND_API.G_MISS_NUM,
      LOT_CONTROL_CODE                NUMBER       := FND_API.G_MISS_NUM,
      REVISION_QTY_CONTROL_CODE       NUMBER       := FND_API.G_MISS_NUM,
      COMMS_NL_TRACKABLE_FLAG         VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      LOCATION_CONTROL_CODE           NUMBER       := FND_API.G_MISS_NUM,
      PHYSICAL_ADJUSTMENT_ID          NUMBER       := FND_API.G_MISS_NUM,
      CYCLE_COUNT_ID                  NUMBER       := FND_API.G_MISS_NUM,
      --R12 changes,Included to track rebuildables and asset numbers
      EAM_ITEM_TYPE		      NUMBER	   := FND_API.G_MISS_NUM,
      RCV_TRANSACTION_ID              NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_TRANSACTION_ID         NUMBER       := FND_API.G_MISS_NUM);

   TYPE MTL_ITEM_TBL_TYPE is TABLE OF MTL_ITEM_REC_TYPE INDEX BY BINARY_INTEGER;

   TYPE MTL_TRX_TYPE is RECORD
   (MTL_TRANSACTION_ID              NUMBER);


   PROCEDURE RECEIPT_INVENTORY(p_transaction_id     IN  NUMBER,
                               p_message_id         IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE MISC_RECEIPT(p_transaction_id     IN  NUMBER,
                          p_message_id         IN  NUMBER,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);


   PROCEDURE MISC_ISSUE(p_transaction_id     IN  NUMBER,
                        p_message_id         IN  NUMBER,
                        x_return_status      OUT NOCOPY VARCHAR2,
                        x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE PHYSICAL_INVENTORY(p_transaction_id     IN  NUMBER,
                                p_message_id         IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE CYCLE_COUNT(p_transaction_id     IN  NUMBER,
                         p_message_id         IN  NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE GET_TRANSACTION_RECS(p_transaction_id     IN  NUMBER,
                                  x_mtl_item_tbl       OUT NOCOPY  CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_error_message      OUT NOCOPY VARCHAR2);

   PROCEDURE DECODE_MESSAGE (P_Msg_Header      IN XNP_MESSAGE.Msg_Header_Rec_Type,
	                     P_Msg_Text	       IN  VARCHAR2,
	                     X_Return_Status   OUT NOCOPY VARCHAR2,
	                     X_Error_Message   OUT NOCOPY VARCHAR2,
                             X_MTL_TRX_REC     OUT NOCOPY CSI_INV_TRXS_PKG.MTL_TRX_TYPE);

PROCEDURE Check_item_Trackable(
     p_inventory_item_id IN NUMBER,
     p_nl_trackable_flag OUT NOCOPY VARCHAR2);

PROCEDURE get_asset_creation_code(
     p_inventory_item_id IN NUMBER,
     p_asset_creation_code OUT NOCOPY VARCHAR2);

PROCEDURE check_depreciable(
     p_inventory_item_id IN NUMBER,
     p_depreciable OUT NOCOPY VARCHAR2);

PROCEDURE get_master_organization(p_organization_id          IN  NUMBER,
                                  p_master_organization_id   OUT NOCOPY NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_error_message            OUT NOCOPY VARCHAR2);

PROCEDURE build_error_string (
        p_string            IN OUT NOCOPY VARCHAR2,
        p_attribute         IN     VARCHAR2,
        p_value             IN     VARCHAR2);

PROCEDURE get_string_value (
        p_string            IN      VARCHAR2,
        p_attribute         IN      VARCHAR2,
        x_value             OUT NOCOPY     VARCHAR2);

FUNCTION is_csi_installed RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(is_eib_installed, WNDS, WNPS);

FUNCTION get_neg_inv_code (p_org_id in NUMBER) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(get_neg_inv_code, WNDS);

FUNCTION Get_Default_Status_Id(p_transaction_id IN NUMBER) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(get_default_status_id, WNDS);

FUNCTION Init_Instance_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Query_Rec;
FUNCTION Init_Instance_Create_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec;

FUNCTION Init_Instance_Update_Rec RETURN CSI_DATASTRUCTURES_PUB.Instance_Rec;

FUNCTION Init_Txn_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Rec;

FUNCTION Init_Txn_Error_Rec RETURN CSI_DATASTRUCTURES_PUB.TRANSACTION_Error_Rec;

FUNCTION Init_Party_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Tbl;

FUNCTION Init_Account_Tbl RETURN CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;

FUNCTION Init_ext_attrib_values_tbl RETURN CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;

FUNCTION Init_Pricing_Attribs_Tbl RETURN CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;

FUNCTION Init_Org_Assignments_Tbl RETURN CSI_DATASTRUCTURES_PUB.organization_units_tbl;

FUNCTION Init_Asset_Assignment_Tbl RETURN CSI_DATASTRUCTURES_PUB.instance_asset_tbl;

FUNCTION Get_Dflt_Project_Location_Id RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(Get_Dflt_Project_Location_Id, WNDS);

FUNCTION Get_Location_Type_Code(P_Location_Meaning IN VARCHAR2) RETURN VARCHAR2;

--PRAGMA RESTRICT_REFERENCES(Get_Location_Type_Code, WNDS);

FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2, P_App_Short_Name IN VARCHAR2) RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(Get_Txn_Type_Id, WNDS);

FUNCTION Get_Txn_Type_Code(P_Txn_Id IN NUMBER) RETURN VARCHAR2;

--PRAGMA RESTRICT_REFERENCES(Get_Txn_Type_Code, WNDS);

FUNCTION Get_Txn_Status_Code(P_Txn_Status IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Txn_Action_Code(P_Txn_Action IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Fnd_Employee_Id(P_Last_Updated IN NUMBER) RETURN NUMBER;

FUNCTION Init_Instance_Asset_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Query_Rec;

FUNCTION Init_Instance_Asset_Rec RETURN CSI_DATASTRUCTURES_PUB.instance_asset_Rec;

FUNCTION Init_Party_Query_Rec RETURN CSI_DATASTRUCTURES_PUB.Party_Query_Rec;

FUNCTION get_inv_name (p_transaction_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE log_csi_error(p_trx_error_rec IN CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

PROCEDURE create_csi_txn(px_txn_rec IN OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_REC,
                         x_error_message OUT NOCOPY VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE get_redeploy_flag(
              p_inventory_item_id IN NUMBER
             ,p_serial_number     IN VARCHAR2
             ,p_transaction_date  IN DATE
             ,x_redeploy_flag     OUT NOCOPY VARCHAR2
             ,x_return_status     OUT NOCOPY VARCHAR2
             ,x_error_message     OUT NOCOPY VARCHAR2);

FUNCTION valid_ib_txn (p_transaction_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE set_item_attr_query_values(
   l_mtl_item_tbl          IN  CSI_INV_TRXS_PKG.MTL_ITEM_TBL_TYPE,
   table_index             IN  NUMBER,
   p_source                IN  VARCHAR2,
   x_instance_query_rec    OUT NOCOPY csi_datastructures_pub.instance_query_rec,
   x_return_status         OUT NOCOPY varchar2);

END CSI_INV_TRXS_PKG;

/
