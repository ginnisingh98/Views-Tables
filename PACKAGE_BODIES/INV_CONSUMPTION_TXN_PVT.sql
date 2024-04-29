--------------------------------------------------------
--  DDL for Package Body INV_CONSUMPTION_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSUMPTION_TXN_PVT" AS
-- $Header: INVVRETB.pls 120.1 2006/04/27 14:27:22 rajkrish noship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVRETB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Create Records in mtl_consumption_transactions                     |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      Price Update Insert                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     07/22/03 David Herring   Created procedure                        |
--|     10/27/03 David Herring   Added update                             |
--|                              to mtl_material_transactions             |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_CONSUMPTION_TXN_PVT';
g_user_id              NUMBER       := FND_PROFILE.value('USER_ID');
g_resp_id              NUMBER       := FND_PROFILE.value('RESP_ID');

--===================
-- PUBLIC PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Price Update Insert     PUBLIC
-- PARAMETERS: p_transaction_id            IN unique id and link to mmt
--             p_consumption_po_header_id  IN consumption advice (global)
--             p_consumption_release_id    IN consumption advice (local)
--             p_transaction_quantity      IN quantity retroactively priced
--
-- COMMENT   : This procedure will insert records
--           : into mtl_consumption_transactions
--           : mtl_material_transactions is updated with
--           : the owning org of the blanket.
--=========================================================================
PROCEDURE price_update_insert
( p_transaction_id               IN   NUMBER
, p_consumption_po_header_id     IN   NUMBER
, p_consumption_release_id       IN   NUMBER
, p_transaction_quantity         IN   NUMBER
, p_po_distribution_id           IN   NUMBER
, x_msg_count                    OUT  NOCOPY NUMBER
, x_msg_data                     OUT  NOCOPY VARCHAR2
, x_return_status                OUT  NOCOPY VARCHAR2
)
IS
l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_blanket            NUMBER;
l_owning_org_id      NUMBER;
BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> Update Consumption','INV_CONSUMPTION_TXN_PVT'
     , 9
     );
  END IF;

  INSERT INTO mtl_consumption_transactions mct
  ( mct.transaction_id
  , mct.consumption_po_header_id
  , mct.consumption_release_id
  , mct.net_qty
  , mct.created_by
  , mct.creation_date
  , mct.last_updated_by
  , mct.last_update_date
  , mct.last_update_login
  , mct.consumption_processed_flag
  , mct.po_distribution_id
  )
  VALUES
  ( p_transaction_id
  , p_consumption_po_header_id
  , p_consumption_release_id
  , p_transaction_quantity
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.login_id
  , 'Y'
  , p_po_distribution_id
  );

  -- populate the owning org in mtl_material_transactions
  -- with the vendor site id
  -- The is needed for the isp page to pick up the
  -- price update transactions bug 3209997

  SELECT DISTINCT mmt.transaction_source_id
  INTO l_blanket
  FROM mtl_material_transactions mmt
  WHERE mmt.transaction_id = p_transaction_id;

  SELECT DISTINCT poh.vendor_site_id
  INTO l_owning_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = l_blanket;

  UPDATE mtl_material_transactions mmt
  SET mmt.owning_organization_id = l_owning_org_id
     ,mmt.owning_tp_type = 1
  WHERE mmt.transaction_id = p_transaction_id;

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '<< Update Consumption','INV_CONSUMPTION_TXN_PVT'
     , 9
     );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END price_update_insert;

END INV_CONSUMPTION_TXN_PVT;

/
