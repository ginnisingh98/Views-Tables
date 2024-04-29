--------------------------------------------------------
--  DDL for Package Body PO_BULK_DOWNLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_BULK_DOWNLOAD_PKG" AS
/* $Header: POBLKDWNB.pls 120.0.12010000.25 2014/08/26 03:10:00 puppulur noship $ */

PROCEDURE download_lines_with_descrip(errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY VARCHAR2,
                         p_po_header_id        IN   NUMBER)
IS

    TYPE distinctCatIds IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    distinctCatIds_tab distinctCatIds;
    l_selected_cat_id NUMBER;
    l_temp_table_name VARCHAR2(200) := NULL;
    l_attr_data_select VARCHAR2(20000) := NULL;
    l_attr_data_where VARCHAR2(20000) := NULL;
    l_attr_data_from VARCHAR2(20000) := NULL;
    l_create_tab VARCHAR2(20000) := NULL;
    l_counter NUMBER;

    l_LineTypeMsg VARCHAR2(2000);
    l_LineNumMsg  VARCHAR2(2000);
    l_ExpirationDtMsg VARCHAR2(200);
    l_ShipToOrgMsg VARCHAR2(200);
    l_ShipToLocMsg VARCHAR2(200);
    l_QuantityMsg VARCHAR2(200);
    l_EffectiveFromMsg VARCHAR2(200);
    l_EffectiveToMsg VARCHAR2(200);
    l_BreakPriceMsg VARCHAR2(200);
    l_DiscountMsg VARCHAR2(200);
    l_item_sec_label varchar2(200);
    l_action_label varchar2(200);
    l_ItemSecMsg varchar2(200);
    l_ActionMsg varchar2(200);

    c sys_refcursor;

    TYPE attr_name_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.ATTRIBUTE_NAME%TYPE;
    TYPE stored_intable_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.STORED_IN_TABLE%TYPE;
    TYPE stored_incol_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.STORED_IN_COLUMN%TYPE;
    TYPE key_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.KEY%TYPE;
    TYPE rt_cat_id_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.RT_CATEGORY_ID%TYPE;
    TYPE lang_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.LANGUAGE%TYPE;
    TYPE attrids_tab IS TABLE OF ICX_CAT_ATTRIBUTES_TL.ATTRIBUTE_ID%TYPE;

    TYPE names_tab IS TABLE OF VARCHAR2(5000) INDEX BY VARCHAR2(100);

    TYPE key_tab_of_tables IS TABLE OF key_tab INDEX BY VARCHAR2(100);

    l_usrkeys_for_insert_by_cat  key_tab := key_tab();
    l_usrkeys_for_insert_forall key_tab_of_tables ;
    l_usrcols_for_select_by_cat  key_tab := key_tab();
    l_usrcols_for_select_forall key_tab_of_tables ;

    l_usrattr_col_str_for_create VARCHAR2(30000);




    l_base_desc_keys VARCHAR2(20000);
    l_prev_cat_tab_exits NUMBER;
    l_key_exists NUMBER;
    l_key_of_cat VARCHAR2(1000);
    l_key_of_unique_tab VARCHAR2(1000);
    l_key_tab_of_cat key_tab := key_tab();
    l_unique_usr_defined_desc VARCHAR2(20000);
    l_variable_cols VARCHAR2(30000);
    l_cat_key_exists NUMBER;
    l_key_of_tab VARCHAR2(1000);
    l_select_to_retrieve_dump CLOB;


    l_fixed_columns_in_temp VARCHAR2(20000);
    l_shipment_columns_in_temp VARCHAR2(20000);


    TYPE idtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE detailstype IS TABLE OF VARCHAR2(30000);

    po_line_id_tab idtype;
    po_details_tab  detailstype;



    l_BaseCatIdIndex number:=0;

    l_line_num_label VARCHAR2(50);
    l_line_type_label VARCHAR2(50);

    l_po_look_code  PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;


    l_attr_tlp_table VARCHAR2(100) := 'PO_ATTRIBUTE_VALUES_TLP';
    l_attr_table   VARCHAR2(100) := 'PO_ATTRIBUTE_VALUES';
    l_attr_tab_alias   VARCHAR2(20) := 'POLA';
    l_attrtlp_tab_alias VARCHAR2(20) := 'POTLP';


    lbase_attr_names  attr_name_tab;
    lbase_stored_tables stored_intable_tab;
    lbase_stored_columns  stored_incol_tab;
    lbase_keys key_tab;
    lbase_rt_cat_ids  rt_cat_id_tab;
    lbase_languages  lang_tab;
    lbase_attr_ids attrids_tab;

    lusr_attr_names  attr_name_tab;
    lusr_stored_tables stored_intable_tab;
    lusr_stored_columns  stored_incol_tab;
    lusr_keys key_tab;
    lusr_rt_cat_ids  rt_cat_id_tab;
    lusr_languages  lang_tab;
    lusr_attr_ids attrids_tab;


    lbase_attr_columns VARCHAR2(20000) := NULL ;
    lbase_attrtlp_columns VARCHAR2(20000) := NULL;
    lbase_attr_keys VARCHAR2(20000) := NULL;
    lbase_attrtlp_keys VARCHAR2(20000) := NULL;
    lbase_attr_col VARCHAR2(20000) := NULL;
    lbase_attrtlp_col VARCHAR2(20000) := NULL;

    lusr_attr_columns VARCHAR2(20000) := NULL ;
    lusr_attrtlp_columns VARCHAR2(20000) := NULL;
    lusr_attr_keys VARCHAR2(20000) := NULL;
    lusr_attrtlp_keys VARCHAR2(20000) := NULL;
    lusr_attr_col VARCHAR2(20000) := NULL;
    lusr_attrtlp_col VARCHAR2(20000) := NULL;

    l_exists_in_unique_attr_names NUMBER;

    l_unique_usr_attr_names_tab attr_name_tab := attr_name_tab();
    l_unique_temp_table_cols key_tab :=  key_tab();
    l_unique_key_tab key_tab := key_tab();
    l_subscript NUMBER;


    l_usr_cols_for_select VARCHAR2(30000);



    attrMetaDataCur SYS_REFCURSOR;
    l_po_lineattr_select VARCHAR2(20000);
    l_count NUMBER:=0;
    l_lang VARCHAR2(5) := UserEnv('lang');

    l_attr_metadata_select VARCHAR2(2000);
    l_attr_metadata_nullstored_col VARCHAR2(2000);
    l_index_textattr    NUMBER := 0;
    l_index_textattrtlp NUMBER := 0;
    l_index_numattr NUMBER := 0;
    l_index_numattrtlp NUMBER := 0;

    l_select_stmt VARCHAR2(20000) := NULL;
    l_insert_clause CLOB := NULL;
    l_attribute_names VARCHAR2(20000) := NULL;



    l_po_header_id NUMBER ;
    l_limit_rec NUMBER := 10000;
    loopCount NUMBER := 0;
    line_count_complete_tab NUMBER := 0;


    lp_selected_po_line_id NUMBER;
    lp_selected_ip_cat_id NUMBER;

    l_records_header VARCHAR2(30000) := NULL;
    l_record_header_usr_desc_tab   attr_name_tab := attr_name_tab();
    l_record_header_base_desc_tab  attr_name_tab := attr_name_tab();
    l_exists_in_rec_header NUMBER;

    l_created_table_names names_tab;


    l_text_col_datatyp VARCHAR2(30) := 'VARCHAR2(700)';

    l_long_col_datatyp VARCHAR2(30) := ' VARCHAR2(4000)';

    l_time varchar2(30);
    l_progress NUMBER;

    l_restrictAccess VARCHAR2(1):='N';


BEGIN

  l_po_header_id :=  p_po_header_id;
  retcode:='0';

  l_progress := 1;
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'Entered into download_lines procedure l_progress '||l_progress||' '||l_time);

  BEGIN
    po_global.set_role('SUPPLIER');
  END;

  BEGIN
    SELECT TYPE_LOOKUP_CODE
    INTO  l_po_look_code
    FROM  PO_HEADERS_ALL POH
    WHERE POH.PO_HEADER_ID = l_po_header_id;
  EXCEPTION
  WHEN No_Data_Found THEN
    --Dbms_Output.put_line('Purchase order with the id not found');
    RETURN;
  END;

  IF (l_po_look_code <> 'BLANKET') THEN
    --Dbms_Output.put_line('Purchase order provided is an Agreement');
    RETURN;
  END IF;


  /* Retrieving base Descriptors */

  l_progress := 2;
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'Entered Retrieving base Descriptors l_progress '||l_progress||' '||l_time);


  l_attr_metadata_nullstored_col := 'SELECT ATTRIBUTE_NAME,STORED_IN_TABLE,STORED_IN_COLUMN,KEY,RT_CATEGORY_ID,LANGUAGE,ATTRIBUTE_ID
	                                FROM ICX_CAT_ATTRIBUTES_TL ICATL
	                                WHERE LANGUAGE='''|| l_lang||''' AND
                                  KEY NOT IN ('''||'SUPPLIER'||''','''||'SUPPLIER_SITE'||''','''||'SOURCE'||''',
                                  '''||'CURRENCY'||''','''||'FUNCTIONAL_PRICE'||''','''||'FUNCTIONAL_CURRENCY'||''')
	                                AND Nvl(RESTRICT_ACCESS,'''||'N'||''')='||''''||l_restrictAccess||''''||' AND ICATL.RT_CATEGORY_ID = 0 ORDER BY SEQUENCE';

  --Dbms_Output.put_line(l_attr_metadata_nullstored_col);
  OPEN attrMetaDataCur FOR l_attr_metadata_nullstored_col;
  LOOP
		FETCH attrMetaDataCur
			BULK COLLECT INTO lbase_attr_names,lbase_stored_tables,lbase_stored_columns,lbase_keys,lbase_rt_cat_ids,lbase_languages,lbase_attr_ids;
			EXIT WHEN attrMetaDataCur%NOTFOUND;
  END LOOP;
  CLOSE attrMetaDataCur;

  /* Getting base Descriptors data */

        IF (lbase_attr_names.Count > 0) THEN
          FOR i IN lbase_attr_names.first .. lbase_attr_names.last
          LOOP
            IF(lbase_stored_tables(i) = l_attr_table) THEN
                IF ((lbase_stored_columns(i) LIKE 'TEXT_%') OR (lbase_stored_columns(i) LIKE 'TL_TEXT%')) THEN
                    IF (lbase_attr_columns IS NOT NULL) THEN
                      lbase_attr_columns := lbase_attr_columns ||','||l_attr_tab_alias||'.'||lbase_stored_columns(i)||''  ;
                    ELSE
                      lbase_attr_columns := l_attr_tab_alias||'.'||lbase_stored_columns(i)||' ' ;
                    END IF;

                    IF (lbase_attr_keys IS NOT NULL) THEN
                      lbase_attr_keys := lbase_attr_keys ||',"'||lbase_keys(i)||'"';
                      lbase_attr_col :=  lbase_attr_col  ||',"'||lbase_keys(i)||'"'||' ' ||l_text_col_datatyp;
                    ELSE
                      lbase_attr_keys := '"'||lbase_keys(i)||'"';
                      lbase_attr_col :=  lbase_attr_keys ||' '||l_text_col_datatyp;
                    END IF;

                ELSIF (lbase_stored_columns(i) LIKE 'NUM_%')  THEN
                    IF (lbase_attr_columns IS NOT NULL) THEN
                      lbase_attr_columns := lbase_attr_columns ||','||l_attr_tab_alias||'.'||lbase_stored_columns(i) ;
                    ELSE
                      lbase_attr_columns := l_attr_tab_alias||'.'||lbase_stored_columns(i);
                    END IF;

                    IF (lbase_attr_keys IS NOT NULL) THEN
                      lbase_attr_keys := lbase_attr_keys ||',"'||lbase_keys(i)||'"' ;
                      lbase_attr_col :=  lbase_attr_col||',"'||lbase_keys(i)||'"NUMBER';
                    ELSE
                      lbase_attr_keys := '"'||lbase_keys(i)||'"';
                      lbase_attr_col :=  lbase_attr_keys ||'NUMBER';
                    END IF;

                END IF;

          ELSIF (lbase_stored_tables(i) = l_attr_tlp_table) THEN
                IF ((lbase_stored_columns(i) LIKE 'TEXT_%') OR (lbase_stored_columns(i) LIKE 'TL_TEXT%')) THEN
                    IF (lbase_attrtlp_columns IS NOT NULL) THEN
                      lbase_attrtlp_columns := lbase_attrtlp_columns ||','||l_attrtlp_tab_alias||'.'||lbase_stored_columns(i) ||'' ;
                    ELSE
                      lbase_attrtlp_columns := l_attrtlp_tab_alias||'.'||lbase_stored_columns(i)||' ';
                    END IF;

                    IF (lbase_attrtlp_keys IS NOT NULL) THEN
                      lbase_attrtlp_keys := lbase_attrtlp_keys ||',"'||lbase_keys(i)||'"' ;
                      lbase_attrtlp_col := lbase_attrtlp_col ||',"'||lbase_keys(i)||'"'||' ' ||l_text_col_datatyp;
                    ELSE
                      lbase_attrtlp_keys := '"'||lbase_keys(i) ||'"';
                      lbase_attrtlp_col :=  lbase_attrtlp_keys ||' '||l_text_col_datatyp;
                    END IF;

                ELSIF (lbase_stored_columns(i) LIKE 'NUM_%')  THEN
                    IF (lbase_attrtlp_columns IS NOT NULL) THEN
                      lbase_attrtlp_columns := lbase_attrtlp_columns ||','||l_attrtlp_tab_alias||'.'||lbase_stored_columns(i)||'' ;
                    ELSE
                      lbase_attrtlp_columns := l_attrtlp_tab_alias||'.'||lbase_stored_columns(i)||'';
                    END IF;

                    IF (lbase_attrtlp_keys IS NOT NULL) THEN
                      lbase_attrtlp_keys := lbase_attrtlp_keys ||',"'||lbase_keys(i)||'"' ;
                      lbase_attrtlp_col := lbase_attrtlp_col ||',"'||lbase_keys(i)||'"NUMBER';
                    ELSE
                      lbase_attrtlp_keys := '"'||lbase_keys(i) ||'"';
                      lbase_attrtlp_col :=  lbase_attrtlp_keys ||'NUMBER';
                    END IF;
                END IF;
          END IF;
        END LOOP;
      END IF;


  l_progress := 3;
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'Retrieving base Descriptors completed l_progress '||l_progress||' '||l_time);


  /* Retrieving distinct shopping categories from purchase order lines */

   l_progress := 4;
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'Retrieving distinct shopping categories from purchase order lines l_progress '||l_progress||' '||l_time);

  BEGIN
	SELECT DISTINCT(IP_CATEGORY_ID) BULK COLLECT
	INTO distinctCatIds_tab
	FROM PO_LINES_MERGE_V
  WHERE PO_HEADER_ID = l_po_header_id
  AND Nvl(expiration_date,SYSDATE)>=sysdate
	AND IP_CATEGORY_ID IS NOT NULL;
  EXCEPTION
  WHEN No_Data_Found THEN
    --Dbms_Output.put_line('No Lines found in the Agreement');
	  RETURN;
  END;

  l_progress := 5;
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'Retrieving distinct shopping categories from purchase order lines l_progress '||l_progress||' '||l_time);

 l_count:= 0;
 l_count:=distinctCatIds_tab.Count;
 FND_FILE.put_line(FND_FILE.log,'Number of distinct shopping categories is '||l_count);

 l_progress := 6;

 /*Looping through the distinct shopping categories to retrive the user defined descriptors info*/
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress||' '||l_time);
  FND_FILE.put_line(FND_FILE.log,'Looping through the distinct shopping categories to retrive the user defined descriptors info start '||l_time);

	    IF  (l_count > 0) THEN

		    FOR i IN 1 .. distinctCatIds_tab.COUNT
		    LOOP
		      l_selected_cat_id := distinctCatIds_tab(i) ;

          IF (l_selected_cat_id <> -2) THEN
            l_attr_metadata_select := 'SELECT ATTRIBUTE_NAME,STORED_IN_TABLE,STORED_IN_COLUMN,KEY,RT_CATEGORY_ID,LANGUAGE,ATTRIBUTE_ID
	                                    FROM ICX_CAT_ATTRIBUTES_TL ICATL
	                                    WHERE STORED_IN_TABLE IN ('''||l_attr_table||''','''||l_attr_tlp_table||''')
                                      AND LANGUAGE='''|| l_lang||'''
	                                    AND Nvl(RESTRICT_ACCESS,'''||'N'||''')='||''''||l_restrictAccess||''''||' AND ICATL.RT_CATEGORY_ID IN ('|| l_selected_cat_id ||') ORDER BY rt_category_id,sequence ASC';

		        IF (l_selected_cat_id is not null) THEN

              OPEN attrMetaDataCur FOR l_attr_metadata_select;
				      LOOP
					      FETCH attrMetaDataCur
					      BULK COLLECT INTO lusr_attr_names,lusr_stored_tables,lusr_stored_columns,lusr_keys,lusr_rt_cat_ids,lusr_languages,lusr_attr_ids;
					      EXIT WHEN attrMetaDataCur%NOTFOUND;
              END LOOP;
              CLOSE attrMetaDataCur;
            END IF;

            select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;

            IF (lusr_rt_cat_ids.Count > 0) THEN

              FOR i IN lusr_rt_cat_ids.first .. lusr_rt_cat_ids.last
              LOOP
                IF(lusr_stored_tables(i) = l_attr_table) THEN
                  IF ((lusr_stored_columns(i) LIKE 'TEXT_%') OR (lusr_stored_columns(i) LIKE 'TL_TEXT%')
                    OR (lusr_stored_columns(i) LIKE 'NUM_%') ) THEN

                    lusr_attr_keys := '"'||lusr_keys(i) ||'"';
                    lusr_attr_col :=  lusr_attr_keys ||' '||l_text_col_datatyp;
                    lusr_attr_columns := l_attr_tab_alias||'.'||lusr_stored_columns(i)||' ' ;
                  END IF;
                ELSIF (lusr_stored_tables(i) = l_attr_tlp_table) THEN
                  IF ((lusr_stored_columns(i) LIKE 'TEXT_%') OR (lusr_stored_columns(i) LIKE 'TL_TEXT%')
                    OR (lusr_stored_columns(i) LIKE 'NUM_%') ) THEN

                    lusr_attr_keys := '"'||lusr_keys(i) ||'"';
                    lusr_attr_col :=  lusr_attr_keys ||' '||l_text_col_datatyp;
                    lusr_attr_columns := l_attrtlp_tab_alias||'.'||lusr_stored_columns(i)||' ' ;
                  END IF;
                END IF;
                l_key_exists:=0;
                FOR p IN 1 ..l_unique_key_tab.Count
                LOOP
                IF ( l_unique_key_tab(p) = lusr_attr_keys) THEN
                    l_key_exists := 1;
                    EXIT;
                  END IF;
                END LOOP;

                IF (l_key_exists = 0) THEN
                  l_subscript := l_unique_key_tab.Count+1;
                  l_unique_key_tab.extend;
                  l_unique_key_tab(l_subscript) := lusr_attr_keys;
                  l_unique_temp_table_cols.extend;
                  l_unique_temp_table_cols(l_subscript) := lusr_attr_col;
                  l_unique_usr_attr_names_tab.extend;
                  l_unique_usr_attr_names_tab(l_subscript) := lusr_attr_names(i);


                END IF;
                l_usrkeys_for_insert_by_cat.extend;
                l_usrkeys_for_insert_by_cat(i) := lusr_attr_keys;

                l_usrcols_for_select_by_cat.extend;
                l_usrcols_for_select_by_cat(i) := lusr_attr_columns;
              END LOOP;
            END IF;
            IF (l_usrkeys_for_insert_by_cat.Count <> 0) THEN
              l_usrkeys_for_insert_forall(''''||l_selected_cat_id||'''') := l_usrkeys_for_insert_by_cat;
              l_usrkeys_for_insert_by_cat.DELETE;
              l_usrcols_for_select_forall(''''||l_selected_cat_id||'''') := l_usrcols_for_select_by_cat;
              l_usrcols_for_select_by_cat.DELETE;
            END IF;
          END IF;
        END LOOP;
      END IF;

      l_progress:=7;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress||' '||l_time);
      FND_FILE.put_line(FND_FILE.log,'Looping through the distinct shopping categories to retrive the user defined descriptors info completed '||l_time);

      /* Constructing ddl to insert the data into a global temp table for each category*/

      l_temp_table_name := 'po_attr'||l_po_header_id||fnd_global.conc_request_id||fnd_global.user_id;

      l_progress:=8;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress||' '||l_time);
      FND_FILE.put_line(FND_FILE.log,'l_temp_table_name '||l_temp_table_name);
      --Dbms_Output.put_line(l_temp_table_name);

        l_create_tab := get_ddl_to_create_temp_table(l_temp_table_name);

        IF (lbase_attr_col IS NOT NULL) THEN
          l_create_tab := l_create_tab ||','|| lbase_attr_col;
        END IF;

        IF (lbase_attrtlp_col IS NOT NULL) THEN
          l_create_tab := l_create_tab ||','|| lbase_attrtlp_col;
        END IF;


        FOR i IN 1.. l_unique_temp_table_cols.Count
        LOOP
          IF (l_usrattr_col_str_for_create IS NULL ) THEN
            l_usrattr_col_str_for_create := l_unique_temp_table_cols(i);
          ELSE
            l_usrattr_col_str_for_create := l_usrattr_col_str_for_create ||','||l_unique_temp_table_cols(i);
          END IF;
        END LOOP;

        IF (l_usrattr_col_str_for_create IS NOT NULL) THEN
          l_create_tab := l_create_tab ||','||l_usrattr_col_str_for_create;
        END IF;

        l_create_tab := l_create_tab||') ON COMMIT PRESERVE ROWS';

        --Dbms_Output.put_line(l_create_tab);

        BEGIN


        FND_FILE.put_line(FND_FILE.log,'Table creation with name '||l_temp_table_name||' starts '||l_time);

          EXECUTE IMMEDIATE  l_create_tab;

        FND_FILE.put_line(FND_FILE.log,'Table creation with name '||l_temp_table_name||' completed '||l_time);

        EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.put_line(FND_FILE.log,'Exception while creating table '||l_temp_table_name);
          FND_FILE.put_line(FND_FILE.log,'Exception while creating table '||sqlerrm);
        END;

      /* Constructing select statement to retrieve the data for each category dynamically and insert*/


      FOR i IN 1 .. distinctCatIds_tab.COUNT
		  LOOP

        l_attr_data_select := NULL;
        l_attr_data_from := NULL;
        l_attr_data_where := NULL;
        l_select_stmt := NULL;
        l_insert_clause := NULL;
        l_usr_cols_for_select := NULL;


        l_attr_data_select :=  get_attr_data_select();
        l_attr_data_from := get_query_from_clause();
        l_attr_data_where  := get_query_where_clause(l_po_header_id,distinctCatIds_tab(i),l_lang);


        IF (lbase_attr_columns IS NOT NULL) THEN
            l_attr_data_select := l_attr_data_select ||','|| lbase_attr_columns;
        END IF;
        IF (lbase_attrtlp_columns IS NOT NULL) THEN
          l_attr_data_select := l_attr_data_select || ','||lbase_attrtlp_columns;
        END IF;
        --Dbms_Output.put_line('base columns for select '|| l_attr_data_select);

        l_progress:=9;
        select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
        FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
        FND_FILE.put_line(FND_FILE.log,'base columns for select '||l_attr_data_select||' '||l_time);


        IF (distinctCatIds_tab(i) <> -2) THEN
            --Dbms_Output.put_line(distinctCatIds_tab(i));
            IF (l_usrcols_for_select_forall.EXISTS(''''||distinctCatIds_tab(i)||'''')) THEN
              l_usrcols_for_select_by_cat:= l_usrcols_for_select_forall(''''||distinctCatIds_tab(i)||'''');
              FOR j IN 1 ..l_usrcols_for_select_by_cat.Count
              LOOP
                IF (l_usr_cols_for_select IS NOT NULL) THEN
                  l_usr_cols_for_select := l_usr_cols_for_select || ','||l_usrcols_for_select_by_cat(j);
                ELSE
                  l_usr_cols_for_select := l_usrcols_for_select_by_cat(j);
                END IF;
              END LOOP;
            END IF;
        END IF;

        --Dbms_Output.put_line('user columns for select '|| l_usr_cols_for_select);

        l_progress:=10;
        select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
        FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
        FND_FILE.put_line(FND_FILE.log,'user columns for select '||l_usr_cols_for_select||' '||l_time);


        IF (l_usr_cols_for_select IS NOT NULL) THEN
          l_attr_data_select :=  l_attr_data_select||','||l_usr_cols_for_select;
        END IF;

        l_select_stmt :=  l_attr_data_select ||' '|| l_attr_data_from||' '|| l_attr_data_where;

      /* Construct insert clause to insert into temp table*/

        l_insert_clause := get_data_insert_clause(l_temp_table_name);

        IF (lbase_attr_keys IS NOT NULL) THEN
          l_insert_clause  := l_insert_clause ||','|| lbase_attr_keys;
        END IF;

        IF (lbase_attrtlp_keys IS NOT NULL) THEN
          l_insert_clause := l_insert_clause ||','|| lbase_attrtlp_keys;
        END IF;

        IF (distinctCatIds_tab(i) <> -2) THEN
          IF (l_usrkeys_for_insert_forall.EXISTS(''''||distinctCatIds_tab(i)||'''')) THEN
            l_usrkeys_for_insert_by_cat:= l_usrkeys_for_insert_forall(''''||distinctCatIds_tab(i)||'''');

            FOR j IN 1 ..l_usrkeys_for_insert_by_cat.Count
            LOOP

              l_insert_clause := l_insert_clause || ','||l_usrkeys_for_insert_by_cat(j);

            END LOOP;
          END IF;
        END IF;


        l_insert_clause := l_insert_clause ||')  '|| l_select_stmt;


        select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
        FND_FILE.put_line(FND_FILE.log,'Insertion starts for category id '||distinctCatIds_tab(i)||' '||l_time);

        FND_FILE.put_line(FND_FILE.log,'l_insert_clause is '||l_insert_clause);


        EXECUTE IMMEDIATE  l_insert_clause;

        select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
        FND_FILE.put_line(FND_FILE.log,'Insertion completed for category id '||distinctCatIds_tab(i)||' '||l_time);

      END LOOP;


      FOR i IN 1 ..lbase_attr_names.Count
      LOOP
        IF  (l_attribute_names IS NULL ) THEN
          l_attribute_names := '"'||REPLACE(lbase_attr_names(i),'"','""')||'"';
        ELSE
          l_attribute_names := l_attribute_names||','||'"'||REPLACE(lbase_attr_names(i),'"','""')||'"';
        END IF;
      END LOOP;

      l_progress:=11;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'l_attribute_names '||l_attribute_names||' '||l_time);

      FOR i IN 1 ..l_unique_usr_attr_names_tab.Count
      LOOP
        IF  (l_attribute_names IS NULL ) THEN
          l_attribute_names := '"'||REPLACE(l_unique_usr_attr_names_tab(i),'"','""')||'"';
        ELSE
          l_attribute_names := l_attribute_names||','||'"'||REPLACE(l_unique_usr_attr_names_tab(i),'"','""')||'"';
        END IF;
      END LOOP;

      l_progress:=12;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'l_attribute_names after appending unique keys '||l_attribute_names||' '||l_time);

      /*

      Get Translated Line Number, Line Type Messages

      */
      BEGIN
      SELECT MEANING INTO l_LineNumMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='LINE_NUM'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN No_Data_Found THEN
       l_LineNumMsg:='Line Number';
      END;

      BEGIN
        SELECT MEANING INTO l_LineTypeMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='LINE_TYPE'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN No_Data_Found THEN
       l_LineTypeMsg:='Line Type';
      END;

      BEGIN
       SELECT MEANING INTO l_ItemSecMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TYPE'
	AND
	lookup_code='ITEM_SECTION'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ItemSecMsg:='Item Section';
      END;

      BEGIN
       SELECT MEANING INTO l_ActionMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TYPE'
	AND
	lookup_code='ACTION'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ActionMsg:='Action';
      END;

      l_item_sec_label:='"'||l_ItemSecMsg||'"';
      l_action_label:='"'||l_ActionMsg||'"';

      l_line_num_label := '"'||l_LineNumMsg||'"';
      l_line_type_label :='"'||l_LineTypeMsg||'"';

      l_records_header := l_item_sec_label||','||l_action_label||','||l_line_num_label||','|| l_line_type_label;
      l_records_header := l_records_header ||','||l_attribute_names;


      BEGIN
       SELECT MEANING INTO l_ExpirationDtMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='EXPIRATION_DATE'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ExpirationDtMsg:='Expiration Date';
      END;

      BEGIN
       SELECT MEANING INTO l_ShipToOrgMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='SHIP_TO_ORG'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ShipToOrgMsg:='Ship-To Org';
      END;

      BEGIN
       SELECT MEANING INTO l_ShipToLocMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='SHIP_TO_LOCATION'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ShipToLocMsg:='Ship-To Location';
      END;

BEGIN
       SELECT MEANING INTO l_QuantityMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='QUANTITY'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_QuantityMsg:='Quantity';
      END;

BEGIN
       SELECT MEANING INTO l_EffectiveFromMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='EFFECTIVE_FROM'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_EffectiveFromMsg:='Effective From';
      END;

BEGIN
       SELECT MEANING INTO l_EffectiveToMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='EFFECTIVE_TO'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_EffectiveToMsg:='Effective To';
      END;

BEGIN
       SELECT MEANING INTO l_BreakPriceMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='BREAK_PRICE'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_BreakPriceMsg:='Break Price';
      END;

BEGIN
       SELECT MEANING INTO l_DiscountMsg FROM fnd_lookup_values
	WHERE
	lookup_type='ICX_CAT_TXT_TOKENS'
	AND
	lookup_code='DISCOUNT'
	AND
	LANGUAGE=UserEnv('lang');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_DiscountMsg:='Discount';
      END;


      l_records_header := l_records_header ||','||'"'||l_ExpirationDtMsg||'"'||','||'"'||l_ShipToOrgMsg||'"'||','||'"'||l_ShipToLocMsg||'"'||','||'"'||l_QuantityMsg||'"'||',';
      l_records_header := l_records_header ||'"'||l_EffectiveFromMsg||'"'||','||'"'||l_EffectiveToMsg||'"'||','||'"'||l_BreakPriceMsg||'"'||','||'"'||l_DiscountMsg||'"';
      l_progress:=13;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'l_records_header is '||l_records_header||' '||l_time);

      --Dbms_Output.put_line(l_records_header);
      FND_FILE.put_line(FND_FILE.output,l_records_header);

      l_fixed_columns_in_temp:= get_fixed_columns();
      l_shipment_columns_in_temp:= get_shipment_columns();

      /* Base descriptors column string for fetching the concatenated data */
      /* Sequence Bug */

      FOR i IN lbase_attr_names.first .. lbase_attr_names.last
      LOOP

            IF (l_base_desc_keys IS NULL) THEN
                    l_base_desc_keys := '''"'''||'||REPLACE("'||lbase_keys(i)||'",''"'',''""'')||'||'''",''';

            ELSE
                    IF lbase_keys(i)='LONG_DESCRIPTION' THEN
                    l_base_desc_keys := l_base_desc_keys||'||''"'''||'||REPLACE(REPLACE(LONG_DESCRIPTION,''"'',''""''),fnd_global.local_chr(10),'' '')||'||'''",''';

                    ELSE
                    l_base_desc_keys := l_base_desc_keys||'||''"'''||'||REPLACE("'||lbase_keys(i)||'",''"'',''""'')||'||'''",''';
                    END IF;
            END IF;


      END LOOP;

    FOR i IN 1 .. l_unique_key_tab.Count
    LOOP
      IF (l_variable_cols IS NULL) THEN
        l_variable_cols:= '''"'''||'||REPLACE('||l_unique_key_tab(i)||',''"'',''""'')||'||'''",''';
      ELSE
        l_variable_cols := l_variable_cols ||'||''"'''||'||REPLACE('||l_unique_key_tab(i)||',''"'',''""'')||'||'''",''';
      END IF;
    END LOOP;

    IF (l_select_to_retrieve_dump IS NULL) THEN
          IF l_variable_cols IS NULL THEN
            l_select_to_retrieve_dump := 'SELECT'||' '||'LINE_NUM'||','||l_fixed_columns_in_temp||'||'',''||'||l_base_desc_keys||'||'||
            l_shipment_columns_in_temp||' '||'PO_LINE_DETAILS'||' '||'FROM'||' '||l_temp_table_name;

          ELSE
            l_select_to_retrieve_dump := 'SELECT'||' '||'LINE_NUM'||','||l_fixed_columns_in_temp||'||'',''||'||l_base_desc_keys||'||'||
            l_variable_cols||'||'||l_shipment_columns_in_temp||' '||'PO_LINE_DETAILS'||' '||'FROM'||' '||l_temp_table_name;
          END IF;
    END IF;

    l_select_to_retrieve_dump := 'SELECT'||' '||'LINE_NUM'||','||'PO_LINE_DETAILS'||' '||'FROM'||' '||'('||l_select_to_retrieve_dump||')'||' '||'ORDER BY LINE_NUM ASC';

    BEGIN
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'Final SELECT Query is '||l_select_to_retrieve_dump||l_time);

    EXCEPTION
    WHEN OTHERS THEN
    FND_FILE.put_line(FND_FILE.log,'Exception while printing l_select_to_retrieve_dump '||SQLERRM);
    END;

    BEGIN
      loopCount := 0;
      OPEN  c FOR  l_select_to_retrieve_dump;
      LOOP
        loopCount := loopCount+1;

        FETCH c BULK COLLECT INTO po_line_id_tab,po_details_tab LIMIT l_limit_rec;
        l_count:=0;
        l_count:=po_details_tab.Count;

        IF l_count>0 THEN

          FOR i IN po_details_tab.FIRST .. po_details_tab.LAST
          LOOP
            --Dbms_Output.put_line(Trim(po_details_tab(i)));
            FND_FILE.put_line(FND_FILE.output,',,'||po_details_tab(i));

          END LOOP;

          END IF;

          EXIT WHEN c%NOTFOUND;
        END LOOP;
        CLOSE c;
      END;

      BEGIN
      l_progress:=14;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'Dropping of table '||l_temp_table_name||' starts '||l_time);

      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_temp_table_name;
      EXECUTE IMMEDIATE  'DROP TABLE '||l_temp_table_name;

      l_progress:=15;
      select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress);
      FND_FILE.put_line(FND_FILE.log,'Dropping of table '||l_temp_table_name||' completed '||l_time);

      EXCEPTION
      WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress||' Exception while dropping table '||l_temp_table_name);
      FND_FILE.put_line(FND_FILE.log,'l_progress '||l_progress||'Exception while dropping table '||sqlerrm);
        NULL;
      END;


EXCEPTION
WHEN OTHERS THEN
  retcode:='2';
  select to_char(sysdate,'DD-MON-RRRR HH24:MI:SS') INTO l_time from dual;
  FND_FILE.put_line(FND_FILE.log,'In exception '||l_progress||' '||l_time || sqlerrm);
  NULL;
END download_lines_with_descrip;

FUNCTION  get_attr_data_select RETURN VARCHAR2 IS
l_attr_data_select VARCHAR(20000):= NULL;
BEGIN

               l_attr_data_select:= '   SELECT
                                        PLV.PO_LINE_ID,
                                        PLV.LINE_NUM,
                                        LT.LINE_TYPE,
                                        POLA.THUMBNAIL_IMAGE,
                                        POLA.PICTURE,
                                        PLV.ITEM_DESCRIPTION DESCRIPTION,
                                        ICAT.CATEGORY_NAME,
                                        mck.concatenated_segments,
                                        PLV.vendor_product_num,
                                        PLV.supplier_part_auxid,
                                        po_bulk_download_pkg.getItemNumber(item_id,PLV.org_id),
                                        PLV.ITEM_REVISION,
                                        POTLP.MANUFACTURER,
                                        POLA.MANUFACTURER_PART_NUM,
                                        mtluom.UOM_CODE,
                                        PLV.UNIT_PRICE,
                                        POLA.AVAILABILITY,
                                        POLA.LEAD_TIME,
                                        POLA.UNSPSC,
                                        POTLP.ALIAS,
                                        POTLP.COMMENTS,
                                        POTLP.LONG_DESCRIPTION,
                                        POLA.ATTACHMENT_URL,
                                        POLA.SUPPLIER_URL,
                                        POLA.MANUFACTURER_URL,
                                        unnum.UN_NUMBER,
                                        hzclass.hazard_class,
                                        PLV.EXPIRATION_DATE,
                                        ORGDEF.ORGANIZATION_NAME,
                                        HRLOC.LOCATION_CODE,
                                        PLLV.QUANTITY,
                                        PLLV.START_DATE,
                                        PLLV.END_DATE,
                                        PLLV.PRICE_OVERRIDE,
                                        PLLV.PRICE_DISCOUNT';

return l_attr_data_select;
END get_attr_data_select;


FUNCTION  get_query_from_clause RETURN VARCHAR2 IS
l_data_query_from_clause VARCHAR(20000):= NULL;
BEGIN

           l_data_query_from_clause := ' FROM PO_LINES_MERGE_V PLV,
                                       po_line_types LT,
                                       po_lookup_codes LC,
                                       po_lookup_codes LC1,
                                       mtl_categories_kfv mck,
                                       mtl_categories_vl mcv,
                                       mtl_units_of_measure mtluom,
                                       org_organization_definitions orgdef,
                                       hr_locations_all_tl hrloc,
                                       PO_HAZARD_CLASSES_VL hzclass,
                                       po_un_numbers unnum,
                                       PO_ATTR_VALUES_MERGE_V POLA,
                                       PO_LINE_LOCATIONS_MERGE_V PLLV,
                                       ICX_CAT_CATEGORIES_V ICAT,
                                       PO_ATTR_VALUES_TLP_MERGE_V POTLP' ;

RETURN l_data_query_from_clause;
END get_query_from_clause;


FUNCTION get_query_where_clause(l_po_header_id NUMBER,l_selected_cat_id NUMBER ,l_lang VARCHAR2) RETURN VARCHAR2
IS

l_data_query_where_clause VARCHAR2(20000) := NULL;

BEGIN

 l_data_query_where_clause := ' WHERE PLV.PO_LINE_ID=PLLV.PO_LINE_ID(+) AND
                                       LC.lookup_code = LT.order_type_lookup_code AND
                                       LC.lookup_type = '''||'ORDER TYPE'||''' AND
                                       LT.purchase_basis = LC1.lookup_code AND
                                       LC1.lookup_type = '''||'PURCHASE BASIS'||''' AND
                                       LT.line_type_id =  PLV.Line_Type_Id AND
                                       mck.category_id = mcv.category_id AND
                                       mck.category_id = plv.category_id AND
                                       mtluom.unit_of_measure (+) = PLV.UNIT_MEAS_LOOKUP_CODE AND
                                       mtluom.LANGUAGE (+) = '''|| l_lang||''' AND
                                       PLLV.SHIP_TO_ORGANIZATION_ID = orgdef.organization_id(+) AND
                                       PLLV.SHIP_TO_LOCATION_ID = hrloc.location_id(+) AND
                                       hrloc.LANGUAGE(+) = '''|| l_lang||''' AND
                                       hzclass.hazard_class_id(+) = PLV.HAZARD_CLASS_ID AND
                                       unnum.un_number_id(+) = PLV.UN_NUMBER_ID AND
                                       POLA.IP_CATEGORY_ID(+)=PLV.IP_CATEGORY_ID AND
                                       POLA.PO_LINE_ID(+)=PLV.PO_LINE_ID AND
                                       POTLP.IP_CATEGORY_ID(+)=PLV.IP_CATEGORY_ID AND
                                       POTLP.PO_LINE_ID(+)=PLV.PO_LINE_ID AND
                                       ICAT.RT_CATEGORY_ID(+) = PLV.IP_CATEGORY_Id AND
                                       ICAT.LANGUAGE(+) = '''|| l_lang||''' AND
                                       POTLP.LANGUAGE(+)='''|| l_lang||''' AND
                                       Nvl(PLV.expiration_date,SYSDATE)>=sysdate AND
                                       PlV.PO_HEADER_ID= '|| l_po_header_id ||
                                       ' AND PLV.IP_CATEGORY_ID ='|| l_selected_cat_id ||'';

RETURN l_data_query_where_clause;
END get_query_where_clause;



FUNCTION get_ddl_to_create_temp_table(l_temp_table_name VARCHAR2) RETURN VARCHAR2
IS
l_ddl_to_create_temp_tab VARCHAR2(20000) := NULL;
BEGIN

--l_ddl_to_create_temp_tab  := ' CREATE GLOBAL TEMPORARY TABLE '||' '||l_temp_table_name ||' '||
l_ddl_to_create_temp_tab  := ' CREATE GLOBAL TEMPORARY TABLE '||' '||l_temp_table_name ||' '||
        '(PO_LINE_ID NUMBER,LINE_NUM NUMBER, LINE_TYPE VARCHAR2(30),THUMBNAIL_IMAGE VARCHAR2(700),
          PICTURE VARCHAR2(700),DESCRIPTION VARCHAR2(240),SHOPPING_CATEGORY VARCHAR2(250),PURCHASING_CATEGORY VARCHAR2(250),
          SUPPLIER_PART_NUM VARCHAR2(25),SUPPLIER_PART_AUXID VARCHAR2(255),INTERNAL_ITEM_NUM VARCHAR2(250),
          ITEM_REVISION VARCHAR2(3),MANUFACTURER VARCHAR2(700),MANUFACTURER_PART_NUM VARCHAR2(700),
          UOM VARCHAR2(25),PRICE NUMBER,AVAILABILITY VARCHAR2(700),LEAD_TIME NUMBER,
          UNSPSC VARCHAR2(700),ALIAS VARCHAR2(700),COMMENTS VARCHAR2(700),LONG_DESCRIPTION VARCHAR2(4000),
          ATTACHMENT_URL VARCHAR2(700),SUPPLIER_URL VARCHAR2(700),MANUFACTURER_URL VARCHAR2(700),
          UN_NUMBER VARCHAR2(25),HAZARD_CLASS VARCHAR2(25),EXPIRATION_DATE DATE,SHIP_TO_ORGNAME VARCHAR2(250),
          SHIP_TO_LOCATION_CODE VARCHAR2(250),QUANTITY NUMBER,START_DATE DATE,END_DATE DATE,PRICE_OVERRIDE NUMBER,
          PRICE_DISCOUNT NUMBER';

RETURN l_ddl_to_create_temp_tab;
END get_ddl_to_create_temp_table;

FUNCTION get_data_insert_clause(l_temp_table_name VARCHAR2) RETURN VARCHAR2
IS
l_insert_data_clause VARCHAR2(20000) := NULL;
BEGIN
l_insert_data_clause := 'INSERT INTO ' || l_temp_table_name ||' '|| '(PO_LINE_ID ,LINE_NUM , LINE_TYPE ,
         THUMBNAIL_IMAGE , PICTURE , DESCRIPTION , SHOPPING_CATEGORY,PURCHASING_CATEGORY,
         SUPPLIER_PART_NUM ,SUPPLIER_PART_AUXID ,INTERNAL_ITEM_NUM,ITEM_REVISION , MANUFACTURER ,
         MANUFACTURER_PART_NUM ,UOM,PRICE,AVAILABILITY ,LEAD_TIME,UNSPSC, ALIAS,
         COMMENTS,LONG_DESCRIPTION,ATTACHMENT_URL,SUPPLIER_URL,MANUFACTURER_URL,UN_NUMBER,
         HAZARD_CLASS ,EXPIRATION_DATE ,SHIP_TO_ORGNAME ,SHIP_TO_LOCATION_CODE,
         QUANTITY ,START_DATE ,END_DATE ,PRICE_OVERRIDE ,PRICE_DISCOUNT';



RETURN l_insert_data_clause;
END get_data_insert_clause;

FUNCTION getItemNumber(itemId NUMBER,orgId NUMBER) RETURN VARCHAR2
IS
l_CONCATENATED_SEGMENTS MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
IF itemId IS NULL THEN
RETURN NULL;
END IF;

BEGIN
select CONCATENATED_SEGMENTS INTO l_CONCATENATED_SEGMENTS from MTL_SYSTEM_ITEMS_KFV
WHERE INVENTORY_ITEM_ID= itemId AND ORGANIZATION_ID=orgId
AND ROWNUM=1;

RETURN l_CONCATENATED_SEGMENTS;
EXCEPTION
WHEN No_Data_Found THEN
FND_FILE.put_line(FND_FILE.log,'Exception in getItemNumber '||sqlerrm);
RETURN NULL;
END;
END getItemNumber;


FUNCTION get_fixed_columns RETURN VARCHAR2
IS

l_fixed_columns_in_temp VARCHAR2(20000);
BEGIN
/*
l_fixed_columns_in_temp:=      '''"'''||'||LINE_NUM||'||'''","'''||'||REPLACE(LINE_TYPE,''"'',''""'')||'||'''","'''||'||REPLACE(THUMBNAIL_IMAGE,''"'',''""'')||'||'''","'''
             ||'||REPLACE(PICTURE,''"'',''""'')||'||'''","'''||'||REPLACE(DESCRIPTION,''"'',''""'')||'||'''","'''||'||REPLACE(IP_CATEGORY,''"'',''""'')||'||'''","'''
             ||'||REPLACE(CATEGORY,''"'',''""'')||'||'''","'''||'||REPLACE(VENDOR_PRODUCT_NUM,''"'',''""'')||'||'''","'''||'||REPLACE(SUPPLIER_PART_AUXID,''"'',''""'')||'||'''","'''
             ||'||REPLACE(ITEM_NUMBER,''"'',''""'')||'||'''","'''||'||REPLACE(ITEM_REVISION,''"'',''""'')||'||'''","'''||'||REPLACE(MANUFACTURER,''"'',''""'')||'||'''","'''
             ||'||REPLACE(MANUFACTURER_PART_NUM,''"'',''""'')||'||'''","'''||'||REPLACE(UOM_CODE,''"'',''""'')||'||'''","'''||'||UNIT_PRICE||'||'''","'''
             ||'||REPLACE(AVAILABILITY,''"'',''""'')||'||'''","'''||'||LEAD_TIME||'||'''","'''||'||REPLACE(UNSPSC,''"'',''""'')||'||'''","'''
             ||'||REPLACE(ALIAS,''"'',''""'')||'||'''","'''||'||REPLACE(COMMENTS,''"'',''""'')||'||'''","'''||'||REPLACE(REPLACE(LONG_DESCRIPTION,''"'',''""''),fnd_global.local_chr(10),'' '')||'||'''","'''
             ||'||REPLACE(ATTACHMENT_URL,''"'',''""'')||'||'''","'''||'||REPLACE(SUPPLIER_URL,''"'',''""'')||'||'''","'''||'||REPLACE(MANUFACTURER_URL,''"'',''""'')||'||'''","'''
             ||'||REPLACE(UN_NUMBER,''"'',''""'')||'||'''","'''||'||REPLACE(HAZARD_CLASS,''"'',''""'')||'||'''"''' ;
*/

l_fixed_columns_in_temp:=      '''"'''||'||LINE_NUM||'||'''","'''||'||REPLACE(LINE_TYPE,''"'',''""'')||'||'''"''' ;


RETURN l_fixed_columns_in_temp;
END  get_fixed_columns;


FUNCTION get_shipment_columns RETURN VARCHAR2
IS
l_shipment_columns_in_temp VARCHAR2(20000);
BEGIN
        l_shipment_columns_in_temp := '''"'''||'||EXPIRATION_DATE||'||'''","'''||'||REPLACE(SHIP_TO_ORGNAME,''"'',''""'')||'||'''","'''||'||REPLACE(SHIP_TO_LOCATION_CODE,''"'',''""'')||'||'''","'''||
        '||QUANTITY||'||'''","'''||'||START_DATE||'||'''","'''||'||END_DATE||'||'''","'''||'||PRICE_OVERRIDE||'||'''","'''||'||PRICE_DISCOUNT||'||'''"''';

RETURN l_shipment_columns_in_temp;
END get_shipment_columns;


END po_bulk_download_pkg;

/
