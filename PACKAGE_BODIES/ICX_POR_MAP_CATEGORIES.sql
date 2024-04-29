--------------------------------------------------------
--  DDL for Package Body ICX_POR_MAP_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_MAP_CATEGORIES" AS
/* $Header: ICXECMCB.pls 115.0 2002/11/20 19:35:43 sbgeorge noship $*/

gNewCatIdTab   dbms_sql.number_table;
gNewCatNameTab dbms_sql.varchar2_table;
gNewCatLangTab dbms_sql.varchar2_table;

PROCEDURE clear_tables IS
BEGIN
  gNewCatIdTab.DELETE;
  gNewCatNameTab.DELETE;
  gNewCatLangTab.DELETE;
END clear_tables;

PROCEDURE map_categories(p_sourceCategory IN VARCHAR2,
                         p_oldCatKey IN VARCHAR2,
                         p_destCatKey IN VARCHAR2,
			 p_userId IN NUMBER,
			 p_status OUT VARCHAR2,
			 p_message OUT VARCHAR2)
IS
  cursor c_populate_new_cat_info(p_destCatKey VARCHAR2) is
    SELECT rt_category_id, category_name, language
    FROM icx_cat_categories_tl
    WHERE upper_key = UPPER(p_destCatKey) ;

  cursor c_installed_languages is
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag in ('B', 'I');

  xErrLoc    INTEGER := 0;
  v_oldCatId NUMBER := -1;
  v_jobNum   NUMBER := -1;
  v_newCatName icx_cat_categories_tl.category_name%TYPE;

BEGIN
  p_status := 'Y'; --SUCCESS
  xErrLoc := 100;
  UPDATE ICX_POR_category_data_sources
  SET category_key = p_destCatKey,
      last_updated_by = p_userId,
      last_update_date = sysdate
  WHERE external_source_key = p_sourceCategory
  AND external_source = 'Oracle';

  p_message := 'No: of rows updated in icx_por_category_data_sources:' ||SQL%ROWCOUNT;

  xErrLoc := 200;
  --Mapping already existed only then requires the
  --updation of icx_cat_category_items, icx_cat_ext_items_tlp and icx_cat_items_tlp
  if ( SQL%ROWCOUNT > 0 ) then
    --populate the destCategory informations
    xErrLoc := 300;
    OPEN c_populate_new_cat_info (p_destCatKey);
      xErrLoc := 400;
      FETCH c_populate_new_cat_info
      BULK COLLECT INTO gNewCatIdTab, gNewCatNameTab, gNewCatLangTab;
      xErrLoc := 500;
    CLOSE c_populate_new_cat_info;

    xErrLoc := 600;
    --Get the category_id of sourceCategory
    SELECT rt_category_id INTO v_oldCatId
    FROM icx_cat_categories_tl
    WHERE upper_key = UPPER(p_oldCatKey)
    and rownum = 1;
    p_message := p_message ||'; newCatdId:' ||gNewCatIdTab(1) ||', oldCatId:' ||v_oldCatId;

    xErrLoc := 700;
    --update category_items
    UPDATE  icx_cat_category_items ci1
    SET     ci1.rt_category_id = gNewCatIdTab(1)
    WHERE   (ci1.rt_item_id, ci1.rt_category_id) in
    (SELECT ci2.rt_item_id, ci2.rt_category_id
     FROM   icx_cat_category_items ci2,
            icx_cat_items_b i
     WHERE  ci2.rt_category_id = v_oldCatId
       AND  ci2.rt_item_id = i.rt_item_id
       -- only update extracted items
       AND  i.extractor_updated_flag = 'Y' );
    p_message := p_message ||'; No: of rows updated in icx_cat_category_items:' ||SQL%ROWCOUNT;

    /*  DLD No need to check since there will be always a row in icx_cat_items_tlp
    SELECT 1 into hasLocals
    FROM   icx_cat_descriptors_tl
    WHERE  rt_category_id = :oldCatID
    AND    rownum = 1

    if ( hasLocals = 1 )then
    */

    xErrLoc := 800;
    --update cat_ext_items_tlp with the new category_id and make all the attributes to null
    update icx_cat_ext_items_tlp ext
    set rt_category_id = gNewCatIdTab(1), --newCatID
        text_cat_attribute1 = null, text_cat_attribute2 = null, text_cat_attribute3 = null,
        text_cat_attribute4 = null, text_cat_attribute5 = null, text_cat_attribute6 = null,
        text_cat_attribute7 = null, text_cat_attribute8 = null, text_cat_attribute9 = null,
        text_cat_attribute10 = null, text_cat_attribute11 = null, text_cat_attribute12 = null,
        text_cat_attribute13 = null, text_cat_attribute14 = null, text_cat_attribute15 = null,
        text_cat_attribute16 = null, text_cat_attribute17 = null, text_cat_attribute18 = null,
        text_cat_attribute19 = null, text_cat_attribute20 = null, text_cat_attribute21 = null,
        text_cat_attribute22 = null, text_cat_attribute23 = null, text_cat_attribute24 = null,
        text_cat_attribute25 = null, text_cat_attribute26 = null, text_cat_attribute27 = null,
        text_cat_attribute28 = null, text_cat_attribute29 = null, text_cat_attribute30 = null,
        text_cat_attribute31 = null, text_cat_attribute32 = null, text_cat_attribute33 = null,
        text_cat_attribute34 = null, text_cat_attribute35 = null, text_cat_attribute36 = null,
        text_cat_attribute37 = null, text_cat_attribute38 = null, text_cat_attribute39 = null,
        text_cat_attribute40 = null, text_cat_attribute41 = null, text_cat_attribute42 = null,
        text_cat_attribute43 = null, text_cat_attribute44 = null, text_cat_attribute45 = null,
        text_cat_attribute46 = null, text_cat_attribute47 = null, text_cat_attribute48 = null,
        text_cat_attribute49 = null, text_cat_attribute50 = null,
        num_cat_attribute1 = null, num_cat_attribute2 = null, num_cat_attribute3 = null,
        num_cat_attribute4 = null, num_cat_attribute5 = null, num_cat_attribute6 = null,
        num_cat_attribute7 = null, num_cat_attribute8 = null, num_cat_attribute9 = null,
        num_cat_attribute10 = null, num_cat_attribute11 = null, num_cat_attribute12 = null,
        num_cat_attribute13 = null, num_cat_attribute14 = null, num_cat_attribute15 = null,
        num_cat_attribute16 = null, num_cat_attribute17 = null, num_cat_attribute18 = null,
        num_cat_attribute19 = null, num_cat_attribute20 = null, num_cat_attribute21 = null,
        num_cat_attribute22 = null, num_cat_attribute23 = null, num_cat_attribute24 = null,
        num_cat_attribute25 = null, num_cat_attribute26 = null, num_cat_attribute27 = null,
        num_cat_attribute28 = null, num_cat_attribute29 = null, num_cat_attribute30 = null,
        num_cat_attribute31 = null, num_cat_attribute32 = null, num_cat_attribute33 = null,
        num_cat_attribute34 = null, num_cat_attribute35 = null, num_cat_attribute36 = null,
        num_cat_attribute37 = null, num_cat_attribute38 = null, num_cat_attribute39 = null,
        num_cat_attribute40 = null, num_cat_attribute41 = null, num_cat_attribute42 = null,
        num_cat_attribute43 = null, num_cat_attribute44 = null, num_cat_attribute45 = null,
        num_cat_attribute46 = null, num_cat_attribute47 = null, num_cat_attribute48 = null,
        num_cat_attribute49 = null, num_cat_attribute50 = null,
        tl_text_cat_attribute1 = null, tl_text_cat_attribute2 = null, tl_text_cat_attribute3 = null,
        tl_text_cat_attribute4 = null, tl_text_cat_attribute5 = null, tl_text_cat_attribute6 = null,
        tl_text_cat_attribute7 = null, tl_text_cat_attribute8 = null, tl_text_cat_attribute9 = null,
        tl_text_cat_attribute10 = null, tl_text_cat_attribute11 = null, tl_text_cat_attribute12 = null,
        tl_text_cat_attribute13 = null, tl_text_cat_attribute14 = null, tl_text_cat_attribute15 = null,
        tl_text_cat_attribute16 = null, tl_text_cat_attribute17 = null, tl_text_cat_attribute18 = null,
        tl_text_cat_attribute19 = null, tl_text_cat_attribute20 = null, tl_text_cat_attribute21 = null,
        tl_text_cat_attribute22 = null, tl_text_cat_attribute23 = null, tl_text_cat_attribute24 = null,
        tl_text_cat_attribute25 = null, tl_text_cat_attribute26 = null, tl_text_cat_attribute27 = null,
        tl_text_cat_attribute28 = null, tl_text_cat_attribute29 = null, tl_text_cat_attribute30 = null,
        tl_text_cat_attribute31 = null, tl_text_cat_attribute32 = null, tl_text_cat_attribute33 = null,
        tl_text_cat_attribute34 = null, tl_text_cat_attribute35 = null, tl_text_cat_attribute36 = null,
        tl_text_cat_attribute37 = null, tl_text_cat_attribute38 = null, tl_text_cat_attribute39 = null,
        tl_text_cat_attribute40 = null, tl_text_cat_attribute41 = null, tl_text_cat_attribute42 = null,
        tl_text_cat_attribute43 = null, tl_text_cat_attribute44 = null, tl_text_cat_attribute45 = null,
        tl_text_cat_attribute46 = null, tl_text_cat_attribute47 = null, tl_text_cat_attribute48 = null,
        tl_text_cat_attribute49 = null, tl_text_cat_attribute50 = null
    where rt_category_id = v_oldCatId --oldCatID
    and exists ( select 'x' from icx_cat_items_b b
                 where ext.rt_item_id = b.rt_item_id
                 and   b.extractor_updated_flag = 'Y' );
    --end if;
    xErrLoc := 810;
    p_message := p_message ||'; No: of rows updated in icx_cat_ext_items_tlp:' ||SQL%ROWCOUNT;

    xErrLoc := 900;
    --Get the jobNum to update in icx_cat_items_tlp for the rebuild of intermedia index
    SELECT icx_por_batch_jobs_s.nextval
      INTO v_jobNum
      FROM dual;
    xErrLoc := 810;
    p_message := p_message ||'; jobNum:' ||v_jobNum;

    xErrLoc := 1000;
    FOR lang in c_installed_languages LOOP
      --Get the category_name for the installed language
      --to be updated in the primary_category_name in icx_cat_items_tlp
      v_newCatName := 'NULL CATG NAME';
      FOR i in 1..gNewCatLangTab.COUNT LOOP
        if ( lang.language_code = gNewCatLangTab(i) ) then
          v_newCatName := gNewCatNameTab(i);
          exit;
        else
          v_newCatName := 'NULL CATG NAME';
        end if;
      END LOOP;
      xErrLoc := 1100;
      if ( v_newCatName <> 'NULL CATG NAME' ) then
        xErrLoc := 1200;
	-- update icx_cat_items_tlp with jobNum and primary_category_name and primary_category_id.
        UPDATE icx_cat_items_tlp
           SET --job_number = v_jobNum,
               request_id = v_jobNum,
               primary_category_id = gNewCatIdTab(1),
               primary_category_name = v_newCatName
         WHERE language = lang.language_code
           AND rt_item_id in
               (SELECT i.rt_item_id
                  FROM icx_cat_category_items ci,
                       icx_cat_items_b i
                 WHERE ci.rt_category_id = gNewCatIdTab(1)
                   AND ci.rt_item_id = i.rt_item_id
                   AND i.extractor_updated_flag = 'Y');
	p_message := p_message ||'; No: of rows updated in icx_cat_items_tlp for '||lang.language_code ||' :' ||SQL%ROWCOUNT;
      end if;
    END LOOP;

    xErrLoc := 1300;
    ICX_POR_POPULATE_DESC.populateCtxDescAll(v_jobNum, 'N');

  else
    xErrLoc := 1400;
    --If there was no mapping existing then insert one.
    INSERT INTO ICX_POR_category_data_sources
    (external_source_key, external_source,  created_by, last_updated_by, creation_date, last_update_date, category_key, last_update_login)
    VALUES ( p_sourceCategory, 'Oracle', p_userId, p_userId, sysdate, sysdate, p_destCatKey, p_userId );
    p_message := p_message ||'; New row inserted into icx_por_category_data_sources';
  end if;
  xErrLoc := 1500;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      p_status := 'N'; --FAILURE
      p_message := p_message ||' Exception at ICX_POR_MAP_CATEGORIES.map_categories('
                   || xErrLoc || '): '
                   || ', '|| SQLERRM;
      ROLLBACK;
      --RAISE_APPLICATION_ERROR(-20000,
      --  'Exception at ICX_POR_MAP_CATEGORIES.map_categories('
      --  || xErrLoc || '): '
      --  || ', '|| SQLERRM);
END map_categories;

END ICX_POR_MAP_CATEGORIES;

/
