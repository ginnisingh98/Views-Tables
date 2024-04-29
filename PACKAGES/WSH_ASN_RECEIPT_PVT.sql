--------------------------------------------------------
--  DDL for Package WSH_ASN_RECEIPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ASN_RECEIPT_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHVASRS.pls 120.0 2005/05/26 17:54:40 appldev noship $ */

TYPE T_NUM   is TABLE OF NUMBER;
TYPE T_V1 is TABLE  OF VARCHAR2(1);
TYPE T_V250 is TABLE  OF VARCHAR2(250);
TYPE T_V30 is TABLE  OF VARCHAR2(30);
TYPE T_DATE is TABLE  OF DATE;



TYPE  local_dd_rec_type IS RECORD
(
del_detail_id 	        NUMBER,
delivery_id	        NUMBER,
shipment_line_id	NUMBER,
shpmt_line_id_idx       NUMBER,
transaction_type	VARCHAR2(50),
shipment_header_id      number,
bol			VARCHAR2(50),
trip_id			NUMBER,
lpn_id	 		NUMBER,
lpn_name			VARCHAR2(50),
psno			VARCHAR2(250),
waybill			VARCHAR2(30),
truck_num		VARCHAR2(35),
schedule_ship_date      DATE,
expected_receipt_date   DATE,
initial_pickup_date     DATE,
rcv_gross_weight	NUMBER,
rcv_gross_weight_uom_code VARCHAR2(3),
rcv_net_weight          NUMBER,
rcv_net_weight_uom_code VARCHAR2(3),
rcv_Tare_weight         NUMBER,
rcv_Tare_weight_uom_code VARCHAR2(3),
rcv_carrier_id           NUMBER
);

TYPE local_dd_rec_table_type IS TABLE OF local_dd_rec_type index by binary_integer;

TYPE update_dd_rec_type is RECORD (
delivery_detail_id  T_NUM := T_NUM(),
requested_quantity  T_NUM := T_NUM(),
requested_quantity2  T_NUM := T_NUM(),
shipped_quantity  T_NUM := T_NUM(),
returned_quantity T_NUM := T_NUM(),
received_quantity  T_NUM := T_NUM(),
shipped_quantity2  T_NUM := T_NUM(),
returned_quantity2 T_NUM := T_NUM(),
received_quantity2  T_NUM := T_NUM(),
 inventory_item_id T_NUM := T_NUM(),
 ship_from_location_id T_NUM := T_NUM(),
item_description T_V250 := T_V250(),
released_status  T_V1 := T_V1(),
rcv_shipment_line_id T_NUM := T_NUM(),
waybill_num          T_V30 := T_V30(),
released_status_db  T_V1  := T_V1(),
gross_weight  T_NUM  := T_NUM(),
net_weight  T_NUM  := T_NUM(),
volume  T_NUM  := T_NUM(),
last_update_date T_DATE := T_DATE(),
shipped_date     T_DATE := T_DATE()
);

TYPE temp_dels_rec IS RECORD(
        delivery_id NUMBER,
        header_id   NUMBER
        );
TYPE temp_dels_type IS TABLE OF temp_dels_rec INDEX BY BINARY_INTEGER;

--=============================================================================
--      API name        : Process_matched_txns
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--			  p_dd_rec IN WSH_IB_DEL_DET_REC_TYPE
--			  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--			  p_shipment_header_id IN NUMBER
--			  p_action_prms IN wsh_glbl_var_Strct_grp.action_parameters_rec_type
--			  p_max_txn_id IN NUMBER
--      OUT             :
--			  l_po_cancel_rec	OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--			  l_po_close_rec	OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--                        x_return_status            OUT     VARCHAR2(1)
--==============================================================================
PROCEDURE Process_Matched_Txns(
--p_dd_rec IN OUT NOCOPY WSH_IB_DEL_DET_REC_TYPE,
p_dd_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
p_shipment_header_id IN NUMBER,
p_max_txn_id IN NUMBER,
x_po_cancel_rec	OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
x_po_close_rec	OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2);

--=============================================================================
--      API name        : Cancel_ASN
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--			  p_header_id IN NUMBER
--			  p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--			  p_action_prms IN wsh_glbl_var_Strct_grp.action_parameters_rec_type
--      OUT             :
--                         x_return_status            OUT     VARCHAR2(1)
--==============================================================================

PROCEDURE Cancel_ASN(
p_header_id IN NUMBER,
p_action_prms IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
x_return_status OUT NOCOPY VARCHAR2) ;




--=============================================================================
 --      API name        : Unassign_open_det_from_del
 --      Type            : Private.
 --      Function        :
 --      Pre-reqs        : None.
 --      Parameters      :
 --      IN              :
 --                        del_ids            IN   wsh_util_core.id_tab_type
 --      OUT             :
 --                         x_return_status   OUT     VARCHAR2
-- ==============================================================================
PROCEDURE Unassign_open_det_from_del(
p_del_ids            IN   wsh_util_core.id_tab_type,
p_action_prms  IN wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
p_shipment_header_id         IN      NUMBER,
x_return_status   OUT NOCOPY  VARCHAR2 );


--=============================================================================
--      API name        : initialize_txns
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			p_local_dd_rec	              IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
--			p_index_dd_ids_cache      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_index_dd_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_index_del_ids_cache     IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_index_del_ids_ext_cache IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_del_ids_del_ids_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_del_ids_del_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
--			p_uniq_del_ids_tab           IN OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE
--			p_action_prms         IN OUT NOCOPY wsh_glbl_var_strct_grp.action_parameters_rec_type
--			x_return_status          OUT NOCOPY VARCHAR2
-- =============================================================================
PROCEDURE initialize_txns(
p_local_dd_rec	              IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
p_index_dd_ids_cache      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_dd_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_del_ids_cache     IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_del_ids_ext_cache IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_del_ids_del_ids_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_del_ids_del_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_uniq_del_ids_tab           IN OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
p_action_prms         IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
p_shipment_header_id         IN      NUMBER,
x_return_status          OUT NOCOPY VARCHAR2  );

--=============================================================================
--      API name        : reconfigure_del_trips
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                       dd_rec IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE
 --		         x_return_status OUT VARCHAR2
-- =============================================================================
PROCEDURE reconfigure_del_trips(
p_local_dd_rec IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
p_action_prms    IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
x_lpnGWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnGWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
p_shipment_header_id         IN      NUMBER,
x_return_status  OUT NOCOPY VARCHAR2);

--=============================================================================
--      API name        : SORT_DD_REC
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                        p_local_dd_rec IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE
--                        x_return_status OUT VARCHAR2
-- =============================================================================

PROCEDURE sort_dd_rec(
        p_local_dd_rec IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
        x_return_status  OUT NOCOPY VARCHAR2);

--=============================================================================
--      API name        :Synch_bols
--      Type            :Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                       p_del_id      IN      NUMBER,
--                       p_bol         IN      VARCHAR2
--			 p_action_prms   IN      wsh_glbl_var_strct_grp.dd_action_parameters_rec_type
--                       x_return_status  OUT NOCOPY VARCHAR2
-- =============================================================================
Procedure Synch_bols(
p_del_id        IN      NUMBER,
p_bol           IN      VARCHAR2,
p_action_prms   IN      wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
x_return_status         OUT NOCOPY VARCHAR2) ;

--=============================================================================
--      API name        : update_status
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                        action_code   IN   VARCHAR2
--                        p_del_ids     IN   wsh_util_core.id_tab_type
--                        p_trip_ids    IN   wsh_util_core.id_tab_type
--                        p_stop_ids    IN   wsh_util_core.id_tab_type
--			  p_shipment_header_id_tab   IN wsh_util_core.id_tab_type,
--			  p_initial_pickup_date_tab IN wsh_util_core.Date_Tab_Type
--			  p_expected_receipt_date_tab IN wsh_util_core.Date_Tab_Type
--                        p_local_dd_rec              IN LOCAL_DD_REC_TABLE_TYPE,
--			  x_return_status  OUT VARCHAR2
-- ============================================================================

PROCEDURE update_status (
p_action_prms    IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
p_del_ids     IN   wsh_util_core.id_tab_type,
p_trip_ids    IN   wsh_util_core.id_tab_type,
p_stop_ids    IN   wsh_util_core.id_tab_type,
p_shipment_header_id_tab   IN wsh_util_core.id_tab_type,
p_initial_pickup_date_tab IN wsh_util_core.Date_Tab_Type ,
p_expected_receipt_date_tab IN wsh_util_core.Date_Tab_Type  ,
p_rcv_carrier_id_tab        IN wsh_util_core.Id_Tab_Type,
p_local_dd_rec              IN LOCAL_DD_REC_TABLE_TYPE,
x_lpnGWTcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnGWTcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcachetbl                IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcacheExttbl             IN  OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_return_status  OUT NOCOPY VARCHAR2) ;

--=============================================================================
--      API name        : consolidate_qty
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                        p_consolidate_qty_rec IN OUT  WSH_ASN_RECEIPT_PVT.consolidate_qty_rec_type
--			  p_sli_qty_cache	IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			  p_sli_qty_ext_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--                        p_remaining_qty       IN      NUMBER
--                        po_shipment_line_id   IN      NUMBER
--                        x_return_status       OUT  VARCHAR2
-- ============================================================================

PROCEDURE consolidate_qty(
p_sli_qty_cache	      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_sli_qty_ext_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_remaining_qty       IN OUT NOCOPY NUMBER,
po_shipment_line_id   IN            NUMBER,
x_return_status          OUT NOCOPY VARCHAR2);

Procedure populate_update_dd_rec(
  p_dd_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
  p_index IN NUMBER,
  p_line_rec IN OE_WSH_BULK_GRP.line_rec_type,
  p_gross_weight IN NUMBER DEFAULT NULL,
  p_net_weight IN NUMBER DEFAULT NULL,
  p_volume IN NUMBER DEFAULT NULL,
  x_release_status IN VARCHAR2,
  l_update_dd_rec IN OUT NOCOPY update_dd_rec_type,
  x_lpnIdCacheTbl IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
  x_lpnIdCacheExtTbl IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
  x_return_status OUT NOCOPY VARCHAR2);


---
--=============================================================================
--      API name        : create_update_waybill_psno_bol
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			  p_local_dd_rec  IN OUT  LOCAL_DD_REC_TABLE_TYPE
--			  l_loop_index IN NUMBER
--			  pack_ids IN OUT  WSH_UTIL_CORE.id_tab_type
--			  curr_del IN OUT  NUMBER
--			  curr_bol IN OUT  VARCHAR2
--			  curr_lpn IN OUT  NUMBER
--			  l_psno   IN OUT  VARCHAR2
--			  l_waybill   IN OUT  VARCHAR2
--			  l_use_lpns  IN OUT  NUMBER
--			  l_psno_flag IN OUT  NUMBER
--			  l_trigger   IN OUT  NUMBER
--			  l_waybill_flag IN OUT  NUMBER
--			  temp_trips IN OUT  WSH_UTIL_CORE.id_tab_type
--			  temp_dels  IN OUT  temp_dels_type
--			  x_return_status OUT  VARCHAR2
-- ============================================================================


PROCEDURE create_update_waybill_psno_bol(
  p_local_dd_rec  IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
  l_loop_index    IN NUMBER,
  pack_ids        IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  curr_del        IN OUT NOCOPY NUMBER,
  curr_bol	  IN OUT NOCOPY VARCHAR2,
  curr_lpn	  IN OUT NOCOPY NUMBER,
  curr_lpn_name	  IN OUT NOCOPY VARCHAR2,
  curr_del_det    IN OUT NOCOPY NUMBER,
  l_psno	  IN OUT NOCOPY VARCHAR2,
  l_waybill       IN OUT NOCOPY VARCHAR2,
  l_psno_flag     IN OUT NOCOPY NUMBER,
  l_trigger       IN OUT NOCOPY NUMBER,
  l_waybill_flag  IN OUT NOCOPY NUMBER,
  temp_dels       IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  p_action_prms   IN OUT NOCOPY wsh_glbl_var_strct_grp.dd_action_parameters_rec_type,
  x_return_status OUT NOCOPY VARCHAR2
 );




--=============================================================================
--      API name        : create_update_inbound_document
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			p_document_number IN VARCHAR2,
--		        p_entity_name IN VARCHAR2,
--			p_delivery_id IN NUMBER,
--		        p_transaction_type IN VARCHAR2,
--			x_return_status OUT NOCOPY  VARCHAR2
-- ============================================================================


  PROCEDURE create_update_inbound_document (
     p_document_number IN VARCHAR2,
     p_entity_name IN VARCHAR2,
     p_delivery_id IN NUMBER,
     p_transaction_type IN VARCHAR2,
     x_return_status OUT NOCOPY  VARCHAR2);



--=============================================================================
--      API name        : cancel_close_pending_txns
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--			  p_po_cancel_rec	IN OE_WSH_BULK_GRP.line_rec_type
--			  p_po_close_rec	IN OE_WSH_BULK_GRP.line_rec_type
--      OUT             :
--                        x_return_status            OUT     VARCHAR2(1)
--==============================================================================

PROCEDURE cancel_close_pending_txns(
p_po_cancel_rec	IN OE_WSH_BULK_GRP.line_rec_type,
p_po_close_rec	IN OE_WSH_BULK_GRP.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2);



END WSH_ASN_RECEIPT_PVT;

 

/
