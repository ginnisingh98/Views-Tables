--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_EXPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_EXPORT_DATA" AUTHID CURRENT_USER AS
-- $Header: INVIDEPS.pls 120.1 2006/05/25 18:07:15 yawang noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVIDEPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_EXPORT_DATA                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     10/12/01 yawang          Created                                  |
--|     10/23/01 yawang          Modified,add parameter legal entity, zone|
--|                              code,usage type,stat type and period name|
--|     03/15/02 yawang          Add parameter currency code and exchange |
--|                              rate                                     |
--|     12/03/02 vma             Add NOCOPY to OUT parameters to comply   |
--|                              with new PL/SQL standards for better     |
--|                              performance.                             |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Generate_Export_Data   PUBLIC
--
-- PARAMETERS: x_return_status         Procedure return status
--             x_msg_count             Number of messages in the list
--             x_msg_data              Message text
--             p_api_version_number    Known Version Number
--             p_init_msg_list         Empty PL/SQL Table list for
--                                     Initialization
--
--             p_legal_entity_id       Legal Entity
--             p_zone_code             Economic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Statistical Type
--             p_period_name           Period Name
--             p_movement_type         Movement Type
--             p_currency_code         The currency in which user want to see
--                                     the statistic value
--             p_exchange_rate         The exchange rate for the currency code
--                                     user selected
--             p_amount_display        Display whole number or of currency precision
--
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- COMMENT   : Procedure specification
--             to generate flat data file used in IDEP
--
-- Updated   :  15/Mar/2002
--=======================================================================--

PROCEDURE Generate_Export_Data
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_legal_entity_id      IN  NUMBER
, p_zone_code            IN  VARCHAR2
, p_usage_type           IN  VARCHAR2
, p_stat_type            IN  VARCHAR2
, p_movement_type        IN  VARCHAR2
, p_period_name          IN  VARCHAR2
, p_amount_display       IN  VARCHAR2
, p_currency_code        IN  VARCHAR2
, p_exchange_rate_char   IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
;

END INV_MGD_MVT_EXPORT_DATA;

 

/
