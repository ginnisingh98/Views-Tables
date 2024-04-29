--------------------------------------------------------
--  DDL for Package Body INV_AP_TAX_ENGINE_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_AP_TAX_ENGINE_MDTR" AS
-- $Header: INVMTAXB.pls 120.2 2006/01/31 18:42:28 rajkrish noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMTAXB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consiged inventory INV/AP Dependency wrapper API                   |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_Default_Tax_Code                                              |
--|     Calculate_Tax                                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     12/01/02 pseshadr  Created                                        |
--|     12/01/02 dherring  Created                                        |
--+========================================================================

--===================
-- PROCEDURES AND FUNCTIONS
--===================

l_debug     NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

--========================================================================
-- PROCEDURE  : Calculate_Tax         PUBLIC
-- COMMENT   : Calculate tax done by eBTax
--========================================================================

PROCEDURE Calculate_Tax
(  x_return_status OUT NOCOPY VARCHAR2
,  x_msg_count     OUT NOCOPY VARCHAR2
,  x_msg_data      OUT NOCOPY VARCHAR2
)
IS

BEGIN

 IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'Entering ZX_API_PUB.Calculate_Tax'
     , 9
     );
  END IF;

   -- Invoke eBTax to calculate Tax.

   ZX_API_PUB.Calculate_Tax
   ( p_api_version   => 1.0
   , p_init_msg_list => FND_API.G_TRUE
   , p_validation_level => 11
   , p_commit           => FND_API.G_FALSE
   , x_return_status    => x_return_status
   , x_msg_count        => x_msg_count
   , x_msg_data         => x_msg_data);

IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'after return from  ZX_API_PUB.Calculate_Tax '|| x_return_status
     , 9
     );
  END IF;

IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'Calling ZX_API_PUB.Determine_recovery '
     , 9
     );
  END IF;


ZX_API_PUB.Determine_recovery
   ( p_api_version   => 1.0
   , p_init_msg_list => FND_API.G_TRUE
   , p_validation_level => 11
   , p_commit           => FND_API.G_FALSE
   , x_return_status    => x_return_status
   , x_msg_count        => x_msg_count
   , x_msg_data         => x_msg_data);

IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'after ZX_API_PUB.Determine_recovery  ' || x_return_status
     , 9
     );
  END IF;


IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( 'exiting ZX_API_PUB.Calculate_Tax'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_Tax;


END INV_AP_TAX_ENGINE_MDTR;

/
