--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_SETUP_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_SETUP_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVUSGSS.pls 115.5 2002/11/22 19:32:28 yawang ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVUSGSS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_SETUP_MDTR                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     06/16/00   ksaini     Added Get_Movement_Stat_Usages Procedure    |
--|     04/01/02   pseshadr   Added Get_Reference_Context Procedure       |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Get_Reference_Context       PRIVATE
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction type (SO,PO etc)
-- COMMENT   :
--             This processes all the parameters for the specified legal
--             entity .
--========================================================================


PROCEDURE Get_Reference_Context
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, ref_crsr               IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
);

--========================================================================
-- PROCEDURE : Get_Setup_Context       PRIVATE
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_movement_transaction  Movement Transaction Record
--             ref_crsr                Cursor
-- COMMENT   :
--             This processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Get_Setup_Context
( p_legal_entity_id      IN  NUMBER
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, setup_crsr             IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
);

--========================================================================
-- PROCEDURE : Get_Invoice_Context       PRIVATE
-- PARAMETERS:
--             x_return_status         return status
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_transaction type      Transaction type (SO,PO etc)
-- COMMENT   : Processes the setup info when updating the Invoice
--========================================================================

PROCEDURE Get_Invoice_Context
( p_legal_entity_id      IN  NUMBER
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, p_transaction_type     IN  VARCHAR2
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, setup_crsr             IN OUT NOCOPY INV_MGD_MVT_DATA_STR.setupCurTyp
);


--========================================================================
-- FUNCTION : Process_Setup_Context       PRIVATE
-- PARAMETERS:
--             p_movement_transaction     movement transaction record
-- COMMENT   :
--========================================================================

FUNCTION Process_Setup_Context
( p_movement_transaction IN INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type)
RETURN VARCHAR2;


--========================================================================
-- PROCEDURE : Get_Movement_Stat_Usages   PRIVATE
-- PARAMETERS:
--             x_return_status            OUT return status
--             x_msg_count                OUT number of messages in the list
--             x_msg_data                 OUT message text
--             p_legal_entity_id          IN  legal_entity
--             p_economic_zone_code       IN  economic zone
--             p_usage_type               IN  usage type
--             p_stat_type                IN  stat_type
--             x_movement_stat_usages_rec OUT Stat type Usages record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Procedure that returns the category id for an item
--=======================================================================--
PROCEDURE Get_Movement_Stat_Usages
( x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_legal_entity_id         IN  NUMBER
, p_economic_zone_code      IN  VARCHAR2
, p_usage_type              IN  VARCHAR2
, p_stat_type               IN  VARCHAR2
, x_movement_stat_usages_rec OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
);

END INV_MGD_MVT_SETUP_MDTR;

 

/
