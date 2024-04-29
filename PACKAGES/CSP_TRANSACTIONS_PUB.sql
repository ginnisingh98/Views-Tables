--------------------------------------------------------
--  DDL for Package CSP_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TRANSACTIONS_PUB" AUTHID CURRENT_USER AS
/*$Header: csppttns.pls 120.2.12010000.11 2013/08/02 08:43:58 cmgandhi ship $*/
--Start of comments
--
-- API name	: CSP_TRANSACTIONS_PUB
-- Type		: Public
-- Purpose	: Maintains the transactions for Spares Management
-- Modification History
-- 19-Oct-1999	phegde	Created
--
-- End of comments

TYPE Trans_Items_Rec_Type IS RECORD
(
  INVENTORY_ITEM_ID     NUMBER        :=  NULL,
  REVISION              VARCHAR2(10)  :=  NULL,
  QUANTITY              NUMBER        :=  NULL,
  UOM_CODE              VARCHAR2(3)   :=  NULL,
  LOT_NUMBER            VARCHAR2(10)  :=  NULL,
  SERIAL_NUMBER         VARCHAR2(25)  :=  NULL,
  FRM_ORGANIZATION_ID   NUMBER        :=  NULL,
  FRM_SUBINVENTORY_CODE VARCHAR2(25)  :=  NULL,
  FRM_LOCATOR_ID        NUMBER        :=  NULL,
  TO_ORGANIZATION_ID    NUMBER        :=  NULL,
  TO_SUBINVENTORY_CODE  VARCHAR2(25)  :=  NULL,
  TO_LOCATOR_ID         NUMBER        :=  NULL,
  TO_SERIAL_NUMBER      VARCHAR2(25)  :=  NULL,
  WAYBILL_AIRBILL       VARCHAR2(60)  :=  NULL,
  FREIGHT_CODE          VARCHAR2(30)  :=  NULL,
  SHIPMENT_NUMBER       VARCHAR2(30)  :=  NULL,
  PACKLIST_LINE_ID      NUMBER        :=  NULL,
  TEMP_TRANSACTION_ID   NUMBER        :=  NULL,
  ERROR_MSG             VARCHAR2(2000)  :=  NULL,
  SHIPMENT_LINE_ID      NUMBER          := NULL,
  REASON_ID             NUMBER          := NULL
);

G_MISS_Trans_Items_Rec_Type   Trans_Items_Rec_Type;

TYPE Trans_Items_Tbl_Type IS TABLE OF Trans_Items_Rec_Type INDEX BY BINARY_INTEGER;

/* Creates a record for move order header */

PROCEDURE CREATE_MOVE_ORDER_HEADER
 (px_header_id              IN OUT NOCOPY NUMBER
 ,p_request_number          IN VARCHAR2	    := FND_API.G_MISS_CHAR
 ,p_api_version             IN NUMBER
 ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
 ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
 ,p_date_required           IN DATE
 ,p_organization_id         IN NUMBER
 ,p_from_subinventory_code  IN VARCHAR2
 ,p_to_subinventory_code    IN VARCHAR2
 ,p_address1                IN VARCHAR2
 ,p_address2                IN VARCHAR2
 ,p_address3                IN VARCHAR2
 ,p_address4                IN VARCHAR2
 ,p_city                    IN VARCHAR2
 ,p_postal_code             IN VARCHAR2
 ,p_state                   IN VARCHAR2
 ,p_province                IN VARCHAR2
 ,p_country                 IN VARCHAR2
 ,p_freight_carrier         IN VARCHAR2
 ,p_shipment_method         IN VARCHAR2
 ,p_autoreceipt_flag        IN VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
 );

/* Creates a Move Order Line */

PROCEDURE CREATE_MOVE_ORDER_LINE
 (p_api_version             IN NUMBER
 ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_FALSE
 ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
 ,px_line_id                IN OUT NOCOPY NUMBER
 ,p_header_id               IN NUMBER
 ,p_organization_id         IN NUMBER
 ,p_from_subinventory_code  IN VARCHAR2
 ,p_from_locator_id         IN NUMBER
 ,p_inventory_item_id       IN NUMBER
 ,p_revision                IN VARCHAR2
 ,p_lot_number              IN VARCHAR2
 ,p_serial_number_start     IN VARCHAR2
 ,p_serial_number_end       IN VARCHAR2
 ,p_quantity                IN NUMBER
 ,p_uom_code                IN VARCHAR2
 ,p_quantity_delivered      IN NUMBER
 ,p_to_subinventory_code    IN VARCHAR2
 ,p_to_locator_id           IN VARCHAR2
 ,p_to_organization_id      IN NUMBER
 ,p_service_request         IN VARCHAR2
 ,p_task_id                 IN NUMBER
 ,p_task_assignment_id      IN NUMBER
 ,p_customer_po             IN VARCHAR2
 ,p_date_required           IN DATE
 ,p_comments                IN VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
 );

procedure cancel_move_order_header(
  p_header_id         in  number,
  x_return_status   OUT NOCOPY varchar2,
  x_msg_count       OUT NOCOPY number,
  x_msg_data        OUT NOCOPY varchar2);

procedure cancel_move_order_line(
  p_line_id       IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2);

procedure reject_move_order_line(
  p_line_id       IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE TRANSACT_MATERIAL
  (p_api_version            IN NUMBER
  ,p_Init_Msg_List          IN VARCHAR2     := FND_API.G_FALSE
  ,p_commit                 IN VARCHAR2     := FND_API.G_FALSE
  ,px_transaction_id        IN OUT NOCOPY NUMBER
  ,px_transaction_header_id IN OUT NOCOPY NUMBER
  ,p_inventory_item_id      IN NUMBER
  ,p_organization_id        IN NUMBER
  ,p_subinventory_code      IN VARCHAR2
  ,p_locator_id             IN NUMBER
  ,p_lot_number             IN VARCHAR2
  ,p_lot_expiration_date    IN DATE := NULL
  ,p_revision               IN VARCHAR2
  ,p_serial_number          IN VARCHAR2
  ,p_to_serial_number       IN VARCHAR2 := NULL
  ,p_quantity               IN NUMBER
  ,p_uom                    IN VARCHAR2
  ,p_source_id              IN VARCHAR2
  ,p_source_line_id         IN NUMBER
  ,p_transaction_type_id    IN NUMBER
  ,p_account_id             IN NUMBER DEFAULT NULL
  ,p_transfer_to_subinventory IN VARCHAR2
  ,p_transfer_to_locator    IN NUMBER
  ,p_transfer_to_organization IN NUMBER
  ,p_online_process_flag    IN BOOLEAN := TRUE
  ,p_transaction_source_id      IN NUMBER             -- added by klou 03/30/20000
  ,p_trx_source_line_id         IN NUMBER             -- added by klou 03/30/20000
  ,p_transaction_source_name	IN VARCHAR2 DEFAULT NULL
  ,p_waybill_airbill		IN VARCHAR2 DEFAULT NULL
  ,p_shipment_number		IN VARCHAR2   DEFAULT NULL
  ,p_freight_code		IN VARCHAR2 DEFAULT NULL
  ,p_reason_id			IN NUMBER   DEFAULT NULL
  ,p_transaction_reference	IN VARCHAR2 DEFAULT NULL
  ,p_transaction_date     	IN DATE DEFAULT sysdate
  ,p_expected_delivery_date     IN DATE DEFAULT NULL
  ,p_FINAL_COMPLETION_FLAG  IN VARCHAR2 DEFAULT NULL
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2
 );

 PROCEDURE transact_temp_record(
       P_Api_Version_Number      IN      NUMBER,
       P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
       P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
       p_validation_level        IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       p_transaction_temp_id     IN      NUMBER,
       px_transaction_header_id  IN OUT NOCOPY  NUMBER,
       p_online_process_flag     IN      BOOLEAN      := FALSE,
       X_Return_Status           OUT NOCOPY     VARCHAR2,
       X_Msg_Count               OUT NOCOPY     NUMBER,
       X_Msg_Data                OUT NOCOPY     VARCHAR2
       );

PROCEDURE transact_items_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY Trans_Items_Tbl_Type,
    p_Trans_Type_id           IN      NUMBER,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

PROCEDURE transact_subinv_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY Trans_Items_Tbl_Type,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

PROCEDURE transact_intorg_transfer (
    P_Api_Version_Number      IN      NUMBER,
    P_Init_Msg_List           IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN      VARCHAR2     := FND_API.G_FALSE,
    p_Trans_Items             IN OUT NOCOPY Trans_Items_Tbl_Type,
    p_if_intransit            IN      BOOLEAN,
    X_Return_Status           OUT NOCOPY     VARCHAR2,
    X_Msg_Count               OUT NOCOPY     NUMBER,
    X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

PROCEDURE create_move_order (
    p_Trans_Items            IN OUT NOCOPY Trans_Items_Tbl_Type,
    p_date_required          IN DATE,
    p_comments               IN VARCHAR2,
    x_move_order_number      OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  );

PROCEDURE receive_requirement_trans (
    p_trans_header_id     IN NUMBER,
    p_trans_line_id       IN NUMBER,
    p_trans_record        IN Trans_Items_Rec_Type,
    p_trans_type          IN VARCHAR2,
    p_req_line_detail_id  IN NUMBER,
    p_close_short         IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  );

FUNCTION getPartsReturnOrderType (
      p_source_org_id      IN NUMBER,
      p_source_subinv      IN VARCHAR2,
      p_dest_org_id        IN NUMBER,
      p_dest_subinv        IN VARCHAR2
   ) RETURN VARCHAR2;

function res_for_rcv_trans(p_subscription_guid IN RAW,
                        p_event IN OUT NOCOPY wf_event_t) return varchar2;

type csparray is table of number;

function gen_numbers(n in number default null) return csparray PIPELINED;

END csp_transactions_pub;

/
