--------------------------------------------------------
--  DDL for Package WSH_RCV_CORR_RTV_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RCV_CORR_RTV_TXN_PKG" AUTHID CURRENT_USER as
/* $Header: WSHRCRVS.pls 115.4 2004/01/19 00:34:03 rvishnuv noship $ */

--===================
-- PUBLIC VARS
--===================

  -- This record is used to process the matched records (for corrections
  -- , rtvs, and rtv corrections) and update the
  -- received and returned quantities on delivery details
  -- accordingly.
  -- record_changed_flag_tab tells us whether the respective delivery detail needs to be updated or
  -- or not.
  TYPE update_detail_rec_type is RECORD (
         del_det_id_tab wsh_util_core.id_tab_type,
         requested_qty_tab wsh_util_core.id_tab_type,
         requested_qty2_tab wsh_util_core.id_tab_type,
         shipped_qty_tab wsh_util_core.id_tab_type,
         shipped_qty2_tab wsh_util_core.id_tab_type,
         received_qty_tab wsh_util_core.id_tab_type,
         received_qty2_tab wsh_util_core.id_tab_type,
         returned_qty_tab wsh_util_core.id_tab_type,
         returned_qty2_tab wsh_util_core.id_tab_type,
         shipment_line_id_tab wsh_util_core.id_tab_type,
         released_sts_tab wsh_util_core.column_tab_type,
         record_changed_flag_tab wsh_util_core.column_tab_type,
         wv_changed_flag_tab     wsh_util_core.column_tab_type,
         net_weight_tab          wsh_util_core.id_tab_type,
         gross_weight_tab        wsh_util_core.id_tab_type,
         volume_tab              wsh_util_core.id_tab_type);

  -- This record is used to handle the remaining requested quantity
  -- on open delivery details.
  -- please refer to the process_remaining_req_quantity procedure
  -- description in the package body for more details
  TYPE rem_req_qty_rec_type is RECORD(
    requested_quantity  NUMBER,
    requested_quantity_uom  VARCHAR2(3),
    requested_quantity2 NUMBER,
    requested_quantity2_uom VARCHAR2(3),
    po_line_location_id NUMBER,
    po_line_id          NUMBER);

  -- This record is used as a input record in
  -- process_remaining_req_quantity
  TYPE action_in_rec_type is RECORD(
    action_code  VARCHAR2(30));


  -- This record is used as a out record in
  -- process_corrections_and_rtv just for
  -- accomadating any additional out parameters in future
  TYPE corr_rtv_out_rec_type is RECORD(
    dummy  VARCHAR2(1));

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Process_Corrections_And_Rtv --
--                                    This procedure is called from
--                                    both Inbound Reconciliation UI and
--                                    Matching Algorithm to match the
--                                    Corrections and RTV transactions.
--
-- PARAMETERS: p_api_version           Known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_rtv_corr_in_rec       global line rec type (not used)
--             p_matched_detail_rec    record of matched delivery details
--             p_action_prms           action parameters record type
--             p_rtv_corr_out_rec      output record of the API (not used)
--             x_po_cancel_rec         output record of cancelled po lines
--             x_po_close_rec          output record of closed po lines
--             x_msg_data              text of messages
--             x_msg_count             number of messages in the list
--             x_return_status         return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to match the child transactions (Receipt Corrections, RTV, and RTV corrections) of a Receipt.
--========================================================================
  PROCEDURE process_corrections_and_rtv (
              p_rtv_corr_in_rec IN OE_WSH_BULK_GRP.Line_rec_type,
              p_matched_detail_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
              p_action_prms      IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
              p_rtv_corr_out_rec OUT NOCOPY corr_rtv_out_rec_type,
              x_po_cancel_rec OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_po_close_rec  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_msg_data      OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Process_Remaining_Req_Quantity --
--                                     This procedure is called from
--                                     process_corrections_and_rtv
--                                     and from revert_details to handle
--                                     the remaining requested quantity
--                                     that needs to be adjusted on open
--                                     delivery details.
--
-- PARAMETERS: p_rem_req_qty_rec       Record that stores the remaining
--                                     requested quantity after performing the
--                                     matching or after performing the revert.
--             p_in_rec                Input record to pass the action code
--                                     (possible values are "MATCH" and
--                                     "REVERT_MATCH").
--             x_return_status         Return status of the API

-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
  PROCEDURE process_remaining_req_quantity (
    p_rem_req_qty_rec IN rem_req_qty_rec_type,
    p_in_rec          IN action_in_rec_type,
    x_return_status OUT NOCOPY VARCHAR2);

END WSH_RCV_CORR_RTV_TXN_PKG;

 

/
