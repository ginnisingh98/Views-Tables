--------------------------------------------------------
--  DDL for Package Body FEM_TABLE_PUBLISH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_TABLE_PUBLISH_PKG" AS
/* $Header: FEMVDIPUBB.pls 120.3 2007/07/30 15:18:12 gdonthir noship $ */

PROCEDURE Generate_XML_CP(
  x_retcode        OUT NOCOPY NUMBER,
  x_errbuff        OUT NOCOPY VARCHAR2,
  p_diObjDefId IN NUMBER,
  p_view IN VARCHAR2,
  p_comp_totals IN VARCHAR2
 )
IS

x_xml_result CLOB;


BEGIN
Generate_XML(
  x_retcode,
  x_errbuff,
  p_diObjDefId,
  x_xml_result,
  'OFFLINE',
  p_view,
  p_comp_totals);

EXCEPTION

 WHEN OTHERS THEN
   fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                                p_module   => g_block||'.Generate_XML_CP()',
                                p_msg_text => 'EXCEPTION BLOCK:'||sqlerrm);

   x_retCode := 2;

END Generate_XML_CP;



PROCEDURE Run_Report
(
 x_req_id OUT NOCOPY NUMBER,
 x_retcode OUT NOCOPY NUMBER,
 x_errbuff OUT NOCOPY VARCHAR2,
 x_xml_result OUT NOCOPY CLOB,
 p_diObjDefId IN NUMBER,
 p_gen_mode IN VARCHAR2,
 p_gen_format IN VARCHAR2,
 p_gen_template IN VARCHAR2,
 p_view IN VARCHAR2,
 p_comp_totals IN VARCHAR2,
 p_diQuery IN VARCHAR2
)
IS

l_xml_layout boolean:=FALSE;
l_req_id NUMBER;
l_iso_lang VARCHAR2(2);
l_iso_terr VARCHAR2(2);

CURSOR get_lang_terr_csr IS
SELECT LOWER(ISO_LANGUAGE) lang, ISO_TERRITORY terr FROM FND_LANGUAGES WHERE LANGUAGE_CODE = USERENV('LANG');


BEGIN

fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Run_Report()',
                              p_msg_text => 'Parameters:'||p_diObjDefId||','||p_gen_mode||','||p_gen_format||','||p_gen_template||','||p_view||','||p_comp_totals||','||p_diQuery);


FOR lang_rec in get_lang_terr_csr LOOP
 l_iso_lang := lang_rec.lang;
 l_iso_terr := lang_rec.terr;
END LOOP;

fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Run_Report()',
                              p_msg_text => 'l_iso_lang:' ||l_iso_lang ||','||'l_iso_terr:'||l_iso_terr);

IF p_gen_template = 'FEMDIREP' THEN

IF p_gen_mode = 'OFFLINE' THEN
 l_xml_layout := FND_REQUEST.ADD_LAYOUT('FEM',p_gen_template,l_iso_lang,l_iso_terr,p_gen_format);
 l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                 (application   =>  'FEM',
                  program       =>  'FEMDIREPDEF',
                  description   =>  NULL,
                  start_time    =>  NULL,
                  sub_request   =>  FALSE,
                  argument1     =>  p_diObjDefId,
                  argument2     =>  p_view,
                  argument3     =>  p_comp_totals
                  );
  x_req_id := l_req_id;
ELSE

 Generate_XML(
  x_retcode,
  x_errbuff,
  p_diObjDefId,
  x_xml_result,
  p_gen_mode,
  p_view,
  p_comp_totals);

END IF;

ELSE

IF p_gen_mode = 'OFFLINE' THEN
 l_xml_layout := FND_REQUEST.ADD_LAYOUT('FEM',p_gen_template,l_iso_lang,l_iso_terr,p_gen_format);
 l_req_id :=  FND_REQUEST.SUBMIT_REQUEST
                 (application   =>  'FEM',
                  program       =>  'FEMDICREPDEF',
                  description   =>  NULL,
                  start_time    =>  NULL,
                  sub_request   =>  FALSE,
                  argument1     =>  p_diObjDefId,
                  argument2     =>  p_diQuery,
                  argument3     =>  p_view
                  );
  x_req_id := l_req_id;
ELSE

 Generate_Cust_XML(
  p_diObjDefId,
  p_diQuery,
  p_gen_mode,
  p_view,
  x_xml_result
 );

END IF;

END IF;
COMMIT;
END Run_Report;





PROCEDURE Generate_XML(
  x_retcode        OUT NOCOPY NUMBER,
  x_errbuff        OUT NOCOPY VARCHAR2,
  p_diObjDefId IN NUMBER,
  x_xml_result OUT NOCOPY CLOB,
  p_mode IN VARCHAR2,
  p_view IN VARCHAR2,
  p_comp_totals IN VARCHAR2)
IS

selectclause CLOB;
l_query CLOB;
fromclause CLOB;
--tablename CLOB;
l_metadata_xml CLOB;
l_test_xml CLOB;
l_test1_xml CLOB;
dim VARCHAR2(20);
l_xmlresult CLOB;
--queryCtx DBMS_XMLGEN.ctxHandle;
queryCtx DBMS_XMLquery.ctxType;
l_tablename VARCHAR2(50);
l_clob_size   NUMBER;
l_data_size   NUMBER;
l_offset      NUMBER;
l_chunk_size  INTEGER;
l_chunk       VARCHAR2(32767);
l_condition_Obj_id NUMBER;
l_condition_name VARCHAR2(100);
whereClause CLOB;
l_dataHeaderClob CLOB;
l_table_display_name VARCHAR2(255);
l_di_name VARCHAR2(255);
l_header varchar2(200);
l_data_present varchar2(4);
col_count NUMBER:=0;
P_INSTN_AMT INTEGER:=23;
l_eraseamt INTEGER:=3;
P_RT_AMT BINARY_INTEGER:=6;
l_bal_sum NUMBER;
l_bal_sum_query VARCHAR2(32767);
l_bal_cols_present varchar2(4):='No';
l_order_col VARCHAR2(30);
l_sort_dir_flag VARCHAR2(1);
l_order_by_added VARCHAR2(1):='N';
l_queryString VARCHAR2(32767);
l_xmlString VARCHAR2(32767);

--CURSOR get_required_columns_cursor(p_tablename IN VARCHAR2) IS
CURSOR get_required_columns_cursor IS
SELECT DataInspectorColumnsEO.DATA_INSPECTOR_OBJ_DEF_ID,
       DataInspectorColumnsEO.TABLE_NAME,
       DataInspectorColumnsEO.COLUMN_NAME,
       DataInspectorColumnsEO.DISPLAY_SEQUENCE,
       EnabledTableColumnEO.DISPLAY_NAME,
       EnabledTableColumnEO.FEM_DATA_TYPE_CODE,
       EnabledTableColumnEO.DIMENSION_ID,
       DataInspectorColumnsEO.SORT_SEQUENCE,
       DataInspectorColumnsEO.SORT_DIRECTION_FLAG,
       (select member_name_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_name_col,
       (select member_display_code_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_code_col,
(select member_vl_object_name from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_table_name,
(select dimension_varchar_label from fem_dimensions_b where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
dimension_varchar_label,
(select dimension_name from fem_dimensions_vl where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS dimension_name,
(select member_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS member_col
FROM   FEM_DATA_INSPECTOR_COLS DataInspectorColumnsEO,
       FEM_TAB_COLUMNS_V EnabledTableColumnEO
WHERE  EnabledTableColumnEO.TABLE_NAME = DataInspectorColumnsEO.TABLE_NAME
AND    EnabledTableColumnEO.COLUMN_NAME = DataInspectorColumnsEO.COLUMN_NAME
AND    DataInspectorColumnsEO.DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId
ORDER BY DataInspectorColumnsEO.DISPLAY_SEQUENCE ASC;

CURSOR column_order_csr IS
SELECT COLUMN_NAME,
       SORT_SEQUENCE,
       SORT_DIRECTION_FLAG
FROM   FEM_DATA_INSPECTOR_COLS
WHERE  DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId
AND    SORT_SEQUENCE IS NOT NULL
ORDER BY SORT_SEQUENCE ASC;

CURSOR get_table_name_csr IS
SELECT TABLE_NAME FROM FEM_DATA_INSPECTORS WHERE DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId;

CURSOR get_condition_Obj_id_cursor IS
SELECT FEM_DATA_INSPECTORS.CONDITION_OBJ_ID, FEM_OBJECT_CATALOG_VL.OBJECT_NAME  FROM    FEM_DATA_INSPECTORS, FEM_OBJECT_CATALOG_VL
   WHERE FEM_DATA_INSPECTORS.DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId AND
        FEM_OBJECT_CATALOG_VL.OBJECT_ID = FEM_DATA_INSPECTORS.CONDITION_OBJ_ID;

CURSOR get_table_display_name_cursor IS
SELECT DISPLAY_NAME FROM FEM_TABLES_VL WHERE TABLE_NAME = l_tablename;

cURSOR get_di_name_csr is
SELECT display_name from fem_object_definition_vl where object_definition_id = p_diObjDefId;

BEGIN

fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Generate_XML()',
                              p_msg_text => 'BEGIN');

dim := 'DIMENSION';
fnd_file.put_line(fnd_file.log, '***************************Parameters****************************');
fnd_file.put_line(fnd_file.log, '*   DI Object Def Id : ' || to_char(p_diObjDefId));

/*****************************************************************
Get the Table name
*****************************************************************/

OPEN get_table_name_csr;
FETCH get_table_name_csr INTO l_tableName;
CLOSE get_table_name_csr;

/*****************************************************************
Get the condition details.
*****************************************************************/

OPEN get_condition_obj_id_cursor;
FETCH get_condition_obj_id_cursor INTO l_condition_obj_id,l_condition_name ;
CLOSE get_condition_obj_id_cursor;

fnd_file.put_line(fnd_file.log,'*   Condition Id: ' || l_condition_obj_id);

/*****************************************************************
Get the DI Name.
*****************************************************************/

OPEN get_di_name_csr;
 FETCH get_di_name_csr INTO l_di_name;
CLOSE get_di_name_csr;

fnd_file.put_line(fnd_file.log,'*   DI Name: ' || l_di_name);

/*****************************************************************
Get the Condition predicate.
*****************************************************************/

IF l_condition_obj_id IS NOT NULL THEN
   getConditionPredicate(l_condition_obj_id,l_tableName,whereClause);
END IF;

fnd_file.put_line(fnd_file.log,'*   Condition Predicate: ' || whereClause);


/*****************************************************************
Get the table display name.
*****************************************************************/

OPEN get_table_display_name_cursor;
FETCH get_table_display_name_cursor INTO l_table_display_name;
CLOSE get_table_display_name_cursor;

fnd_file.put_line(fnd_file.log,'*   Table Display Name: ' || l_table_display_name);


fnd_file.put_line(fnd_file.log,'*   Show: ' || p_view);
fnd_file.put_line(fnd_file.log,'*   Compute Column Totals: ' || p_comp_totals);
fnd_file.put_line(fnd_file.log,'*   Execute: ' || p_mode);
fnd_file.put_line(fnd_file.log,'***************************Parameters****************************');
fnd_file.put_line(fnd_file.log,'                                                                 ');

/*****************************************************************
Add header details to CLOB
*****************************************************************/
dbms_lob.createtemporary(l_metadata_xml,TRUE);

l_xmlString := '<?xml version=''1.0''?>';
l_xmlString := l_xmlString || '<Root>';
l_xmlString := l_xmlstring || ' <TABLE_NAME>'|| l_table_display_name || '</TABLE_NAME>';
l_xmlString := l_xmlString || ' <CONDITION_NAME>'|| l_condition_name || '</CONDITION_NAME>';
l_xmlString := l_xmlString || ' <DI_NAME>'|| l_di_name || '</DI_NAME>';
l_xmlString := l_xmlString || ' <COL_DEFS>';

dbms_lob.writeappend(l_metadata_xml,LENGTH(l_xmlString),l_xmlString);
/**********************************************************
 Prepare the query
***********************************************************/
dbms_lob.createtemporary(selectClause,TRUE);
dbms_lob.createtemporary(l_query,TRUE);

FOR row_record in get_required_columns_cursor LOOP


l_tablename := row_record.TABLE_NAME;
col_count := col_count + 1;


l_xmlString := '  <COL_DEF>';
l_xmlString := l_xmlString || '   <COL_NUM>'||col_count||'</COL_NUM> ';
l_xmlString := l_xmlString || '   <COL_NAME>'||row_record.DISPLAY_NAME||'</COL_NAME> ' ;
l_xmlString := l_xmlString || '   <COL_TYPE>' || row_record.FEM_DATA_TYPE_CODE ||'</COL_TYPE> ';

IF(p_comp_totals = 'Y' AND row_record.FEM_DATA_TYPE_CODE = 'BALANCE') THEN
 l_bal_cols_present := 'Yes';
 l_bal_sum_query := ' SELECT SUM(' || row_record.COLUMN_NAME || ') FROM ' || row_record.TABLE_NAME;

 IF whereClause IS NOT NULL THEN
   l_bal_sum_query := l_bal_sum_query || ' WHERE ' || whereClause;
 END IF;

 fnd_file.put_line(fnd_file.log,'Bal Sum Query: ' || l_bal_sum_query);
 fnd_file.put_line(fnd_file.log,'                                                                 ');
 EXECUTE IMMEDIATE l_bal_sum_query INTO l_bal_sum;
 l_xmlString := l_xmlString || '  <COL_TOTAL>' || l_bal_sum ||'</COL_TOTAL> ';

ELSE

 l_bal_cols_present := 'No';

END IF;

l_xmlString := l_xmlString || '  </COL_DEF>';


 IF (row_record.FEM_DATA_TYPE_CODE = dim AND (p_view = 'Name')) THEN
   l_queryString := ' CURSOR ( SELECT '''||  col_count ||  ''' as colNum,
'||row_record.member_table_name || '.' || row_record.member_name_col || ' as colValue ' ||' from ' ||
row_record.member_table_name || ', ' || l_tablename ||' b ' ||' where ' || row_record.member_table_name || '.' || row_record.member_col || '(+)=' ||
'b' || '.'||row_record.COLUMN_NAME || ' and  a.rowid = b.rowid ' || ') as col , ';

 ELSIF (row_record.FEM_DATA_TYPE_CODE = dim AND (p_view = 'Code')) THEN
   l_queryString := ' CURSOR ( SELECT ''' || col_count || ''' as colNum,
'||row_record.member_table_name || '.' || row_record.member_code_col || ' as colValue ' ||' from ' ||
row_record.member_table_name || ', ' || l_tablename ||' b ' ||' where ' || row_record.member_table_name || '.' || row_record.member_col || '(+)=' ||
'b' || '.'||row_record.COLUMN_NAME || ' and  a.rowid = b.rowid ' || ') as col , ' ;


 ELSE

    l_queryString := ' CURSOR ( SELECT '''  || col_count ||  ''' as colNum, '||
    row_record.TABLE_NAME || '.' || ROW_RECORD.COLUMN_NAME || ' as colValue' || ' from ' || row_record.TABLE_NAME ||
    ' where ' ||  row_record.TABLE_NAME || '.' || 'ROWID' || ' = ' || 'a' || '.' || 'ROWID'
    || ' ) as col , ' ;

 END IF;
 --fnd_file.put_line(fnd_file.log,l_queryString);
 dbms_lob.writeappend(selectClause,LENGTH(l_queryString),l_queryString);
 dbms_lob.writeappend(l_metadata_xml,LENGTH(l_xmlString),l_xmlString);

END LOOP;

l_xmlString :=  ' </COL_DEFS>';
l_xmlString := l_xmlString || ' <BAL_COLS_PRESENT>' ||l_bal_cols_present||'</BAL_COLS_PRESENT> ';
dbms_lob.writeappend(l_metadata_xml,LENGTH(l_xmlString),l_xmlString);



dbms_lob.erase(selectClause,l_eraseamt,dbms_lob.getlength(selectClause)-2);

/**************************************************
Prepare the final query
**************************************************/


/**************************************************
Add Condition clause.
**************************************************/

--l_query := 'SELECT ' || selectclause || ' FROM ' || l_tablename || ' a';

l_queryString := 'SELECT ';
dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
--fnd_file.put_line(fnd_file.log,'After appending to l_query');
dbms_lob.append(l_query,selectClause);
l_queryString := ' FROM ' || l_tablename || ' a';
dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);

IF whereClause IS NOT NULL THEN
  --l_query := l_query ||' WHERE ' || whereClause;
  l_queryString := ' WHERE ';
  dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
  dbms_lob.append(l_query,whereClause);
END IF;




/**************************************************
Add Order by Clause
**************************************************/


FOR order_record in column_order_csr LOOP

 IF(l_order_by_added = 'N') THEN
  l_queryString := ' ORDER BY ';
  l_order_by_added := 'Y';
 END IF;

 l_order_col := order_record.COLUMN_NAME;
 l_sort_dir_flag := order_record.SORT_DIRECTION_FLAG;
 l_queryString := l_queryString || ' a.' || l_order_col;

 IF(l_sort_dir_flag = 'A') THEN
   l_queryString := l_queryString || ' ASC,';
 ELSE
   l_queryString := l_queryString || ' DESC,';
 END IF;

END LOOP;

IF(l_order_by_added = 'Y') THEN
 l_queryString := SUBSTR(l_queryString, 1, LENGTH(l_queryString) - 1);
 dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
END IF;

fnd_file.put_line(fnd_file.log, 'The final query : ');
--fnd_file.put_line(fnd_file.log,l_query);



/**************************************************
Get the xml.
**************************************************/
fnd_file.put_line(fnd_file.log,'************************************XML******************************************************');

queryCtx := DBMS_XMLQuery.newContext(l_query);
DBMS_XMLQuery.setRowsetTag(queryCtx, 'Extracted_Records');
DBMS_XMLQuery.setRowTag(queryCtx, 'Row');

l_xmlResult := DBMS_XMLQuery.getXML(queryCtx);
DBMS_XMLQuery.closeContext(queryCtx);

l_data_size := dbms_lob.getlength(l_xmlResult);
if l_data_size > 45 then
   l_data_present := 'Yes';
else
   l_data_present := 'No';
end if;

l_xmlString :=  ' <DATA_PRESENT>' || l_data_present || '</DATA_PRESENT>';
dbms_lob.writeappend(l_metadata_xml,LENGTH(l_xmlString),l_xmlString);


/**************************************************
Add result xml to metadata xml after removing the processing instruction.
metadata xml is your final clob.
**************************************************/
dbms_lob.erase(l_xmlResult,P_INSTN_AMT,1);
dbms_lob.write(l_xmlResult,P_INSTN_AMT,1,'<!-- PINSTN removed -->');
dbms_lob.append(l_metadata_xml,l_xmlResult);

--Close off. l_metadata_xml is your final clob.
l_xmlString :=  '</Root>';
dbms_lob.writeappend(l_metadata_xml,LENGTH(l_xmlString),l_xmlString);


l_clob_size := dbms_lob.getlength(l_metadata_xml);
l_offset     := 1;
l_chunk_size := 3000;

WHILE (l_clob_size > 0) LOOP

  l_chunk := dbms_lob.substr (l_metadata_xml, l_chunk_size, l_offset);
  --fnd_file.put_line(fnd_file.log,l_chunk);
  fnd_file.put(
    which => fnd_file.output,
    buff  => l_chunk);
  l_clob_size := l_clob_size - l_chunk_size;
  l_offset := l_offset + l_chunk_size;

END LOOP;

IF p_mode = 'ONLINE' THEN
  x_xml_result := l_metadata_xml;
END IF;

fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Generate_XML()',
                              p_msg_text => 'END');


dbms_lob.freetemporary(selectClause);
dbms_lob.freetemporary(l_query);
dbms_lob.freetemporary(l_metadata_xml);

EXCEPTION
 WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log,sqlerrm);
  fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                                p_module   => g_block||'.Generate_XML()',
                                p_msg_text => 'EXCEPTION BLOCK:'||sqlerrm);

END Generate_XML;




PROCEDURE Generate_Cust_XML_CP
(
 x_retcode OUT NOCOPY NUMBER,
 x_errbuff OUT NOCOPY VARCHAR2,
 p_diObjDefId IN NUMBER,
 p_diQuery IN VARCHAR2,
 p_view IN VARCHAR2
)
IS

x_xml_result CLOB;


BEGIN
Generate_Cust_XML(
  p_diObjDefId,
  p_diQuery,
  'OFFLINE',
  p_view,
  x_xml_result
 );

EXCEPTION

 WHEN OTHERS THEN
   x_retCode := 2;
   fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                                 p_module   => g_block||'.Generate_Cust_XML_CP()',
                                 p_msg_text => 'EXCEPTION BLOCK:'||sqlerrm);

END Generate_Cust_XML_CP;






PROCEDURE Generate_Cust_XML
(
 p_diObjDefId IN NUMBER,
 p_diQuery IN VARCHAR2,
 p_mode IN VARCHAR2,
 p_view IN VARCHAR2,
 x_xml_result OUT NOCOPY CLOB
)
IS

selectclause CLOB;
l_query CLOB;
fromclause CLOB;
--tablename CLOB;
l_metadata_xml CLOB;
l_test_xml CLOB;
l_test1_xml CLOB;
dim VARCHAR2(20);
l_xmlresult CLOB;
--queryCtx DBMS_XMLGEN.ctxHandle;
queryCtx DBMS_XMLquery.ctxType;
l_tablename VARCHAR2(50);
l_clob_size   NUMBER;
l_data_size   NUMBER;
l_offset      NUMBER;
l_chunk_size  INTEGER;
l_chunk       VARCHAR2(32767);
trashStr      VARCHAR2(32767);
sortseq       VARCHAR2(32767);
l_condition_Obj_id NUMBER;
l_condition_name VARCHAR2(100);
whereClause CLOB;
l_dataHeaderClob CLOB;
l_table_display_name VARCHAR2(255);
l_di_name VARCHAR2(255);
l_header varchar2(200);
l_data_present varchar2(4);
col_count NUMBER:=0;
P_INSTN_AMT INTEGER:=23;
l_eraseamt INTEGER:=3;
P_RT_AMT BINARY_INTEGER:=6;
l_bal_sum NUMBER;
l_bal_sum_query VARCHAR2(32767);
l_bal_cols_present varchar2(4):='No';
l_order_col VARCHAR2(30);
l_sort_dir_flag VARCHAR2(1);
l_order_by_added VARCHAR2(1):='N';
l_queryString VARCHAR2(32767);

CURSOR get_required_columns_cursor IS
SELECT DataInspectorColumnsEO.DATA_INSPECTOR_OBJ_DEF_ID,
       DataInspectorColumnsEO.TABLE_NAME,
       DataInspectorColumnsEO.COLUMN_NAME,
       DataInspectorColumnsEO.DISPLAY_SEQUENCE,
       EnabledTableColumnEO.DISPLAY_NAME,
       EnabledTableColumnEO.FEM_DATA_TYPE_CODE,
       EnabledTableColumnEO.DIMENSION_ID,
       DataInspectorColumnsEO.SORT_SEQUENCE,
       DataInspectorColumnsEO.SORT_DIRECTION_FLAG,
       (select member_name_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_name_col,
(select member_display_code_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_code_col,
(select member_vl_object_name from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
member_table_name,
(select dimension_varchar_label from fem_dimensions_b where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS
dimension_varchar_label,
(select dimension_name from fem_dimensions_vl where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS dimension_name,
(select member_col from fem_xdim_dimensions where dimension_id = EnabledTableColumnEO.DIMENSION_ID) AS member_col
FROM   FEM_DATA_INSPECTOR_COLS DataInspectorColumnsEO,
       FEM_TAB_COLUMNS_V EnabledTableColumnEO
WHERE  EnabledTableColumnEO.TABLE_NAME = DataInspectorColumnsEO.TABLE_NAME
AND    EnabledTableColumnEO.COLUMN_NAME = DataInspectorColumnsEO.COLUMN_NAME
AND    DataInspectorColumnsEO.DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId
ORDER BY DataInspectorColumnsEO.DISPLAY_SEQUENCE ASC;

CURSOR get_table_name_csr IS
SELECT TABLE_NAME FROM FEM_DATA_INSPECTORS WHERE DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId;

CURSOR get_condition_Obj_id_cursor IS
SELECT FEM_DATA_INSPECTORS.CONDITION_OBJ_ID, FEM_OBJECT_CATALOG_VL.OBJECT_NAME  FROM    FEM_DATA_INSPECTORS, FEM_OBJECT_CATALOG_VL
   WHERE FEM_DATA_INSPECTORS.DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId AND
        FEM_OBJECT_CATALOG_VL.OBJECT_ID = FEM_DATA_INSPECTORS.CONDITION_OBJ_ID;


CURSOR column_order_csr IS
SELECT COLUMN_NAME,
       SORT_SEQUENCE,
       SORT_DIRECTION_FLAG
FROM   FEM_DATA_INSPECTOR_COLS
WHERE  DATA_INSPECTOR_OBJ_DEF_ID = p_diObjDefId
AND    SORT_SEQUENCE IS NOT NULL
ORDER BY SORT_SEQUENCE ASC;


BEGIN

fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Generate_Cust_XML()',
                              p_msg_text => 'BEGIN');


dim := 'DIMENSION';
fnd_file.put_line(fnd_file.log, 'DI Object Def Id:' || to_char(p_diObjDefId));
fnd_file.put_line(fnd_file.log, 'View:'||p_view);

/*****************************************************************
Get the Table name
*****************************************************************/

OPEN get_table_name_csr;
FETCH get_table_name_csr INTO l_tableName;
CLOSE get_table_name_csr;

IF p_diQuery IS NULL THEN

  /*****************************************************************
  Get the condition details.
  *****************************************************************/

  OPEN get_condition_obj_id_cursor;
  FETCH get_condition_obj_id_cursor INTO l_condition_obj_id,l_condition_name ;
  CLOSE get_condition_obj_id_cursor;

  /*****************************************************************
  Get the Condition predicate.
  *****************************************************************/

  IF l_condition_obj_id IS NOT NULL THEN
     getConditionPredicate(l_condition_obj_id,l_tableName,whereClause);
  END IF;

  fnd_file.put_line(fnd_file.log,'Condition predicate is:' || whereClause);

  dbms_lob.createtemporary(selectClause,TRUE);
  dbms_lob.createtemporary(l_query,TRUE);
  l_queryString :=  'SELECT ';
  dbms_lob.writeappend(selectClause,LENGTH(l_queryString),l_queryString);

  FOR row_record in get_required_columns_cursor LOOP

   --Bug#6174477: Change the query as per view option
   IF (row_record.FEM_DATA_TYPE_CODE = dim AND (p_view = 'Name')) THEN
       l_queryString :=  ' ( SELECT ' ||
       row_record.member_table_name || '.' || row_record.member_name_col ||' from ' ||
       row_record.member_table_name || ', ' || l_tablename ||' b ' ||' where ' || row_record.member_table_name || '.' || row_record.member_col || '(+)=' ||
       'b' || '.'||row_record.COLUMN_NAME || ' and  a.rowid = b.rowid ' || ') as ' || row_record.member_name_col || ' , ';

   ELSIF (row_record.FEM_DATA_TYPE_CODE = dim AND (p_view = 'Code')) THEN
       l_queryString :=  ' ( SELECT ' ||
       row_record.member_table_name || '.' || row_record.member_code_col ||' from ' ||
       row_record.member_table_name || ', ' || l_tablename ||' b ' ||' where ' || row_record.member_table_name || '.' || row_record.member_col || '(+)=' ||
       'b' || '.'||row_record.COLUMN_NAME || ' and  a.rowid = b.rowid ' || ') as ' || row_record.member_code_col || ' , ';

   ELSE
      l_queryString :=  row_record.COLUMN_NAME || ' , ';

   END IF;

      dbms_lob.writeappend(selectClause,LENGTH(l_queryString),l_queryString);

  END LOOP;

  dbms_lob.erase(selectClause,l_eraseamt,dbms_lob.getlength(selectClause)-2);

  /** Prepare the final Query**/

    dbms_lob.append(l_query,selectClause);
    l_queryString := ' FROM ' || l_tablename || ' a';
    dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
  /**************************************************
            Add Condition clause.
  **************************************************/

   IF whereClause IS NOT NULL THEN
       l_queryString := ' WHERE ';
       dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
       dbms_lob.append(l_query,whereClause);
   END IF;

  /**************************************************
            Add Order by Clause
   **************************************************/


   FOR order_record in column_order_csr LOOP

    IF(l_order_by_added = 'N') THEN
      l_queryString := ' ORDER BY ';
      l_order_by_added := 'Y';
    END IF;

    l_order_col := order_record.COLUMN_NAME;
    l_sort_dir_flag := order_record.SORT_DIRECTION_FLAG;
    l_queryString := l_queryString || ' a.' || l_order_col;

    IF(l_sort_dir_flag = 'A') THEN
     l_queryString := l_queryString || ' ASC,';
    ELSE
     l_queryString := l_queryString || ' DESC,';
    END IF;

  END LOOP;

  IF(l_order_by_added = 'Y') THEN
   l_queryString := SUBSTR(l_queryString, 1, LENGTH(l_queryString) - 1);
   dbms_lob.writeappend(l_query,LENGTH(l_queryString),l_queryString);
  END IF;

ELSE

  l_query := p_diQuery;

END IF;

fnd_file.put_line(fnd_file.log, 'Final query:');
--fnd_file.put_line(fnd_file.log,l_query);

/**************************************************
Get the xml.
**************************************************/
fnd_file.put_line(fnd_file.log,'************************************XML******************************************************');

queryCtx := DBMS_XMLQuery.newContext(l_query);
DBMS_XMLQuery.setRowsetTag(queryCtx, 'Extracted_Records');
DBMS_XMLQuery.setRowTag(queryCtx, 'Row');

l_xmlResult := DBMS_XMLQuery.getXML(queryCtx);
DBMS_XMLQuery.closeContext(queryCtx);

l_clob_size := dbms_lob.getlength(l_xmlResult);
l_offset     := 1;
l_chunk_size := 3000;

WHILE (l_clob_size > 0) LOOP

  l_chunk := dbms_lob.substr (l_xmlResult, l_chunk_size, l_offset);
  --fnd_file.put_line(fnd_file.log,l_chunk);
  fnd_file.put(
    which => fnd_file.output,
    buff  => l_chunk);
  l_clob_size := l_clob_size - l_chunk_size;
  l_offset := l_offset + l_chunk_size;

END LOOP;

IF p_mode = 'ONLINE' THEN
  x_xml_result := l_xmlResult;
END IF;


fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Generate_Cust_XML()',
                              p_msg_text => 'END');
dbms_lob.freetemporary(selectClause);
dbms_lob.freetemporary(l_query);


EXCEPTION
 WHEN OTHERS THEN
fnd_file.put_line(fnd_file.log,sqlerrm);
fem_engines_pkg.tech_message (p_severity => g_log_level_1,
                              p_module   => g_block||'.Generate_Cust_XML()',
                              p_msg_text => 'EXCEPTION BLOCK:'||sqlerrm);


END Generate_Cust_XML;













/********************************
getConditionPredicate

********************************/



PROCEDURE getConditionPredicate(
p_condObjId IN NUMBER,
p_tableName IN VARCHAR2,
p_whereClause OUT NOCOPY CLOB)
IS

--G_DEFAULT_EFFECTIVE_DATE_NULL     constant date := FND_DATE.Canonical_To_Date('2500/01/01');
messageData VARCHAR2(32767);
effDateStr DATE;
returnStatus VARCHAR2(1000);
messageCount NUMBER;
effDateString VARCHAR2(32);
l_date_string VARCHAR2(32767);
l_date_value varchar2(30);

BEGIN
effDateString := 'FEM_EFFECTIVE_DATE';

l_date_string := FND_PROFILE.value(effDateString);

if (l_date_string is not null) then
  --l_date_value := FND_DATE.Canonical_To_Date(l_date_string);
    -- Remove the time component.
    --l_date_value := FND_DATE.date_to_canonical(trunc(l_date_value));
l_date_value := l_date_string;

end if;

FEM_CONDITIONS_API.GENERATE_CONDITION_PREDICATE(
p_condition_obj_id => p_condObjId,
         p_rule_effective_date => l_date_value,
         p_input_fact_table_name => p_tableName,
         p_table_alias => NULL,
         p_display_predicate => 'N',
         p_return_predicate_type => 'BOTH',
         p_logging_turned_on  =>'Y' ,
         x_return_status  => returnStatus,
         x_msg_count => messageCount,
         x_msg_data => messageData,
         x_predicate_string => p_whereClause);

END getConditionPredicate;

END FEM_TABLE_PUBLISH_PKG;

/
