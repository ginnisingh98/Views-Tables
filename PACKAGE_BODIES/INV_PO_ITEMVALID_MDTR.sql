--------------------------------------------------------
--  DDL for Package Body INV_PO_ITEMVALID_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PO_ITEMVALID_MDTR" AS
-- $Header: INVMPO1B.pls 120.0 2005/05/25 05:16:24 appldev noship $ --
--+===========================================================================+
--|               Copyright (c) 2003 Oracle Corporation                       |
--|                       Redwood Shores, CA, USA                             |
--|                         All rights reserved.                              |
--+===========================================================================+
--| FILENAME                                                                  |
--|   INVMPO1S.pls                                                            |
--|                                                                           |
--| DESCRIPTION                                                               |
--|   Check  the VMI/Consigned Enabled for a given item/organization          |
--|	combinations.							                                  |
--|     This mediator package is used to access PO objects from               |
--|     INV product.                                                          |
--|                                                                           |
--| PROCEDURES:                                                               |
--|   Check_VmiOrConsign_Enabled                                              |
--|   Check_Consign_Enabled                                                   |
--|                                                                           |
--| FUNCTIONS:                                                                |
--|                                                                           |
--| HISTORY                                                                   |
--|   2003/21/07 dpenmats       Created.                                      |
--|	2005/07/03 myerrams	  Updated the file to comply with File.Sql.46   |
--|					  GSCC Standard, Bug No: 4202824			|
--|                                                                           |
--+===========================================================================+

--=============================================================================
-- TYPE DECLARATIONS
--=============================================================================

--=============================================================================
-- CONSTANTS
--=============================================================================

G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'INV.plsql.'||G_PKG_NAME || '.';

--=============================================================================
-- GLOBAL VARIABLES
--=============================================================================

g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================

---=========================================================================
-- PROCEDURE  : Check_VmiOrConsign_Enabled
-- PARAMETERS:
--   p_api_version        REQUIRED. API version
--   p_init_msg_list      REQUIRED. FND_API.G_TRUE to reset the message list
--                                  FND_API.G_FALSE to not reset it.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   x_return_status      REQUIRED. Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count          REQUIRED. Number of messages on the message list
--   x_msg_data           REQUIRED. Return message data if message count is 1
--   p_item_id	          REQUIRED. Inventory Item Id
--   p_organization_id    REQUIRED. Inventory organization ID
--   x_vmiorconsign_flag  REQUIRED. Vmi or consigned enabled flag
--                                  'Y' indicates a valid vmi or cosigned
--                                    inventory exists
--                                  'N' indicates no valid vmi or consigned
-- COMMENT   : This procedure is called by Items form and Item open interface
--		to decide whether there exist a valid vmi or consigned
--		for a particular item/organization combination
--=========================================================================

PROCEDURE Check_VmiOrConsign_Enabled
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, p_item_id                   IN  NUMBER
, p_organization_id           IN  NUMBER
, x_vmiorconsign_flag         OUT  NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Check_VmiOrConsign_Enabled';
l_api_version CONSTANT NUMBER       := 1.0;
l_vmiorconsign_flag VARCHAR2(1) := 'N';

BEGIN

--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--  IF (g_fnd_debug = 'Y') THEN
  IF (g_fnd_debug = 'Y'and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  SELECT 'Y'
    INTO l_vmiorconsign_flag
    FROM po_approved_supplier_list pasl,
         po_asl_attributes paa,
	 po_asl_status_rules pasr
    WHERE pasl.item_id = p_item_id
	AND pasl.using_organization_id IN (-1,p_organization_id)
	AND pasl.asl_id = paa.asl_id
	AND pasr.business_rule = '2_SOURCING'
	AND pasr.allow_action_flag = 'Y'
	AND pasr.status_id = pasl.asl_status_id
	AND (disable_flag IS NULL OR disable_flag = 'N')
	AND paa.using_organization_id = (SELECT  max(paa2.using_organization_id)
		FROM po_asl_attributes paa2
		WHERE   paa2.asl_id = pasl.asl_id
		AND paa2.using_organization_id IN (-1,p_organization_id))
	AND (paa.consigned_from_supplier_flag='Y' OR paa.enable_vmi_flag='Y')
	AND rownum=1;

    x_vmiorconsign_flag := l_vmiorconsign_flag;
  FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--  IF (g_fnd_debug = 'Y') THEN
  IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_vmiorconsign_flag := 'N';
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--    IF (g_fnd_debug = 'Y')
    IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Check_VmiOrConsign_Enabled;

---=========================================================================
-- PROCEDURE  : Check_Consign_Enabled
-- PARAMETERS:
--   p_api_version        REQUIRED. API version
--   p_init_msg_list      REQUIRED. FND_API.G_TRUE to reset the message list
--                                  FND_API.G_FALSE to not reset it.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   x_return_status      REQUIRED. Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count          REQUIRED. Number of messages on the message list
--   x_msg_data           REQUIRED. Return message data if message count is 1
--   p_item_id	          REQUIRED. Inventory Item Id
--   p_organization_id    REQUIRED. Inventory organization ID
--   x_vmiorconsign_flag  REQUIRED. Vmi or consigned enabled flag
--                                  'Y' indicates a valid vmi or cosigned
--                                    inventory exists
--                                  'N' indicates no valid vmi or consigned
-- COMMENT   : This procedure is called by Items form and Item open interface
--		to decide whether there exist a valid vmi or consigned
--		for a particular item/organization combination
--=========================================================================

PROCEDURE Check_Consign_Enabled
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, p_item_id                   IN  NUMBER
, p_organization_id           IN  NUMBER
, x_consign_flag         OUT  NOCOPY VARCHAR2
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Check_Consign_Enabled';
l_api_version CONSTANT NUMBER       := 1.0;
l_consign_flag VARCHAR2(1) := 'N';
l_profile   VARCHAR2(1);

BEGIN
--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--  IF (g_fnd_debug = 'Y') THEN
  IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
  END IF;

  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_profile.value('AP_SUPPLIER_CONSIGNED_ENABLED') <> 'Y' THEN
	x_consign_flag := 'N';
  ELSE

  SELECT 'Y'
    INTO l_consign_flag
    FROM po_approved_supplier_list pasl,
         po_asl_attributes paa,
	 po_asl_status_rules pasr
    WHERE pasl.item_id = p_item_id
	AND pasl.using_organization_id IN (-1,p_organization_id)
	AND pasl.asl_id = paa.asl_id
	AND pasr.business_rule = '2_SOURCING'
	AND pasr.allow_action_flag = 'Y'
	AND pasr.status_id = pasl.asl_status_id
	AND (disable_flag IS NULL OR disable_flag = 'N')
	AND paa.using_organization_id = (SELECT  max(paa2.using_organization_id)
		FROM po_asl_attributes paa2
		WHERE   paa2.asl_id = pasl.asl_id
		AND paa2.using_organization_id IN (-1,p_organization_id))
	AND paa.consigned_from_supplier_flag='Y'
	AND rownum=1;

  x_consign_flag := l_consign_flag;
  END IF;

  FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--  IF (g_fnd_debug = 'Y') THEN
  IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_consign_flag := 'N';
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--myerrams, changed the following code to comply with File.Sql.46 GSCC standard, Bug: 4202824
--    IF (g_fnd_debug = 'Y')
    IF (g_fnd_debug = 'Y' and FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Check_Consign_Enabled;

END INV_PO_ITEMVALID_MDTR;


/
