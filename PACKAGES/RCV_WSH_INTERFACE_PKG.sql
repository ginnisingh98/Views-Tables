--------------------------------------------------------
--  DDL for Package RCV_WSH_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_WSH_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVWSHIS.pls 120.0.12010000.8 2013/02/27 13:00:19 honwei noship $*/

  g_asn_debug         VARCHAR2(1)  := asn_debug.is_debug_on;

  PROCEDURE  create_delivery_details
    (  p_return_org_id         IN         NUMBER,
       p_interface_txn_id      IN         NUMBER,
       p_use_mtl_lot           IN         NUMBER,
       p_use_mtl_serial        IN         NUMBER,
       p_ship_to               IN         NUMBER,
       p_site_use              IN         NUMBER
    );

  PROCEDURE interface_to_rcv
    (  p_delivery_id           IN         NUMBER,
       p_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE invoke_RTP
    (  p_group_id              IN         NUMBER,
       p_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE process_txn
    (  p_header_id             IN         NUMBER,
       p_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE load_mtl_interfaces
    (  p_txn_desc              IN         VARCHAR2,
       p_wdd_rec               IN         wsh_delivery_details%rowtype,
       p_header_id             IN         NUMBER,
       p_delivery_id           IN         NUMBER);

  PROCEDURE load_rcv_interfaces
    (  p_delivery_id           IN         NUMBER,
       p_wdd_rec               IN         wsh_delivery_details%rowtype,
       p_group_id              IN         NUMBER);

  PROCEDURE load_lot_serial_interfaces
    (  p_source                IN         VARCHAR2,
       p_wdd_rec               IN         wsh_delivery_details%rowtype,
       p_parent_id             IN         NUMBER);

  PROCEDURE perform_post_tm_updates
    (  p_TM_source             IN         VARCHAR2,
       p_delivery_id           IN         NUMBER );

  PROCEDURE adjust_rcv_quantities
    (  p_delivery_detail_id    IN            NUMBER   ,
       p_item_id               IN            NUMBER   ,
       p_wdd_shipped_qty       IN            NUMBER   ,
       p_wdd_shipped_uom_code  IN            VARCHAR2 ,
       p_wdd_shipped_qty2      IN            NUMBER   ,
       p_wdd_shipped_uom_code2 IN            VARCHAR2 ,
       p_bkup_rti_id           IN            NUMBER   ,
       p_bkup_rti_quantity     IN OUT NOCOPY NUMBER   ,--RTV project phase 2
       p_bkup_rti_uom          IN            VARCHAR2 ,
       p_bkup_rti_puom         IN            VARCHAR2 ,
       p_bkup_rti_suom         IN            VARCHAR2 ,
       p_bkup_rti_src_uom      IN            VARCHAR2 );

  PROCEDURE clean_up_after_rtp
    (  p_delivery_id           IN         NUMBER,
       p_group_id              IN         NUMBER);

  TYPE RTI_id_tbl IS TABLE OF
       rcv_transactions_interface.interface_transaction_id%TYPE
       INDEX BY BINARY_INTEGER;

  PROCEDURE cancel_rtv_lines
    (  p_rti_id_tbl            IN        rcv_wsh_interface_pkg.RTI_id_tbl);

END RCV_WSH_INTERFACE_PKG;

/
