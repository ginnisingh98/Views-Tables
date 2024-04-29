--------------------------------------------------------
--  DDL for Package WSH_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRANSACTIONS_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: WSHTXHSS.pls 120.0.12010000.3 2009/12/03 10:26:42 mvudugul ship $ */

C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

TYPE Txns_History_Record_Type is RECORD
(
	transaction_id 	WSH_TRANSACTIONS_HISTORY.transaction_id%TYPE,
	document_type 	WSH_TRANSACTIONS_HISTORY.document_type%TYPE,
	document_direction 	WSH_TRANSACTIONS_HISTORY.document_direction%TYPE,
	document_number WSH_TRANSACTIONS_HISTORY.document_number%TYPE,
	orig_document_number 	WSH_TRANSACTIONS_HISTORY.orig_document_number%TYPE,
	entity_number 	WSH_TRANSACTIONS_HISTORY.entity_number%TYPE,
	entity_type 	WSH_TRANSACTIONS_HISTORY.entity_type%TYPE,
	trading_partner_id 	WSH_TRANSACTIONS_HISTORY.trading_partner_id%TYPE,
	action_type 	WSH_TRANSACTIONS_HISTORY.action_type%TYPE,
	transaction_status WSH_TRANSACTIONS_HISTORY.transaction_status%TYPE,
	ecx_message_id 	WSH_TRANSACTIONS_HISTORY.ecx_message_id%TYPE,
	event_name  	WSH_TRANSACTIONS_HISTORY.event_name%TYPE,
	event_key 	WSH_TRANSACTIONS_HISTORY.event_key%TYPE,
	item_type	WSH_TRANSACTIONS_HISTORY.item_type%TYPE,
	internal_control_number WSH_TRANSACTIONS_HISTORY.internal_control_number%TYPE,
        -- R12.1.1 STANDALONE PROJECT
        document_revision WSH_TRANSACTIONS_HISTORY.document_revision%TYPE,
	attribute_category 	WSH_TRANSACTIONS_HISTORY.attribute_category%TYPE,
	attribute1 	WSH_TRANSACTIONS_HISTORY.attribute1%TYPE,
	attribute2 	WSH_TRANSACTIONS_HISTORY.attribute2%TYPE,
	attribute3 	WSH_TRANSACTIONS_HISTORY.attribute3%TYPE,
	attribute4 	WSH_TRANSACTIONS_HISTORY.attribute4%TYPE,
	attribute5 	WSH_TRANSACTIONS_HISTORY.attribute5%TYPE,
	attribute6 	WSH_TRANSACTIONS_HISTORY.attribute6%TYPE,
	attribute7 	WSH_TRANSACTIONS_HISTORY.attribute7%TYPE,
	attribute8 	WSH_TRANSACTIONS_HISTORY.attribute8%TYPE,
	attribute9 	WSH_TRANSACTIONS_HISTORY.attribute9%TYPE,
	attribute10 	WSH_TRANSACTIONS_HISTORY.attribute10%TYPE,
	attribute11 	WSH_TRANSACTIONS_HISTORY.attribute11%TYPE,
	attribute12 	WSH_TRANSACTIONS_HISTORY.attribute12%TYPE,
	attribute13	WSH_TRANSACTIONS_HISTORY.attribute13%TYPE,
	attribute14 	WSH_TRANSACTIONS_HISTORY.attribute14%TYPE,
	attribute15 	WSH_TRANSACTIONS_HISTORY.attribute15%TYPE,
        client_code     VARCHAR2(10)); -- LSP PROJECT :


PROCEDURE Create_Update_Txns_History(
	p_txns_history_rec	IN OUT NOCOPY  Txns_History_Record_Type,
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
	--R12.1.1 STANDALONE PROJECT
        p_document_revision     IN      NUMBER DEFAULT NULL,
	x_return_status		OUT NOCOPY 	VARCHAR2
	);

END WSH_TRANSACTIONS_HISTORY_PKG;

/
