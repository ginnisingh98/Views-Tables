--------------------------------------------------------
--  DDL for Package INV_PO_ITEMVALID_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PO_ITEMVALID_MDTR" AUTHID CURRENT_USER AS
-- $Header: INVMPO1S.pls 115.1 2003/08/21 08:31:57 dpenmats noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPO1S.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Check  the VMI/Consigned Enabled for a given item/organization    |
--|	combinations.							                              |
--|     This mediator package is used to access PO objects from           |
--|     INV product.                                                      |
--|                                                                       |
--| HISTORY                                                               |
--|     2003/21/07 dpenmats       Created                                 |
--+=======================================================================+

--=============================================================================
-- CONSTANTS
--=============================================================================

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'INV_PO_ITEMVALID_MDTR';

--=============================================================================
-- PUBLIC VARIABLES
--=============================================================================

--=========================================================================
-- PROCEDURES AND FUNCTIONS
--=========================================================================

--=========================================================================
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
);

--=========================================================================
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
--   x_consign_flag       REQUIRED. Consigned enabled flag
--                                  'Y' indicates a valid vmi or cosigned
--                                    inventory exists
--                                  'N' indicates no valid vmi or consigned
-- COMMENT   : This procedure is called by Items form and Item open interface
--		to decide whether there exist a valid consigned Inventory
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
, x_consign_flag              OUT NOCOPY VARCHAR2
);

END INV_PO_ITEMVALID_MDTR;


 

/
