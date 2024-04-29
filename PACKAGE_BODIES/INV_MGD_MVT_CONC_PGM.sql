--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_CONC_PGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_CONC_PGM" AS
-- $Header: INVCPRGB.pls 120.2 2006/05/25 18:03:54 yawang noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVCPRGB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of INV_MGD_MVT_CONC_PGM                                      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Run_Movement_Stats                                                |
--|     Run_Exception_verification                                        |
--|     Run_Reset_Movement_Stats                                          |
--|     Run_Purge_Movement_Stats                                          |
--|     Run_Export_Data                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     04/01/2000 pseshadr     Created                                   |
--|     10/15/2001 yawang       Add procedure Run_Export_Data             |
--|     11/09/2001 yawang       Modify procedure Run_Reset_Status to add  |
--|                             parameter p_movement_status               |
--|     03/18/2002 yawang       Add currency code and exchange rate to    |
--|                             Run_Export_Data                           |
--|     11/22/2002 vma          Add NOCOPY to OUT paramters. Print to LOG |
--|                             only if debug profile option is enabled.  |
--|     12/02/2004 vma          Reverse the order of x_errbuf and         |
--|                             x_retcode in API signatures to follow     |
--|                             Concurrent Manager standard.              |
--+=======================================================================

--===================
-- CONSTANTS
--===================
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_CONC_PGM.';
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MGD_MVT_CONC_PGM';

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Run_Movement_Stats      PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_legal_entity_id       Legal ENtity ID
--             p_start_date            Transaction range (start date)
--             p_end_date              Transaction range (end date)
--             p_source_type           Transaction source type (PO,SO,RMA etc)
-- COMMENT   : This is the concurrent program for movement statistics.
--========================================================================
PROCEDURE Run_Movement_Stats
( x_errbuf         OUT NOCOPY VARCHAR2
, x_retcode        OUT NOCOPY VARCHAR2
, p_legal_entity_id IN  NUMBER
, p_start_date     IN  VARCHAR2
, p_end_date       IN  VARCHAR2
, p_source_type    IN  VARCHAR2
)
IS
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(100);
l_le_start_date         DATE;
l_server_start_date     DATE;
l_le_end_date           DATE;
l_server_end_date       DATE;
l_procedure_name CONSTANT VARCHAR2(30) := 'Run_Movement_Stats';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  --Convert legal entity char date to date format
  l_le_start_date := TRUNC(FND_DATE.canonical_to_date(p_start_date));

  --Fix bug5047762, deduct 1 second from 00:00:00 of next day to make
  --sure it is within last second of p_end_date
  IF p_end_date IS NOT NULL
  THEN
    l_le_end_date := TRUNC(FND_DATE.canonical_to_date(p_end_date) + 1) - 1/(24*60*60);
  END IF;

  --Fix bug3731618, no movement record generated if the end date is not specified
  --Set correct legal entity end date
  /*IF p_end_date IS NULL
  THEN
    l_le_end_date := TRUNC(sysdate+1);
  ELSE
    l_le_end_date := TRUNC(FND_DATE.canonical_to_date(p_end_date) + 1);
  END IF;
*/

  --Timezone support, convert legal entity time to server time
  l_server_start_date := INV_LE_TIMEZONE_PUB.Get_Server_Day_Time_For_Le
  ( p_le_date => l_le_start_date
  , p_le_id   => p_legal_entity_id
  );

  IF p_end_date IS NULL
  THEN
    l_server_end_date := TRUNC(sysdate+1) - 1/(24*60*60);
  ELSE
    l_server_end_date := INV_LE_TIMEZONE_PUB.Get_Server_Day_Time_For_Le
    ( p_le_date => l_le_end_date
    , p_le_id   => p_legal_entity_id
    );
  END IF;

  -- Call the transaction proxy which processes all the transactions.
  INV_MGD_MVT_STATS_PROC.PROCESS_TRANSACTION
  ( p_api_version_number   => 1.0
  , p_init_msg_list        => FND_API.G_FALSE
  , p_legal_entity_id      => p_legal_entity_id
  , p_start_date           => l_server_start_date
  , p_end_date             => l_server_end_date
  , p_source_type          => NVL(p_source_type,'ALL')
  , x_msg_count            => l_msg_count
  , x_msg_data             => l_msg_data
  , x_return_status        => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuf := NULL;
  ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||' in unexpected exception'
                    , x_errbuf
                    );
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Run_Movement_Stats'
                             );
    END IF;

    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name||' in others exception'
                    , x_errbuf
                    );
    END IF;
END Run_Movement_Stats;


--========================================================================
-- PROCEDURE : Run_Exception_Verification      PUBLIC
-- PARAMETERS: x_retcode              0 success, 1 warning, 2 error
--             x_errbuf               error buffer
--             p_legal_entity_id      Legal Entity
--             p_economic_zone_code   Economic Zone
--             p_usage_type           Usage Type
--             p_stat_type            Stat. Type
---            p_period_name          Movement Statistics Period
--             p_document_source_type Document Source Type
--                                    (PO,SO,INV,RMA,RTV)
---
--=======================================================================--
PROCEDURE Run_Exception_verification
( x_errbuf                     OUT NOCOPY VARCHAR2
, x_retcode                    OUT NOCOPY VARCHAR2
, p_legal_entity_id            IN  NUMBER
, p_economic_zone_code         IN  VARCHAR2
, p_usage_type                 IN  VARCHAR2
, p_stat_type                  IN  VARCHAR2
, p_period_name                IN  VARCHAR2
, p_document_source_type       IN  VARCHAR2
)
IS
 x_return_status   VARCHAR2(10);
 x_msg_count       NUMBER;
 x_msg_data        VARCHAR2(1000);
 l_procedure_name CONSTANT VARCHAR2(30) := 'Run_Exception_verification';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

-- Call Exception verification procedure that validates all the transactions

  INV_MGD_MVT_VALIDATE_PROC.Validate_Transaction
    ( p_api_version_number       => 1.0
    , p_init_msg_list            => FND_API.G_FALSE
    , p_legal_entity_id          => p_legal_entity_id
    , p_economic_zone_code       => p_economic_zone_code
    , p_usage_type               => p_usage_type
    , p_stat_type                => p_stat_type
    , p_period_name              => p_period_name
    , p_document_source_type     => p_document_source_type
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    );

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuf := NULL;
  ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                              , 'Run Exception Verification'
                              );
    END IF;

    x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    x_retcode := 2;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
END Run_Exception_Verification;

--========================================================================
-- PROCEDURE : Run_Reset_Status        PUBLIC
-- PARAMETERS: x_retcode               0 success, 1 warning, 2 error
--             x_errbuf                error buffer
--             p_legal_entity_id       Legal Entity
--             p_economic_zone         Economic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Status Type
--             p_period_name           Period Name
--             p_document_source_type  Document Source Type
--                                     (PO,SO,INV,RMA,RTV)
--             p_reset_option          Reset Status Option
--                                     (All, Ignore Only, Exclude Ignore)
-- COMMENT:    This is the concurrent program for running the Reset
--             Transaction Status.
--
-- History:    11/09/2001 yawang       Add parameter p_reset_option, called
--                                     procedure version has increased to 2.0
--=======================================================================--

PROCEDURE Run_Reset_Status
( x_errbuf                     OUT  NOCOPY VARCHAR2
, x_retcode                    OUT  NOCOPY VARCHAR2
, p_legal_entity_id            IN   NUMBER
, p_economic_zone              IN   VARCHAR2
, p_usage_type                 IN   VARCHAR2
, p_stat_type                  IN   VARCHAR2
, p_period_name                IN   VARCHAR2
, p_document_source_type       IN   VARCHAR2
, p_reset_option               IN   VARCHAR2
)

IS
  l_return_status         VARCHAR2(10);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(1000);
  l_procedure_name CONSTANT VARCHAR2(30) := 'Run_Reset_Status';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

  -- Call the Reset Transaction procedure to reset the status to Open
  INV_MGD_MVT_RESET_TRANS.Reset_Transaction_Status
  ( p_api_version_number    => 2.0
  , p_init_msg_list         => FND_API.G_FALSE
  , p_legal_entity_id       => p_legal_entity_id
  , p_zone_code             => p_economic_zone
  , p_usage_type            => p_usage_type
  , p_stat_type             => p_stat_type
  , p_period_name           => p_period_name
  , p_document_source_type  => p_document_source_type
  , p_reset_option          => p_reset_option
  , x_return_status         => l_return_status
  , x_msg_count             => l_msg_count
  , x_msg_data              => l_msg_data
  );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuf := NULL;
  ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Run_Reset_Status'
                             );
    END IF;

    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
END Run_Reset_Status;


--========================================================================
-- PROCEDURE : Run_Purge_Movement_Statistics        PUBLIC
-- PARAMETERS: x_retcode               0 success, 1 warning, 2 error
--             x_errbuf                error buffer
--             p_legal_entity_id       Legal Entity
--             p_economic_zone         Econimic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Status Type
--             p_period_name           Period Name
--             p_document_source_type  Document Source Type
--                                     (PO,SO,INV,RMA,RTV)
-- COMMENT:    This is the concurrent program to run the Purging
--             of the movement transactions .
--=======================================================================--

PROCEDURE Run_Purge_Movement_Stats
( x_errbuf                     OUT  NOCOPY VARCHAR2
, x_retcode                    OUT  NOCOPY VARCHAR2
, p_legal_entity_id            IN   NUMBER
, p_economic_zone              IN   VARCHAR2
, p_usage_type                 IN   VARCHAR2
, p_stat_type                  IN   VARCHAR2
, p_period_name                IN   VARCHAR2
, p_document_source_type       IN   VARCHAR2
)

IS
  x_return_status         VARCHAR2(10);
  x_msg_count             NUMBER;
  x_msg_data              VARCHAR2(1000);
  l_procedure_name CONSTANT VARCHAR2(30) := 'Run_Purge_Movement_Stats';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

  -- Call the Purge Movement Transactions procedure to purge the transactions.

  INV_MGD_MVT_PURGE_TRANS.Purge_Movement_Transactions
    ( p_api_version_number    => 1.0
    , p_init_msg_list         => FND_API.G_FALSE
    , p_legal_entity_id       => p_legal_entity_id
    , p_zone_code             => p_economic_zone
    , p_usage_type            => p_usage_type
    , p_stat_type             => p_stat_type
    , p_period_name           => p_period_name
    , p_document_source_type  => p_document_source_type
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    );

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuf := NULL;
  ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Run_Purge_Movement_Statistics'
                             );
    END IF;

    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
END Run_Purge_Movement_Stats;


--========================================================================
-- PROCEDURE : Run_Export_Data         PUBLIC
-- PARAMETERS: x_retcode               0 success, 1 warning, 2 error
--             x_errbuf                error buffer
--             p_legal_entity_id       Legal Entity
--             p_zone_code             Economic Zone
--             p_usage_type            Usage Type
--             p_stat_type             Statistical Type
--             p_period_name           Period Name
--             p_movement_type         Movement Type
--             p_currency_code         Currency Code
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
IS
  l_return_status        VARCHAR2(10);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_procedure_name CONSTANT VARCHAR2(30) := 'Run_Export_Data';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

  -- Call the Run Export Data procedure to generate the flat data file
  INV_MGD_MVT_EXPORT_DATA.Generate_Export_Data
  ( p_api_version_number => 1.0
  , p_init_msg_list      => FND_API.G_FALSE
  , p_legal_entity_id    => p_legal_entity_id
  , p_zone_code          => p_zone_code
  , p_usage_type         => p_usage_type
  , p_stat_type          => p_stat_type
  , p_movement_type      => p_movement_type
  , p_period_name        => p_period_name
  , p_amount_display     => p_amount_display
  , p_currency_code      => p_currency_code
  , p_exchange_rate_char => p_exchange_rate_char
  , x_return_status      => l_return_status
  , x_msg_count          => l_msg_count
  , x_msg_data           => l_msg_data);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuf := NULL;
  ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Run_Export_Data'
                             );
    END IF;

    x_retcode := 2;
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_NAME || l_procedure_name
                    , x_errbuf
                    );
    END IF;
END Run_Export_Data;

END INV_MGD_MVT_CONC_PGM;

/
