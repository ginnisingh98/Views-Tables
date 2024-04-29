--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RECONCILIAITON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RECONCILIAITON_PVT" AUTHID CURRENT_USER AS
--$Header: JMFVSKRS.pls 120.0 2005/07/06 00:25 rajkrish noship $
--+===========================================================================+
--|               Copyright (c) YYYY Oracle Corporation                       |
--|                       Redwood Shores, CA, USA                             |
--|                         All rights reserved.                              |
--+===========================================================================+
--| FILENAME                                                                  |
--|   JMFVSHRB.pls|
--|                                                                           |
--| DESCRIPTION                                                               |
--|   This package is used for SHIKYU Reconciliation purposes
--|                                                                           |
--| PROCEDURES:                                                               |
--|   Process_SHIKYU_Reconciliation
--|                                                                           |
--| FUNCTIONS:                                                                |
--|                                                                           |
--| HISTORY                                                                   |
--|   May-01 2005 rajkrish created
-- Last updated: May-19th afternoon
--|                                                                           |
--+===========================================================================+

--=============================================================================
-- TYPE DECLARATIONS
--=============================================================================

--=============================================================================
-- CONSTANTS
--=============================================================================

--=============================================================================
-- GLOBAL VARIABLES
--=============================================================================
--g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================e
--=============================================================================
-- API NAME      : Process_SHIKYU_Reconciliation
-- TYPE          : PRIVATE
-- PRE-REQS      : SHIKYU datamodel and SHIKYU process should exists
-- DESCRIPTION   : Process the SHIKYi reconciliation once the
---                shikyu Interlock has been run
---
-- PARAMETERS    :
--   p_api_version        REQUIRED. API version
--   p_init_msg_list      REQUIRED. FND_API.G_TRUE to reset the message list
--                                  FND_API.G_FALSE to not reset it.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   p_commit             OPTIONAL. FND_API.G_TRUE to have API commit the change
--                                  FND_API.G_FALSE to not commit the change.
--                                  Include this if API does DML.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   p_validation_level   OPTIONAL. value between 0 and 100.
--                                  FND_API.G_VALID_LEVEL_NONE  -> 0
--                                  FND_API.G_VALID_LEVEL_FULL  -> 100
--                                  Public APIs should not have this parameter
--                                  since it should always be FULL validation.
--                                  If API perform some level not required by
--                                  some API caller, this parameter should be
--                                  included.
--                                  Product group can define intermediate
--                                  validation levels.
--                                  If pass NULL, it means i
--                                    FND_API.G_VALID_LEVEL_FULL
--
--   x_return_status      REQUIRED. Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count          REQUIRED. Number of messages on the message list
--   x_msg_data           REQUIRED. Return message data if message count is 1
--   p_card_id            REQUIRED. Card ID to be deleted.
-- EXCEPTIONS    :
--
--=============================================================================

PROCEDURE Process_SHIKYU_Reconciliation
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, p_commit                    IN  VARCHAR2
, p_validation_level          IN  NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, P_Operating_unit            IN NUMBER
, p_from_organization         IN NUMBER
, p_to_organization           IN NUMBER
);


END JMF_SHIKYU_RECONCILIAITON_PVT ;

 

/
