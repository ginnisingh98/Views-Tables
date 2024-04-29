--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXT_CLASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXT_CLASS" AS
/* $Header: ICXEXTCB.pls 115.28 2004/03/31 18:46:06 vkartik ship $*/

--------------------------------------------------------------
--                     Type and Cursor                      --
--------------------------------------------------------------

TYPE tClassification IS RECORD (
  category_id		NUMBER,
  category_name 	ICX_CAT_CATEGORIES_TL.CATEGORY_NAME%TYPE,
  language		VARCHAR2(4),
  source_lang		VARCHAR2(4),
  rt_category_id	NUMBER,
  old_category_name	ICX_CAT_CATEGORIES_TL.CATEGORY_NAME%TYPE);

TYPE tCursorType	IS REF CURSOR;

--------------------------------------------------------------
--                    Global Variables                      --
--------------------------------------------------------------
gLastCategoryKey 	icx_cat_categories_TL.KEY%TYPE;
gLastRtCategoryId	NUMBER := -1;
gCompletedCount		PLS_INTEGER := 0;

--------------------------------------------------------------
--                     Global Tables                        --
--------------------------------------------------------------
gAddRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
gAddCategoryKeys	DBMS_SQL.VARCHAR2_TABLE;
gAddCategoryNames	DBMS_SQL.VARCHAR2_TABLE;
gAddLanguages		DBMS_SQL.VARCHAR2_TABLE;
gAddSourceLangs		DBMS_SQL.VARCHAR2_TABLE;
gAddNewRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
gAddNewCategoryKeys	DBMS_SQL.VARCHAR2_TABLE;

gUpdateRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
gUpdateCategoryKeys	DBMS_SQL.VARCHAR2_TABLE;
gUpdateCategoryNames	DBMS_SQL.VARCHAR2_TABLE;
gUpdateLanguages	DBMS_SQL.VARCHAR2_TABLE;
gUpdateSourceLangs	DBMS_SQL.VARCHAR2_TABLE;

--------------------------------------------------------------
--                   Global PL/SQL Tables                   --
--------------------------------------------------------------

PROCEDURE clearTables(pMode	IN VARCHAR2) IS
BEGIN
  IF (pMode IN ('ALL', 'ADD')) THEN
    gAddRtCategoryIds.DELETE;
    gAddCategoryKeys.DELETE;
    gAddCategoryNames.DELETE;
    gAddLanguages.DELETE;
    gAddSourceLangs.DELETE;
    gAddNewRtCategoryIds.DELETE;
    gAddNewCategoryKeys.DELETE;
  END IF;

  IF (pMode IN ('ALL', 'UPDATE')) THEN
    gUpdateRtCategoryIds.DELETE;
    gUpdateCategoryKeys.DELETE;
    gUpdateCategoryNames.DELETE;
    gUpdateLanguages.DELETE;
    gUpdateSourceLangs.DELETE;
  END IF;
END;

--------------------------------------------------------------
--                        Snap Shots                        --
--------------------------------------------------------------

FUNCTION snapShot(pIndex	IN PLS_INTEGER,
		  pMode		IN VARCHAR2) RETURN varchar2 IS
  xShot varchar2(2000) := 'SnapShot('||pMode||')['||pIndex||']--';
BEGIN
  IF (pMode = 'ADD') THEN
    xShot := xShot || ' gAddRtCategoryId: ' ||
      ICX_POR_EXT_UTL.getTableElement(gAddRtCategoryIds, pIndex) || ',';
    xShot := xShot || ' gAddCategoryKey: '||
      ICX_POR_EXT_UTL.getTableElement(gAddCategoryKeys, pIndex) || ',';
    xShot := xShot || ' gAddCategoryName: '||
      ICX_POR_EXT_UTL.getTableElement(gAddCategoryNames, pIndex) || ',';
    xShot := xShot || ' gAddLanguage: '||
      ICX_POR_EXT_UTL.getTableElement(gAddLanguages, pIndex) || ',';
    xShot := xShot || ' gAddSourceLang: '||
      ICX_POR_EXT_UTL.getTableElement(gAddSourceLangs, pIndex);
  ELSIF (pMode = 'ADDNEW') THEN
    xShot := xShot || ' gAddNewRtCategoryId: '||
      ICX_POR_EXT_UTL.getTableElement(gAddNewRtCategoryIds, pIndex) || ',';
    xShot := xShot || ' gAddNewCategoryKey: ' ||
      ICX_POR_EXT_UTL.getTableElement(gAddNewCategoryKeys, pIndex);
  ELSIF (pMode = 'UPDATE') THEN
    xShot := xShot || ' gUpdateRtCategoryId: ' ||
      ICX_POR_EXT_UTL.getTableElement(gUpdateRtCategoryIds, pIndex) || ',';
    xShot := xShot || ' gUpdateCategoryKey: ' ||
      ICX_POR_EXT_UTL.getTableElement(gUpdateCategoryKeys, pIndex) || ',';
    xShot := xShot || ' gUpdateCategoryName: ' ||
      ICX_POR_EXT_UTL.getTableElement(gUpdateCategoryNames, pIndex) || ',';
    xShot := xShot || ' gUpdateLanguage: ' ||
      ICX_POR_EXT_UTL.getTableElement(gUpdateLanguages, pIndex) || ',';
    xShot := xShot || ' gUpdateSourceLang: ' ||
      ICX_POR_EXT_UTL.getTableElement(gUpdateSourceLangs, pIndex);
  END IF;

  RETURN xShot;
END snapShot;

--------------------------------------------------------------
--                Sync Category Procedures                  --
--------------------------------------------------------------

-- Add categories
PROCEDURE addCategories(pType	IN PLS_INTEGER) IS
  xErrLoc	PLS_INTEGER := 100;
  xMode		VARCHAR2(20) := 'ADD';

  CURSOR cRebuildItems(p_rt_category_id	IN NUMBER,
                       p_language	IN VARCHAR2) IS
    SELECT rowid
    FROM   icx_cat_items_tlp
    WHERE  primary_category_id = p_rt_category_id
    AND    language = p_language;

  xRowIds	DBMS_SQL.UROWID_TABLE;

BEGIN

  IF (ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gAddRtCategoryIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL, snapShot(i, 'ADD'));
    END LOOP;
    FOR i in 1..gAddNewRtCategoryIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL, snapShot(i, 'ADDNEW'));
    END LOOP;
  END IF;

  xErrLoc := 200;

  -- Add categories
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Insert icx_cat_categories_tl');
  END IF;

  FORALL i IN 1..gAddRtCategoryIds.COUNT
    INSERT INTO icx_cat_categories_tl(
      rt_category_id, category_name, key, title, type, language,
      source_lang, upper_category_name, upper_key, section_map,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login, request_id, program_application_id,
      program_id, program_update_date)
    VALUES(gAddRtCategoryIds(i),gAddCategoryNames(i),
           gAddCategoryKeys(i), 'Oracle', pType,
           gAddLanguages(i), gAddSourceLangs(i),
           upper(gAddCategoryNames(i)), upper(gAddCategoryKeys(i)),
           rpad('0', 300, 0),
           ICX_POR_EXTRACTOR.gUserId, SYSDATE,
           ICX_POR_EXTRACTOR.gUserId, SYSDATE,
           ICX_POR_EXTRACTOR.gLoginId, ICX_POR_EXTRACTOR.gRequestId,
           ICX_POR_EXTRACTOR.gProgramApplicationId,
           ICX_POR_EXTRACTOR.gProgramId, SYSDATE);

  -- Duplicate template headers accross all installed languages
  -- For categories, we don't replicate, just take it as is
  IF (pType = TEMPLATE_HEADER_TYPE) THEN
    -- template header
    xErrLoc := 300;
    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
      ICX_POR_EXT_UTL.debug('Replicate template headers accross ' ||
                            'installed languages');
    END IF;
    -- Replicate accross installed langs
    FORALL i IN 1..gAddRtCategoryIds.COUNT
      INSERT INTO icx_cat_categories_tl(
        rt_category_id, category_name, key, title, type, language,
        source_lang, upper_category_name, upper_key, section_map,
        created_by, creation_date, last_updated_by, last_update_date,
        last_update_login, request_id, program_application_id,
        program_id, program_update_date)
      SELECT gAddRtCategoryIds(i), gAddCategoryNames(i),
             gAddCategoryKeys(i), 'Oracle', TEMPLATE_HEADER_TYPE,
             language_code, gAddLanguages(i),
             upper(gAddCategoryNames(i)), upper(gAddCategoryKeys(i)),
             rpad('0', 300, 0),
             ICX_POR_EXTRACTOR.gUserId, SYSDATE,
             ICX_POR_EXTRACTOR.gUserId, SYSDATE,
             ICX_POR_EXTRACTOR.gLoginId, ICX_POR_EXTRACTOR.gRequestId,
             ICX_POR_EXTRACTOR.gProgramApplicationId,
             ICX_POR_EXTRACTOR.gProgramId, SYSDATE
        FROM fnd_languages
       WHERE installed_flag = 'I';

  END IF;

  xErrLoc := 400;
  xMode := 'ADDNEW';

  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Create ICX_POR_CATEGORY_DATA_SOURCES records');
  END IF;

  -- Creates ICX_POR_CATEGORY_DATA_SOURCES records

  -- Bug#3011247 : srmani  - Adding back the Not Exists Clause.
  -- Workaround, as Bulktable cannot be referenced inside a not exists clause.

  FORALL i IN 1..gAddRtCategoryIds.COUNT
   INSERT INTO icx_por_category_data_sources (
   -- Bug: 3291430 - Also populate rt_category_id with value from icx_cat_categories_tl
         rt_category_id,
         category_key,
         external_source, external_source_key,
         created_by, creation_date, last_updated_by, last_update_date,
         last_update_login, request_id, program_application_id,
         program_id, program_update_date)
     SELECT rt_category_id, key,'Oracle', key,
            ICX_POR_EXTRACTOR.gUserId, SYSDATE,
            ICX_POR_EXTRACTOR.gUserId, SYSDATE,
            ICX_POR_EXTRACTOR.gLoginId, ICX_POR_EXTRACTOR.gRequestId,
            ICX_POR_EXTRACTOR.gProgramApplicationId,
            ICX_POR_EXTRACTOR.gProgramId, SYSDATE
     FROM   icx_cat_categories_tl
     WHERE
            rt_category_id = gAddRtCategoryIds(i) and
            language = gAddLanguages(i) and
            not exists (select 1
                        from   icx_por_category_data_sources
                        where  external_source = 'Oracle'
                           and external_source_key = key);

  xErrLoc := 500;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Create ICX_POR_CATEGORY_ORDER_MAP records');
  END IF;

  -- Creates ICX_POR_CATEGORY_ORDER_MAP records
  IF (pType = CATEGORY_TYPE) THEN
    FORALL i IN 1..gAddNewRtCategoryIds.COUNT
      INSERT INTO icx_por_category_order_map (
        rt_category_id, external_source, external_source_key,
        created_by, creation_date, last_updated_by,
        last_update_date, last_update_login)
      VALUES(gAddNewRtCategoryIds(i), 'Oracle', gAddNewCategoryKeys(i),
             ICX_POR_EXTRACTOR.gUserId, SYSDATE,
             ICX_POR_EXTRACTOR.gUserId, SYSDATE,
             ICX_POR_EXTRACTOR.gLoginId);
  END IF;

  xErrLoc := 600;
  ICX_POR_EXT_UTL.extAFCommit;
  clearTables('ADD');

EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.addCategories-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    raise ICX_POR_EXT_UTL.gException;

END addCategories;

-- Update categories
PROCEDURE updateCategories(pType	IN PLS_INTEGER) IS
  xErrLoc	PLS_INTEGER := 100;
  xMode		VARCHAR2(20) := 'UPDATE';

  CURSOR cRebuildItems(p_rt_category_id	IN NUMBER,
                       p_language	IN VARCHAR2) IS
    SELECT rowid
    FROM   icx_cat_items_tlp
    WHERE  primary_category_id = p_rt_category_id
    AND    language = p_language;

  xRowIds	DBMS_SQL.UROWID_TABLE;

BEGIN

  IF (ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gUpdateRtCategoryIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL, snapShot(i, xMode));
    END LOOP;
  END IF;

  xErrLoc := 100;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Set rebuild job num');
  END IF;
  -- set rebuild_job since category name is changed

  IF (pType = CATEGORY_TYPE) THEN
    -- Only consider regular category, not template because
    -- the intermedia index string doesn't contain template name
    -- Primary category only store regular category

    FOR i IN 1..gUpdateRtCategoryIds.COUNT LOOP

      OPEN cRebuildItems(gUpdateRtCategoryIds(i), gUpdateLanguages(i));

      LOOP
        xErrLoc := 200;
        xRowIds.DELETE;

        xErrLoc := 220;
        FETCH cRebuildItems
        BULK  COLLECT INTO xRowIds
        LIMIT ICX_POR_EXT_UTL.gCommitSize;
        EXIT  WHEN xRowIds.COUNT = 0;

        xErrLoc := 240;
        FORALL j IN 1..xRowIds.COUNT
          UPDATE icx_cat_items_tlp
             SET primary_category_name = gUpdateCategoryNames(i),
                 last_updated_by = ICX_POR_EXTRACTOR.gUserId,
		 last_update_date = SYSDATE,
		 last_update_login = ICX_POR_EXTRACTOR.gLoginId,
		 request_id = ICX_POR_EXTRACTOR.gRequestId,
		 program_application_id = ICX_POR_EXTRACTOR.gProgramApplicationId,
		 program_id = ICX_POR_EXTRACTOR.gProgramId,
		 program_update_date = SYSDATE
           WHERE rowid = xRowIds(j);

        ICX_POR_EXT_UTL.extAFCommit;

      END LOOP;

      xErrLoc := 300;
      CLOSE cRebuildItems;
    END LOOP;

  END IF;

  xErrLoc := 400;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
    ICX_POR_EXT_UTL.debug('Update ICX_CAT_CATEGORIES_TL');
  END IF;

  FORALL i IN 1..gUpdateRtCategoryIds.COUNT
    UPDATE icx_cat_categories_tl
      SET  category_name = gUpdateCategoryNames(i),
           upper_category_name = upper(gUpdateCategoryNames(i)),
           source_lang = gUpdateSourceLangs(i),
           last_updated_by = ICX_POR_EXTRACTOR.gUserId,
	   last_update_date = SYSDATE,
	   last_update_login = ICX_POR_EXTRACTOR.gLoginId,
	   request_id = ICX_POR_EXTRACTOR.gRequestId,
	   program_application_id = ICX_POR_EXTRACTOR.gProgramApplicationId,
	   program_id = ICX_POR_EXTRACTOR.gProgramId,
	   program_update_date = SYSDATE
     WHERE rt_category_id = gUpdateRtCategoryIds(i)
       AND language = gUpdateLanguages(i);

  ICX_POR_EXT_UTL.extAFCommit;

  xErrLoc := 500;
  clearTables(xMode);

EXCEPTION
  when others then
    IF (cRebuildItems%ISOPEN) THEN
      CLOSE cRebuildItems;
    END IF;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.updateCategories-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));

    ICX_POR_EXT_UTL.extRollback;

    raise ICX_POR_EXT_UTL.gException;

END updateCategories;

-- Process batch data
PROCEDURE processBatchData(pType	IN PLS_INTEGER,
			   pMode	IN VARCHAR2) IS
  xErrLoc	PLS_INTEGER := 100;

BEGIN
  xErrLoc := 100;

  IF (pMode = 'OUTLOOP' OR
      -- Since we will commit the changes as a transaction in addCategories,
      -- we need to re-calculate the correct commit size
      (pType = CATEGORY_TYPE AND
       (ICX_POR_EXT_UTL.gCommitSize < 3 OR
        gAddRtCategoryIds.COUNT >= ICX_POR_EXT_UTL.gCommitSize/3)) OR
      (pType = TEMPLATE_HEADER_TYPE AND
       (ICX_POR_EXT_UTL.gCommitSize <
        ICX_POR_EXTRACTOR.gInstalledLanguageCount+2 OR
        gAddRtCategoryIds.COUNT >=
        ICX_POR_EXT_UTL.gCommitSize/
        (ICX_POR_EXTRACTOR.gInstalledLanguageCount+2))))
  THEN
    xErrLoc := 200;
    IF (pType = CATEGORY_TYPE) THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch category extract -- Pending[Insert: ' ||
        gAddRtCategoryIds.COUNT || '], Completed[' || gCompletedCount || ']');
    ELSE
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch template header extract -- Pending[Insert: ' ||
        gAddRtCategoryIds.COUNT || '], Completed[' || gCompletedCount || ']');
    END IF;

    gCompletedCount := gCompletedCount + gAddRtCategoryIds.COUNT;
    addCategories(pType);
  END IF;

  IF (pMode = 'OUTLOOP' OR
      gUpdateRtCategoryIds.COUNT >= ICX_POR_EXT_UTL.gCommitSize)
  THEN
    xErrLoc := 300;
    IF (pType = CATEGORY_TYPE) THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch category extract -- Pending[Update: ' ||
        gUpdateRtCategoryIds.COUNT || '], Completed[' ||
        gCompletedCount || ']');
    ELSE
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Process batch template header extract -- Pending[Update: ' ||
        gUpdateRtCategoryIds.COUNT || '], Completed[' || gCompletedCount || ']');
    END IF;

    gCompletedCount := gCompletedCount + gUpdateRtCategoryIds.COUNT;
    updateCategories(pType);
  END IF;

  xErrLoc := 400;
EXCEPTION
  when ICX_POR_EXT_UTL.gException then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.processBatchData-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  when others then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.processBatchData-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END processBatchData;

--------------------------------------------------------------
--               Extract Classfication Data                 --
--------------------------------------------------------------
-- Open classification cursor
PROCEDURE openClassCursor(pType		IN PLS_INTEGER,
			  pCursor	IN OUT NOCOPY tCursorType)
IS
  xCategorySetId	NUMBER;
  xValidateFlag		VARCHAR2(1);
  xStructureId		NUMBER;
  xLastRunDate		DATE;
  xString		VARCHAR2(4000);
  xErrLoc		PLS_INTEGER := 100;

BEGIN
  xErrLoc := 100;

  IF (pType = CATEGORY_TYPE) THEN
    xErrLoc := 200;
    -- get category set info
    select category_set_id,
           validate_flag,
           structure_id
    into   xCategorySetId,
           xValidateFlag,
           xStructureId
    from   mtl_default_sets_view
    where  functional_area_id = 2;

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Category Set Information[category_set_id: ' || xCategorySetId ||
      ', validate_flag: ' || xValidateFlag ||
      ', structure_id: ' || xStructureId || ']');

    xErrLoc := 210;
    xLastRunDate := ICX_POR_EXTRACTOR.gLoaderValue.categories_last_run_date;

    xErrLoc := 220;
    xString :=
      'select distinct mck.category_id category_id, ' ||
      ' nvl(mctl.description, mck.concatenated_segments) category_name, ' ||
      ' mctl.language language, ' ||
      ' mctl.source_lang source_lang, ' ||
      ' icat.rt_category_id rt_category_id, ' ||
      ' icat2.category_name old_category_name ';

    xErrLoc := 230;
    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'from imtl_categories_kfv mck, ' ||
    	' imtl_categories_tl mctl, ' ||
    	' icx_cat_categories_tl icat, ' ||
    	' icx_cat_categories_tl icat2 ';
      IF xValidateFlag = 'Y' THEN
        xString := xString ||
          ', imtl_category_set_valid_cats mcsvc ';
      END IF;
    ELSE
      xString := xString ||
        'from mtl_categories_kfv mck, ' ||
    	' mtl_categories_tl mctl, ' ||
    	' icx_cat_categories_tl icat, ' ||
    	' icx_cat_categories_tl icat2 ';
      IF xValidateFlag = 'Y' THEN
        xString := xString ||
          ', mtl_category_set_valid_cats mcsvc ';
      END IF;
    END IF;

    xErrLoc := 240;
    xString := xString ||
      'where mck.structure_id = :structure_id ' ||
      'and mck.web_status = ''Y'' ' ||
      'and nvl(mck.start_date_active, sysdate) <= sysdate ' ||
      'and sysdate < nvl(mck.end_date_active, sysdate+1) ' ||
      'and sysdate < nvl(mck.disable_date, sysdate+1) ' ||
      'and GREATEST(mck.last_update_date, mctl.last_update_date';
    IF xValidateFlag = 'Y' THEN
      xString := xString || ', mcsvc.last_update_date';
    END IF;
    xString := xString ||
      ') > NVL(:last_run_date, mck.last_update_date-1) ' ||
      'and mctl.category_id = mck.category_id ' ||
      'and mctl.language in (select language_code ' ||
      ' from fnd_languages ' ||
      ' where installed_flag in (''B'', ''I'')) ' ||
      'and to_char(mctl.category_id) = icat.key (+) ' ||
      'and to_char(mctl.category_id) = icat2.key (+) ' ||
      'and mctl.language = icat2.language (+) ';

    xErrLoc := 260;
    IF xValidateFlag = 'Y' THEN
      xErrLoc := 270;
      xString := xString ||
        'and mcsvc.category_set_id = :category_set_id ' ||
        'and mcsvc.category_id = mck.category_id ';
    END IF;

    xErrLoc := 280;
    xString := xString || 'order  by 1 ';

    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
        'Query for category extraction: ' || xString);
    END IF;

    xErrLoc := 300;
    IF xValidateFlag = 'Y' THEN
      xErrLoc := 320;
      OPEN pCursor FOR xString USING xStructureId, xLastRunDate,
                                     xCategorySetId;
    ELSE
      xErrLoc := 340;
      OPEN pCursor FOR xString USING xStructureId, xLastRunDate;
    END IF;
  ELSIF (pType = TEMPLATE_HEADER_TYPE) THEN
    xErrLoc := 400;
    if (ICX_POR_EXTRACTOR.gLoaderValue.load_internal_item = 'Y' and
        ICX_POR_EXTRACTOR.gLoaderValue.template_headers_last_run_date >
        ICX_POR_EXTRACTOR.gLoaderValue.internal_item_last_run_date) then
      xLastRunDate :=
        ICX_POR_EXTRACTOR.gLoaderValue.internal_item_last_run_date;
    else
      xLastRunDate :=
        ICX_POR_EXTRACTOR.gLoaderValue.template_headers_last_run_date;
    end if;

    xErrLoc := 420;
    xString :=
      'select distinct to_number(NULL) category_id, ' ||
      ' templates.express_name category_name, ' ||
      ' to_char(NULL) language, ' ||
      ' to_char(NULL) source_lang, ' ||
      ' icat.rt_category_id rt_category_id, ' ||
      ' icat.category_name old_category_name ';

    xErrLoc := 430;
    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'from ipo_reqexpress_headers_all templates, ' ||
    	' icx_cat_categories_tl icat ';
    ELSE
      xString := xString ||
        'from po_reqexpress_headers_all templates, ' ||
    	' icx_cat_categories_tl icat ';
    END IF;

    xErrLoc := 440;
    xString := xString ||
      'where templates.last_update_date > NVL(:last_run_date, ' ||
      ' templates.last_update_date-1) ' ||
      'and NVL(templates.inactive_date, sysdate+1) > sysdate ' ||
      'and exists (select -1 ';

    xErrLoc := 450;
    IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
      xString := xString ||
        'from ipo_reqexpress_lines_all tlines ';
    ELSE
      xString := xString ||
        'from po_reqexpress_lines_all tlines ';
    END IF;

    xErrLoc := 460;
    xString := xString ||
      'where tlines.express_name = templates.express_name ' ||
      'and (templates.org_id is null and  ' ||
      ' tlines.org_id is null or ' ||
      ' templates.org_id = tlines.org_id) ' ||
      'and (:load_internal_item = ''Y'' or ' ||
      ' tlines.source_type_code = ''VENDOR'')) ' ||
      'and templates.express_name||''_tmpl'' = icat.key (+) ' ||
      'and icat.language (+) = :base_lang ';

    xErrLoc := 470;

    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.INFO_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
        'Query for template header extraction: ' || xString);
    END IF;

    xErrLoc := 500;
    OPEN pCursor FOR xString USING xLastRunDate,
         ICX_POR_EXTRACTOR.gLoaderValue.load_internal_item,
         ICX_POR_EXTRACTOR.gBaseLang;
  END IF;

  xErrLoc := 600;
EXCEPTION
  when ICX_POR_EXT_UTL.gException then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.openClassCursor-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  when others then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.openClassCursor-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END openClassCursor;

-- Process classification records
PROCEDURE processClassRecords(pType	IN PLS_INTEGER,
			      pCursor	IN tCursorType)
IS
  xRtCategoryId	number;

  xCategoryIds		DBMS_SQL.NUMBER_TABLE;
  xCategoryNames 	DBMS_SQL.VARCHAR2_TABLE;
  xLanguages		DBMS_SQL.VARCHAR2_TABLE;
  xSourceLangs		DBMS_SQL.VARCHAR2_TABLE;
  xRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
  xOldCategoryNames	DBMS_SQL.VARCHAR2_TABLE;

  xErrLoc		PLS_INTEGER := 100;
  xPendingCount		PLS_INTEGER := 0;

BEGIN

  xErrLoc := 100;
  clearTables('ALL');

  LOOP
    xErrLoc := 120;

    xCategoryIds.DELETE;
    xCategoryNames.DELETE;
    xLanguages.DELETE;
    xSourceLangs.DELETE;
    xRtCategoryIds.DELETE;
    xOldCategoryNames.DELETE;

    IF (ICX_POR_EXT_UTL.getDatabaseVersion < 9.0) THEN
      xErrLoc := 150;
      EXIT WHEN pCursor%NOTFOUND;
      -- Oracle 8i doesn't support BULK Collect from dynamic SQL
      FOR i IN 1..ICX_POR_EXT_UTL.gCommitSize LOOP
        FETCH pCursor
        INTO  xCategoryIds(i), xCategoryNames(i),
              xLanguages(i), xSourceLangs(i),
              xRtCategoryIds(i), xOldCategoryNames(i);
        EXIT WHEN pCursor%NOTFOUND;
      END LOOP;
    ELSE
      xErrLoc := 200;
      FETCH pCursor
      BULK  COLLECT INTO xCategoryIds, xCategoryNames,
                         xLanguages, xSourceLangs,
                         xRtCategoryIds, xOldCategoryNames
      LIMIT ICX_POR_EXT_UTL.gCommitSize;
      EXIT  WHEN xCategoryIds.COUNT = 0;
    END IF;

    xErrLoc := 240;
    FOR i IN 1..xCategoryIds.COUNT LOOP
      IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
          'Classification[category_id: '|| xCategoryIds(i) ||
          ', category_name: '|| xCategoryNames(i) ||
          ', language: '|| xLanguages(i) ||
          ', source_lang: '|| xSourceLangs(i) ||
          ', rt_category_id: '|| xRtCategoryIds(i) ||
          ', old_category_name: '|| xOldCategoryNames(i) || ']');
      END IF;

      xErrLoc := 300;
      IF (xRtCategoryIds(i) IS NULL) THEN
        -- Add action
        xErrLoc := 310;

        IF (pType = CATEGORY_TYPE) THEN
          -- Check do we have rows for other languages?
          IF (gLastRtCategoryId <> -1 and
              gLastCategoryKey = to_char(xCategoryIds(i))) THEN
            xRtCategoryID := gLastRtCategoryId;
            IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
              ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
                'Found category id with other language:' || xRtCategoryId);
            END IF;
          ELSE
            xErrLoc := 330;
            select icx_por_categoryid.nextval
              into xRtCategoryId
              from dual;
            xErrLoc := 350;
            IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
              ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
                'Create a new category id:' || xRtCategoryId);
            END IF;
            xPendingCount := gAddNewRtCategoryIds.COUNT + 1;
            gAddNewRtCategoryIds(xPendingCount) := xRtCategoryId;
            gAddNewCategoryKeys(xPendingCount) := to_char(xCategoryIds(i));

            gLastCategoryKey := to_char(xCategoryIds(i));
            gLastRtCategoryId := xRtCategoryId;
          END IF;
        ELSIF (pType = TEMPLATE_HEADER_TYPE) THEN
          xErrLoc := 360;
          select icx_por_categoryid.nextval
            into xRtCategoryId
            from dual;
          IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
            ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
              'Create new category id:' || xRtCategoryId);
          END IF;
          xPendingCount := gAddNewRtCategoryIds.COUNT + 1;
          gAddNewRtCategoryIds(xPendingCount) := xRtCategoryId;
          gAddNewCategoryKeys(xPendingCount) := xCategoryNames(i)||'_tmpl';
        END IF;

        xErrLoc := 380;
        xPendingCount := gAddRtCategoryIds.COUNT + 1;
        gAddRtCategoryIds(xPendingCount) := xRtCategoryId;
        IF (pType = CATEGORY_TYPE) THEN
          gAddCategoryKeys(xPendingCount) := to_char(xCategoryIds(i));
        ELSIF (pType = TEMPLATE_HEADER_TYPE) THEN
          gAddCategoryKeys(xPendingCount) := xCategoryNames(i)||'_tmpl';
        END IF;
        gAddCategoryNames(xPendingCount) := xCategoryNames(i);
        IF (pType = CATEGORY_TYPE) THEN
          gAddLanguages(xPendingCount) := xLanguages(i);
          gAddSourceLangs(xPendingCount) := xSourceLangs(i);
        ELSIF (pType = TEMPLATE_HEADER_TYPE) THEN
          gAddLanguages(xPendingCount) := ICX_POR_EXTRACTOR.gBaseLang;
          gAddSourceLangs(xPendingCount) := ICX_POR_EXTRACTOR.gBaseLang;
        END IF;

      ELSE
        IF (xOldCategoryNames(i) IS NULL) THEN
          -- Translate for category
          xErrLoc := 310;
          xPendingCount := gAddRtCategoryIds.COUNT + 1;
          gAddRtCategoryIds(xPendingCount) := xRtCategoryIds(i);
          gAddCategoryKeys(xPendingCount) := to_char(xCategoryIds(i));
          gAddCategoryNames(xPendingCount) := xCategoryNames(i);
          gAddLanguages(xPendingCount) := xLanguages(i);
          gAddSourceLangs(xPendingCount) := xSourceLangs(i);
        ELSE
          -- Update action
          IF (xOldCategoryNames(i) <> xCategoryNames(i)) then
            -- Only when name changed, we need to update
            xErrLoc := 400;
            xPendingCount := gUpdateCategoryKeys.COUNT + 1;
            gUpdateCategoryKeys(xPendingCount) := xCategoryNames(i)||'_tmpl';
            gUpdateCategoryNames(xPendingCount) := xCategoryNames(i);
            gUpdateRtCategoryIds(xPendingCount) := xRtCategoryIds(i);
            IF (pType = CATEGORY_TYPE) THEN
              gUpdateLanguages(xPendingCount) := xLanguages(i);
              gUpdateSourceLangs(xPendingCount) := xSourceLangs(i);
            ELSIF (pType = TEMPLATE_HEADER_TYPE) THEN
              gUpdateLanguages(xPendingCount) := ICX_POR_EXTRACTOR.gBaseLang;
              gUpdateSourceLangs(xPendingCount) := ICX_POR_EXTRACTOR.gBaseLang;
            END IF;
          ELSE
            IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
              ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
                'Category name is the same, no action needed');
            END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;

    xErrLoc := 500;
    -- move classification data
    processBatchData(pType, 'INLOOP');

  END LOOP;

  xErrLoc := 600;
  -- process remaining
  processBatchData(pType, 'OUTLOOP');

  IF (pType = CATEGORY_TYPE) THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Total processed categories: ' || gCompletedCount);
  ELSE
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Total processed template headers: ' || gCompletedCount);
  END IF;

EXCEPTION
  when ICX_POR_EXT_UTL.gException then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.processClassRecords-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  when others then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.processClassRecords-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END processClassRecords;

-- Main procedure
PROCEDURE extractClassificationData
IS
  xErrLoc	PLS_INTEGER := 100;
  cClass	tCursorType;

BEGIN
  xErrLoc := 100;
  IF (ICX_POR_EXTRACTOR.gLoaderValue.load_categories = 'Y') THEN

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Extract oracle categories');

    xErrLoc := 120;
    openClassCursor(CATEGORY_TYPE, cClass);

    xErrLoc := 140;
    processClassRecords(CATEGORY_TYPE, cClass);

    xErrLoc := 160;
    CLOSE cClass;

    xErrLoc := 180;
    ICX_POR_EXTRACTOR.setLastRunDates('CATEGORY');
  END IF; -- load_categories

  xErrLoc := 200;
  gCompletedCount := 0;

  IF (ICX_POR_EXTRACTOR.gLoaderValue.load_template_headers = 'Y') THEN

    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Extract template headers');

    xErrLoc := 220;
    openClassCursor(TEMPLATE_HEADER_TYPE, cClass);

    xErrLoc := 240;
    processClassRecords(TEMPLATE_HEADER_TYPE, cClass);

    xErrLoc := 260;
    CLOSE cClass;

    xErrLoc := 280;
    ICX_POR_EXTRACTOR.setLastRunDates('TEMPLATE_HEADER');
  END IF;  -- load_template_headers

  xErrLoc := 300;

EXCEPTION
  when ICX_POR_EXT_UTL.gException then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    IF (cClass%ISOPEN) THEN
      CLOSE cClass;
    END IF;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.extractClassificationData-'||
      xErrLoc);
    raise ICX_POR_EXT_UTL.gException;
  when others then
    -- rollback;
    ICX_POR_EXT_UTL.extRollback;

    IF (cClass%ISOPEN) THEN
      CLOSE cClass;
    END IF;

    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_CLASS.extractClassificationData-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END extractClassificationData;


END ICX_POR_EXT_CLASS;

/
