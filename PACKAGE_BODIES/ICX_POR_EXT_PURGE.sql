--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXT_PURGE" AS
/* $Header: ICXEXTPB.pls 120.1 2006/01/10 12:01:03 sbgeorge noship $*/

--------------------------------------------------------------
--                     Type and Cursor                      --
--------------------------------------------------------------

TYPE tClassification IS RECORD (
  rt_category_id	NUMBER,
  key			ICX_CAT_CATEGORIES_TL.KEY%TYPE,
  type			NUMBER);

TYPE tClassCursorType	IS REF CURSOR;

TYPE tItem IS RECORD (
  rt_item_id		NUMBER);

TYPE tItemCursorType	IS REF CURSOR;

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------
gRtCategoryIds		DBMS_SQL.NUMBER_TABLE;
gCategoryKeys		DBMS_SQL.VARCHAR2_TABLE;
gCategoryTypes		DBMS_SQL.NUMBER_TABLE;
gRtItemIds 		DBMS_SQL.NUMBER_TABLE;

gCompletedCount		PLS_INTEGER := 0;

-- Bug 2001770
gExceptionOccured	BOOLEAN := FALSE;
gRestartTime 		PLS_INTEGER := 0;

--------------------------------------------------------------
--                   Global PL/SQL Tables                   --
--------------------------------------------------------------

PROCEDURE clearTables(pMode	IN VARCHAR2) IS
BEGIN
  IF (pMode IN ('ALL', 'CLASS')) THEN
    gRtCategoryIds.DELETE;
    gCategoryKeys.DELETE;
    gCategoryTypes.DELETE;
  END IF;

  IF (pMode IN ('ALL', 'ITEM')) THEN
    gRtItemIds.DELETE;
  END IF;
END;

--------------------------------------------------------------
--                        Snap Shots                        --
--------------------------------------------------------------

FUNCTION snapShot(pIndex	IN PLS_INTEGER,
		  pMode		IN VARCHAR2) RETURN varchar2 IS
  xShot varchar2(2000) := 'SnapShot('||pMode||')['||pIndex||']--';
BEGIN
  IF (pMode = 'CLASS') THEN
    xShot := xShot || ' gRtCategoryIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gRtCategoryIds, pIndex) || ',';
    xShot := xShot || ' gCategoryKeys: ' ||
      ICX_POR_EXT_UTL.getTableElement(gCategoryKeys, pIndex) || ',';
    xShot := xShot || ' gCategoryTypes: ' ||
      ICX_POR_EXT_UTL.getTableElement(gCategoryTypes, pIndex);
  ELSIF (pMode = 'ITEM') THEN
    xShot := xShot || ' gRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gRtItemIds, pIndex);
  END IF;

  RETURN xShot;
END snapShot;

--------------------------------------------------------------
--                    Delete Procedures                     --
--------------------------------------------------------------

-- Delete categories
PROCEDURE deleteCategories IS

  CURSOR cCatItems(p_rt_category_id	IN NUMBER) IS
    SELECT rt_item_id
    FROM   icx_cat_category_items
    WHERE  rt_category_id = p_rt_category_id;

  xRtItemIds	DBMS_SQL.NUMBER_TABLE;
  xErrLoc	PLS_INTEGER := 100;

BEGIN

  IF (gCategoryKeys.COUNT = 0) THEN
    RETURN;
  END IF;

  IF (ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gCategoryKeys.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, 'CLASS'));
    END LOOP;
  END IF;

  xErrLoc := 100;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Delete from ICX_POR_CATEGORY_DATA_SOURCES');
  END IF;
  FORALL i IN 1..gCategoryKeys.COUNT
    DELETE FROM icx_por_category_data_sources
    WHERE  category_key = gCategoryKeys(i)
    AND    external_source = 'Oracle';

  ICX_POR_EXT_UTL.extCommit;

  xErrLoc := 200;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Delete from ICX_POR_CATEGORY_ORDER_MAP');
  END IF;
  FORALL i IN 1..gRtCategoryIds.COUNT
    DELETE FROM icx_por_category_order_map
    WHERE  rt_category_id = gRtCategoryIds(i)
    AND    external_source = 'Oracle';

  ICX_POR_EXT_UTL.extCommit;

  xErrLoc := 300;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Delete from ICX_POR_TABLE_OF_CONTENTS_TL');
  END IF;
  FORALL i IN 1..gRtCategoryIds.COUNT
    DELETE FROM icx_por_table_of_contents_tl
    WHERE child = gRtCategoryIds(i);

  ICX_POR_EXT_UTL.extCommit;

  xErrLoc := 400;
  FOR i IN 1..gRtCategoryIds.COUNT LOOP

    xErrLoc := 410;
    OPEN cCatItems(gRtCategoryIds(i));

    LOOP
      xErrLoc := 420;
      xRtItemIds.DELETE;

      xErrLoc := 430;
      FETCH cCatItems
      BULK  COLLECT INTO xRtItemIds
      LIMIT ICX_POR_EXT_UTL.gCommitSize;
      EXIT  WHEN xRtItemIds.COUNT = 0;

      -- For Category, need also delete all assoicated item records
      -- For Template Header, only delete that category_item association
      IF (gCategoryTypes(i) = ICX_POR_EXT_CLASS.CATEGORY_TYPE) THEN

        xErrLoc := 440;
        ICX_POR_DELETE_CATALOG.setCommitSize(ICX_POR_EXT_UTL.gCommitSize);
        xErrLoc := 445;
        ICX_POR_DELETE_CATALOG.deleteCommonTables(xRtItemIds,
          ICX_POR_DELETE_CATALOG.CATITEM_TABLE_LAST);

      ELSIF (gCategoryTypes(i) = ICX_POR_EXT_CLASS.TEMPLATE_HEADER_TYPE) THEN

        xErrLoc := 450;
        IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
          ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_CATEGORY_ITEMS');
        END IF;
        FORALL j IN 1..xRtItemIds.COUNT
          DELETE FROM icx_cat_category_items
          WHERE  rt_item_id = xRtItemIds(j)
          AND    rt_category_id = gRtCategoryIds(i);

      END IF;

      xErrLoc := 460;
      ICX_POR_EXT_UTL.extCommit;

    END LOOP;

    xErrLoc := 480;
    CLOSE cCatItems;

  END LOOP;

  xErrLoc := 500;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_CATEGORIES_TL');
  END IF;
  FORALL i IN 1..gRtCategoryIds.COUNT
    DELETE FROM icx_cat_categories_tl
    WHERE  rt_category_id = gRtCategoryIds(i);

  xErrLoc := 600;
  ICX_POR_EXT_UTL.extAFCommit;

  xErrLoc := 700;
  clearTables('CLASS');
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.deleteCategories-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, 'CLASS'));

    ICX_POR_EXT_UTL.extRollback;

    IF (cCatItems%ISOPEN) THEN
      CLOSE cCatItems;
    END IF;

    raise ICX_POR_EXT_UTL.gException;
END deleteCategories;

-- Delete Items
procedure deleteItems IS

  xErrLoc       PLS_INTEGER := 100;

BEGIN
  IF (gRtItemIds.COUNT = 0) THEN
    RETURN;
  END IF;

  if (ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL) then
    FOR i in 1..gRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, 'ITEM'));
    END LOOP;
  end if;

  xErrLoc := 200;
  ICX_POR_DELETE_CATALOG.setCommitSize(ICX_POR_EXT_UTL.gCommitSize);

  xErrLoc := 300;
  ICX_POR_DELETE_CATALOG.deleteCommonTables(gRtItemIds,
    ICX_POR_DELETE_CATALOG.ITEM_TABLE_LAST);

  xErrLoc := 500;
  clearTables('ITEM');
exception
  when others then
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.deleteItems-'||
      xErrLoc||' '||SQLERRM);

    raise ICX_POR_EXT_UTL.gException;
end deleteItems;

-- Process batch data
PROCEDURE processBatchData(pType	IN VARCHAR2,
			   pMode	IN VARCHAR2) IS
  xErrLoc	PLS_INTEGER := 100;
  x_return_err	varchar2(2000);

BEGIN
  xErrLoc := 100;

  IF (pType = 'CLASS' AND
      (pMode = 'OUTLOOP' OR
       gRtCategoryIds.COUNT >= ICX_POR_EXT_UTL.gCommitSize))
  THEN
    xErrLoc := 200;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch category purge -- Pending[' ||
        gRtCategoryIds.COUNT || '], Completed[' || gCompletedCount || ']');

    gCompletedCount := gCompletedCount + gRtCategoryIds.COUNT;
    deleteCategories;
  END IF;

  xErrLoc := 300;
  IF (pType = 'ITEM' AND
      (pMode = 'OUTLOOP' OR
       gRtItemIds.COUNT >= ICX_POR_EXT_UTL.gCommitSize))
  THEN
    xErrLoc := 400;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch item purge -- Pending[' ||
        gRtItemIds.COUNT || '], Completed[' || gCompletedCount || ']');

    gCompletedCount := gCompletedCount + gRtItemIds.COUNT;
    deleteItems;
  END IF;

  xErrLoc := 500;
EXCEPTION
  when OTHERS then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.processBatchData-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END processBatchData;

--------------------------------------------------------------
--               Purge Classfication Data                   --
--------------------------------------------------------------
-- Open classification cursor
PROCEDURE openClassCursor(pMode		IN PLS_INTEGER,
                          pInvCatId 	IN NUMBER,
			  pCursor	IN OUT NOCOPY tClassCursorType)
IS
  xCategorySetId	NUMBER;
  xValidateFlag		VARCHAR2(1);
  xStructureId		NUMBER;
  xString 		VARCHAR2(4000);
  xErrLoc		PLS_INTEGER := 100;

BEGIN
  xErrLoc := 100;

  IF (pMode = NORMAL_MODE) THEN
    xErrLoc := 200;
    -- get category set info
    SELECT category_set_id,
           validate_flag,
           structure_id
    INTO   xCategorySetId,
           xValidateFlag,
           xStructureId
    FROM   mtl_default_sets_view
    WHERE  functional_area_id = 2;

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Category Set Information[category_set_id: ' || xCategorySetId ||
      ', validate_flag: ' || xValidateFlag ||
      ', structure_id: ' || xStructureId || ']');

    xErrLoc := 210;
    xString :=
      'SELECT cat.rt_category_id, cat.key, cat.type ' ||
      'FROM   icx_cat_categories_tl cat ' ||
      'WHERE  title = ''Oracle'' ' ||
      'AND    language = ''' || ICX_POR_EXTRACTOR.gBaseLang || ''' ' ||
      'AND    ((type = '||ICX_POR_EXT_CLASS.TEMPLATE_HEADER_TYPE||' AND '||
      '         NOT EXISTS (SELECT ''active template header'' ';

    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'FROM ipo_reqexpress_headers_all templ ';
    ELSE
      xString := xString ||
        'FROM po_reqexpress_headers_all templ ';
    END IF;

    xString := xString ||
      'WHERE templ.express_name||''_tmpl'' = cat.key ' ||
      'AND (NVL(inactive_date,SYSDATE+1)>SYSDATE))) OR ' ||
      '     (type = '||ICX_POR_EXT_CLASS.CATEGORY_TYPE||' AND '||
      '      NOT EXISTS (SELECT ''active oracle category'' ';

    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'FROM imtl_categories_kfv mck ';
    ELSE
      xString := xString ||
        'FROM mtl_categories_kfv mck ';
    END IF;

    IF (xValidateFlag = 'Y') THEN
      xErrLoc := 220;
      IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
        xString := xString ||
          ', imtl_category_set_valid_cats mcsvc ';
      ELSE
        xString := xString ||
          ', mtl_category_set_valid_cats mcsvc ';
      END IF;
      xString := xString ||
        'WHERE mcsvc.category_set_id = :category_set_id ' ||
        'AND    mcsvc.category_id = TO_NUMBER(cat.key) ' ||
        'AND    mcsvc.category_id = mck.category_id ';
    ELSE
      xErrLoc := 240;
      xString := xString ||
        'WHERE mck.category_id = TO_NUMBER(cat.key) ';
    END IF;

    xErrLoc := 260;
    xString := xString ||
      'AND mck.structure_id = :structure_id ' ||
      'AND mck.web_status = ''Y'' ' ||
      'AND NVL(mck.start_date_active,SYSDATE)<=SYSDATE ' ||
      'AND SYSDATE<NVL(mck.end_date_active,SYSDATE+1) ' ||
      'AND SYSDATE<NVL(mck.disable_date,SYSDATE+1)))) ';

    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'AND cat.last_updated_by = '||ICX_POR_EXT_TEST.TEST_USER_ID;
    END IF;

    xErrLoc := 270;
    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
        'Query for category purge: ' || xString);
    END IF;

    IF xValidateFlag = 'Y' THEN
      xErrLoc := 280;
      OPEN pCursor FOR xString USING xCategorySetId,xStructureId;
    ELSE
      xErrLoc := 290;
      OPEN pCursor FOR xString USING xStructureId;
    END IF;

  ELSIF (pMode = ALL_MODE) THEN
    xErrLoc := 300;
    OPEN pCursor FOR
      SELECT cat.rt_category_id, cat.key, cat.type
      FROM   icx_cat_categories_tl cat
      WHERE  cat.title = 'Oracle'
      AND    cat.language = ICX_POR_EXTRACTOR.gBaseLang
      AND    NOT EXISTS (SELECT 'Bulkloaded items'
                         FROM   icx_cat_items_b i,
                                icx_cat_category_items ci
                         WHERE  ci.rt_category_id = cat.rt_category_id
                         AND    ci.rt_item_id = i.rt_item_id
                         AND    NVL(i.extractor_updated_flag, 'N') = 'N');
  ELSIF (pMode = CATEGORY_MODE) THEN
    xErrLoc := 300;
    OPEN pCursor FOR
      SELECT cat.rt_category_id, cat.key, cat.type
      FROM   icx_cat_categories_tl cat
      WHERE  cat.title = 'Oracle'
      AND    cat.language = ICX_POR_EXTRACTOR.gBaseLang
      AND    key = to_char(pInvCatId)
      AND    NOT EXISTS (SELECT 'Bulkloaded items'
                         FROM   icx_cat_items_b i,
                                icx_cat_category_items ci
                         WHERE  ci.rt_category_id = cat.rt_category_id
                         AND    ci.rt_item_id = i.rt_item_id
                         AND    NVL(i.extractor_updated_flag, 'N') = 'N');

  END IF;

  xErrLoc := 500;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.openClassCursor-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END openClassCursor;

-- Main procedure to purge classification data
PROCEDURE purgeClassificationData(pMode     IN PLS_INTEGER,
                                  pInvCatId IN NUMBER)
IS

  xRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
  xKeys			DBMS_SQL.VARCHAR2_TABLE;
  xTypes		DBMS_SQL.NUMBER_TABLE;

  xErrLoc		PLS_INTEGER := 100;
  cClass		tClassCursorType;

  xPendingCount		PLS_INTEGER := 0;

BEGIN
  xErrLoc := 100;
  gCompletedCount := 0;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Purge oracle classification data');

  xErrLoc := 120;
  openClassCursor(pMode, pInvCatId, cClass);

  xErrLoc := 140;

  clearTables('CLASS');

  LOOP
    xErrLoc := 200;

    xRtCategoryIds.DELETE;
    xKeys.DELETE;
    xTypes.DELETE;

    IF (ICX_POR_EXT_UTL.getDatabaseVersion < 9.0) THEN
      xErrLoc := 150;
      EXIT WHEN cClass%NOTFOUND;
      -- Oracle 8i doesn't support BULK Collect from dynamic SQL
      FOR i IN 1..ICX_POR_EXT_UTL.gCommitSize LOOP
        FETCH cClass
        INTO  xRtCategoryIds(i), xKeys(i), xTypes(i);
        EXIT WHEN cClass%NOTFOUND;
      END LOOP;
    ELSE
      xErrLoc := 200;
      FETCH cClass
      BULK  COLLECT INTO xRtCategoryIds, xKeys, xTypes
      LIMIT ICX_POR_EXT_UTL.gCommitSize;
      EXIT  WHEN xRtCategoryIds.COUNT = 0;
    END IF;

    xErrLoc := 240;
    FOR i IN 1..xRtCategoryIds.COUNT LOOP
      IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
          'Classification[rt_category_id: '|| xRtCategoryIds(i) ||
          ', key: '|| xKeys(i) || ', type: '|| xTypes(i) ||']');
      END IF;

      xErrLoc := 300;
      xPendingCount := gRtCategoryIds.COUNT + 1;
      gRtCategoryIds(xPendingCount) := xRtCategoryIds(i);
      gCategoryKeys(xPendingCount)  := xKeys(i);
      gCategoryTypes(xPendingCount) := xTypes(i);

    END LOOP;

    xErrLoc := 500;
    -- move classification data
    processBatchData('CLASS', 'INLOOP');

  END LOOP;

  xErrLoc := 600;
  -- process remaining
  processBatchData('CLASS', 'OUTLOOP');

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Total deleted categories: ' || gCompletedCount);

  xErrLoc := 700;
  CLOSE cClass;

  xErrLoc := 900;
  gRestartTime := 0;
  gExceptionOccured := false;

EXCEPTION
  when ICX_POR_EXT_UTL.gException then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.purgeClassificationData-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  when others then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.purgeClassificationData-'||
      xErrLoc||' '||SQLERRM);

    -- Bug 2001770
    -- handle exception ORA-01555: snapshot too old: rollback segment
    -- number 9 with name "RBS08" too small
    if (SQLCODE = -01555) then
      if (gRestartTime < 3) then
       gRestartTime := gRestartTime + 1;
       ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
         'Restart ICX_POR_EXT_PURGE.purgeClassificationData ' ||
         gRestartTime || ' times');
       gExceptionOccured := true;
       -- Bug 2305219, zxzhang, 05/06/2002
       -- purgeClassificationData;
       purgeClassificationData(pMode, pInvCatId);
     else
       ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
         'Restart ICX_POR_EXT_PURGE.purgeClassificationData too many times');
       raise ICX_POR_EXT_UTL.gException;
     end if;
   else
     raise ICX_POR_EXT_UTL.gException;
   end if;

END purgeClassificationData;

--------------------------------------------------------------
--                     Purge Item Data                      --
--------------------------------------------------------------
-- Open item cursor
PROCEDURE openItemCursor(pMode		IN PLS_INTEGER,
                         pInvCatItemId 	IN NUMBER,
                         pType		IN VARCHAR2,
			 pCursor	IN OUT NOCOPY tItemCursorType)
IS
  xErrLoc		PLS_INTEGER := 100;
  xString 		VARCHAR2(4000);

BEGIN
  xErrLoc := 100;

  IF (pMode = NORMAL_MODE) THEN
    xErrLoc := 200;

    IF (pType = 'DELETED_ITEMS') THEN
      xErrLoc := 240;
      xString :=
        'SELECT i.rt_item_id ' ||
        'FROM   icx_cat_items_b i ' ||
        'WHERE  i.extractor_updated_flag = ''Y'' ' ||
        'AND    i.internal_item_id is not null ';

      IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
        xString := xString ||
          'AND i.last_updated_by = '||ICX_POR_EXT_TEST.TEST_USER_ID||' ';
      END IF;

      xString := xString ||
        'AND NOT EXISTS (SELECT ''item deleted from item master'' ';
      IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
        xString := xString ||
          'FROM imtl_system_items_kfv m, '||
          'ifinancials_system_params_all fsp ';
      ELSE
        xString := xString ||
          'FROM mtl_system_items_kfv m, ' ||
          'financials_system_params_all fsp ';
      END IF;
      xString := xString ||
        'WHERE m.inventory_item_id = i.internal_item_id ' ||
        'AND i.org_id = fsp.org_id ' ||
        'AND fsp.inventory_organization_id = m.organization_id) ';

    ELSIF (pType = 'INVALID_CATGORY_ITEMS') THEN
      xErrLoc := 260;
      xString :=
        'SELECT i.rt_item_id ' ||
        'FROM   icx_cat_items_b i, ' ||
         'icx_cat_item_prices p1 ' ||
        'WHERE  i.extractor_updated_flag = ''Y'' ' ||
        'AND    i.internal_item_id is not null ';

      IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
        xString := xString ||
          'AND i.last_updated_by = '||ICX_POR_EXT_TEST.TEST_USER_ID||' ';
      END IF;

      xString := xString ||
      -- Check for invalid item category association
        'AND i.rt_item_id = p1.rt_item_id  ' ||
	'AND NOT((p1.contract_line_id <> -2) OR (p1.template_line_id <> -2)) ' ||
        'AND NOT EXISTS (SELECT ''Invalid item category association'' ';
      IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
        xString := xString ||
          'FROM imtl_item_categories m, '||
          'ifinancials_system_params_all fsp, ';
      ELSE
        xString := xString ||
          'FROM mtl_item_categories m, ' ||
          'financials_system_params_all fsp, ';
      END IF;
      xString := xString ||
        'icx_cat_item_prices p ' ||
        'WHERE i.rt_item_id = p.rt_item_id ' ||
        'AND m.category_id = p.mtl_category_id ' ||
        'AND m.inventory_item_id = i.internal_item_id ' ||
        'AND i.org_id = fsp.org_id ' ||
        'AND fsp.inventory_organization_id = m.organization_id) ';
    END IF;

    xErrLoc := 270;
    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
        'Query for item purge: ' || xString);
    END IF;

    xErrLoc := 280;
    OPEN pCursor FOR xString;

  ELSIF (pMode = ALL_MODE) THEN
    xErrLoc := 300;
    OPEN pCursor FOR
      SELECT i.rt_item_id
      FROM   icx_cat_items_b i
      WHERE  i.extractor_updated_flag = 'Y';

  ELSIF (pMode = CATEGORY_MODE) THEN
    xErrLoc := 400;
    OPEN pCursor FOR
      SELECT distinct i.rt_item_id
      FROM   icx_cat_items_b i,
             icx_cat_item_prices p
      WHERE  p.mtl_category_id = pInvCatItemId
      AND    p.rt_item_id = i.rt_item_id
      AND    i.extractor_updated_flag = 'Y';

  ELSIF (pMode = ITEM_MODE) THEN
    xErrLoc := 500;
    OPEN pCursor FOR
      SELECT i.rt_item_id
      FROM   icx_cat_items_b i
      WHERE  i.internal_item_id = pInvCatItemId
      AND    i.extractor_updated_flag = 'Y';

  END IF;

  xErrLoc := 600;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.openItemCursor-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END openItemCursor;

-- Process item records
PROCEDURE processItemRecords(pCursor	IN tItemCursorType)
IS
  xRtItemIds		DBMS_SQL.NUMBER_TABLE;

  xErrLoc		PLS_INTEGER := 100;
  xPendingCount		PLS_INTEGER := 0;

BEGIN
  xErrLoc := 100;
  clearTables('ITEM');

  LOOP
    xErrLoc := 200;

    xRtItemIds.DELETE;

    IF (ICX_POR_EXT_UTL.getDatabaseVersion < 9.0) THEN
      xErrLoc := 150;
      EXIT WHEN pCursor%NOTFOUND;
      -- Oracle 8i doesn't support BULK Collect from dynamic SQL
      FOR i IN 1..ICX_POR_EXT_UTL.gCommitSize LOOP
        FETCH pCursor
        INTO  xRtItemIds(i);
        EXIT WHEN pCursor%NOTFOUND;
      END LOOP;
    ELSE
      xErrLoc := 200;
      FETCH pCursor
      BULK  COLLECT INTO xRtItemIds
      LIMIT ICX_POR_EXT_UTL.gCommitSize;
      EXIT  WHEN xRtItemIds.COUNT = 0;
    END IF;

    xErrLoc := 240;
    FOR i IN 1..xRtItemIds.COUNT LOOP
      IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
          'Item[rt_item_id: '|| xRtItemIds(i) || ']');
      END IF;

      xErrLoc := 300;
      xPendingCount := gRtItemIds.COUNT + 1;
      gRtItemIds(xPendingCount) := xRtItemIds(i);

    END LOOP;

    xErrLoc := 500;
    -- process item data
    processBatchData('ITEM', 'INLOOP');

  END LOOP;

  xErrLoc := 600;
  -- process remaining
  processBatchData('ITEM', 'OUTLOOP');

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Total deleted items: ' || gCompletedCount);

  xErrLoc := 700;

EXCEPTION
  when others then
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.processItemRecords-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END processItemRecords;

-- Main procedure to purge classification data
PROCEDURE purgeItemData (pMode 		    IN PLS_INTEGER,
                         pInvCatItemId 	    IN NUMBER)
IS

  xRtItemIds		DBMS_SQL.NUMBER_TABLE;
  xPriceRowIds		DBMS_SQL.UROWID_TABLE;
  xMtlCategoryIds	DBMS_SQL.NUMBER_TABLE;

  xErrLoc		PLS_INTEGER := 100;
  cItem			tItemCursorType;

  xPendingCount		PLS_INTEGER := 0;

BEGIN
  xErrLoc := 100;
  gCompletedCount := 0;

  IF (pMode = NORMAL_MODE) THEN

    xErrLoc := 120;
    openItemCursor(pMode, pInvCatItemId, 'DELETED_ITEMS', cItem);

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Purge items deleted from item masters');

    xErrLoc := 140;
    processItemRecords(cItem);

    CLOSE cItem;

    xErrLoc := 160;
    openItemCursor(pMode, pInvCatItemId, 'INVALID_CATGORY_ITEMS', cItem);

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Purge items with invalid association in MTL_ITEM_CATEGORIES');

    xErrLoc := 180;
    processItemRecords(cItem);

    CLOSE cItem;

  ELSE

    xErrLoc := 200;
    openItemCursor(pMode, pInvCatItemId, NULL, cItem);

    xErrLoc := 220;
    processItemRecords(cItem);

    CLOSE cItem;
  END IF;

  gRestartTime := 0;
  gExceptionOccured := false;

  xErrLoc := 300;
  ICX_POR_EXT_ITEM.cleanupPrices;
EXCEPTION
  WHEN ICX_POR_EXT_UTL.gException THEN
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.purgeItemData-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_PURGE.purgeItemData-'||
      xErrLoc||' '||SQLERRM);

    -- Bug 2001770
    -- handle exception ORA-01555: snapshot too old: rollback segment
    -- number 9 with name "RBS08" too small
    if (SQLCODE = -01555) then
      if (gRestartTime < 3) then
       gRestartTime := gRestartTime + 1;
       ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
         'Restart ICX_POR_EXT_PURGE.purgeItemData ' ||
         gRestartTime || ' times');
       gExceptionOccured := true;

       purgeItemData(pMode, pInvCatItemId);
     else
       ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
         'Restart ICX_POR_EXT_PURGE.purgeItemData too many times');
       raise ICX_POR_EXT_UTL.gException;
     end if;
   else
     raise ICX_POR_EXT_UTL.gException;
   end if;

END purgeItemData;

END ICX_POR_EXT_PURGE;

/
