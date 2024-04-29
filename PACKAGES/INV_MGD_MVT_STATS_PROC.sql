--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_STATS_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_STATS_PROC" AUTHID CURRENT_USER AS
/* $Header: INVSTATS.pls 120.0.12010000.2 2008/10/01 12:03:51 ajmittal ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVSTATS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_STATS_PROC                                   |
--|                                                                       |
--| HISTORY                                                               |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Process_Transaction     PRIVATE
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_source type           Transaction type (SO,PO etc)
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--| 02/08/2008 ajmittal Bug 7165989 - Movement Statistics  RMA    |
--|                             Triangulation uptake.			  |
--|				Modified procs:Process_IO_Arrival_Txn,    |
--|				Process_RMA_Transaction			  |
--|				New procedure : Process_RMA_Triangulation |
--========================================================================
/* 7165989 - New procedure added to process RMA Triangulation transactions */
--========================================================================
-- PROCEDURE : Process_RMA_Triangulation     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_movement_transaction  Movement Transaction record
--             p_stat_typ_transaction  Parameter details
-- COMMENT   : This processes all the RMA triangulation txn for the specified
--		legal entity where the RMA is booked
--========================================================================

PROCEDURE Process_RMA_Triangulation
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);
PROCEDURE Process_Transaction
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_source_type          IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_Transaction     OVERLOADED
-- PARAMETERS:
--             x_return_status         return status
--             p_movement_transaction  Movement Transaction record
-- COMMENT   :
--             This procedure is overloaded so that the form can use
--             this proceure to directly enter data in the mvt stats
--             table.
--========================================================================

PROCEDURE Process_Transaction
( p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- PROCEDURE : Process_INV_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      INV
-- COMMENT   :
--             This processes all the INV transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_INV_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Process_SO_Transaction  PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO,RMA,drop shipments,IO
-- COMMENT   :
--             This processes all the SO transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_SO_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_Triangulation_Txn  PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO,RMA,drop shipments,IO
-- COMMENT   :
--             This processes all the triangulation transactions (create
--             transaction in one legal entity and pick release in another
--             legal entity of different country) for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--             This procedure will create arrival record only for the
--             creation side of cross legal entity transactions for invoice
--             based triangulation mode. The pick release side will be taken
--             care of by the regular process_so_transaction.
--========================================================================

PROCEDURE Process_Triangulation_Txn
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_IO_Arrival_Txn  PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      SO,RMA,drop shipments,IO
-- COMMENT   :
--             This processes all the internal order arrival transactions
--             for the specified legal entity that have a transaction date
--             within the specified date range.
--             This procedure will create arrival record only for the
--             receiving side of internal order transactions. The dispatch
--             side will be taken care by the regular process_so_transaction.
--========================================================================

PROCEDURE Process_IO_Arrival_Txn
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Process_PO_Transaction  PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      PO,RTV
-- COMMENT   :
--             This processes all the PO transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_PO_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_RMA_Transaction  PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      RMA
-- COMMENT   :
--             This processes all the RMA transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Process_RMA_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Update_Invoice_Info     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This updates the invoice information for the particular
--             transaction_type for the records that are Open and Verified
--========================================================================

PROCEDURE Update_Invoice_Info
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_Pending_Transaction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This processes the pending transactions
--========================================================================

PROCEDURE Process_Pending_Transaction
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Update_PO_With_Correction     PRIVATE
-- PARAMETERS: x_return_status         status flag
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction Type
-- COMMENT   :
--             This updates the PO or RTV transaction with correction if
--             the original PO or RTV is not closed yet
--========================================================================


PROCEDURE Update_PO_With_Correction
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);


END INV_MGD_MVT_STATS_PROC;

/
