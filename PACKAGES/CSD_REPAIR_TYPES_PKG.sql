--------------------------------------------------------
--  DDL for Package CSD_REPAIR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: csdtdrts.pls 120.4.12010000.2 2008/12/20 02:26:29 takwong ship $ */
procedure INSERT_ROW (
  X_ROWID                in OUT NOCOPY VARCHAR2,
  X_REPAIR_TYPE_ID           in NUMBER,
  X_WORKFLOW_ITEM_TYPE      in VARCHAR2,
  X_START_DATE_ACTIVE       in DATE,
  X_END_DATE_ACTIVE         in DATE,
  X_ATTRIBUTE_CATEGORY      in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10              in VARCHAR2,
  X_ATTRIBUTE11              in VARCHAR2,
  X_ATTRIBUTE12              in VARCHAR2,
  X_ATTRIBUTE13              in VARCHAR2,
  X_ATTRIBUTE14              in VARCHAR2,
  X_ATTRIBUTE15              in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE        in DATE,
  X_LAST_UPDATED_BY         in NUMBER,
  X_LAST_UPDATE_LOGIN       in NUMBER,
  X_REPAIR_MODE                 in Varchar2,
  X_INTERFACE_TO_OM_FLAG        in Varchar2,
  X_BOOK_SALES_ORDER_FLAG       in Varchar2,
  X_RELEASE_SALES_ORDER_FLAG    in Varchar2,
  X_SHIP_SALES_ORDER_FLAG       in Varchar2,
  X_AUTO_PROCESS_RMA            in Varchar2,
  X_SEEDED_FLAG                 in Varchar2,
  X_REPAIR_TYPE_REF             in Varchar2,
  X_BUSINESS_PROCESS_ID         in NUMBER,
  X_PRICE_LIST_HEADER_ID        in NUMBER,
  X_CPR_TXN_BILLING_TYPE_ID     in NUMBER,
  X_CPS_TXN_BILLING_TYPE_ID     in NUMBER,
  X_LR_TXN_BILLING_TYPE_ID      in NUMBER,
  X_LS_TXN_BILLING_TYPE_ID      in NUMBER,
  X_THIRD_SHIP_TXN_B_TYPE_ID    in NUMBER := null,
  X_THIRD_RMA_TXN_B_TYPE_ID     in NUMBER := null,
  X_MTL_TXN_BILLING_TYPE_ID   in NUMBER,
  X_LBR_TXN_BILLING_TYPE_ID   in NUMBER,
  X_EXP_TXN_BILLING_TYPE_ID   in NUMBER,
  X_INTERNAL_ORDER_FLAG       in Varchar2,
  X_THIRD_PARTY_FLAG       in Varchar2 := null,
  X_OBJECT_VERSION_NUMBER       in NUMBER,
  X_START_FLOW_STATUS_ID        in NUMBER);

procedure LOCK_ROW (
  X_REPAIR_TYPE_ID           in NUMBER,
  X_OBJECT_VERSION_NUMBER       in NUMBER
);

procedure UPDATE_ROW (
  X_REPAIR_TYPE_ID           in NUMBER,
  X_WORKFLOW_ITEM_TYPE      in VARCHAR2,
  X_START_DATE_ACTIVE       in DATE,
  X_END_DATE_ACTIVE         in DATE,
  X_ATTRIBUTE_CATEGORY      in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10              in VARCHAR2,
  X_ATTRIBUTE11              in VARCHAR2,
  X_ATTRIBUTE12              in VARCHAR2,
  X_ATTRIBUTE13              in VARCHAR2,
  X_ATTRIBUTE14              in VARCHAR2,
  X_ATTRIBUTE15              in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_LAST_UPDATE_DATE        in DATE,
  X_LAST_UPDATED_BY         in NUMBER,
  X_LAST_UPDATE_LOGIN       in NUMBER,
  X_REPAIR_MODE                 in Varchar2,
  X_INTERFACE_TO_OM_FLAG        in Varchar2,
  X_BOOK_SALES_ORDER_FLAG       in Varchar2,
  X_RELEASE_SALES_ORDER_FLAG    in Varchar2,
  X_SHIP_SALES_ORDER_FLAG       in Varchar2,
  X_AUTO_PROCESS_RMA            in Varchar2,
  X_SEEDED_FLAG                 in Varchar2,
  X_REPAIR_TYPE_REF             in Varchar2,
  X_BUSINESS_PROCESS_ID         in NUMBER,
  X_PRICE_LIST_HEADER_ID        in NUMBER,
  X_CPR_TXN_BILLING_TYPE_ID     in NUMBER,
  X_CPS_TXN_BILLING_TYPE_ID     in NUMBER,
  X_LR_TXN_BILLING_TYPE_ID      in NUMBER,
  X_LS_TXN_BILLING_TYPE_ID      in NUMBER,
  X_THIRD_SHIP_TXN_B_TYPE_ID    in NUMBER := FND_API.G_MISS_NUM,
  X_THIRD_RMA_TXN_B_TYPE_ID     in NUMBER := FND_API.G_MISS_NUM,
  X_MTL_TXN_BILLING_TYPE_ID   in NUMBER,
  X_LBR_TXN_BILLING_TYPE_ID   in NUMBER,
  X_EXP_TXN_BILLING_TYPE_ID   in NUMBER,
  X_INTERNAL_ORDER_FLAG       in Varchar2,
  X_THIRD_PARTY_FLAG       in Varchar2 :=FND_API.G_MISS_CHAR,
  X_OBJECT_VERSION_NUMBER       in NUMBER,
  X_START_FLOW_STATUS_ID        in NUMBER);

procedure DELETE_ROW (
  X_REPAIR_TYPE_ID in NUMBER
);
procedure ADD_LANGUAGE;

PROCEDURE Translate_Row
  (p_repair_type_id       IN  NUMBER
  ,p_name                 IN  VARCHAR2
  ,p_description          IN  VARCHAR2
  ,p_owner                IN  VARCHAR2
  );

PROCEDURE Load_Row
  (p_repair_type_id           IN  NUMBER
  ,p_name                     IN  VARCHAR2
  ,p_description              IN  VARCHAR2
  ,p_workflow_item_type       IN  VARCHAR2
  ,p_start_date_active        IN  DATE
  ,p_end_date_active          IN  DATE
  ,p_owner                    IN  VARCHAR2
  ,p_repair_mode              IN  VARCHAR2
  ,p_interface_to_om_flag     IN  VARCHAR2
  ,p_book_sales_order_flag    IN VARCHAR2
  ,p_release_sales_order_flag IN VARCHAR2
  ,p_ship_sales_order_flag    IN VARCHAR2
  ,p_auto_process_rma         IN VARCHAR2
  ,p_seeded_flag              IN VARCHAR2
  ,p_repair_type_ref          IN VARCHAR2
  ,p_business_process_id      IN NUMBER
  ,p_price_list_header_id     IN NUMBER
  ,p_cpr_txn_billing_type_id  IN NUMBER
  ,p_cps_txn_billing_type_id  IN NUMBER
  ,p_lr_txn_billing_type_id   IN NUMBER
  ,p_ls_txn_billing_type_id   IN NUMBER
--  ,p_third_ship_txn_b_type_id   IN NUMBER := null
--  ,p_third_rma_txn_b_type_id   IN NUMBER  := null
  ,p_mtl_txn_billing_type_id  IN NUMBER
  ,p_lbr_txn_billing_type_id  IN NUMBER
  ,p_exp_txn_billing_type_id  IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_internal_order_flag      IN VARCHAR2 := NULL
--  ,p_third_party_flag      IN VARCHAR2 := NULL
  );
end CSD_REPAIR_TYPES_PKG;

/
