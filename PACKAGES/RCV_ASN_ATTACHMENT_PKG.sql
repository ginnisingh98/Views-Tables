--------------------------------------------------------
--  DDL for Package RCV_ASN_ATTACHMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ASN_ATTACHMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVASNAS.pls 115.0 2004/01/17 23:07:14 mji noship $*/


TYPE asn_attach_id_tbl_type IS TABLE OF
     RCV_TRANSACTIONS_INTERFACE.asn_attach_id%TYPE INDEX BY BINARY_INTEGER;


PROCEDURE copy_asn_line_attachment (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN 	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count		OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2,
		p_interface_txn_id	IN 	NUMBER,
		p_shipment_line_id	IN 	NUMBER );

PROCEDURE delete_asn_intf_attachments (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN  	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count         	OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2 );


PROCEDURE delete_line_attachment (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN  	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count		OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2,
		p_asn_attach_id 	IN  	NUMBER );


END RCV_ASN_ATTACHMENT_PKG;

 

/
