--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_CONC_PGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_CONC_PGM" AUTHID CURRENT_USER AS
-- $Header: INVCPRGS.pls 120.1 2006/05/25 18:03:09 yawang noship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVCPRGS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_CONC_PGM                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     04/01/2000 pseshadr     Created                                   |
--|     10/15/2001 yawang       Add procedure Run_Export_Data             |
--|     11/09/2001 yawang       Modify Run_Reset_Status                   |
--|     03/18/2002 yawang       Add exchange rate to Run_Export_Data      |
--|     11/22/2002 vma          Add NOCOPY to OUT parameters              |
--|     12/02/2004 vma          Reverse the order of x_errbuf and         |
--|                             x_retcode in API signatures to follow     |
--|                             Concurrent Manager standard.              |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Run_Movement_Stats      PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_legal_entity_id       Legal Entity ID
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
--             p_source_type           Document Source Type
-- COMMENT   : This is the concurrent program for movement statistics.
--             It processes all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Run_Movement_Stats
( x_errbuf         OUT NOCOPY VARCHAR2
, x_retcode        OUT NOCOPY VARCHAR2
, p_legal_entity_id IN  NUMBER
, p_start_date     IN  VARCHAR2
, p_end_date       IN  VARCHAR2
, p_source_type    IN  VARCHAR2
);


--========================================================================
-- PROCEDURE : Run_Exception_Verification  PUBLIC
-- PARAMETERS: x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--             p_legal_entity_id      Legal Entity
--             p_economic_zone_code   Economic Zone
--             p_usage_type           Usage Type
--             p_stat_type            Stat. Type
---            p_period_name          Movement Statistics Period
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
---
-- COMMENT   : This is the concurrent program specification for
--             Exception Verification Procedure/Report ,
--             which will validates and print
--             Exceptions for the Movement Statistics
--             transactions
---
--=======================================================================--


PROCEDURE Run_Exception_verification
( x_errbuf                OUT NOCOPY VARCHAR2
, x_retcode               OUT NOCOPY VARCHAR2
, p_legal_entity_id       IN  NUMBER
, p_economic_zone_code    IN  VARCHAR2
, p_usage_type            IN  VARCHAR2
, p_stat_type             IN  VARCHAR2
, p_period_name           IN  VARCHAR2
, p_document_source_type  IN  VARCHAR2
);


--========================================================================
-- PROCEDURE : Run_Reset_Status        PUBLIC
-- PARAMETERS: x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--             p_legal_entity_id       Legal Entity
--             p_economic_zone         Econimic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Status Type
--             p_period_name           Period Name
--             p_document_source_type  Document Source Type
--                                     (PO,SO,INV,RMA,RTV)
--             p_reset_option          Reset Status Option
--                                     (All, Ignore only, Exclude Ignore)
--
-- COMMENT   : This is the concurrent program specification
--             for Run_Reset_Status
---            enabling the movement statistics transaction
--             status to be  updated or changed to Open(O)
--             and EDI_SENT_FLAG      = 'N'
--
-- History:   11/09/2001  yawang    Add parameter p_reset_option to
--                                  support ignore records
--=======================================================================--

PROCEDURE Run_Reset_Status
( x_errbuf               OUT  NOCOPY VARCHAR2
, x_retcode              OUT  NOCOPY VARCHAR2
, p_legal_entity_id      IN   NUMBER
, p_economic_zone        IN   VARCHAR2
, p_usage_type           IN   VARCHAR2
, p_stat_type            IN   VARCHAR2
, p_period_name          IN   VARCHAR2
, p_document_source_type IN   VARCHAR2
, p_reset_option         IN   VARCHAR2
)
;


--========================================================================
-- PROCEDURE : Run_Purge_Movement_Stats   PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_legal_entity_id       Legal Entity
--             p_economic_zone         Econimic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Status Type
--             p_period_name           Period Name
--             p_document_source_type  Document Source Type
--                                     (PO,SO,INV,RMA,RTV)
-- COMMENT   : This is the concurrent program for purging movement
--             statistics transactions.
--             It purges all the transaction for the specified legal
--             entity that have a transaction date within the specified
--             date range.
--========================================================================

PROCEDURE Run_Purge_Movement_Stats
( x_errbuf               OUT  NOCOPY VARCHAR2
, x_retcode              OUT  NOCOPY VARCHAR2
, p_legal_entity_id      IN   NUMBER
, p_economic_zone        IN   VARCHAR2
, p_usage_type           IN   VARCHAR2
, p_stat_type            IN   VARCHAR2
, p_period_name          IN   VARCHAR2
, p_document_source_type IN   VARCHAR2
);


--========================================================================
-- PROCEDURE : Run_Export_Data           PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_legal_entity_id       Legal Entity
--             p_zone_code             Economic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Statistical Type
--             p_movement_type         Movement Type
--             p_period_name           Period Name
--             p_currency_code         Currency Code (support multi-currency)
--             p_exchange_rate         Exchange Rate
--             p_inverse_rate          Y - display inverse rate
--                                     N - display non-inverse rate
--             p_rate_type             Exchange rate type
--                                     p_inverse_rate and p_rate_type are hidded
--                                     parameters in application, they are used to
--                                     determine list of value of exchange rate
--             p_amount_display        display whole number or currency precision
--
-- COMMENT   : This is the concurrent program specification for Run_Export_Data
--             used in IDEP declaration. It will generate a flat file in out
--             directory for specified movement type and report reference and
--             the records included in this file need to be in status of 'F'
--
--=======================================================================--

PROCEDURE Run_Export_Data
( x_errbuf               OUT  NOCOPY VARCHAR2
, x_retcode              OUT  NOCOPY VARCHAR2
, p_legal_entity_id      IN   NUMBER
, p_zone_code            IN   VARCHAR2
, p_usage_type           IN   VARCHAR2
, p_stat_type            IN   VARCHAR2
, p_movement_type        IN   VARCHAR2
, p_period_name          IN   VARCHAR2
, p_amount_display       IN   VARCHAR2
, p_currency_code        IN   VARCHAR2
, p_inverse_rate         IN   VARCHAR2
, p_rate_type            IN   NUMBER
, p_exchange_rate_char   IN   VARCHAR2
)
;

END INV_MGD_MVT_CONC_PGM;

 

/
