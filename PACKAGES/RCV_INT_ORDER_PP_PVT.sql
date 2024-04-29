--------------------------------------------------------
--  DDL for Package RCV_INT_ORDER_PP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INT_ORDER_PP_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVPPIOS.pls 120.1.12010000.1 2008/07/24 14:36:12 appldev ship $ */

PROCEDURE derive_internal_order_header(
    p_header_record     IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_internal_order_header(
    p_header_record     IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_internal_order_header(
    p_header_record     IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type);

/* Bug 3314675. Use this procedure to default shipment_header_id for
 * the given shipment_num.
*/
PROCEDURE default_shipment_info(p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);

PROCEDURE update_header(
    p_header_record     IN OUT NOCOPY   rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_io_receive_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN OUT NOCOPY   binary_integer,
    temp_cascaded_table IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    x_header_record     IN              rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_io_trans_line(
    x_cascaded_table     in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                    in out  nocopy binary_integer,
    temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
    x_header_record      in rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_io_correct_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN OUT NOCOPY   binary_integer,
    temp_cascaded_table IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    x_header_record     IN              rcv_roi_preprocessor.header_rec_type);

PROCEDURE default_io_receive_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN              binary_integer);

PROCEDURE default_io_trans_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN              binary_integer);

PROCEDURE default_io_correct_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN              binary_integer);

PROCEDURE validate_io_receive_line(
    x_cascaded_table    IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN              binary_integer,
    x_header_record     IN              rcv_roi_preprocessor.header_rec_type);

 /* The following procedure and functions are added as part of Bug#6375015 fix.
    Procedure get_deliver_to_person_from_rsl()
    Function  get_deliver_to_person_from_rt()
    Function  get_deliver_to_person_from_rti() */

PROCEDURE get_deliver_to_person_from_rsl(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
);

FUNCTION get_deliver_to_person_from_rt(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
) RETURN NUMBER;

FUNCTION get_deliver_to_person_from_rti(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
) RETURN NUMBER;

END RCV_INT_ORDER_PP_PVT;

/
