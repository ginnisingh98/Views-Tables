--------------------------------------------------------
--  DDL for Package INV_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTIONS_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: INVTXHSS.pls 120.0.12010000.3 2010/02/03 20:32:49 musinha noship $ */

TYPE Txns_History_Record_Type is RECORD
(
	transaction_id 	MTL_TXNS_HISTORY.transaction_id%TYPE,
	document_type 	MTL_TXNS_HISTORY.document_type%TYPE,
	document_direction 	MTL_TXNS_HISTORY.document_direction%TYPE,
	document_number MTL_TXNS_HISTORY.document_number%TYPE,
	entity_number 	MTL_TXNS_HISTORY.entity_number%TYPE,
	entity_type 	MTL_TXNS_HISTORY.entity_type%TYPE,
	trading_partner_id 	MTL_TXNS_HISTORY.trading_partner_id%TYPE,
	action_type 	MTL_TXNS_HISTORY.action_type%TYPE,
	transaction_status MTL_TXNS_HISTORY.transaction_status%TYPE,
	ecx_message_id 	MTL_TXNS_HISTORY.ecx_message_id%TYPE,
	event_name  	MTL_TXNS_HISTORY.event_name%TYPE,
	event_key 	MTL_TXNS_HISTORY.event_key%TYPE,
	item_type	MTL_TXNS_HISTORY.item_type%TYPE,
	internal_control_number MTL_TXNS_HISTORY.internal_control_number%TYPE,
        document_revision MTL_TXNS_HISTORY.document_revision%TYPE,
	attribute_category 	MTL_TXNS_HISTORY.attribute_category%TYPE,
	attribute1 	MTL_TXNS_HISTORY.attribute1%TYPE,
	attribute2 	MTL_TXNS_HISTORY.attribute2%TYPE,
	attribute3 	MTL_TXNS_HISTORY.attribute3%TYPE,
	attribute4 	MTL_TXNS_HISTORY.attribute4%TYPE,
	attribute5 	MTL_TXNS_HISTORY.attribute5%TYPE,
	attribute6 	MTL_TXNS_HISTORY.attribute6%TYPE,
	attribute7 	MTL_TXNS_HISTORY.attribute7%TYPE,
	attribute8 	MTL_TXNS_HISTORY.attribute8%TYPE,
	attribute9 	MTL_TXNS_HISTORY.attribute9%TYPE,
	attribute10 	MTL_TXNS_HISTORY.attribute10%TYPE,
	attribute11 	MTL_TXNS_HISTORY.attribute11%TYPE,
	attribute12 	MTL_TXNS_HISTORY.attribute12%TYPE,
	attribute13	MTL_TXNS_HISTORY.attribute13%TYPE,
	attribute14 	MTL_TXNS_HISTORY.attribute14%TYPE,
	attribute15 	MTL_TXNS_HISTORY.attribute15%TYPE,
        client_code     MTL_CLIENT_PARAMETERS.client_code%TYPE
	);


PROCEDURE Create_Update_Txns_History(
	p_txns_history_rec	IN OUT NOCOPY  Txns_History_Record_Type,
        P_xml_document_id       IN  NUMBER DEFAULT NULL,
	x_txns_id		OUT NOCOPY 	NUMBER,
	x_return_status		OUT NOCOPY 	VARCHAR2
	);

PROCEDURE Get_Txns_History(
	p_item_type		IN	VARCHAR2,
	p_event_key		IN	VARCHAR2,
	p_direction		IN	VARCHAR2,
	p_document_type		IN	VARCHAR2,
	p_txns_history_rec	OUT NOCOPY 	Txns_History_Record_Type,
	x_return_status		OUT NOCOPY 	VARCHAR2
	);

/* Should be deleted if not needed.

PROCEDURE Create_Txns_History(
	p_transaction_id	IN	NUMBER,
	p_document_type		IN	VARCHAR2,
	p_document_direction 	IN	VARCHAR2,
	p_document_number 	IN	VARCHAR2,
	p_orig_document_number 	IN	VARCHAR2,
	p_entity_number		IN	VARCHAR2,
	p_entity_type		IN 	VARCHAR2,
	p_trading_partner_id 	IN	NUMBER,
	p_action_type 		IN	VARCHAR2,
	p_transaction_status 	IN	VARCHAR2,
	p_ecx_message_id	IN	VARCHAR2,
	p_event_name  		IN	VARCHAR2,
	p_event_key 		IN	VARCHAR2,
	p_item_type		IN	VARCHAR2,
	p_internal_control_number IN	VARCHAR2,
	p_document_revision     IN      NUMBER DEFAULT NULL,
	x_return_status		OUT NOCOPY 	VARCHAR2
	);

*/

END INV_TRANSACTIONS_HISTORY_PKG;

/
