--------------------------------------------------------
--  DDL for Package Body INV_ITEM_ORG_ASSIGN_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_ORG_ASSIGN_CP" AS
/* $Header: INVCOSGB.pls 120.2.12010000.3 2010/07/29 14:24:01 ccsingh ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCOSGB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_ITEM_ORG_ASSIGN_CP                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     09/01/00 vjavli  Created                                          |
--|     09/12/00 vjavli  Updated  modified to category_id                 |
--|     10/16/00 vjavli  updated  swapped the loop for item and           |
--|                      organization list. item range cursor             |
--|                      modified to select only for master org id        |
--|     12/11/00 vjavli  Signature updated to p_org_hier_level_id         |
--|     06/02/01 pjuvara Restructured to use Item Open Interface          |
--|     11/20/01 vjavli  new api's implemented to improve the             |
--|                      performance                                      |
--|     01/23/02 vjavli  log exception for org property validation        |
--|     10/15/02 vjavli  Bug#2591335 fix: Build_Item_Cursor modified      |
--|     11/21/02 vma     Improve performance: print debug messages        |
--|                      to log only if profile option is enabled         |
--|     30-Apr-2003  rajkrish sqlBind Issue                               |
--|     31-Aug-2003  vjavli Performance enhancement for Retail Customer   |
--|                         re-design to bypass validation phase of Item  |
--|                         Import API                                    |
--|                         Bug#3095409 fix                               |
--|     17-Sep-2003  vjavli Performance enhancement completed             |
--|                         Found that the program is 5 times faster than |
--|                         before                                        |
--|     03-Feb-2004  nkilleda Bug 3306087 fix The Item_Org_Assignment     |
--|                         procedure has been modified as follows        |
--|                         > Accept a new parameter p_source_org_id of   |
--|                           type number.                                |
--|                         > A new validation for the source organization|
--|                           to have same master as that of the hierarchy|
--|                           origin has been added.                      |
--|                         > If the source organization is not null, then|
--|                           the list of items is generated from source  |
--|                           org. based on the range / category specified|
--|                           Otherwise, the item list is got from the    |
--|                           item master org. of the hierarchy origin    |
--|                         > x_errbuff and x_retcode should be in order  |
--|                           according to AOL standards inorder to       |
--|                           display warning and error messages.         |
--|                           Otherwise, conc. manager will consider as   |
--|                           completed normal eventhough exception raised|
--|                         > Build_Item_Cursor: x_xcenario NOCOPY added  |
--|                           for previous version;                       |
--|                           wait_for_worker: OUT NOCOPY added           |
--|     06/22/2004 nesoni      Bug 2642331. Interface of procedure        |
--|                            Item_Org_Assignment is modified to accept  |
--|                            parameter p_category_set_name as NUMERIC.  |
--|                            Earlier it was VARCHAR2. Parameter text    |
--|                            is replaced from p_category_set_name to    |
--|                            p_category_set_id.                         |
--|     01/17/2004 vjavli    Bug#4121148 fix: INVPULI4.assign_status_     |
--|                          attributes added as recommended by BOM team  |
--|                          since the signature has been modified by BOM |
--|     01/27/2006 vmutyala  Bug#4997972 revision label not getting copied|
--+======================================================================*/

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_ITEM_ORG_ASSIGN_CP';
G_SLEEP_TIME           NUMBER       := 15;

g_submit_failure_exc   EXCEPTION;

TYPE g_request_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
TYPE g_item_cur_type IS REF CURSOR;

g_unit_test_mode       BOOLEAN     := FALSE;
G_DEBUG                VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');


--===================
-- PRIVATE PROCEDURES AND FUNCTIONS
--===================

-- ==========================================================================
-- PROCEDURE : validate_gl_account    PRIVATE
-- PARAMETERS: p_org_tbl   IN INV_OrgHierarchy_PVT.OrgID_tbl_type
--             Organization List of the Hierarchy and Origin
--
--             x_valid_org_tbl OUT INV_OrgHierarchy_PVT.OrgID_tbl_type
--             Shortened Organization List containing only valid organizations
--
-- COMMENT   : Validate GL account info against GL_CODE_COMBINATIONS for each
--             organization in the Organization List
--             Update global pl/sql table G_ORG_GL_REV_TBL set the valid_flag
--             to 'Y' for the successful validation
--             Otherwise, set to 'N' for NOT a valid code combination
--             Short list the organization list only for valid organizations
-- =====================================================================
PROCEDURE validate_gl_account
(p_org_tbl       IN         INV_OrgHierarchy_PVT.OrgID_tbl_type
,x_valid_org_tbl OUT NOCOPY INV_OrgHierarchy_PVT.OrgID_tbl_type
)
IS

-- Get Chart of Accounts Id for the organization
CURSOR chart_of_accounts_cur(c_organization_id  NUMBER)
IS
SELECT
  chart_of_accounts_id
FROM
  gl_sets_of_books
, hr_organization_information
WHERE set_of_books_id                = org_information1
  AND upper(org_information_context) = upper('Accounting Information')
  AND organization_id                = c_organization_id;

-- check GL code combination id exists
CURSOR ccid_exists_cur(c_chart_of_accounts_id  NUMBER
                      ,c_code_combination_id   NUMBER)
IS
SELECT
  code_combination_id
FROM
  gl_code_combinations
WHERE chart_of_accounts_id = c_chart_of_accounts_id
  AND code_combination_id  = c_code_combination_id
  AND nvl(start_date_active,SYSDATE) <= SYSDATE
  AND nvl(end_date_active,SYSDATE)   >= SYSDATE;

l_organization_id       NUMBER;
l_cost_of_sales_account NUMBER;
l_encumbrance_account   NUMBER;
l_sales_account         NUMBER;
l_expense_account       NUMBER;
l_chart_of_accounts_id  NUMBER;
l_code_combination_id   NUMBER;
l_valid_flag            VARCHAR2(1);
l_organization_id_idx   BINARY_INTEGER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> validate_gl_account'
    );
  END IF;

  -- initialize short list table
  x_valid_org_tbl.DELETE;

  FOR l_org_id_idx IN 1 .. p_org_tbl.COUNT LOOP

    l_organization_id     := p_org_tbl(l_org_id_idx);
    l_organization_id_idx := l_organization_id;

    -- Initialize valid flag
    l_valid_flag := 'N';

    -- get chart of accounts id
    OPEN chart_of_accounts_cur(l_organization_id);
    FETCH chart_of_accounts_cur
     INTO l_chart_of_accounts_id;
    CLOSE chart_of_accounts_cur;

    -- ============================================
    -- validate cost of sales account
    -- ============================================
    l_cost_of_sales_account :=
    G_ORG_GL_REV_TBL(l_organization_id_idx).cost_of_sales_account;
      -- check for NULL value
      -- do not check for NULL values
      IF l_cost_of_sales_account IS NOT NULL THEN
      OPEN ccid_exists_cur(l_chart_of_accounts_id
                          ,l_cost_of_sales_account
                          );
      FETCH ccid_exists_cur
       INTO l_code_combination_id;

      IF ccid_exists_cur%FOUND THEN
        l_valid_flag := 'Y';
      ELSE
        l_valid_flag := 'N';
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
            ,'Cost of Sales Account NOT valid for organization Id:' || l_organization_id
            );
          END IF;
      END IF;
      CLOSE ccid_exists_cur;
      END IF; -- null value check

    -- ========================================
    -- validate encumbrance account
    -- ========================================
    IF l_valid_flag = 'Y' THEN

    l_encumbrance_account   :=
    G_ORG_GL_REV_TBL(l_organization_id_idx).encumbrance_account;
      -- Do not check for null value
      IF l_encumbrance_account IS NOT NULL THEN
      OPEN ccid_exists_cur(l_chart_of_accounts_id
                          ,l_encumbrance_account
                          );
      FETCH ccid_exists_cur
       INTO l_code_combination_id;

      IF ccid_exists_cur%FOUND THEN
        l_valid_flag := 'Y';
      ELSE
        l_valid_flag := 'N';
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
            ,'Encumbrance Account NOT valid for organization Id:' || l_organization_id
            );
          END IF;
      END IF;

      CLOSE ccid_exists_cur;
      END IF; -- null value check

    END IF;

    -- =============================================
    -- validate sales account
    -- =============================================
    IF l_valid_flag = 'Y' THEN

    l_sales_account :=
    G_ORG_GL_REV_TBL(l_organization_id_idx).sales_account;
      -- Do not check for null value
      IF l_sales_account IS NOT NULL THEN
      OPEN ccid_exists_cur(l_chart_of_accounts_id
                          ,l_sales_account
                          );
      FETCH ccid_exists_cur
       INTO l_code_combination_id;

      IF ccid_exists_cur%FOUND THEN
        l_valid_flag := 'Y';
      ELSE
        l_valid_flag := 'N';
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
            ,'Sales Account NOT valid for organization Id:' || l_organization_id
            );
          END IF;
      END IF;
      CLOSE ccid_exists_cur;
      END IF; -- null value check

    END IF;

    -- ==========================================
    -- validate expense account
    -- ==========================================
    IF l_valid_flag = 'Y' THEN
    l_expense_account :=
    G_ORG_GL_REV_TBL(l_organization_id_idx).expense_account;
      -- Do not check for null value
      IF l_expense_account IS NOT NULL THEN
      OPEN ccid_exists_cur(l_chart_of_accounts_id
                          ,l_expense_account
                          );
      FETCH ccid_exists_cur
       INTO l_code_combination_id;

      IF ccid_exists_cur%FOUND THEN
        l_valid_flag := 'Y';
      ELSE
        l_valid_flag := 'N';
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
            ,'Expense Account NOT valid for organization Id:' || l_organization_id
            );
          END IF;
      END IF;
      CLOSE ccid_exists_cur;
      END IF; -- null vaue check

    END IF;

    -- assign valid_flag value
    -- valid flag will be 'Y' if all the gl accounts are valid
    -- if any of the gl account is NOT valid, then the valid_flag
    -- is set to 'N'
    G_ORG_GL_REV_TBL(l_organization_id_idx).valid_flag := l_valid_flag;

  IF G_DEBUG = 'Y' THEN
    IF l_valid_flag = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'GL Account Info Valid for the organization Id:' || l_organization_id
    );
    END IF;
  END IF;

  -- ========================================================
  -- Short List only valid organizations
  -- ========================================================
  IF l_valid_flag = 'Y' THEN
    x_valid_org_tbl(x_valid_org_tbl.COUNT + 1 )
      := p_org_tbl(l_org_id_idx);
  END IF;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< validate_gl_account'
    );
  END IF;

END;


-- ====================================================================
-- PROCEDURE : Retrieve_gl_rev       PRIVATE
-- PARAMETERS: p_org_tbl      IN   INV_OrgHierarchy_PVT.OrgID_tbl_type
-- COMMENT   : Retrieve GL Account Info and starting revision for each
--             organization in the Organization List
--             Store the values in global PL/SQL table G_ORG_GL_REV_TBL
--             Organization Id itself is the index
-- ====================================================================
PROCEDURE Retrieve_gl_rev(p_org_tbl  IN INV_OrgHierarchy_PVT.OrgID_tbl_type)
IS

-- Cursor to retrieve GL Account Info and starting revision
-- of the organization
CURSOR gl_account_revision_cur(c_organization_id  NUMBER)
IS
SELECT
  organization_id
, cost_of_sales_account
, encumbrance_account
, sales_account
, expense_account
, starting_revision
FROM
  mtl_parameters
WHERE organization_id = c_organization_id;

gl_account_rev_row  gl_account_revision_cur%ROWTYPE;

l_organization_id     NUMBER;
l_organization_id_idx BINARY_INTEGER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Retrieve_gl_rev'
    );
  END IF;

  FOR l_org_id_idx IN 1 .. p_org_tbl.COUNT LOOP

    l_organization_id     := p_org_tbl(l_org_id_idx);
    l_organization_id_idx := l_organization_id;

    OPEN gl_account_revision_cur(l_organization_id);
    FETCH gl_account_revision_cur
     INTO gl_account_rev_row;

    CLOSE gl_account_revision_cur;

    G_ORG_GL_REV_TBL(l_organization_id_idx).organization_id :=
      gl_account_rev_row.organization_id;
    G_ORG_GL_REV_TBL(l_organization_id_idx).cost_of_sales_account :=
      gl_account_rev_row.cost_of_sales_account;
    G_ORG_GL_REV_TBL(l_organization_id_idx).encumbrance_account :=
      gl_account_rev_row.encumbrance_account;
    G_ORG_GL_REV_TBL(l_organization_id_idx).sales_account :=
      gl_account_rev_row.sales_account;
    G_ORG_GL_REV_TBL(l_organization_id_idx).expense_account :=
      gl_account_rev_row.expense_account;
    G_ORG_GL_REV_TBL(l_organization_id_idx).starting_revision :=
      gl_account_rev_row.starting_revision;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , 'Org GL Revision table count: ' || G_ORG_GL_REV_TBL.COUNT
    );
  END IF;

END; -- Retrieve_gl_rev


--========================================================================
-- PROCEDURE : Build_Item_Cursor       PRIVATE
-- PARAMETERS: p_cat_structure_id      IN            Category flexfield
--                                                   structure ID
--             x_item_cursor           OUT NOCOPY    item cursor statement
-- COMMENT   : This procedure builds the item cursor statement. This statement
--             needs to be built at run time (dynamic SQL) because of the
--             dynamic nature of the System Item and Category flexfields.
--=========================================================================
/* Following method interface has been modified to incorporate CategorySetId as filter criteria.
 * Added parameter p_category_set_id to method Build_Item_Cursor. Bug: 2642331
 */
PROCEDURE Build_Item_Cursor
( p_category_set_id  IN            NUMBER  --Changed data type from VARCHAR2 to NUMBER. Bug:2642331
, p_cat_structure_id IN            NUMBER
, p_cat_from         IN            VARCHAR2
, p_cat_to           IN            VARCHAR2
, p_item_from        IN            VARCHAR2
, p_item_to          IN            VARCHAR2
, p_master_org_id    IN            NUMBER
, x_item_cursor      IN OUT NOCOPY VARCHAR2
, x_scenario         OUT NOCOPY    VARCHAR2
)
IS
  l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
  l_structure_rec  FND_FLEX_KEY_API.structure_type;
  l_segment_rec    FND_FLEX_KEY_API.segment_type;
  l_segment_tbl    FND_FLEX_KEY_API.segment_list;
  l_segment_number NUMBER;
  l_mstk_segs      VARCHAR2(850);
  l_mcat_segs      VARCHAR2(850);
  l_mcat_f         VARCHAR2(2000);
  l_mcat_w1        VARCHAR2(2000);
  l_mcat_w2        VARCHAR2(2000);
  l_mstk_w         VARCHAR2(2000);

  l_item_scenario  VARCHAR2(2);
  l_cat_scenario  VARCHAR2(2);
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Build_Item_Cursor'
    );
  END IF;

  FND_FLEX_KEY_API.set_session_mode('customer_data');

  -- retrieve system item concatenated flexfield
  l_mstk_segs := '';
  l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MSTK');
  l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, 101);
  FND_FLEX_KEY_API.get_segments
  ( flexfield => l_flexfield_rec
  , structure => l_structure_rec
  , nsegments => l_segment_number
  , segments  => l_segment_tbl
  );
  FOR l_idx IN 1..l_segment_number LOOP
   l_segment_rec := FND_FLEX_KEY_API.find_segment
                   ( l_flexfield_rec
                   , l_structure_rec
                   , l_segment_tbl(l_idx)
                   );
   l_mstk_segs := l_mstk_segs ||'msi.'||l_segment_rec.column_name;
   IF l_idx < l_segment_number THEN
     l_mstk_segs := l_mstk_segs||'||'||''''||l_structure_rec.segment_separator||''''||'||';
   END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'item flexfield segments:'||l_mstk_segs
    );
  END IF;

  -- retrieve item category concatenated flexfield
  l_mcat_segs := '';
  l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MCAT');
  l_structure_rec := FND_FLEX_KEY_API.find_structure
                     ( l_flexfield_rec
                     , p_cat_structure_id
                     );
  FND_FLEX_KEY_API.get_segments
  ( flexfield => l_flexfield_rec
  , structure => l_structure_rec
  , nsegments => l_segment_number
  , segments  => l_segment_tbl
  );
  FOR l_idx IN 1..l_segment_number LOOP
   l_segment_rec := FND_FLEX_KEY_API.find_segment
                   ( l_flexfield_rec
                   , l_structure_rec
                   , l_segment_tbl(l_idx)
                   );
   l_mcat_segs   := l_mcat_segs ||'mc.'||l_segment_rec.column_name;
   IF l_idx < l_segment_number THEN
     l_mcat_segs := l_mcat_segs||'||'||''''||
                    l_structure_rec.segment_separator||''''||'||';
   END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'category flexfield segments:'||l_mcat_segs
    );
  END IF;

  IF p_item_from IS NOT NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||
               ' BETWEEN :b_item_from AND :b_item_to ';

    l_item_scenario := 'i1';

  ELSIF p_item_from IS NOT NULL AND p_item_to IS NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' >= :b_item_from ';

    l_item_scenario := 'i2';

  ELSIF p_item_from IS NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' <= :b_item_to ';

    l_item_scenario := 'i3';

  ELSE
    l_mstk_w := NULL;

    l_item_scenario := 'i4';

  END IF;

  /* Following dynamic From clause and Where clasue have been modified
  to incorporate CategorySetId as filter criteria.
  Bug: 2642331
  l_mcat_f  := ', mtl_item_categories mic, mtl_categories_b mc';
  l_mcat_w1 := ' AND msi.inventory_item_id = mic.inventory_item_id'||
               ' AND msi.organization_id  =  mic.organization_id'  ||
               ' AND mic.category_id = mc.category_id'             ||
               ' AND mc.structure_id = :b_cat_structure_id ';
  */
  l_mcat_f  := ', mtl_item_categories mic, mtl_categories_b mc ';
  l_mcat_w1 := ' AND msi.inventory_item_id = mic.inventory_item_id'||
               ' AND msi.organization_id  =  mic.organization_id'  ||
               ' AND mic.category_id = mc.category_id'             ||
               ' AND mc.structure_id = :b_cat_structure_id '        ||
               ' AND mic.category_set_id = :b_category_set_id ';

  IF p_cat_from IS NOT NULL AND p_cat_to IS NOT NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||
                 ' BETWEEN :b_cat_from AND :b_cat_to ';

    l_cat_scenario := 'c1' ;

  ELSIF p_cat_from IS NOT NULL AND p_cat_to IS NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||' >= :b_cat_from ';

   l_cat_scenario := 'c2' ;

  ELSIF p_cat_from IS NULL AND p_cat_to IS NOT NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||' <= :b_cat_to ';

   l_cat_scenario := 'c3' ;

  ELSE

    l_mcat_f  := NULL;
    l_mcat_w1 := NULL;
    l_mcat_w2 := NULL;

    l_cat_scenario := 'c4' ;
  END IF;

  x_scenario := null;
  x_scenario := l_item_scenario || l_cat_scenario ;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'l_item_scenario => '|| l_item_scenario
    );

    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'l_cat_scenario => '|| l_cat_scenario
    );

    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'before cursor , x_scenario => '|| x_scenario
    );
  END IF;

  x_item_cursor :=  'SELECT  msi.inventory_item_id'                        ||
                     ' FROM  mtl_system_items_b msi'                       ||
                             l_mcat_f                                      ||
                     ' WHERE msi.organization_id = :b_master_org_id  '    ||
                             l_mstk_w                                      ||
                             l_mcat_w1                                     ||
                             l_mcat_w2;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , SUBSTR(x_item_cursor, 1, 250)
    );
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , SUBSTR(x_item_cursor, 251, 500)
    );
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , SUBSTR(x_item_cursor, 501, 750)
    );

    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Build_Item_Cursor'
    );
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
      , FND_FLEX_KEY_API.message
      );
    END IF;
    RAISE;

END Build_Item_Cursor;


--========================================================================
-- FUNCTION  : Get_Master_Org          PRIVATE
-- PARAMETERS: p_org_hier_origin_id     IN Organization Hierarchy
--                                        origin Id
-- RETURNS   : NUMBER
-- COMMENT   : This function returns the ID of the master organization
--             common to all the organizations in the hierarchy.
--=========================================================================
FUNCTION Get_Master_Org
( p_org_hier_origin_id IN NUMBER
)
RETURN NUMBER
IS
  l_master_org_id NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Get_Master_Org'
    );
  END IF;

  SELECT  master_organization_id
    INTO  l_master_org_id
    FROM  mtl_parameters
    WHERE organization_id = p_org_hier_origin_id;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Get_Master_Org'
    );
  END IF;

  RETURN l_master_org_id;

END Get_Master_Org;

--========================================================================
-- FUNCTION  : Get_Set_Process_ID      PRIVATE
-- PARAMETERS: None
-- RETURNS   : NUMBER
-- COMMENT   : This function returns the next set process ID to be used to
--             run the Item Open Interface
--=========================================================================
FUNCTION Get_Set_Process_ID
RETURN NUMBER
IS
  l_set_process_id NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Get_Set_Process_ID'
    );
  END IF;

  SELECT  mtl_system_items_intf_sets_s.NEXTVAL
    INTO  l_set_process_id
    FROM  dual;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Get_Set_Process_ID'
    );
  END IF;

  RETURN l_set_process_id;

END Get_Set_Process_ID;


--========================================================================
-- FUNCTION  : Has_Worker_Completed    PRIVATE
-- PARAMETERS: p_request_id            IN  NUMBER
-- RETURNS   : BOOLEAN
-- COMMENT   : Accepts a request ID. TRUE if the corresponding worker
--             has completed; FALSE otherwise
--=========================================================================
FUNCTION Has_Worker_Completed
( p_request_id  IN NUMBER
)
RETURN BOOLEAN
IS
  l_count   NUMBER;
  l_result  BOOLEAN;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Has_Worker_Completed'
    );
  END IF;

  SELECT  COUNT(*)
    INTO  l_count
    FROM  fnd_concurrent_requests
    WHERE request_id = p_request_id
      AND phase_code = 'C';

  IF l_count = 1 THEN
    l_result := TRUE;
  ELSE
    l_result := FALSE;
  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Has_Worker_Completed'
    );
  END IF;

  RETURN l_result;

END Has_Worker_Completed;


--========================================================================
-- PROCEDURE : Wait_For_Worker         PRIVATE
-- PARAMETERS: p_workers               IN  workers' request ID
--             x_worker_idx            OUT position in p_workers of the
--                                         completed worked
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of one of them; it returns
--             the completed worker through x_worker_idx
--=========================================================================
PROCEDURE Wait_For_Worker
( p_workers          IN  g_request_tbl_type
, x_worker_idx       OUT NOCOPY BINARY_INTEGER
)
IS
  l_done BOOLEAN;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Wait_For_Worker'
    );
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF Has_Worker_Completed(p_workers(l_Idx)) THEN
          l_done := TRUE;
          x_worker_idx := l_Idx;
          EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Wait_For_Worker'
    );
  END IF;

END Wait_For_Worker;


--========================================================================
-- PROCEDURE : Wait_For_All_Workers    PRIVATE
-- PARAMETERS: p_workers               IN workers' request ID
-- COMMENT   : This procedure polls the submitted workers and suspend
--             the program till the completion of all of them.
--=========================================================================
PROCEDURE Wait_For_All_Workers
( p_workers          IN g_request_tbl_type
)
IS
  l_done BOOLEAN;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Wait_For_All_Workers'
    );
  END IF;

  l_done := FALSE;

  WHILE (NOT l_done) LOOP

    l_done := TRUE;

    FOR l_Idx IN 1..p_workers.COUNT LOOP

      IF NOT Has_Worker_Completed(p_workers(l_Idx)) THEN
        l_done := FALSE;
        EXIT;
      END IF;

    END LOOP;

    IF (NOT l_done) THEN
      DBMS_LOCK.sleep(G_SLEEP_TIME);
    END IF;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Wait_For_All_Workers'
    );
  END IF;

END Wait_For_All_Workers;


--========================================================================
-- PROCEDURE : Submit_Item_Import      PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
-- COMMENT   : This procedure submits the Item Import concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--             The list of workers' request ID is updated.
--=========================================================================
PROCEDURE Submit_Item_Import
( p_organization_id  IN            NUMBER
, p_set_process_id   IN            NUMBER
, x_workers          IN OUT NOCOPY g_request_tbl_type
, p_request_count    IN            NUMBER
)
IS
  l_worker_idx     BINARY_INTEGER;
  l_request_id     NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Submit_Item_Import'
    );
  END IF;

  IF NOT g_unit_test_mode THEN

    IF x_workers.COUNT < p_request_count THEN
      -- number of workers submitted so far does not exceed the maximum
      -- number of workers allowed
      l_worker_idx := x_workers.COUNT + 1;
    ELSE
      -- need to wait for a submitted worker to finish
      Wait_For_Worker
      ( p_workers    => x_workers
      , x_worker_idx => l_worker_idx
      );
    END IF;

    IF NOT FND_REQUEST.Set_Options
           ( implicit  => 'WARNING'
           , protected => 'YES'
           )
    THEN
      RAISE g_submit_failure_exc;
    END IF;
    x_workers(l_worker_idx):= FND_REQUEST.Submit_Request
                              ( application => 'INV'
                              , program     => 'INCOIN'
                              , argument1   => p_organization_id
                              , argument2   => 1
                              , argument3   => /*2 Bug 5962957 to ensure that the validation happens settting this to 1*/ 1
                              , argument4   => 1
                              , argument5   => 1
                              , argument6   => p_set_process_id
                              , argument7   => 1
                              );
    IF x_workers(l_worker_idx) = 0 THEN
      RAISE g_submit_failure_exc;
    END IF;

  END IF;

  COMMIT;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Submit_Item_Import'
    );
  END IF;

END Submit_Item_Import;


--========================================================================
-- PROCEDURE : Filter_Org_List         PRIVATE
-- PARAMETERS: p_org_tbl               IN            List of organizations
--             p_inventory_item_id     IN            Item
--             x_filtered_org_tbl      IN OUT NOCOPY Filtered list of orgs
-- COMMENT   : This procedure returns a shortened organization list
--             where the organization to which a given item is already
--             assigned are removed.
--=========================================================================
PROCEDURE Filter_Org_List
( p_org_tbl           IN            INV_ORGHIERARCHY_PVT.OrgID_tbl_type
, p_inventory_item_id IN            NUMBER
, x_filtered_org_tbl  IN OUT NOCOPY INV_ORGHIERARCHY_PVT.OrgID_tbl_type
)
IS
  l_count NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Filter_Org_List'
    );
  END IF;

  x_filtered_org_tbl.DELETE;

  FOR l_Idx IN 1..p_org_tbl.COUNT
  LOOP

      SELECT  COUNT(*)
        INTO  l_count
        FROM  mtl_system_items
        WHERE organization_id = p_org_tbl(l_Idx)
          AND inventory_item_id = p_inventory_item_id;

      IF l_count = 0 THEN
        x_filtered_org_tbl(x_filtered_org_tbl.COUNT+1) := p_org_tbl(l_Idx);
      END IF;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Filter_Org_List'
    );
  END IF;

END Filter_Org_List;

--========================================================================
-- PROCEDURE : Determine_Return_Code   PRIVATE
-- PARAMETERS: x_retcode               OUT NOCOPY    Return code
--             x_errbuff               OUT NOCOPY    Return message
-- COMMENT   : This procedure verifies that all the records have been
--             successfully processed by the Item Open Interface program and
--             returns a warning in case of failure.
--=========================================================================
PROCEDURE Determine_Return_Code
( x_retcode   OUT NOCOPY VARCHAR2
, x_errbuff   OUT NOCOPY VARCHAR2
)
IS
  l_error_count NUMBER;
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Determine_Return_Code'
    );
  END IF;

  -- Check for any left over records
  -- If the item record is successful, that record will be deleted
  -- from the interface tables
  -- Otherwise, that record exists in the interface tables
  SELECT  COUNT(*)
    INTO  l_error_count
    FROM  mtl_system_items_interface
    WHERE request_id = FND_GLOBAL.conc_request_id
    /*AND process_flag = 4; Bug 5962957 Changing this to 1 since the records are passed in as process_flag 1*/
    AND process_flag = 1;

  IF l_error_count > 0 THEN
    x_retcode := RETCODE_WARNING;
    FND_MESSAGE.Set_Name('INV', 'INV_MGD_ITEM_ORG_ASSIGN_WARN');
    FND_MESSAGE.Set_Token('RECORD_NUMBER', l_error_count);
    x_errbuff  := FND_MESSAGE.Get;
  ELSE
    x_retcode := RETCODE_SUCCESS;
    x_errbuff := NULL;
  END IF;
  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Determine_Return_Code'
    );
  END IF;

END Determine_Return_Code;

--===================
-- PUBLIC PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- FUNCTION  : Get_cost_of_sales_account  PUBLIC
-- COMMENT   : This function is to get the Cost of Sales Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_cost_of_sales_account(p_organization_id  IN NUMBER)
RETURN NUMBER
IS

l_organization_id_idx        BINARY_INTEGER;
l_cost_of_sales_account      NUMBER;

cost_of_sales_no_found_exc   EXCEPTION;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF G_ORG_GL_REV_TBL.EXISTS(l_organization_id_idx) THEN
    l_cost_of_sales_account :=
      G_ORG_GL_REV_TBL(l_organization_id_idx).cost_of_sales_account;
    RETURN(l_cost_of_sales_account);
  ELSE
    RAISE cost_of_sales_no_found_exc;
  END IF;

EXCEPTION
  WHEN cost_of_sales_no_found_exc THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,'Cost of Sales Account NOT found for the organization' || p_organization_id);
    END IF;
  RAISE;

END;


--========================================================================
-- FUNCTION  : Get_encumbrance_account  PUBLIC
-- COMMENT   : This function is to get the Encumbrance Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_encumbrance_account(p_organization_id  IN NUMBER)
RETURN NUMBER
IS

l_organization_id_idx        BINARY_INTEGER;
l_encumbrance_account        NUMBER;

encumbrance_account_no_exc   EXCEPTION;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF G_ORG_GL_REV_TBL.EXISTS(l_organization_id_idx) THEN
    l_encumbrance_account :=
      G_ORG_GL_REV_TBL(l_organization_id_idx).encumbrance_account;
    RETURN(l_encumbrance_account);
  ELSE
    RAISE encumbrance_account_no_exc;
  END IF;

EXCEPTION
  WHEN encumbrance_account_no_exc THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,'Encumbrance Account NOT found for the organization' || p_organization_id);
    END IF;
  RAISE;

END;

--========================================================================
-- FUNCTION  : Get_sales_account  PUBLIC
-- COMMENT   : This function is to get the Sales Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_sales_account(p_organization_id  IN NUMBER)
RETURN NUMBER
IS

l_organization_id_idx        BINARY_INTEGER;
l_sales_account              NUMBER;

sales_account_no_found_exc   EXCEPTION;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF G_ORG_GL_REV_TBL.EXISTS(l_organization_id_idx) THEN
    l_sales_account :=
      G_ORG_GL_REV_TBL(l_organization_id_idx).sales_account;
    RETURN(l_sales_account);
  ELSE
    RAISE sales_account_no_found_exc;
  END IF;

EXCEPTION
  WHEN sales_account_no_found_exc THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,'Sales Account NOT found for the organization' || p_organization_id);
    END IF;
  RAISE;

END;

--========================================================================
-- FUNCTION  : Get_expense_account  PUBLIC
-- COMMENT   : This function is to get the Expense Account from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_expense_account(p_organization_id  IN NUMBER)
RETURN NUMBER
IS

l_organization_id_idx          BINARY_INTEGER;
l_expense_account              NUMBER;

expense_account_no_found_exc   EXCEPTION;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF G_ORG_GL_REV_TBL.EXISTS(l_organization_id_idx) THEN
    l_expense_account :=
      G_ORG_GL_REV_TBL(l_organization_id_idx).expense_account;
    RETURN(l_expense_account);
  ELSE
    RAISE expense_account_no_found_exc;
  END IF;

EXCEPTION
  WHEN expense_account_no_found_exc THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,'Expense Account NOT found for the organization Id:' || p_organization_id);
    END IF;
  RAISE;

END;

--========================================================================
-- FUNCTION  : Get_start_revision  PUBLIC
-- COMMENT   : This function is to get the starting revision from
--           : global pl/sql table: g_org_gl_rev_tbl for the corresponding
--           : organization id
--
-- PRE-COND  : none
-- EXCEPTIONS: none
--========================================================================
FUNCTION Get_start_revision(p_organization_id  IN NUMBER)
RETURN VARCHAR2
IS

l_organization_id_idx          BINARY_INTEGER;
l_start_revision               VARCHAR2(3);

start_revision_no_found_exc    EXCEPTION;

BEGIN
  l_organization_id_idx  := p_organization_id;
  IF G_ORG_GL_REV_TBL.EXISTS(l_organization_id_idx) THEN
    l_start_revision :=
      G_ORG_GL_REV_TBL(l_organization_id_idx).starting_revision;
    RETURN(l_start_revision);
  ELSE
    RAISE start_revision_no_found_exc;
  END IF;

EXCEPTION
  WHEN start_revision_no_found_exc THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,'Starting Reivision NOT found for the organization' || p_organization_id);
    END IF;
  RAISE;

END;

--========================================================================
-- PROCEDURE : Set_Unit_Test_Mode      PUBLIC
-- COMMENT   : This procedure sets the unit test mode that prevents the
--             program from attempting to submit concurrent requests and
--             enables it to run it from SQL*Plus. The Item Interface will
--             not be run.
--=========================================================================
PROCEDURE  Set_Unit_Test
IS
BEGIN
  g_unit_test_mode := TRUE;
END Set_Unit_Test;


--========================================================================
-- PROCEDURE : Item_Org_Assignment     PUBLIC
-- PARAMETERS: x_errbuff               return error messages
--             x_retcode               return status
-- ************# Bug 3306087 : added new parameter ***********************
--             p_source_org_id         IN Source Organization Id
-- ***********************************************************************
--             p_org_hier_origin_id    IN Organization Hierarchy
--                                        Origin Id
--             p_org_hierarchy_id      IN Organization Hierarchy Id
--             where all the organizations for the selected hierarchy origin in
--             each hierarchy share the same item master.
--             p_category_set_id       IN Category set id
--             p_category_struct       IN Category Structure used by category pair
--             p_category_from         IN Item Category name from
--             p_category_to           IN Item Category name to
--             p_item_from             IN From Item Number
--             p_item_to               IN To Item Number
--             p_request_count         IN Maximum number of workers
--
-- COMMENT   : This is a procedure which creates new items for all the
--             organizations in an hierarchy origin. This also include the
--             hierarchy origin itself.
--=========================================================================
/* Bug 2642331. Interface of procedure Item_Org_Assignment is modified to accept
 * parameter p_category_set_name as NUMERIC.Earlier it was VARCHAR2. Parameter text
 * is replaced from p_category_set_name to p_category_set_id
 */
PROCEDURE  Item_Org_Assignment
( x_errbuff            OUT   NOCOPY VARCHAR2
, x_retcode            OUT   NOCOPY VARCHAR2
, p_source_org_id       IN   NUMBER
, p_org_hier_origin_id  IN   NUMBER
, p_org_hierarchy_id    IN   NUMBER
--, p_category_set_name  IN    VARCHAR2  made it numeric from varchar.
--Parameter text is replaced from p_category_set_name to p_category_set_id Bug:2642331
, p_category_set_id     IN   NUMBER
, p_category_struct     IN   NUMBER
, p_category_from       IN   VARCHAR2
, p_category_to         IN   VARCHAR2
, p_item_from           IN   VARCHAR2
, p_item_to             IN   VARCHAR2
, p_request_count       IN   NUMBER
)
IS

  l_org_tbl            INV_OrgHierarchy_PVT.OrgID_tbl_type;
  l_filtered_org_tbl   INV_OrgHierarchy_PVT.OrgID_tbl_type;
  l_org_id             NUMBER;
  l_src_master         NUMBER; -- Source Org. Item Master
  l_master_org_id      NUMBER;
  l_max_batch_size     NUMBER;
  l_batch_size         NUMBER;
  l_set_process_id     NUMBER;
  l_inventory_item_id  NUMBER;
  l_workers_tbl        g_request_tbl_type;
  l_min_index          BINARY_INTEGER;
  l_max_index          BINARY_INTEGER;
  l_item_cur           g_item_cur_type;
  l_item_cursor        VARCHAR2(4000);
  l_property_msg       VARCHAR2(2000);
  l_hierarchy_name     VARCHAR2(30);
  l_property           VARCHAR2(100);
  l_property_flag      VARCHAR2(1);

  l_hierarchy_validation EXCEPTION;

  l_scenario           VARCHAR2(30);

-- Variable to store revision_label Bug 4997972
  l_rev_label          VARCHAR2(80);
-- Variables for Assign Master Defaults
l_return_code     INTEGER;
l_err_text        VARCHAR2(240);

-- GL Account valid organization List
l_valid_org_tbl  INV_OrgHierarchy_PVT.OrgID_tbl_type;

-- Cursor to retrieve primary unit of measure for the item
-- and also to validate with mtl_units_of_measure
CURSOR primary_uom_cur(c_master_org_id     NUMBER
                      ,c_inventory_item_id NUMBER
                      )
IS
SELECT
  msib.primary_uom_code  primary_uom_code
, msib.primary_unit_of_measure  primary_unit_of_measure
FROM
  mtl_system_items_b msib
, mtl_units_of_measure muom
WHERE msib.organization_id          =  c_master_org_id
  AND msib.inventory_item_id        =  c_inventory_item_id
  AND msib.primary_unit_of_measure  =  muom.unit_of_measure
  AND SYSDATE < nvl(muom.disable_date,SYSDATE+1);

primary_uom_row  primary_uom_cur%ROWTYPE;

-- Cursor to retrieve a row in items interface table
CURSOR items_interface_cur(c_set_process_id     NUMBER
                          ,c_inventory_item_id  NUMBER
                          ,c_organization_id    NUMBER
                          )
IS
SELECT
  rowid
, inventory_item_id
, organization_id
, transaction_id
, set_process_id
FROM
  mtl_system_items_interface
WHERE set_process_id     = c_set_process_id
  AND inventory_item_id  = c_inventory_item_id
  AND organization_id    = c_organization_id
FOR UPDATE;

items_interface_row  items_interface_cur%ROWTYPE;

-- Exception for assign master default
assign_master_default_except  EXCEPTION;
assign_status_attrib_except   EXCEPTION;

--serial_tagging enh -- bug 9913552
Serial_Tagging_Exception      EXCEPTION;
x_ret_sts                     VARCHAR2(1);

BEGIN

  IF G_DEBUG = 'Y' THEN
    -- initialize log
    INV_ORGHIERARCHY_PVT.Log_Initialize;
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Item_Org_Assignment'
    );
  END IF;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  -- get the max batch size from the profile option;
  -- default it to 1000 if the profile option is not defined.
  l_max_batch_size := NVL( TO_NUMBER
                           ( FND_PROFILE.Value('INV_CCEOI_COMMIT_POINT')
                           )
                         , 1000
                         );


  -- Get Organization List
  INV_ORGHIERARCHY_PVT.get_organization_list
  ( p_hierarchy_id   => p_org_hierarchy_id
  , p_origin_org_id  => p_org_hier_origin_id
  , x_org_id_tbl     => l_org_tbl
  , p_include_origin => 'Y'
  );

  -- Validate for the same item master
  l_property_flag := INV_ORGHIERARCHY_PVT.
                       validate_property(l_org_tbl, 'MASTER');

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_EVENT
    ,'Property Flag:' || l_property_flag );
  END IF;

  -- 3306087  : Start Code Change
  -- NKILLEDA : Added validation of master org for new parameter
  --             source org. The source org. should have the same
  --             master org as all the orgs in the hierarchy.
  --            the master org, passed to item cursors for getting
  --             the item list, should be set to source master org.
  --             if it is not null, otherwise set to the master
  --             org of hierarchy origin.
  IF l_property_flag = 'Y'
  THEN
    l_master_org_id := Get_Master_Org(p_org_hier_origin_id);
    IF p_source_org_id is not null
    THEN
      l_src_master := Get_Master_Org(p_source_org_id);
      IF l_src_master <> l_master_org_id
      THEN
        FND_MESSAGE.set_name('INV', 'INV_INVALID_SOURCE_ORG');
        x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);
        RAISE l_hierarchy_validation;
      ELSE
        -- assigning source organization to be used to get
        -- the list of items in the range specified.
        l_master_org_id := p_source_org_id;
      END IF;
    END IF;
  ELSE
    -- get hierarchy name
    SELECT name
      INTO l_hierarchy_name
      FROM per_organization_structures
        WHERE organization_structure_id = p_org_hierarchy_id;

    -- get the hierarchy property text
    SELECT meaning
      INTO l_property
      FROM mfg_lookups
        WHERE lookup_type = 'INV_MGD_HIER_PROPERTY_TYPE'
          AND lookup_code = 1;

    -- raise hiearchy validation failure
    -- Set the message, tokens
    FND_MESSAGE.set_name('INV', 'INV_MGD_HIER_INVALID_PROPERTY');
    FND_MESSAGE.set_token('HIERARCHY', l_hierarchy_name);
    FND_MESSAGE.set_token('PROPERTY', l_property);
    x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);

    RAISE l_hierarchy_validation;

  END IF;

  -- ====================================================================
  -- Retrieve GL Account Info and starting revision for each organization
  -- in the Organization List
  -- Store the values in global PL/SQL table G_ORG_GL_REV_TBL
  -- ====================================================================
  Retrieve_gl_rev(p_org_tbl   => l_org_tbl);

  -- =====================================================================
  -- Validate GL account info against GL_CODE_COMBINATIONS for each
  -- organization in the Organization List
  -- Update global pl/sql table G_ORG_GL_REV_TBL set the valid_flag to 'Y'
  -- for the successful validation
  -- Otherwise, set to 'N' for NOT a valid code combination
  -- Short List only for valid organizations
  -- =====================================================================
  validate_gl_account(p_org_tbl        => l_org_tbl
                     ,x_valid_org_tbl  => l_valid_org_tbl
                     );

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , 'Valid Org table size: '|| TO_CHAR(l_valid_org_tbl.COUNT)
      );
    END IF;

  -- get the master organization ID
  -- Note: all the organizations in the hierarchy share the same item master
  -- 3306087   : Start Code Change
  -- NKILLEDA  : The items should be sourced from the source organization if
  --             source org is passed as parameter, otherwise the items should
  --             be assigned from master org to all organizations in hierarchy.
  --             The following line is not necessary as master org id is already
  --              assigned to source org id or hier origin master.
  --
  --  l_master_org_id := Get_Master_Org
  --                   ( p_org_hier_origin_id => p_org_hier_origin_id );
  --
  -- 3306087   : End Code Change

  l_batch_size := 0;
  l_set_process_id := Get_Set_Process_ID;

  IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , 'About to call Build_Item_Cursor '
      );
  END IF;

  l_scenario := NULL;

 /* Following method interface has been modified to incorporate CategorySetId as filter criteria.
  * Added parameter p_category_set_id to method Build_Item_Cursor. Bug: 2642331
  */
  Build_Item_Cursor
  ( p_category_set_id => p_category_set_id
  , p_cat_structure_id => p_category_struct
  , p_cat_from         => p_category_from
  , p_cat_to           => p_category_to
  , p_item_from        => p_item_from
  , p_item_to          => p_item_to
  , p_master_org_id    => l_master_org_id
  , x_item_cursor      => l_item_cursor
  , x_scenario         => l_scenario
  );

  IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , 'Out of Build_Item_Cursor '
      );
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , 'l_scenario => '|| l_scenario
      );
  END IF;

  -- List of items for the selected item range, category range
  -- and for the master organization of the hierarchy level id

  --------------------------------------------------------------
  ---   SQL Bind fix by using the USING command
  ---------------------------------------------------------------
 /* Bug: 2642331. l_item_cur is provided one more bind parameters for CategorySetId.
  */
  IF l_scenario = 'i1c1'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
      l_master_org_id,
      p_item_from, p_item_to,
      p_category_struct ,p_category_set_id ,
      p_category_from, p_category_to ;

  ELSIF l_scenario = 'i2c1'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
      l_master_org_id,
      p_item_from,
      p_category_struct, p_category_set_id ,
      p_category_from, p_category_to ;

  ELSIF l_scenario = 'i3c1'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
       l_master_org_id,
       p_item_to,
       p_category_struct ,p_category_set_id ,
       p_category_from, p_category_to ;

  ELSIF l_scenario = 'i4c1'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
       l_master_org_id,
       p_category_struct, p_category_set_id ,
       p_category_from, p_category_to ;

  ELSIF l_scenario = 'i1c2'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_item_from, p_item_to,
        p_category_struct , p_category_set_id ,
        p_category_from ;

  ELSIF l_scenario = 'i2c2'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_item_from,
        p_category_struct ,p_category_set_id ,
        p_category_from ;

  ELSIF l_scenario = 'i3c2'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_item_to,
        p_category_struct ,p_category_set_id ,
        p_category_from ;

  ELSIF l_scenario = 'i4c2'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_category_struct,  p_category_set_id ,
        p_category_from ;

 ELSIF l_scenario = 'i1c3'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
       l_master_org_id,
       p_item_from, p_item_to,
       p_category_struct ,p_category_set_id ,
       p_category_to ;

  ELSIF l_scenario = 'i2c3'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_item_from,
        p_category_struct ,p_category_set_id ,
        p_category_to ;

  ELSIF l_scenario = 'i3c3'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_item_to,
        p_category_struct , p_category_set_id ,
        p_category_to ;

  ELSIF l_scenario = 'i4c3'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
        l_master_org_id,
        p_category_struct, p_category_set_id ,
        p_category_to ;

  ELSIF l_scenario = 'i1c4'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
      l_master_org_id,
      p_item_from, p_item_to ;

  ELSIF l_scenario = 'i2c4'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING
      l_master_org_id,
      p_item_from ;

  ELSIF l_scenario = 'i3c4'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING l_master_org_id,
          p_item_to ;

  ELSIF l_scenario = 'i4c4'
  THEN
    OPEN l_item_cur FOR l_item_cursor
    USING l_master_org_id;

  END IF;

  ----------------------------- End BIND Fix ------------------

--  Old code commented --
--  OPEN l_item_cur FOR l_item_cursor; --

  IF G_DEBUG = 'Y' THEN
   INV_ORGHIERARCHY_PVT.Log
   ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'start LOOP on l_item_cur'
   );
  END IF;

  LOOP

    FETCH l_item_cur INTO l_inventory_item_id;
    EXIT WHEN l_item_cur%NOTFOUND;

    -- ===========================================
    -- Get Primary Unit of Measure of the item
    -- validate with mtl_units_of_measure
    -- ===========================================
    OPEN primary_uom_cur(l_master_org_id
                        ,l_inventory_item_id
                        );
    FETCH primary_uom_cur
     INTO primary_uom_row;

    IF primary_uom_cur%FOUND THEN


    Filter_Org_List
    ( p_org_tbl           => l_valid_org_tbl
    , p_inventory_item_id => l_inventory_item_id
    , x_filtered_org_tbl  => l_filtered_org_tbl
    );

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , 'Filtered table size: '|| TO_CHAR(l_filtered_org_tbl.COUNT)
      );
    END IF;

    IF l_filtered_org_tbl.COUNT > 0 THEN

      l_min_index := 1;

      IF l_filtered_org_tbl.COUNT > (l_max_batch_size - l_batch_size) THEN
        l_max_index := l_max_batch_size - l_batch_size;
      ELSE
        l_max_index := l_filtered_org_tbl.COUNT;
      END IF;

      LOOP

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         , 'Loop on a batch'
          );

          INV_ORGHIERARCHY_PVT.Log
          ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          , 'Min index:'||TO_CHAR(l_min_index)
          );
          INV_ORGHIERARCHY_PVT.Log
          ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          , 'Max index:'||TO_CHAR(l_max_index)
          );
        END IF;



        FORALL l_Idx IN l_min_index..l_max_index
          INSERT INTO mtl_system_items_interface
          ( process_flag
          , set_process_id
          , transaction_type
          , inventory_item_id
          , organization_id
          , primary_uom_code
          , primary_unit_of_measure
          , cost_of_sales_account
          , encumbrance_account
          , sales_account
          , expense_account
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , last_update_login
          , request_id
          , program_application_id
          , program_id
          , program_update_date
          )
          VALUES
          ( /*4 Bug 5962957 here the validation should happen so changing it to 1*/
	    1
          , l_set_process_id
          , 'CREATE'
          , l_inventory_item_id
          , l_filtered_org_tbl(l_Idx)
          , primary_uom_row.primary_uom_code
          , primary_uom_row.primary_unit_of_measure
          , get_cost_of_sales_account(l_filtered_org_tbl(l_Idx))
          , get_encumbrance_account(l_filtered_org_tbl(l_Idx))
          , get_sales_account(l_filtered_org_tbl(l_Idx))
          , get_expense_account(l_filtered_org_tbl(l_Idx))
          , SYSDATE
          , FND_GLOBAL.user_id
          , SYSDATE
          , FND_GLOBAL.user_id
          , FND_GLOBAL.login_id
          , FND_GLOBAL.conc_request_id
          , FND_GLOBAL.prog_appl_id
          , FND_GLOBAL.conc_program_id
          , SYSDATE
          );


        -- =====================================================================
        -- for that range of index assign master defaults and insert into
        -- revision interface table
        -- =====================================================================
        FOR l_Idx IN l_min_index..l_max_index  LOOP

        -- Get rowid from items interface table
        OPEN items_interface_cur(l_set_process_id
                                ,l_inventory_item_id
                                ,l_filtered_org_tbl(l_Idx)
                                );
        FETCH items_interface_cur
         INTO items_interface_row;

          -- Assign Master Defaults
          l_return_code := INVPUTLI.Assign_master_defaults
                             (Tran_id         => NULL
                             ,Item_id         => items_interface_row.inventory_item_id
                             ,Org_id          => items_interface_row.organization_id
                             ,Master_org_id   => l_master_org_id
                             ,Status_default  => NULL
                             ,Uom_default     => NULL
                             ,Allow_item_desc_flag => NULL
                             ,Req_required_flag    => NULL
                             ,p_rowid              => items_interface_row.rowid
                             ,Err_text             => l_err_text
                             );

          -- error while assigning master defaults
          IF l_return_code <> 0 THEN
            RAISE assign_master_default_except;
          ELSE
            -- Bug#4121148 fix: invoke INVPULI4.assign_status_attributes
	    -- Bug 8549754 vggarg Passed master_org_id containing the value of source org id as parameter.
            l_return_code := INVPULI4.assign_status_attributes(
                               item_id  => items_interface_row.inventory_item_id
                             , org_id   => items_interface_row.organization_id
                             , err_text => l_err_text
                             , xset_id  => l_set_process_id
                             , p_rowid  => items_interface_row.rowid
     			     , master_org_id   => l_master_org_id);
              if l_return_code <> 0 then
                raise assign_status_attrib_except;
              end if;
          END IF;

          -- Serial_tagging -- bug 9913552
	  IF ( INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => l_inventory_item_id,
                                                    p_organization_id   => l_master_org_id)=2 ) THEN

             /* both p_from_item_id and p_to_item_id will be same in this case */
	           INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
	                                  p_from_item_id  => l_inventory_item_id,
	                                  p_from_org_id   => l_master_org_id,
	                                  p_to_item_id    => items_interface_row.inventory_item_id,
	                                  p_to_org_id     => items_interface_row.organization_id,
	                                  x_return_status => x_ret_sts);

             IF x_ret_sts <>FND_API.G_RET_STS_SUCCESS THEN

               FND_MESSAGE.set_name('INV', 'INV_COPY_SER_FAIL_UNEXP');
               x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);

               RAISE Serial_Tagging_Exception;

             END IF ;

        END IF ;


          /* commented for better performance
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
              , 'Assign Master default successful:'|| items_interface_row.rowid
              || ' Item Id:' || items_interface_row.inventory_item_id ||
              ' Org Id:' || items_interface_row.organization_id
              );
          END IF;
          */

        /* Bug 4997972 The following statement is for storing revision label and revision */

          l_rev_label := get_start_revision(items_interface_row.organization_id);

          -- ===========================================================
          -- Insert into Revisions interface table
          -- ===========================================================
          INSERT INTO mtl_item_revisions_interface
          ( inventory_item_id
          , organization_id
          , revision
          , revision_label
          , implementation_date
          , effectivity_date
          , transaction_id
          , process_flag
          , transaction_type
          , set_process_id
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , last_update_login
          , request_id
          , program_application_id
          , program_id
          , program_update_date
          , revision_id
          )
          VALUES
          (items_interface_row.inventory_item_id
          ,items_interface_row.organization_id
          ,l_rev_label
          ,l_rev_label
          ,SYSDATE
          ,SYSDATE
          ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
          ,/*4 Bug 5962957 here the validation should happen so changing it to 1*/ 1
          ,'CREATE'
          ,l_set_process_id
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,FND_GLOBAL.login_id
          ,FND_GLOBAL.conc_request_id
          ,FND_GLOBAL.prog_appl_id
          ,FND_GLOBAL.conc_program_id
          ,SYSDATE
          ,MTL_ITEM_REVISIONS_B_S.nextval
          );

          /* commented for better performance
          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
              , 'Revision interface successful:'|| items_interface_row.rowid
              || ' Item Id:' || items_interface_row.inventory_item_id ||
              ' Org Id:' || items_interface_row.organization_id
              );
          END IF;
          */

          CLOSE items_interface_cur;

        END LOOP; -- end loop for that range of index

        l_batch_size := l_batch_size + l_max_index - l_min_index + 1;

        IF l_batch_size >= l_max_batch_size THEN
          Submit_Item_Import
          ( p_organization_id => p_org_hier_origin_id
          , p_set_process_id  => l_set_process_id
          , x_workers         => l_workers_tbl
          , p_request_count   => p_request_count
          );


          l_batch_size := 0;
          l_set_process_id := Get_Set_Process_ID;
        END IF;

        l_min_index := l_max_index + 1;
        IF l_filtered_org_tbl.COUNT > (l_max_index + l_max_batch_size) THEN
          l_max_index := l_max_index+l_max_batch_size;
        ELSE
          l_max_index := l_filtered_org_tbl.COUNT;
        END IF;

        EXIT WHEN (l_min_index > l_filtered_org_tbl.COUNT);

    END LOOP; -- end loop of filter org list

          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_EVENT
              , 'Interface records inserted for Item:' || l_inventory_item_id
                || ' '|| 'Process Id:'|| l_set_process_id
              );
          END IF;

    END IF; -- organization list check

  ELSE

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_ERROR
      , 'Valid Primary Unit of Measure not found for the item id:'||
        l_inventory_item_id
      );
    END IF;

  END IF; -- primary uom check
  CLOSE primary_uom_cur;

  END LOOP; -- item cursor loop

  CLOSE l_item_cur;

  -- if there are records posted in the interface table but for which the
  -- Item Import program has not been submitted, submit it.
  IF l_batch_size > 0 THEN
    Submit_Item_Import
    ( p_organization_id =>p_org_hier_origin_id
    , p_set_process_id => l_set_process_id
    , x_workers        => l_workers_tbl
    , p_request_count  => p_request_count
    );
  END IF;

  Wait_For_All_Workers(p_workers  => l_workers_tbl);

  Determine_Return_Code
  ( x_retcode  => x_retcode
  , x_errbuff  => x_errbuff
  );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Item_Org_Assignment'
    );
  END IF;

EXCEPTION

  WHEN g_submit_failure_exc THEN
    FND_MESSAGE.Set_Name('INV', 'INV_UNABLE_TO_SUBMIT_CONC');
    x_errbuff := SUBSTR(FND_MESSAGE.Get, 1, 255);
    x_retcode := RETCODE_ERROR;

  WHEN l_hierarchy_validation THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,x_errbuff);
    END IF;
    x_retcode := RETCODE_ERROR;

  WHEN assign_master_default_except THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,l_err_text);
    END IF;
    x_errbuff := l_err_text;
    x_retcode := l_return_code;

  WHEN assign_status_attrib_except THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,l_err_text);
    END IF;
    x_errbuff := l_err_text;
    x_retcode := l_return_code;
--serial_tagging eng -- bug 9913552
  WHEN Serial_Tagging_Exception  THEN
     IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,x_errbuff);
    END IF;
    x_retcode := RETCODE_ERROR;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Item_Org_Assignment'
      );
    END IF;
    x_retcode := RETCODE_ERROR;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);

END Item_Org_Assignment;


END INV_ITEM_ORG_ASSIGN_CP;

/
