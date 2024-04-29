--------------------------------------------------------
--  DDL for Package CSI_T_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_UI_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtuis.pls 115.8 2004/05/12 00:17:41 brmanesh ship $*/

  g_pkg_name varchar2(30) := 'csi_t_ui_pkg';

  -- Name         : txn_source_rec
  -- Description  : To hold the source information of the txn details

  TYPE txn_source_rec IS RECORD(
    ORGANIZATION_ID             NUMBER        := FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID           NUMBER        := FND_API.G_MISS_NUM,
    INVENTORY_ITEM_NAME         VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ITEM_REVISION               VARCHAR2(3)   := FND_API.G_MISS_CHAR,
    SOURCE_QUANTITY             NUMBER        := FND_API.G_MISS_NUM,
    SOURCE_UOM                  VARCHAR2(3)   := FND_API.G_MISS_CHAR,
    SHIPPED_QUANTITY            NUMBER        := FND_API.G_MISS_NUM,
    FULFILLED_QUANTITY          NUMBER        := FND_API.G_MISS_NUM,
    PARTY_ID                    NUMBER        := FND_API.G_MISS_NUM,
    PARTY_ACCOUNT_ID            NUMBER        := FND_API.G_MISS_NUM,
    BILL_TO_ADDRESS_ID          NUMBER        := FND_API.G_MISS_NUM,
    SHIP_TO_ADDRESS_ID          NUMBER        := FND_API.G_MISS_NUM,
    PRIMARY_UOM                 VARCHAR2(3)   := FND_API.G_MISS_CHAR,
    SERIAL_CONTROL_FLAG         VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    LOT_CONTROL_FLAG            VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    NL_TRACKABLE_FLAG           VARCHAR2(1)   := FND_API.G_MISS_CHAR);


  -- Name         : txn_source_param_rec
  -- Description  : To hold the source information of the txn details

  TYPE txn_source_param_rec IS RECORD(
    STANDALONE_MODE             VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    SOURCE_TRANSACTION_TYPE_ID  NUMBER        := FND_API.G_MISS_NUM,
    SOURCE_TRANSACTION_TABLE    VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    SOURCE_TRANSACTION_ID       NUMBER        := FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID           NUMBER        := FND_API.G_MISS_NUM,
    INV_ORGN_ID                 NUMBER        := FND_API.G_MISS_NUM,
    ITEM_REVISION               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    TRANSACTED_QUANTITY         NUMBER        := FND_API.G_MISS_NUM,
    TRANSACTED_UOM              VARCHAR2(3)   := FND_API.G_MISS_CHAR,
    PARTY_ID                    NUMBER        := FND_API.G_MISS_NUM,
    ACCOUNT_ID                  NUMBER        := FND_API.G_MISS_NUM,
    SHIP_TO_ORG_ID              NUMBER        := FND_API.G_MISS_NUM,
    SHIP_TO_CONTACT_ID          NUMBER        := FND_API.G_MISS_NUM,
    INVOICE_TO_ORG_ID           NUMBER        := FND_API.G_MISS_NUM,
    INVOICE_TO_CONTACT_ID       NUMBER        := FND_API.G_MISS_NUM);

  FUNCTION g_miss_num RETURN number;
  FUNCTION g_miss_char RETURN varchar2;
  FUNCTION g_miss_date RETURN date;
  FUNCTION g_valid_level(p_level varchar2) RETURN number;
  FUNCTION g_boolean(p_FLAG varchar2) RETURN varchar2;
  FUNCTION get_error_constant(err_msg varchar2) RETURN varchar2;
  FUNCTION ui_txn_source_rec RETURN csi_t_ui_pvt.txn_source_rec;
  FUNCTION ui_txn_source_param_rec RETURN csi_t_ui_pvt.txn_source_param_rec;
  FUNCTION ui_txn_line_rec RETURN csi_t_datastructures_grp.txn_line_rec;
  -- Included for partner ordering changes
  FUNCTION ui_partner_order_rec RETURN oe_install_base_util.partner_order_rec;
  -- End Changes for Partner Ordering

  PROCEDURE get_src_txn_type_id(
    p_order_line_id IN            number,
    px_txn_type_id  IN OUT nocopy number,
    x_return_status    OUT nocopy varchar2);

END csi_t_ui_pvt;

 

/
