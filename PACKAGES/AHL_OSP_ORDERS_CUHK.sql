--------------------------------------------------------
--  DDL for Package AHL_OSP_ORDERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_ORDERS_CUHK" AUTHID CURRENT_USER AS
/* $Header: AHLCOSPS.pls 120.0 2005/11/11 11:49:34 jeli noship $*/
PROCEDURE process_osp_order_pre(
    p_osp_order_rec       IN  AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_osp_order_lines_tbl IN  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2);

PROCEDURE process_osp_order_post(
    p_osp_order_rec       IN  AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_osp_order_lines_tbl IN  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2);

END AHL_OSP_ORDERS_CUHK;

 

/
