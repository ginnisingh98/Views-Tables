--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_FIN_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_FIN_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVFMDRS.pls 120.1.12010000.1 2008/07/24 01:32:36 appldev ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVFMDRS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_FIN_MDTR                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     04/01/00 pseshadr        Created                                  |
--|     04/01/02 pseshadr        Added Get_Reference_date procedure       |
--+======================================================================*/


--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE : Calc_Exchange_Rate PUBLIC
-- PARAMETERS:
--             p_stat_typ_transaction  mtl_stat_type_usages data record
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This function returns the exchange rate based on
--             the conversion date that is set up in the
--             statistical type info form.
--=======================================================================

PROCEDURE Calc_Exchange_Rate
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
);

--========================================================================
-- FUNCTION : Calc_Movement_AMount PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Calculates and returns the Movement Amount value
--=======================================================================

FUNCTION Calc_Movement_Amount
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
RETURN NUMBER;

--========================================================================
-- FUNCTION : Calc_Statistics_Value PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Calculates and returns the Statistics value
--=======================================================================

FUNCTION Calc_Statistics_Value
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
RETURN NUMBER;

--========================================================================
-- PROCEDURE : Calc_Invoice_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT Movement Statistics Record
--             p_stat_typ_transaction  IN  Stat type Usages record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Procedure to calcualte the invoice information
--=======================================================================--

PROCEDURE Calc_Invoice_Info
( p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- FUNCTION :  Get_Set_Of_Books_Period
-- PARAMETERS: p_legal_entity_id        Legal Entity
--             p_period_date            Invoice date or transaction date
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the Period Name
--             based on invoice date or movement date if invoice date is null
--=========================================================================
/* Bug: 5291257. Function defintion is modified to remove parameter
p_period_type.  */
FUNCTION Get_Set_Of_Books_Period
( p_legal_entity_id IN VARCHAR2
, p_period_date     IN DATE
--, p_period_type     IN VARCHAR2
)
RETURN VARCHAR2;


--========================================================================
-- FUNCTION :  Get_Period_Name
-- PARAMETERS: p_movement_transacton    Movement Transaction record
--             p_stat_typ_transaction   Stat typ tranaction
-- COMMENT   : Function that returns the Period Name
--=========================================================================

FUNCTION Get_Period_Name
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
) RETURN VARCHAR2;


--========================================================================
-- PROCEDURE :  Get_Reference_Date
-- PARAMETERS: p_movement_transacton    Movement Transaction record
--             p_stat_typ_transaction   Stat typ tranaction
-- COMMENT   : Procedure that gets the Reference Date
--=========================================================================

PROCEDURE Get_Reference_Date
( p_stat_typ_transaction IN INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);


--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize;

--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
);

END INV_MGD_MVT_FIN_MDTR;

/
