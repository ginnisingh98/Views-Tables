--------------------------------------------------------
--  DDL for Package Body INV_MGD_POS_ITEM_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POS_ITEM_MDTR" AS
/* $Header: INVMPITB.pls 120.2 2006/03/09 23:46:24 nesoni noship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPITS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Item Mediator                 |
--| HISTORY                                                               |
--|     09/05/2000 Paolo Juvara      Created                              |
--|     11/21/2002 Vivian Ma         Performance: modify code to print to |
--|                                  log only if debug profile option is  |
--|                                  enabled                              |
--|     19/AUG/2005 Neelam Soni      Modified for bug  4357322            |
--|     09/MAR/2006 Neelam Soni      Modified for bug  4951736                        |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME           CONSTANT VARCHAR2(30):= 'INV_MGD_POS_ITEM_MDTR';


--===================
-- GLOBAL VARIABLES
--===================
G_DEBUG              VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build_Item_List PUBLIC
-- PARAMETERS: p_organization_tbl      list of organization
--             p_master_org_id         master item organization
--             p_item_from             item from range
--             p_item_to               item to range
--             p_category_id           category id
--             x_item_tbl              item list
-- COMMENT   : Builds the list of items to view
-- PRE-COND  : p_organization_tbl is not empty
-- POST-COND : x_item_tbl is not empty
--========================================================================
PROCEDURE Build_Item_List
( p_organization_tbl   IN            INV_MGD_POS_UTIL.organization_tbl_type
, p_master_org_id      IN            NUMBER   DEFAULT NULL
, p_item_from          IN            VARCHAR2 DEFAULT NULL
, p_item_to            IN            VARCHAR2 DEFAULT NULL
, p_category_id        IN            NUMBER   DEFAULT NULL
, x_item_tbl           IN OUT NOCOPY INV_MGD_POS_UTIL.item_tbl_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Build_Item_List';
-- Following usused variable commented during bug 4357322
--l_master_organization_id   NUMBER;
l_category_set_id          NUMBER;
CURSOR l_item1_crsr
( p_organization_id        NUMBER
, p_item_from              VARCHAR2
, p_item_to                VARCHAR2
) IS
/* yawang fix bug 2210524 use kfv view to replace the base table to get all the segments
  SELECT  organization_id
     ,  inventory_item_id
     ,  segment1
  FROM  mtl_system_items_b msi
  WHERE organization_id = p_organization_id
    AND segment1
        BETWEEN NVL(p_item_from,segment1) AND NVL(p_item_to,segment1);
*/
/* UNION part from query is deleted for better performance. Bug 4951736
SELECT  organization_id
     ,  inventory_item_id
  FROM  mtl_system_items_kfv msik
  WHERE organization_id = p_organization_id
    AND concatenated_segments
    BETWEEN NVL(p_item_from,concatenated_segments) AND NVL(p_item_to,concatenated_segments)
  -- Following union clause added for bug 4357322
  UNION
  SELECT p_organization_id, -1
  FROM dual where NOT EXISTS
  ( SELECT 1 FROM mtl_system_items_kfv
    WHERE organization_id = p_organization_id
    AND concatenated_segments
        BETWEEN NVL(p_item_from,concatenated_segments) AND NVL(p_item_to,concatenated_segments)
  ) ;
*/
SELECT  organization_id
     ,  inventory_item_id
  FROM  mtl_system_items_kfv msik
  WHERE organization_id = p_organization_id
    AND concatenated_segments
    BETWEEN NVL(p_item_from,concatenated_segments) AND NVL(p_item_to,concatenated_segments);

CURSOR l_item2_crsr
( p_organization_id        NUMBER
, p_item_from              VARCHAR2
, p_item_to                VARCHAR2
--, p_mstr_organization_id   NUMBER  yawang fix bug 2210154
, p_category_set_id        NUMBER
, p_category_id            NUMBER
) IS
SELECT  msik.organization_id
     ,  msik.inventory_item_id
  FROM  mtl_item_categories mic
     ,  mtl_system_items_kfv msik
  WHERE msik.organization_id = p_organization_id
    AND msik.concatenated_segments
        BETWEEN NVL(p_item_from, msik.concatenated_segments)
            AND NVL(p_item_to,msik.concatenated_segments)
    AND mic.inventory_item_id = msik.inventory_item_id
    AND mic.organization_id = msik.organization_id --p_mstr_organization_id,
                                                   --fix bug 2210154 yawang
    AND mic.category_set_id = p_category_set_id
    AND mic.category_id     = p_category_id
  -- Following union clause added for bug 4357322
  UNION
  SELECT p_organization_id, -1
  FROM dual where NOT EXISTS
  ( SELECT 1 FROM mtl_system_items_kfv msik, mtl_item_categories mic
    WHERE msik.organization_id = p_organization_id
    AND msik.concatenated_segments
        BETWEEN NVL(p_item_from,msik.concatenated_segments)
            AND NVL(p_item_to,msik.concatenated_segments)
    AND mic.inventory_item_id = msik.inventory_item_id
    AND mic.organization_id = msik.organization_id
    AND mic.category_set_id = p_category_set_id
    AND mic.category_id     = p_category_id
  )
  ;

/* yawang fix bug 2210524 use kfv view to replace the base table to get all the segments
CURSOR l_item2_crsr
( p_organization_id        NUMBER
, p_item_from              VARCHAR2
, p_item_to                VARCHAR2
--, p_mstr_organization_id   NUMBER  yawang fix bug 2210154
, p_category_set_id        NUMBER
, p_category_id            NUMBER
) IS
SELECT  msi.organization_id
     ,  msi.inventory_item_id
     ,  msi.segment1
  FROM  mtl_item_categories mic
     ,  mtl_system_items_b msi
  WHERE msi.organization_id = p_organization_id
    AND msi.segment1
        BETWEEN NVL(p_item_from, msi.segment1) AND NVL(p_item_to,msi.segment1)
    AND mic.inventory_item_id = msi.inventory_item_id
    AND mic.organization_id = msi.organization_id --p_mstr_organization_id,fix bug 2210154 yawang
    AND mic.category_set_id = p_category_set_id
    AND mic.category_id     = p_category_id;
*/
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
     ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

  -- Initialize organization list
  x_item_tbl.DELETE;

  IF p_category_id IS NULL THEN

    -- don't need to join to mtl_item_categories
    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'build item list without category filter'
      );
    END IF;

    BEGIN
      FOR l_Idx IN p_organization_tbl.FIRST..p_organization_tbl.LAST LOOP
        OPEN l_item1_crsr
        ( p_organization_tbl(l_Idx).id
        , p_item_from
        , p_item_to
        );
        LOOP
          FETCH l_item1_crsr
          INTO
            x_item_tbl(x_item_tbl.COUNT + 1).organization_id
          , x_item_tbl(x_item_tbl.COUNT + 1).item_id;
         -- Added for bug 4951736 to avoid union in query
         IF l_item1_crsr%NOTFOUND AND l_item1_crsr%ROWCOUNT = 0 THEN
          x_item_tbl(x_item_tbl.COUNT + 1).organization_id :=
           p_organization_tbl(l_Idx).id;
          x_item_tbl(x_item_tbl.COUNT).item_id := -1;
          x_item_tbl(x_item_tbl.COUNT).organization_code :=
            p_organization_tbl(l_Idx).code;
         END IF;

          EXIT WHEN l_item1_crsr%NOTFOUND;
          x_item_tbl(x_item_tbl.COUNT).organization_code :=
            p_organization_tbl(l_Idx).code;
        END LOOP;


        CLOSE l_item1_crsr;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF l_item1_crsr%ISOPEN THEN
          CLOSE l_item1_crsr;
        END IF;
        RAISE;
    END;

  ELSE

    -- need to join to mtl_item_categories;
    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'build item list with category filter'
      );
    END IF;

    /*fix bug 2210154 yawang no need of master org
    --  get the master org first if needed
    IF p_master_org_id IS NULL THEN
      SELECT master_organization_id
        INTO l_master_organization_id
        FROM mtl_parameters
        WHERE organization_id = p_organization_tbl(1).id;
    ELSE
      l_master_organization_id := p_master_org_id;
    END IF; */

    -- get the default category set for Inventory
    SELECT category_set_id
      INTO l_category_set_id
      FROM mtl_default_category_sets
      WHERE functional_area_id = 1;

    BEGIN
      FOR l_Idx IN p_organization_tbl.FIRST..p_organization_tbl.LAST LOOP
        OPEN l_item2_crsr
        ( p_organization_tbl(l_Idx).id
        , p_item_from
        , p_item_to
        --, l_master_organization_id  yawang fix bug 2210154
        , l_category_set_id
        , p_category_id
        );
        LOOP
          FETCH l_item2_crsr
          INTO
            x_item_tbl(x_item_tbl.COUNT + 1).organization_id
          , x_item_tbl(x_item_tbl.COUNT + 1).item_id;
          EXIT WHEN l_item2_crsr%NOTFOUND;
          x_item_tbl(x_item_tbl.COUNT).organization_code :=
            p_organization_tbl(l_Idx).code;
        END LOOP;
        CLOSE l_item2_crsr;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF l_item2_crsr%ISOPEN THEN
          CLOSE l_item2_crsr;
        END IF;
        RAISE;
    END;

  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

END Build_Item_List;




END INV_MGD_POS_ITEM_MDTR;

/
