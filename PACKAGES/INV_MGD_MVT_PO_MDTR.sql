--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_PO_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_PO_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVPMDRS.pls 120.0.12010000.3 2008/10/01 12:02:36 ajmittal ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVPMDRS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_PO_MDTR                                      |
--|     Get_Parent_Mvt                                                    |
--|     Get_IO_Arrival_Txn
--|     Get_IO_Arrival_Details
--|     Update_PO_Transaction                                             |
--|                                                                       |
--| HISTORY
--|     05-Aug-08  Ajmittal     Bug 7165989 - Movement Statistics  RMA    |
--|                             Triangulation uptake. Modified the        |
--|				Update_PO_transactions procedure to pass  |
--|				the Movement Stat Status attribute	  |
--|				that will be stamped to RCV_TRANSACTIONS  |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Get_PO_Transactions    PRIVATE
-- PARAMETERS: po_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for PO and returns the cursor.
--========================================================================

PROCEDURE Get_PO_Transactions
( po_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_RTV_Transactions    PRIVATE
-- PARAMETERS: rtv_crsr                REF cursor
--             x_return_status         return status
-- COMMENT   :
--             This opens the cursor for RTV and returns the cursor.
--========================================================================
PROCEDURE Get_RTV_Transactions
( rtv_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.rtvCurTyp
, p_parent_id             IN  NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_Blanket_Info        PUBLIC
-- PARAMETERS: p_movement_transaction  movement transaction record type
--             x_movement_transaction  movement transaction record type
-- COMMENT   :
--             This procedure gets info for Blanket PO's
--========================================================================
PROCEDURE Get_Blanket_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- PROCEDURE : Get_RMA_Transactions    PRIVATE
-- PARAMETERS: rma_Crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for RMA and returns the cursor.
--========================================================================

PROCEDURE Get_RMA_Transactions
( rma_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_PO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_PO_Transactions
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_mvt_stat_status      IN RCV_TRANSACTIONS.mvt_stat_status%TYPE -- 7165989
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Get_PO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for PO
--========================================================================

PROCEDURE Get_PO_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_DropShipment_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for PO
--========================================================================

PROCEDURE Get_DropShipment_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_RMA_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for RMA
--========================================================================

PROCEDURE Get_RMA_Details
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_Parent_Mvt          PRIVATE
-- PARAMETERS: p_rcv_transaction_id    transaction id
--             p_movement_transaction  movement transaction record
--             x_movement_id           movement id
--             x_movement_status       movement status
--             x_source_type           document source type
-- COMMENT   : Get movement id, movement status and source type of given
--             transaction id
--========================================================================
PROCEDURE Get_Parent_Mvt
( p_movement_transaction IN
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_rcv_transaction_id   IN NUMBER
, x_movement_id          OUT NOCOPY NUMBER
, x_movement_status      OUT NOCOPY VARCHAR2
, x_source_type          OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_IO_Arrival_Txn     PRIVATE
-- PARAMETERS: po_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for IO arrival and returns the cursor.
--========================================================================

PROCEDURE Get_IO_Arrival_Txn
( io_arrival_crsr                IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.poCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_IO_Arrival_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for IO Arrival
--========================================================================

PROCEDURE Get_IO_Arrival_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

END INV_MGD_MVT_PO_MDTR;

/
