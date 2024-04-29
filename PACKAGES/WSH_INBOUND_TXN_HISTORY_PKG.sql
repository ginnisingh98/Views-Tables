--------------------------------------------------------
--  DDL for Package WSH_INBOUND_TXN_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INBOUND_TXN_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: WSHIBTXS.pls 120.0 2005/05/26 18:01:28 appldev noship $ */

    --
    --
--===================
-- PUBLIC VARS
--===================
    C_ASN                             CONSTANT  VARCHAR2(30)  := 'ASN';
    C_CANCEL_ASN                      CONSTANT  VARCHAR2(30)  := 'CANCEL_ASN';
    C_RECEIPT                         CONSTANT  VARCHAR2(30)  := 'RECEIPT';
    C_RECEIPT_CORRECTION              CONSTANT  VARCHAR2(30)  := 'RECEIPT_CORRECTION';
    C_RTV                             CONSTANT  VARCHAR2(30)  := 'RTV';
    C_RTV_CORRECTION                  CONSTANT  VARCHAR2(30)  := 'RTV_CORRECTION';
    C_RECEIPT_ADD                     CONSTANT  VARCHAR2(30)  := 'RECEIPT_ADD';
    C_RECEIPT_HEADER_UPD              CONSTANT  VARCHAR2(30)  := 'RECEIPT_HEADER_UPD';
    C_RECEIPT_CORRECTION_POSITIVE     CONSTANT  VARCHAR2(30)  := 'RECEIPT_CORRECTION_POSITIVE';
    C_RECEIPT_CORRECTION_NEGATIVE     CONSTANT  VARCHAR2(30)  := 'RECEIPT_CORRECTION_NEGATIVE';
    C_RTV_CORRECTION_POSITIVE         CONSTANT  VARCHAR2(30)  := 'RTV_CORRECTION_POSITIVE';
    C_RTV_CORRECTION_NEGATIVE         CONSTANT  VARCHAR2(30)  := 'RTV_CORRECTION_NEGATIVE';
    --
    --
    C_PENDING                         CONSTANT  VARCHAR2(30)  := 'PENDING_MATCHING';
    C_MATCHED                         CONSTANT  VARCHAR2(30)  := 'MATCHED';
    C_PENDING_PARENT_MATCHING         CONSTANT  VARCHAR2(30)  := 'PENDING_PARENT_MATCHING';
    C_MATCHED_AND_CHILD_PENDING       CONSTANT  VARCHAR2(30)  := 'MATCHED_AND_CHILD_PENDING';
    C_CANCELLED                       CONSTANT  VARCHAR2(30)  := 'CANCELLED';
    C_TRIGGERED                       CONSTANT  VARCHAR2(30)  := 'TRIGGERED';
    C_GENERATED                       CONSTANT  VARCHAR2(30)  := 'GENERATED';
    C_PROCESSED                       CONSTANT  VARCHAR2(30)  := 'PROCESSED';


  TYPE ib_txn_history_rec_type is RECORD (
           TRANSACTION_ID    NUMBER,
           RECEIPT_NUMBER    VARCHAR2(40), --vendor merge change
           REVISION_NUMBER   VARCHAR2(30),
           SHIPMENT_NUMBER   VARCHAR2(30),
           TRANSACTION_TYPE  VARCHAR2(50),
           SHIPMENT_HEADER_ID NUMBER,
           PARENT_SHIPMENT_HEADER_ID NUMBER,
           ORGANIZATION_ID NUMBER,
           SUPPLIER_ID NUMBER,
           SHIPPED_DATE DATE,
           RECEIPT_DATE DATE,
           STATUS  VARCHAR2(50),
           MAX_RCV_TRANSACTION_ID NUMBER,
           CARRIER_ID NUMBER,
           MATCH_REVERTED_BY NUMBER,
           MATCHED_BY NUMBER,
           SHIPMENT_LINE_ID NUMBER,
           OBJECT_VERSION_NUMBER NUMBER,
	   SHIP_FROM_LOCATION_ID NUMBER);   --  IB-Phase-2

  TYPE inboundTxnHistory_recTbl_type is RECORD
    (
      TRANSACTION_ID              WSH_BULK_TYPES_GRP.tbl_num,
      RECEIPT_NUMBER              WSH_BULK_TYPES_GRP.tbl_v30,
      REVISION_NUMBER             WSH_BULK_TYPES_GRP.tbl_v30,
      SHIPMENT_NUMBER             WSH_BULK_TYPES_GRP.tbl_v30,
      TRANSACTION_TYPE            WSH_BULK_TYPES_GRP.tbl_v50,
      SHIPMENT_HEADER_ID          WSH_BULK_TYPES_GRP.tbl_num,
      PARENT_SHIPMENT_HEADER_ID   WSH_BULK_TYPES_GRP.tbl_num,
      ORGANIZATION_ID             WSH_BULK_TYPES_GRP.tbl_num,
      SUPPLIER_ID                 WSH_BULK_TYPES_GRP.tbl_num,
      SHIPPED_DATE                WSH_BULK_TYPES_GRP.tbl_date,
      RECEIPT_DATE                WSH_BULK_TYPES_GRP.tbl_date,
      STATUS                      WSH_BULK_TYPES_GRP.tbl_v50,
      MAX_RCV_TRANSACTION_ID      WSH_BULK_TYPES_GRP.tbl_num,
      CARRIER_ID                  WSH_BULK_TYPES_GRP.tbl_num,
      MATCH_REVERTED_BY           WSH_BULK_TYPES_GRP.tbl_num,
      MATCHED_BY                  WSH_BULK_TYPES_GRP.tbl_num,
      SHIPMENT_LINE_ID            WSH_BULK_TYPES_GRP.tbl_num,
      OBJECT_VERSION_NUMBER       WSH_BULK_TYPES_GRP.tbl_num,
      SHIP_FROM_LOCATION_ID       WSH_BULK_TYPES_GRP.tbl_num  --  IB-Phase-2
   );

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Txn_History     This procedure is used to create
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_txn_id                Transacion Id returned by the API
--                                     after inserting a record into
--                                     wsh_inbound_txn_history.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to create a record in the
--             wsh_inbound_txn_history table.
--             The following are the valid transaction types -
--             ASN, RECEIPT, RECEIPT_ADD, RECEIPT_CORRECTION_NEGATIVE,
--             RECEIPT_CORRECTION_POSITIVE, ROUTING_REQUEST,
--             ROUTING_RESPONSE, RTV, RECEIPT_CORRECTION, RTV_CORRECTION,
--             CANCEL_ASN, RTV_CORRECTION_POSITIVE,RTV_CORRECTION_NEGATIVE,
--             RECEIPT_HEADER_UPD.
--========================================================================
  PROCEDURE create_txn_history (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_txn_id                OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE create_txn_history_bulk
              (
                x_inboundTxnHistory_recTbl  IN OUT NOCOPY inboundTxnHistory_recTbl_type,
                x_return_status             OUT NOCOPY  VARCHAR2
              );
  PROCEDURE autonomous_Create_bulk
	    (
                x_inboundTxnHistory_recTbl  IN OUT NOCOPY  inboundTxnHistory_recTbl_type,
                x_return_status             OUT NOCOPY  VARCHAR2
            );

--========================================================================
-- PROCEDURE : Update_Txn_History     This procedure is used to update
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to a update a record in the
--             wsh_inbound_txn_history table.
--========================================================================
  PROCEDURE update_txn_history (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_return_status      OUT NOCOPY VARCHAR2);
--========================================================================
-- PROCEDURE : Delete_Txn_History     This procedure is used to delete
--                                    a record in the wsh_inbound_txn_history
--                                    table
--
-- PARAMETERS: p_transaction_id        This is unique identifier of a record
--                                     in wsh_inbound_txn_history.
--             x_return_status         return status of the API.
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to delete a record in the
--             wsh_inbound_txn_history table.
--========================================================================
  PROCEDURE delete_txn_history (
              p_transaction_id  IN NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Get_Txn_History        This procedure is used to get the record
--                                    from wsh_inbound_txn_history based on the
--                                    inputs shipment_header_id
--                                    ,transaction_type and transaction_id.
--
-- PARAMETERS: p_transaction_id        This is unique identifier of a record
--                                     in wsh_inbound_txn_history.
--             p_shipment_header_id    Shipment_Header_id of the transaction.
--             p_transaction_type      Type of Transaction.
--             x_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to a get the record from
--             wsh_inbound_txn_history based on the inputs
--             shipment_header_id, transaction_type, and transaction_id.
--========================================================================
  PROCEDURE get_txn_history (
              p_transaction_id  IN NUMBER DEFAULT NULL,
              p_shipment_header_id IN NUMBER DEFAULT NULL,
              p_transaction_type IN VARCHAR2 DEFAULT NULL,
              x_txn_history_rec  OUT NOCOPY ib_txn_history_rec_type,
              x_return_status      OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Post_Process           This procedure is used to update the
--                                    status column of the record in
--                                    wsh_inbound_txn_history based on the
--                                    inputs
--
-- PARAMETERS: p_shipment_header_id    Shipment_Header_id of the transaction.
--             p_max_rcv_txn_id        Maximum rcv_transaction_id stored in
--                                     wsh_inbound_txn_history.
--             p_txn_status            New Status of the transaction.
--             p_txn_type              Type of Transaction.
--             x_txn_history_rec       This is of type ib_txn_history_rec_type.
--             x_return_status         return status of the API.

-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is not being used any more.
--========================================================================

  PROCEDURE post_process (
              p_shipment_header_id IN NUMBER,
              p_max_rcv_txn_id IN NUMBER,
              p_txn_status IN VARCHAR2,
              p_txn_type IN VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE post_process
    (
      p_shipment_header_id IN NUMBER,
      p_max_rcv_txn_id    IN NUMBER,
      p_action_code        IN VARCHAR2,   -- MATCHED/CANCEL/REVERT
      p_txn_type           IN VARCHAR2,   -- ASN/RECEIPT
      p_object_version_number IN NUMBER,
      x_return_status      OUT NOCOPY VARCHAR2
    );

  PROCEDURE lock_asn_receipt_header
              (
                p_shipment_header_id IN NUMBER DEFAULT NULL,
                p_transaction_type   IN VARCHAR2 DEFAULT NULL,
                p_on_error           IN VARCHAR2 DEFAULT 'RETURN', -- 'RETRY'
                p_on_noDataFound     IN VARCHAR2 DEFAULT WSH_UTIL_CORE.G_RET_STS_ERROR, --WSH_UTIL_CORE.G_RET_STS_SUCCESS
                x_txn_history_rec    OUT NOCOPY ib_txn_history_rec_type,
                x_return_status      OUT NOCOPY VARCHAR2,
                x_locked             OUT NOCOPY VARCHAR2 -- Y/N
              );
  PROCEDURE autonomous_Create (
              p_txn_history_rec IN ib_txn_history_rec_type,
              x_txn_id                OUT NOCOPY NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
            );
    PROCEDURE lock_n_roll
                (
                  p_transaction_id IN NUMBER DEFAULT NULL,
                  x_return_status      OUT NOCOPY VARCHAR2,
                  x_locked             OUT NOCOPY VARCHAR2 -- Y/N
                );
  PROCEDURE getTransactionTypeMeaning
              (
                p_transactionType    IN VARCHAR2,
                x_transactionMeaning OUT NOCOPY VARCHAR2,
                x_return_status      OUT NOCOPY VARCHAR2
              );

END WSH_INBOUND_TXN_HISTORY_PKG;

 

/
