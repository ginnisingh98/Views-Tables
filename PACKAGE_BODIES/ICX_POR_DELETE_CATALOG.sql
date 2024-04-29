--------------------------------------------------------
--  DDL for Package Body ICX_POR_DELETE_CATALOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_DELETE_CATALOG" AS
/* $Header: ICXDELCB.pls 115.7 2004/06/10 10:43:56 sosingha ship $*/


/**
 ** Global varibles
 **/
gReturnError	VARCHAR2(4000) := NULL;
gCommitSize	NUMBER := 2000;

-- ORA-01555: snapshot too old: rollback segment number  with name "" too small
snap_shot_too_old EXCEPTION;
PRAGMA EXCEPTION_INIT(snap_shot_too_old, -1555);

PROCEDURE setCommitSize(pCommitSize	IN PLS_INTEGER) IS
BEGIN
  gCommitSize := pCommitSize;
END setCommitSize;

/**
 ** Proc : delete_items_in_category
 ** Procedure called when a category is deleted from ecmanager.
 ** Desc : Deletes the items and prices in the category id specified
 **        Deletes the category related info from icx_cat_browse_trees,
 **        icx_por_category_data_sources, icx_por_category_order_map
 **/
PROCEDURE delete_items_in_category (
                                    errbuf            OUT NOCOPY VARCHAR2,
                                    retcode           OUT NOCOPY VARCHAR2,
                                    p_rt_category_id   IN NUMBER,
                                    p_category_key     IN VARCHAR2)
IS
BEGIN
   retcode := 0;
   errbuf := '';

   delete_items_in_category(p_rt_category_id, p_category_key);

EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SQLERRM;
      raise;
END delete_items_in_category;

/**
 ** Proc : delete_items_in_category
 ** Procedure called when a category is deleted from ecmanager.
 ** Desc : Deletes the items and prices in the category id specified
 **        Deletes the category related info from icx_cat_browse_trees,
 **        icx_por_category_data_sources, icx_por_category_order_map
 **/
PROCEDURE delete_items_in_category (p_rt_category_id        IN NUMBER,
                                    p_category_key          IN VARCHAR2)
IS
  --TYPE CursorType       IS REF CURSOR;
  --item_cursor           CursorType;

  CURSOR item_cursor(c_rt_category_id IN NUMBER) IS
   SELECT rt_item_id
   FROM   icx_cat_category_items
   WHERE  rt_category_id = c_rt_category_id;

  l_rt_item_ids         DBMS_SQL.NUMBER_TABLE;

  xCommitSize           PLS_INTEGER := 2000;
  xErrLoc               PLS_INTEGER := 0;
BEGIN

  -- Set Log level to NOLOG_LEVEL, so no log file will be generated for ECManager
  --ICX_POR_EXT_UTL.setDebugLevel(ICX_POR_EXT_UTL.NOLOG_LEVEL);

  -- Set commit size
  xErrLoc := 100;
  fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
  setCommitSize(xCommitSize);

  xErrLoc := 120;
  OPEN item_cursor(p_rt_category_id);

  xErrLoc := 150;
  LOOP
    xErrLoc := 200;
    BEGIN
    FETCH item_cursor
    BULK COLLECT INTO l_rt_item_ids
    LIMIT gCommitSize;

    EXIT WHEN l_rt_item_ids.COUNT = 0;

    xErrLoc := 240;
    deleteCommonTables(l_rt_item_ids, CATITEM_TABLE_LAST);
    commit;
    l_rt_item_ids.DELETE;

   xErrLoc := 300;
   EXCEPTION
      WHEN snap_shot_too_old THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'ORA-01555: snapshot too old: caught at '||
        'ICX_POR_DELETE_CATALOG.delete_items_in_category(' || xErrLoc|| ')'||     ', sqlerrm:' ||sqlerrm ||
        '; so close the cursor and reopen the cursor-');
        xErrLoc := 400;
        COMMIT;
        IF (item_cursor%ISOPEN) THEN
            xErrLoc := 500;
            CLOSE item_cursor;
            xErrLoc := 600;
            OPEN item_cursor(p_rt_category_id);
        END IF;
    END;
    END LOOP;

  xErrLoc := 700;
  deleteCategoryRelatedInfo(p_rt_category_id, p_category_key);
  commit;

  xErrLoc := 800;
  IF (item_cursor%ISOPEN) THEN
    CLOSE item_cursor;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    gReturnError := gReturnError ||
      'ICX_POR_DELETE_CATALOG.delete_items_in_category(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delete_items_in_category;

/**
 ** Proc : delete_items_in_catalog
 ** Desc : Deletes the items and prices in the catalog name specified
 **/
PROCEDURE delete_items_in_catalog (p_catalog_name        IN VARCHAR2)
IS
  --TYPE CursorType       IS REF CURSOR;
  --item_cursor           CursorType;

  CURSOR item_cursor(c_catalog_name IN VARCHAR2) IS
    SELECT rt_item_id
    FROM   icx_cat_items_b
    WHERE  catalog_name = c_catalog_name
    AND    extractor_updated_flag = 'N';

  l_rt_item_ids         DBMS_SQL.NUMBER_TABLE;

  xCommitSize           PLS_INTEGER := 2000;
  xErrLoc               PLS_INTEGER := 0;
BEGIN

  -- Set Log level to NOLOG_LEVEL, so no log file will be generated for ECManager
  --ICX_POR_EXT_UTL.setDebugLevel(ICX_POR_EXT_UTL.NOLOG_LEVEL);

  -- Set commit size
  xErrLoc := 100;
  fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
  setCommitSize(xCommitSize);

  xErrLoc := 120;
  open item_cursor(p_catalog_name);

  xErrLoc := 150;
  LOOP
    xErrLoc := 200;
    BEGIN
    FETCH item_cursor
    BULK COLLECT INTO l_rt_item_ids
    LIMIT gCommitSize;

    EXIT WHEN l_rt_item_ids.COUNT = 0;

    xErrLoc := 240;
    deleteCommonTables(l_rt_item_ids);
    commit;
    l_rt_item_ids.DELETE;

    xErrLoc := 400;
    EXCEPTION
      WHEN snap_shot_too_old THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'ORA-01555: snapshot too old: caught at '||
      'ICX_POR_DELETE_CATALOG.delete_items_in_catalog(' || xErrLoc|| ')'||
      ', sqlerrm:' ||sqlerrm ||
      '; so close the cursor and reopen the cursor-');
      xErrLoc := 500;
      COMMIT;
      IF (item_cursor%ISOPEN) THEN
          xErrLoc := 600;
          CLOSE item_cursor;
          xErrLoc := 700;
          OPEN item_cursor(p_catalog_name);
      END IF;
    END;

  END LOOP;

  IF (item_cursor%ISOPEN) THEN
     CLOSE item_cursor;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    gReturnError := gReturnError ||
      'ICX_POR_DELETE_CATALOG.delete_items_in_catalog(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delete_items_in_catalog;

/**
 ** Proc : delete_supplier_catalog_opUnit
 ** Desc : Deletes the catalog for the supplier and Operating Unit specified.
 **/
PROCEDURE delete_supplier_catalog_opUnit (p_supplier IN VARCHAR2,
                                          p_operating_unit_id IN NUMBER DEFAULT -2)
IS
  --TYPE CursorType	IS REF CURSOR;
  --item_cursor		CursorType;

  CURSOR item_cursor(c_supplier IN VARCHAR2,
                     c_operating_unit_id IN NUMBER) IS
    SELECT rt_item_id
    FROM   icx_cat_items_b
    WHERE  supplier = c_supplier
    AND    org_id = c_operating_unit_id
    AND    extractor_updated_flag = 'N';

  l_rt_item_ids		DBMS_SQL.NUMBER_TABLE;

  xCommitSize		PLS_INTEGER := 2000;
  xErrLoc 	    	PLS_INTEGER := 0;
BEGIN

  -- Set Log level to NOLOG_LEVEL, so no log file will be generated for ECManager
  --ICX_POR_EXT_UTL.setDebugLevel(ICX_POR_EXT_UTL.NOLOG_LEVEL);

  -- Set commit size
  xErrLoc := 100;
  fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
  setCommitSize(xCommitSize);

  xErrLoc := 120;
  OPEN item_cursor(p_supplier, p_operating_unit_id);

  xErrLoc := 150;
  LOOP
    xErrLoc := 200;
    BEGIN
    FETCH item_cursor
    BULK COLLECT INTO l_rt_item_ids
    LIMIT gCommitSize;

    EXIT WHEN l_rt_item_ids.COUNT = 0;

    xErrLoc := 240;
    deleteCommonTables(l_rt_item_ids);
    commit;
    l_rt_item_ids.DELETE;

   xErrLoc := 400;
   EXCEPTION
     WHEN snap_shot_too_old THEN
       ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
       'ORA-01555: snapshot too old: caught at '||
       'ICX_POR_DELETE_CATALOG.delete_supplier_catalog_opUnit(' || xErrLoc|| ')'||     ', sqlerrm:' ||sqlerrm ||
       '; so close the cursor and reopen the cursor-');
       xErrLoc := 500;
       COMMIT;
       IF (item_cursor%ISOPEN) THEN
           xErrLoc := 600;
           CLOSE item_cursor;
           xErrLoc := 700;
           OPEN item_cursor(p_supplier, p_operating_unit_id);
       END IF;
   END;

   END LOOP;
   IF (item_cursor%ISOPEN) THEN
       CLOSE item_cursor;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    gReturnError := gReturnError ||
      'ICX_POR_DELETE_CATALOG.delete_supplier_catalog_opUnit(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delete_supplier_catalog_opUnit;

/**
 ** Proc : delPriceHistory
 ** Desc : Deletes the data from ICX_CAT_PRICE_HISTORY
 **/
PROCEDURE delPriceHistory(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_PRICE_HISTORY');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_price_history
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delPriceHistory-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delPriceHistory(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delPriceHistory;

/**
 ** Proc : delItemsTLP
 ** Desc : Deletes the data from ICX_CAT_ITEMS_TLP
 **/
PROCEDURE delItemsTLP(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_ITEMS_TLP');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_items_tlp
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delItemsTLP(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delItemsTLP;

/**
 ** Proc : delExtItemsTLP
 ** Desc : Deletes the data from ICX_CAT_EXT_ITEMS_TLP
 **/
PROCEDURE delExtItemsTLP(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_EXT_ITEMS_TLP');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_ext_items_tlp
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delExtItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delExtItemsTLP(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delExtItemsTLP;

/**
 ** Proc : delItemsCtxTLP
 ** Desc : Deletes the data from ICX_CAT_ITEMS_CTX_TLP
 **/
PROCEDURE delItemsCtxTLP(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_ITEMS_CTX_TLP');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_items_ctx_tlp
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delItemsCtxTLP-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delItemsCtxTLP(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delItemsCtxTLP;

/**
 ** Proc : delFavoriteList
 ** Desc : Deletes the data from POR_FAVORITE_LIST_LINES
 **/
PROCEDURE delFavoriteList(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from POR_FAVORITE_LIST_LINES');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM por_favorite_list_lines
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delFavoriteList-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delFavoriteList(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delFavoriteList;

/**
 ** Proc : delCategoryItems
 ** Desc : Deletes the data from ICX_CAT_CATEGORY_ITEMS
 **/
PROCEDURE delCategoryItems(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_CATEGORY_ITEMS');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_category_items
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize ;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delCategoryItems-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delCategoryItems(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delCategoryItems;

/**
 ** Proc : delPriceLists
 ** Desc : Deletes the data from ICX_CAT_PRICE_LISTS
 **/
PROCEDURE delPriceLists(pPriceListIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_PRICE_LISTS');
  xErrLoc := 100;
  FORALL i IN 1..pPriceListIds.COUNT
    DELETE FROM icx_cat_price_lists pl
    WHERE  pl.price_list_id = pPriceListIds(i)
    AND    NOT EXISTS (SELECT 'price line'
                       FROM   icx_cat_item_prices p
                       WHERE  p.price_list_id = pl.price_list_id);
  xErrLoc := 200;
  ICX_POR_EXT_UTL.extCommit;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delPriceLists-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('Index: '|| SQL%ROWCOUNT+1);
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delPriceLists(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delPriceLists;

/**
 ** Proc : delItemPrices
 ** Desc : Deletes the data from ICX_CAT_ITEM_PRICES
 **/
PROCEDURE delItemPrices(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;
  xPriceListIds	DBMS_SQL.NUMBER_TABLE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_ITEM_PRICES');
  xErrLoc := 100;
  WHILE xContinue LOOP
    xPriceListIds.DELETE;

    xErrLoc := 140;
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_item_prices
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize
      RETURNING price_list_id BULK COLLECT INTO xPriceListIds;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;

    xErrLoc := 300;
    delPriceLists(xPriceListIds);
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delItemPrices-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delItemPrices(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delItemPrices;

/**
 ** Proc : delItemsB
 ** Desc : Deletes the data from ICX_CAT_ITEMS_B
 **/
PROCEDURE delItemsB(pRtItemIds	IN DBMS_SQL.NUMBER_TABLE)
IS
  xErrLoc	PLS_INTEGER := 0;
  xContinue	BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_ITEMS_B');
  xErrLoc := 100;
  WHILE xContinue LOOP
    FORALL i IN 1..pRtItemIds.COUNT
      DELETE FROM icx_cat_items_b
      WHERE  rt_item_id = pRtItemIds(i)
      AND    rownum <= gCommitSize;

    xErrLoc := 200;
    ICX_POR_EXT_UTL.extCommit;
    IF ( SQL%ROWCOUNT < gCommitSize ) THEN
       xContinue := FALSE;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_DELETE_CATALOG.delItemsB-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError('pRtItemIds('||SQL%ROWCOUNT+1||'): '||
      pRtItemIds(SQL%ROWCOUNT+1));
    ICX_POR_EXT_UTL.extRollback;
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.delItemsB(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END delItemsB;

/**
 ** Proc : deleteCommonTables
 ** Desc : Deletes the data from common tables used by Extractor and DeleteCatalog
 **/
PROCEDURE deleteCommonTables(pRtItemIds 	IN dbms_sql.number_table,
                             pDeleteOrder 	IN PLS_INTEGER DEFAULT ITEM_TABLE_LAST)
IS
  xErrLoc PLS_INTEGER := 0;

BEGIN
  xErrLoc := 100;
  delPriceHistory(pRtItemIds);
  xErrLoc := 120;
  delItemsTLP(pRtItemIds);
  xErrLoc := 140;
  delExtItemsTLP(pRtItemIds);
  xErrLoc := 160;
  delItemsCtxTLP(pRtItemIds);
  xErrLoc := 180;
  delFavoriteList(pRtItemIds);

  -- Based on pDeleteOrder, we have to delete ICX_CAT_ITEMS_B
  -- before ICX_CAT_CATEGORY_ITEMS, or the other way.
  -- The reason: if pRtItemIds is seleced based on ICX_CAT_ITEMS_B,
  -- we have to delete ICX_CAT_ITEMS_B last, otherwise if exception
  -- happens, next time we won't get correct pRtItemIds, which would
  -- cause data corruption. Same reason for ICX_CAT_CATEGORY_ITEMS.
  IF (pDeleteOrder = ITEM_TABLE_LAST) THEN
    xErrLoc := 200;
    delCategoryItems(pRtItemIds);
    xErrLoc := 240;
    delItemPrices(pRtItemIds);
    xErrLoc := 260;
    delItemsB(pRtItemIds);
  ELSIF (pDeleteOrder = CATITEM_TABLE_LAST) THEN
    xErrLoc := 300;
    delItemPrices(pRtItemIds);
    xErrLoc := 340;
    delItemsB(pRtItemIds);
    xErrLoc := 360;
    delCategoryItems(pRtItemIds);
  END IF;

  xErrLoc := 400;
  ICX_POR_EXT_UTL.extAFCommit;

EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.extRollback;

    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.deleteCommonTables(' ||
      xErrLoc||'): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END deleteCommonTables;

/**
 ** Proc : deleteCategoryRelatedInfo
 ** Desc : Deletes the data from ICX_CAT_BROWSE_TREES,
 **        ICX_POR_CATEGORY_ORDER_MAP, ICX_POR_CATEGORY_DATA_SOURCES
 **/
PROCEDURE deleteCategoryRelatedInfo(pRtCategoryId  IN NUMBER,
                                    pCategoryKey   IN VARCHAR2)
IS
  xErrLoc       PLS_INTEGER := 0;
  xContinue     BOOLEAN := TRUE;

BEGIN
  ICX_POR_EXT_UTL.debug('Delete from ICX_CAT_BROWSE_TREES');
  --Delete the item category from browse trees if it existed in any toc.
  xErrLoc := 100;
  DELETE FROM icx_cat_browse_trees
  WHERE  child_category_id = pRtCategoryId;

  ICX_POR_EXT_UTL.debug('Delete from ICX_POR_CATEGORY_ORDER_MAP');
  --Delete the mapping for the item category.
  xErrLoc := 200;
  DELETE FROM icx_por_category_order_map
  WHERE  rt_category_id = pRtCategoryId;

  ICX_POR_EXT_UTL.debug('Delete from ICX_POR_CATEGORY_DATA_SOURCES');
  --Delete the mapping for the item category.
  xErrLoc := 300;
  DELETE FROM icx_por_category_data_sources
  WHERE  category_key = pCategoryKey;

EXCEPTION
  WHEN OTHERS THEN
    gReturnError := gReturnError || 'ICX_POR_DELETE_CATALOG.deleteCategoryRelatedInfo(' ||
      xErrLoc|| '): '||sqlerrm;
    raise_application_error(-20000,gReturnError);
END deleteCategoryRelatedInfo;

END ICX_POR_DELETE_CATALOG;

/
