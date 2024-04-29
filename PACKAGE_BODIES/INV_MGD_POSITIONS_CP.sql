--------------------------------------------------------
--  DDL for Package Body INV_MGD_POSITIONS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POSITIONS_CP" AS
-- $Header: INVCPOSB.pls 120.1 2005/06/21 06:25:50 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCPOSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Concurrent programs implementation for Inventory Position View    |
--|     and Export                                                        |
--|                                                                       |
--| HISTORY                                                               |
--|     10/12/2000 Paolo Juvara      Created                              |
--|     11/21/2002 Vivian Ma         PL/SQL Performance: print to log     |
--|                                  only if debug profile option is      |
--|                                  enabled                              |
--+=======================================================================+

--===================
-- GLOBAL VARIABLES
--===================
G_DEBUG    VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build                   PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_data_set_name         data set name
--             p_hierarchy_id          organization hierarchy
--             p_hierarchy_level       hierarchy level
--             p_item_from             item range from
--             p_item_to               item range to
--             p_category_id           item category
--             p_date_from             date range from
--             p_date_to               date range to
--             p_bucket_size           bucket size
-- COMMENT   : Inventory Position Build concurrent program
--========================================================================
PROCEDURE Build
( x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_data_set_name      IN  VARCHAR2
, p_hierarchy_id       IN  NUMBER
, p_hierarchy_level    IN  VARCHAR2
, p_item_from          IN  VARCHAR2
, p_item_to            IN  VARCHAR2
, p_category_id        IN  NUMBER
, p_date_from          IN  VARCHAR2
, p_date_to            IN  VARCHAR2
, p_bucket_size        IN  VARCHAR2
)
IS

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log_Initialize;
    INV_MGD_POS_UTIL.Log
    ( INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    ,  '> INV_MGD_POSITIONS_CP.Build'
    );
  END IF;

  INV_MGD_POSITIONS_PROC.Build
  ( p_init_msg_list      => FND_API.G_TRUE
  , x_return_status      => l_return_status
  , x_msg_count          => l_msg_count
  , x_msg_data           => l_msg_data
  , p_data_set_name      => p_data_set_name
  , p_hierarchy_id       => p_hierarchy_id
  , p_hierarchy_level    => p_hierarchy_level
  , p_item_from          => p_item_from
  , p_item_to            => p_item_to
  , p_category_id        => p_category_id
  , p_date_from          => p_date_from
  , p_date_to            => p_date_to
  , p_bucket_size        => p_bucket_size
  );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuff := NULL;
  ELSE
    x_retcode := 2;
    x_errbuff := SUBSTR(l_msg_data, 1, 255);
    ROLLBACK;
  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , '< INV_MGD_POSITIONS_CP.Build'
    );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( 'INV_MGD_POSITIONS_CP'
                             , 'Build'
                             );
    END IF;
    x_retcode := 2;
    x_errbuff := SUBSTR
                 ( FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                 , 1, 255
                 );
    ROLLBACK;

END Build;


--========================================================================
-- PROCEDURE : Purge                   PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_purge_all             Y to purge all, N otherwise
--             p_data_set_name         purge specific data set name
--             p_created_by            purge data set for specific user ID
--             p_creation_date         purge data set created before date
-- COMMENT   : Inventory Position Purge concurrent program; p_purge_all takes
--             priority over other parameters
--========================================================================
PROCEDURE Purge
( x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_purge_all          IN  VARCHAR2
, p_data_set_name      IN  VARCHAR2
, p_created_by         IN  VARCHAR2
, p_creation_date      IN  VARCHAR2
)
IS

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log_Initialize;
    INV_MGD_POS_UTIL.Log
    ( INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , '> INV_MGD_POSITIONS_CP.Purge'
    );
  END IF;

  INV_MGD_POSITIONS_PROC.Purge
  ( p_init_msg_list      => FND_API.G_TRUE
  , x_return_status      => l_return_status
  , x_msg_count          => l_msg_count
  , x_msg_data           => l_msg_data
  , p_purge_all          => p_purge_all
  , p_created_by         => p_created_by
  , p_data_set_name      => p_data_set_name
  , p_creation_date      => p_creation_date
  );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_retcode := 0;
    x_errbuff := NULL;
  ELSE
    x_retcode := 2;
    x_errbuff := SUBSTR(l_msg_data, 1, 255);
    ROLLBACK;
  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , '< INV_MGD_POSITIONS_CP.Purge'
    );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( 'INV_MGD_POSITIONS_CP'
                             , 'Purge'
                             );
    END IF;
    x_retcode := 2;
    x_errbuff := SUBSTR
                 ( FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                 , 1, 255
                 );
    ROLLBACK;

END Purge;


END INV_MGD_POSITIONS_CP;

/
