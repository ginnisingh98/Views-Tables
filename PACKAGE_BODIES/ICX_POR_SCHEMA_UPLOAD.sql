--------------------------------------------------------
--  DDL for Package Body ICX_POR_SCHEMA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_SCHEMA_UPLOAD" AS
/* $Header: ICXSULDB.pls 115.26 2004/08/03 00:56:56 kaholee ship $*/

-- Default number of characters for columns created as VARCHAR2
DEFAULT_COLUMN_SIZE	CONSTANT Number := 700;

gLastTableName VARCHAR2(30) := null;
gLastTableExist VARCHAR2(1) := 'N';
BATCH_SIZE       NUMBER:= 10000;
-------------------------------------------------------------------------
--                           Rebuild Index                             --
-------------------------------------------------------------------------
--
-- Copied from ICXCGCDB.pls
--

--
-- Cursor to fetch intalled languages
--
    CURSOR installed_languages_csr IS
        select language_code
        from fnd_languages
        where installed_flag in ('B', 'I');

/**
 ** Procedure : populate_ctx_desc_indexes
 ** Synopsis  : Update the ctx_<lang> columns for items belong to
 **             those categories which own rebuild_flags or their
 **             local descriptors' rebuild_flags are set to 'Y.'
 **
 ** Parameter:  p_request_id - number of the job to rebuild
 **/

PROCEDURE populate_ctx_desc_indexes(p_request_id IN INTEGER := -1) IS

    xErrLoc         NUMBER := 0;    -- execution location for error trapping
    rebuildBase     NUMBER :=0;
    vCategoryId     NUMBER;
    vItemSourceCursor NUMBER;
    vSqlString       VARCHAR2(4000);
    items_tl_cv     ICX_POR_CTX_DESC.Item_Source_cv_Type;

    CURSOR CatIdCur(p_request_id IN NUMBER) is
        SELECT distinct catid
        FROM (
            SELECT
            dl.rt_category_id catid
            FROM   icx_cat_descriptors_tl dl
            WHERE  dl.request_id = p_request_id
--OEX_IP_PORTING            AND    dl.class = 'ICX_CAT_ATTR'
            AND    dl.rebuild_flag = 'Y'
            AND    dl.rt_category_id<>0
            UNION
            SELECT ctl.rt_category_id catid
            FROM  icx_cat_categories_tl ctl
            where ctl.request_id = p_request_id
            AND ctl.rebuild_flag  in ('D','B')
            AND ctl.rt_category_id<>0
            );
BEGIN

    xErrLoc := 100;
    -- check if we need to rebuild ctx str for base attribute
    BEGIN
        SELECT 1
        INTO rebuildBase
        FROM dual
        WHERE EXISTS
            (SELECT 1
            FROM   icx_cat_descriptors_tl
            WHERE  request_id = p_request_id
            AND    rebuild_flag = 'Y'
            AND    rt_category_id = 0)
--OEX_IP_PORTING            AND    class = 'ICX_BASE_ATTR')
        OR  EXISTS
            (SELECT 1
            FROM   icx_cat_categories_tl
            WHERE  request_id = p_request_id
            AND    rebuild_flag = 'D'
            AND    rt_category_id = 0);
    EXCEPTION
        when no_data_found then
        null;
    END;

    if (rebuildBase = 1) then
        xErrLoc := 120;
        ICX_POR_CTX_DESC.populateBaseAttributes('Y','Y');
        xErrLoc := 130;
    else
        xErrLoc := 150;
        -- no need to do the following for changed category names
        -- if we've already done with the base attributes

        -- get sql table for base attributes
        OPEN items_tl_cv FOR
            SELECT tl.rowid, tl.rt_item_id, tl.language
            FROM icx_cat_items_tlp tl,
                icx_cat_categories_tl ctl
            where tl.primary_category_id = ctl.rt_category_id
            and tl.language = ctl.language
            and ctl.request_id = p_request_id
            AND ctl.rebuild_flag  in ('C','B')
            AND ctl.rt_category_id<>0;

        xErrLoc := 200;
        ICX_POR_CTX_DESC.populateCtxDescBaseAtt(items_tl_cv,'Y','Y',NULL,'ROWID');

        xErrLoc := 300;
        CLOSE items_tl_cv;
    end if; --if (rebuildBase = 1)

    xErrLoc := 400;
    -- rebuild changed searchable category attributes
    -- category attribute loop
    -- need to rebuild index because of deletion of searchable category attributes
    xErrLoc := 500;
    FOR catRec IN CatIdCur(p_request_id)
        LOOP
        vCategoryId := catRec.catid;
        vItemSourceCursor := DBMS_SQL.OPEN_CURSOR;
        xErrLoc := 520;

        --Changes for populate_ctx_desc_indexes to not throw invalid ROWID exception
        --vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_CAT_ITEMS_TLP '||
        --            ' WHERE primary_category_id = :catid';
        vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_CAT_EXT_ITEMS_TLP '||
                    ' WHERE rt_category_id = :catid';
        DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
        DBMS_SQL.BIND_VARIABLE(vItemSourceCursor, ':catid', vCategoryId);
/*
        IF (vCatTableExists = 1) THEN
--STO_CHECK: to get list of items affected by a category/descriptor change
--           cant we just use the category items table...do we need
--           icx_por_c<blah> table ??
            vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_POR_C'||vCategoryId||'_TL';
            DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
        ELSE
            vSqlString := 'SELECT rowid,rt_item_id,language FROM ICX_POR_ITEMS_TL '||
                    ' WHERE primary_category_id = :catid)';
            DBMS_SQL.PARSE(vItemSourceCursor, vSqlString, DBMS_SQL.NATIVE);
            DBMS_SQL.BIND_VARIABLE(vItemSourceCursor, ':catid', vCategoryId);
        END IF;
*/

        xErrLoc := 540;
        ICX_POR_CTX_DESC.populateCtxDescCatAtt(vCategoryId, vItemSourceCursor,'Y',
                                'Y', NULL, 'ROWID');
        xErrLoc:=560;
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
        xErrLoc:=580;
    END LOOP;

    xErrLoc := 600;

    -- reset rebuild_flag
    UPDATE icx_cat_categories_tl
    SET    rebuild_flag = NULL
    WHERE  request_id = p_request_id;

    xErrLoc := 700;
    UPDATE icx_cat_descriptors_tl
    SET    rebuild_flag = NULL
    WHERE  request_id = p_request_id;
    COMMIT;

    -- rebuild the intermedia or context indexes
    xErrLoc := 800;
    ICX_POR_INTERMEDIA_INDEX.rebuild_index;
    xErrLoc := 900;
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF(DBMS_SQL.IS_OPEN(vItemSourceCursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(vItemSourceCursor);
    END IF;

  RAISE_APPLICATION_ERROR
    (-20000, 'Exception at ICX_POR_SCHEMA_UPLOAD.populate_ctx_desc_indexes('||
     xErrLoc||'), '|| SQLERRM);

END populate_ctx_desc_indexes;

/**
 ** Procedure : populate_ctx_desc_indexes
 ** Synopsis  : Overloaded version. Contains 2 extra out parameters
 **             which are used by Concurrent program.
 **             No other functional change
 **             Update the ctx_<lang> columns for items belong to
 **             those categories which own rebuild_flags or their
 **             local descriptors' rebuild_flags are set to 'Y.'
 **
 ** Parameter:  p_request_id - number of the job to rebuild
 **/

PROCEDURE populate_ctx_desc_indexes(errbuf       OUT NOCOPY VARCHAR2,
                                    retcode      OUT NOCOPY VARCHAR2,
                                    p_request_id IN  INTEGER := -1) IS
BEGIN
   retcode := 0;
   errbuf := '';

   populate_ctx_desc_indexes(p_request_id);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SQLERRM;
      raise;
END populate_ctx_desc_indexes;


-------------------------------------------------------------------------
--                             ADD ACTION                              --
-------------------------------------------------------------------------

/**
 ** Proc : add_child_category
 ** Desc : Add a category as a child of another category.
 **        If this child category is already a child of other
 **        category, this relationship will be remained.
 **        Also this parent category should be navigation type.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE add_child_category (p_parent_id	IN NUMBER,
                              p_child_id	IN NUMBER,
                              p_user_id         IN NUMBER,
                              p_login_id        IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  xType           NUMBER;
  xTableName      VARCHAR2(30);
  xViewName       VARCHAR2(30);
  xStatement      VARCHAR2(500);

BEGIN

  xErrLoc := 100;

  select type
  into   xType
  from   icx_cat_categories_tl
  where  rt_category_id = p_parent_id
  and    rownum = 1;

  xErrLoc := 200;

  -- Only navigate category can be parent
  -- pcreddy # bug # 2959731 : ROOT will be a parent for the newly created
  -- NAVIGATION_TYPE categories
  if (p_parent_id <> 0 AND xType <> NAVIGATION_TYPE) then
    return;
  end if;

  xErrLoc := 300;

  --Changes for userId, loginId
  INSERT INTO icx_cat_browse_trees
  (parent_category_id, child_category_id,
  LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LAST_UPDATE_DATE,
  CREATED_BY, CREATION_DATE)
  SELECT p_parent_id, p_child_id,
         p_login_id, p_user_id, sysdate, p_user_id, sysdate
  FROM   DUAL
  WHERE  NOT EXISTS (SELECT NULL
                       FROM   icx_cat_browse_trees
                       WHERE  parent_category_id = p_parent_id
                       AND    child_category_id = p_child_id);
  xErrLoc := 400;
  -- pcreddy # bug 2959731 :
  -- when the parent is ROOT no need of doing any other operations
  IF (p_parent_id <> 0) THEN
    -- 1775192
    -- we also need to remove the child who is originally
    -- a top level navigational category
    DELETE FROM icx_cat_browse_trees
    WHERE  parent_category_id = 0
    AND    child_category_id = p_child_id;

    xErrLoc := 500;
    -- Add entry for parent category into toc table
    -- with its parentid=0: For Browse category to work
    -- Bug#1681042: Only Exception: If the parent is already a child dont add
    --Changes for userId, loginId
    INSERT INTO icx_cat_browse_trees
    (PARENT_CATEGORY_ID, CHILD_CATEGORY_ID,
     LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LAST_UPDATE_DATE,
     CREATED_BY, CREATION_DATE)
    SELECT 0, p_parent_id, p_login_id, p_user_id, sysdate, p_user_id, sysdate
    FROM   DUAL
    WHERE  NOT EXISTS (SELECT NULL
                       FROM   icx_cat_browse_trees
                       WHERE   child_category_id = p_parent_id);
  END IF;

  xErrLoc := 600;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.add_child_category('
        || xErrLoc || '): ' || SQLERRM);

END add_child_category;

/**
 ** Proc : delete_child_category
 ** Desc : Delete a category as a child of another category.
 **        Also this parent category should be navigation type.
 **/

PROCEDURE delete_child_category (p_parent_id	IN NUMBER,
                                 p_child_id	IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  xType           NUMBER;
  xTableName      VARCHAR2(30);
  xViewName       VARCHAR2(30);
  xStatement      VARCHAR2(500);

BEGIN

  xErrLoc := 100;

  select type
  into   xType
  from   icx_cat_categories_tl
  where  rt_category_id = p_parent_id
  and    rownum = 1;

  xErrLoc := 200;

  -- Only navigate category can be parent
  if (xType <> NAVIGATION_TYPE) then
    return;
  end if;

  xErrLoc := 300;

  DELETE FROM ICX_CAT_BROWSE_TREES
  WHERE  PARENT_CATEGORY_ID = p_parent_id
  AND    CHILD_CATEGORY_ID = p_child_id;

  xErrLoc := 500;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.delete_child_category('
        || xErrLoc || '): ' || SQLERRM);

END delete_child_category;

/**
 ** Proc : create_category
 ** Desc : Create a new category with the specified name + key.
 **        If parent is specified, a new link will be created.
 **        This method assumes all parameters are validated, and
 **        it will create rows for each installed language.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_category (p_category_id	OUT NOCOPY NUMBER,
                           p_key		IN VARCHAR2,
                           p_name		IN VARCHAR2,
                           p_description	IN VARCHAR2,
                           p_type		IN NUMBER,
                           p_language		IN VARCHAR2,
                           p_parent_id		IN NUMBER DEFAULT -1,
                           p_request_id		IN NUMBER DEFAULT -1,
                           p_user_id            IN NUMBER,
                           p_login_id           IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  xTableName      VARCHAR2(30);
  xViewName       VARCHAR2(30);
  xStatement      VARCHAR2(500);

BEGIN
  xErrLoc := 100;

  select icx_por_categoryid.nextval
  into   p_category_id
  from   DUAL;

  xErrLoc := 200;

  FOR language_row IN installed_languages_csr LOOP

    xErrLoc := 300;

    --Changes for userId, loginId
    INSERT INTO ICX_CAT_CATEGORIES_TL
    (RT_CATEGORY_ID, LANGUAGE, SOURCE_LANG, CATEGORY_NAME,
     DESCRIPTION, TYPE, KEY, UPPER_KEY, TITLE, CREATED_BY,
     CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN, UPPER_CATEGORY_NAME, REQUEST_ID, REBUILD_FLAG,SECTION_MAP)
    VALUES
    (p_category_id, language_row.language_code, p_language, p_name,
     p_description, p_type, p_key, upper(p_key), NULL, p_user_id,
     SYSDATE, p_user_id, SYSDATE, p_login_id, upper(p_name), p_request_id, 'N',
     lpad('0','300','0'));

  END LOOP;

  xErrLoc := 350;
  if (p_parent_id <> -1) then

    xErrLoc := 400;
    --Changes for userId, loginId
    add_child_category(p_parent_id, p_category_id, p_user_id, p_login_id);

  elsif (p_type = NAVIGATION_TYPE) then

    -- Bug#2959731: pcreddy- Add the navigational category to root by default.
    xErrLoc := 450;
    add_child_category(0, p_category_id, p_user_id, p_login_id);

  end if;

  xErrLoc := 500;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.create_category('
        || xErrLoc || '): ' || SQLERRM);

END create_category;

/**
 ** Proc : create_descriptor
 ** Desc : Create a new local descriptor within a category.
 **        A dynamic category table will be created if it doesn't
 **        exist, and a new column is added to this table.
 **        This method assumes everything is validated before
 **        calling. And it will create rows for each installed language.
 **/
/* OEX_IP_PORTING: added 3 p-arameters for section tag, storedintable, storedincolumn */
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_descriptor (p_descriptor_id		OUT NOCOPY NUMBER,
                             p_key			      IN VARCHAR2,
                             p_name 			IN VARCHAR2 DEFAULT NULL,
                             p_description		IN VARCHAR2 DEFAULT NULL,
                             p_type			      IN VARCHAR2 DEFAULT
                                                          TEXT_TYPE,
                             p_sequence			IN NUMBER,
                             p_search_results_visible	IN VARCHAR2 DEFAULT NO,
                             p_item_detail_visible	IN VARCHAR2 DEFAULT NO,
                             p_searchable	      	IN VARCHAR2 DEFAULT NO,
                             p_required			IN VARCHAR2 DEFAULT NO,
                             p_refinable		IN VARCHAR2 DEFAULT NO,
                             p_multivalue               IN VARCHAR2 DEFAULT NO,
                             p_default_value		IN VARCHAR2 DEFAULT NULL,
                             p_language			IN VARCHAR2,
                             p_category_id 		IN NUMBER,
                             p_request_id	        IN NUMBER DEFAULT -1,
                             p_section_tag		OUT NOCOPY NUMBER,
                             p_stored_in_table	        OUT NOCOPY VARCHAR2,
                             p_stored_in_column	        OUT NOCOPY VARCHAR2,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER )
IS

  xErrLoc         INTEGER := 0;

  xColumnType     VARCHAR2(30);
  xTableName      VARCHAR2(30);
  xStatement      VARCHAR2(500);
  xDummyDescId    NUMBER;

  xRebuildFlag	VARCHAR2(1) := 'N';

  l_type		  VARCHAR2(1);
  l_sequence		NUMBER;
  l_search_results_visible VARCHAR2(1);
  l_item_detail_visible	   VARCHAR2(1);
  l_searchable	      	   VARCHAR2(1);
  l_required			   VARCHAR2(1);
  l_refinable		       VARCHAR2(1);
  l_multivalue             VARCHAR2(1);

BEGIN

  IF (p_type IS NULL) THEN
     l_type :=  TEXT_TYPE; --Default is text type: Bug#2611529
  ElSE
     l_type :=  p_type;
  END IF;

  IF (p_sequence IS NULL) THEN
    select floor(max(sequence))+1 into l_sequence
    from icx_cat_descriptors_tl
    where rt_category_id = p_category_id
    and language = p_language;
--OEX_IP_PORTING    and class in ('ICX_BASE_ATTR','IPD_BASE_ATTR', 'POM_PRICE_ATTR', 'ICX_CAT_ATTR');
  ElSE
    l_sequence :=p_sequence;
  END IF;

  IF (p_search_results_visible IS NULL) THEN
    l_search_results_visible := NO;
  ELSE
    l_search_results_visible := p_search_results_visible;
  END IF;

  IF (p_item_detail_visible IS NULL) THEN
    l_item_detail_visible := YES;
  ELSE
    l_item_detail_visible := p_item_detail_visible;
  END IF;

  IF (p_searchable IS NULL) THEN
    l_searchable := NO;
  ELSE
    l_searchable := p_searchable;
  END IF;

  IF (p_required IS NULL) THEN
    l_required := NO;
  ELSE
    l_required := p_required;
  END IF;

  IF (p_refinable IS NULL) THEN
    l_refinable := NO;
  ElSE
    l_refinable := p_refinable;
  END IF;

  IF (p_multivalue IS NULL) THEN
    l_multivalue := NO;
  ELSE
    l_multivalue := p_multivalue;
  END IF;

  IF (l_multivalue IS NULL or l_multivalue = NO) THEN
    xErrLoc := 100;

    -- Bug 1404129, zxzhang
    -- Disable editing root category
    -- jinwang : enable to edit root category attribute
    if (p_category_id < 0) then
      return;
    end if;

    xErrLoc := 200;

    -- Get the new descriptor id

    select icx_por_descriptorid.nextval
    into   p_descriptor_id
    from   dual;

    xErrLoc := 300;

    if (l_type = TEXT_TYPE or l_type = TRANSLATABLE_TEXT_TYPE) then
      xColumnType := 'VARCHAR2(' || to_char(DEFAULT_COLUMN_SIZE) || ')';
    elsif (l_type = NUMERIC_TYPE or l_type = INTEGER_TYPE) then
      xColumnType := 'NUMBER';
    elsif (l_type = DATE_TYPE) then
      xColumnType := 'DATE';
    else
      xColumnType := 'VARCHAR2(' || to_char(DEFAULT_COLUMN_SIZE) || ')';
    end if;

    xErrLoc := 400;


    xErrLoc := 600;

    -- Reset category view
    -- Commented out, as is not needed in Exchange, only in IP
    -- reset_category_view(p_category_id);

    xErrLoc := 700;

    -- Insert into icx_cat_descriptors_tl table

    xErrLoc := 750;

    --Changes for userId, loginId
    create_descriptor_metadata (p_descriptor_id, p_key, p_name,
	           		      p_description, l_type, l_sequence,
		      	      l_search_results_visible, l_item_detail_visible,
			            l_searchable, l_required, l_refinable, l_multivalue,
			            p_default_value, p_language, p_category_id,
			            p_request_id, xRebuildFlag, xDummyDescId,
                                    p_user_id, p_login_id);

    xErrLoc := 800;

    -- update the icx_cat_schema_versions
    inc_schema_change_version(p_category_id);

    xErrLoc := 900;

    -- OEX_IP_PORTING: Added l_type as parameter
    assign_section_tag(p_category_id, p_descriptor_id, p_section_tag, p_stored_in_table, p_stored_in_column, l_type );

  END IF;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        RAISE_APPLICATION_ERROR(-20000,
          'Exception at ICX_POR_SCHEMA_UPLOAD.create_descriptor('
          || xErrLoc || '): ' || SQLERRM);

END create_descriptor;


/**
 ** Proc : create_descriptor_metadata
 ** Desc : Insert a new local descriptor into icx_cat_descriptors_tl.
 **        This method simply pulls out the metadata section of a descriptor
 **        that gets inserted into ICX_DESCRIPTORS_TL. This is done to
 **        separate the insertion of data, from the creation of a dynamic
 **        table. And is called directly in online category creation.
 **        This method assumes everything is validated before
 **        calling. And it will create rows for each installed language.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_descriptor_metadata (p_descriptor_id		IN NUMBER,
                             p_key			            IN VARCHAR2,
                             p_name 		          	IN VARCHAR2,
                             p_description	      	IN VARCHAR2,
                             p_type		            	IN VARCHAR2,
                             p_sequence				IN NUMBER,
                             p_search_results_visible		IN VARCHAR2,
                             p_item_detail_visible		IN VARCHAR2,
                             p_searchable				IN VARCHAR2,
                             p_required				IN VARCHAR2,
                             p_refinable				IN VARCHAR2,
                             p_multivalue      		      IN VARCHAR2,
                             p_default_value			IN VARCHAR2,
                             p_language				IN VARCHAR2,
                             p_category_id 			IN NUMBER,
			     p_request_id				IN NUMBER DEFAULT -1,
			     p_rebuild_flag         	      IN VARCHAR2,
			     p_descriptor_id_out		OUT NOCOPY NUMBER,
                             p_user_id                        IN NUMBER,
                             p_login_id                       IN NUMBER)
IS

   xErrLoc         INTEGER := 0;
   xClass          VARCHAR2(20) := NULL;

BEGIN

   p_descriptor_id_out := p_descriptor_id;

   -- if the p_descriptor_id = -1, then it is being created by adding
   -- a new descriptor to an existing category, via online editing
   -- so we must generate the id here.
   -- in the other case it has already been generated from the PL/SQL
   -- create_descriptor that calls it, unlike the edit case
  if (p_descriptor_id = -1) then
     select icx_por_descriptorid.nextval
     into   p_descriptor_id_out
     from   dual;
  end if;

  -- set the class value
  IF (p_category_id = 0) THEN
    xClass := 'ICX_BASE_ATTR';
  ELSE
    xClass := 'ICX_CAT_ATTR';
  END IF;

  xErrLoc := 100;

  --Changes for userId, loginId
  INSERT INTO icx_cat_descriptors_tl
  (RT_DESCRIPTOR_ID, RT_CATEGORY_ID, LANGUAGE, SOURCE_LANG,
   DESCRIPTOR_NAME, DESCRIPTION, TYPE, KEY, TITLE, SEQUENCE,
   DEFAULTVALUE, MULTI_VALUE_TYPE, MULTI_VALUE_KEY,
   REQUIRED, REFINABLE, SEARCHABLE, SEARCH_RESULTS_VISIBLE,
   ITEM_DETAIL_VISIBLE , CREATED_BY, CREATION_DATE,
   LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
   request_id, REBUILD_FLAG, MULTIVALUE,CUSTOMIZATION_LEVEL, CLASS)
  SELECT p_descriptor_id_out, p_category_id,
         fnd_languages.language_code, p_language,
         p_name,
         decode(p_description,'#DEL',null,p_description),
         to_number(p_type), p_key, NULL, p_sequence,
         p_default_value, NULL, NULL,
         p_required, p_refinable, to_number(p_searchable), p_search_results_visible,
         p_item_detail_visible, p_user_id, sysdate,
         p_user_id, sysdate, p_login_id, p_request_id, p_rebuild_flag, p_multivalue,
         DECODE(p_type, URL_TYPE, '111011', DATE_TYPE, '111011', '111111'),
         xClass
  FROM   fnd_languages
  WHERE  installed_flag in ('B', 'I');

  xErrLoc := 200;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.create_descriptor_metadata('
        || xErrLoc || '): ' || SQLERRM);

END create_descriptor_metadata;


-------------------------------------------------------------------------
--                            UPDATE ACTION                            --
-------------------------------------------------------------------------

/**
 ** Proc : update_category
 ** Desc : Update an existing category for a sepcified language.
 **        If parent is specified, a new link will be created.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE update_category (p_category_id	IN NUMBER,
                           p_language	IN VARCHAR2,
                           p_name		IN VARCHAR2 DEFAULT NULL,
                           p_description	IN VARCHAR2 DEFAULT NULL,
                           p_type		IN NUMBER   DEFAULT -1,
                           p_parent_id	IN NUMBER   DEFAULT -1,
                           p_request_id	IN NUMBER   DEFAULT -1,
                           p_user_id            IN NUMBER,
                           p_login_id           IN NUMBER)
IS

  xErrLoc         INTEGER := 0;
  xRebuildFlag	VARCHAR2(1) := 'N';

  xContinue     BOOLEAN := TRUE;
  xCommitSize   INTEGER := 2500;
  xLangArray    DBMS_SQL.VARCHAR2_TABLE;
  CURSOR translateLangCsr IS
    SELECT language
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    and type = p_type
    and source_lang = p_language
    and  source_lang <> language
    UNION
    SELECT p_language FROM DUAL;

BEGIN

  xErrLoc := 100;

  -- Bug 1404129, zxzhang
  -- Disable editing root category
  if (p_category_id <= 0) then
    return;
  end if;

  xErrLoc := 110;

  OPEN translateLangCsr;
  FETCH translateLangCsr BULK COLLECT into xLangArray;
  CLOSE translateLangCsr;

  xErrLoc := 120;
  FOR i in 1..xLangArray.COUNT LOOP
    xErrLoc := 130;

    -- rebuild flag
    -- 'C': catagory name changed
    -- 'D': searchable descriptor deleted
    -- 'B': both 'C' and 'D'
    --Changes for userId, loginId
    UPDATE ICX_CAT_CATEGORIES_TL
    SET    CATEGORY_NAME = NVL(p_name, CATEGORY_NAME),
           UPPER_CATEGORY_NAME = NVL(upper(p_name), UPPER_CATEGORY_NAME),
           DESCRIPTION = decode(p_description,'#DEL',null, null, DESCRIPTION,p_description),
           SOURCE_LANG = p_language,
           LAST_UPDATED_BY = p_user_id,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = p_login_id,
           REQUEST_ID = p_request_id,
           REBUILD_FLAG = decode(p_name,CATEGORY_NAME,
           --p_name=CATEGORY_NAME, no change
           rebuild_flag,
           --p_name is null which means category name is not changed
           null,
           rebuild_flag,
           --p_name<>CATEGORY_NAME, category name changed
           decode(rebuild_flag,'D','B','B','B','C'))
    WHERE  RT_CATEGORY_ID = p_category_id
    AND    LANGUAGE = xLangArray(i);

    xErrLoc := 140;

    -- update icx_cat_items_tlp only if it's a genus category
    IF (p_type = 2) THEN
      -- set the commit size
      fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
      xContinue := TRUE;
      WHILE xContinue LOOP
        xErrLoc := 150;
        -- Add update for primary_category_name in icx_cat_items_tlp;
        UPDATE ICX_CAT_ITEMS_TLP
        SET    primary_category_name = p_name
        WHERE  primary_category_id = p_category_id
        AND    language = xLangArray(i)
        AND    primary_category_name <> p_name
        AND    rownum <= xCommitSize ;

        xErrLoc := 160;
        IF ( SQL%ROWCOUNT < xCommitSize ) THEN
          xContinue := FALSE;
        END IF;

        xErrLoc := 170;
        COMMIT;
      END LOOP;
    END IF;
  END LOOP;
  xErrLoc := 180;

  -- commented out since type can not be changed.
  /*if (p_type <> -1) then
    UPDATE ICX_CAT_CATEGORIES_TL
    SET    TYPE = decode(p_type, -1, TYPE, p_type),
           LAST_UPDATED_BY = 0,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = 0,
           REQUEST_ID = p_request_id
    WHERE  RT_CATEGORY_ID = p_category_id;
  end if;
  */
  xErrLoc := 200;

  if (p_parent_id <> -1) then

    xErrLoc := 300;
    --Changes for userId, loginId
    add_child_category(p_parent_id, p_category_id, p_user_id, p_login_id);

  end if;

  xErrLoc := 400;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.update_category('
        || xErrLoc || '): ' || SQLERRM);

END update_category;

/**
 ** Proc : update_descriptor
 ** Desc : Update a existing local descriptor for a specified language
 **        within a category.
 **/
/* OEX_IP_PORTING: added 3 p-arameters for section tag, storedintable, storedincolumn */
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE update_descriptor (p_descriptor_id          IN NUMBER,
                             p_language		      IN VARCHAR2,
                             p_name 		      IN VARCHAR2 DEFAULT NULL,
                             p_description	      IN VARCHAR2 DEFAULT NULL,
                             p_default_value	      IN VARCHAR2 DEFAULT NULL,
                             p_sequence		      IN VARCHAR2 DEFAULT NULL,
                             p_search_results_visible IN VARCHAR2 DEFAULT NULL,
                             p_item_detail_visible    IN VARCHAR2 DEFAULT NULL,
                             p_searchable	      IN VARCHAR2 DEFAULT NULL,
                             p_required		      IN VARCHAR2 DEFAULT NULL,
                             p_refinable	      IN VARCHAR2 DEFAULT NULL,
                             p_multivalue             IN VARCHAR2 DEFAULT NULL,
                             p_request_id	      IN NUMBER   DEFAULT -1,
                             p_section_tag	      OUT NOCOPY NUMBER,
                             p_stored_in_table	      OUT NOCOPY VARCHAR2 ,
                             p_stored_in_column	      OUT NOCOPY VARCHAR2 ,
                             p_user_id                IN NUMBER,
                             p_login_id               IN NUMBER)
IS

  xErrLoc         INTEGER := 0;
  xCategoryID	NUMBER;
  -- OEX_IP_PORTING
  xType	        VARCHAR2(1) := NULL;

  xRebuildFlag	VARCHAR2(1) := 'N';
  xSearchable     VARCHAR2(1) := NULL;

BEGIN

  xErrLoc := 100;

  -- added type in select list..need this for assign_section_tag
  -- you need the type to determine the stored_in_column and store it
  -- in icx_cat_descriptors_tl, which is done in the
  -- assign_section_tag procedure
  select rt_category_id, to_char(searchable), to_char(type)
  into   xCategoryID, xSearchable, xType
  from   icx_cat_descriptors_tl
  where  rt_descriptor_id = p_descriptor_id
--OEX_IP_PORTING  AND    class IN ('ICX_BASE_ATTR','IPD_BASE_ATTR', 'POM_PRICE_ATTR', 'ICX_CAT_ATTR')
  and    rownum = 1;

  xErrLoc := 200;

  -- Bug 1404129, zxzhang
  -- Disable editing root category
  -- jinwang
  -- enable to edit root category descriptor
  if (xCategoryID < 0) then
    return;
  end if;

  xErrLoc := 240;

  if (p_searchable IS NOT NULL AND p_searchable <> xSearchable) then
    xRebuildFlag := 'Y';
  end if;

  --Changes for userId, loginId
  UPDATE icx_cat_descriptors_tl
  SET    DESCRIPTOR_NAME = NVL(p_name, DESCRIPTOR_NAME),
         DESCRIPTION = decode(p_description,'#DEL',null, null, DESCRIPTION,p_description),
         SOURCE_LANG = p_language,
         CREATION_DATE = sysdate,
         LAST_UPDATED_BY = p_user_id,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATE_LOGIN = p_login_id,
         REQUEST_ID = p_request_id
  WHERE  RT_DESCRIPTOR_ID = p_descriptor_id
  AND    LANGUAGE = p_language;

  -- update the icx_cat_schema_versions
  inc_schema_change_version(xCategoryID);

  xErrLoc := 150;

  -- Update the following for all languages

  if (p_default_value is not null or
      p_search_results_visible is not null or
      p_item_detail_visible is not null or
      p_searchable is not null or
      p_required is not null or
      p_multivalue is not null or
      p_refinable is not null) then
    UPDATE icx_cat_descriptors_tl
    SET    DEFAULTVALUE = NVL(p_default_value, DEFAULTVALUE),
           SEQUENCE = decode(p_sequence,null,sequence,'#DEL',null,to_number(p_sequence)),
           SEARCH_RESULTS_VISIBLE = TO_NUMBER(NVL(p_search_results_visible,
                                                  SEARCH_RESULTS_VISIBLE)),
           ITEM_DETAIL_VISIBLE = TO_NUMBER(NVL(p_item_detail_visible,
                                               ITEM_DETAIL_VISIBLE)),
           SEARCHABLE = TO_NUMBER(NVL(p_searchable, SEARCHABLE)),
           REQUIRED = TO_NUMBER(NVL(p_required, REQUIRED)),
           MULTIVALUE = TO_NUMBER(NVL(p_multivalue, MULTIVALUE)),
           REFINABLE = TO_NUMBER(NVL(p_refinable, REFINABLE)),
           CREATION_DATE = sysdate,
           LAST_UPDATED_BY = p_user_id,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = p_login_id,
           REQUEST_ID = p_request_id,
           REBUILD_FLAG = xRebuildFlag
    WHERE  RT_DESCRIPTOR_ID = p_descriptor_id;

    xErrLoc := 200;

  end if;

  xErrLoc := 400;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.update_descriptor('
        || xErrLoc || '): ' || SQLERRM);

END update_descriptor;


-------------------------------------------------------------------------
--                            DELETE ACTION                            --
-------------------------------------------------------------------------

/**
 ** Proc : delete_category
 ** Desc : Delete category from icx_cat_categories_tl;
 **        Delete local descriptors from icx_cat_descriptors_tl;
 **        Dlete items from icx_por_items, icx_por_items_tl and
 **        icx_cat_category_items;
 **        Delete links from icx_cat_browse_trees;
 **/
PROCEDURE delete_category (p_category_id IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  l_count         NUMBER := 0;
  l_type          NUMBER := 0;

  CURSOR toc_children(p_category_id number) IS
    select child_category_id from icx_cat_browse_trees
    where parent_category_id = p_category_id;


BEGIN

  xErrLoc := 100;

  -- Bug 1404129, zxzhang
  -- Disable editing root category
  if (p_category_id <= 0) then
    return;
  end if;

  delete from icx_cat_categories_tl
  where  rt_category_id = p_category_id;

  xErrLoc := 200;

  delete from icx_cat_descriptors_tl
  where  rt_category_id = p_category_id;

  xErrLoc := 300;

  delete from icx_cat_browse_trees
  where  child_category_id = p_category_id;

  xErrLoc := 700;
  -- OEX_IP_PORTING:  Check
  -- drop_category_table(p_category_id);

  xErrLoc := 800;
    FOR c_child IN toc_children(p_category_id) LOOP

    delete from icx_cat_browse_trees
    where  child_category_id = c_child.child_category_id
    and    parent_category_id = p_category_id;
    xErrLoc := 810;

    select count(*) into l_count
    from icx_cat_browse_trees
    where child_category_id = c_child.child_category_id;
    xErrLoc := 820;

    if ( l_count = 0 ) then
      SELECT type INTO l_type
      FROM   icx_cat_categories_tl
      WHERE  rt_category_id = c_child.child_category_id
      AND    language = USERENV('LANG');
      xErrLoc := 830;

      -- only if the child is a navigational category
      if ( l_type = 1 ) then
        INSERT INTO icx_cat_browse_trees
         (parent_category_id, child_category_id,
          LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LAST_UPDATE_DATE,
          CREATED_BY, CREATION_DATE)
        VALUES
         (0, c_child.child_category_id, 0, 0, sysdate, 0, sysdate);
      end if;
      xErrLoc := 840;
   end if;

  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.delete_category('
        || xErrLoc || '): ' || SQLERRM);

END delete_category;


/**
 ** Proc : delete_category_tree
 ** Desc : Navigate the subtree, delete the whole subtree and items
 **        associated.
 **/

PROCEDURE delete_category_tree (p_category_id IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  --
  -- Cursot to fetch child categories
  --
  CURSOR child_categories_csr (p_category_id NUMBER) IS
    select distinct cat.rt_category_id,
           cat.type
      from icx_cat_categories_tl cat,
           icx_cat_browse_trees toc
     where toc.parent_category_id = p_category_id
       and toc.child_category_id = cat.rt_category_id;

BEGIN

  xErrLoc := 100;

  delete_category(p_category_id);

  xErrLoc := 200;

  FOR categories IN child_categories_csr(p_category_id) LOOP
    xErrLoc := 300;

    -- Only navigate category has subtree
    if (categories.type = NAVIGATION_TYPE) then
      xErrLoc := 400;
      delete_category_tree(categories.rt_category_id);
      xErrLoc := 450;
    elsif (categories.type = GENUS_TYPE) then
      xErrLoc := 500;
      delete_category(categories.rt_category_id);
      xErrLoc := 550;
    end if;

  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.delete_category_tree('
        || xErrLoc || '): ' || SQLERRM);

END delete_category_tree;


/**
 ** Proc : delete_descriptor
 ** Desc : Delete the local descriptor within a category.
 **        If no local descriptors for this category, the
 **        dynamic table and view will be dropped.
 **/
 --Bug#3027134 Added who columns in icx_cat_deleted_attributes
 --as part of ECM OA Rewrite
 --So add two parameters for user_id and login_id to delete_descriptors
 --to populate the who columns in icx_cat_deleted_attributes.

PROCEDURE delete_descriptor (p_descriptor_id IN NUMBER,
                             p_request_id	 IN NUMBER   DEFAULT -1,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER)
IS

  xErrLoc         INTEGER := 0;

  xCategoryID     NUMBER;

  xColumnName     VARCHAR2(30);
  xColumnType     VARCHAR2(30);
  xTableName      VARCHAR2(30);
  xStatement      VARCHAR2(500);
  xStoredInColumn VARCHAR2(30);
  xStoredInTable  VARCHAR2(30);
  xSearchable     VARCHAR2(1);
  xType           VARCHAR2(30);

BEGIN

  xErrLoc := 100;

  select rt_category_id, to_char(searchable), to_char(type),
  stored_in_table, stored_in_column
  into   xCategoryID, xSearchable, xType,
  xStoredInTable, xStoredInColumn
  from   icx_cat_descriptors_tl
  where  rt_descriptor_id = p_descriptor_id
--OEX_IP_PORTING  AND    class IN ('ICX_BASE_ATTR', 'IPD_BASE_ATTR', 'POM_PRICE_ATTR', 'ICX_CAT_ATTR')
  and    rownum = 1;

  xErrLoc := 200;

  -- Prevent from deleting the seeded root descriptors.
  if (p_descriptor_id <= NUM_SEEDED_DESCRIPTORS) then
    return;
  end if;

  xErrLoc := 240;

  release_section_tag(xCategoryID, p_descriptor_id);

  xErrLoc := 400;

  delete from icx_cat_descriptors_tl
  where  rt_descriptor_id = p_descriptor_id;

  xErrLoc := 600;

  -- update the icx_cat_schema_versions
  inc_schema_change_version(xCategoryID);
  xErrLoc := 700;

  -- rebuild flag
  -- 'C': catagory name changed
  -- 'D': searchable descriptor deleted
  -- 'B': both 'C' and 'D'

  -- rebuild index if the deleted descriptor is searchable
  if (xSearchable = YES) then
    update icx_cat_categories_tl
    set rebuild_flag = decode(rebuild_flag,'C','B','B','B','D'),
        REQUEST_ID =p_request_id
    where rt_category_id = xCategoryID;
  end if;

  xErrLoc := 800;

  -- populate the deleted_descriptors table so that the descriptor column
  -- values will be erased in the items_tlp/ext_items_tlp table later.
  --Bug#3027134 Added who columns in icx_cat_deleted_attributes
  --as part of ECM OA Rewrite
  --So populate the who columns in icx_cat_deleted_attributes.
  insert into icx_cat_deleted_attributes
  (rt_category_id, rt_descriptor_id, stored_in_table, stored_in_column,
   last_update_login, last_updated_by, last_update_date, created_by,
   creation_date)
  values (xCategoryID, p_descriptor_id, xStoredInTable, xStoredInColumn,
   p_login_id, p_user_id, sysdate, p_user_id, sysdate);

  xErrLoc := 900;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.delete_descriptor('
        || xErrLoc || '): ' || SQLERRM);

END delete_descriptor;

-------------------------------------------------------------------------
--                             Validation                              --
-------------------------------------------------------------------------

PROCEDURE validate_descriptor(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_user_action IN VARCHAR2,
                             p_system_action OUT NOCOPY VARCHAR2,
                             p_language IN VARCHAR2,
                             p_descriptor_id OUT NOCOPY NUMBER,
                             p_key IN VARCHAR2,
                             p_name IN VARCHAR2,
                             p_type IN VARCHAR2,
                             p_description IN VARCHAR2,
                             p_required IN VARCHAR2,
                             p_sequence IN VARCHAR2,
                             p_searchable IN VARCHAR2,
                             p_multivalue IN VARCHAR2,
                             p_itemdetailvisible IN VARCHAR2,
                             p_searchResultsVisible IN VARCHAR2,
                             p_owner_key IN VARCHAR2,
                             p_owner_name IN VARCHAR2,
                             p_owner_id OUT NOCOPY NUMBER,
                             p_is_valid OUT NOCOPY VARCHAR2) IS
  l_progress VARCHAR2(10) := '000';
  l_return_val VARCHAR2(1) := 'Y';
  l_num_val NUMBER := 0;
  l_current_type VARCHAR2(30) := NULL;
  l_name VARCHAR2(250) := NULL;
  l_sequence NUMBER := -1;
  l_searchvisible VARCHAR2(1) := NULL;
  l_searchable VARCHAR2(1):= NULL;
  l_detailvisible VARCHAR2(1) := NULL;
  l_required VARCHAR2(1) := NULL;
  l_class VARCHAR2(30) := NULL;
  l_multivalue VARCHAR2(1) := NULL;
  l_customizelevel VARCHAR2(30) := NULL;
  l_tableName VARCHAR2(30);
  l_columnName VARCHAR2(30);
  l_statement VARCHAR2(500);

  l_cursor INTEGER := 0;
  l_count  NUMBER := -1;
  result NUMBER;

BEGIN

  p_descriptor_id := NULL;
  p_owner_id := NULL;

  IF (p_user_action IN ('SYNC', 'DELETE')) THEN
    -- Check key is not null and is unique
    l_progress := '001_0';

    -- Check owner is not null
    IF (p_owner_key IS NULL AND p_owner_name IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_CAT_ATTRIB_OWNER_KEY', 'ICX_POR_INVALID_CATEGORY',
        p_line_number);
      l_return_val := 'N';
    ELSE

      IF (p_owner_key IS NOT NULL) THEN
        BEGIN
          l_progress := '002_1';

          SELECT rt_category_id INTO p_owner_id
          FROM icx_cat_categories_tl
          WHERE upper_key = UPPER(p_owner_key)
          AND language = p_language
          AND type IN (0,2);

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_ATTRIB_OWNER_KEY',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;
      END IF;

      IF (p_owner_name IS NOT NULL) THEN
        BEGIN
          l_progress := '002_3';

          SELECT rt_category_id INTO p_owner_id
          FROM icx_cat_categories_tl
          WHERE upper_category_name = UPPER(p_owner_name)
          AND language = p_language
          AND type IN (0,2);

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_ATTRIB_OWNER_NAME',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;
      END IF;

    END IF;

    IF (p_key IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_ATTRIB_KEY', 'ICX_POR_CAT_FIELD_REQUIRED', p_line_number);
      l_return_val := 'N';

      -- Validate the rest as an ADD action
      IF (p_user_action = 'SYNC') THEN
        p_system_action := 'ADD';
      ELSIF (p_user_action = 'DELETE') THEN
        p_system_action := 'DELETE';
      END IF;

    ELSE

      IF (p_owner_id IS NOT NULL) THEN

        BEGIN
          l_progress := '002_4';

          SELECT rt_descriptor_id, rt_category_id, to_char(type),
                 descriptor_name, sequence, search_results_visible,
                 to_char(searchable), item_detail_visible, class,
                 to_char(required), multivalue, customization_level
          INTO p_descriptor_id, p_owner_id, l_current_type,
               l_name, l_sequence, l_searchvisible, l_searchable,
               l_detailvisible, l_class, l_required, l_multivalue,
               l_customizelevel
          FROM icx_cat_descriptors_tl
          WHERE UPPER(key) = UPPER(p_key)
          AND language = p_language
          AND rt_category_id = p_owner_id
--OEX_IP_PORTING          AND class in('ICX_BASE_ATTR','IPD_BASE_ATTR','POM_PRICE_ATTR','ICX_CAT_ATTR')
          AND rownum = 1;

          IF (p_user_action = 'SYNC') THEN
            p_system_action := 'UPDATE';
          ELSIF (p_user_action = 'DELETE') THEN
            p_system_action := 'DELETE';
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            IF (p_user_action = 'SYNC') THEN
              p_system_action := 'ADD';
            ELSIF (p_user_action = 'DELETE') THEN
              p_system_action := 'DELETE';
              InsertError(p_request_id,'ICX_POR_ATTRIB_KEY','ICX_POR_CAT_INVALID_ATTRIB',
                p_line_number);
              l_return_val := 'N';
            END IF;
        END;

      ELSE
         IF (p_user_action = 'SYNC') THEN
           p_system_action := 'ADD';
         ELSIF (p_user_action = 'DELETE') THEN
           p_system_action := 'DELETE';
         END IF;
      END IF;

    END IF;

  ELSE
    p_system_action := p_user_action;
  END IF;

  IF (p_system_action = 'ADD') THEN
    -- Add Action

    -- Check name is not null
    IF (p_name IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_ATTRIB_NAME', 'ICX_POR_CAT_FIELD_REQUIRED',
        p_line_number);
      l_return_val := 'N';
    ELSE
      -- Check uniqueness if owner is known
      IF (p_owner_id IS NOT NULL) THEN

        BEGIN
          l_progress := '003_1';
          l_num_val := 0;

          IF (p_owner_id = 0) THEN
            -- check uniqueness against all the descriptor names
            SELECT 1 INTO l_num_val
            FROM dual WHERE EXISTS (
            SELECT 1 FROM icx_cat_descriptors_tl
            WHERE UPPER(descriptor_name) = UPPER(p_name));
            --AND language = p_language
--OEX_IP_PORTING            AND class in('ICX_BASE_ATTR','IPD_BASE_ATTR','POM_PRICE_ATTR','ICX_CAT_ATTR'));
          ELSE
            -- check uniqueness against root descriptors and the
            -- descriptors inside that particular category
            SELECT 1 INTO l_num_val
            FROM dual WHERE EXISTS (
            SELECT 1 FROM icx_cat_descriptors_tl
            WHERE UPPER(descriptor_name) = UPPER(p_name)
            AND (rt_category_id = p_owner_id OR rt_category_id = 0));
            --AND language = p_language
--OEX_IP_PORTING            AND class in('ICX_BASE_ATTR','IPD_BASE_ATTR','POM_PRICE_ATTR','ICX_CAT_ATTR'));
          END IF;

          InsertError(p_request_id,'ICX_POR_ATTRIB_NAME','ICX_POR_ATTRIB_NAME_UNIQUE_M',
            p_line_number);
          l_return_val := 'N';
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;

      END IF;

    END IF;

    -- jinwang:
    -- check the uniqueness of the key
    IF (p_owner_id IS NOT NULL AND p_key IS NOT NULL) THEN
      BEGIN
        l_progress := '003_2';
        l_num_val := 0;

        IF (p_owner_id = 0) THEN
          -- check uniqueness against all the descriptor keys
          SELECT 1 INTO l_num_val
          FROM dual WHERE EXISTS (
          SELECT 1 FROM icx_cat_descriptors_tl
          WHERE UPPER(key) = UPPER(p_key)
          AND language = p_language);
        ELSE
          -- check uniqueness against root descriptors and the
          -- descriptors inside that particular category
          SELECT 1 INTO l_num_val
          FROM dual WHERE EXISTS (
          SELECT 1 FROM icx_cat_descriptors_tl
          WHERE UPPER(key) = UPPER(p_key)
          AND (rt_category_id = p_owner_id OR rt_category_id = 0)
          AND language = p_language);
        END IF;

        --Code will mostly not come here !!!!!CHECK!!!!!
        InsertError(p_request_id,'ICX_POR_ATTRIB_KEY','ICX_POR_ATTRIB_KEY_UNIQUE_M',
            p_line_number);
        l_return_val := 'N';
      EXCEPTION
        WHEN no_data_found THEN
          null;
      END;

    END IF;

    l_progress := '004';

    -- jinwang
    -- validate rule: can add REQUIRED base attribute only if no item exists
    --                in the exchange;
    --                can add REQUIRED category attribute only if no item exists
    --                in that category;
    IF (p_required = YES AND p_owner_id IS NOT NULL AND p_key IS NOT NULL) THEN
      BEGIN
          l_num_val := 0;

          IF (p_owner_id = 0) THEN
            SELECT 1 INTO l_num_val
            FROM dual WHERE EXISTS (
            SELECT 1 FROM icx_cat_category_items);

          ELSE
            SELECT 1 INTO l_num_val
            FROM dual WHERE EXISTS (
            SELECT 1 FROM icx_cat_category_items
            WHERE rt_category_id = p_owner_id);

          END IF;

          -- smallya 04/13/2001 added if else condition to display different messages
          -- for base and category attributes , bug number : 1736317
          IF (p_owner_id = 0) THEN
            InsertError(p_request_id,'ICX_POR_CAT_ATTRIB_REQUIRED','ICX_POR_BASE_N_ADD_REQD',p_line_number);
          ELSE
            InsertError(p_request_id,'ICX_POR_CAT_ATTRIB_REQUIRED','ICX_POR_CAT_N_ADD_REQD',p_line_number);
          END IF;

          l_return_val := 'N';
        EXCEPTION
          WHEN no_data_found THEN
            null;
        END;
    END IF;

    -- jinwang
    -- validate rule: Number of Base Attriutes < 100 (per descriptor TYPE)
    l_num_val := 0;

    SELECT COUNT(*) INTO l_num_val
    FROM icx_cat_descriptors_tl
    WHERE rt_category_id = 0
    AND language = p_language
    AND to_char(type) = p_type; -- OEX_IP_PORTING

    -- OEX_IP_PORTING
    IF (l_num_val >= 100 AND p_owner_id IS NOT NULL AND p_owner_id = 0) THEN
      InsertError(p_request_id,'ICX_POR_ATTRIB_KEY','ICX_POR_BASE_ATT_NUM_EXCEED',
                  p_line_number);
      l_return_val := 'N';
    END IF;

    -- jinwang
    -- validate rule: Number of Category attribute < 50 per type, per category
    IF (p_owner_id IS NOT NULL AND p_owner_id <> 0) THEN
      l_num_val := 0;

      SELECT COUNT(*) INTO l_num_val
      FROM icx_cat_descriptors_tl
      WHERE rt_category_id = p_owner_id
      AND language = p_language
      AND to_char(type) = p_type; -- OEX_IP_PORTING

      IF (l_num_val >= 50) THEN
        InsertError(p_request_id,'ICX_POR_ATTRIB_KEY','ICX_POR_CAT_ATT_NUM_EXCEED',
                    p_line_number);
        l_return_val := 'N';
      END IF;
    END IF;

  ELSIF (p_system_action = 'UPDATE') THEN
    -- Update Action

    -- If specified, check name is not already used by another category
    -- We only check the other categories so the user can specify the same name
    -- during update

    -- jinwang l_progress := '005_0';
    -- validate rule: can not update any pricing attributes
    -- Commenting Out as not supported in IP
    /*****
    IF (l_class = 'POM_PRICE_ATTR') THEN
      InsertError(p_request_id, 'ICX_POR_ATTRIB_KEY', 'POM_CAT_CHANGE_PRICE_ATTR',
                  p_line_number);
      l_return_val := 'N';
    ELSE
    ******/

    IF (p_name IS NOT NULL) THEN

    -- No need to check whether p_owner_id is null coz in that case
    -- p_system_action will be 'ADD'

      BEGIN
        l_progress := '005_1';
        l_num_val := 0;

        IF (p_owner_id = 0) THEN
          -- check uniqueness against all the other descriptor names
          SELECT 1 INTO l_num_val
          FROM dual WHERE EXISTS (
          SELECT 1 FROM icx_cat_descriptors_tl
          WHERE UPPER(descriptor_name) = UPPER(p_name)
          AND rt_descriptor_id <> p_descriptor_id);
          --AND language = p_language
        ELSE
          -- check uniqueness against root descriptors and the other
          -- descriptors inside that particular category
          SELECT 1 INTO l_num_val
          FROM dual WHERE EXISTS (
          SELECT 1 FROM icx_cat_descriptors_tl
          WHERE UPPER(descriptor_name) = UPPER(p_name)
          AND (rt_category_id = p_owner_id OR rt_category_id = 0)
          AND rt_descriptor_id <> p_descriptor_id);
          --AND language = p_language
        END IF;

        InsertError(p_request_id, 'ICX_POR_ATTRIB_NAME', 'ICX_POR_ATTRIB_NAME_UNIQUE_M',
          p_line_number);
        l_return_val := 'N';

      EXCEPTION
        WHEN no_data_found THEN
          -- name is unique
          null;
      END;

    END IF;

    l_progress := '005_2';

    -- jinwang
        l_progress := '005_3';

    -- jinwang
    -- validate rule: type can not be updated
    IF (p_type IS NOT NULL AND p_type <> l_current_type) THEN
      -- Cannot update type
      InsertError(p_request_id, 'ICX_POR_CAT_CATEGORY_TYPE', 'ICX_POR_CAT_CHANGE_TYPE',
                  p_line_number);
      l_return_val := 'N';
    END IF;

    l_progress := '005_4';
  ELSE
    --Bug#2743930
    --IF (SUBSTR(l_customizelevel,1,1) = 0) THEN
    -- Check name is not null
    IF (p_descriptor_id IS NOT NULL AND
        p_descriptor_id <= NUM_SEEDED_DESCRIPTORS) THEN
      IF (p_name IS NOT NULL) THEN
        InsertError(p_request_id, 'ICX_POR_ATTRIB_NAME', 'ICX_POR_CAT_DELETE_RESERVED',
                    p_line_number);
        l_return_val := 'N';
      ELSIF (p_key IS NOT NULL) THEN
        InsertError(p_request_id, 'ICX_POR_ATTRIB_KEY', 'ICX_POR_CAT_DELETE_RESERVED',
                    p_line_number);
        l_return_val := 'N';
      END IF;
    END IF;
  END IF;

  l_progress := '010';

  p_is_valid := l_return_val;

  IF(p_owner_id IS NULL) THEN
    p_owner_id := -1;
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at ICX_POR_SCHEMA_UPLOAD.validate_descriptor(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END validate_descriptor;

PROCEDURE validate_category(p_request_id IN OUT NOCOPY NUMBER,
                           p_line_number IN NUMBER,
                           p_user_action IN VARCHAR2,
                           p_system_action OUT NOCOPY VARCHAR2,
                           p_language IN VARCHAR2,
                           p_category_id OUT NOCOPY NUMBER,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_type_value OUT NOCOPY VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2,
                           p_owner_id OUT NOCOPY NUMBER,
                           p_is_valid OUT NOCOPY VARCHAR2) IS
  l_progress VARCHAR2(10) := '000';
  l_return_val VARCHAR2(1) := 'Y';
  l_num_val NUMBER := 0;
  l_action VARCHAR2(10) := 'ADD';
  l_current_type NUMBER := NULL;
BEGIN

  p_owner_id := NULL;
  p_type_value := NULL;
  p_category_id := NULL;

  IF (p_user_action IN ('SYNC', 'DELETE')) THEN
    -- Check key is not null
    l_progress := '000';

    IF (p_key IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_CATEGORY_KEY', 'ICX_POR_CAT_FIELD_REQUIRED',
        p_line_number);
      l_return_val := 'N';

      -- Validate the rest as in an ADD action
      IF (p_user_action = 'DELETE') THEN
        p_system_action := 'DELETE';
      ELSE
        p_system_action := 'ADD';
      END IF;

    ELSE

      l_progress := '000_1';

      BEGIN
        SELECT rt_category_id, type INTO p_category_id, l_current_type
        FROM icx_cat_categories_tl
        WHERE upper_key = UPPER(p_key)
        AND language = p_language
        AND rownum = 1;

        IF (p_user_action = 'SYNC') THEN
          p_system_action := 'UPDATE';
        ELSIF (p_user_action = 'DELETE') THEN
          p_system_action := 'DELETE';
        END IF;

      EXCEPTION
        WHEN no_data_found THEN
          IF (p_user_action = 'SYNC') THEN
            p_system_action := 'ADD';
          ELSIF (p_user_action = 'DELETE') THEN
            p_system_action := 'DELETE';
            InsertError(p_request_id,'ICX_POR_CATEGORY_KEY','ICX_POR_INVALID_CATEGORY',
              p_line_number);
            l_return_val := 'N';
          END IF;
      END;

    END IF;

  ELSE
    p_system_action := p_user_action;
  END IF;

  IF (p_system_action = 'ADD') THEN
    -- Add Action

    l_progress := '003';

    -- Check name is not null and is unique
    IF (p_name IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_CATEGORY_NAME', 'ICX_POR_CAT_FIELD_REQUIRED',
        p_line_number);
      l_return_val := 'N';
    ELSE
      l_progress := '004';
      l_num_val := 0;

      SELECT count(1) INTO l_num_val
      FROM icx_cat_categories_tl
      WHERE upper_category_name = UPPER(p_name);
      --AND language = p_language

      IF (l_num_val > 0) THEN
        InsertError(p_request_id, 'ICX_POR_CATEGORY_NAME', 'ICX_POR_CAT_NAME_UNIQUE_M',
          p_line_number);
        l_return_val := 'N';
      END IF;

    END IF;

    l_progress := '005';

    -- Default type to GENUS
    IF (p_type IS NULL) THEN
      null;
--      InsertError(p_request_id, 'ICX_POR_CAT_CATEGORY_TYPE', 'ICX_POR_CAT_FIELD_REQUIRED', p_line_number);
--      l_return_val := 'N';
    END IF;

  ELSIF (p_system_action = 'UPDATE') THEN
    -- Update Action

    -- No need to check if key exists, since if it doesn't it would have
    -- been an 'ADD' action

    -- If specified, check name is not already used by another category
    -- We only check the other categories so the user can specify the same name
    -- during update

    l_progress := '006';

    IF (p_name IS NOT NULL) THEN
      l_num_val := 0;

      SELECT count(1) INTO l_num_val
      FROM icx_cat_categories_tl
      WHERE upper_category_name = UPPER(p_name)
      --AND language = p_language
      AND rt_category_id <> p_category_id;

      IF (l_num_val > 0) THEN
        InsertError(p_request_id, 'ICX_POR_CATEGORY_NAME', 'ICX_POR_CAT_NAME_UNIQUE_M',
          p_line_number);
        l_return_val := 'N';
      END IF;

    END IF;

    -- jinwang
    -- validate rule: root category can not be updated
    IF (p_category_id = 0) THEN
      InsertError(p_request_id, 'ICX_POR_CATEGORY_KEY', 'ICX_POR_CAT_ROOT_DELETE',
          p_line_number);
      l_return_val := 'N';
    END IF;

  ELSIF (p_system_action = 'DELETE') THEN
    -- jinwang
    -- validate rule: root category can not be deleted
    IF (p_key IS NOT NULL AND p_category_id = 0) THEN
      InsertError(p_request_id, 'ICX_POR_CATEGORY_KEY', 'ICX_POR_CAT_ROOT_DELETE',
                  p_line_number);
      l_return_val := 'N';
    END IF;
    BEGIN

      l_progress := '006_1';

    -- check if there are any items in this category
      SELECT 1 INTO l_num_val
      FROM dual
      WHERE EXISTS (SELECT 1 FROM icx_cat_category_items
      WHERE rt_category_id = p_category_id);

      InsertError(p_request_id, 'ICX_POR_CATEGORY_KEY', 'ICX_POR_CAT_HAS_ITEMS',
        p_line_number);
      l_return_val := 'N';

    EXCEPTION
      WHEN no_data_found THEN
      -- No items for this category
        null;
    END;

  END IF;

  -- Check type
  l_progress := '010';

  -- Check to see if type is valid
  IF (p_user_action = 'SYNC' AND p_type IS NOT NULL) THEN
    IF (p_type IN ('0','1','2')) THEN
      p_type_value := p_type;
    ELSIF (p_language = 'US') THEN
      -- Hard code in the validation for speed
      IF (UPPER(p_type) = 'ROOT') THEN
        p_type_value := '0';
      ELSIF (UPPER(p_type) = 'BROWSING') THEN
        p_type_value := '1';
      ELSIF (UPPER(p_type) = 'NAVIGATION') THEN
        p_type_value := '1';
      ELSIF (UPPER(p_type) = 'ITEM') THEN
        p_type_value := '2';
      ELSIF (UPPER(p_type) = 'GENUS') THEN
        p_type_value := '2';
      ELSE
        InsertError(p_request_id, 'ICX_POR_CAT_CATEGORY_TYPE', 'ICX_POR_CAT_INVALID_TYPE',
          p_line_number);
        l_return_val := 'N';
      END IF;

    ELSE

      BEGIN
        SELECT lookup_code INTO p_type_value
        FROM fnd_lookup_values
        WHERE lookup_type = 'ICX_CAT_TYPE'
        AND UPPER(meaning) = UPPER(p_type)
        AND language = p_language;
        l_progress := '100';

      EXCEPTION
        WHEN no_data_found THEN
          InsertError(p_request_id, 'ICX_POR_CAT_CATEGORY_TYPE', 'ICX_POR_CAT_INVALID_TYPE',
            p_line_number);
          l_return_val := 'N';
      END;
    END IF;

    l_progress := '200';
    IF (p_system_action = 'UPDATE') THEN
      IF (p_type_value is not null and l_current_type <> p_type_value) THEN
        -- Cannot update type
        InsertError(p_request_id, 'ICX_POR_CAT_CATEGORY_TYPE', 'ICX_POR_CAT_CHANGE_TYPE',
          p_line_number);
        l_return_val := 'N';
      END IF;
    END IF;
  ELSIF (p_system_action IN ('UPDATE')) THEN
    p_type_value := l_current_type;
  END IF;
  l_progress := '500';

  p_is_valid := l_return_val;

  COMMIT;

EXCEPTION
  WHEN others THEN
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at ICX_POR_SCHEMA_UPLOAD.validate_category(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END validate_category;

PROCEDURE validate_hier_relationship(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_user_action IN VARCHAR2,
                             p_system_action OUT NOCOPY VARCHAR2,
                             p_language IN VARCHAR2,
                             p_parent_key IN VARCHAR2,
                             p_parent_name IN VARCHAR2,
                             p_parent_id OUT NOCOPY NUMBER,
                             p_child_key IN VARCHAR2,
                             p_child_name IN VARCHAR2,
                             p_child_id OUT NOCOPY NUMBER,
                             p_is_valid OUT NOCOPY VARCHAR2) IS
  l_progress VARCHAR2(10) := '000';
  l_return_val VARCHAR2(1) := 'Y';
  l_num_val NUMBER := -1;
  l_parent_type NUMBER := null;
BEGIN
  p_parent_id := NULL;
  p_child_id := NULL;

  IF (p_user_action = 'SYNC' OR p_user_action = 'DELETE') THEN
    -- Check parent is not null
    l_progress := '000';

    IF (p_user_action = 'SYNC') THEN
      -- SYNC is equivalent to add
      p_system_action := 'ADD';
    ELSE
      p_system_action := 'DELETE';
    END IF;

    IF (p_parent_key IS NULL AND p_parent_name IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_CAT_PARENT_KEY',
        'ICX_POR_CAT_FIELD_REQUIRED',
        p_line_number);
      l_return_val := 'N';
    ELSE

      l_progress := '010';

      IF (p_parent_key IS NOT NULL) THEN
        BEGIN
          l_progress := '020';

          -- check if parent key exists
          SELECT rt_category_id, type INTO p_parent_id, l_parent_type
          FROM icx_cat_categories_tl
          WHERE upper_key = UPPER(p_parent_key)
          AND language = p_language;

          IF (l_parent_type = 2) THEN
            InsertError(p_request_id, 'ICX_POR_CAT_PARENT_KEY',
              'ICX_POR_CAT_GENUS_PARENT', p_line_number);
            l_return_val := 'N';
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_PARENT_KEY',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;

      END IF;

      l_progress := '030';

      IF (p_parent_name IS NOT NULL) THEN
        BEGIN
          l_progress := '040';

          -- check if parent key exists
          SELECT rt_category_id, type  INTO l_num_val, l_parent_type
          FROM icx_cat_categories_tl
          WHERE upper_category_name = UPPER(p_parent_name)
          AND language = p_language;

          IF (p_parent_id IS NOT NULL) THEN

            IF (p_parent_id <> l_num_val) THEN
              -- Key and Name points to different category
              InsertError(p_request_id, 'ICX_POR_CAT_PARENT_NAME',
                'ICX_POR_CAT_REL_DIFF_KEY_NAME',
                p_line_number);
              l_return_val := 'N';
            END IF;

          ELSE
            p_parent_id := l_num_val;
          END IF;

          IF (l_parent_type = 2) THEN
            InsertError(p_request_id, 'ICX_POR_CAT_PARENT_NAME',
              'ICX_POR_CAT_GENUS_PARENT', p_line_number);
            l_return_val := 'N';
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_PARENT_NAME',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;

      END IF;

    END IF;

    l_progress := '050';

    IF (p_child_key IS NULL AND p_child_name IS NULL) THEN
      InsertError(p_request_id, 'ICX_POR_CAT_CHILD_KEY', 'ICX_POR_CAT_FIELD_REQUIRED',
        p_line_number);
      l_return_val := 'N';
    ELSE

      l_progress := '060';

      IF (p_child_key IS NOT NULL) THEN
        BEGIN
          -- check if child key exists
          SELECT rt_category_id INTO p_child_id
          FROM icx_cat_categories_tl
          WHERE upper_key = UPPER(p_child_key)
          AND language = p_language;

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_CHILD_KEY',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;

      END IF;

      l_progress := '070';

      IF (p_child_name IS NOT NULL) THEN
        BEGIN
          -- check if child key exists
          SELECT rt_category_id INTO l_num_val
          FROM icx_cat_categories_tl
          WHERE upper_category_name = UPPER(p_child_name)
          AND language = p_language;

          IF (p_child_id IS NOT NULL) THEN

            IF (p_child_id <> l_num_val) THEN
              -- Key and Name points to different category
              InsertError(p_request_id, 'ICX_POR_CAT_CHILD_NAME',
                'ICX_POR_CAT_REL_DIFF_KEY_NAME', p_line_number);
              l_return_val := 'N';
            END IF;

          ELSE
            p_child_id := l_num_val;
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            InsertError(p_request_id, 'ICX_POR_CAT_CHILD_NAME',
              'ICX_POR_INVALID_CATEGORY', p_line_number);
            l_return_val := 'N';
        END;

      END IF;

    END IF;

    IF (p_child_id IS NOT NULL AND p_parent_id IS NOT NULL) THEN

      IF (p_system_action = 'ADD') THEN
        IF (p_child_id = p_parent_id) THEN
	   -- Bug 1546149, zxzhang, Jan-02-00
           IF (p_child_key IS NOT NULL) THEN
             InsertError(p_request_id, 'ICX_POR_CAT_CHILD_KEY',
               'ICX_POR_CAT_SAME_PARENT_CHILD', p_line_number);
           ELSE
             InsertError(p_request_id, 'ICX_POR_CAT_CHILD_NAME',
               'ICX_POR_CAT_SAME_PARENT_CHILD', p_line_number);
           END IF;
	   l_return_val := 'N';
        END IF;
      ELSIF (p_system_action = 'DELETE') THEN

        BEGIN
          SELECT 1 INTO l_num_val
          FROM dual
          WHERE exists (SELECT 1 FROM icx_cat_browse_trees
          WHERE parent_category_id = p_parent_id
          AND child_category_id = p_child_id);

        EXCEPTION
	   WHEN no_data_found THEN
	      -- Bug 1546149, zxzhang, Jan-02-00
	      IF (p_child_key IS NOT NULL) THEN
		 InsertError(p_request_id, 'ICX_POR_CAT_CHILD_KEY',
			     --ErrMsg 'ICX_POR_CAT_SAME_PARENT_CHILD', p_line_number);
			     'ICX_POR_CAT_REL_NO_CHILD', p_line_number);
	       ELSE
		 InsertError(p_request_id, 'ICX_POR_CAT_CHILD_NAME',
			     --ErrMsg 'ICX_POR_CAT_SAME_PARENT_CHILD', p_line_number);
			     'ICX_POR_CAT_REL_NO_CHILD', p_line_number);
	      END IF;
	      l_return_val := 'N';
        END;

      END IF;

    END IF;

  END IF;

  p_is_valid := l_return_val;

  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at ICX_POR_SCHEMA_UPLOAD.validate_hier_relationship(ErrLoc = ' || l_progress ||') ' || 'SQL Error : ' || SQLERRM);
END validate_hier_relationship;


PROCEDURE InsertError(p_request_id in out NOCOPY number,
                      p_descriptor_key in varchar2,
                      p_message_name in varchar2,
                      p_line_number in number
 ) IS
  l_progress varchar2(10) := '000';
  BEGIN
    l_progress := '001';

    if (p_request_id is null) then
      l_progress := '002';
      SELECT icx_por_batch_jobs_s.nextval
      INTO   p_request_id
      FROM   sys.dual;
    end if;

    l_progress := '004';
    INSERT into icx_por_failed_line_messages (
      job_number,
      descriptor_key,
      message_name,
      line_number
    ) VALUES (
      p_request_id,
      p_descriptor_key,
      p_message_name,
      p_line_number
    );

    l_progress := '005';
    COMMIT;
  EXCEPTION
    WHEN others THEN
      -- Debug('[InsertError-'||l_progress||'] '||SQLERRM);
        RAISE_APPLICATION_ERROR
              (-20000, 'Exception at ICX_POR_SCHEMA_UPLOAD.InsertError(ErrLoc = ' || l_progress ||') ' ||
               'SQL Error : ' || SQLERRM);
  END InsertError;

/**
 ** Proc : release_section_tag
 ** Desc : Called when a descriptor is to be deleted or made not searchable
 **        SHOULD BE CALLED BEFORE THE DESCRIPTOR IS ACTUALLY DELETED
 **        Before calling this the rows in icx_cat_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id - category to be modified
 ** p_descriptor_id - descriptor to be modified
 **/
PROCEDURE release_section_tag(p_category_id IN NUMBER,
                              p_descriptor_id IN NUMBER) IS
  v_bit_position PLS_INTEGER := 0;
  v_section_map VARCHAR2(300) := NULL;
  xErrLoc PLS_INTEGER;
BEGIN
  xErrLoc := 100;

  -- Find the section map, we can use any row with p_category_id
  SELECT section_map INTO v_section_map
  FROM icx_cat_categories_tl
  WHERE rt_category_id = p_category_id AND ROWNUM = 1;

  xErrLoc := 200;

  SELECT section_tag INTO v_bit_position
  FROM icx_cat_descriptors_tl
  WHERE rt_descriptor_id = p_descriptor_id
  AND ROWNUM = 1;

  IF v_bit_position IS NULL THEN
    -- There is no section tag assigned, no need to do anything
    RETURN;
  END IF;

  xErrLoc := 300;

  UPDATE icx_cat_descriptors_tl SET section_tag = NULL
  WHERE rt_descriptor_id = p_descriptor_id;

  IF p_category_id > 0 THEN
    v_bit_position := v_bit_position - 5000;
  elsif p_descriptor_id >= NUM_SEEDED_DESCRIPTORS then
    v_bit_position := v_bit_position - 1000;
  END IF;

  v_section_map := substr(v_section_map,1,v_bit_position-1) || '0' ||
    substr(v_section_map,v_bit_position+1);

  xErrLoc := 400;

  UPDATE icx_cat_categories_tl SET section_map = v_section_map
  WHERE rt_category_id = p_category_id;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Exception at ICX_POR_SCHEMA_UPLOAD.release_section_tag(' || xErrLoc || '): ' || SQLERRM);
END release_section_tag;


/**
 ** Proc : assign_section_tag
 ** Desc : Assigns a section tag to a given searchable descriptor. If the
 **        descriptor is already assigned a tag then the assigned tag will
 **        be returned.
 **        Before calling this the rows in icx_cat_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id IN NUMBER - category to be modified
 ** p_descriptor_id IN NUMBER - descriptor to be modified
 ** p_section_tag OUT NUMBER - section tag assigned
 **/
PROCEDURE assign_section_tag(p_category_id IN NUMBER,
                             p_descriptor_id IN NUMBER,
                             p_section_tag OUT NOCOPY NUMBER,
                             p_stored_in_table OUT NOCOPY VARCHAR2,
                             p_stored_in_column OUT NOCOPY VARCHAR2,
                             p_type IN VARCHAR2
                             ) IS
  v_section_map VARCHAR2(300);
  l_section_tag  NUMBER;
  l_stored_in_column VARCHAR2(30);
  l_stored_in_table VARCHAR2(30);
  l_column_prefix VARCHAR2(10);
  xErrLoc PLS_INTEGER := 0;
BEGIN

  -- Check whether a section tag is already assigned
  SELECT section_tag, stored_in_table, stored_in_column
  INTO l_section_tag, l_stored_in_table, l_stored_in_column
  FROM icx_cat_descriptors_tl
  WHERE rt_descriptor_id = p_descriptor_id
  AND rownum = 1;

  IF (p_section_tag IS NOT NULL) THEN
  -- Section tag already assigned, just return
    -- OEX_IP_PORTING
    p_section_tag := l_section_tag;
    p_stored_in_table := l_stored_in_table;
    p_stored_in_column := l_stored_in_column;
    RETURN;
  END IF;

  xErrLoc := 100;

  -- We already do the check for max attributes per type in validate_descriptor
  -- You would never reach here if num descriptors per type is >100
  -- validate_descriptor would have thrown the error,
  -- ICX_POR_CAT_ATT_NUM_EXCEED or ICX_POR_BASE_ATT_NUM_EXCEED
  if (p_type = 0) then
    SELECT section_map, INSTR(section_map,'0', 1, 1) INTO v_section_map, p_section_tag
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    AND rownum = 1;
  elsif (p_type = 1) then
    SELECT section_map, INSTR(section_map,'0', 101, 1) INTO v_section_map, p_section_tag
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    AND rownum = 1;
  elsif (p_type =2) then
    SELECT section_map, INSTR(section_map,'0', 201, 1) INTO v_section_map, p_section_tag
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    AND rownum = 1;
  end if;


  xErrLoc := 110;

  IF (p_section_tag > 0) THEN

    -- identifythe stored_in_table and stored_in_column for the
    -- descriptor..
    -- The stored in table depends on category_id
    -- and stored in column depends on descriptor type
    if (p_category_id = 0) then
      l_stored_in_table := 'ICX_CAT_ITEMS_TLP';
      l_column_prefix := 'BASE';
    else
      l_stored_in_table := 'ICX_CAT_EXT_ITEMS_TLP';
      l_column_prefix := 'CAT';
    end if;

    -- if section tag is 1, then the stored_in_column is
    -- TEXT_<CAT/BASE>_ATTRIBUTE_1
    -- if section tag is 101, then the stored_in_column is
    -- NUM_<CAT/BASE>_ATTRIBUTE_1
    -- if section tag is 201, then the stored_in_column is
    -- TL_TEXT_<CAT/BASE>_ATTRIBUTE_1
    -- So subtract the right amount to get the number that should suffixed to the
    -- the stored in column(Done below).
    if (p_type = TEXT_TYPE) then
      l_stored_in_column := 'TEXT_'||l_column_prefix||'_ATTRIBUTE'||to_char(p_section_tag);
    elsif (p_type = NUMERIC_TYPE) then
      p_section_tag := p_section_tag - 100;
      l_stored_in_column := 'NUM_'||l_column_prefix||'_ATTRIBUTE'||to_char(p_section_tag);
      p_section_tag := p_section_tag + 100;
    else
      p_section_tag := p_section_tag - 200;
      l_stored_in_column := 'TL_TEXT_'||l_column_prefix||'_ATTRIBUTE'||to_char(p_section_tag);
      p_section_tag := p_section_tag + 200;
    end if;

    xErrLoc := 120;

    v_section_map := substr(v_section_map,1,p_section_tag-1) || '1' ||
      substr(v_section_map,p_section_tag+1);

    xErrLoc := 130;

    IF (p_category_id > 0) THEN
      p_section_tag := p_section_tag + 5000;
    ELSE
      p_section_tag := p_section_tag + 1000;
    END IF;

    xErrLoc := 200;

    UPDATE icx_cat_categories_tl SET section_map = v_section_map
    WHERE rt_category_id = p_category_id;

    xErrLoc := 300;

    UPDATE icx_cat_descriptors_tl SET section_tag = p_section_tag,
           stored_in_table = l_stored_in_table,
           stored_in_column = l_stored_in_column
    WHERE rt_descriptor_id = p_descriptor_id;

    xErrLoc := 300;

    -- OEX_IP_PORTING
    p_stored_in_table := l_stored_in_table;
    p_stored_in_column := l_stored_in_column;

  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Exception at ICX_POR_SCHEMA_UPLOAD.assign_section_tag(' || xErrLoc || '): ' || SQLERRM);
END assign_section_tag;

/**
 ** Proc : assign_all_section_tags
 ** Desc : Assigns section tags to all searchable descriptors of a given
 **        category.  This is intended to be called during the upgrade to 6.2
 **        or when batch update of a category is needed
 **        Before calling this the rows in icx_cat_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id - category to be modified
 **/
PROCEDURE assign_all_section_tags(p_category_id IN NUMBER) IS
  v_section_map VARCHAR2(300);
  v_start PLS_INTEGER;
  v_section_tag PLS_INTEGER;
  -- OEX_IP_PORTING
  v_stored_section_tag NUMBER;
  v_base_language fnd_languages.language_code%TYPE;
  v_offset PLS_INTEGER;
  v_bit_position PLS_INTEGER;
  v_typeOffset PLS_INTEGER;
  v_type PLS_INTEGER;
  xErrLoc PLS_INTEGER;
  l_stored_in_column VARCHAR2(30);
  l_stored_in_table VARCHAR2(30);

  -- Get the descriptor id..
  -- Needed to determine the section tag values
  -- Assign section map/section tag only for non-seeded attributes
  CURSOR get_assigned_descriptors(x_category_id NUMBER, x_language VARCHAR2) IS
    SELECT rt_descriptor_id, section_tag, type FROM icx_cat_descriptors_tl
    WHERE rt_category_id = x_category_id
    AND language = x_language
    AND section_tag IS NOT NULL
    AND rt_descriptor_id >1000
    ORDER BY rt_descriptor_id
;

  CURSOR get_unassigned_descriptors(x_category_id NUMBER,x_language VARCHAR2) IS
    SELECT rt_descriptor_id, type FROM icx_cat_descriptors_tl
    WHERE rt_category_id = x_category_id
    AND language = x_language
    AND section_tag IS NULL
    AND rt_descriptor_id >1000
    ORDER BY rt_descriptor_id
;

BEGIN
  v_section_map := LPAD('0',300,'0');
  -- Category attributes start with section tag=5000
  IF (p_category_id <> 0) THEN
    v_offset := 5000;
  END IF;

  xErrLoc := 100;

  SELECT language_code INTO v_base_language
  FROM fnd_languages WHERE installed_flag = 'B';

  /*
   * Step 1: Generate the bitmap based on all searchable attributes that already
   * have a section tag.  This takes care of deleted attributes or attributes
   * changed to not searchable since the corresponding bits will be cleared
   */
  xErrLoc := 200;

  FOR rec IN get_assigned_descriptors(p_category_id,v_base_language) LOOP
    v_type := rec.type;
    -- Unseeded base attributes start with section tag=1000
    if(p_category_id = 0 AND rec.rt_descriptor_id > NUM_SEEDED_DESCRIPTORS) then
      v_offset := 1000;
    elsif(rec.rt_descriptor_id <= NUM_SEEDED_DESCRIPTORS) then
      v_offset := 0;
    end if;

    xErrLoc := 220;

    v_bit_position := rec.section_tag - v_offset;
    v_section_map := substr(v_section_map,1,v_bit_position-1) || '1' || substr(v_section_map,v_bit_position+1);
    xErrLoc := 230;

    if(rec.rt_descriptor_id > 1000) then
      get_stored_in_values(rec.rt_descriptor_id, p_category_id, rec.type, rec.section_tag,
                           l_stored_in_table, l_stored_in_column);
      xErrLoc := 240;

      UPDATE icx_cat_descriptors_tl
      SET stored_in_column = l_stored_in_column,
          stored_in_table = l_stored_in_table
      WHERE rt_descriptor_id = rec.rt_descriptor_id
      AND   (stored_in_column is null OR stored_in_table is null);
    END IF;

  END LOOP;

  /*
   * Step 2: For each searchable attribute that does not have a tag assigned,
   * get the first unused tag and assign to it
   */
  xErrLoc := 300;
  v_start := 1;

  FOR rec IN get_unassigned_descriptors(p_category_id,v_base_language) LOOP
    v_type := rec.type;

    -- Within the 300 characters, the first 100 is reserved for text, 101-200 is
    -- reserved for number and 201-300 is reserved for translated text: this
    -- information is stored in v_typeOffset
--    v_section_tag := INSTR(v_section_map,'0',v_start);
    if (v_type = 0) then
      v_section_tag := INSTR(v_section_map,'0', 1, 1);
    elsif (v_type = 1) then
      v_section_tag := INSTR(v_section_map,'0', 101, 1);
    elsif (v_type = 2) then
      v_section_tag := INSTR(v_section_map,'0', 201, 1);
    end if;
    v_section_map := substr(v_section_map,1,v_section_tag-1) || '1' ||
      substr(v_section_map,v_section_tag+1);

    -- OEX_IP_PORTING: Set the section tag based on seeded/category attribute
    --                 unseeded root descriptors
    if(p_category_id <> 0 ) then
      v_stored_section_tag := v_section_tag + 5000;
    elsif(p_category_id = 0 AND rec.rt_descriptor_id > NUM_SEEDED_DESCRIPTORS) then
      v_stored_section_tag := v_section_tag + 1000;
    else
      v_stored_section_tag := v_section_tag;
    end if;

    get_stored_in_values(rec.rt_descriptor_id, p_category_id, rec.type, v_stored_section_tag,
                         l_stored_in_table, l_stored_in_column);

    UPDATE icx_cat_descriptors_tl
    SET section_tag = v_stored_section_tag,
        stored_in_column = l_stored_in_column,
        stored_in_table = l_stored_in_table
    WHERE rt_descriptor_id = rec.rt_descriptor_id;
  END LOOP;

  xErrLoc := 400;

  UPDATE icx_cat_categories_tl SET section_map = v_section_map
  WHERE rt_category_id = p_category_id;

  xErrLoc := 500;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Exception at ICX_POR_SCHEMA_UPLOAD.assign_all_section_tags(' || xErrLoc || '): ' || SQLERRM);
END assign_all_section_tags;

/**
 ** Proc : get_stored_in_values
 ** Desc : Formulates the stored_in_table, stored_in_column
 ** Parameters:
 ** p_descriptor_id - rt_descriptor_id
 ** p_category_id   - rt_category_id
 ** type            - type
 ** p_section_tag   - section_tag
 **/
PROCEDURE get_stored_in_values(p_descriptor_id IN NUMBER,
                               p_category_id IN NUMBER,
                               p_type IN VARCHAR2,
                               p_section_tag IN NUMBER,
                               p_stored_in_table OUT NOCOPY VARCHAR2,
                               p_stored_in_column OUT NOCOPY VARCHAR2) IS

  l_stored_in_column VARCHAR2(30);
  l_stored_in_table VARCHAR2(30);
  l_column_prefix VARCHAR2(10);
  v_section_tag  NUMBER := p_section_tag;
  xErrLoc PLS_INTEGER := 0;
BEGIN
  xErrLoc := 100;

  xErrLoc := 200;
  IF (p_section_tag > 0) THEN
    -- identifythe stored_in_table and stored_in_column for the
    -- descriptor..
    -- The stored in table depends on category_id
    -- and stored in column depends on descriptor type

    if (p_category_id = 0) then
      l_stored_in_table := 'ICX_CAT_ITEMS_TLP';
      l_column_prefix := 'BASE';

      if (p_descriptor_id > NUM_SEEDED_DESCRIPTORS) then
        v_section_tag := v_section_tag - 1000;
      end if;
    else
      l_stored_in_table := 'ICX_CAT_EXT_ITEMS_TLP';
      l_column_prefix := 'CAT';
      v_section_tag := v_section_tag - 5000;
    end if;
    -- if section tag is 1, then the stored_in_column is
    -- TEXT_<CAT/BASE>_ATTRIBUTE_1
    -- if section tag is 101, then the stored_in_column is
    -- NUM_<CAT/BASE>_ATTRIBUTE_1
    -- if section tag is 201, then the stored_in_column is
    -- TL_TEXT_<CAT/BASE>_ATTRIBUTE_1
    -- So subtract the right amount to get the number that should suffixed to the
    -- the stored in column(Done below).
    if (p_type = TEXT_TYPE) then
      l_stored_in_column := 'TEXT_'||l_column_prefix||'_ATTRIBUTE'||to_char(v_section_tag);
    elsif (p_type = NUMERIC_TYPE) then
      v_section_tag := v_section_tag - 100;
      l_stored_in_column := 'NUM_'||l_column_prefix||'_ATTRIBUTE'||to_char(v_section_tag);
    else
      v_section_tag := v_section_tag - 200;
      l_stored_in_column := 'TL_TEXT_'||l_column_prefix||'_ATTRIBUTE'||to_char(v_section_tag);
    end if;
    xErrLoc := 200;

    -- OEX_IP_PORTING
    p_stored_in_table := l_stored_in_table;
    p_stored_in_column := l_stored_in_column;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Exception at ICX_POR_SCHEMA_UPLOAD.get_stored_in_values(' || xErrLoc || '): ' || SQLERRM);
END get_stored_in_values;

PROCEDURE save_failed_category(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2) IS
l_progress VARCHAR2(5) := '100';
BEGIN

  --Bug#2729328
  --IF p_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CATEGORY_KEY', p_key);
  --END IF;

  --Bug#2729328
  l_progress := '200';

  --IF p_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CATEGORY_NAME', p_name);
  --END IF;

  l_progress := '300';

  IF p_type IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CAT_CATEGORY_TYPE', p_type);
  END IF;

  l_progress := '400';

  IF p_description IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CATEGORY_DESC', p_description);
  END IF;

  l_progress := '500';

  IF p_owner_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CAT_ATTRIB_OWNER_KEY', p_owner_key);
  END IF;

  l_progress := '600';

  IF p_owner_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'CATEGORY', 'ICX_POR_CAT_ATTRIB_OWNER_NAME', p_owner_name);
  END IF;

  l_progress := '700';
  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.save_failed_category(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END save_failed_category;

-- jinwang:
-- add searchresultsvisible, required, multivalues to
-- the parameter set.
PROCEDURE save_failed_descriptor(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2,
                           p_sequence IN VARCHAR2,
                           p_default_value IN VARCHAR2,
                           p_searchable IN VARCHAR2,
                           p_itemdetailvisible IN VARCHAR2,
                           p_searchresultsvisible IN VARCHAR2,
                           p_required IN VARCHAR2,
                           p_multivalue IN VARCHAR2,
			   p_errortype IN VARCHAR2) IS
l_progress VARCHAR2(5) := '100';
BEGIN

  IF p_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_ATTRIB_KEY', p_key);
  END IF;

  l_progress := '200';

  IF p_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_ATTRIB_NAME', p_name);
  END IF;

  l_progress := '300';

  IF p_type IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_CATEGORY_TYPE', p_type);
  END IF;

  l_progress := '400';

  IF p_description IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CATEGORY_DESC', p_description);
  END IF;

  l_progress := '500';

  -- Bug 1383537 - Use ICX_POR_CAT_ATTRIB_OWNER_KEY and ICX_POR_CAT_ATTRIB_OWNER_NAME
  -- instead of ICX_POR_CAT_ATTRIB_OWNER to avoid unique index violation.
  IF p_owner_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_OWNER_KEY',
    p_owner_key);
  END IF;

  l_progress := '600';

  IF p_owner_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_OWNER_NAME',
    p_owner_name);
  END IF;

  l_progress := '700';

  IF p_sequence IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_ATTRIB_SEQ', p_sequence);
  END IF;

  l_progress := '800';

  IF p_default_value IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_DEFAULT',
    p_default_value);
  END IF;

  l_progress := '900';

  IF p_searchable IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_SEARCHABLE',
    p_searchable);
  END IF;

  l_progress := '1000';

  IF p_itemdetailvisible IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTR_DETAILVISIBLE',
    p_itemdetailvisible);
  END IF;

  l_progress := '1100';

  IF p_searchresultsvisible IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_SEARCH_VISIBLE',
    p_searchresultsvisible);
  END IF;

  l_progress := '1200';

  --!!!!!CHECK!!!!!
  IF p_required IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_REQUIRED',
    p_required);
  END IF;

  l_progress := '1300';

  IF p_multivalue IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, p_errortype, 'ICX_POR_CAT_ATTRIB_MULTIVALUE',
    p_multivalue);

  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.save_failed_descriptor(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END save_failed_descriptor;

PROCEDURE save_failed_hier_relationship(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_parent_key IN VARCHAR2,
                           p_parent_name IN VARCHAR2,
                           p_child_key IN VARCHAR2,
                           p_child_name IN VARCHAR2) IS
l_progress VARCHAR2(5) := '100';
BEGIN

  IF p_parent_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'RELATIONSHIP', 'ICX_POR_CAT_PARENT_KEY',
    p_parent_key);
  END IF;

  l_progress := '110';

  IF p_parent_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'RELATIONSHIP', 'ICX_POR_CAT_PARENT_NAME',
    p_parent_name);
  END IF;

  l_progress := '120';

  IF p_child_key IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'RELATIONSHIP', 'ICX_POR_CAT_CHILD_KEY',
    p_child_key);
  END IF;

  l_progress := '110';

  IF p_child_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'RELATIONSHIP', 'ICX_POR_CAT_CHILD_NAME',
    p_child_name);
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.save_failed_hier_relationship(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END save_failed_hier_relationship;

/* this is added for bug 2108372
   the procedure itself will do nothing.
   it will be called when starting a shema bulk load job.
*/
PROCEDURE prepare_job is
   BEGIN
      null;
END prepare_job;

PROCEDURE inc_schema_change_version(p_category_id IN NUMBER) is
    xErrLoc         NUMBER := 0;
    xAttribId       NUMBER := 0;
BEGIN
    xErrLoc := 100;
    if(p_category_id = 0) then
      xAttribId := ROOT_ATTRIB_ID;
    else
      xAttribId := LOCAL_ATTRIB_ID;
    end if;

    xErrLoc := 200;

    update icx_cat_schema_versions
    set version=version+1
    where descriptor_set_id=xAttribId;

    xErrLoc := 300;

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.inc_schema_change_version('
        || xErrLoc || '): ' || SQLERRM);
END inc_schema_change_version;

-- Bug#2323821
-- Added new IN parameter line_number and use the same to insert
-- into failed_lines and failed_line_messages instead of 1, as 1 causes
-- not to display this line if there is a failure in ADMIN section also

PROCEDURE fail_root_descriptor_section(p_request_id IN OUT NOCOPY NUMBER,
                                       p_action IN VARCHAR2,
                                       p_line_number IN NUMBER) IS
l_progress VARCHAR2(5) := '100';
BEGIN

    INSERT INTO icx_por_failed_lines (job_number,
         line_number,
         action,
         row_type,
         descriptor_key,
         descriptor_value)
    VALUES (p_request_id,
         p_line_number,
         p_action,
         'DESCRIPTOR',
         'ICX_POR_ROOT_SECTION',
         'root desc section');

    l_progress := '200';
    -- Bug#2094215
    -- Currently we have dont have root descriptor row type.
    -- And for all schema errors we display key: value <Message>
    -- If we want to display  just the message for descriptor row type
    -- then you have to have a mismatch in descriptor key between
    -- failed line and failed line messages table. Once you have a different
    -- page for the schema rejected lines then we wont be displaying the
    -- key:value <message> format.
    InsertError(p_request_id, 'ICX_POR_ROOT_SECTION1',
                         'ICX_POR_ROOT_PROFILE_OFF',
                         p_line_number);

    l_progress := '300';

  COMMIT;
EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.fail_root_descriptor_section(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END fail_root_descriptor_section;

--
-- Set the descriptor columns in the items_tlp/ext_items_tlp table to null
-- when the descriptor is deleted
--
PROCEDURE sync_deleted_descriptors
IS
  --Bug#3072827
  --Removed the rt_descriptor_id from the cursor and add a distinct
  --When descriptors are deleted from online, we add CR jobs which process
  --sync_deleted_descriptors, so there could be a scenario, when rt_category_id,
  --stored_in_table and stored_in_column are same
  --with rt_descriptor_id different in icx_cat_deleted_attributes.
  --In the above case without distinct, the sync_deleted_descriptors will
  --fail with exception 'ORA-00957:duplicate column name'
  CURSOR deleted_descriptors_csr IS
    SELECT distinct rt_category_id, stored_in_table, stored_in_column
      from icx_cat_deleted_attributes order by stored_in_table, rt_category_id;
  vRtCategoryIds dbms_sql.number_table;
  --Bug#3072827 vRtDescriptorIds dbms_sql.number_table;
  vStoredInColumns dbms_sql.varchar2_table;
  vStoredInTables dbms_sql.varchar2_table;
  xErrLoc         NUMBER := 100;
  update_tlp_sql_string VARCHAR2(4000) := null;
  update_tlp_set_string VARCHAR2(4000) := null;
  update_tlp_value_string VARCHAR2(4000) := null;
  update_exttlp_sql_string VARCHAR2(4000) := null;
  update_exttlp_set_string VARCHAR2(4000) := null;
  update_exttlp_value_string VARCHAR2(4000) := null;
  numBaseAttribs NUMBER :=0;
  numCatAttribs NUMBER :=0;
  v_cursor_id NUMBER;
  nextCategoryId NUMBER :=0;
  result NUMBER;
  v_sql varchar2(255);

BEGIN

  xErrLoc := 100;
  numBaseAttribs := 0;
  numCatAttribs := 0;

  xErrLoc := 200;
  OPEN deleted_descriptors_csr;

  LOOP
    vRtCategoryIds.DELETE;
    --Bug#3072827 vRtDescriptorIds.DELETE;
    vStoredInColumns.DELETE;
    vStoredInTables.DELETE;

    xErrLoc := 300;

    FETCH deleted_descriptors_csr BULK COLLECT INTO
      vRtCategoryIds, vStoredInTables, vStoredInColumns
    LIMIT BATCH_SIZE;

    --Bug#3072827
    EXIT WHEN vRtCategoryIds.COUNT = 0;

    xErrLoc := 400;

    FOR i IN 1..vRtCategoryIds.COUNT LOOP

       if i < vRtCategoryIds.COUNT  then
         nextCategoryId := vRtCategoryIds(i+1);
       end if;


        -- No change in category, continue forming the update statement.
        -- Processing Root descriptors.
        IF vRtCategoryIds(i) = 0 THEN
          if (numBaseAttribs = 0) then
            update_tlp_set_string := vStoredInColumns(i);
            update_tlp_value_string := ' null';
          else
            update_tlp_set_string := update_tlp_set_string || ' , '|| vStoredInColumns(i) ;
            update_tlp_value_string := update_tlp_value_string || ' , '|| 'null';
          end if;
          numBaseAttribs := numBaseAttribs+1;
          xErrLoc := 500;
        ELSE
          -- Processing the local descriptors.
          -- You are now going to see all the local descriptors(due to order by)

          if (numCatAttribs = 0) then
            update_exttlp_set_string := vStoredInColumns(i);
            update_exttlp_value_string := ' null';
          else
            update_exttlp_set_string := update_exttlp_set_string || ' , '|| vStoredInColumns(i) ;
            update_exttlp_value_string := update_exttlp_value_string || ' , '|| 'null';
          end if;
          numCatAttribs := numCatAttribs+1;
        END IF;

      -- Once we have read the category process it...
      -- Category changed in the list, means a new category is read, so
      -- process the category and its descriptors...
      -- process even when end of list is reached..
      IF (i = vRtCategoryIds.COUNT OR nextCategoryId <> vRtCategoryIds(i)) THEN
        v_cursor_id := DBMS_SQL.open_cursor;

        -- Process the category read.
        xErrLoc := 700;

        IF vRtCategoryIds(i) = 0 THEN
          update_tlp_sql_string := 'UPDATE ICX_CAT_ITEMS_TLP SET ';
          update_tlp_sql_string := update_tlp_sql_string ||' ('||update_tlp_set_string||' ) = (select ' || update_tlp_value_string|| ' from dual) where primary_category_id = :cat_id';
          xErrLoc := 750;
          DBMS_SQL.parse(v_cursor_id, update_tlp_sql_string, dbms_sql.native);
          -- Reset the values for reading next set of Base attributes for
          -- the next category
          numBaseAttribs := 0;
          update_tlp_set_string := null;
          update_tlp_value_string := null;
        ELSE
          -- Process the category attributes just read for this category
          update_exttlp_sql_string := 'UPDATE ICX_CAT_EXT_ITEMS_TLP SET ';
          update_exttlp_sql_string := update_exttlp_sql_string||' ('||update_exttlp_set_string||' ) = (select ' || update_exttlp_value_string|| ' from dual) where rt_category_id = :cat_id';
        xErrLoc := 750;
          DBMS_SQL.parse(v_cursor_id, update_exttlp_sql_string, dbms_sql.native);
          -- Reset the values for reading next set of category attributes for
          -- the next category
          numCatAttribs := 0;
          update_exttlp_set_string := null;
          update_exttlp_value_string := null;
        END IF;

        xErrLoc := 800;
        DBMS_SQL.bind_variable(v_cursor_id, ':cat_id', vRtCategoryIds(i));
        result := DBMS_SQL.execute(v_cursor_id);
        DBMS_SQL.close_cursor(v_cursor_id);

      END IF;

      xErrLoc := 600+i;
    END LOOP;

    xErrLoc := 1000;

    COMMIT;
    --Bug#3072827
    IF (vRtCategoryIds.COUNT < BATCH_SIZE) THEN
      EXIT;
    END IF;
  END LOOP;
  CLOSE deleted_descriptors_csr;

  xErrLoc := 1400;

  -- do not hardcode "icx." get the schema name dynamically..
  v_sql := 'TRUNCATE TABLE ' || ICX_POR_EXT_UTL.getIcxSchema ||'.icx_cat_deleted_attributes';
  execute immediate v_sql;

  xErrLoc := 1500;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.sync_deleted_descriptors('
        || xErrLoc || '): ' || SQLERRM);

END sync_deleted_descriptors;

/** Proc : update_items_for_category
 ** Desc : Overloaded method for concurrent program executable.
 **        Executable for the Category Rename Concurrent Program.
 ** See  : update_items_for_category [below]
 **/
PROCEDURE update_items_for_category (
                           errbuf         OUT NOCOPY VARCHAR2,
                           retcode        OUT NOCOPY VARCHAR2,
                           p_category_name      IN VARCHAR2,
                           p_category_id     IN NUMBER,
                           p_language     IN VARCHAR2,
                           p_request_id   IN NUMBER   DEFAULT -1)
IS
BEGIN
   retcode := 0;
   errbuf := '';

        update_items_for_category(p_category_name, p_category_id,
                             p_language, p_request_id);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SQLERRM;
      raise;
END update_items_for_category;

/**
 ** Proc : update_items_for_category
 ** Desc : Update primary_category_name in items_tlp with the category name for a sepcified language.
 **/
PROCEDURE update_items_for_category (p_category_name      IN VARCHAR2,
                           p_category_id   	IN NUMBER,
                           p_language   	IN VARCHAR2,
                           p_request_id 	IN NUMBER   DEFAULT -1)
IS

  xErrLoc       INTEGER := 0;
  xContinue     BOOLEAN := TRUE;
  xCommitSize   INTEGER := 2500;
  xLangArray    ECM_LANG_ARRAY;
  CURSOR translateLangCsr IS
    SELECT language
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    and type = 2
    and source_lang = p_language
    and  source_lang <> language
    UNION
    SELECT p_language FROM DUAL;
BEGIN
  --Set the commit size
  xErrLoc := 100;
  fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);

  OPEN translateLangCsr;
  FETCH translateLangCsr BULK COLLECT into xLangArray;
  CLOSE translateLangCsr;

  xErrLoc := 110;
  FOR i in 1..xLangArray.COUNT LOOP
    xErrLoc := 110;
    xContinue := TRUE;

    xErrLoc := 120;
    WHILE xContinue LOOP
      UPDATE icx_cat_items_tlp
      SET primary_category_name = p_category_name,
          request_id = p_request_id
      WHERE primary_category_id=p_category_id
      AND   language = xLangArray(i)
      AND   nvl(request_id, -1) <> p_request_id
      AND   rownum <= xCommitSize;

      xErrLoc := 130;
      IF ( SQL%ROWCOUNT < xCommitSize ) THEN
        xContinue := FALSE;
      END IF;

      xErrLoc := 140;
      COMMIT;
    END LOOP;
  END LOOP;
  xErrLoc := 150;
  COMMIT;

  xErrLoc := 160;
  populate_ctx_desc_indexes(p_request_id);

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.update_items_for_category('
        || xErrLoc || '): ' || SQLERRM);

END update_items_for_category;

/**
 ** Proc : handle_delete_descriptors
 ** Desc : Overloaded version. Handles the plsql call required
 **        when a descritpor is deleted from ecmanager
 **/
PROCEDURE handle_delete_descriptors (
                           errbuf                     OUT NOCOPY VARCHAR2,
                           retcode                    OUT NOCOPY VARCHAR2,
                           p_searchable                IN NUMBER,
                           p_rename_category_done      IN VARCHAR2,
                           p_category_name             IN VARCHAR2,
                           p_rt_category_id            IN NUMBER,
                           p_language                  IN VARCHAR2,
                           p_request_id                IN NUMBER   DEFAULT -1)
IS
BEGIN
   retcode := 0;
   errbuf := '';

  handle_delete_descriptors(p_searchable,
                            p_rename_category_done,
                            p_category_name,
                            p_rt_category_id,
                            p_language,
                            p_request_id);
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SQLERRM;
      raise;

END handle_delete_descriptors;

/**
 ** Proc : handle_delete_descriptors
 ** Desc : Handles the plsql call required when a descritpor is deleted from ecmanager
 **/
PROCEDURE handle_delete_descriptors (p_searchable      IN NUMBER,
                           p_rename_category_done      IN VARCHAR2,
                           p_category_name             IN VARCHAR2,
                           p_rt_category_id            IN NUMBER,
                           p_language                  IN VARCHAR2,
                           p_request_id                IN NUMBER   DEFAULT -1)
IS
  xErrLoc       INTEGER := 0;
BEGIN

  xErrLoc := 100;
  sync_deleted_descriptors;

  xErrLoc := 120;
  IF ( p_rename_category_done = 'Y' ) THEN
    update_items_for_category(p_category_name, p_rt_category_id, p_language, p_request_id);
  ELSIF ( p_searchable = 1) THEN
    populate_ctx_desc_indexes(p_request_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_SCHEMA_UPLOAD.handle_delete_descriptors('
        || xErrLoc || '): ' || SQLERRM);

END handle_delete_descriptors;

END ICX_POR_SCHEMA_UPLOAD;

/
