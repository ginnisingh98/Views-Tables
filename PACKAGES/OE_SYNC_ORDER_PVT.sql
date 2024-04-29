--------------------------------------------------------
--  DDL for Package OE_SYNC_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SYNC_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVGNOS.pls 120.1.12010000.1 2008/07/25 08:00:00 appldev ship $ */

PROCEDURE sync_header_line(p_header_rec         IN OE_Order_Pub.Header_Rec_Type
                          ,p_line_rec           IN OE_Order_PUB.Line_Rec_Type
                          ,p_hdr_req_id         IN NUMBER DEFAULT NULL
                          ,p_lin_req_id         IN NUMBER DEFAULT NULL
                          ,p_change_type        IN VARCHAR2 DEFAULT NULL
                          ,p_hold_source_id     IN NUMBER DEFAULT NULL
                          ,p_order_hold_id      IN NUMBER DEFAULT NULL
                          ,p_hold_release_id    IN NUMBER DEFAULT NULL);

PROCEDURE  INSERT_SYNC_LINE(
                        P_LINE_REC              OE_Order_PUB.Line_Rec_Type,
                        P_CHANGE_TYPE           VARCHAR2,
                        p_req_id                NUMBER,
                        X_RETURN_STATUS         OUT NOCOPY   VARCHAR2
                        );

PROCEDURE process_order_sync(p_header_id          IN NUMBER DEFAULT NULL
                            ,p_hdr_req_id         IN NUMBER DEFAULT NULL
                            ,p_line_id            IN NUMBER DEFAULT NULL
                            ,p_lin_req_id         IN NUMBER DEFAULT NULL
                            ,p_hold_source_id     IN NUMBER DEFAULT NULL
                            ,p_order_hold_id      IN NUMBER DEFAULT NULL
                            ,p_change_type        IN VARCHAR2 DEFAULT NULL
                            ,p_hdr_ack_tbl        OUT NOCOPY oe_acknowledgment_pub.header_ack_tbl_type
                            ,p_line_ack_tbl       OUT NOCOPY oe_acknowledgment_pub.line_ack_tbl_type
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2
                            );

PROCEDURE raise_bpel_out_event(p_header_id          IN NUMBER DEFAULT NULL
                              ,p_line_id            IN NUMBER DEFAULT NULL
                              ,p_hdr_req_id         IN NUMBER DEFAULT NULL
                              ,p_lin_req_id         IN NUMBER DEFAULT NULL
                              ,p_change_type        IN VARCHAR2 DEFAULT NULL
                              ,p_hold_source_id     IN NUMBER DEFAULT NULL
                              ,p_order_hold_id      IN NUMBER DEFAULT NULL);
END OE_SYNC_ORDER_PVT;

/
