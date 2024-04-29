--------------------------------------------------------
--  DDL for Package Body INV_MGD_POSITIONS_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POSITIONS_PROC" AS
-- $Header: INVSPOSB.pls 120.2 2005/09/01 22:36:51 nesoni ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVSPOSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export Processor                      |
--|                                                                       |
--| HISTORY                                                               |
--|     09/11/2000 Paolo Juvara      Created                              |
--|     11/21/2002 Vivian Ma         Performance: modify code to print to |
--|                                  log only if debug profile option is  |
--|                                  enabled                              |
--|     19/AUG/2005 Neelam Soni      Modified for bug  4357322            |
--+=======================================================================+

--===================
-- CONSTANTS
--===================
G_PKG_NAME           CONSTANT VARCHAR2(30):= 'INV_MGD_POSITIONS_PROC';

--===================
-- GLOBAL VARIABLES
--===================
G_DEBUG              VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

--===================
-- TYPES
--===================
TYPE g_context_rec_type IS RECORD
( data_set_name            VARCHAR2(80)
, hierarchy_id             NUMBER
, hierarchy_name           VARCHAR2(30)
, hierarchy_version_id     NUMBER
, parent_organization_id   NUMBER
, parent_organization_code VARCHAR2(3)
);

TYPE g_organization_tbl_type IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- FUNCTION  : Data_Set_Exists         PRIVATE
-- PARAMETERS: p_data_set_name         data set name
-- COMMENT   : TRUE if the data set exists
--========================================================================
FUNCTION Data_Set_Exists(p_data_set_name IN VARCHAR2) RETURN BOOLEAN
IS
  l_count NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Data_Set_Exists'
    );
  END IF;

  SELECT COUNT(*)
    INTO l_count
    FROM mtl_mgd_inventory_positions
    WHERE data_set_name = p_data_set_name;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Data_Set_Exists'
    );
  END IF;

  IF l_count = 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END Data_Set_Exists;


--========================================================================
-- PROCEDURE : Get_Context             PRIVATE
-- PARAMETERS: p_data_set_name         data_set_name
--             p_hierarchy_id          hierarchy id
--             p_parent_org_code       parent organizaton code (hier. level)
--             x_context_rec           context information
-- COMMENT   : retrieves context information
--========================================================================
PROCEDURE Get_Context
( p_data_set_name          IN         VARCHAR2
, p_hierarchy_id           IN         NUMBER
, p_parent_org_code        IN         VARCHAR2
, x_context_rec            OUT NOCOPY g_context_rec_type
)
IS
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Get_Context'
    );
  END IF;

  x_context_rec.data_set_name            := p_data_set_name;
  x_context_rec.hierarchy_id             := p_hierarchy_id;
  x_context_rec.parent_organization_code := p_parent_org_code;

  -- get hierarchy_name
  SELECT
    name
  INTO
    x_context_rec.hierarchy_name
  FROM per_organization_structures
  WHERE organization_structure_id = p_hierarchy_id;

  -- get hierarchy version
  SELECT
    org_structure_version_id
  INTO
    x_context_rec.hierarchy_version_id
  FROM per_org_structure_versions
  WHERE organization_structure_id = p_hierarchy_id
    AND SYSDATE BETWEEN date_from AND NVL(date_to, SYSDATE);

  -- get parent organization code
  SELECT
    organization_id
  INTO
    x_context_rec.parent_organization_id
  FROM mtl_parameters
  WHERE organization_code = p_parent_org_code;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Get_Context'
    );
  END IF;

END Get_Context;


--========================================================================
-- PROCEDURE : Reserve_Data_Set_Name   PRIVATE
-- PARAMETERS: p_data_set_name         data_set_name
--             x_return_status         return status
-- COMMENT   : this procedures checks that the data set name is unique and
--             reserves it to prevent parallel requests from interfering
--             with each other; it returs FND_API.G_RET_STS_SUCCESS if the
--             reservation is successful; FND_API.G_RET_STS_ERROR otherwise;
--             the reservation is achieved by:
--                 - locking the table
--                 - checking for the existance of rows with the same data set
--                   name
--                 - if a row exists, FND_API.G_RET_STS_ERROR is returned
--                 - otherwise, a dummy row is created and committed (which
--                   releases the lock
--            the dummy row created by the reservation needs to be removed
--            at the end of the process by calling Release_Data_Set_Name.
--========================================================================
PROCEDURE Reserve_Data_Set_Name
( p_data_set_name          IN         VARCHAR2
, x_return_status          OUT NOCOPY /* file.sql.39 change */        VARCHAR2
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Reserve_Data_Set_Name'
    );
  END IF;

  LOCK TABLE mtl_mgd_inventory_positions IN SHARE ROW EXCLUSIVE MODE;

  IF Data_Set_Exists(p_data_set_name) THEN

    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSE

    MTL_MGD_INV_POSITIONS_PKG.Insert_Row
    ( p_data_set_name             => p_data_set_name
    , p_bucket_name               => 'LOCK'
    , p_organization_code         => 'LCK'
    , p_inventory_item_code       => 'LOCK'
    , p_hierarchy_id              => -1
    , p_hierarchy_name            => -1
    , p_parent_organization_code  => 'LCK'
    , p_parent_organization_id    => -1
    , p_bucket_size_code          => 'LOCK'
    , p_bucket_start_date         => SYSDATE
    , p_bucket_end_date           => SYSDATE
    , p_inventory_item_id         => -1
    , p_organization_id           => -1
    , p_hierarchy_delta_qty       => 0
    , p_hierarchy_end_on_hand_qty => 0
    , p_org_received_qty          => 0
    , p_org_issued_qty            => 0
    , p_org_delta_qty             => 0
    , p_org_end_on_hand_qty       => 0
    );
    COMMIT;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Reserve_Data_Set_Name'
    );
  END IF;

END Reserve_Data_Set_Name;



--========================================================================
-- PROCEDURE : Release_Data_Set_Name   PRIVATE
-- PARAMETERS: p_data_set_name         data_set_name
-- COMMENT   : releases the reservation made by the Reserve_Data_Set_Name
--             procedure
--========================================================================
PROCEDURE Release_Data_Set_Name
( p_data_set_name          IN         VARCHAR2
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Release_Data_Set_Name'
    );
  END IF;

  DELETE FROM mtl_mgd_inventory_positions
    WHERE data_set_name     = p_data_set_name
      AND organization_id   = -1
      AND bucket_name       = 'LOCK'
      AND inventory_item_id = -1;
  COMMIT;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Release_Data_Set_Name'
    );
  END IF;

END Release_Data_Set_Name;

--========================================================================
-- FUNCTION  : Get_Master_Org          PRIVATE
-- PARAMETERS: p_hierarchy_level       hierarchy level
-- COMMENT   : Retrieve the master organization
--========================================================================
FUNCTION Get_Master_Org(p_hierarchy_level IN NUMBER) RETURN NUMBER
IS
  l_master_org_id  NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Get_Master_Org'
    );
  END IF;

  SELECT master_organization_id
    INTO l_master_org_id
    FROM mtl_parameters
    WHERE organization_id = p_hierarchy_level;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Get_Master_Org'
    );
  END IF;

  RETURN l_master_org_id;

END Get_Master_Org;


--========================================================================
-- PROCEDURE : Get_Child_Organizations PRIVATE
-- PARAMETERS: p_context_rec           context
--             p_organization_id       organization
--             x_child_org_tbl         list of organizations under
--                                     p_organization_id
-- COMMENT   : retrieves the list of organizations in under p_organization_id
--             in the hierarchy
--========================================================================
PROCEDURE Get_Child_Organizations
( p_context_rec         IN         g_context_rec_type
, p_organization_id     IN         NUMBER
, x_child_organizations OUT NOCOPY g_organization_tbl_type
)
IS
  CURSOR l_org_children_crsr
  ( p_hierarchy_version_id  NUMBER
  , p_organization_id       NUMBER
  )
  IS
  SELECT organization_id_child
    FROM per_org_structure_elements
    WHERE org_structure_version_id   = p_hierarchy_version_id
      AND organization_id_parent     = p_organization_id;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Get_Child_Organizations'
    );
  END IF;

  OPEN l_org_children_crsr
  ( p_hierarchy_version_id => p_context_rec.hierarchy_version_id
  , p_organization_id      => p_organization_id
  );

  LOOP
    FETCH  l_org_children_crsr
      INTO x_child_organizations(x_child_organizations.COUNT + 1);
    EXIT WHEN l_org_children_crsr%NOTFOUND;
  END LOOP;

  CLOSE l_org_children_crsr;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Get_Child_Organizations'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
      , p_msg => 'Exception: '||SQLERRM
      );
    END IF;
    IF l_org_children_crsr%ISOPEN THEN
      CLOSE l_org_children_crsr;
    END IF;
    RAISE;
END Get_Child_Organizations;

--========================================================================
-- FUNCTION  : All_Completed           PRIVATE
-- PARAMETERS: p_organization_tbl      list of organization
--             p_child_organizations   list of organizations to check
-- COMMENT   : TRUE if all the organizations in p_child_organizations are
--             marked as completed in p_organization_tbl; FALSE otherwise
--========================================================================
FUNCTION All_Completed
( p_organization_tbl     IN  INV_MGD_POS_UTIL.organization_tbl_type
, p_child_organizations  IN  g_organization_tbl_type
) RETURN BOOLEAN
IS
  l_completed BOOLEAN;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'All_Completed'
    );
  END IF;

  l_completed := TRUE;

  FOR l_Idx1 IN 1..p_child_organizations.COUNT LOOP

    FOR l_Idx2 IN 1..p_organization_tbl.COUNT LOOP
      IF p_organization_tbl(l_Idx2).id = p_child_organizations(l_Idx1) THEN
        l_completed := p_organization_tbl(l_Idx2).complete_flag;
        EXIT;
      END IF;
    END LOOP;

    EXIT WHEN NOT l_completed;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'All_Completed'
    );
  END IF;

  RETURN l_completed;

END All_Completed;

--========================================================================
-- PROCEDURE : Calc_Item_Begin_Qty     PRIVATE
-- PARAMETERS: p_organization_id       organization
--             p_item_id               item
--             p_date                  date
--             x_quantity              quantity on hand
-- COMMENT   : calculates beginning quantity on hand for an item in one
--             organization as specified by the given date
--========================================================================
PROCEDURE Calc_Item_Begin_Qty
( p_organization_id   IN            NUMBER
, p_item_id           IN            NUMBER
, p_date              IN            DATE
, x_quantity          OUT NOCOPY /* file.sql.39 change */           NUMBER
)
IS
  l_base_period_id       NUMBER;
  l_base_period_end_date DATE;
  l_base_qty             NUMBER;
  l_begin_qty            NUMBER;
  l_current_qty          NUMBER;
  l_rollback_qty         NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Calc_Item_Begin_Qty'
    );
  END IF;

  -- get offset quantity
/*2872802*/

  SELECT NVL(SUM(primary_transaction_quantity),0)
  INTO
     l_current_qty
  FROM mtl_onhand_quantities_detail
  WHERE organization_id   = p_organization_id
    AND inventory_item_id = p_item_id;

  -- yawang fix bug 2195443, filter OUT NOCOPY /* file.sql.39 change */ transaction action id 24 and 30
  -- this 24 and 30 info is from Material Transaction form
  SELECT
    NVL(SUM(primary_quantity), 0)
  INTO
    l_rollback_qty
  FROM mtl_material_transactions
  WHERE organization_id    = p_organization_id
    AND inventory_item_id  = p_item_id
    AND transaction_date   >= p_date
    AND transaction_action_id NOT IN (24,30,50,51,52); /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

  l_begin_qty := l_current_qty - l_rollback_qty;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'l_begin_qty:'||TO_CHAR(l_begin_qty)
    );
  END IF;

  x_quantity := l_begin_qty;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Calc_Item_Begin_Qty'
    );
  END IF;
END Calc_Item_Begin_Qty;


--========================================================================
-- PROCEDURE : Process_Bucket          PRIVATE
-- PARAMETERS: p_context_rec           context information
--             p_item_rec              item
--             p_bucket_rec            bucket
--             p_begin_qty             begin quantity
--             x_end_qty               end quantity
-- COMMENT   : processes a bucket for an item by populating an entry in
--             MTL_MGD_INVENTORY_POSITIONS with data for the current
--             organization; passes the end quantity OUT NOCOPY /* file.sql.39 change */ as begin quantity
--             for the next bucket
--========================================================================
PROCEDURE Process_Bucket
( p_context_rec   IN  g_context_rec_type
, p_item_rec      IN  INV_MGD_POS_UTIL.item_rec_type
, p_bucket_rec    IN  INV_MGD_POS_UTIL.bucket_rec_type
, p_begin_qty     IN  NUMBER
, x_end_qty       OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
  l_org_received_qty  NUMBER;
  l_org_issued_qty    NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Process_Bucket'
    );
  END IF;


  -- yawang fix bug 2195443, filter OUT NOCOPY /* file.sql.39 change */ transaction action id 24 and 30
  -- this 24 and 30 info is from Material Transaction form
  -- get received quantity
  SELECT
    NVL(SUM(primary_quantity), 0)
  INTO
    l_org_received_qty
  FROM mtl_material_transactions
  WHERE organization_id       = p_item_rec.organization_id
    AND inventory_item_id     = p_item_rec.item_id
    AND transaction_date     >= p_bucket_rec.start_date
    AND transaction_date      < p_bucket_rec.end_date
    AND transaction_quantity  > 0
    AND transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

  -- get issued quantity
  SELECT
    NVL(SUM(-primary_quantity), 0)
  INTO
    l_org_issued_qty
  FROM mtl_material_transactions
  WHERE organization_id       = p_item_rec.organization_id
    AND inventory_item_id     = p_item_rec.item_id
    AND transaction_date     >= p_bucket_rec.start_date
    AND transaction_date      < p_bucket_rec.end_date
    AND transaction_quantity  < 0
    AND transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

  MTL_MGD_INV_POSITIONS_PKG.Insert_Row
  ( p_data_set_name             => p_context_rec.data_set_name
  , p_bucket_name               => p_bucket_rec.name
  , p_organization_code         => p_item_rec.organization_code
  , p_inventory_item_code       => p_item_rec.item_code
  , p_hierarchy_id              => p_context_rec.hierarchy_id
  , p_hierarchy_name            => p_context_rec.hierarchy_name
  , p_parent_organization_code  => p_context_rec.parent_organization_code
  , p_parent_organization_id    => p_context_rec.parent_organization_id
  , p_bucket_size_code          => p_bucket_rec.bucket_size
  , p_bucket_start_date         => p_bucket_rec.start_date
  , p_bucket_end_date           => p_bucket_rec.end_date
  , p_inventory_item_id         => p_item_rec.item_id
  , p_organization_id           => p_item_rec.organization_id
  , p_hierarchy_delta_qty       => 0
  , p_hierarchy_end_on_hand_qty => 0
  , p_org_received_qty          => l_org_received_qty
  , p_org_issued_qty            => l_org_issued_qty
  , p_org_delta_qty             => l_org_received_qty - l_org_issued_qty
  , p_org_end_on_hand_qty       => NVL(p_begin_qty,0) +
                                   l_org_received_qty - l_org_issued_qty
  );

  x_end_qty := NVL(p_begin_qty,0) + l_org_received_qty - l_org_issued_qty;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Process_Bucket'
    );
  END IF;
END Process_Bucket;


--========================================================================
-- PROCEDURE : Calc_Org_Level_Info     PRIVATE
-- PARAMETERS: p_context_rec           context information
--             p_item_rec              item
--             p_bucket_tbl            bucket list
-- COMMENT   : calculates the data for a given item in a given organization
--             across the list of buckets
--========================================================================
PROCEDURE Calc_Org_Level_Info
( p_context_rec       IN  g_context_rec_type
, p_item_rec          IN            INV_MGD_POS_UTIL.item_rec_type
, p_bucket_tbl        IN            INV_MGD_POS_UTIL.bucket_tbl_type
)
IS
  l_begin_qty         NUMBER;

  -- Following variable added. Bug:4357322
  l_end_qty           NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Calc_Org_Level_Info'
    );
  END IF;

  Calc_Item_Begin_Qty
  ( p_organization_id     =>  p_item_rec.organization_id
  , p_item_id             =>  p_item_rec.item_id
  , p_date                =>  p_bucket_tbl(1).start_date
  , x_quantity            =>  l_begin_qty
  );

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'Looping on buckets'
    );
  END IF;
  FOR l_Idx IN 1..p_bucket_tbl.COUNT
  LOOP
    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'Bucket: '||p_bucket_tbl(l_Idx).name
      );
    END IF;

    -- l_end_qty is passed in place of l_begin_qty. Bug:4357322
    Process_bucket
    ( p_context_rec => p_context_rec
    , p_item_rec    => p_item_rec
    , p_bucket_rec  => p_bucket_tbl(l_Idx)
    , p_begin_qty   => l_begin_qty
    , x_end_qty     => l_end_qty
    );
    l_begin_qty := l_end_qty;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Calc_Org_Level_Info'
    );
  END IF;

END Calc_Org_Level_Info;

--========================================================================
-- PROCEDURE : Get_Hierarchy_Level_Data PRIVATE
-- PARAMETERS: p_context_rec            context
--             p_child_organizations    organization
--             p_item_rec               item
--             p_bucket_rec             bucket
--             x_hier_delta_qty         delta qty at hierarchy level
--             x_hier_end_on_hand_qty   end bucket on hand qty at hier. level
-- COMMENT   : retrieves the hierarchy level data for a given organization
--========================================================================
PROCEDURE Get_Hierarchy_Level_Data
( p_context_rec          IN         g_context_rec_type
, p_organization_id      IN         NUMBER
, p_child_organizations  IN         g_organization_tbl_type
, p_item_rec             IN         INV_MGD_POS_UTIL.item_rec_type
, p_bucket_rec           IN         INV_MGD_POS_UTIL.bucket_rec_type
, x_hier_delta_qty       OUT NOCOPY NUMBER
, x_hier_end_on_hand_qty OUT NOCOPY NUMBER
)
IS
  -- Following variables added. Bug:4357322
  l_child_organization g_organization_tbl_type;
  l_sub_child_organization g_organization_tbl_type;
  l_sub_delta_qty    NUMBER;
  l_sub_on_hand_qty  NUMBER;

  l_delta_qty       NUMBER;
  l_on_hand_qty     NUMBER;
  l_old_delta_qty   NUMBER;
  l_old_on_hand_qty NUMBER;
  CURSOR l_org_data_crsr
  ( p_data_set_name     VARCHAR2
  , p_organization_id   NUMBER
  , p_bucket_name       VARCHAR2
  , p_inventory_item_id NUMBER
  )
  IS
  SELECT
    org_delta_qty
  , org_end_on_hand_qty
  FROM mtl_mgd_inventory_positions
  WHERE data_set_name     = p_data_set_name
    AND organization_id   = p_organization_id
    AND bucket_name       = p_bucket_name
    AND inventory_item_id = p_inventory_item_id;
  CURSOR l_hier_data_crsr
  ( p_data_set_name     VARCHAR2
  , p_organization_id   NUMBER
  , p_bucket_name       VARCHAR2
  , p_inventory_item_id NUMBER
  )
  IS
  SELECT
    hierarchy_delta_qty
  , hierarchy_end_on_hand_qty
  FROM mtl_mgd_inventory_positions
  WHERE data_set_name     = p_data_set_name
    AND organization_id   = p_organization_id
    AND bucket_name       = p_bucket_name
    AND inventory_item_id = p_inventory_item_id;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Get_Hierarchy_Level_Data'
    );
  END IF;

  OPEN l_org_data_crsr
  ( p_data_set_name     => p_context_rec.data_set_name
  , p_organization_id   => p_organization_id
  , p_bucket_name       => p_bucket_rec.name
  , p_inventory_item_id => p_item_rec.item_id
  );
  FETCH l_org_data_crsr INTO l_old_delta_qty, l_old_on_hand_qty;
  IF l_org_data_crsr%NOTFOUND THEN
    l_old_delta_qty := 0;
    l_old_on_hand_qty := 0;
  END IF;
  CLOSE l_org_data_crsr;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'hierarchy origin on hand qty :'||l_old_on_hand_qty
    );
  END IF;

  FOR l_Idx IN 1..p_child_organizations.COUNT
  LOOP

    OPEN l_hier_data_crsr
    ( p_data_set_name     => p_context_rec.data_set_name
    , p_organization_id   => p_child_organizations(l_Idx)
    , p_bucket_name       => p_bucket_rec.name
    , p_inventory_item_id => p_item_rec.item_id
    );

    -- Following assignment added for bug:4357322
    l_delta_qty := 0;
    l_on_hand_qty := 0;

    FETCH l_hier_data_crsr INTO l_delta_qty, l_on_hand_qty;
    IF l_hier_data_crsr%NOTFOUND THEN
      -- Following block modified for bug:4357322
      Get_Child_Organizations(p_context_rec,p_child_organizations(l_Idx), l_child_organization);

      IF (l_child_organization IS NOT NULL AND l_child_organization.COUNT > 0)THEN
        IF G_DEBUG = 'Y' THEN
         INV_MGD_POS_UTIL.Log
          ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
          , p_msg => 'child org Id : '||p_child_organizations(l_Idx)
          );
         INV_MGD_POS_UTIL.Log
          ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
          , p_msg => 'Number of children : '||l_child_organization.COUNT
          );
        END IF ;
        FOR l_index IN 1..l_child_organization.COUNT
        LOOP
         IF G_DEBUG = 'Y' THEN
            INV_MGD_POS_UTIL.Log
	    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
	    , p_msg => 'Sub child organization Id :'||l_child_organization(l_index)
            );
         END IF;
         Get_Child_Organizations(p_context_rec,l_child_organization(l_index), l_sub_child_organization);
         Get_Hierarchy_Level_Data(p_context_rec,l_child_organization(l_index), l_sub_child_organization
         ,p_item_rec, p_bucket_rec, l_sub_delta_qty,l_sub_on_hand_qty);

         l_delta_qty := l_delta_qty + l_sub_delta_qty;
         l_on_hand_qty := l_on_hand_qty + l_sub_on_hand_qty;
         IF G_DEBUG = 'Y' THEN
            INV_MGD_POS_UTIL.Log
	    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
	    , p_msg => 'Delta Qty:'||l_delta_qty
            );
            INV_MGD_POS_UTIL.Log
	    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
	    , p_msg => 'Onhand Qty :'||l_on_hand_qty
            );
            INV_MGD_POS_UTIL.Log
	    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
	    , p_msg => 'Sub Delta Qty :'||l_sub_delta_qty
            );
            INV_MGD_POS_UTIL.Log
	    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
	    , p_msg => 'Sub Onhand Qty :'||l_sub_on_hand_qty
            );
          END IF;
        END LOOP;
      END IF;
    -- End of bug 4357322 fix
    END IF;
    CLOSE l_hier_data_crsr;

    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'child org on hand qty :'||l_on_hand_qty
      );
    END IF;

    l_old_delta_qty   := l_old_delta_qty + l_delta_qty;
    l_old_on_hand_qty := l_old_on_hand_qty + l_on_hand_qty;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'hierarchy on hand qty :'||l_old_on_hand_qty
    );
  END IF;

  x_hier_delta_qty       := l_old_delta_qty;
  x_hier_end_on_hand_qty := l_old_on_hand_qty;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Get_Hierarchy_Level_Data'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
      , p_msg => 'Exception: '||SQLERRM
      );
    END IF;
    IF l_org_data_crsr%ISOPEN THEN
      CLOSE l_org_data_crsr;
    END IF;
    IF l_hier_data_crsr%ISOPEN THEN
      CLOSE l_hier_data_crsr;
    END IF;
    RAISE;
END Get_Hierarchy_Level_Data;

--========================================================================
-- PROCEDURE : Calc_Hier_Level_Info    PRIVATE
-- PARAMETERS: p_context_rec           context
--             p_organization_tbl      organization list
--             p_orgnaization_idx      index of the give organization in
--                                     p_organization_tbl
--             p_item_tbl              item list
--             p_bucket_tbl            bucket list
-- COMMENT   : calculates the hierarchy level data for a given organization
--========================================================================
PROCEDURE Calc_Hier_Level_Info
( p_context_rec       IN            g_context_rec_type
, p_organization_tbl  IN            INV_MGD_POS_UTIL.organization_tbl_type
, p_organization_idx  IN            NUMBER
, p_item_tbl          IN            INV_MGD_POS_UTIL.item_tbl_type
, p_bucket_tbl        IN            INV_MGD_POS_UTIL.bucket_tbl_type
, x_completed_flag    OUT NOCOPY /* file.sql.39 change */           BOOLEAN
)
IS
  l_child_org_tbl     g_organization_tbl_type;
  l_delta_qty         NUMBER;
  l_end_on_hand_qty   NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Calc_Hier_Level_Info'
    );
  END IF;

  Get_Child_Organizations
  ( p_context_rec         => p_context_rec
  , p_organization_id     => p_organization_tbl(p_organization_idx).id
  , x_child_organizations => l_child_org_tbl
  );

  IF All_Completed
     ( p_organization_tbl    => p_organization_tbl
     , p_child_organizations => l_child_org_tbl
     )
  THEN

    FOR l_itm_Idx IN 1..p_item_tbl.COUNT
    LOOP

      IF G_DEBUG = 'Y' THEN
        INV_MGD_POS_UTIL.Log
        ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
        , p_msg => 'itm_idx: '||l_itm_idx
        );
      END IF;

      IF p_item_tbl(l_itm_idx).organization_id =
         p_organization_tbl(p_organization_idx).id
      THEN

        IF G_DEBUG = 'Y' THEN
          INV_MGD_POS_UTIL.Log
          ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
          , p_msg => 'item: '||p_item_tbl(l_itm_idx).item_id
          );
        END IF;

        --IF Clause added for bug 4357322
        IF (p_item_tbl(l_itm_idx).item_id > 0) THEN
         FOR l_Bkt_Idx IN 1..p_bucket_tbl.COUNT
         LOOP

          IF G_DEBUG = 'Y' THEN
            INV_MGD_POS_UTIL.Log
            ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
            , p_msg => 'bucket: '||p_bucket_tbl(l_bkt_idx).name
            );
          END IF;

          Get_Hierarchy_Level_Data
          ( p_context_rec          => p_context_rec
          , p_organization_id      => p_organization_tbl(p_organization_idx).id
          , p_child_organizations  => l_child_org_tbl
          , p_item_rec             => p_item_tbl(l_itm_idx)
          , p_bucket_rec           => p_bucket_tbl(l_bkt_idx)
          , x_hier_delta_qty       => l_delta_qty
          , x_hier_end_on_hand_qty => l_end_on_hand_qty
          );

          IF G_DEBUG = 'Y' THEN
            INV_MGD_POS_UTIL.Log
            ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
            , p_msg => 'delta qty: '||l_delta_qty
            );
            INV_MGD_POS_UTIL.Log
            ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
            , p_msg => 'end on hand qty: '||l_end_on_hand_qty
            );
          END IF;

          MTL_MGD_INV_POSITIONS_PKG.Update_Hierarchy_Data
          ( p_data_set_name             => p_context_rec.data_set_name
          , p_bucket_name               => p_bucket_tbl(l_bkt_idx).name
          , p_organization_id           => p_item_tbl(l_itm_idx).organization_id
          , p_inventory_item_id         => p_item_tbl(l_itm_idx).item_id
          , p_hierarchy_delta_qty       => l_delta_qty
          , p_hierarchy_end_on_hand_qty => l_end_on_hand_qty
          );

         END LOOP; -- p_bucket_tbl
        END IF;
      END IF;

    END LOOP; -- p_item_tbl

    x_completed_flag := TRUE;

  ELSE

    x_completed_flag := FALSE;

  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Calc_Hier_Level_Info'
    );
  END IF;

END Calc_Hier_Level_Info;

--========================================================================
-- PROCEDURE : Fetch_Data              PRIVATE
-- PARAMETERS: p_context_rec           context information
--             p_organization_tbl      list of organizations
--             p_item_tbl              list of items
--             p_bucket_tbl            list of buckets
-- COMMENT   : Retrieve the data from the transaction tables and build the
--             data set in the temporary table
--========================================================================
PROCEDURE Fetch_Data
( p_context_rec       IN            g_context_rec_type
, x_organization_tbl  IN OUT NOCOPY INV_MGD_POS_UTIL.organization_tbl_type
, p_item_tbl          IN            INV_MGD_POS_UTIL.item_tbl_type
, p_bucket_tbl        IN            INV_MGD_POS_UTIL.bucket_tbl_type
)
IS
  l_all_org_completed BOOLEAN;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||'Fetch_Data'
    );

    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'Looping on items'
    );
  END IF;

  FOR l_Idx IN 1..p_item_tbl.COUNT
  LOOP

    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'item '||p_item_tbl(l_Idx).item_id ||
                ' org  '||p_item_tbl(l_Idx).organization_id
      );
    END IF;

    Calc_Org_Level_Info
    ( p_context_rec   => p_context_rec
    , p_item_rec      => p_item_tbl(l_Idx)
    , p_bucket_tbl    => p_bucket_tbl
    );

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'Looping while orgs are not completed'
    );
  END IF;
  LOOP

    l_all_org_completed := TRUE;

    IF G_DEBUG = 'Y' THEN
      INV_MGD_POS_UTIL.Log
      ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
      , p_msg => 'Looping on organizations'
      );
    END IF;
    FOR l_Idx IN 1..x_organization_tbl.COUNT
    LOOP
      IF G_DEBUG = 'Y' THEN
        INV_MGD_POS_UTIL.Log
        ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
        , p_msg => 'org: '||x_organization_tbl(l_Idx).id
        );
      END IF;
      IF NOT x_organization_tbl(l_Idx).complete_flag THEN

        l_all_org_completed := FALSE;

        Calc_Hier_Level_Info
        ( p_context_rec      => p_context_rec
        , p_organization_tbl => x_organization_tbl
        , p_organization_idx => l_Idx
        , p_item_tbl         => p_item_tbl
        , p_bucket_tbl       => p_bucket_tbl
        , x_completed_flag   => x_organization_tbl(l_Idx).complete_flag
        );

      END IF;

    END LOOP;

    EXIT WHEN l_all_org_completed;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||'Fetch_Data'
    );
  END IF;

END Fetch_Data;


--========================================================================
-- PROCEDURE : Build                   PUBLIC
-- PARAMETERS: p_init_msg_list         standard API parameter
--             x_return_status         standard API parameter
--             x_msg_count             standard API parameter
--             x_msg_data              standard API parameter
--             p_data_set_name         data set name
--             p_hierarchy_id          organization hierarchy
--             p_hierarchy_level       hierarchy level
--             p_item_from             item range from
--             p_item_to               item range to
--             p_category_id           item category
--             p_date_from             date range from (in canonical frmt)
--             p_date_to               date range to (in canonical frmt)
--             p_bucket_size           bucket size
-- COMMENT   : Inventory Position Build processor
-- PRE-COND  : all organization in hierarchy share same item master
--========================================================================
PROCEDURE Build
( p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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

l_api_name                 CONSTANT VARCHAR2(30):= 'Build';
l_return_status            VARCHAR2(1);
l_master_org_id            NUMBER;
l_context_rec              g_context_rec_type;
l_organization_tbl         INV_MGD_POS_UTIL.organization_tbl_type;
l_item_tbl                 INV_MGD_POS_UTIL.item_tbl_type;
l_bucket_tbl               INV_MGD_POS_UTIL.bucket_tbl_type;
l_dupl_data_set_name       EXCEPTION;
l_empty_data_set           EXCEPTION;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- reserve data set name
  Reserve_Data_Set_Name
  ( p_data_set_name => p_data_set_name
  , x_return_status => l_return_status
  );
  IF NOT l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    RAISE l_dupl_data_set_name;
  END IF;

  -- Get context
  Get_Context
  ( p_data_set_name      => p_data_set_name
  , p_hierarchy_id       => p_hierarchy_id
  , p_parent_org_code    => p_hierarchy_level
  , x_context_rec        => l_context_rec
  );

  -- retrieve master organization ID
  l_master_org_id := Get_Master_Org
                     ( p_hierarchy_level=>l_context_rec.parent_organization_id
                     );

  -- build list of organizations
  INV_MGD_POS_ORGANIZATION_MDTR.Build_Organization_List
  ( p_hierarchy_id       => l_context_rec.hierarchy_id
  , p_hierarchy_level_id => l_context_rec.parent_organization_id
  , x_organization_tbl   => l_organization_tbl
  );

  -- build list of items
  INV_MGD_POS_ITEM_MDTR.Build_Item_List
  ( p_organization_tbl   => l_organization_tbl
  , p_master_org_id      => l_master_org_id
  , p_item_from          => p_item_from
  , p_item_to            => p_item_to
  , p_category_id        => p_category_id
  , x_item_tbl           => l_item_tbl
  );

  -- build list of buckets
  INV_MGD_POS_BUCKET_MDTR.Build_Bucket_List
  ( p_organization_id    => l_master_org_id
  , p_date_from          => FND_DATE.canonical_to_date(p_date_from)
  , p_date_to            => FND_DATE.canonical_to_date(p_date_to)
  , p_bucket_size        => p_bucket_size
  , x_bucket_tbl         => l_bucket_tbl
  );

  -- fetch data into temporary table
  Fetch_Data
  ( p_context_rec       => l_context_rec
  , x_organization_tbl  => l_organization_tbl
  , p_item_tbl          => l_item_tbl
  , p_bucket_tbl        => l_bucket_tbl
  );

  -- releases the reservation on the data set name
  Release_Data_Set_Name(p_data_set_name => p_data_set_name);

  -- Verify that data set created data
  IF NOT Data_Set_Exists(p_data_set_name => p_data_set_name) THEN
    RAISE l_empty_data_set;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Get message count and data
  FND_MSG_PUB.Count_And_Get
  ( p_encoded => FND_API.G_FALSE
  , p_count   => x_msg_count
  , p_data    => x_msg_data
  );

  -- calculate hierarchy level information
  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

EXCEPTION

  WHEN l_empty_data_set THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- generate proper error message
    FND_MESSAGE.set_name
    ( application => 'INV'
    , name        => 'INV_MGD_IPBD_EMPTY_DATASET'
    );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN l_dupl_data_set_name THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- generate proper error message
    FND_MESSAGE.set_name
    ( application => 'INV'
    , name        => 'INV_MGD_IPBD_DUPL_DATASET'
    );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Build_Organization_List'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

END Build;


--========================================================================
-- PROCEDURE : Purge                   PUBLIC
-- PARAMETERS: p_init_msg_list         standard API parameter
--             x_return_status         standard API parameter
--             x_msg_count             standard API parameter
--             x_msg_data              standard API parameter
--             p_purge_all             Y to purge all, N otherwise
--             p_created_by            purge data set for specific user ID
--             p_creation_date         purge data set created before date
--             p_data_set_name         purge specific data set name
-- COMMENT   : Inventory Position Purge concurrent program; p_purge_all takes
--             priority over other parameters
--========================================================================
PROCEDURE Purge
( p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_purge_all          IN  VARCHAR2
, p_data_set_name      IN  VARCHAR2
, p_created_by         IN  VARCHAR2
, p_creation_date      IN  VARCHAR2
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Purge';

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

  IF p_purge_all = 'Y' THEN

    MTL_MGD_INV_POSITIONS_PKG.Delete_All;

  ELSE

    MTL_MGD_INV_POSITIONS_PKG.Delete
    ( p_data_set_name  => p_data_set_name
    , p_created_by     => p_created_by
    , p_creation_date  => FND_DATE.canonical_to_date(p_creation_date)
    );

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Get message count and data
  FND_MSG_PUB.Count_And_Get
  ( p_encoded => FND_API.G_FALSE
  , p_count   => x_msg_count
  , p_data    => x_msg_data
  );

  IF G_DEBUG = 'Y' THEN
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
    , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
    );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , l_api_name
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE
    , p_count   => x_msg_count
    , p_data    => x_msg_data
    );

END Purge;



END INV_MGD_POSITIONS_PROC;

/
