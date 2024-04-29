--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_STATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_STATS_PVT" AUTHID CURRENT_USER AS
-- $Header: INVVMVTS.pls 115.13 2002/12/11 01:05:38 yawang ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVMVTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_STATS_PVT                                      |
--|                                                                       |
--| HISTORY                                                               |
--|     04/01/00 pseshadr        Created                                  |
--|     06/15/00 ksaini          Added Procedures                         |
--|     07/18/00 ksaini          Added Validate_Rules procedure           |
--|     04/01/02 pseshadr        Added Get Pending Txns procedure         |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Create_Movement_Statistics PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_FALSE not to reset list
--             p_transaction_type      transaction type(inv,rec.,PO etc)
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_material_transaction  material transaction data record
--             p_shipment_transaction  shipment transaction data record
--             p_receipt_transaction   receipt transaction data record
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Called by the Process Transaction after all the
--             processing is done to insert the transaction/record
--             into the movement statistics table.
--             This procedure does the insert into the table.
--=======================================================================

PROCEDURE Create_Movement_Statistics
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Init_Movement_Record    PUBLIC
-- PARAMETERS:
--             x_movement_transaction  in  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure defaults values for certain attributes which
--             are common for all the transactions.
--             Eg: statistical_procedure_code,creation_method etc.
--=======================================================================

PROCEDURE Init_Movement_Record
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- PROCEDURE : Get_Open_Mvmt_Stats_Txns    PRIVATE
-- PARAMETERS: val_crsr                    REF cursor
--             x_return_status             return status
--             p_start_date                Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for INV and returns the cursor.
--========================================================================

PROCEDURE Get_Open_Mvmt_Stats_Txns (
   val_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_statistics        IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_legal_entity_id            IN  NUMBER
 , p_economic_zone_code         IN  VARCHAR2
 , p_usage_type                 IN  VARCHAR2
 , p_stat_type                  IN  VARCHAR2
 , p_period_name                IN  VARCHAR2
 , p_document_source_type       IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_Pending_Txns    PRIVATE
-- PARAMETERS:
--             val_crsr                    cursor that returns the selection
--             p_movement_Transaction      Movement Transaction record
--             p_transaction_type          Transaction Type (SO,PO etc)
--             x_return_status             return status
-- COMMENT   :
--             This gets  all the pending transactions
--========================================================================

PROCEDURE Get_Pending_Txns (
   val_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_transaction        IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_document_source_type       IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_Invoice_Transactions    PRIVATE
-- PARAMETERS: inv_crsr                    REF cursor
--             x_return_status             return status
--             p_start_date                Transaction start date
--             p_end_date                  Transaction end date
--             p_transaction_type          Transaction Type
-- COMMENT   :
--========================================================================
PROCEDURE Get_Invoice_Transactions (
   inv_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_transaction       IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_start_date                 IN  DATE
 , p_end_date                   IN  DATE
 , p_transaction_type           IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Get_PO_Trans_With_Correction    PRIVATE
-- PARAMETERS: inv_crsr                        REF cursor
--             x_return_status                 return status
--             p_legal_entity_id               Legal entity id
--             p_start_date                    Transaction start date
--             p_end_date                      Transaction end date
--             p_transaction_type              Transaction Type
-- COMMENT   :
--========================================================================
PROCEDURE Get_PO_Trans_With_Correction
( inv_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
, p_legal_entity_id            IN  NUMBER
, p_start_date                 IN  DATE
, p_end_date                   IN  DATE
, p_transaction_type           IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Update_Movement_Statistics   PRIVATE
--
-- PARAMETERS: x_return_status      Procedure return status
--             x_msg_count          Number of messages in the list
--             x_msg_data           Message text
--             P_MOVEMENT_STATISTICS    Material Movement Statistics transaction
--                                  Input data record
--
-- COMMENT   : Procedure body to Update the Movement
--             Statistics record with the
--             calculated values ( EX: Invoice information, Status etc ).
-- Updated   : 09/Jul/1999
--=======================================================================--
PROCEDURE Update_Movement_Statistics (
  p_movement_statistics  IN
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status                OUT NOCOPY    VARCHAR2
, x_msg_count                    OUT NOCOPY    NUMBER
, x_msg_data                     OUT NOCOPY    VARCHAR2
);


 --=========================================================================

-- PROCEDURE : Validate_Movement_Statistics  PRIVATE
--
-- PARAMETERS:
--             p_movement_statistics     Material Movement Statistics transaction
--                                       Input data record
--             p_movement_stat_usages_rec usage record
--             x_excp_list               PL/SQL Table type list for storing
--                                       and returning the Exception messages
--             x_return_status           Procedure return status
--             x_msg_count               Number of messages in the list
--             x_msg_data                Message text
--             x_movement_statistics     Material Movement Statistics transaction
--                                       Output data record
--
-- VERSION   : current version           1.0
--             initial version           1.0
--
-- COMMENT   :  Procedure specification to Perform the
--              Validation for the Movement
--             Statistics Record FOR Exceptions
--
-- CREATED  : 10/20/1999
--=============================================================================-
PROCEDURE Validate_Movement_Statistics
 ( p_movement_statistics     IN
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_movement_stat_usages_rec IN
     INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
 , x_excp_list                OUT NOCOPY
     INV_MGD_MVT_DATA_STR.excp_list
 , x_updated_flag             OUT NOCOPY VARCHAR2
 , x_return_status            OUT NOCOPY VARCHAR2
 , x_msg_count                OUT NOCOPY NUMBER
 , x_msg_data                 OUT NOCOPY VARCHAR2
 , x_movement_statistics      OUT NOCOPY
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 );

--========================================================================
-- PROCEDURE : Delete_Movement_Statistics PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Called by the Form to delete a movement record
--=======================================================================
PROCEDURE Delete_Movement_Statistics
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Validate_Rules            PRIVATE
-- PARAMETERS: p_mtl_transaction          IN  movement transaction record
--             x_mtl_transaction          OUT movement transaction record
--             x_return_status            OUT standard output
--             x_record_status            OUT 'Y' if corrected, 'N' otherwise
--
-- VERSION   : current version         1.0
--             initial_version          1.0
-- COMMENT   : Validate the transaction record for its DELIVERY_TERMS,
--             UNIT_WEIGHT/TOTAL_WEIGHT and COMMODITY_CODE.
--=======================================================================
PROCEDURE Validate_Rules
( p_movement_stat_usages_rec      IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction          IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status                 OUT NOCOPY VARCHAR2
, x_Uom_status                    OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
);


END INV_MGD_MVT_STATS_PVT;

 

/
