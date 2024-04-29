--------------------------------------------------------
--  DDL for Package Body JMF_INTERLOCK_SHIKYU_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_INTERLOCK_SHIKYU_CP" AS
-- $Header: JMFCSHKB.pls 120.2 2005/07/08 17:44 vchu noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFCSHKB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Interlock SHIKYU Concurrent Program wrapper                       |
--| HISTORY                                                               |
--|     04/26/2005 pseshadr       Created                                 |
--|     07/05/2005 rajkrish       Updated MOAC                            |
--|     07/08/2005 vchu           Fixed GSCC error File.Pkg.21            |
--+======================================================================--

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'JMF_Interlock_Shikyu_CP';
g_log_enabled          BOOLEAN;

--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================

--========================================================================
-- PROCEDURE : Interlock_SHIKYU_Manager     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_batch_size         IN    Size of a batch
--             p_max_workers        IN    Number of workers allowed
--             p_operating_unit     IN    Operating Unit
--             p_from_organization  IN    From Organization
--             p_to_organization    IN    To Organization
-- COMMENT   : This is the concurrent program wrapper for the Interlock
--             SHIKYU Manager.This will invoke the JMF_Subcontract_Orders Private
--             package to load the subcontract orders and assign records to batches.
--=========================================================================
PROCEDURE Interlock_SHIKYU_Manager
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_size         IN  NUMBER
, p_max_workers        IN  NUMBER
, p_from_organization  IN  NUMBER
, p_to_organization    IN  NUMBER
)
IS
 l_program CONSTANT VARCHAR2(30) := 'Interlock_Shikyu_Manager';
 l_OU_id   NUMBER ;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||'Start >>'
                  );
  END IF;

  l_OU_ID := MO_GLOBAL.get_current_org_id ;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'l_OU_ID => '|| l_OU_ID
                  );
  END IF;
  JMF_SUBCONTRACT_ORDERS_PVT.Subcontract_Orders_Manager
  ( p_batch_size         => p_batch_size
  , p_max_workers        => p_max_workers
  , p_operating_unit     => l_ou_id
  , p_from_organization  => p_from_organization
  , p_to_organization    => p_to_organization
  , p_init_msg_list      => FND_API.G_TRUE
  , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '  Subcontract_Orders_Manager '
                  );
  END IF;

  IF g_log_enabled
  THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME ||l_program
                  , 'Exit'
                  ) ;
  END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);

END Interlock_SHIKYU_Manager;

--========================================================================
-- PROCEDURE : Interlock_SHIKYU_Worker     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY  Return status
--             x_errbuff            OUT NOCOPY  Return error message
--             p_batch_id           IN    Batch identifier
-- COMMENT   : This procedure will process all the records in the batch
--=========================================================================
PROCEDURE Interlock_SHIKYU_Worker
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
)
IS
 l_program CONSTANT VARCHAR2(30) := 'Interlock_Shikyu_Worker';

BEGIN
  IF g_log_enabled
  THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME ||l_program
                  , 'Entry'
                  ) ;
  END IF;
  END IF;

  JMF_SUBCONTRACT_ORDERS_PVT.Subcontract_Orders_Worker
  ( p_batch_id  => p_batch_id
  );

  IF g_log_enabled
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME ||l_program
                  , 'Exit'
                  ) ;
  END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);


END Interlock_SHIKYU_Worker;

--========================================================================
-- PROCEDURE :Run_SHIKYU_reconciliation     PUBLIC
-- PARAMETERS:
--             x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_operating_unit         IN    Operating Unit
--             p_from_organization   IN    From Organization
--             p_to_organization       IN    To Organization
-- COMMENT   : This is the concurrent program wrapper for the SHIKYU
--                            reconciliation process
--=========================================================================

PROCEDURE Run_SHIKYU_reconciliation
( x_retcode                     OUT NOCOPY VARCHAR2
, x_errbuff                     OUT NOCOPY VARCHAR2
, p_from_organization           IN  NUMBER
, p_to_organization             IN  NUMBER
)
IS

l_return_status VARCHAR2(1) ;
l_msg_count      NUMBER ;
l_msg_data       VARCHAR2(3000) ;
l_OU_ID          NUMBER ;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    g_log_enabled := TRUE;
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , G_PKG_NAME ||
            'Run_SHIKYU_reconciliation.invoked'
                 , 'Entry' ) ;
  END IF;

 l_OU_ID   := MO_GLOBAL.get_current_org_id ;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , G_PKG_NAME ,
            'l_OU_ID => '|| l_OU_ID
                  ) ;
  END IF;

   JMF_SHIKYU_RECONCILIAITON_PVT.Process_SHIKYU_Reconciliation
  ( p_api_version              => 1.0
  , p_init_msg_list            => NULL
  , p_commit                   => NULL
  , p_validation_level         => NULL
  , x_return_status            => l_return_status
  , x_msg_count                => l_msg_count
  , x_msg_data                 => l_msg_data
  , P_Operating_unit           => l_OU_ID
  , p_from_organization        => p_from_organization
  , p_to_organization         => p_to_organization
  ) ;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , G_PKG_NAME ||
            'Process_SHIKYU_Reconciliation'
             , ' return'
                  ) ;
  END IF;
  IF g_log_enabled
  THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                 , G_PKG_NAME ||
        'Run_SHIKYU_reconciliation.invoked'
                 , 'Exit' ) ;
  END IF;
  END IF;

EXCEPTION

 WHEN OTHERS THEN
   x_retcode := 2;
   x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                       ,1
                       ,250);

END Run_SHIKYU_reconciliation ;

END JMF_Interlock_SHIKYU_CP;

/
