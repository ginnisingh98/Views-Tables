--------------------------------------------------------
--  DDL for Package Body ICX_POR_CTX_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_CTX_DESC" AS
-- $Header: ICXCGCDB.pls 115.22 2004/07/14 13:17:41 sosingha ship $

-- Previous releases of iProcurement had p_rebuildAll meaning, to rebuild
-- ctx column for all language or just the language for which item was
-- loaded. Eitherway the rebuild always happened. With just one ctx column
-- with this release, the p_rebuildAll is not useful. Always rebuild the
-- ctx_desc column to be backward compatible with the scripts that had
-- been released with calls to populateCtxDescAll!
--
-- The populateCtxDescAll is called only from Extractor and ECManager, in both
-- cases the log type is concurrent, hence the default value is "CONCURRENT".
--
PROCEDURE populateCtxDescAll(p_jobno IN INTEGER DEFAULT 0,
                             p_rebuildAll in VARCHAR2 DEFAULT 'Y',
                             p_log_type in VARCHAR2 DEFAULT 'CONCURRENT') IS
    xErrLoc         INTEGER := 0;  -- execution location for error trapping
    items_tl_cv     item_source_cv_type;
    items_tl_csr    item_source_cv_type;

    vRowids  dbms_sql.urowid_table;
BEGIN
    xErrLoc := 100;

    IF (p_jobno <= 0) THEN
      populateDescAll(p_log_type);
    ELSE
      OPEN items_tl_cv for
        SELECT tl.rowid, tl.rt_item_id, tl.language
        FROM icx_cat_items_tlp tl
        WHERE tl.request_id = p_jobno;

      xErrLoc := 300;
      populateCtxDescBaseAtt(items_tl_cv,'Y', 'Y', NULL, 'ROWID', 'CONCURRENT');
      xErrLoc := 330;
      CLOSE items_tl_cv;

      xErrLoc := 350;
      OPEN items_tl_cv for
          SELECT tl.rowid, tl.rt_item_id, tl.language
          FROM icx_cat_items_tlp tl
          WHERE tl.request_id = p_jobno;

      xErrLoc := 400;
      populateCtxDescBuyerInfo(items_tl_cv, 'Y', 'Y', null, 'ROWID', 'CONCURRENT');
      xErrLoc := 500;
      CLOSE items_tl_cv;

      xErrLoc := 600;
      populateCategoryAttribsByJob(p_jobno, 'N', 'N', 'CONCURRENT');

      xErrLoc := 700;

      -- Update the icx_cat_items_tlp.ctx_desc column so that rebuild index
      -- will pick up the changes. Master table index column need to be
      -- updated in order for the detail table changes to be effective
      OPEN items_tl_csr for
        SELECT rowid FROM icx_cat_items_tlp
        where request_id = p_jobno;

      xErrLoc := 720;

      --Debugging
      icx_por_ext_utl.debug('about to update icx_cat_items_tlp.ctx_desc');
      xErrLoc := 730;
      LOOP
        FETCH items_tl_csr BULK COLLECT INTO
          vRowids
        LIMIT BATCH_SIZE;

        EXIT WHEN vRowids.COUNT = 0;
        xErrLoc := 750;

        FORALL i IN 1..vRowids.COUNT
          UPDATE ICX_CAT_ITEMS_TLP
          SET CTX_DESC = null
          WHERE rowid = vRowids(i);

        xErrLoc := 800;

        --Bug#2849869: added due to the 8i issue.
        IF (vRowids.COUNT < BATCH_SIZE) THEN
          EXIT;
        END IF;
        xErrLoc := 900;

      END LOOP;
      xErrLoc := 910;
      --Debugging
      icx_por_ext_utl.debug('done updating icx_cat_items_tlp.ctx_desc');
      xErrLoc := 920;

      CLOSE items_tl_csr;

      xErrLoc := 930;
      --Debugging
      icx_por_ext_utl.debug('start to rebuild index');
      xErrLoc := 940;
      -- rebuild the intermedia or context indexes
      ICX_POR_INTERMEDIA_INDEX.rebuild_index;
      xErrLoc := 1000;
      --Debugging
      icx_por_ext_utl.debug('rebuild index done');
    END IF;
    xErrLoc := 1010;

EXCEPTION
    WHEN OTHERS THEN
      icx_por_ext_utl.debug(icx_por_ext_utl.DEBUG_LEVEL,
		'Exception at ICX_POR_CTX_DESC.populateCtxDescAll('||
                xErrLoc || '), ' || SQLERRM);
      rollback;
      ICX_POR_EXT_UTL.printStackTrace;
      ICX_POR_EXT_UTL.closeLog;

    IF items_tl_cv%ISOPEN THEN
        CLOSE items_tl_cv;
    END IF;

        RAISE_APPLICATION_ERROR (-20000,
        'Exception at ICX_POR_CTX_DESC.populateCtxDescAll('||xErrLoc|| '), '||SQLERRM );
END populateCtxDescAll;

PROCEDURE populateDescAll(errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY VARCHAR2,
                          p_log_type in VARCHAR2 DEFAULT 'CONCURRENT')
IS
BEGIN
  populateDescAll(p_log_type);
END;

PROCEDURE populateDescAll(p_log_type in VARCHAR2 DEFAULT 'CONCURRENT')
IS
v_sql varchar2(255);
BEGIN
   --Debugging added icx_por_ext_utl.debug
   v_sql :=  'truncate table '|| ICX_POR_EXT_UTL.getIcxSchema ||'.icx_cat_items_ctx_tlp';
   icx_por_ext_utl.debug('populateDescAll, about to truncate icx_cat_items_ctx_tlp');
   EXECUTE IMMEDIATE v_sql;
   icx_por_ext_utl.debug('populateDescAll, icx_cat_items_ctx_tlp truncated ');

   ICX_POR_INTERMEDIA_INDEX.drop_index;
   icx_por_ext_utl.debug('populateDescAll, drop_index done ');

   populateBaseAttributes('N', 'N', p_log_type);
   icx_por_ext_utl.debug('populateDescAll, populateBaseAttributes done ');

   populateBuyerInfo('N','N', p_log_type);
   icx_por_ext_utl.debug('populateDescAll, populateBuyerInfo done ');

   populateCategoryAttributes('N', 'N', p_log_type);
   icx_por_ext_utl.debug('populateDescAll, populateCategoryAttributes done ');

   ICX_POR_INTERMEDIA_INDEX.create_index;
   icx_por_ext_utl.debug('populateDescAll, create_index done ');

   -- disable the intermedia index concurrent program once it has been run successfully
   -- we will use FND API FND_PROGRAM.ENABLE_PROGRAM for achieving the same
   icx_por_ext_utl.debug('populateDescAll, disabling intermedia index concurrent program to prevent re-run');
   fnd_program.enable_program('ICXCICRI', 'ICX', 'N');
   icx_por_ext_utl.debug('populateDescAll, intermedia index concurrent program disabled ');

END;

/*
** -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
** Procedure : populateBaseAttributes
** Synopsis  : Update the ctx_<lang> for all the items in a given job.
** ActionPlan: 1. Collect root descriptors and local descriptors from
**	          cursors defined above.
**	       2. Concatenate all from 1 into a 'allSelectList' and
**	       3. Update ctx_<lang> in icx_cat_items_ctx_tlp with 2 .
**             4. Update ctx_desc in icx_cat_items_tlp with null : Bug#3329169
** -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
*/

PROCEDURE populateBaseAttributes(pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y', p_log_type IN VARCHAR2 DEFAULT 'LOADER')
IS

   xErrLoc         PLS_INTEGER := 0;
   getItemsTlCur   item_source_cv_type;

   -- Bug # 3329169
   items_tl_csr    item_source_cv_type;
   vRowids  dbms_sql.urowid_table;

BEGIN
   xErrLoc := 100;

   --Debugging
   --icx_por_track_validate_job_s.log('populateBaseAttributes', p_log_type);

   OPEN getItemsTlCur FOR
      SELECT rowid,rt_item_id,language
      FROM icx_cat_items_tlp;

   xErrLoc := 200;

   populateCtxDescBaseAtt(getItemsTlCur, pDeleteYN, pUpdateYN, NULL, 'ROWID', p_log_type);
   xErrLoc := 230;

   CLOSE getItemsTlCur;

   xErrLoc := 300;
   -- Bug#3329169
   -- Update the icx_cat_items_tlp.ctx_desc column so that rebuild index
   -- will pick up the changes. Master table index column need to be
   -- updated in order for the detail table changes to be effective
   OPEN items_tl_csr FOR
     SELECT rowid FROM icx_cat_items_tlp;

   xErrLoc := 320;
   LOOP
     FETCH items_tl_csr BULK COLLECT INTO
       vRowids
     LIMIT BATCH_SIZE;
     EXIT WHEN vRowids.COUNT = 0;

     xErrLoc := 340;
     FORALL i IN 1..vRowids.COUNT
       UPDATE ICX_CAT_ITEMS_TLP
       SET CTX_DESC = null
       WHERE rowid = vRowids(i);

     xErrLoc := 360;
     IF (vRowids.COUNT < BATCH_SIZE) THEN
       EXIT;
     END IF;
   END LOOP;

   xErrLoc := 380;
   CLOSE items_tl_csr;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

  IF getItemsTlCur%ISOPEN THEN
      CLOSE getItemsTlCur;
  END IF;

  IF items_tl_csr%ISOPEN THEN
      CLOSE items_tl_csr;
  END IF;

  RAISE_APPLICATION_ERROR (-20000,
    'Exception at ICX_POR_CTX_DESC.populateBaseAttributes('||xErrLoc|| '), '||SQLERRM );

END populateBaseAttributes;

PROCEDURE populateCategoryAttribsByJob( pJobNum IN INTEGER DEFAULT 0,
  pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y',
  p_log_type IN VARCHAR2 DEFAULT 'LOADER')
IS

    vCategoryId     INTEGER := 0;
    vLang           FND_LANGUAGES.language_code%TYPE;
    xErrLoc         PLS_INTEGER;
    vItemSourceCursor NUMBER;
    vSqlString      VARCHAR2(4000);


    -- Get all the categories for a given language
    -- that has atleast one searchable attribute
    -- and has atleast one item loaded by the given job.

    CURSOR getCatWithSearchCur(p_lang IN VARCHAR2, p_jobNum IN INTEGER) is
      SELECT cat.rt_category_id
      FROM icx_cat_categories_tl cat
      WHERE cat.language = p_lang
        AND cat.rt_category_id <> 0
        AND cat.type = 2
        AND exists (select 'X'
                    from icx_cat_descriptors_tl des
                    where des.rt_category_id = cat.rt_category_id
                      and des.language = cat.language
                      and des.searchable = 1)
        AND exists (select 'X'
                    from icx_cat_category_items cit, icx_cat_items_b it
                    where cit.rt_category_id = cat.rt_category_id
                    and   cit.rt_item_id = it.rt_item_id
                    and   it.request_id = p_jobNum);
BEGIN
    xErrLoc:=100;

    --Debugging
    --icx_por_track_validate_job_s.log('populateCategoryAttribsByJob', p_log_type);
    --Debugging
    icx_por_ext_utl.debug('start of populateCategoryAttribsByJob');
    xErrLoc := 110;

    BEGIN
        SELECT language_code
        INTO vLang
        FROM fnd_languages
        WHERE installed_flag = 'B';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vLang := 'US';
    END;

    -- For Category Attributes
    -- Loop thru the Category Cursor and get the Insert and Update Tables
    xErrLoc:=200;
    FOR catRec in getCatWithSearchCur(vLang, pJobNum)
    LOOP
        vCategoryId := catRec.rt_category_id;
        vItemSourceCursor := DBMS_SQL.OPEN_CURSOR;
        xErrLoc := 220;
        -- OEX_IP_PORTING
        vSqlString := 'SELECT tlp.rowid,tlp.rt_item_id,tlp.language FROM ICX_CAT_EXT_ITEMS_TLP tlp, icx_cat_items_b it where tlp.rt_category_id = :category_id and it.rt_item_id=tlp.rt_item_id and it.request_id=:request_id';
        xErrLoc := 230;
        DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
        xErrLoc := 235;
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':category_id',vCategoryId);
        xErrLoc := 240;
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':request_id',pJobNum);
        xErrLoc := 245;
        populateCtxDescCatAtt(vCategoryId, vItemSourceCursor,pDeleteYN,
                                pUpdateYN, NULL, 'ROWID', p_log_type);
        xErrLoc:=260;
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
        xErrLoc:=280;
    END LOOP;
    xErrLoc:=300;
    --Debugging
    icx_por_ext_utl.debug('populateCategoryAttribsByJob done');
    xErrLoc := 1001;
 EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF (DBMS_SQL.IS_OPEN(vItemSourceCursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
    END IF;

    RAISE_APPLICATION_ERROR (-20000,
      'Exception at ICX_POR_CTX_DESC.populateCategoryAttribsByJob('||xErrLoc|| '), catId: ' || vCategoryId || ' Error: ' ||SQLERRM );
END populateCategoryAttribsByJob;

PROCEDURE populateCategoryAttributes( pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y',
  p_log_type IN VARCHAR2 DEFAULT 'LOADER')
IS

    vCategoryId     INTEGER := 0;
    vLang           FND_LANGUAGES.language_code%TYPE;
    xErrLoc         PLS_INTEGER;
    vItemSourceCursor NUMBER;
    vSqlString      VARCHAR2(4000);

    -- Get all the categories for a given language
    -- that has atleast one searchable attribute
    -- and has atleast one item classified under it

    CURSOR getCatWithSearchCur(p_lang IN VARCHAR2) is
      SELECT cat.rt_category_id
      FROM icx_cat_categories_tl cat
      WHERE cat.language = p_lang
        AND cat.rt_category_id <> 0
        AND cat.type = 2
        AND exists (select 'X'
                    from icx_cat_descriptors_tl des
                    where des.rt_category_id = cat.rt_category_id
                      and des.language = cat.language
                      and des.searchable = 1)
        AND exists (select 'X'
                    from icx_cat_category_items cit
                    where cit.rt_category_id = cat.rt_category_id);
BEGIN
    xErrLoc:=100;
    --Debugging
    icx_por_ext_utl.debug('start of populateCategoryAttributes ');
    xErrLoc := 101;
    BEGIN
        SELECT language_code
        INTO vLang
        FROM fnd_languages
        WHERE installed_flag = 'B';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            vLang := 'US';
    END;

    -- For Category Attributes
    -- Loop thru the Category Cursor and get the Insert and Update Tables
    xErrLoc:=200;
    FOR catRec in getCatWithSearchCur(vLang)
    LOOP
        vCategoryId := catRec.rt_category_id;
        vItemSourceCursor := DBMS_SQL.OPEN_CURSOR;
        xErrLoc := 220;
        -- OEX_IP_PORTING
        -- Add "and rt_item_id = :rt_item_ids". Bind array of the
        -- item ids table
        vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_CAT_EXT_ITEMS_TLP where rt_category_id = :category_id';
        xErrLoc := 230;
        DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
        xErrLoc := 235;
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':category_id',vCategoryId);
        xErrLoc := 240;
        populateCtxDescCatAtt(vCategoryId, vItemSourceCursor,pDeleteYN,
                                pUpdateYN, NULL, 'ROWID', p_log_type);
        xErrLoc:=260;
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
        xErrLoc:=280;
    END LOOP;
    xErrLoc:=300;
    --Debugging
    icx_por_ext_utl.debug('populateCategoryAttributes done');
    xErrLoc := 1001;
 EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF (DBMS_SQL.IS_OPEN(vItemSourceCursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
    END IF;

    RAISE_APPLICATION_ERROR (-20000,
      'Exception at ICX_POR_CTX_DESC.populateCategoryAttributes('||xErrLoc|| '), catId: ' || vCategoryId || ' Error: ' ||SQLERRM );
END populateCategoryAttributes;

/* The calling procedure is responsible for opening and closing the cursor*/
PROCEDURE populateCtxDescBaseAtt(pItemSourceCv IN item_source_cv_type,
                                 pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                                 pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                                 pLanguage IN VARCHAR2 DEFAULT NULL,
                                 pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                                 p_log_type IN VARCHAR2 DEFAULT 'LOADER') IS
    xErrLoc         INTEGER := 0;  -- execution location for error trapping
    vInsertSqlTab   ICX_POR_CTX_SQL_PKG.SQLTab;
    vUpdateSqlTab   ICX_POR_CTX_SQL_PKG.SQLTab;
    vRowidTab       DBMS_SQL.UROWID_TABLE;
    vItemIdTab      DBMS_SQL.NUMBER_TABLE;
    vLangTab        DBMS_SQL.VARCHAR2_TABLE;
    c_handle        NUMBER ;
    c_status        PLS_INTEGER;
    vSqlString      VARCHAR2(4000);
    p_lang          VARCHAR2(10) := NULL;

BEGIN

    xErrLoc := 0;
    --Debugging
    icx_por_ext_utl.debug('start to process populateCtxDescBaseAtt');
    xErrLoc := 10;
    IF (pSourceType = 'ROWID') THEN
        ICX_POR_CTX_SQL_PKG.build_ctx_sql(0,
            ICX_POR_CTX_SQL_PKG.ROWID_WHERE_CLAUSE, pLanguage, vInsertSqlTab, vUpdateSqlTab);
    ElSE
        ICX_POR_CTX_SQL_PKG.build_ctx_sql(0,
            ICX_POR_CTX_SQL_PKG.ITEMID_WHERE_CLAUSE, pLanguage, vInsertSqlTab, vUpdateSqlTab);
    END IF;

    xErrLoc := 15;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescBaseAtt, vUpdateSqlTab count:' ||
                           to_char(vUpdateSqlTab.COUNT) );

    xErrLoc := 11;

    LOOP
        vRowidTab.DELETE;
        vItemIdTab.DELETE;
        vLangTab.DELETE;

	xErrLoc := 100;
        IF (pSourceType = 'ROWID') THEN
            FETCH pItemSourceCv BULK COLLECT INTO vRowidTab,vItemIdTab,vLangTab LIMIT BATCH_SIZE;
        ELSE
            FETCH pItemSourceCv BULK COLLECT INTO vItemIdTab,vLangTab LIMIT BATCH_SIZE;
        END IF;

        xErrLoc := 110;
        --Debugging
        icx_por_ext_utl.debug('populateCtxDescBaseAtt, vItemIdTab count:' ||
                               to_char(vItemIdTab.COUNT) );

	xErrLoc := 200;
        IF vItemIdTab.COUNT = 0 THEN
            EXIT;
        END IF;

	xErrLoc := 300;

        -- delete exisiting rows from icx_cat_items_ctx_tlp
        IF (pDeleteYN = 'Y') THEN
            FORALL i in 1..vItemIdTab.COUNT
              DELETE FROM icx_cat_items_ctx_tlp
              WHERE rt_item_id = vItemIdTab(i)
              AND language = vLangTab(i)
              AND (sequence < 5000 OR sequence = 10000 OR sequence = 15000);
        END IF;

	xErrLoc := 400;
        -- SqlTab Loop
        FOR i in 1..vUpdateSqlTab.COUNT LOOP
            xErrLoc := xErrLoc + 10;
            vSqlString := vUpdateSqlTab(i);
            c_handle:=DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(c_handle, vSqlString, DBMS_SQL.NATIVE);

            IF (i = vUpdateSqlTab.COUNT - 1) THEN
              -- This is the <orgid> line
              DBMS_SQL.BIND_VARIABLE(c_handle,':p_sequence',10000);
            ELSIF (i = vUpdateSqlTab.COUNT) THEN
              -- This is the </orgid> line
              DBMS_SQL.BIND_VARIABLE(c_handle,':p_sequence',15000);
            ELSE
              DBMS_SQL.BIND_VARIABLE(c_handle,':p_sequence',i);
            END IF;

            DBMS_SQL.BIND_VARIABLE(c_handle,':action_name','SYNC');
            DBMS_SQL.BIND_VARIABLE(c_handle,':p_system_action','SYNC');

            IF (pSourceType = 'ROWID') THEN
                DBMS_SQL.BIND_ARRAY(c_handle,':p_rowid',vRowidTab);
            ELSE
                DBMS_SQL.BIND_ARRAY(c_handle,':p_item_id',vItemIdTab);
            END IF;

            IF (NOT pLanguage IS NULL) THEN
                DBMS_SQL.BIND_VARIABLE(c_handle,':p_language',pLanguage);
                DBMS_SQL.BIND_ARRAY(c_handle, ':language_array', vLangTab);
                DBMS_SQL.BIND_VARIABLE(c_handle,':p_language_section','<lang>'||pLanguage||'</lang>');
            END IF;

            c_status := DBMS_SQL.EXECUTE(c_handle);
            DBMS_SQL.CLOSE_CURSOR(c_handle);
            xErrLoc := xErrLoc + 10;
        END LOOP; -- SqlTab Loop

	xErrLoc := 500;

        COMMIT;
    END LOOP;
    xErrLoc := 1001;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescBaseAtt done');
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF (DBMS_SQL.IS_OPEN(c_handle)) THEN
        DBMS_SQL.CLOSE_CURSOR(c_handle);
      END IF;

	RAISE_APPLICATION_ERROR (-20000,
	'Exception at ICX_POR_CTX_DESC.populateCtxDescBaseAtt('||xErrLoc||
	'), '||SQLERRM );
END populateCtxDescBaseAtt;

/* The calling procedure is responsible for opening and closing the cursor.
   pSourceType = 'ITEMID' doesn't work properly now.
*/
PROCEDURE populateCtxDescCatAtt(pCategoryId IN NUMBER,
                                 pItemSourceCursor IN NUMBER,
                                 pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                                 pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                                 pLanguage IN VARCHAR2 DEFAULT NULL,
                                 pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                                 p_log_type IN VARCHAR2 DEFAULT 'LOADER')
IS
    p_lang          VARCHAR2(10) := NULL;
    vCInsertSqlTab  ICX_POR_CTX_SQL_PKG.SQLTab;
    vCUpdateSqlTab  ICX_POR_CTX_SQL_PKG.SQLTab;
    vCRowidTab      DBMS_SQL.UROWID_TABLE;
    vCLangTab       DBMS_SQL.VARCHAR2_TABLE;
    vCItemIdTab     DBMS_SQL.NUMBER_TABLE;
    c_handle        NUMBER;
    c_status        PLS_INTEGER;
    vSqlString      VARCHAR2(4000);
    vTableName      VARCHAR2(100);
    vIndex          NUMBER:=1;
    vCStatus        NUMBER;
    xErrLoc         PLS_INTEGER;
BEGIN
    xErrLoc := 100;
    --Debugging
    icx_por_ext_utl.debug('start of populateCtxDescCatAtt for pCategoryId:' ||
                           to_char(pCategoryId) );
    xErrLoc := 101;
    vCInsertSqlTab.DELETE;
    vCUpdateSqlTab.DELETE;

    xErrLoc := 110;
    IF(pSourceType = 'ROWID') THEN
        xErrLoc := 120;
        ICX_POR_CTX_SQL_PKG.build_ctx_sql(pCategoryId,
            ICX_POR_CTX_SQL_PKG.ROWID_WHERE_CLAUSE, pLanguage,
            vCInsertSqlTab, vCUpdateSqlTab);
        xErrLoc := 140;
    ELSE
        xErrLoc := 160;
        ICX_POR_CTX_SQL_PKG.build_ctx_sql(pCategoryId,
            ICX_POR_CTX_SQL_PKG.ITEMID_WHERE_CLAUSE, pLanguage,
            vCInsertSqlTab, vCUpdateSqlTab);
        xErrLoc := 180;
    END IF;

    xErrLoc := 190;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescCatAtt, vCUpdateSqlTab count:' ||
                           to_char(vCUpdateSqlTab.COUNT) );


        -----------------------------------------------------------------------
        -- Build a cursor with the category ID added the SQL
        -- Define PL/SQL tables that will hold the value fetched
        -----------------------------------------------------------------------
        --vCursor := DBMS_SQL.OPEN_CURSOR;
        --DBMS_SQL.PARSE(vCursor,'SELECT rowid,rt_item_id,language FROM '||
        --    vTableName, DBMS_SQL.NATIVE);
    xErrLoc := 200;
     IF(pSourceType = 'ROWID') THEN
        xErrLoc := 220;
        DBMS_SQL.DEFINE_ARRAY(pItemSourceCursor,1,vCRowidTab,BATCH_SIZE,vIndex);
        DBMS_SQL.DEFINE_ARRAY(pItemSourceCursor,2,vCItemIdTab,BATCH_SIZE,vIndex);
        DBMS_SQL.DEFINE_ARRAY(pItemSourceCursor,3,vCLangTab,BATCH_SIZE,vIndex);
        xErrLoc := 240;
     ELSE
        xErrLoc := 260;
        DBMS_SQL.DEFINE_ARRAY(pItemSourceCursor,1,vCItemIdTab,BATCH_SIZE,vIndex);
        DBMS_SQL.DEFINE_ARRAY(pItemSourceCursor,2,vCLangTab,BATCH_SIZE,vIndex);
        xErrLoc := 280;
     END IF;

     xErrLoc := 300;
     vCStatus := DBMS_SQL.EXECUTE(pItemSourceCursor);
        -----------------------------------------------------------------------
        -- Loop thru the cursor
        -- FETCH_ROWS will fetch the next set of rows and fill the PL/SQL tables
        -- Loop thru the UpdateSQL tab and for each sql
        -- Bind in the values from the PL/SQL tables
        -----------------------------------------------------------------------

     xErrLoc := 400;
     LOOP

        vCStatus := DBMS_SQL.FETCH_ROWS(pItemSourceCursor);
        IF(pSourceType = 'ROWID') THEN
            DBMS_SQL.COLUMN_VALUE(pItemSourceCursor,1,vCRowidTab);
            DBMS_SQL.COLUMN_VALUE(pItemSourceCursor,2,vCItemIdTab);
            DBMS_SQL.COLUMN_VALUE(pItemSourceCursor,3,vCLangTab);
        ELSE
            DBMS_SQL.COLUMN_VALUE(pItemSourceCursor,1,vCItemIdTab);
            DBMS_SQL.COLUMN_VALUE(pItemSourceCursor,2,vCLangTab);
        END IF;

        xErrLoc := 310;
        --Debugging
        icx_por_ext_utl.debug('populateCtxDescCatAtt, vCItemIdTab count:' ||
                               to_char(vCItemIdTab.COUNT) );

        xErrLoc := 320;
        IF (vCItemIdTab.COUNT = 0) THEN
            EXIT;
        END IF;
        xErrLoc := 500;
        IF (pDeleteYN = 'Y') THEN
                -- Delete the rows for the categories
                xErrLoc := xErrLoc + 10;
                -- dbms_sql.column_value will keep incrementing the indexes of the
                -- pl/sql tables, so need to use FIRST..LAST instead of 1..COUNT
                FORALL i IN vCItemIdTab.FIRST..vCItemIdTab.LAST
                DELETE FROM icx_cat_items_ctx_tlp
                WHERE rt_item_id = vCItemIdTab(i)
                AND sequence >= 5000
                AND sequence < 10000
                AND language = vCLangTab(i);
        END IF;

        xErrLoc := 600;
        FOR i in 1..vCUpdateSqlTab.COUNT LOOP
                xErrLoc := xErrLoc + 10;
                vSqlString := vCUpdateSqlTab(i);
                c_handle:=DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(c_handle, vSqlString, DBMS_SQL.NATIVE);
                DBMS_SQL.BIND_VARIABLE(c_handle, ':p_sequence',i+5000);
                DBMS_SQL.BIND_VARIABLE(c_handle,':current_category_id',pCategoryId);
                DBMS_SQL.BIND_VARIABLE(c_handle,':p_category_id',pCategoryId);
                DBMS_SQL.BIND_VARIABLE(c_handle, ':action_name','SYNC');
                DBMS_SQL.BIND_VARIABLE(c_handle, ':p_system_action','SYNC');
            IF(pSourceType = 'ROWID') THEN
                DBMS_SQL.BIND_ARRAY(c_handle, ':p_rowid',vCRowidTab);
            ELSE
                DBMS_SQL.BIND_ARRAY(c_handle, ':p_item_id',vCItemIdTab);
            END IF;

            IF (NOT pLanguage IS NULL) THEN
                DBMS_SQL.BIND_VARIABLE(c_handle,':p_language',pLanguage);
                DBMS_SQL.BIND_ARRAY(c_handle, ':language_array', vCLangTab);
                DBMS_SQL.BIND_VARIABLE(c_handle,':p_language_section','<lang>'||pLanguage||'</lang>');
            END IF;

            c_status := DBMS_SQL.EXECUTE(c_handle);
            DBMS_SQL.CLOSE_CURSOR(c_handle);
        END LOOP;

        xErrLoc := 700;
        IF (pUpdateYN = 'Y') THEN
            IF(pLanguage IS NULL) THEN
                FOR language_row IN installed_languages_cur LOOP
                    p_lang := language_row.language_code;

                    vSqlString := 'UPDATE icx_cat_items_tlp SET ctx_desc ' ||
                    ' = ''1'' WHERE rt_item_id = :p_item_id AND '||
                    ':curr_lang = :p_lang AND language = :p_lang';

                    c_handle := DBMS_SQL.OPEN_CURSOR;
                    DBMS_SQL.PARSE(c_handle, vSqlString, DBMS_SQL.NATIVE);
                    DBMS_SQL.BIND_ARRAY(c_handle, ':p_item_id', vCItemIdTab);
                    DBMS_SQL.BIND_VARIABLE(c_handle, ':curr_lang', p_lang);
                    DBMS_SQL.BIND_ARRAY(c_handle, ':p_lang', vCLangTab);
                    c_status := DBMS_SQL.EXECUTE(c_handle);
                    DBMS_SQL.CLOSE_CURSOR(c_handle);
                END LOOP;
            ELSE
                vSqlString := 'UPDATE icx_cat_items_tlp SET ctx_desc ' ||
                    ' = ''1'' WHERE rt_item_id = :p_item_id AND '||
                    'language = :p_lang';

                    c_handle := DBMS_SQL.OPEN_CURSOR;
                    DBMS_SQL.PARSE(c_handle, vSqlString, DBMS_SQL.NATIVE);
                    DBMS_SQL.BIND_ARRAY(c_handle, ':p_item_id', vCItemIdTab);
                    DBMS_SQL.BIND_VARIABLE(c_handle, ':p_lang', pLanguage);
                    c_status := DBMS_SQL.EXECUTE(c_handle);
                    DBMS_SQL.CLOSE_CURSOR(c_handle);
            END IF;
        END IF;

        xErrLoc := 800;
            COMMIT;
            vCRowidTab.DELETE;
            vCLangTab.DELETE;
            vCItemIdTab.DELETE;
            EXIT when vCStatus <> BATCH_SIZE;
    END LOOP;
    xErrLoc := 1001;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescCatAtt done');

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF (DBMS_SQL.IS_OPEN(c_handle)) THEN
        DBMS_SQL.CLOSE_CURSOR(c_handle);
      END IF;

      RAISE_APPLICATION_ERROR (-20000,
	'Exception at ICX_POR_CTX_DESC.populateCtxDescCatAtt('||xErrLoc||
	'), '||SQLERRM );
END populateCtxDescCatAtt;
/*
** -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
** Procedure : populateCtxDescLang
** Synopsis  : Update the ctx_<lang> for one item in a Lang.
** This is called from Item.insert() and Item.update().
*/

PROCEDURE populateCtxDescLang(p_item_id IN NUMBER,
			      p_category_id IN NUMBER,
			      p_lang IN VARCHAR2 DEFAULT NULL,
                              p_log_type IN VARCHAR2 DEFAULT 'LOADER') IS

    xErrLoc         PLS_INTEGER := 0;  -- execution location for error trapping
    vItemSourceCv   item_source_cv_type;
    vItemSourceCursor NUMBER;
    vSqlString      VARCHAR2(4000);
    vCatTableExists PLS_INTEGER:=0;
    vSearchableExists PLS_INTEGER:=0;
BEGIN

    xErrLoc := 11;
    --Debugging
    icx_por_ext_utl.debug('start of populateCtxDescLang for itemId:' ||
                           to_char(p_item_id) ||', categoryId:' ||
                           to_char(p_category_id) ||', lang:' ||p_lang);
    xErrLoc := 12;

    populateCtxDescBaseAtt(vItemSourceCv, 'Y', 'Y', NULL, 'ITEMID', 'LOADER');

    -- base attributes
    xErrLoc := 100;
    OPEN vItemSourceCv FOR
      	SELECT rowid,rt_item_id, language
      	FROM ICX_CAT_ITEMS_TLP
	WHERE RT_ITEM_ID= p_item_id;
    xErrLoc := 200;

    IF (p_lang is NULL) THEN -- update item
        xErrLoc := 220;
	    populateCtxDescBaseAtt(vItemSourceCv, 'Y', 'N', NULL, 'ROWID', p_log_type);
        xErrLoc := 240;
    ELSE -- create new item, no need to delete or update
        xErrLoc := 260;
	    populateCtxDescBaseAtt(vItemSourceCv, 'N', 'N', p_lang, 'ROWID', p_log_type);
        xErrLoc := 280;
    END IF;

    xErrLoc := 300;
    CLOSE vItemSourceCv;

    -- category attributes
    xErrLoc := 400;
    vItemSourceCursor := DBMS_SQL.OPEN_CURSOR;
    xErrLoc := 450;

    IF (p_lang is NULL) THEN -- update item
        xErrLoc := 500;
        BEGIN
            SELECT 1
            INTO vCatTableExists
            FROM DUAL
            WHERE EXISTS
                (SELECT 1
                FROM ICX_CAT_DESCRIPTORS_TL
                WHERE RT_CATEGORY_ID=p_category_id
                AND CLASS = 'POM_CAT_ATTR');
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        xErrLoc := 520;
        -- OEX_IP_PORTING
        IF(vCatTableExists = 1) THEN
            vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_CAT_EXT_ITEMS_TLP' ||
                    ' WHERE rt_item_id=:item_id and rt_category_id=:category_id';
        ELSE
            vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_CAT_ITEMS_TLP' ||
                    ' WHERE rt_item_id=:item_id';
        END IF;

        xErrLoc := 540;
        DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
        xErrLoc := 560;
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':item_id',p_item_id);
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':category_id',p_category_id);

        xErrLoc := 580;
        populateCtxDescCatAtt(p_category_id, vItemSourceCursor,'Y',
                                 'Y', p_lang, 'ROWID', p_log_type);
        xErrLoc := 600;
    ELSE -- insert item
        xErrLoc := 620;
        BEGIN
            SELECT 1
            INTO vSearchableExists
            FROM DUAL
            WHERE EXISTS
                (SELECT 1
                FROM ICX_CAT_DESCRIPTORS_TL
                WHERE RT_CATEGORY_ID=p_category_id
                AND CLASS = 'POM_CAT_ATTR'
                AND SEARCHABLE = 1);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        xErrLoc := 640;
        -- only need to do the following if the category has searchable attribute
        IF(vSearchableExists = 1) THEN
            xErrLoc := 680;
            vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_POR_C'||p_category_id||'_TL' ||
                    ' WHERE rt_item_id=:item_id';
            xErrLoc := 700;
            DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
            xErrLoc := 720;
            DBMS_SQL.BIND_VARIABLE(vItemSourceCursor,':item_id',p_item_id);

            xErrLoc := 740;
            populateCtxDescCatAtt(p_category_id, vItemSourceCursor,'N',
                                 'N', p_lang, 'ROWID');
            xErrLoc := 760;
        END IF;
        xErrLoc := 800;
    END IF;

    xErrLoc := 900;
    DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
    xErrLoc := 1000;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescLang done');
    xErrLoc := 1001;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

    IF (vItemSourceCv%ISOPEN) THEN
        CLOSE vItemSourceCv;
    END IF;

    IF (DBMS_SQL.IS_OPEN(vItemSourceCursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
    END IF;

    RAISE_APPLICATION_ERROR (-20000,
        'Exception at ICX_POR_CTX_DESC.populateCtxDescLang('||xErrLoc||
        '), '||SQLERRM );
END populateCtxDescLang;

-- sosingha Bug#3460478: 10g fix for getting the major and minor db version
PROCEDURE rebuild_indexes IS
    version        number := 0;
    xErrLoc        integer := 0;
    majorReleasePos NUMBER := 0;
    minorReleasePos NUMBER := 0;
    versionString  varchar2(30) := null;
    compatibility  varchar2(30) := null;
    majorVersion   varchar2(10) := null;
    minorVersion   varchar2(10) := null;
    plsqlBlock     varchar2(1000) := null;
    cursorID       integer := 0;
    result         integer := 0;
BEGIN

    xErrLoc := 10;
    dbms_utility.db_version(versionString, compatibility);
    --Debugging
    --icx_por_track_validate_job_s.log('*******<<<>>>*** REBUILD_INDEX', 'LOADER');

    xErrLoc := 11;
    --Debugging
    icx_por_ext_utl.debug('*******<<<>>>*** REBUILD_INDEX');
    xErrLoc := 20;
    /*
    majorVersion := substr(versionString, 1, 1);
    minorVersion := substr(versionString, 3, 1);
    */
    select instr(versionString, '.') into majorReleasePos from dual;
    select instr(substr(versionString,majorReleasePos), '.')
    into minorReleasePos from dual;

    xErrLoc := 30;
    majorVersion := substr(versionString, 1, majorReleasePos-1);
    minorVersion := substr(versionString, majorReleasePos+1, minorReleasePos);

    xErrLoc := 40;
    version := to_number(majorVersion) + (to_number(minorVersion) / 10);

    xErrLoc := 50;
    cursorID := DBMS_SQL.open_cursor;
    xErrLoc := 120;
    IF version >= 8.1 THEN
        --smallya Bug: 1713602 commented out the old package call and replaced it with the new one 04/06/2001--
        --plsqlBlock := 'BEGIN icx_por_intermedia_index.rebuild_index; END;';
        plsqlBlock := 'BEGIN ICX_POR_INTERMEDIA_INDEX.rebuild_index; END;';
        /*icx_por_intermedia_index.rebuild_index;*/
    ELSE
        plsqlBlock := 'BEGIN icx_item_context_index_create.rebuild_item_context(''N''); END;';
        /*icx_item_context_index_create.rebuild_item_context('N');*/
    END IF;
    xErrLoc := 121;
    --Debugging
    icx_por_ext_utl.debug('plsql call made in rebuild_indexes:' || plsqlBlock);
    xErrLoc := 122;
    dbms_sql.parse(cursorID, plsqlBlock, dbms_sql.NATIVE);
    xErrLoc := 123;
    --Debugging
    icx_por_ext_utl.debug('start to rebuild_indexes');
    xErrLoc := 130;
    result := DBMS_SQL.execute(cursorID);
    xErrLoc := 133;
    --Debugging
    icx_por_ext_utl.debug('rebuild_indexes done');
    xErrLoc := 170;
    dbms_sql.close_cursor(cursorID);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,
	'Exception at ICX_POR_CTX_DESC.rebuild_indexes(' ||
	xErrLoc||'), '|| SQLERRM || ' #### VARIABLES ####' ||
                                        ' versionString = ' || versionString ||
                                        ' majorVersion = ' || majorVersion ||
                                        ' minorVersion = ' || minorVersion ||
                                        ' version = ' || version);
END rebuild_indexes;

/*
** -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
** Procedure : populateBuyerInfo
** Synopsis  : Update the ctx_<lang> to include buyer id info for all the items
** -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
*/
PROCEDURE populateBuyerInfo( pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y', p_log_type IN VARCHAR2 default 'LOADER')
IS
   xErrLoc       PLS_INTEGER := 0;
   getItemsTlCur   item_source_cv_type;
BEGIN
  xErrLoc := 11;
  --Debugging
  icx_por_ext_utl.debug('start of populateBuyerInfo');

  xErrLoc := 100;

  OPEN getItemsTlCur FOR
    SELECT rowid, rt_item_id, language
    FROM icx_cat_items_tlp;

  xErrLoc := 200;

  populateCtxDescBuyerInfo(getItemsTlCur, pDeleteYN, pUpdateYN, null, 'ROWID', p_log_type);

  CLOSE getItemsTlCur;
  xErrLoc := 101;
  --Debugging
  icx_por_ext_utl.debug('populateBuyerInfo done');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF getItemsTlCur%ISOPEN THEN
      CLOSE getItemsTlCur;
    END IF;

    RAISE_APPLICATION_ERROR (-20000,
      'Exception at ICX_POR_CTX_DESC.populateBuyerInfo('||xErrLoc||'
), '||SQLERRM );
END populateBuyerInfo;

/* The calling procedure is responsible for opening and closing the cursor*/
PROCEDURE populateCtxDescBuyerInfo(pItemSourceCv IN item_source_cv_type,
                            pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                            pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                            pLanguage IN VARCHAR2 DEFAULT NULL,
                            pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                            p_log_type IN VARCHAR2 DEFAULT 'LOADER') is
xErrLoc         INTEGER := 0;  -- execution location for error trapping
vRowidTab       DBMS_SQL.UROWID_TABLE;
vItemIdTab      DBMS_SQL.NUMBER_TABLE;
vLangTab        DBMS_SQL.VARCHAR2_TABLE;
c_handle        NUMBER ;
c_status        PLS_INTEGER;
vSqlString      VARCHAR2(4000);
v_sequence      PLS_INTEGER := 10001;
p_lang          VARCHAR2(10) := NULL;
BEGIN

    xErrLoc := 0;
    --Debugging
    icx_por_ext_utl.debug('start to process populateCtxDescBuyerInfo');
    xErrLoc := 11;

    LOOP
      vRowidTab.DELETE;
      vItemIdTab.DELETE;
      vLangTab.DELETE;

      xErrLoc := 100;

      IF (pSourceType = 'ROWID') THEN
        FETCH pItemSourceCv BULK COLLECT INTO vRowidTab,vItemIdTab,vLangTab
          LIMIT BATCH_SIZE;
      ELSE
        FETCH pItemSourceCv BULK COLLECT INTO vItemIdTab,vLangTab
          LIMIT BATCH_SIZE;
      END IF;

      xErrLoc := 110;
      --Debugging
      icx_por_ext_utl.debug('populateCtxDescBuyerInfo vItemIdTab count:' ||
                             to_char(vItemIdTab.COUNT) );

      xErrLoc := 200;

      IF vItemIdTab.COUNT = 0 THEN
        EXIT;
      END IF;

      xErrLoc := 300;

      -- delete exisiting Buyerid rows from icx_cat_items_ctx_tlp
      IF (pDeleteYN = 'Y') THEN
        FORALL i in 1..vItemIdTab.COUNT
          DELETE FROM icx_cat_items_ctx_tlp
          WHERE rt_item_id = vItemIdTab(i)
          AND language = vLangTab(i)
          AND sequence > 10000
          AND sequence < 15000;
      END IF;

      IF (pSourceType = 'ROWID') THEN

        FORALL i IN 1..vRowIdTab.COUNT
          INSERT INTO icx_cat_items_ctx_tlp
            (rt_item_id,language,sequence,ctx_desc,org_id)
          SELECT tl.rt_item_id, tl.language, v_sequence,
            to_char(pll.org_id), pll.org_id
          FROM icx_cat_items_tlp tl,
          (SELECT distinct org_id FROM icx_cat_item_prices
             WHERE rt_item_id = vItemIdTab(i)
          ) pll
          WHERE tl.rowid = vRowIdTab(i);
      ELSE

        FORALL i IN 1..vItemIdTab.COUNT
          INSERT INTO icx_cat_items_ctx_tlp
            (rt_item_id,language,sequence,ctx_desc,org_id)
          SELECT tl.rt_item_id, tl.language, v_sequence,
            to_char(pll.org_id), pll.org_id
          FROM icx_cat_items_tlp tl,
          (SELECT distinct org_id FROM icx_cat_item_prices
             WHERE rt_item_id = vItemIdTab(i)
          ) pll
          WHERE tl.rt_item_id = vItemIdTab(i)
          AND tl.language = vLangTab(i);

      END IF;

      COMMIT;

    END LOOP;
    xErrLoc := 1001;
    --Debugging
    icx_por_ext_utl.debug('populateCtxDescBuyerInfo done');

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF (DBMS_SQL.IS_OPEN(c_handle)) THEN
        DBMS_SQL.CLOSE_CURSOR(c_handle);
      END IF;

        RAISE_APPLICATION_ERROR (-20000,
        'Exception at ICX_POR_CTX_DESC.populateCtxDescBuyerInfo('||xErrLoc || '), '||SQLERRM );
END populateCtxDescBuyerInfo;


END ICX_POR_CTX_DESC;

/
