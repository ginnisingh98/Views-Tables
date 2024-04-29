--------------------------------------------------------
--  DDL for Package RCV_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTIONS_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTXHSS.pls 120.0.12010000.6 2010/01/22 21:42:10 smididud noship $
 * */

TYPE Txns_History_Record_Type is RECORD
(
        transaction_id           MTL_TXNS_HISTORY.transaction_id%TYPE,
        document_type            MTL_TXNS_HISTORY.document_type%TYPE,
        document_direction       MTL_TXNS_HISTORY.document_direction%TYPE,
        document_number          MTL_TXNS_HISTORY.document_number%TYPE,
        entity_number            MTL_TXNS_HISTORY.entity_number%TYPE,
        entity_type              MTL_TXNS_HISTORY.entity_type%TYPE,
        trading_partner_id       MTL_TXNS_HISTORY.trading_partner_id%TYPE,
        action_type              MTL_TXNS_HISTORY.action_type%TYPE,
        transaction_status       MTL_TXNS_HISTORY.transaction_status%TYPE,
        event_name               MTL_TXNS_HISTORY.event_name%TYPE,
        event_key                MTL_TXNS_HISTORY.event_key%TYPE,
        item_type                MTL_TXNS_HISTORY.item_type%TYPE,
        document_revision        MTL_TXNS_HISTORY.document_revision%TYPE,
        attribute_category       MTL_TXNS_HISTORY.attribute_category%TYPE,
        attribute1               MTL_TXNS_HISTORY.attribute1%TYPE,
        attribute2               MTL_TXNS_HISTORY.attribute2%TYPE,
        attribute3               MTL_TXNS_HISTORY.attribute3%TYPE,
        attribute4               MTL_TXNS_HISTORY.attribute4%TYPE,
        attribute5               MTL_TXNS_HISTORY.attribute5%TYPE,
        attribute6               MTL_TXNS_HISTORY.attribute6%TYPE,
        attribute7               MTL_TXNS_HISTORY.attribute7%TYPE,
        attribute8               MTL_TXNS_HISTORY.attribute8%TYPE,
        attribute9               MTL_TXNS_HISTORY.attribute9%TYPE,
        attribute10              MTL_TXNS_HISTORY.attribute10%TYPE,
        attribute11              MTL_TXNS_HISTORY.attribute11%TYPE,
        attribute12              MTL_TXNS_HISTORY.attribute12%TYPE,
        attribute13              MTL_TXNS_HISTORY.attribute13%TYPE,
        attribute14              MTL_TXNS_HISTORY.attribute14%TYPE,
        attribute15              MTL_TXNS_HISTORY.attribute15%TYPE,
        client_code              MTL_CLIENT_PARAMETERS.client_code%TYPE
        );


PROCEDURE Create_Update_Txns_History(
        p_txns_history_rec   IN OUT NOCOPY  Txns_History_Record_Type,
        p_xml_document_id    IN          NUMBER  DEFAULT NULL,
        x_txns_id            OUT NOCOPY  NUMBER,
        x_return_status      OUT NOCOPY  VARCHAR2
        );

PROCEDURE Get_Txns_History(
        p_item_type          IN        VARCHAR2,
        p_event_key          IN        VARCHAR2,
        p_direction          IN        VARCHAR2,
        p_document_type      IN        VARCHAR2,
        p_txns_history_rec   OUT NOCOPY   Txns_History_Record_Type,
        x_return_status      OUT NOCOPY   VARCHAR2
        );

END RCV_TRANSACTIONS_HISTORY_PKG;

/
