--------------------------------------------------------
--  DDL for Package Body CST_PERIODIC_ABSORPTION_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERIODIC_ABSORPTION_CP" AS
-- $Header: CSTCITPB.pls 120.2.12000000.3 2007/05/10 05:41:14 vmutyala ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTCITPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Periodic Absorption Cost Processor Concurrent Program Wrapper      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Periodic_Absorb_Cost_Process                                      |
--|                                                                       |
--| HISTORY                                                               |
--|     07/21/03   dherring    Created                                    |
--|     10/27/2003 vjavli      p_tolerance parameter updated              |
--|     11/25/03   David Herring moved order of run option parameter      |
--|     01/20/04   vjavli      transfer_cp_manager to add two more out    |
--|                            parameters for return status and error msg |
--|     04/10/2004 vjavli      Concurrent program name change             |
--|                            new name:Periodic_Absorb_Cost_Process      |
--| ----------------------------------------------------------------------|
--| ----------------------- R12 ENHANCEMENTS -----------------------------|
--| ----------------------------------------------------------------------|
--|     06/15/2005 vjavli     Bug#4358239 fix:  Regression caused due to  |
--|                           TZ bug#3720424 fix by Oracle Costing        |
--|                           INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR |
--|                           _LE invoke to be modified                   |
--|     06/15/2005 vjavli     Bug#4351270 fix: timzone issue:             |
--|                           process_upto_date validation should be for  |
--|                           Legal Entity; l_le_process_upto_date        |
--|                           Procedure transfer_cp_manager modified with |
--|                           p_le_process_upto_date                      |
--|     01/30/2006 vjavli     FND Debug Log Messages implemented          |
--+========================================================================

-- ==================================================================
-- GLOBALS
-- ==================================================================
G_PKG_NAME CONSTANT    VARCHAR2(30) := 'CST_PERIODIC_ABSORPTION_CP';

--========================================================================
-- PRIVATE CONSTANTS AND VARIABLES
--========================================================================
G_MODULE_HEAD CONSTANT  VARCHAR2(50) := 'cst.plsql.' || G_PKG_NAME || '.';

--========================================================================
-- PROCEDURE : Periodic_Absorb_Cost_Process      PRIVATE
-- COMMENT   : This procedure acts as a wrapper around the code that will
--             process periodic absorption cost of transactions according
--             to the periodic weighted average costing (PWAC) cost method
--             based on a new periodic absorption cost rollup algorithm
--=========================================================================
PROCEDURE Periodic_Absorb_Cost_Process
( x_errbuf                  OUT NOCOPY VARCHAR2
, x_retcode                 OUT NOCOPY VARCHAR2
, p_legal_entity_id         IN  VARCHAR2
, p_cost_type_id            IN  VARCHAR2
, p_period_id               IN  VARCHAR2
, p_run_options             IN  VARCHAR2
, p_process_upto_date       IN  VARCHAR2 DEFAULT NULL
, p_tolerance               IN  VARCHAR2
, p_number_of_iterations    IN  VARCHAR2
, p_number_of_workers       IN  VARCHAR2 DEFAULT '1'
)
IS

l_routine CONSTANT VARCHAR2(30) := 'periodic_absorb_cost_process';

-- Exception
transfer_cp_mgr_error_exc  EXCEPTION;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;

-- bug#3720424: convert LE to server time zone used to retrieve
-- transactions stored in server time zone
l_process_upto_date_stz   VARCHAR2(50);

-- process upto date for a legal entity
l_le_process_upto_date  VARCHAR2(50);

l_legal_entity_id       NUMBER;
l_cost_type_id          NUMBER;
l_period_id             NUMBER;
l_run_options           NUMBER;
l_tolerance             NUMBER;
l_number_of_iterations  NUMBER;
l_number_of_workers     NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.begin'
                  ,l_routine || '<'
                  );
  END IF;

-- =====================================================================
-- Bug#4351270 fix: Time zone -  validate process upto date of the
-- Legal Entity
-- =====================================================================
l_le_process_upto_date := p_process_upto_date;

 l_legal_entity_id := FND_NUMBER.CANONICAL_TO_NUMBER(p_legal_entity_id);
 l_cost_type_id := FND_NUMBER.CANONICAL_TO_NUMBER(p_cost_type_id);
 l_period_id := FND_NUMBER.CANONICAL_TO_NUMBER(p_period_id);
 l_run_options := FND_NUMBER.CANONICAL_TO_NUMBER(p_run_options);
 l_tolerance := FND_NUMBER.CANONICAL_TO_NUMBER(p_tolerance);
 l_number_of_iterations := FND_NUMBER.CANONICAL_TO_NUMBER(p_number_of_iterations);
 l_number_of_workers := FND_NUMBER.CANONICAL_TO_NUMBER(p_number_of_workers);
-- ======================================================================
-- Added below conversion as part of bug#3720424 by Oracle Costing
-- Converting LE timezone to server timezone
-- bug#4358239 fix as regression of bug#3720424
-- ======================================================================
l_process_upto_date_stz :=
  fnd_date.date_to_canonical(INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(fnd_date.canonical_to_date(p_process_upto_date),l_legal_entity_id));

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                ,G_MODULE_HEAD || l_routine || '.srvtz'
                ,'server time zone process upto date:' || l_process_upto_date_stz
                );
END IF;

  CST_PERIODIC_ABSORPTION_PROC.transfer_cp_manager
  ( p_legal_entity          => l_legal_entity_id
  , p_cost_type_id          => l_cost_type_id
  , p_period_id             => l_period_id
  , p_process_upto_date     => l_process_upto_date_stz
  , p_le_process_upto_date  => l_le_process_upto_date
  , p_tolerance             => l_tolerance
  , p_number_of_iterations  => l_number_of_iterations
  , p_number_of_workers     => l_number_of_workers
  , p_run_options           => l_run_options
  , x_return_status         => l_return_status
  , x_msg_count             => l_msg_count
  , x_msg_data              => x_errbuf
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE transfer_cp_mgr_error_exc;
  END IF;

  -- Concurrent program return status Successful
  x_retcode := '0';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,G_MODULE_HEAD || l_routine || '.end'
                  ,l_routine || '>'
                  );
  END IF;

EXCEPTION
  WHEN transfer_cp_mgr_error_exc THEN
    -- Concurrent program return status Error
    x_retcode := '2';

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := '2';
    x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      x_retcode := '2';
      x_errbuf  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                          ,1
                          ,250);

    END IF;

END Periodic_Absorb_Cost_Process;

END CST_PERIODIC_ABSORPTION_CP;

/
