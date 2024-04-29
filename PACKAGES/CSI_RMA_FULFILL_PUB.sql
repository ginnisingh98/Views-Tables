--------------------------------------------------------
--  DDL for Package CSI_RMA_FULFILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_RMA_FULFILL_PUB" AUTHID CURRENT_USER AS
/* $Header: csipirfs.pls 120.0 2005/05/25 02:31:03 appldev noship $ */

  PROCEDURE get_rma_info(
    p_rma_line_id        IN  number,
    x_rma_line_rec       OUT NOCOPY csi_order_ship_pub.mtl_txn_rec,
    x_error_message      OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE decode_message(
    p_msg_header           IN  xnp_message.msg_header_rec_type,
    p_msg_text             IN  varchar2,
    x_return_status        OUT NOCOPY varchar2,
    x_error_message        OUT NOCOPY varchar2,
    x_rma_line_rec         OUT NOCOPY csi_order_ship_pub.mtl_txn_rec);

  PROCEDURE rma_fulfillment(
    p_rma_line_id    IN  number,
    p_message_id     IN  number,
    x_return_status  OUT NOCOPY varchar2,
    px_trx_error_rec IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

  PROCEDURE fulfill_rma_line(
    p_rma_line_rec   IN   oe_order_lines_all%rowtype,
    p_csi_txn_rec    IN   csi_datastructures_pub.transaction_rec,
    p_line_dtl_tbl   IN   csi_t_datastructures_grp.txn_line_detail_tbl,
    px_trx_error_rec IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_msg_count      OUT NOCOPY number,
    x_msg_data       OUT NOCOPY varchar2,
    x_return_status  OUT NOCOPY varchar2);

END csi_rma_fulfill_pub;

 

/
