--------------------------------------------------------
--  DDL for Package WSH_IB_UI_RECON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_IB_UI_RECON_GRP" AUTHID CURRENT_USER as
/* $Header: WSHURGPS.pls 115.6 2004/04/08 01:02:22 nparikh noship $ */

--===================
-- PUBLIC VARS
--===================

--IB LOGISTICS rvishnuv
--This record structure is used to store the information about matched
-- delivery details that have been matched either from the Inbound
-- Reconciliation UI or through the Matching Algorithm.
TYPE asn_rcv_del_det_rec_type IS RECORD (
  del_detail_id_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  delivery_id_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipment_line_id_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  child_index_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  requested_qty_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipped_qty_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  received_qty_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  returned_qty_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  requested_qty_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipped_qty_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  received_qty_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  returned_qty_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shpmt_line_id_idx_tab         WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  requested_qty2_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipped_qty2_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  received_qty2_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  returned_qty2_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  requested_qty2_db_tab         WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipped_qty2_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  received_qty2_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  returned_qty2_db_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  shipment_line_id_db_tab       WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  ship_from_location_id_tab     WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  po_line_location_id_tab       WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  po_line_id_tab                WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  released_status_tab           WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
  parent_delivery_detail_id_tab	        WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  process_corr_rtv_flag_tab     WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
  process_asn_rcv_flag_tab      WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
  trip_id_tab                   WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  requested_qty_uom_tab         WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type(),
  requested_qty_uom2_tab         WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type(),
  po_header_id_tab                WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
/* Fields below added only for matching algorithm */
  picked_qty_tab                WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  picked_qty2_tab               WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  picked_qty_db_tab             WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  picked_qty2_db_tab            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  match_flag_tab                WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type := WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
  line_date_tab                 WSH_BULK_TYPES_GRP.date_Nested_Tab_Type := WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
  --latest_date_tab                WSH_BULK_TYPES_GRP.date_Nested_Tab_Type := WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
/* Fields above added only for matching algorithm */
  last_update_date_tab            WSH_BULK_TYPES_GRP.date_Nested_Tab_Type := WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
  lineCount_tab            WSH_BULK_TYPES_GRP.number_Nested_Tab_Type := WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
  transaction_type	        varchar2(30),
  shipment_header_id            number,
  max_transaction_id            number,
  object_version_number         number);

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Get_Shipment_Lines      This procedure is called only from
--                                     the Inbound Reconciliation UI
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_view_only_flag        Used to decide wether to query all
--                                     rcv shipment lines or only the ones
--                                     that user is matching.
--                                     It gets a value of "Y" if user is
--                                     reverting a transaction or viewing a
--                                     matched transaction.  Otherwise it gets
--                                     "N".
--             x_shpmt_lines_out_rec   This is a record of tables
--                                     to store the rcv shipment lines
--                                     information that needs to be displayed.
--             x_max_rcv_txn_id        Not used anymore
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to query the rcv shipment lines
--             from rcv_fte_lines_v
--             based on the transaction type and other input parameters
--             mentioned.  We are using a procedure to do this instead
--             of doing a direct query because we need to get the
--             cumulative quantities of the received quantity and
--             returned quantity for the receipt transaction.
--========================================================================
  PROCEDURE get_shipment_lines(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit         IN   VARCHAR2,
              p_shipment_header_id IN NUMBER,
              p_transaction_type   IN VARCHAR2,
              --p_max_rcv_txn_id     IN NUMBER,
              p_view_only_flag     IN VARCHAR2,
              x_shpmt_lines_out_rec OUT NOCOPY WSH_IB_SHPMT_LINE_REC_TYPE,
              x_max_rcv_txn_id OUT NOCOPY NUMBER,
              x_msg_count      OUT NOCOPY NUMBER,
              x_msg_data       OUT NOCOPY VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Revert_Matching         This procedure is called only from
--                                     the Inbound Reconciliation UI to
--                                     revert a matched ASN or a Receipt
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_object_version_number current object version of the
--                                     transaction record in
--                                     wsh_inbound_txn_history
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to revert a matched transaction (ASN or
--             RECEIPT)
--========================================================================
  PROCEDURE revert_matching(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit         IN   VARCHAR2,
              p_shipment_header_id IN NUMBER,
              p_transaction_type IN VARCHAR2,
              p_object_version_number  IN   NUMBER,
              x_msg_count      OUT NOCOPY NUMBER,
              x_msg_data       OUT NOCOPY VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Match_Shipments         This procedure is called only from
--                                     the Inbound Reconciliation UI to
--                                     match a pending ASN or a pending
--                                     Receipt or partially matched Receipt.
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_shipment_header_id    Shipment Header Id of the transaction
--             p_transaction_type      transaction type (ASN or RECEIPT)
--             p_max_rcv_txn_id        Not used any more.
--             p_process_asn_rcv_flag  Flag to decide whether to call
--                                     WSH_ASN_RECEIPT_PVT.Process_Matched_Txns
--                                     or not to match the ASN or Receipt.
--             p_process_corr_rtv_flag Flag to decide whether to call
--                                     WSH_RCV_CORR_RTV_TXN_PKG.
--                                     process_corrections_and_rtv or not
--                                     match the corrections, rtv transactions.
--             p_object_version_number current object version of the
--                                     transaction record in
--                                     wsh_inbound_txn_history
--             p_shipment_line_id_tab  table of shipment line ids.  If
--                                     this table contains any ids, we need
--                                     to delete all those records from
--                                     wsh_inbound_txn_history.
--             p_max_txn_id_tab        table of max transaction ids for
--                                     each shipment line id in
--                                     wsh_inbound_txn_history.
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to revert a matched transaction (ASN or
--             RECEIPT)
--========================================================================
  PROCEDURE match_shipments(
              p_api_version_number     IN   NUMBER,
              p_init_msg_list          IN   VARCHAR2,
              p_commit                 IN   VARCHAR2,
              p_shipment_header_id     IN   NUMBER,
              p_max_rcv_txn_id         IN   NUMBER,
              p_transaction_type       IN   VARCHAR2,
              p_process_asn_rcv_flag   IN   VARCHAR2,
              p_process_corr_rtv_flag  IN   VARCHAR2,
              p_object_version_number  IN   NUMBER,
              p_shipment_line_id_tab   IN   WSH_NUM_TBL_TYPE,
              p_max_txn_id_tab         IN   WSH_NUM_TBL_TYPE,
              x_msg_count              OUT NOCOPY NUMBER,
              x_msg_data               OUT NOCOPY VARCHAR2,
              x_return_status          OUT NOCOPY VARCHAR2);

END WSH_IB_UI_RECON_GRP;

 

/
