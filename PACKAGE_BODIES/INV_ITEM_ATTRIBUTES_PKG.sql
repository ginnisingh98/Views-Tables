--------------------------------------------------------
--  DDL for Package Body INV_ITEM_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_ATTRIBUTES_PKG" AS
/* $Header: INVGIAPB.pls 120.2 2006/02/22 22:39:45 myerrams noship $ */
--/*==========================================================================+
--|   Copyright (c) 2000 Oracle Corporation Belmont, California, USA          |
--|                          All rights reserved.                             |
--+===========================================================================+
--|                                                                           |
--| File Name   : invgiapb.pls                                                |
--| Description : Item attribute processor for the Item Attribute copy form.  |
--|               Creates a pl/sql table of records and populates it with     |
--|               information seeded in the AK dictionary. Queries can then   |
--|               be constructed, based on the pl/sql table of records which  |
--|               retreive the date to populate MTL_ITEM_ATTRIBUTES_TEMP, on  |
--|               which the form is based.                                    |
--|                                                                           |
--| Revision                                                                  |
--|  13-Sep-00  dherring     Created                                          |
--|  17-JUL-01  dherring     Updated with performance enhancements            |
--|  06-NOV-02  vjavli       Bug#2643619 fix: more than one SEGMENT in system |
--|                          items flex field - build_item_cursor procedure to|
--|                          build the dynamic cursor to select the items     |
--|  21-NOV-02  vma          Performance: modify code to print to log only if |
--|                          debug profile option is enabled; add NOCOPY to   |
--|                          OUT parameters of find_org_list, get_type_struct,|
--|                          call_item_update                                 |
--|  20-FEB-03 vjavli        Bug#2808261 fix: organization item records is    |
--|                          getting repeated.  Found that when there is no   |
--|                          item for that organization, it should not be     |
--|                          inserted in MTL_ITEM_ATTRIBUTES_TEMP             |
--|  18-MAR-03 vjavli        Bug#2855692 fix: all items should be displayed   |
--|                          in the items range for all the organizations     |
--|                          procedure: populate_temp_table modified with     |
--|                          WHILE loop for the item_cursor                   |
--|  09-FEB-04 vjavli        GSCC fix: file.sql.47                            |
--|                          FND_INSTALLATION.get_app_info used to obtain     |
--|                          owner of database schema.  This will be used in  |
--|                          WHERE condition to compare with owner along with |
--|                          table_name of all_tab_columns                    |
--|  10-FEB-04 nkilleda      Bug#3148944 fix: Unapproved items should be      |
--|                          excluded from item range when item from and item |
--|                          to fields are input by user. These items are PLM |
--|                          items and should not be visible to an ERPuser.   |
--|                          Modified Build_Item_Cursor (l_mstk_w)            |
--|  11-Mar-04 TMANDA        Bug#3497035 : Replaced p_cat_set_id is not null  |
--|                          with p_cat_set_id <> -1 in populate_temp_table   |
--|                          and Build_Item_Cursor procedures.                |
--|                          Commented unncessary ELSE clauses where the      |
--|                          variables are being set to null.                 |
--|  21-May-04 vto           Bug 3571949: Fixed issue with folder prompts not |
--|                          translated.                                      |
--|  14-NOV-04 nesoni        Bug# 3770547. Procedure populate_temp_table and  |
--|                          Build_Item_Cursor have been modified to          |
--|                          incorporate attribute_category as additional IN  |
--|                          parameter for filtering items for coping. Added  |
--|                          NOCOPY to OUT parameters.                        |
--|  16-DEC-04 nesoni        BUG #4025750. Procedure   populate_temp_table    |
--|                          modified to incorporate CopyDffToNull  as        |
--|                          additional IN parameter.                         |
--|  20-DEC-04 nesoni        BUG #4064005. Procedure   populate_temp_table    |
--|                          and Build_item_Cursor are modified to accept     |
--|                          attribute_category as bind parameter.            |
--|  20-DEC-04 MYERRAMS      BUG #5001785. Modified the Update queries to     |
--|                          use bind variables instead of SQL Literals to    |
--|                          improve the performance.		              |
--+==========================================================================*/

--=================
-- CONSTANTS
--=================

G_INV_ITEM_ATTRIBUTES_PKG VARCHAR2(30) := 'INV_ITEM_ATTRIBUTES_PKG';

--==================
-- GLOBAL VARIABLES
--==================

g_att_tab att_tbl_type;
g_sel_tab sel_tbl_type;
g_cho_rec cho_rec_type;
g_current_att_index BINARY_INTEGER := 0;
g_current_sel_index BINARY_INTEGER := 0;
g_empty_att_tab att_tbl_type;
g_empty_sel_tab sel_tbl_type;
g_itm_rec inv_item_grp.item_rec_type;
g_org_tab INV_ORGHIERARCHY_PVT.orgid_tbl_type;
g_current_org_index BINARY_INTEGER := 0;
g_empty_org_tab INV_ORGHIERARCHY_PVT.orgid_tbl_type;
g_count NUMBER := 0;
g_unit_test_mode       BOOLEAN      := FALSE;
G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_ITEM_ATT_MTN';
G_SLEEP_TIME           NUMBER       := 15;
G_DEBUG                VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

g_submit_failure_exc   EXCEPTION;

TYPE g_request_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
TYPE g_item_cur_type IS REF CURSOR;


--=========================================================================
-- PROCEDURE  : get_type_struct                PRIVATE
-- PARAMETERS :
-- COMMENT    : initialize the pl/sql table with the list user selected
--              attributes
--              This code needed to initialize the pl/sql table with these
--              user selected attributes. The pl/sql table is global and it's
--              contents can then bew accessed by other apis in this package.
--              If the PL/SQL table of records has already been initialized
--              it's id is simply passed back to the calling procedure.
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE get_type_struct
(p_att_tab OUT NOCOPY ATT_TBL_TYPE
,p_cho_rec OUT NOCOPY CHO_REC_TYPE
,p_sel_tab OUT NOCOPY SEL_TBL_TYPE
)
IS

--=================
-- LOCAL VARIABLES
--=================

BEGIN

  p_att_tab := g_att_tab;
  p_cho_rec := g_cho_rec;
  p_sel_tab := g_sel_tab;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'get_type_struct'
                             );
    END IF;
    RAISE;
END get_type_struct;

--=========================================================================
-- PROCEDURE  : set_type_struct                PRIVATE
-- PARAMETERS :
-- COMMENT    : allows the form to populate
--              the two pl/sql tables with the chosen
--              record values and the unique id of the
--              records to be updated
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE set_type_struct
(p_att_tab IN ATT_TBL_TYPE
,p_cho_rec IN CHO_REC_TYPE
,p_sel_tab IN SEL_TBL_TYPE
)
IS

--=================
-- LOCAL VARIABLES
--=================

BEGIN

  g_att_tab := p_att_tab;
  g_cho_rec := p_cho_rec;
  g_sel_tab := p_sel_tab;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'set_type_struct'
                             );
    END IF;
    RAISE;
END set_type_struct;

--=========================================================================
-- PROCEDURE  : populate_type_struct                  PRIVATE
-- PARAMETERS :
-- COMMENT    : populate the pl/sql table of records with approprite
--              data to construct the query to feed the populate temp
--              table procedure.
--              The ak meta model is normalized. Most of the information
--              we required is scattered amongst many tables.
--              This procedure uses 6 simple queries to populate
--              the records. This avoids a costly single query with
--              a join involving 6 tables.
-- PRE-COND   : This procedure must be fed a list of columns selected
--              for display by the user using the find canvas of the
--              item_attributes_copy form.
--=========================================================================
PROCEDURE populate_type_struct(p_att_tab IN ATT_TBL_TYPE)
IS

BEGIN

  -- Initialize on the first user selected attribute

  g_att_tab := p_att_tab;
  g_current_att_index := g_att_tab.FIRST;
  g_count := g_att_tab.COUNT;

  LOOP

    g_att_tab(g_current_att_index).temp_column_name :=
      RPAD('ATTRIBUTE',12,LPAD(TO_CHAR(g_current_att_index + 1),3,'0'));

    /* Added for Bug 4064006 */
    SELECT COLUMN_TYPE
          ,LOOKUP_TABLE
          ,LOOKUP_COLUMN
          ,LOOKUP_TYPE
          ,LOOKUP_TYPE_VALUE
          ,REFERENCE_KEY_COLUMN
    INTO g_att_tab(g_current_att_index).column_type
        ,g_att_tab(g_current_att_index).lookup_table
        ,g_att_tab(g_current_att_index).lookup_column
        ,g_att_tab(g_current_att_index).lookup_type
        ,g_att_tab(g_current_att_index).lookup_type_value
        ,g_att_tab(g_current_att_index).reference_key_column
    FROM MTL_ITEM_ATTRIBUTES_SEED_INFO
    WHERE attribute_code = g_att_tab(g_current_att_index).item_column_name
    ORDER BY rowid;

    /*SELECT default_value_varchar2
          ,display_value_length
    INTO g_att_tab(g_current_att_index).foreign_key_name
        ,g_att_tab(g_current_att_index).column_type
    FROM ak_object_attributes
    WHERE database_object_name = 'MTL_SYSTEM_ITEMS_VL'
    AND attribute_code = g_att_tab(g_current_att_index).item_column_name
    ORDER BY rowid;

    -- If the column is a flexfield then do not overwrite
    -- the display column entry in the table of records
    -- because that has already been populated with
    -- the display name in the forms package
    -- FND_ATTR_AVAILABLE

    IF g_att_tab(g_current_att_index).column_type <> 4
    THEN

      SELECT attribute_label_long
      INTO g_att_tab(g_current_att_index).display_column
      FROM ak_object_attributes_vl
      WHERE database_object_name = 'MTL_SYSTEM_ITEMS_VL'
      AND attribute_code = g_att_tab(g_current_att_index).item_column_name;

    END IF;

    IF g_att_tab(g_current_att_index).foreign_key_name IS NOT NULL
      AND g_att_tab(g_current_att_index).column_type = 1
      THEN

      SELECT from_to_name
            ,to_from_name
      INTO g_att_tab(g_current_att_index).lookup_table
          ,g_att_tab(g_current_att_index).lookup_column
      FROM ak_foreign_keys_tl
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name
      AND language = 'US';

      SELECT from_to_description
            ,to_from_description
      INTO g_att_tab(g_current_att_index).lookup_type
          ,g_att_tab(g_current_att_index).lookup_type_value
      FROM ak_foreign_keys_tl
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name
      AND language = 'US';

      SELECT attribute_code
      INTO g_att_tab(g_current_att_index).foreign_key_column
      FROM ak_foreign_key_columns
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name;

      SELECT attribute_code
      INTO g_att_tab(g_current_att_index).reference_key_column
      FROM ak_unique_key_columns
      WHERE unique_key_name = g_att_tab(g_current_att_index).lookup_table;

    ELSIF g_att_tab(g_current_att_index).foreign_key_name IS NOT NULL
      AND g_att_tab(g_current_att_index).column_type = 2
      THEN

      SELECT from_to_name
            ,to_from_name
      INTO g_att_tab(g_current_att_index).lookup_table
          ,g_att_tab(g_current_att_index).lookup_column
      FROM ak_foreign_keys_tl
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name
      AND language = 'US';

      SELECT from_to_description
            ,to_from_description
      INTO g_att_tab(g_current_att_index).lookup_type
          ,g_att_tab(g_current_att_index).lookup_type_value
      FROM ak_foreign_keys_tl
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name
      AND language = 'US';

      SELECT attribute_code
      INTO g_att_tab(g_current_att_index).foreign_key_column
      FROM ak_foreign_key_columns
      WHERE foreign_key_name = g_att_tab(g_current_att_index).foreign_key_name;

    END IF;
    */
    EXIT WHEN g_current_att_index = g_att_tab.LAST;

    g_current_att_index := g_att_tab.NEXT(g_current_att_index);

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'populate_type_struct'
                             );
    END IF;
    RAISE;
END populate_type_struct;

--=========================================================================
-- PROCEDURE  : clear_type_struct                PRIVATE
-- PARAMETERS :
-- COMMENT    : clear the pl/sql table
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE clear_type_struct
IS

BEGIN

  -- clear the pl/sql table before use
  g_att_tab := g_empty_att_tab;

  -- reset global index
  g_current_att_index := 0;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'clear_type_struct'
                             );
    END IF;
    RAISE;
END clear_type_struct;

--========================================================================
-- PROCEDURE : Build_Item_Cursor       PRIVATE
-- PARAMETERS: p_category_id      IN   Category Id
--             p_category_set_id  IN   Category Set Id
--             p_item_id          IN   Inventory Item Id
--             p_item_from        IN   Item Number From
--             p_item_to          IN   Item Number To
--             p_organization_id  IN   Organization id
--             p_sts_code         IN   Inventory Item Status Code
--             p_attribute_category IN          VARCHAR2
--             p_copy_dff_to_null   IN          VARCHAR2
--             p_attribute_category IN          VARCHAR2
--             x_item_cursor           OUT NOCOPY    item cursor statement
-- COMMENT   : This procedure builds the item cursor statement. This statement
--             needs to be built at run time (dynamic SQL) because of the
--             dynamic nature of the System Item flexfield.
--             This procedure introduced as part of bug#2643619 fix for
--             more than one SEGMENT issue
--=========================================================================
/* Bug: 3770547
One more input parameter AttributeCategory added to find items that need to be populated*/
/* Bug: 4025750
One more filter parameter p_copy_dff_to_null added to find items that need to be populated*/
PROCEDURE Build_Item_Cursor
( p_category_id      IN            NUMBER
, p_category_set_id  IN            NUMBER
, p_item_id          IN            NUMBER
, p_item_from        IN            VARCHAR2
, p_item_to          IN            VARCHAR2
, p_organization_id  IN            NUMBER
, p_sts_code         IN            VARCHAR2
, p_attribute_category IN          VARCHAR2
, p_copy_dff_to_null IN           VARCHAR2
, x_item_cursor      IN OUT NOCOPY VARCHAR2
)
IS
  l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
  l_structure_rec  FND_FLEX_KEY_API.structure_type;
  l_segment_rec    FND_FLEX_KEY_API.segment_type;
  l_segment_tbl    FND_FLEX_KEY_API.segment_list;
  l_segment_number NUMBER;
  l_mstk_segs      VARCHAR2(850);
  l_mcat_f         VARCHAR2(2000);
  l_mcat_w1        VARCHAR2(2000);
  l_mstk_w         VARCHAR2(2000);
  l_sts_w          VARCHAR2(2000);

  l_category_id      NUMBER;
  l_category_set_id  NUMBER;
  l_item_id          NUMBER;
  l_item_from        VARCHAR2(2000);
  l_item_to          VARCHAR2(2000);
  l_organization_id  NUMBER;
  l_sts_code         VARCHAR2(2000);
  -- Bug: 3770547.
  l_dff_w	VARCHAR2(2000);
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
   l_mstk_segs := l_mstk_segs ||'itm.'||l_segment_rec.column_name;
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

  IF p_item_from IS NOT NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' BETWEEN :l_item_from
                                          AND :l_item_to';
  ELSIF p_item_from IS NOT NULL AND p_item_to IS NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' >= :l_item_from';
  ELSIF p_item_from IS NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' <= :l_item_to';
  ELSIF p_item_id <> -1 THEN
    l_mstk_w := ' AND itm.inventory_item_id = :l_item_id';
--Bug#3497035
--  ELSE
--    l_mstk_w := NULL;
  END IF;
  --
  -- Bug 3418944 : Modified by NKILLEDA
  --
  -- Added the check to remove the items that are not approved
  -- ( => approval_status <> 'A' ) from the range of items.
  --
  -- Unapproved items are created in PLM and they should not be
  -- to be visible to an ERP user.
  --
  IF l_mstk_w IS NOT NULL THEN
    l_mstk_w := l_mstk_w ||' AND NVL(itm.approval_status,''A'') = ''A''';
  END IF;

--Bug#3497035
--  l_mcat_f  := ', mtl_item_categories mic';

  IF p_category_id <> -1  AND p_category_set_id <> -1 THEN
--Bug#3497035
--  IF p_category_id <> -1  AND p_category_set_id IS NOT NULL THEN
    l_mcat_f  := ', mtl_item_categories mic';
    l_mcat_w1 := ' AND mic.organization_id = itm.organization_id'     ||
                 ' AND mic.inventory_item_id = itm.inventory_item_id' ||
                 ' AND mic.category_set_id = :l_category_set_id' ||
                 ' AND mic.category_id = :l_category_id';
--Bug#3497035
--  ELSE
--    l_mcat_f  := NULL;
--    l_mcat_w1 := NULL;
  END IF;

  IF p_sts_code IS NOT NULL THEN
    l_sts_w  := ' AND itm.inventory_item_status_code LIKE :l_sts_code';
--Bug#3497035
--  ELSE
--    l_sts_w  := NULL;
  END IF;


 /* Bug: 3770547. Verify if AttributeCategory is present then
  * construct appropriate where clasue and update query accordingly. */
  IF p_attribute_category IS NOT NULL THEN
     --Modified for bug 4025750.
     IF p_copy_dff_to_null IS NULL OR p_copy_dff_to_null = 'NO' THEN
      l_dff_w := ' AND itm.attribute_category = :l_attribute_category ';
     ELSIF p_copy_dff_to_null = 'YES' THEN
      l_dff_w := ' AND (itm.attribute_category IS NULL OR itm.attribute_category = :l_attribute_category )';
     END IF;
  ELSE
    l_dff_w := NULL;
  END IF;

  x_item_cursor :=  'SELECT  DISTINCT
                             par.organization_code
                           , par.organization_id    '                              ||
                    ', ' ||  l_mstk_segs                                           ||
                          ', itm.inventory_item_id'                                ||
                     ' FROM  mtl_system_items_b itm'                               ||
                         ' , mtl_parameters par'                                   ||
                             l_mcat_f                                              ||
                     ' WHERE itm.organization_id = par.organization_id'            ||
                       ' AND itm.organization_id = :organization_id'     ||
                             l_mstk_w                                              ||
                             l_mcat_w1                                             ||
                             l_sts_w                                               ||
                             l_dff_w;

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

--=========================================================================
-- PROCEDURE  : populate_temp_table                PUBLIC
-- PARAMETERS :
-- COMMENT    : contruct queries to populate the temp table
-- PRE-COND   : the table of records must contain all the info necessary
--            : to contruct these queries.
--=========================================================================
/* Bug: 3770547
One more input parameter AttributeCategory added to find items that need to be populated*/
/* Bug: 4025750
One more filter parameter p_copy_dff_to_null added to find items that need to be populated*/
PROCEDURE populate_temp_table
(p_item_id          IN NUMBER
,p_org_code_list    IN INV_ORGHIERARCHY_PVT.orgid_tbl_type
,p_cat_id           IN NUMBER
,p_cat_set_id       IN NUMBER
,p_item_low         IN VARCHAR2
,p_item_high        IN VARCHAR2
,p_sts_code         IN VARCHAR2
,p_attribute_category IN VARCHAR2
,p_copy_dff_to_null IN VARCHAR2)--Added p_copy_dff_to_null parameter for Bug 4025750.
IS

--=================
-- LOCAL VARIABLES
--=================

l_dml_str         VARCHAR2(250);
l_bu_id           NUMBER;
l_org_id          NUMBER;
l_org_index       BINARY_INTEGER;

-- ======================
-- Dynamic Cursor Variable
-- =======================
TYPE g_item_cur_type IS REF CURSOR;
l_item_cur           g_item_cur_type;

-- Variable to hold the SELECT statement
l_item_cursor        VARCHAR2(4000);

-- =========================================
-- Dynamic Cursor SELECT statement variables
-- =========================================
l_organization_code    VARCHAR2(3);
l_organization_id      NUMBER;
l_item_number          VARCHAR2(1025);
l_inventory_item_id    NUMBER;
l_scenario_id          NUMBER;

/* Added for Bug 4064005.*/
item_low_input boolean;
item_high_input  boolean;
item_id_input  boolean;
cat_set_id_input  boolean;
sts_code_input  boolean;
attribute_category_input  boolean;

BEGIN
  /* Following code block added for bug 4025750.
   */
   IF p_attribute_category IS NOT NULL
   AND p_copy_dff_to_null IS NOT NULL
   AND p_copy_dff_to_null = 'YES' THEN
    g_current_att_index := g_att_tab.LAST;
    g_current_att_index := g_current_att_index + 1;
    g_att_tab(g_current_att_index).temp_column_name :=
      RPAD('ATTRIBUTE',12,LPAD(TO_CHAR(g_current_att_index + 1),3,'0'));
    g_att_tab(g_current_att_index).column_type := 4;
    g_att_tab(g_current_att_index).item_column_name := 'Attribute_Category';
    g_att_tab(g_current_att_index).display_column := 'Attribute_Category';
    g_count := g_count + 1;
   END IF;

  -- First make sure there is no left over data from a previous
  -- navigation to this form

  DELETE FROM MTL_ITEM_ATTRIBUTES_TEMP;

  l_org_index := p_org_code_list.FIRST;
  l_org_id := p_org_code_list(l_org_index);

  /* Added for Bug 4064005. */
  IF p_item_low IS NULL THEN
   item_low_input := FALSE;
  ELSE
   item_low_input := TRUE;
  END IF;
  IF p_item_high IS NULL THEN
   item_high_input := FALSE;
  ELSE
   item_high_input := TRUE;
  END IF;
  IF p_item_id = -1 THEN
   item_id_input := FALSE;
  ELSE
   item_id_input := TRUE;
  END IF;
  IF p_cat_set_id = -1 THEN
   cat_set_id_input := FALSE;
  ELSE cat_set_id_input := TRUE;
  END IF;
  IF p_sts_code IS NULL THEN
   sts_code_input := FALSE;
  ELSE
   sts_code_input := TRUE;
  END IF;
  IF p_attribute_category IS NULL THEN
   attribute_category_input := FALSE;
  ELSE
   attribute_category_input := TRUE;
  END IF;


  LOOP

    -- populate the temp table with data context data

    -- Build Dynamic cursor
    -- p_attribute_category is passed as additional in parameter. Bug: 3770547
    Build_Item_Cursor
    ( p_category_id      => p_cat_id
    , p_category_set_id  => p_cat_set_id
    , p_item_id          => p_item_id
    , p_item_from        => p_item_low
    , p_item_to          => p_item_high
    , p_organization_id  => l_org_id
    , p_sts_code         => p_sts_code
    , p_attribute_category => p_attribute_category
    , p_copy_dff_to_null => p_copy_dff_to_null
    , x_item_cursor      => l_item_cursor
    );


    /* Added for Bug 4064005 */
    IF item_low_input AND item_high_input AND cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id, p_sts_code, p_attribute_category;
    ELSIF item_low_input AND item_high_input AND cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id, p_sts_code;
    ELSIF item_low_input AND NOT item_high_input AND cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_cat_set_id, p_cat_id, p_sts_code, p_attribute_category;
    ELSIF item_low_input AND NOT item_high_input AND cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_cat_set_id, p_cat_id, p_sts_code;
    ELSIF NOT item_low_input AND item_high_input AND cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_cat_set_id, p_cat_id, p_sts_code, p_attribute_category;
    ELSIF NOT item_low_input AND item_high_input AND cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_cat_set_id, p_cat_id, p_sts_code;
    ELSIF item_id_input AND cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_cat_set_id, p_cat_id, p_sts_code, p_attribute_category;
    ELSIF item_id_input AND cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_cat_set_id, p_cat_id, p_sts_code;
    ELSIF item_low_input AND item_high_input AND cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id, p_attribute_category;
    ELSIF item_low_input AND item_high_input AND cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id;
    ELSIF item_low_input AND NOT item_high_input AND cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_cat_set_id, p_cat_id, p_attribute_category;
    ELSIF item_low_input AND NOT item_high_input AND cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_cat_set_id, p_cat_id;
    ELSIF NOT item_low_input AND item_high_input AND cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_cat_set_id, p_cat_id, p_attribute_category;
    ELSIF NOT item_low_input AND item_high_input AND cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_cat_set_id, p_cat_id;
    ELSIF item_id_input AND cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_cat_set_id, p_cat_id, p_attribute_category;
    ELSIF item_id_input AND cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_cat_set_id, p_cat_id;
    ELSIF item_low_input AND item_high_input AND NOT cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_sts_code, p_attribute_category;
    ELSIF item_low_input AND item_high_input AND NOT cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_sts_code;
    ELSIF item_low_input AND NOT item_high_input AND NOT cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_sts_code, p_attribute_category;
    ELSIF item_low_input AND NOT item_high_input AND NOT cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_sts_code;
    ELSIF NOT item_low_input AND item_high_input AND NOT cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_sts_code, p_attribute_category;
    ELSIF NOT item_low_input AND item_high_input AND NOT cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_sts_code;
    ELSIF item_id_input AND NOT cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_sts_code, p_attribute_category;
    ELSIF item_id_input AND NOT cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_sts_code;
    ELSIF item_low_input AND item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high, p_attribute_category;
    ELSIF item_low_input AND item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_item_high;
    ELSIF item_low_input AND NOT item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low, p_attribute_category;
    ELSIF item_low_input AND NOT item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_low;
    ELSIF NOT item_low_input AND item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high, p_attribute_category;
    ELSIF NOT item_low_input AND item_high_input AND NOT cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_high;
    ELSIF item_id_input AND NOT cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id, p_attribute_category;
    ELSIF item_id_input AND NOT cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_item_id;

    /* Added for Bug 4064006 */
   ELSIF NOT item_low_input AND NOT item_high_input AND NOT item_id_input AND cat_set_id_input AND sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_cat_set_id, p_cat_id, p_sts_code , p_attribute_category;
   ELSIF NOT item_low_input AND NOT item_high_input AND NOT item_id_input AND cat_set_id_input AND sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_cat_set_id, p_cat_id, p_sts_code;
   ELSIF NOT item_low_input AND NOT item_high_input AND NOT item_id_input AND cat_set_id_input AND NOT sts_code_input AND attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_cat_set_id, p_cat_id, p_attribute_category;
   ELSIF NOT item_low_input AND NOT item_high_input AND NOT item_id_input AND cat_set_id_input AND NOT sts_code_input AND NOT attribute_category_input THEN
      OPEN l_item_cur FOR l_item_cursor
      USING l_org_id, p_cat_set_id, p_cat_id;

   END IF;

  /* Commented during bug 4064005
    -- Item Info for the selected category set, category, item range or item id
    -- with inventory item status code

    IF p_item_low IS NOT NULL
    AND p_item_high IS NOT NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id, p_sts_code;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_cat_set_id, p_cat_id, p_sts_code;

    ELSIF p_item_low IS NULL
    AND p_item_high IS NOT NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_high, p_cat_set_id, p_cat_id, p_sts_code;

    ELSIF p_item_id <> -1
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_id, p_cat_set_id, p_cat_id, p_sts_code;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NOT NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_item_high, p_cat_set_id, p_cat_id;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_cat_set_id, p_cat_id;

    ELSIF p_item_low IS NULL
    AND p_item_high IS NOT NULL
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_high, p_cat_set_id, p_cat_id;

    ELSIF p_item_id <> -1
    AND p_cat_id <> -1
--Bug#3497035
--    AND p_cat_set_id IS NOT NULL
    AND p_cat_set_id <> -1
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_id, p_cat_set_id, p_cat_id;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NOT NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_item_high, p_sts_code;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_sts_code;

    ELSIF p_item_low IS NULL
    AND p_item_high IS NOT NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_high, p_sts_code;

    ELSIF p_item_id <> -1
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NOT NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_id, p_sts_code;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NOT NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low, p_item_high;

    ELSIF p_item_low IS NOT NULL
    AND p_item_high IS NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_low;

    ELSIF p_item_low IS NULL
    AND p_item_high IS NOT NULL
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_high;

    ELSIF p_item_id <> -1
--Bug#3497035
    AND (p_cat_id = -1 OR p_cat_set_id = -1)
--    AND (p_cat_id = -1 OR p_cat_set_id IS NULL)
    AND p_sts_code IS NULL THEN

      OPEN l_item_cur FOR l_item_cursor
      USING
        l_org_id, p_item_id;

    END IF;
*/


    FETCH l_item_cur
     INTO l_organization_code
         ,l_organization_id
         ,l_item_number
         ,l_inventory_item_id;

    WHILE l_item_cur%FOUND LOOP

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        ( INV_ORGHIERARCHY_PVT.G_LOG_EVENT
        , 'Organization Code:' || l_organization_code || ' ' ||
          'Organization Id:' || l_organization_id || ' ' ||
          'Item Number:' || l_item_number || ' ' ||
          'Inventory Item Id:' || l_inventory_item_id
        );
      END IF;

      -- populate the table
      INSERT INTO MTL_ITEM_ATTRIBUTES_TEMP(
         organization_code
        ,organization_id
        ,item_code
        ,item_id
         )
         VALUES
           ( l_organization_code
           , l_organization_id
           , l_item_number
           , l_inventory_item_id
           );

      FETCH l_item_cur
       INTO l_organization_code
           ,l_organization_id
           ,l_item_number
           ,l_inventory_item_id;


    END LOOP; -- item cursor loop

    CLOSE l_item_cur;

    EXIT WHEN l_org_index = p_org_code_list.LAST;
    l_org_index := p_org_code_list.NEXT(l_org_index);
    l_org_id := p_org_code_list(l_org_index);

  END LOOP;

  g_current_att_index := g_att_tab.FIRST;

  LOOP

    IF g_att_tab(g_current_att_index).column_type = 1 THEN


      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP tmp SET ( '
         || g_att_tab(g_current_att_index).temp_column_name
         || ' ) = '
         || ' (SELECT '
         || g_att_tab(g_current_att_index).item_column_name
         || ' FROM MTL_SYSTEM_ITEMS_VL itm '
         || ' WHERE tmp.item_id = itm.inventory_item_id '
         || ' AND tmp.organization_id = itm.organization_id '
         || ')';

      EXECUTE IMMEDIATE l_dml_str;
/*myerrams, Modified the following query to use bind variables. Bug: 5001785*/
      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP TMP SET ( '
         || CONCAT(g_att_tab(g_current_att_index).temp_column_name,'_DSP')
         || ' ) = '
         || ' (SELECT FND.'
         || g_att_tab(g_current_att_index).lookup_column
         || ' FROM '
         || g_att_tab(g_current_att_index).lookup_table
         || ' FND '
         || ' WHERE FND.'
         || g_att_tab(g_current_att_index).lookup_type
         || ' =  :1'
         || ' AND FND.'
         || g_att_tab(g_current_att_index).reference_key_column
         || ' = '
         || ' TMP.'
         || g_att_tab(g_current_att_index).temp_column_name
         || ')';

      EXECUTE IMMEDIATE l_dml_str
      USING g_att_tab(g_current_att_index).lookup_type_value;

    ELSIF g_att_tab(g_current_att_index).column_type = 2 THEN

      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP TMP SET ( '
         || g_att_tab(g_current_att_index).temp_column_name
         || ' ) = '
         || ' (SELECT '
         || g_att_tab(g_current_att_index).item_column_name
         || ' FROM MTL_SYSTEM_ITEMS_VL ITM '
         || ' WHERE TMP.item_id = ITM.inventory_item_id '
         || ' AND TMP.organization_id = ITM.organization_id '
         || ')';

      EXECUTE IMMEDIATE l_dml_str;

      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP TMP SET ( '
         || CONCAT(g_att_tab(g_current_att_index).temp_column_name,'_DSP')
         || ' ) = '
         || ' (SELECT FND.'
         || g_att_tab(g_current_att_index).lookup_column
         || ' FROM '
         || g_att_tab(g_current_att_index).lookup_table
         || ' FND '
         || ' WHERE FND.'
         || g_att_tab(g_current_att_index).lookup_type_value
         || ' = '
         || ' TMP.'
         || g_att_tab(g_current_att_index).temp_column_name
         || ')';

      EXECUTE IMMEDIATE l_dml_str;

    ELSE

      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP tmp SET ( '
         || g_att_tab(g_current_att_index).temp_column_name
         || ' ) = '
         || ' (SELECT '
         || g_att_tab(g_current_att_index).item_column_name
         || ' FROM MTL_SYSTEM_ITEMS_VL itm '
         || ' WHERE tmp.item_id = itm.inventory_item_id '
         || ' AND tmp.organization_id = itm.organization_id '
         || ')';


      EXECUTE IMMEDIATE l_dml_str;

      l_dml_str := 'UPDATE MTL_ITEM_ATTRIBUTES_TEMP tmp SET ( '
         || CONCAT(g_att_tab(g_current_att_index).temp_column_name,'_dsp')
         || ' ) = '
         || ' (SELECT '
         || g_att_tab(g_current_att_index).item_column_name
         || ' FROM MTL_SYSTEM_ITEMS_VL itm '
         || ' WHERE tmp.item_id = itm.inventory_item_id '
         || ' AND tmp.organization_id = itm.organization_id '
         || ')';

      EXECUTE IMMEDIATE l_dml_str;

    END IF;

    EXIT WHEN g_current_att_index = g_att_tab.LAST;

    g_current_att_index := g_att_tab.NEXT(g_current_att_index);

  END LOOP;

  COMMIT;

 EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'populate_temp_table'
                             );
    END IF;
    RAISE;

END populate_temp_table;

--=========================================================================
-- PROCEDURE  : clear_temp_table                PUBLIC
-- PARAMETERS :
-- COMMENT    : clear MTL_ITEM_ATTRIBUTES_TEMP
--              simple command to purge all records in temp table
--              this may not seem necessary as a temp table loses
--              it's data at the eand of each session.
--              However the session will last until the form is
--              dismissed and the user may query several times
--              before dismissing the form.
--              Each time there is a new query the temp table
--              needs to be purged.

-- PRE-COND   : This procedure prior to poulating the temp table
--=========================================================================
PROCEDURE clear_temp_table
IS

BEGIN

  delete MTL_ITEM_ATTRIBUTES_TEMP;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'clear_temp_table'
                             );
    END IF;
    RAISE;
END clear_temp_table;

--=========================================================================
-- PROCEDURE  : find_org_list               PUBLIC
-- PARAMETERS :
-- COMMENT    : Find the organizations that exist in the master org
-- PRE-COND   : called from form
--=========================================================================
PROCEDURE find_org_list
( p_org_tab OUT NOCOPY INV_ORGHIERARCHY_PVT.orgid_tbl_type
)
IS

--================
-- CURSORS
--================

CURSOR org_cur IS
   SELECT ORGANIZATION_ID
   FROM   ORG_ORGANIZATION_DEFINITIONS
   WHERE   ORGANIZATION_ID IN
           (SELECT  DISTINCT ORGANIZATION_ID_PARENT
            FROM     PER_ORG_STRUCTURE_ELEMENTS)
           OR
           ORGANIZATION_ID  IN
           (SELECT  ORGANIZATION_ID_CHILD
            FROM    PER_ORG_STRUCTURE_ELEMENTS)
   ORDER BY ORGANIZATION_NAME;

BEGIN

  -- clear the pl/sql table before use
  g_org_tab := g_empty_org_tab;

  -- open cursor

  IF NOT org_cur%ISOPEN
  THEN
  OPEN org_cur;
  END IF;

  FETCH org_cur INTO g_org_tab(g_org_tab.COUNT+1);

  WHILE org_cur%FOUND
  LOOP

    FETCH org_cur INTO g_org_tab(g_org_tab.COUNT+1);

  END LOOP;

  CLOSE org_cur;

  p_org_tab := g_org_tab;

EXCEPTION
 WHEN OTHERS THEN
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
     FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                            , 'find_org_list'
                            );
   END IF;
END find_org_list;

--=========================================================================
-- PROCEDURE  : call_item_update               PUBLIC
-- PARAMETERS :
-- COMMENT    : This procedure is not currently used.
--            : If the form is enhanced to offer an online
--            : option in the future the code to offer that
--            : functionality should be written here
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE call_item_update
( p_att_tab            IN  INV_ITEM_ATTRIBUTES_PKG.att_tbl_type
 ,p_sel_tab            IN  INV_ITEM_ATTRIBUTES_PKG.sel_tbl_type
 ,p_inventory_item_id  OUT NOCOPY NUMBER
 ,p_organization_id    OUT NOCOPY NUMBER
 ,p_return_status      OUT NOCOPY VARCHAR2
 ,p_error_tab          OUT NOCOPY INV_Item_GRP.Error_tbl_type
)
IS

x_errbuff             VARCHAR2(240);
x_retcode             NUMBER;

BEGIN

  x_errbuff := NULL;
  x_retcode := 0;

EXCEPTION
 WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'call_item_update'
                             );
    END IF;
    x_retcode := 2;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
END call_item_update;

--=========================================================================
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

  SELECT  COUNT(*)
    INTO  l_error_count
    FROM  mtl_system_items_interface
    WHERE NVL(request_id, 0) = NVL(FND_GLOBAL.conc_request_id, 0);

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
-- PROCEDURE : Submit_Item_Update     PRIVATE
-- PARAMETERS: p_organization_id       IN            an organization
--             p_set_process_id        IN            Set process ID
--             x_workers               IN OUT NOCOPY workers' request ID
--             p_request_count         IN            max worker number
-- COMMENT   : This procedure submits the Item Update concurrent program.
--             Before submitting the request, it verifies that there are
--             enough workers available and wait for the completion of one
--             if necessary.
--             The list of workers' request ID is updated.
--=========================================================================
PROCEDURE Submit_Item_Update
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
    , '> Submit_Item_Update'
    );

    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'x_workers.COUNT: '||TO_CHAR(x_workers.COUNT)
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

    -- argument 7 is the run mode which is 2 for update

    x_workers(l_worker_idx):= FND_REQUEST.Submit_Request
                              ( application => 'INV'
                              , program     => 'INCOIN'
                              , argument1   => p_organization_id
                              , argument2   => 1
                              , argument3   => 1
                              , argument4   => 1
                              , argument5   => 1
                              , argument6   => p_set_process_id
                              , argument7   => 2
                              );

    IF x_workers(l_worker_idx) = 0 THEN
      RAISE g_submit_failure_exc;
    END IF;

  END IF;

  COMMIT;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Submit_Item_Update'
    );
  END IF;

END Submit_Item_Update;

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
-- FUNCTION  : Get_Master_Org          PRIVATE
-- PARAMETERS: p_org_hier_level_id     IN Organization Hierarchy
--                                        Level Id
-- RETURNS   : NUMBER
-- COMMENT   : This function returns the ID of the master organization
--             common to all the organizations in the hierarchy.
--=========================================================================
FUNCTION Get_Master_Org
( p_org_hier_level_id IN NUMBER
)
RETURN NUMBER
IS
  l_master_org_id NUMBER;
BEGIN

  SELECT  master_organization_id
    INTO  l_master_org_id
    FROM  mtl_parameters
    WHERE organization_id = p_org_hier_level_id;

  RETURN l_master_org_id;

END Get_Master_Org;

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

--=========================================================================
-- PROCEDURE  : batch item update               PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_seq_id                sequence number
-- COMMENT    : Called from a concurrent program if used
--              this procedure allows the user to work in a
--              no modal fashion.
--              Blanket Update records in the MTL_SYSTEM_ITEMS table
--              The struct att_tab contains the columns that
--              are to be updated and the default values they are
--              to be updated to.
--              The struct sel_tab contains the unique id
--              of the records that are to be updated
--              The procedure constructs the record p_item_rec
--              with the default values
--              It then loops through the selected records
--              and calls the published item update api
--              for each unique record.
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE batch_item_update
( x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_seq_id             IN  NUMBER
)

IS

--================
-- TYPE
--================

TYPE itm_rec_type IS
     RECORD (item_column_name     VARCHAR2(240)
            ,chosen_value         VARCHAR2(240));

TYPE itm_tbl_type IS TABLE OF itm_rec_type
     INDEX BY BINARY_INTEGER;

TYPE upd_rec_type IS
     RECORD (item_id               NUMBER
            ,organization_id       NUMBER);

TYPE upd_tbl_type IS TABLE OF upd_rec_type
     INDEX BY BINARY_INTEGER;

--================
-- CURSORS
--================

CURSOR att_cur IS
  SELECT item_column_name
        ,chosen_value
  FROM mtl_item_values_temp
  WHERE item_update_id = p_seq_id
  ORDER BY current_att_index;

CURSOR sel_cur IS
  SELECT inventory_item_id
        ,organization_id
  FROM mtl_update_records_temp
  WHERE item_update_id = p_seq_id;

--=================
-- LOCAL VARIABLES
--=================
l_current_sel_index   BINARY_INTEGER := 0;
l_current_att_index   BINARY_INTEGER := 0;
l_att_tab             itm_tbl_type;
l_sel_tab             upd_tbl_type;

l_commit              VARCHAR2(20) := fnd_api.g_FALSE;
l_lock_rows           VARCHAR2(20) := fnd_api.g_TRUE;
l_validation_level    NUMBER := fnd_api.g_VALID_LEVEL_FULL;
l_item_rec            INV_Item_GRP.Item_rec_type;
x_item_rec            INV_Item_GRP.Item_rec_type;
x_return_status       VARCHAR2(1);
x_Error_tbl           INV_Item_GRP.Error_tbl_type;
l_sel_item            VARCHAR2(24);
l_org_code            VARCHAR2(24);
l_status              VARCHAR2(10);
l_dml_str             VARCHAR2(250);
l_max_batch_size      NUMBER;
l_batch_size          NUMBER;
l_master_org_id       NUMBER;
l_min_index           NUMBER;
l_max_index           NUMBER;
l_set_process_id      NUMBER;
l_organization_id     NUMBER;
l_workers_tbl         g_request_tbl_type;
l_request_count       NUMBER;
l_count               NUMBER;
l_data_type           VARCHAR2(24);

-- variables for FND_INSTALLATION procedure
l_app_owner_schema    VARCHAR2(30);
l_app_status          VARCHAR2(1);
l_app_industry        VARCHAR2(1);
l_app_info_status     BOOLEAN;

BEGIN

  INV_ORGHIERARCHY_PVT.Log_Initialize;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '> Batch Item Update'
    );
  END IF;

  -- the following select and if statement are included
  -- to ensure the INV_ITEM_ATTRIBUTES_PKG is compiled
  -- system tests found that the dependancy on package
  --
  SELECT status
  INTO l_status
  FROM user_objects
  WHERE object_name = 'INV_ITEM_ATTRIBUTES_PKG'
  AND object_type = 'PACKAGE BODY';

  IF l_status = 'INVALID' THEN
    DBMS_DDL.ALTER_COMPILE('package','apps','INV_ITEM_ATTRIBUTES_PKG');
  END IF;

  -- open item attribute cursor

  IF NOT att_cur%ISOPEN
  THEN
  OPEN att_cur;
  END IF;

  FETCH att_cur INTO l_att_tab(l_att_tab.COUNT);

  WHILE att_cur%FOUND
  LOOP

    FETCH att_cur INTO l_att_tab(l_att_tab.COUNT);

  END LOOP;

  CLOSE att_cur;

  IF NOT sel_cur%ISOPEN
  THEN
  OPEN sel_cur;
  END IF;

  FETCH sel_cur INTO l_sel_tab(l_sel_tab.COUNT+1);

  WHILE sel_cur%FOUND
  LOOP

    FETCH sel_cur INTO l_sel_tab(l_sel_tab.COUNT+1);

  END LOOP;

  CLOSE sel_cur;

  -- get the max batch size from the profile option;
  -- default it to 1000 if the profile option is not defined.
  l_max_batch_size := NVL( TO_NUMBER
                           ( FND_PROFILE.Value('INV_CCEOI_COMMIT_POINT')
                           )
                         , 1000
                         );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'l_max_batch_size: '||TO_CHAR(l_max_batch_size)
    );
  END IF;

  -- get the max number of workers from the profile option;
  -- default it to 1 if the profile option is not defined.
  l_request_count := NVL( TO_NUMBER
                          ( FND_PROFILE.Value('INV_MGD_MAX_WORK')
                          )
                        , 1
                        );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    , 'l_request_count: '||TO_CHAR(l_request_count)
    );
  END IF;

  l_batch_size := 0;
  l_set_process_id := Get_Set_Process_ID;

  -- Get Application database owner schema
  l_app_info_status := FND_INSTALLATION.get_app_info
                         (application_short_name => 'INV'
                         ,status                 => l_app_status
                         ,industry               => l_app_industry
                         ,oracle_schema          => l_app_owner_schema
                         );

  -- get the master organization ID

  l_current_sel_index := l_sel_tab.FIRST;

  l_master_org_id := Get_Master_Org(l_sel_tab(l_current_sel_index).organization_id);

  IF l_sel_tab.COUNT > 0 THEN

    l_min_index := 1;

    IF l_sel_tab.COUNT > l_max_batch_size THEN
      l_max_index := l_max_batch_size;
    ELSE
      l_max_index := l_sel_tab.COUNT;
    END IF;

    LOOP

      -- loop through all the records to be updated

      l_current_att_index := 0;

      INSERT INTO mtl_system_items_interface
      ( process_flag
      , set_process_id
      , transaction_type
      , inventory_item_id
      , organization_id
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , request_id
      , program_application_id
      , program_id
      , program_update_date
      , copy_item_id
      , copy_organization_id
       )
      VALUES
      ( 1
      , l_set_process_id
      , 'UPDATE'
      , l_sel_tab(l_current_sel_index).item_id
      , l_sel_tab(l_current_sel_index).organization_id
      , SYSDATE
      , FND_GLOBAL.user_id
      , SYSDATE
      , FND_GLOBAL.user_id
      , FND_GLOBAL.login_id
      , FND_GLOBAL.conc_request_id
      , FND_GLOBAL.prog_appl_id
      , FND_GLOBAL.conc_program_id
      , SYSDATE
      , l_sel_tab(l_current_sel_index).item_id
      , l_master_org_id
      );

      IF l_current_sel_index >= l_max_index THEN

        -- Update the records in the interface table with
        -- the values to copy from

        SELECT count(*)
        INTO l_count
        FROM mtl_item_values_temp
        WHERE item_update_id = p_seq_id;

        LOOP

          -- Update the records in the interface table with
          -- the values to copy from

          EXIT WHEN l_current_att_index = l_count;

          -- Establish if the value is to be updated with null

          IF l_att_tab(l_current_att_index).chosen_value IS NULL THEN
            -- Bug#2445587 fix: Copy item attribute should not copy item status to NULL
            -- column inventory_item_status_code not required to be assigned with !
            IF l_att_tab(l_current_att_index).item_column_name <> 'INVENTORY_ITEM_STATUS_CODE'
            THEN

               SELECT data_type
               INTO l_data_type
               FROM all_tab_columns
               WHERE table_name = 'MTL_SYSTEM_ITEMS_INTERFACE'
               AND owner = l_app_owner_schema
               AND column_name = upper(l_att_tab(l_current_att_index).item_column_name);

               IF l_data_type = 'NUMBER' THEN
                 UPDATE mtl_item_values_temp tmp
                 SET tmp.chosen_value = '-999999'
                 WHERE tmp.current_att_index = l_current_att_index
                 AND tmp.item_update_id = p_seq_id;
               ELSIF l_data_type = 'VARCHAR2' THEN
                 UPDATE mtl_item_values_temp tmp
                 SET tmp.chosen_value = '!'
                 WHERE tmp.current_att_index = l_current_att_index
                 AND tmp.item_update_id = p_seq_id;
               END IF;

            ELSE

              UPDATE mtl_item_values_temp tmp
              SET tmp.chosen_value = FND_PROFILE.VALUE('INV_STATUS_DEFAULT')
              WHERE tmp.current_att_index = l_current_att_index
              AND tmp.item_update_id = p_seq_id;
            END IF; -- inventory_item_status_code check

          END IF;

/*myerrams, Modified the following query to use bind variables. Bug: 5001785*/
          l_dml_str := 'UPDATE mtl_system_items_interface int SET (int.'
             || l_att_tab(l_current_att_index).item_column_name
             || ') = ('
             || ' SELECT tmp.chosen_value'
             || ' FROM mtl_item_values_temp tmp '
             || ' WHERE tmp.current_att_index = :1'
             || ' AND tmp.item_update_id = :2'
             || ') WHERE (int.set_process_id = :3'
             || ')';
          EXECUTE IMMEDIATE l_dml_str
	  USING l_current_att_index, p_seq_id, l_set_process_id;

          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
            , 'Update Complete'
            );
          END IF;

          l_current_att_index := l_current_att_index + 1;

          l_min_index := l_max_index + 1;
          IF l_sel_tab.COUNT > (l_max_index + l_max_batch_size) THEN
            l_max_index := l_max_index+l_max_batch_size;
          ELSE
            l_max_index := l_sel_tab.COUNT;
          END IF;

        END LOOP;

        Submit_Item_Update(l_sel_tab(l_current_sel_index).organization_id
                          ,l_set_process_id
                          ,l_workers_tbl
                          ,l_request_count);

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          , 'Submit done'
          );
        END IF;

        l_batch_size := 0;
        l_set_process_id := Get_Set_Process_ID;
        l_current_att_index := 0;

      END IF;

      EXIT WHEN l_current_sel_index = l_sel_tab.LAST;

      l_current_sel_index := l_current_sel_index + 1;

    END LOOP;

  END IF;

  Wait_For_All_Workers(p_workers  => l_workers_tbl);

  DELETE mtl_item_values_temp
  WHERE item_update_id = p_seq_id;

  DELETE mtl_update_records_temp
  WHERE item_update_id = p_seq_id;

  Determine_Return_Code
  ( x_retcode  => x_retcode
  , x_errbuff  => x_errbuff
  );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    ( INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
    , '< Batch Item Update'
    );
  END IF;

EXCEPTION
 WHEN g_submit_failure_exc THEN
   FND_MESSAGE.Set_Name('INV', 'INV_UNABLE_TO_SUBMIT_CONC');
   x_errbuff := SUBSTR(FND_MESSAGE.Get, 1, 255);
   x_retcode := RETCODE_ERROR;
 WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'batch_item_update'
                             );
    x_retcode := RETCODE_ERROR;
    x_errbuff := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
    END IF;

END batch_item_update;

--=========================================================================
-- PROCEDURE  : populate_temp_tables      PUBLIC
-- PARAMETERS :
-- COMMENT    : This procedure is called just before
--              the call to the concurrent program
--              which will update the item attributes.
--
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE populate_temp_tables
(p_att_tab IN  INV_ITEM_ATTRIBUTES_PKG.att_tbl_type
,x_seq_id  OUT NOCOPY NUMBER
)
IS

--=================
-- LOCAL VARIABLES
--=================

l_seq_id   NUMBER;
l_last     NUMBER;

BEGIN

  g_att_tab := p_att_tab;
  g_current_att_index := g_att_tab.FIRST;

  l_last := g_count - 1;

  -- generate the sequence id which will identify this update
  SELECT mtl_update_session_s.NEXTVAL INTO l_seq_id FROM dual;

  -- populate the item values temp table with the names and values
  -- of the attributes that need to be copied.
  -- This information can not be read directly from
  -- the MTL_ITEM_ATTRIBUTES_TEMP table as the attributes names
  -- have been assigned dynamically. for more please read the dld

  LOOP

    INSERT INTO mtl_item_values_temp(item_update_id
                                    ,item_column_name
                                    ,chosen_value
                                    ,current_att_index
                                    )
                              VALUES(l_seq_id
                                    ,g_att_tab(g_current_att_index).item_column_name
                                    ,g_att_tab(g_current_att_index).chosen_value
                                    ,g_current_att_index
                                    );

    EXIT WHEN g_current_att_index = l_last;

    g_current_att_index := g_att_tab.NEXT(g_current_att_index);

  END LOOP;

  -- populate the update records table with the organization id and the
  -- item id of all the records to be copied to.
  -- This information can be read directly from the table
  -- mtl_item_attributes_temp.

  INSERT into mtl_update_records_temp(
    item_update_id
   ,inventory_item_id
   ,organization_id)
  SELECT
    l_seq_id
   ,mia.item_id
   ,mia.organization_id
  FROM
    mtl_item_attributes_temp mia
  WHERE mia.checkbox = 'Y';

  -- return the sequence id
  x_seq_id := l_seq_id;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_INV_ITEM_ATTRIBUTES_PKG
                             , 'populate_temp_tables'
                             );
    END IF;
    RAISE;
END populate_temp_tables;

END INV_ITEM_ATTRIBUTES_PKG;

/
