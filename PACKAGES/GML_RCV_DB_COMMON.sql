--------------------------------------------------------
--  DDL for Package GML_RCV_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RCV_DB_COMMON" AUTHID CURRENT_USER AS
/* $Header: GMLRCVCS.pls 120.0 2005/05/25 16:35:20 appldev noship $ */

PROCEDURE RAISE_QUALITY_EVENT(	x_transaction_id IN NUMBER,
				x_item_id	IN NUMBER,
				x_organization_id IN NUMBER);


Procedure VALIDATE_RMA_LOT_QUANTITIES( p_api_version   IN  NUMBER,
                                       p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                                       p_opm_item_id  IN NUMBER,
                                       p_lot_id       IN NUMBER,
                                       p_lot_no       IN VARCHAR2,
                                       p_sublot_no    IN VARCHAR2,
                                       p_oe_header_id IN NUMBER,
                                       p_oe_line_id   IN NUMBER,
                                       p_trx_qty      IN NUMBER,
                                       p_trx_uom      IN VARCHAR2,
                                       p_rma_lot_qty  IN NUMBER,
                                       p_rma_lot_uom  IN VARCHAR2,
                                       p_line_set_id  IN NUMBER,
                                       p_called_from  IN VARCHAR2 DEFAULT 'FORM',
                                       X_allowed          OUT NOCOPY VARCHAR2,
                                       X_allowed_quantity OUT NOCOPY NUMBER,
                                       x_return_status    OUT NOCOPY VARCHAR2);


Procedure VALIDATE_IO_LOT_QUANTITIES   (p_api_version   	IN  NUMBER,
					p_init_msg_list 	IN  VARCHAR2 := FND_API.G_FALSE,
					p_opm_item_id  	IN NUMBER,
					p_lot_id       	IN NUMBER,
					p_trx_qty      	IN NUMBER,
					p_trx_uom      	IN VARCHAR2,
					p_order_num		IN NUMBER,
					p_req_header_id	IN NUMBER,
					p_req_line_id	IN NUMBER,
					p_shipment_header_id	IN NUMBER,
					p_shipment_line_id	IN NUMBER,
					p_req_distribution_id	IN NUMBER,
					p_called_from  	IN VARCHAR2 DEFAULT 'FORM',
					X_allowed          OUT NOCOPY VARCHAR2,
					X_allowed_quantity OUT NOCOPY NUMBER,
					x_return_status    OUT NOCOPY VARCHAR2);

END GML_RCV_DB_COMMON;
 

/
