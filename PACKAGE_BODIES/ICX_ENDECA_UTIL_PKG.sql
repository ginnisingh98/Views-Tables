--------------------------------------------------------
--  DDL for Package Body ICX_ENDECA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ENDECA_UTIL_PKG" AS
  /* $Header: ICXEUTLB.pls 120.0.12010000.39 2014/04/24 14:42:44 mzhussai noship $ */
  -- Read the profile option that enables/disables the debug log
  g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
  g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  -- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL NUMBER;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'ICX.PLSQL.ICX_ENDECA_UTIL_PKG';
PROCEDURE populate_KVPs
IS
  l_progress VARCHAR2(3);
  sql_query  VARCHAR2(32767);
  l_status varchar2(30);
  l_industry varchar2(30);
  l_result BOOLEAN;
  l_schema all_tables.owner%TYPE;

  CURSOR zones(zonetype VARCHAR2)
  IS
    SELECT DISTINCT 'sqe(icxz'
      || zonetype
      || zoneb.SQE_SEQUENCE
      ||')' sqe_exp ,
      zone_id
    FROM ICX_CAT_CONTENT_ZONES_B zoneb,
      ICX_CAT_STORE_CONTENTS_V contentv
    WHERE zoneb.ZONE_ID = contentv.CONTENT_ID
    AND zoneb.TYPE      ='LOCAL';
  CURSOR language_csr
  IS
    SELECT LANGUAGE_CODE
    FROM fnd_languages
    WHERE INSTALLED_FLAG IN ('I', 'B');
TYPE RecList
IS
  TABLE OF zones%ROWTYPE;
  l_language_code fnd_languages.LANGUAGE_CODE%type;
  rec RecList;
BEGIN
  --Non-Translatable Attributes

  l_result := FND_INSTALLATION.GET_APP_INFO('PO', l_status, l_industry, l_schema);

  delete ICX_CAT_ENDECA_ITEM_ATTRIBUTES;

 -- Base descriptors

  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM ALL_TAB_COLUMNS
  WHERE table_name = upper('po_attribute_values')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.INVENTORY_ITEM_ID || ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' || pav.REQ_TEMPLATE_LINE_NUM|| ''#'' ||pav.ORG_ID|| ''#'' || icatl.language "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||rec.column_name || ' , icatl.language';
    sql_query := sql_query||' FROM po_attribute_values pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES''  And (Icatl.Rt_Category_Id=0) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;

-- Category descriptors
  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM ALL_TAB_COLUMNS
  WHERE table_name = upper('po_attribute_values')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT /*+ index(pav po_attribute_values_N1)*/pav.INVENTORY_ITEM_ID || ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' ||';
    sql_query := sql_query||'pav.REQ_TEMPLATE_LINE_NUM|| ''#'' ||pav.ORG_ID|| ''#'' || icatl.language "RecordSpec",Icatl.KEY "Attribute",'||rec.column_name || ' , icatl.language';
    sql_query := sql_query||' FROM po_attribute_values pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES''  And (Icatl.Rt_Category_Id = Pav.Ip_Category_Id) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;

  --Translatable Base Attributes
  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM all_tab_columns
  WHERE table_name = upper('po_attribute_values_tlp')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.INVENTORY_ITEM_ID|| ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' || pav.REQ_TEMPLATE_LINE_NUM|| ''#'' || pav.ORG_ID|| ''#'' || pav.language "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||rec.column_name|| ' , pav.language';
    sql_query := sql_query||' FROM po_attribute_values_tlp pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES_TLP'' AND icatl.language = pav.language And (Icatl.Rt_Category_Id=0) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;

--Translatable Category Attributes

  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM all_tab_columns
  WHERE table_name = upper('po_attribute_values_tlp')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT /*+ index(pav po_attribute_values_tlp_N1)*/pav.INVENTORY_ITEM_ID|| ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' ||';
    sql_query := sql_query||'pav.REQ_TEMPLATE_LINE_NUM|| ''#'' || pav.ORG_ID|| ''#'' || pav.language "RecordSpec",Icatl.KEY "Attribute",'||rec.column_name|| ' , pav.language';
    sql_query := sql_query||' FROM po_attribute_values_tlp pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES_TLP'' AND icatl.language = pav.language And (Icatl.Rt_Category_Id = Pav.Ip_Category_Id ) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;

  OPEN language_csr;
  LOOP
    FETCH language_csr INTO l_language_code;
    EXIT
  WHEN language_csr%notfound;
    OPEN zones('b');
    FETCH zones bulk COLLECT INTO rec;

    $IF DBMS_DB_VERSION.VER_LE_10 $THEN

    FOR i IN 1..rec.count LOOP
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT  ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESB',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    END LOOP;

    $ELSE

    FORALL i IN 1..rec.count
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT  ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESB',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

   $END

    CLOSE zones;

    OPEN zones('p');
    FETCH zones bulk COLLECT INTO rec;

    $IF DBMS_DB_VERSION.VER_LE_10 $THEN

    FOR i IN 1..rec.count LOOP
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESP',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    END LOOP;

    $ELSE

    FORALL i IN 1..rec.count
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESP',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    $END

    CLOSE zones;

    OPEN zones('i');
    FETCH zones bulk COLLECT INTO rec;

    $IF DBMS_DB_VERSION.VER_LE_10 $THEN

    FOR i IN 1..rec.count  LOOP
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESI',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    END LOOP;

    $ELSE

    FORALL i IN 1..rec.count
    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT ctx.INVENTORY_ITEM_ID || '#' ||ctx.PO_LINE_ID || '#' || ctx.REQ_TEMPLATE_NAME || '#' ||ctx.REQ_TEMPLATE_LINE_NUM || '#' ||ctx.ORG_ID || '#' ||ctx.LANGUAGE,
      'ZONESI',
      rec(i).zone_id,
      l_language_code
    FROM  ICX_CAT_ITEMS_CTX_HDRS_TLP ctx
    WHERE contains(ctx_Desc,
       rec(i).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    $END

    CLOSE zones;
   END LOOP;
  CLOSE language_csr;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_KVPs ' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_KVPs;


PROCEDURE populate_KVPs_for_punchout IS
  l_progress VARCHAR2(3);
  sql_query  VARCHAR2(32767);
  l_status varchar2(30);
  l_industry varchar2(30);
  l_result BOOLEAN;
  l_schema all_tables.owner%TYPE;

  CURSOR language_csr
  IS
    SELECT LANGUAGE_CODE
    FROM fnd_languages
    WHERE INSTALLED_FLAG IN ('I', 'B');
  l_language_code fnd_languages.LANGUAGE_CODE%type;
BEGIN
  --Non-Translatable Attributes

  l_result := FND_INSTALLATION.GET_APP_INFO('ICX', l_status, l_industry, l_schema);

  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM ALL_TAB_COLUMNS
  WHERE table_name = upper('icx_cat_pch_item_attrs')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.punchout_item_id "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||rec.column_name || ' , icatl.language';
    sql_query := sql_query||' FROM icx_cat_pch_item_attrs pav, icx_cat_punchout_items pitems, Icx_Cat_Attributes_Tl Icatl';
    sql_query := sql_query||' WHERE pitems.punchout_item_id = pav.punchout_item_id and icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES''  And (Icatl.Rt_Category_Id = pitems.Ip_Category_Id or Icatl.Rt_Category_Id=0) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;
  --Translatable Attributes
  FOR Rec IN
  (SELECT COLUMN_NAME
  FROM all_tab_columns
  WHERE table_name = upper('icx_cat_pch_item_attrs_tlp')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.punchout_item_id "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||rec.column_name|| ' , pav.language';
    sql_query := sql_query||' FROM icx_cat_pch_item_attrs_tlp pav, icx_cat_punchout_items pitems,Icx_Cat_Attributes_Tl Icatl';
    sql_query := sql_query||' WHERE pitems.punchout_item_id = pav.punchout_item_id and icatl.stored_in_column = ''';
    sql_query := sql_query||rec.column_name;
    sql_query := sql_query||''' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES_TLP'' AND icatl.language = pav.language And (Icatl.Rt_Category_Id = pitems.Ip_Category_Id or Icatl.Rt_Category_Id=0) AND '||rec.column_name||' IS NOT NULL';
    EXECUTE IMMEDIATE sql_query;
  END LOOP;
  OPEN language_csr;
  LOOP
    FETCH language_csr INTO l_language_code;
    EXIT WHEN language_csr%notfound;

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT EID_ENDECA_ID,
      'ZONESB',
      ZONE_ID,
      l_language_code
    FROM ICX_CAT_ENDECA_ITEMS_V
    WHERE ZONE_ID is not null
    AND language=l_language_code
    UNION ALL
    SELECT EID_ENDECA_ID,
      'ZONESP',
      ZONE_ID,
      l_language_code
    FROM ICX_CAT_ENDECA_ITEMS_V
    WHERE ZONE_ID is not null
    AND language=l_language_code
    UNION ALL
    SELECT EID_ENDECA_ID,
      'ZONESI',
      ZONE_ID,
      l_language_code
    FROM ICX_CAT_ENDECA_ITEMS_V
    WHERE zone_id is not null
    AND language=l_language_code  ;

    END LOOP;
  CLOSE language_csr;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_KVPs_for_punchout ' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_KVPs_for_punchout;

PROCEDURE populate_attribute_metadata
IS
  l_progress VARCHAR2(3);
  CURSOR descriptors
  IS
    SELECT DISTINCT SubStrb(attributekey,1,30) attributekey, attributekey attrKey
    FROM ICX_CAT_ENDECA_ITEM_ATTRIBUTES ita,
      fnd_languages fla
    WHERE ita.language     =fla.language_code
    AND fla.installed_flag = 'B'
    AND attributekey NOT  IN ('ZONESI', 'ZONESB', 'ZONESP');

TYPE descriptorsList
IS
  TABLE OF descriptors%ROWTYPE;
  descRec descriptorsList ;
  CURSOR language_csr
  IS
    SELECT LANGUAGE_CODE FROM fnd_languages WHERE INSTALLED_FLAG IN ('I', 'B');
  l_language_code fnd_languages.LANGUAGE_CODE%type;
   l_attr_name   icx_cat_attributes_tl.ATTRIBUTE_NAME%TYPE;

BEGIN
  OPEN descriptors ;
  FETCH descriptors bulk collect INTO descRec;
  for i IN 1..descRec.count LOOP
  INSERT
  INTO FND_EID_PDR_ATTRS_B
    (
      EID_INSTANCE_ID,
      EID_INSTANCE_ATTRIBUTE,
      ENDECA_DATATYPE,
      EID_ATTR_PROFILE_ID,
      EID_RELEASE_VERSION,
      ATTRIBUTE_SOURCE,
      MANAGED_ATTRIBUTE_FLAG,
      HIERARCHICAL_MGD_ATTR_FLAG,
      DIM_ENABLE_REFINEMENTS_FLAG,
      DIM_SEARCH_HIERARCHICAL_FLAG,
      REC_SEARCH_HIERARCHICAL_FLAG,
      MGD_ATTR_EID_RELEASE_VERSION,
      OBSOLETED_FLAG,
      OBSOLETED_EID_RELEASE_VERSION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      1,
      ICX_ENDECA_UTIL_PKG.makeNCName(descRec(i).attributekey),
      'mdex:string',
      (SELECT EID_ATTR_PROFILE_ID
      FROM FND_EID_PDR_ATTR_PROFILES
      WHERE EID_ATTR_PROFILE_CODE = 'Dimension'
      ),
      2.3,
      'ORACLE',
      'N',
      'N',
      'Y',
      'N',
      'N',
      2.3,
      'N',
      0,
      -1,
      SYSDATE,
      -1,
      SYSDATE,
     -1
    );

  END LOOP;

  OPEN language_csr;
  LOOP
    FETCH language_csr INTO l_language_code;
    EXIT
  WHEN language_csr%notfound;

  FOR i IN 1..descRec.count
  LOOP

      SELECT attribute_name INTO l_attr_name FROM icx_cat_attributes_tl WHERE KEY=descRec(i).attrkey AND LANGUAGE= l_language_code AND ROWNUM=1;

  INSERT
  INTO FND_EID_PDR_ATTRS_TL
    (
      EID_INSTANCE_ID,
      EID_INSTANCE_ATTRIBUTE,
      LANGUAGE,
      SOURCE_LANG,
      DISPLAY_NAME,
      ATTRIBUTE_DESC,
      USER_DISPLAY_NAME,
      USER_ATTRIBUTE_DESC,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      1 ,
      ICX_ENDECA_UTIL_PKG.makeNCName(descRec(i).attributekey) ,
      l_language_code,
      l_language_code,
      l_attr_name ,
      l_attr_name ,
      l_attr_name,
      l_attr_name,
      -1,
      SYSDATE ,
      -1,
      SYSDATE ,
     -1
    ) ;
  END LOOP;
 END LOOP;

  FOR  i IN 1..descRec.Count
  LOOP
    INSERT
    INTO FND_EID_ATTR_GROUPS
      (
        EID_INSTANCE_ID,
        EID_INSTANCE_GROUP,
        EID_INSTANCE_ATTRIBUTE,
        EID_INSTANCE_GROUP_ATTR_SEQ,
        EID_INST_GROUP_ATTR_USER_SEQ,
        GROUP_ATTRIBUTE_SOURCE,
        EID_RELEASE_VERSION,
        OBSOLETED_FLAG,
        OBSOLETED_EID_RELEASE_VERSION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        1,
        'REFINEMENTS',
        ICX_ENDECA_UTIL_PKG.makeNCName(descRec(i).attributekey),
        i,
        i,
        'ORACLE',
        2.3,
        'N',
        0,
        1004511,
        SYSDATE,
        1004511,
        SYSDATE,
        1004511
      );

    END LOOP ;
  CLOSE descriptors ;

EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_attribute_metadata ' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_attribute_metadata;

PROCEDURE populate_managed_attr_metadata
IS
  l_orphan_exists varchar2(1) := 'Y';
  CURSOR language_csr
  IS
    SELECT LANGUAGE_CODE FROM fnd_languages WHERE INSTALLED_FLAG IN ('I', 'B');
  l_progress VARCHAR2(3);
  l_language_code fnd_languages.LANGUAGE_CODE%type;
BEGIN
  DELETE FROM FND_EID_DDR_MGD_ATT_VALS WHERE eid_instance_id=1;
  OPEN language_csr;
  LOOP
    FETCH language_csr INTO l_language_code;
    EXIT
  WHEN language_csr%notfound;
    INSERT INTO FND_EID_DDR_MGD_ATT_VALS
      (
        eid_inst_mgd_att_val_id,
        eid_instance_id ,
        eid_instance_mgd_attribute ,
        "LANGUAGE" ,
        source_lang ,
        eid_instance_dim_spec ,
        eid_instance_dim_val_disp_name ,
        eid_instance_dim_parent_spec ,
        eid_instance_dim_val_synonym,
        additional_synonyms_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
      ) VALUES
      (
        FND_EID_DDR_MGD_ATT_VALS_S.nextval ,
        1,
        'SHOPPING_CATEGORY',
        l_language_code,
        l_language_code,
        -2 , --'OTHERS',
       Nvl((SELECT MESSAGE_TEXT  FROM fnd_new_messages WHERE  MESSAGE_NAME = 'ICX_CAT_ENDECA_OTHERS' AND   LANGUAGE_CODE = l_language_code),'Others'),
        '/',
        NULL,
        NULL,
        -1,
        sysdate ,
        -1,
        SYSDATE,
        -1
      );
    INSERT
    INTO FND_EID_DDR_MGD_ATT_VALS
      (
        eid_inst_mgd_att_val_id,
        eid_instance_id ,
        eid_instance_mgd_attribute ,
        "LANGUAGE" ,
        source_lang ,
        eid_instance_dim_spec ,
        eid_instance_dim_val_disp_name ,
        eid_instance_dim_parent_spec ,
        eid_instance_dim_val_synonym,
        additional_synonyms_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
      )
      (SELECT FND_EID_DDR_MGD_ATT_VALS_S.nextval eid_inst_mgd_att_val_id ,
          1 eid_instance_id,
          'SHOPPING_CATEGORY' eid_instance_mgd_attribute,
          l_language_code "LANGUAGE",
          l_language_code source_lang ,
          Categories.RT_CATEGORY_ID eid_instance_dim_spec ,
          Categories.CATEGORY_NAME eid_instance_dim_val_disp_name,
          DECODE(Hierarchy.parent_category_id, 0 , '/', Hierarchy.parent_category_id) eid_instance_dim_parent_spec,
          Categories.DESCRIPTION eid_instance_dim_val_synonym,
          NULL additional_synonyms_flag ,
          -1 created_by,
          sysdate creation_date,
          -1 last_updated_by,
          SYSDATE last_update_date,
          -1 last_update_login
        FROM ICX_CAT_CATEGORIES_TL Categories,
          icx_cat_browse_trees Hierarchy
        WHERE Categories.LANGUAGE      = l_language_code
        AND Hierarchy.child_category_id=Categories.rt_category_id
        --Bug#16418889 : Check for existence of parent_category_id in icx_cat_categories_tl
        -- If not existing, then don't populate these hierarchy records.
        and exists(select 1 from icx_cat_categories_tl parent
                   where parent.rt_category_id = hierarchy.parent_category_id
                   or    hierarchy.parent_category_id = 0 )

      );
    INSERT
    INTO FND_EID_DDR_MGD_ATT_VALS
      (
        eid_inst_mgd_att_val_id,
        eid_instance_id ,
        eid_instance_mgd_attribute ,
        "LANGUAGE" ,
        source_lang ,
        eid_instance_dim_spec ,
        eid_instance_dim_val_disp_name ,
        eid_instance_dim_parent_spec ,
        eid_instance_dim_val_synonym,
        additional_synonyms_flag ,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
      )
      (SELECT FND_EID_DDR_MGD_ATT_VALS_S.nextval eid_inst_mgd_att_val_id,
          1 eid_instance_id,
          'SHOPPING_CATEGORY' eid_instance_mgd_attribute,
          l_language_code "LANGUAGE",
          l_language_code source_lang,
          Categories.RT_CATEGORY_ID eid_instance_dim_spec ,
          Categories.CATEGORY_NAME eid_instance_dim_val_disp_name,
          -2 eid_instance_dim_parent_spec, -- 'OTHERS' eid_instance_dim_parent_spec,
          NULL eid_instance_dim_val_synonym,
          NULL additional_synonyms_flag ,
          -1 created_by,
          sysdate creation_date,
          -1 last_updated_by,
          SYSDATE last_update_date,
          -1 last_update_login
        FROM
          (SELECT DISTINCT ip_category_id, language FROM icx_cat_items_ctx_hdrs_tlp
           UNION SELECT DISTINCT ip_category_id, language FROM icx_cat_punchout_items items,
                 icx_cat_pch_item_attrs_tlp attrs
                 where items.punchout_item_id = attrs.punchout_item_id
          ) items,
          ICX_CAT_CATEGORIES_TL categories
        WHERE items.ip_category_id    = categories.rt_category_id
        AND items.language            = categories.language
        AND categories.language       = l_language_code
        AND items.IP_CATEGORY_ID NOT IN
          (SELECT DISTINCT child_category_id FROM icx_cat_browse_trees
           WHERE PARENT_CATEGORY_ID IN (SELECT RT_CATEGORY_ID FROM
                                            ICX_CAT_CATEGORIES_TL)
           OR    PARENT_CATEGORY_ID = 0
          )
      );

  END LOOP;


      --BUG#16418889 : Ensure no duplicate exists in FND_EID_DDR_MGD_ATT_VALS
      DELETE from FND_EID_DDR_MGD_ATT_VALS a where rowid > (
        select min(rowid)  from FND_EID_DDR_MGD_ATT_VALS b
        where a.eid_instance_id = b.eid_instance_id
        and   a.eid_instance_mgd_attribute = b.eid_instance_mgd_attribute
        and   a.language = b.language
        and   a.eid_instance_dim_spec = b.eid_instance_dim_spec);

  WHILE(l_orphan_exists = 'Y')
  LOOP
    DELETE FND_EID_DDR_MGD_ATT_VALS WHERE EID_INSTANCE_DIM_PARENT_SPEC NOT IN
      (SELECT EID_INSTANCE_DIM_SPEC FROM FND_EID_DDR_MGD_ATT_VALS)
       AND EID_INSTANCE_DIM_PARENT_SPEC <> '/';
    BEGIN
      SELECT 'Y' INTO l_orphan_exists
      FROM DUAL WHERE EXISTS(SELECT '1' FROM FND_EID_DDR_MGD_ATT_VALS WHERE EID_INSTANCE_DIM_PARENT_SPEC NOT IN
        (SELECT EID_INSTANCE_DIM_SPEC FROM FND_EID_DDR_MGD_ATT_VALS)
      AND EID_INSTANCE_DIM_PARENT_SPEC <> '/');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       l_orphan_exists := 'N';
    END;
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_managed_attr_metadata ' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_managed_attr_metadata;


PROCEDURE populate_precedence_rules
IS
  l_progress VARCHAR2(3);
BEGIN
  DELETE FROM FND_EID_PRECEDENCE_RULES WHERE eid_instance_id=1;
  INSERT
  INTO FND_EID_PRECEDENCE_RULES
    (
      EID_INSTANCE_ID,
      EID_INSTANCE_PRECEDENCE_RULE,
      TRIGGER_INSTANCE_ATTRIBUTE,
      TARGET_INSTANCE_ATTRIBUTE,
      TRIGGER_ATTR_VALUE,
      LEAF_TRIGGER_FLAG,
      EID_RELEASE_VERSION,
      OBSOLETED_FLAG,
      OBSOLETED_EID_RELEASE_VERSION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
  SELECT 1,
    SubStrB('ICX_'
    || ICX_ENDECA_UTIL_PKG.makeNCName(ATTRIBUTEKEY), 1,30),
    'SHOPPING_CATEGORY',
    SubStrB(ICX_ENDECA_UTIL_PKG.makeNCName(ATTRIBUTEKEY), 1,30),
    NULL,
    'N',
    '2.3',
    NULL,
    NULL,
    -1,
    sysdate,
    -1,
    SYSDATE,
   -1
  FROM ICX_CAT_ENDECA_ITEM_ATTRIBUTES ita,
    fnd_languages lang
  WHERE lang.language_code= ita.LANGUAGE
  AND lang.installed_flag ='B'
  GROUP BY ATTRIBUTEKEY;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_precedence_rules ' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_precedence_rules;


PROCEDURE get_applicable_zones
(
  p_zone_ids  OUT NOCOPY ICX_TBL_VARCHAR240,
  x_return_status OUT NOCOPY VARCHAR2
)
is
  l_progress VARCHAR2(3);
cursor zone_csr is
SELECT  to_char(zones.zone_id)
FROM    icx_cat_store_contents storecontent
       ,icx_cat_content_zones_b zones
WHERE   storecontent.content_type = 'CONTENT_ZONE'
AND     storecontent.content_id = zones.zone_id
AND     zones.TYPE in ('LOCAL','PUNCHOUT')
AND     (
                zones.security_assignment_flag = 'ALL_USERS'
        OR      (
                        zones.security_assignment_flag = 'OU_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the OU'
                        FROM    icx_cat_secure_contents ouassignments
                        WHERE   ouassignments.secure_by = 'OPERATING_UNIT'
                        AND     storecontent.content_id = ouassignments.content_id
                        AND     ouassignments.org_id = Nvl(fnd_global.org_id, mo_global.get_current_org_id)
                        )
                )
        OR      (
                        zones.security_assignment_flag = 'RESP_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the Responsibility'
                        FROM    icx_cat_secure_contents respassignments
                        WHERE   respassignments.secure_by = 'RESPONSIBILITY'
                        AND     storecontent.content_id = respassignments.content_id
                        AND     respassignments.responsibility_id = fnd_global.resp_id
                        )
                )
        );

begin

open zone_csr;
fetch zone_csr bulk collect into p_zone_ids;
close zone_csr;

exception when others then
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.get_applicable_zones ' || l_progress || 'SQLERRM:' || SQLERRM);
end  get_applicable_zones;


PROCEDURE get_applicable_contents(p_content_ids  OUT NOCOPY ICX_TBL_VARCHAR240,
                                  x_return_status OUT NOCOPY VARCHAR2)

is
  l_progress VARCHAR2(3);
cursor zone_csr is
SELECT  to_char(zones.zone_id)
FROM    icx_cat_store_contents storecontent
       ,icx_cat_content_zones_b zones
WHERE   storecontent.content_type = 'CONTENT_ZONE'
AND     storecontent.content_id = zones.zone_id
AND     zones.TYPE IN ('PUNCHOUT', 'INFORMATIONAL')
AND     (
                zones.security_assignment_flag = 'ALL_USERS'
        OR      (
                        zones.security_assignment_flag = 'OU_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the OU'
                        FROM    icx_cat_secure_contents ouassignments
                        WHERE   ouassignments.secure_by = 'OPERATING_UNIT'
                        AND     storecontent.content_id = ouassignments.content_id
                        AND     ouassignments.org_id = decode(fnd_global.org_id, -1, mo_global.get_current_org_id, fnd_global.org_id)
                        )
                )
        OR      (
                        zones.security_assignment_flag = 'RESP_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the Responsibility'
                        FROM    icx_cat_secure_contents respassignments
                        WHERE   respassignments.secure_by = 'RESPONSIBILITY'
                        AND     storecontent.content_id = respassignments.content_id
                        AND     respassignments.responsibility_id = fnd_global.resp_id
                        )
                )
        )
UNION ALL
SELECT To_Char(B.template_id)
    FROM por_noncat_templates_all_b B
    WHERE B.ORG_ID = -2 OR B.ORG_ID = decode(fnd_global.org_id, -1, mo_global.get_current_org_id, fnd_global.org_id);

begin

open zone_csr;
fetch zone_csr bulk collect into p_content_ids;
close zone_csr;

exception when others then
   RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.get_applicable_contents ' || l_progress || 'SQLERRM:' || SQLERRM);
end  get_applicable_contents;

Function get_attachment (p_inventory_item_id number,p_organization_id number) RETURN CLOB
is
l_clob		CLOB;
CURSOR shortattachment_cur (p_inventory_item_id number,p_organization_id number) IS
select
    fdst.short_text 	as
from
    FND_DOCUMENTS_SHORT_TEXT fdst,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fdst.media_id = fdv.media_id and
    fdv.datatype_id = 1 AND
    fad.document_id = fdv.document_id and
    fad.entity_name = 'MTL_SYSTEM_ITEMS' and
    fad.pk1_value = to_char(p_organization_id) and
    fad.pk2_value = to_char(p_inventory_item_id)
  order by fdv.file_name;

CURSOR longattachment_cur (p_inventory_item_id number,p_organization_id number) IS
   select
    fdlt.long_text
from
    FND_DOCUMENTS_LONG_TEXT fdlt,
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fdlt.media_id = fdv.media_id and
    fdv.datatype_id = 2 and
    fad.document_id = fdv.document_id and
    fad.entity_name = 'MTL_SYSTEM_ITEMS' and
    fad.pk1_value = to_char(p_organization_id) and
    fad.pk2_value = to_char(p_inventory_item_id)
  order by fdlt.media_id desc;

CURSOR fileattachment_cur (p_inventory_item_id number,p_organization_id number) IS
  SELECT
  FND_EID_ATTH_PKG.return_text(fl.file_id) AS text
  from
    fnd_documents_vl fdv,
    fnd_attached_documents fad ,
    fnd_lobs fl
  where
    fad.document_id = fdv.document_id and
    fad.entity_name = 'MTL_SYSTEM_ITEMS' AND
    fl.file_id= fdv.media_id   and
    fad.pk1_value= to_char(p_organization_id) and
    fad.pk2_value= to_char(p_inventory_item_id) and
    fdv.file_name  is not null and
    fdv.datatype_id =6 ;

CURSOR urlattachment_cur (p_inventory_item_id number,p_organization_id number) IS
  select
      fdv.url
  from
    fnd_documents_vl fdv,
    fnd_attached_documents fad
  where
    fad.document_id = fdv.document_id and
    fad.entity_name = 'MTL_SYSTEM_ITEMS' and
    fad.pk1_value= to_char(p_organization_id) and
    fad.pk2_value= to_char(p_inventory_item_id) and
    fdv.datatype_id=5;
begin
       l_clob:=NULL;

 if(p_inventory_item_id is null or p_organization_id is null ) then
   return l_clob;
 end if;
 -- short attachment
  begin
    for shortattachment_record in shortattachment_cur(p_inventory_item_id,p_organization_id) loop
        l_clob:=  l_clob||shortattachment_record.short_text  ;
    end loop;
   exception
   when  NO_DATA_FOUND then
     null;
  end;
  --long attachment
  begin
    for longattachment_record in longattachment_cur(p_inventory_item_id,p_organization_id) loop
        l_clob:=  l_clob||longattachment_record.long_text  ;
    end loop;
   exception
   when  NO_DATA_FOUND then
     null;
  end;
  --file attachment
  begin
    for fileattachment_record in fileattachment_cur(p_inventory_item_id,p_organization_id) loop
        l_clob:=  l_clob||fileattachment_record.text  ;
    end loop;
   exception
   when  NO_DATA_FOUND then
     null;
  end;

     --url attachment
    begin
    for urlattachment_record in urlattachment_cur(p_inventory_item_id,p_organization_id) loop
        l_clob:=  l_clob||urlattachment_record.url  ;
    end loop;
   exception
   when  NO_DATA_FOUND THEN

     null;
  end;

  RETURN l_clob;
end get_attachment;

procedure incrementalInsert

IS

lIHInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
lIHPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
lIHReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
lIHReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
lIHOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
lIHLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;

l_progress VARCHAR2(3);


BEGIN

-- inserting endeca item attributes

l_progress := '001';

SELECT inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, LANGUAGE
BULK COLLECT INTO   lIHInventoryItemIdTbl,     lIHPoLineIdTbl,lIHReqTemplateNameTbl,lIHReqTemplateLineNumTbl, lIHOrgIdTbl,lIHLanguageTbl
FROM icx_cat_items_ctx_hdrs_tlp WHERE  internal_Request_id =  ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id;


 l_progress := '002';

ICX_ENDECA_UTIL_PKG.insertIncrementalItem(lIHInventoryItemIdTbl,lIHPoLineIdTbl,lIHReqTemplateNameTbl,lIHReqTemplateLineNumTbl,lIHOrgIdTbl,lIHLanguageTbl);


 l_progress := '003';

COMMIT;

exception

 WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_ENDECA_UTIL_PKG.incrementalInsert'
        || l_progress || '): ' || SQLERRM);

END incrementalInsert;

procedure  incrementalDelete(gIHInventoryItemIdTbl   IN        DBMS_SQL.NUMBER_TABLE,
gIHPoLineIdTbl       IN           DBMS_SQL.NUMBER_TABLE,
gIHReqTemplateNameTbl  IN         DBMS_SQL.VARCHAR2_TABLE,
gIHReqTemplateLineNumTbl IN       DBMS_SQL.NUMBER_TABLE,
gIHOrgIdTbl                IN     DBMS_SQL.NUMBER_TABLE,
gIHLanguageTbl               IN   DBMS_SQL.VARCHAR2_TABLE
)

is

  l_progress VARCHAR2(3);
  i NUMBER;
  itemKey varchar2(200);

BEGIN

 l_progress := '001';

for i in 1..gIHInventoryItemIdTbl.count loop

itemKey := gIHInventoryItemIdTbl(i) || '#' || gIHPoLineIdTbl(i) || '#' || gIHReqTemplateNameTbl(i) || '#' || gIHReqTemplateLineNumTbl(i) || '#' || gIHOrgIdTbl(i) || '#' || gIHLanguageTbl(i);

delete from ICX_CAT_ENDECA_ITEM_ATTRIBUTES where recordkey = itemKey  ;

 l_progress := '002';

INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue) values(itemKey,'##DELETERECORD##','##DELETERECORD##');

end loop;

exception

WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.incrementalDelete ' || l_progress || 'SQLERRM:' || SQLERRM);

end incrementalDelete;


procedure insertIncrementalItem(gIHInventoryItemIdTbl   IN        DBMS_SQL.NUMBER_TABLE,
gIHPoLineIdTbl       IN           DBMS_SQL.NUMBER_TABLE,
gIHReqTemplateNameTbl  IN         DBMS_SQL.VARCHAR2_TABLE,
gIHReqTemplateLineNumTbl IN       DBMS_SQL.NUMBER_TABLE,
gIHOrgIdTbl                IN     DBMS_SQL.NUMBER_TABLE,
gIHLanguageTbl               IN   DBMS_SQL.VARCHAR2_TABLE)

  IS

 sql_query varchar2(32767);
  l_progress VARCHAR2(3);
  itemKey varchar2(4000);
  l_status varchar2(30);
  l_industry varchar2(30);
  l_result BOOLEAN;
  l_schema all_tables.owner%TYPE;

 CURSOR zones(zonetype VARCHAR2)
  IS
    SELECT DISTINCT 'sqe(icxz'
      || zonetype
      || zoneb.SQE_SEQUENCE
      ||')' sqe_exp ,
      zone_id
    FROM ICX_CAT_CONTENT_ZONES_B zoneb,
      ICX_CAT_STORE_CONTENTS_V contentv
    WHERE zoneb.ZONE_ID = contentv.CONTENT_ID
    AND zoneb.TYPE      ='LOCAL';
  CURSOR language_csr
  IS
    SELECT LANGUAGE_CODE
    FROM fnd_languages
    WHERE INSTALLED_FLAG IN ('I', 'B');
TYPE RecList
IS
  TABLE OF zones%ROWTYPE ;
  l_language_code fnd_languages.LANGUAGE_CODE%type;
  rec RecList;


  begin

  l_result := FND_INSTALLATION.GET_APP_INFO('PO', l_status, l_industry, l_schema);

  for i in 1..gIHInventoryItemIdTbl.count loop

-- Before inserting, delete the records if already there exists any with the same itemkey
delete from ICX_CAT_ENDECA_ITEM_ATTRIBUTES
where recordkey = gIHInventoryItemIdTbl(i) || '#' || gIHPoLineIdTbl(i) || '#' ||
      gIHReqTemplateNameTbl(i) || '#' || gIHReqTemplateLineNumTbl(i) || '#' || gIHOrgIdTbl(i) ||
      '#' || gIHLanguageTbl(i)    ;


 -- descriptors

 FOR attrRec IN
  (SELECT COLUMN_NAME
  FROM ALL_TAB_COLUMNS
  WHERE table_name = upper('po_attribute_values')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
 LOOP
  sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.INVENTORY_ITEM_ID || ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' || ' ||
    'pav.REQ_TEMPLATE_LINE_NUM|| ''#'' ||pav.ORG_ID|| ''#'' || icatl.language "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||attrRec.column_name || ' , icatl.language';
    sql_query := sql_query||' FROM po_attribute_values pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||attrRec.column_name || '''';
    sql_query := sql_query||' AND pav.INVENTORY_ITEM_ID ='||gIHInventoryItemIdTbl(i) || ' and  pav.PO_LINE_ID = '||
      gIHPoLineIdTbl(i) || ' and  pav.REQ_TEMPLATE_NAME =''' ||gIHReqTemplateNameTbl(i) || ''' and  pav.REQ_TEMPLATE_LINE_NUM =' ||
      gIHReqTemplateLineNumTbl(i) || ' and  pav.ORG_ID ='|| gIHOrgIdTbl(i) || ' and  icatl.language=''' || gIHLanguageTbl(i)||'''' ;
    sql_query := sql_query||' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES''  And (Icatl.Rt_Category_Id = Pav.Ip_Category_Id ' ||
      'or Icatl.Rt_Category_Id=0) AND '||attrRec.column_name||' IS NOT NULL';


    EXECUTE IMMEDIATE sql_query;
  END LOOP;

  --Translatable Attributes
  FOR attrRec IN
  (SELECT COLUMN_NAME
  FROM all_tab_columns
  WHERE table_name = upper('po_attribute_values_tlp')
  AND COLUMN_NAME LIKE '%ATTRIBUTE%'
  AND OWNER = l_schema
  )
  LOOP
    sql_query := 'INSERT INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES( recordkey, attributekey, attributevalue, LANGUAGE) ';
    sql_query := sql_query||'SELECT pav.INVENTORY_ITEM_ID|| ''#'' || pav.PO_LINE_ID|| ''#'' || pav.REQ_TEMPLATE_NAME|| ''#'' || '||
      'pav.REQ_TEMPLATE_LINE_NUM|| ''#'' || pav.ORG_ID|| ''#'' || pav.language "RecordSpec",Icatl.KEY "Attribute",';
    sql_query := sql_query||attrRec.column_name|| ' , pav.language';
    sql_query := sql_query||' FROM po_attribute_values_tlp pav,Icx_Cat_Attributes_Tl Icatl WHERE icatl.stored_in_column = ''';
    sql_query := sql_query||attrRec.column_name || '''';
    sql_query := sql_query||' AND pav.INVENTORY_ITEM_ID ='||gIHInventoryItemIdTbl(i) || ' and  pav.PO_LINE_ID = '|| gIHPoLineIdTbl(i) ||
    ' and  pav.REQ_TEMPLATE_NAME =''' ||gIHReqTemplateNameTbl(i) || ''' and  pav.REQ_TEMPLATE_LINE_NUM =' || gIHReqTemplateLineNumTbl(i) ||
    ' and  pav.ORG_ID ='|| gIHOrgIdTbl(i) || ' and  icatl.language=''' || gIHLanguageTbl(i)||'''' ;
    sql_query := sql_query||' AND icatl.stored_in_table    = ''PO_ATTRIBUTE_VALUES_TLP'' AND icatl.language = pav.language And ' ||
      '(Icatl.Rt_Category_Id = Pav.Ip_Category_Id or Icatl.Rt_Category_Id=0) AND '||attrRec.column_name||' IS NOT NULL';

    EXECUTE IMMEDIATE sql_query;

  END LOOP;

 -- zones data
  OPEN language_csr;
  LOOP
    FETCH language_csr INTO l_language_code;
    EXIT
  WHEN language_csr%notfound;
    OPEN zones('b');
    FETCH zones bulk COLLECT INTO rec;

   $IF DBMS_DB_VERSION.VER_LE_10 $THEN

    FOR j IN 1..rec.count  LOOP

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE ,
      'ZONESB',
      rec(j).zone_id,
      l_language_code
    FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

   END LOOP;

   $ELSE

    FORALL j IN 1..rec.count

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE ,
      'ZONESB',
      rec(j).zone_id,
      l_language_code
    FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    $END

    CLOSE zones;

    OPEN zones('p');

    FETCH zones bulk COLLECT INTO rec;

   $IF DBMS_DB_VERSION.VER_LE_10 $THEN

   FOR j IN 1..rec.count LOOP

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE,
      'ZONESP',
      rec(j).zone_id,
      l_language_code
     FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    END LOOP;

    $ELSE
    FORALL j IN 1..rec.count

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE,
      'ZONESP',
      rec(j).zone_id,
      l_language_code
     FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    $END

    CLOSE zones;

    OPEN zones('i');

    FETCH zones bulk COLLECT INTO rec;

    $IF DBMS_DB_VERSION.VER_LE_10 $THEN

    FOR j IN 1..rec.count LOOP

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE ,
      'ZONESI',
      rec(j).zone_id,
      l_language_code
    FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    END LOOP;

    $ELSE

    FORALL j IN 1..rec.count

    INSERT
    INTO ICX_CAT_ENDECA_ITEM_ATTRIBUTES
      (
        recordkey ,
        attributekey,
        attributevalue,
        language
      )
    SELECT INVENTORY_ITEM_ID || '#' ||PO_LINE_ID || '#' || REQ_TEMPLATE_NAME || '#' ||REQ_TEMPLATE_LINE_NUM || '#' ||ORG_ID || '#' ||LANGUAGE ,
      'ZONESI',
      rec(j).zone_id,
      l_language_code
    FROM icx_cat_items_ctx_hdrs_tlp
    WHERE
    inventory_item_id =gIHInventoryItemIdTbl(i)
    AND po_line_id = gIHPoLineIdTbl(i)
    AND req_template_name =  gIHReqTemplateNameTbl(i)
    AND req_template_line_num =  gIHReqTemplateLineNumTbl(i)
    AND org_id = gIHOrgIdTbl(i)
    AND LANGUAGE = gIHLanguageTbl(i)
    AND contains(ctx_Desc,
       rec(j).sqe_exp
      , 1) > 0
    AND language=l_language_code;

    $END

    CLOSE zones;

  END LOOP;
  CLOSE language_csr;


  end loop;


exception

WHEN OTHERS THEN

  RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.insertIncrementalItem ' ||
    l_progress || 'SQLERRM:' || SQLERRM);

end insertIncrementalItem;


Function makeNCName(p_attribute_name IN VARCHAR2) RETURN VARCHAR2
is
l_attribute_name varchar2(450);
begin
  l_attribute_name := p_attribute_name;
  l_attribute_name := replace(l_attribute_name, ' ', '_');
  l_attribute_name := replace(l_attribute_name, '/', '_');
  l_attribute_name := replace(l_attribute_name, '#', '_');
  l_attribute_name := replace(l_attribute_name, ',', '_');

  return l_attribute_name;
END makeNCName;

PROCEDURE populate_metadata IS
  l_progress varchar2(3);
BEGIN
  l_progress := '001';

  DELETE FROM FND_EID_PDR_ATTRS_B
  WHERE EID_INSTANCE_ID = 1
  AND EID_INSTANCE_ATTRIBUTE not in ('SHOPPING_CATEGORY',
  'CONTENT_TYPE_DISPLAY',
  'INTERNAL_ITEM_NUM',
  'SOURCE',
  'SUPPLIER',
  'SUPPLIER_SITE',
  'SUPPLIER_PART_NUM',
  'SUPPLIER_PART_AUXID',
  'MANUFACTURER',
  'MANUFACTURER_PART_NUM',
  'CONTENT_NAME',
  'CONTENT_TYPE',
  'PURCHASING_CATEGORY',
  'DESCRIPTION',
  'ITEM_REVISION',
  'UNIT_OF_MEASURE',
  'PRICE',
  'CURRENCY',
  'FUNCTIONAL_PRICE',
  'FUNCTIONAL_CURRENCY',
  'AVAILABILITY',
  'LEAD_TIME',
  'UNSPSC',
  'ALIAS',
  'COMMENTS',
  'LONG_DESCRIPTION',
  'ATTACHMENT',
  'ATTACHMENT_URL',
  'SUPPLIER_URL',
  'MANUFACTURER_URL',
  'ITEM_SOURCE_TEXT',
  'ITEM_SOURCE_URL',
  'ITEM_DETAIL_URL',
  'CONTENT_URL',
  'KEYWORDS',
  'ORG_ID',
  'LANGUAGE',
  'EID_ENDECA_ID',
  'EID_LAST_UPDATE_DATE',
  'THUMBNAIL_IMAGE',
  'CTX_DESC',
  'ZONESI',
  'ZONESP',
  'ZONESB',
  'CONTENT_ID',
  'RECORD_TYPE',
  'ZONE_ID',
  'DISPLAY_PRICE');

  DELETE FROM FND_EID_PDR_ATTRS_TL
  WHERE EID_INSTANCE_ID = 1
  AND EID_INSTANCE_ATTRIBUTE not in ('SHOPPING_CATEGORY',
  'CONTENT_TYPE_DISPLAY',
  'INTERNAL_ITEM_NUM',
  'SOURCE',
  'SUPPLIER',
  'SUPPLIER_SITE',
  'SUPPLIER_PART_NUM',
  'SUPPLIER_PART_AUXID',
  'MANUFACTURER',
  'MANUFACTURER_PART_NUM',
  'CONTENT_NAME',
  'CONTENT_TYPE',
  'PURCHASING_CATEGORY',
  'DESCRIPTION',
  'ITEM_REVISION',
  'UNIT_OF_MEASURE',
  'PRICE',
  'CURRENCY',
  'FUNCTIONAL_PRICE',
  'FUNCTIONAL_CURRENCY',
  'AVAILABILITY',
  'LEAD_TIME',
  'UNSPSC',
  'ALIAS',
  'COMMENTS',
  'LONG_DESCRIPTION',
  'ATTACHMENT',
  'ATTACHMENT_URL',
  'SUPPLIER_URL',
  'MANUFACTURER_URL',
  'ITEM_SOURCE_TEXT',
  'ITEM_SOURCE_URL',
  'ITEM_DETAIL_URL',
  'CONTENT_URL',
  'KEYWORDS',
  'ORG_ID',
  'LANGUAGE',
  'EID_ENDECA_ID',
  'EID_LAST_UPDATE_DATE',
  'THUMBNAIL_IMAGE',
  'CTX_DESC',
  'ZONESI',
  'ZONESP',
  'ZONESB',
  'CONTENT_ID',
  'RECORD_TYPE',
  'ZONE_ID',
  'DISPLAY_PRICE');

  DELETE FROM FND_EID_ATTR_GROUPS
  WHERE EID_INSTANCE_ID = 1
  AND EID_INSTANCE_GROUP = 'REFINEMENTS';


  ICX_ENDECA_UTIL_PKG.populate_KVPs;

  ICX_ENDECA_UTIL_PKG.populate_KVPs_for_punchout;

  ICX_ENDECA_UTIL_PKG.populate_attribute_metadata;

  ICX_ENDECA_UTIL_PKG.populate_managed_attr_metadata;

  ICX_ENDECA_UTIL_PKG.populate_precedence_rules;

  commit;

exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(-20000, 'Exception at ICX_ENDECA_UTIL_PKG.populate_metadata' || l_progress || 'SQLERRM:' || SQLERRM);
END populate_metadata;

procedure populate_metadata_SRS (errbuff OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER) is
begin
  populate_metadata;
end populate_metadata_SRS;

FUNCTION  isContentValid(contentId IN NUMBER ) RETURN VARCHAR2

 IS

isValidContent VARCHAR2(1):='N';

BEGIN

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
     'Start of isContentValid API');
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
     'contentId = ' || to_char(contentId));
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
     'fnd_global.org_id = ' || to_char(fnd_global.org_id) );
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
    'fnd_global.user_id = ' || to_char(fnd_global.user_id));
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
    'fnd_global.resp_id = ' || to_char(fnd_global.resp_id));
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
    'fnd_global.resp_appl_id = ' || to_char(fnd_global.resp_appl_id));
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, 'icx.plsql.icx_endeca_util_pkg.isContentValid',
     'mo_global.get_current_org_id = ' || to_char(mo_global.get_current_org_id));
END IF;


SELECT 'Y' INTO isValidContent FROM
(
SELECT  to_char(zones.zone_id) content_id
FROM    icx_cat_store_contents storecontent
       ,icx_cat_content_zones_b zones
WHERE   storecontent.content_type = 'CONTENT_ZONE'
AND     storecontent.content_id = zones.zone_id
AND     zones.TYPE IN ('PUNCHOUT', 'INFORMATIONAL')
AND     (
                zones.security_assignment_flag = 'ALL_USERS'
        OR      (
                        zones.security_assignment_flag = 'OU_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the OU'
                        FROM    icx_cat_secure_contents ouassignments
                        WHERE   ouassignments.secure_by = 'OPERATING_UNIT'
                        AND     storecontent.content_id = ouassignments.content_id
                        AND     ouassignments.org_id = decode(fnd_global.org_id, -1, mo_global.get_current_org_id, fnd_global.org_id)
                        )
                )
        OR      (
                        zones.security_assignment_flag = 'RESP_SECURED'
                AND     EXISTS
                        (
                        SELECT  'Assigned to the Responsibility'
                        FROM    icx_cat_secure_contents respassignments
                        WHERE   respassignments.secure_by = 'RESPONSIBILITY'
                        AND     storecontent.content_id = respassignments.content_id
                        AND     respassignments.responsibility_id = fnd_global.resp_id
                        )
                )
        )
UNION ALL
SELECT To_Char(B.template_id)  content_id
    FROM por_noncat_templates_all_b B
    WHERE B.ORG_ID = -2 OR B.ORG_ID = decode(fnd_global.org_id, -1, mo_global.get_current_org_id, fnd_global.org_id)
)

WHERE content_id  = contentId AND ROWNUM=1;

 RETURN isValidContent;

EXCEPTION

 WHEN No_Data_Found THEN

  isValidContent :='N';

 RETURN isValidContent;

END isContentValid;

PROCEDURE get_cart_desc(
	 p_last_updated_by IN NUMBER,
	 p_org_id          IN NUMBER,
	 x_req_header_id   OUT NOCOPY NUMBER,
     x_cart_desc       OUT NOCOPY VARCHAR2)
IS

l_cart_desc  varchar2(20);
l_req_header_id number ;

itemcount NUMBER;

BEGIN

SELECT requisition_header_id into l_req_header_id
FROM po_requisition_headers_all
WHERE active_shopping_cart_flag = 'Y'
AND last_updated_by = p_last_updated_by
AND org_id = p_org_id ;

SELECT itemcount, fnd_message.get_string('ICX','ICX_POR_TITLE_CART')||decode(ItemCount,0,'','('||ItemCount||')') into itemcount,l_cart_desc
FROM
(
SELECT  count(*) AS itemCount
FROM   po_requisition_headers_all ph,  po_requisition_lines_all pl
WHERE
ph.requisition_header_id = pl.requisition_header_id
AND  nvl(pl.cancel_flag, 'N') = 'N'
AND  nvl(pl.modified_by_agent_flag, 'N') = 'N'
AND  pl.line_location_id IS NULL
AND (nvl(ph.transferred_to_oe_flag, 'N') <> 'Y'
     OR  pl.source_type_code = 'VENDOR')
AND LABOR_REQ_LINE_ID is NULL
AND  ph.requisition_header_id = l_req_header_id
);


x_req_header_id := l_req_header_id ;
x_cart_desc :=l_cart_desc ;

Exception

WHEN OTHERS THEN
x_req_header_id := null;
x_cart_desc :=fnd_message.get_string('ICX','ICX_POR_TITLE_CART') ;

END  get_cart_desc;


FUNCTION load_content(p_url IN VARCHAR2)
RETURN CLOB
IS
  l_http_request  utl_http.req;
  l_http_response utl_http.resp;
  l_clob          CLOB;
  l_text          VARCHAR2(32767);
BEGIN
    -- Set the Proxy.
    set_proxy;

    utl_http.Set_response_error_check(FALSE);

    BEGIN
	    -- Make a HTTP request and get the response.
        l_http_request := utl_http.Begin_request(p_url);

        l_http_response := utl_http.Get_response(l_http_request);

        IF ( l_http_response.status_code >= 400
             AND l_http_response.status_code <= 599 ) THEN

			 -- handling both client side errors((400 to 499) as well as server side errors(500 to 599)

          utl_http.End_response(l_http_response);

          l_clob := NULL;
        ELSE
          -- Initialize the CLOB.
          dbms_lob.Createtemporary(l_clob, TRUE);
          dbms_lob.OPEN(l_clob, dbms_lob.lob_readwrite);

          -- Copy the response into the CLOB.
          LOOP
              utl_http.Read_text(l_http_response, l_text, 32767);
              dbms_lob.Writeappend (l_clob, Length(l_text), l_text);
          END LOOP;
        END IF;
    EXCEPTION
        WHEN utl_http.end_of_body THEN
          utl_http.End_response(l_http_response);
          dbms_lob.CLOSE(l_clob);
        WHEN OTHERS THEN
          utl_http.End_response(l_http_response);
          dbms_lob.CLOSE(l_clob);
          l_clob := NULL;
    END;

    RETURN l_clob;
EXCEPTION
  WHEN OTHERS THEN
       l_clob := NULL;
       RETURN l_clob;
END load_content;


PROCEDURE Set_proxy
IS
  l_proxy        VARCHAR2(500) := NULL;
  l_proxy_server VARCHAR2(450) := NULL;
BEGIN
    l_proxy_server := fnd_profile.Value('POR_PROXY_SERVER_NAME');

    IF( l_proxy_server IS NOT NULL ) THEN
      l_proxy := Trim((l_proxy_server)
                 ||':'
                 ||fnd_profile.Value('POR_PROXY_SERVER_PORT'));
    END IF;

    utl_http.Set_proxy(l_proxy, '');
END set_proxy;


END ICX_ENDECA_UTIL_PKG;

/
