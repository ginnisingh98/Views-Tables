--------------------------------------------------------
--  DDL for Package Body ICX_POR_SCHEMA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_SCHEMA_UPGRADE" AS
-- $Header: ICXUPSCB.pls 115.5 2004/03/31 18:47:29 vkartik ship $

/**
 **
 ** Procedure: create_new_categ_descs_tables
 ** Synopsis : Populate the icx_cat_categories_tl, icx_cat_descriptors_tl,
 **            and icx_cat_browse_trees table. The source for the above
 **            tables are icx_por_categories_tl, icx_Por_descriptors_tl and
 **            icx_por_table_of_contents_tl respectively.
 **/
PROCEDURE create_new_categ_descs_tables IS
BEGIN
  l_loc := 100;

  -- Make a replica(new table) of the categories and descriptors table
  -- dont do a blind replica, may be section map did not exist in
  -- the current version of the customer's odf
  -- Bug#2830088: modified the "not exists" for category check.
  insert into icx_cat_categories_tl
  (
     RT_CATEGORY_ID,
     LANGUAGE,
     SOURCE_LANG,
     CATEGORY_NAME,
     DESCRIPTION,
     TYPE,
     KEY,
     TITLE,
     ITEM_COUNT,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     UPPER_CATEGORY_NAME,
     REBUILD_FLAG,
     section_map,
     UPPER_KEY
  )
  (
   select
     ct1.RT_CATEGORY_ID,
     ct1.LANGUAGE,
     ct1.SOURCE_LANG,
     ct1.CATEGORY_NAME,
     ct1.DESCRIPTION,
     ct1.TYPE,
     ct1.KEY,
     ct1.TITLE,
     ct1.ITEM_COUNT,
     ct1.CREATED_BY,
     ct1.CREATION_DATE,
     ct1.LAST_UPDATED_BY,
     ct1.LAST_UPDATE_DATE,
     ct1.LAST_UPDATE_LOGIN,
     ct1.BATCH_JOB_NUM, -- batch_job_num is request id
     ct1.PROGRAM_APPLICATION_ID,
     ct1.PROGRAM_ID,
     ct1.PROGRAM_UPDATE_DATE,
     ct1.UPPER_CATEGORY_NAME,
     REBUILD_FLAG,
     rpad('0', 300, '0'),
     UPPER_KEY
   from
     icx_por_categories_tl ct1
   where ct1.rt_category_id > 0
   and not exists (select null from icx_cat_categories_tl ct2
                   where ct1.key = ct2.key
                   and ct1.type = ct2.type
                   and   ct1.language = ct2.language)
  );

  l_loc := 300;

  -- make a replica of icx_por_descriptors_tl
  -- ignore the validated, class, customization_level,multivalue,  section_tag
  insert into icx_cat_descriptors_tl
  (
      RT_DESCRIPTOR_ID,
      LANGUAGE,
      SOURCE_LANG,
      TITLE,
      DESCRIPTOR_NAME,
      DESCRIPTION,
      RT_CATEGORY_ID,
      TYPE,
      -- Bug 3092172 fixed by sosingha
      -- ignore the hidden column as upgrade will fail for pre FPE customers due to non availability of this column. We wont honour this column and hence no need to copy the value for this.
      -- HIDDEN,
      SEQUENCE,
      KEY,
      DEFAULTVALUE,
      MULTI_VALUE_TYPE,
      MULTI_VALUE_KEY,
      REQUIRED,
      REFINABLE,
      SEARCHABLE,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      SEARCH_RESULTS_VISIBLE,
      ITEM_DETAIL_VISIBLE,
      REBUILD_FLAG,
      CLASS
  )
  (
    select
      des1.RT_DESCRIPTOR_ID,
      des1.LANGUAGE,
      des1.SOURCE_LANG,
      des1.TITLE,
      des1.DESCRIPTOR_NAME,
      des1.DESCRIPTION,
      des1.RT_CATEGORY_ID,
      des1.TYPE,
      -- Bug 3092172 fixed by sosingha
      -- des1.HIDDEN,
      des1.SEQUENCE,
      des1.KEY,
      des1.DEFAULTVALUE,
      des1.MULTI_VALUE_TYPE,
      des1.MULTI_VALUE_KEY,
      des1.REQUIRED,
      des1.REFINABLE,
      des1.SEARCHABLE,
      des1.CREATED_BY,
      des1.CREATION_DATE,
      des1.LAST_UPDATED_BY,
      des1.LAST_UPDATE_DATE,
      des1.LAST_UPDATE_LOGIN,
      des1.BATCH_JOB_NUM,
      des1.PROGRAM_APPLICATION_ID,
      des1.PROGRAM_ID,
      des1.PROGRAM_UPDATE_DATE,
      des1.SEARCH_RESULTS_VISIBLE,
      des1.ITEM_DETAIL_VISIBLE,
      des1.REBUILD_FLAG,
      decode(des1.rt_category_id, 0 , 'ICX_BASE_ATTR', 'ICX_CAT_ATTR')
    from
      icx_por_descriptors_tl des1
    where des1.rt_descriptor_id > 100
    and not exists (select null from icx_cat_descriptors_tl des2
                   where des1.rt_descriptor_id = des2.rt_descriptor_id
                   and   des1.language = des2.language)
    );
  l_loc := 400;

  -- Populate the icx_cat_browse_trees with rows
  -- from icx_por_table_of_contents_tl
  insert into icx_cat_browse_trees (PARENT_CATEGORY_ID,
  CHILD_CATEGORY_ID, LAST_UPDATE_LOGIN ,
  LAST_UPDATED_BY, LAST_UPDATE_DATE, CREATED_BY, CREATION_DATE)
  select  toc1.RT_CATEGORY_ID, toc1.CHILD, 1, toc1.LAST_UPDATED_BY,
  toc1.LAST_UPDATE_DATE, toc1.CREATED_BY, toc1.CREATION_DATE
  from icx_por_table_of_contents_tl toc1
  where not exists (select null from icx_cat_browse_trees toc2
                    where toc2.PARENT_CATEGORY_ID = toc1.RT_CATEGORY_ID
                    and   toc2.CHILD_CATEGORY_ID = toc1.CHILD);

  l_loc := 500;

EXCEPTION
  WHEN OTHERS THEN
    l_return_err := 'create_new_categ_descs_tables(' ||l_loc||'): '||sqlerrm;
    raise_application_error(-20000,l_return_err);
END create_new_categ_descs_tables;

/**
 **
 ** Procedure: assign_section_tag_and_map
 ** Synopsis : Loop through every genus category and assign a section map
 **            for that category. Descriptors for that category is assigned
 **            section tags.
 **/
PROCEDURE  assign_section_tag_and_map  IS
  l_category_ids   dbms_sql.number_table;
  i                PLS_INTEGER := 1;
  TYPE CursorType  IS REF CURSOR;
  get_categories   CursorType;

BEGIN

  -- Open the cursor for getting categories that have descriptors
  l_loc := 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Open the get_categories cursor to get distinct categories');

  open get_categories for
    select  distinct RT_CATEGORY_ID
    from   icx_cat_descriptors_tl;

  l_loc := 200;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Loop through every category to assign section tag and section map');

  -- Loop through every category to assign section tag and section map.
  LOOP
    l_loc := 300;
    l_category_ids.DELETE;

    FETCH get_categories
    BULK  COLLECT INTO l_category_ids
    LIMIT l_commit_size;
    EXIT WHEN l_category_ids.COUNT = 0;

    -- Loop through all the genus category
    for i in 1..l_category_ids.COUNT loop
      l_loc := 300+i;

      ICX_POR_SCHEMA_UPLOAD.assign_all_section_tags(l_category_ids(i));

      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Assigning section tag and section map for rt_category_id = '|| l_category_ids(i));

    end loop;
    l_loc := 10000;

    COMMIT;
  END LOOP;
  l_loc := 20000;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Close cursor...');
  CLOSE get_categories;
  l_loc := 20010;

EXCEPTION
  WHEN OTHERS THEN
    l_return_err := ' assign_section_tag_and_map(' ||l_loc||'): '||sqlerrm;
    raise_application_error(-20000,l_return_err);
END assign_section_tag_and_map;

/**
 **
 ** Procedure: upgrade
 ** Synopsis : This is the main procedure that need to be called to run
 **            upgrade the schema tables. It calls methods to populate
 **            the new schema tables with rows from the old tables and also
 **            to assign section tags and section maps.
 **/
PROCEDURE upgrade IS
BEGIN
  l_loc := 100;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Schema upgrade Start.');

  -- Populate the rows in all the schema tables(Categories, Descriptors, TOC)
  create_new_categ_descs_tables();
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Created the new Category, Descriptor and TOC table.');
  l_loc := 200;

  assign_section_tag_and_map();
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Populated the new Category and Descriptors table with section maps and section tags.');

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'End Upgrade');

EXCEPTION
  WHEN OTHERS THEN

    l_return_err := 'ICXUPSCB.pls(' ||l_loc||'): '||sqlerrm;
    raise_application_error(-20000,l_return_err);
END upgrade;

END ICX_POR_SCHEMA_UPGRADE;

/
