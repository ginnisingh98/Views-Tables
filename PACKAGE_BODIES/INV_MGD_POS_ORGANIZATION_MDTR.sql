--------------------------------------------------------
--  DDL for Package Body INV_MGD_POS_ORGANIZATION_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POS_ORGANIZATION_MDTR" AS
/* $Header: INVMPORB.pls 115.4 2002/11/23 00:02:50 vma ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPORS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Organization Mediator         |
--| HISTORY                                                               |
--|     09/05/2000 Paolo Juvara      Created                              |
--|     09/16/2002 Veeresha Javli    Bug#2563291 fix use the new api      |
--|                                  get_organization_list instead of     |
--|                                  org_hierarchy_list                   |
--|     09/17/2002 Veeresha Javli    l_hierarchy_name removed             |
--|     11/21/2002 Vivian Ma         Performance: modify code to print to |
--|                                  log only if debug profile option is  |
--|                                  enabled                              |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME           CONSTANT VARCHAR2(30):= 'INV_MGD_POS_ORGANIZATION_MDTR';

--===================
-- GLOBAL VARIABLES
--===================
G_DEBUG              VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build_Organization_List PUBLIC
-- PARAMETERS: p_hierarchy_id          organization hierarchy
--             p_hierarchy_level_id    organization ID identifying the level
--             x_organization_tbl      list of organization
-- COMMENT   : Builds the list of organizations that belong to a hierarchy level
-- POST-COND : x_organization_tbl is not empty
--========================================================================
PROCEDURE Build_Organization_List
( p_hierarchy_id       IN            NUMBER
, p_hierarchy_level_id IN            NUMBER
, x_organization_tbl   IN OUT NOCOPY INV_MGD_POS_UTIL.organization_tbl_type
)
IS

l_api_name             CONSTANT VARCHAR2(30):= 'Build_Organization_List';
l_org_id_tbl           INV_ORGHIERARCHY_PVT.OrgID_tbl_type;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

  -- Initialize organization list
  x_organization_tbl.DELETE;

  -- bug#2563291 fix use the performance enhancement api
  -- get organization list
  INV_ORGHIERARCHY_PVT.get_organization_List
  ( p_hierarchy_id        => p_hierarchy_id
  , p_origin_org_id       => p_hierarchy_level_id
  , x_org_id_tbl          => l_org_id_tbl
  , p_include_origin      => 'Y'
  );
  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'organization list retrieved'
    );
  END IF;

  -- complete the record information
  FOR l_Idx IN l_org_id_tbl.FIRST..l_org_id_tbl.LAST
  LOOP
    SELECT
      organization_id
    , organization_code
    INTO
      x_organization_tbl(l_Idx).id
    , x_organization_tbl(l_Idx).code
    FROM  mtl_parameters
    WHERE organization_id = l_org_id_tbl(l_Idx);
  END LOOP;
  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'organization information retrieved'
    );

    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

END Build_Organization_List;


END INV_MGD_POS_ORGANIZATION_MDTR;

/
