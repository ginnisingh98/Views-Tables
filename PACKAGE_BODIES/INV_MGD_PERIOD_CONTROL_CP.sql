--------------------------------------------------------
--  DDL for Package Body INV_MGD_PERIOD_CONTROL_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_PERIOD_CONTROL_CP" AS
/* $Header: INVCPOPB.pls 120.1 2006/03/09 03:54:51 vmutyala noship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCPCLB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_OPEN_PERIODS_CP                                    |
--|                                                                       |
--| HISTORY                                                               |
--|   26-Sep-2000    rajkrish   Created                                   |
--|   12-DEc-2000    rajkrish   Updated        Hierarchy Origin           |
--|   12/05/2001     vjavli     Updated with new apis for performance     |
--|                             improvement                               |
--|   11/21/2002     vma        Change code to print to log only when     |
--|                             debug profile option is enabled           |
--|   03-FEB-2004  nkamaraj   x_errbuff and x_retcode should be in order  |
--|                           according to AOL standards inorder to       |
--|                           display warning and error messages.         |
--|                           Otherwise, conc. manager will consider as   |
--|                           completed normal eventhough exception raised|
--|     04/08/2004 nesoni        Bug 3555234. Error/Exceptions should be  |
--|                              logged irrespective of FND Debug Enabled |
--|                              profile option.                          |
--+======================================================================*/


--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs)

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_PERIOD_CONTROL_CP';
g_log_level            NUMBER       := NULL;
g_log_mode             VARCHAR2(3)  := 'OFF'; -- possible values: OFF,SQL,SRS

--===============================================
-- GLOBAL VARIABLES
--===============================================
G_DEBUG                VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--========================================================================
-- PROCEDURE : Run_Open_Periods        PUBLIC
-- PARAMETERS: x_retcode               return status
--             x_errbuf                return error messages
--             p_org_hierarchy_origin  IN    NUMBER
--             p_org_hierarchy_id      IN    NUMBER
--             p_close_period_name     IN    VARCHAR2
--             p_open_period_count     IN    NUMBER
--             p_open_or_close_flag    IN    VARCHAR2
--             p_requests_count        IN    NUMBER
--
-- COMMENT   : The concurrent program to Open / Close periods for
--              each organization in
--              organization hierarchy level list.

--=========================================================================
PROCEDURE Run_Period_Control
        ( 	     x_errbuf                OUT  NOCOPY VARCHAR2
        ,        x_retcode               OUT  NOCOPY VARCHAR2
        ,        p_org_hierarchy_origin  IN    NUMBER
        ,	       p_org_hierarchy_id      IN    NUMBER
        ,        p_close_period_name     IN    VARCHAR2
	,        p_close_if_res_recmd    IN    VARCHAR2
        ,        p_open_period_count     IN    NUMBER
        ,        p_open_or_close_flag    IN    VARCHAR2
        ,        p_requests_count        IN    NUMBER
        )
IS

BEGIN

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
     (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'> INV_MGD_OPEN_PERIODS_CP.Run_Period_Control '
     );
  END IF;

  FND_PROFILE.Put('AFLOG_LEVEL', '1');
  -- initialize log
  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log_Initialize;
  END IF;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Calling INV_MGD_PRD_CONTROL_MEDIATOR.Period_Control for '||
        p_open_or_close_flag
    );
  END IF;

  INV_MGD_PRD_CONTROL_MEDIATOR.Period_Control
        (        x_retcode               => x_retcode
        ,        x_errbuff               => x_errbuf
        ,        p_org_hierarchy_origin	 => p_org_hierarchy_origin
   	,	 p_org_hierarchy_id	 => p_org_hierarchy_id
        ,        p_close_period_name     => p_close_period_name
	,        p_close_if_res_recmd    => p_close_if_res_recmd
        ,        p_open_period_count     => p_open_period_count
        ,        p_open_or_close_flag    => p_open_or_close_flag
        ,        p_requests_count        => p_requests_count
        );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
     (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Out of Period_Control '
     );
  END IF;

  -- SRS success
--      x_errbuf := NULL;
--      x_retcode := 0 ;

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
   (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    ,'< INV_MGD_OPEN_PERIODS_CP.Run_Period_Control '
   );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
     */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                            , 'SQLERRM '|| SQLERRM) ;
    --END IF;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' Run_Period_Control '
      );
    END IF;

    x_retcode := '2' ;
    x_errbuf  := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,255);
    ROLLBACK;
    RAISE;

END Run_Period_Control ;


END INV_MGD_PERIOD_CONTROL_CP ;


/
