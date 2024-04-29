--------------------------------------------------------
--  DDL for Package OE_GENESIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GENESIS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUGNIS.pls 120.1.12010000.4 2011/02/24 10:12:51 snimmaga ship $ */

-- AIA Enablement status
TYPE enabled_source_rec_typ IS RECORD ( enabled VARCHAR2(1) );
TYPE enabled_sources_tab_typ IS TABLE OF enabled_source_rec_typ
     INDEX BY BINARY_INTEGER;
g_enabled_sources_tab   enabled_sources_tab_typ;
g_sources_loaded  BOOLEAN := FALSE;

G_INCOMING_FROM_DOO BOOLEAN := FALSE; -- DOO Pre Exploded Kit ER 9339742
G_INCOMING_FROM_SIEBEL BOOLEAN := FALSE; -- DOO Pre Exploded Kit ER 9339742

FUNCTION source_aia_enabled (p_source_id VARCHAR2) RETURN BOOLEAN;

PROCEDURE Convert_hdr_null_to_miss
(   p_x_header_rec        IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
);

PROCEDURE Convert_hdr_pymnt_null_to_miss
(   p_x_Header_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Rec_Type
);

PROCEDURE Convert_Line_null_to_miss
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

----- O2C25
--  To get the name of inventory organization.
FUNCTION Inventory_Org
(
  p_inventory_org_id         IN  NUMBER
) RETURN VARCHAR2;

-- For flow status synchronization
TYPE  status_sync_setup_rec IS RECORD (
                                        flow_status_code  VARCHAR2(30),
                                        object_level      VARCHAR2(4)
                                      );

TYPE status_sync_setup_tab IS TABLE OF status_sync_setup_rec
  INDEX BY VARCHAR2(30);

g_status_setup_loaded   BOOLEAN := FALSE;
g_status_setup_tab      status_sync_setup_tab;

FUNCTION status_needs_sync(
                            p_flow_status_code  VARCHAR2,
                            p_object_level      VARCHAR2 DEFAULT NULL
                          )
  RETURN BOOLEAN;

-- To convert OE_ORDER_PUB_HEADER_REC_TYPE to OE_ORDER_PUB_HDR_REC25
PROCEDURE header_rec_to_hdr_rec25(
    p_header_rec IN         oe_order_pub_header_rec_type,
    x_hdr_rec25  OUT NOCOPY oe_order_pub_hdr_rec25
);

-- To convert OE_ORDER_PUB_LINE_REC_TYP to OE_ORDER_PUB_LIN_REC25
PROCEDURE line_rec_to_line_rec25(
    p_line_rec    IN          oe_order_pub_line_rec_type,
    x_line_rec25  OUT NOCOPY  oe_order_pub_line_rec25
);

-- To convert OE_ORDER_PUB_LINE_TBL_TYPE to OE_ORDER_PUB_LIN_TBL25
PROCEDURE line_tab_to_line_tab25(
    p_line_tab    IN          oe_order_pub_line_tbl_type,
    x_line_tab25  OUT NOCOPY  oe_order_pub_line_tab25
);

-- To convert OE_ACKNOWLEDGMENT_PUB_HEADER_ to OE_ACK_PUB_HDR_REC25
PROCEDURE hdr_ack_rec_to_hdr_ack_rec25(
    p_hdr_ack_rec   IN            oe_acknowledgment_pub_header_,
    x_hdr_ack_rec25 OUT NOCOPY    oe_ack_pub_hdr_rec25
);

-- To convert OE_SYNC_ORDER_PVT_HEADER_ACK_ to OE_ACK_PUB_HDR_TAB25
PROCEDURE hdr_ack_tab_to_hdr_ack_tab25(
    p_hdr_ack_tab     IN            oe_sync_order_pvt_header_ack_,
    x_hdr_ack_tab25   OUT NOCOPY    oe_ack_pub_hdr_tab25
);

-- To convert OE_ACKNOWLEDGMENT_PUB_LINE_AC to OE_ACK_PUB_LINE_REC25
PROCEDURE line_ack_rec_to_line_ack_rec25(
    p_line_ack_rec    IN          oe_acknowledgment_pub_line_ac,
    x_line_ack_rec25  OUT NOCOPY  oe_ack_pub_line_rec25
);


-- To convert OE_SYNC_ORDER_PVT_LINE_ACK_TB to OE_ACK_PUB_LINE_TAB25
PROCEDURE line_ack_tab_to_line_ack_tab25(
    p_line_ack_tab    IN          oe_sync_order_pvt_line_ack_tb,
    x_line_ack_tab25  OUT NOCOPY  oe_ack_pub_line_tab25
);

----- O2C25

procedure print_po_payload (
      P_HEADER_REC APPS.OE_ORDER_PUB.HEADER_REC_TYPE,
      P_HEADER_VAL_REC APPS.OE_ORDER_PUB.HEADER_VAL_REC_TYPE,
      P_HEADER_PAYMENT_TBL APPS.OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE,
      P_LINE_TBL APPS.OE_ORDER_PUB.LINE_TBL_TYPE
      );


END OE_GENESIS_UTIL;

/
