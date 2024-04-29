--------------------------------------------------------
--  DDL for Package Body FEM_DATA_TEMPLATE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DATA_TEMPLATE_UTIL_PKG" AS
/* $Header: fem_intg_dtmanip.plb 120.0 2008/01/10 12:40:00 hakumar noship $ */
g_api varchar2(50) := 'fem.plsql.fem_data_template_util_pkg';
g_nl  varchar2(1) := '
';

--
-- Procedure
--   REPLACE_DT_PROC
-- Purpose
--   Data Template Replacement Procedure.
-- Arguments
--   * None *
-- Example
--   fem_data_template_util_pkg.replace_dt_proc;
-- Notes
--
PROCEDURE replace_dt_proc( x_errbuf  OUT NOCOPY VARCHAR2,
                           x_retcode OUT NOCOPY VARCHAR2
                         )
IS
  TYPE r_fem_datatemplates IS RECORD( template_code          VARCHAR2(150),
                                      template_data          BLOB
                                     );

  TYPE t_fem_datatemplates	IS TABLE OF r_fem_datatemplates;
  l_fem_base_datatemplates t_fem_datatemplates;
  l_fem_datatemplates t_fem_datatemplates;

  l_select_list_fem     VARCHAR2(10000);
  l_from_list_fem       VARCHAR2(10000);
  l_where_clause_fem    VARCHAR2(10000);
  l_element_list_fem    VARCHAR2(10000);
  l_vsmp_xml_elem       VARCHAR2(10000);
  l_remaining_str       VARCHAR2(100);
  l_base_templatecode   VARCHAR2(50);
  l_varchar             VARCHAR2(32767);
  l_start	              INTEGER := 1;
  l_buffer              INTEGER :=32767;
  l_off_write           INTEGER := 1;
  l_amt_write           INTEGER := 32767;
  l_start_tag           NUMBER;
  l_end_tag             NUMBER;
  l_sub_string          VARCHAR2(32767);
  l_start_tag_length    NUMBER;
  l_blob_in             BLOB;
  l_blob_out            BLOB;
  l_clob                CLOB;

  CURSOR c_base_data_templates
  IS
          SELECT lob_code,
                 file_data
            FROM xdo_lobs
           WHERE application_short_name = 'FEM'
             AND lob_type               = 'DATA_TEMPLATE'
             AND lob_code               = 'FEM_GL_WRTBK_ERROR_SOURCE_BASE';
  CURSOR c_active_dims
  IS
SELECT ftcb.column_name,
       SUBSTR(ftcb.column_name, 1, INSTR(ftcb.column_name, '_ID')) || 'NAME' dimension_name,
       ftcb.display_name,
       DECODE(ftcb.column_name, 'CHANNEL_ID', 'fem_channels_tl',
                                'COMPANY_COST_CENTER_ORG_ID', 'fem_cctr_orgs_tl',
                                'CUSTOMER_ID', 'fem_customers_tl',
                                'FINANCIAL_ELEM_ID', 'fem_fin_elems_tl',
                                'INTERCOMPANY_ID', 'fem_cctr_orgs_tl',
                                'LINE_ITEM_ID', 'fem_ln_items_tl',
                                'NATURAL_ACCOUNT_ID', 'fem_nat_accts_tl',
                                'PRODUCT_ID', 'fem_products_tl',
                                'PROJECT_ID', 'fem_projects_tl',
                                'TASK_ID', 'fem_tasks_tl',
                                'USER_DIM10_ID', 'fem_user_dim10_tl',
                                'USER_DIM1_ID', 'fem_user_dim1_tl',
                                'USER_DIM2_ID', 'fem_user_dim2_tl',
                                'USER_DIM3_ID', 'fem_user_dim3_tl',
                                'USER_DIM4_ID', 'fem_user_dim4_tl',
                                'USER_DIM5_ID', 'fem_user_dim5_tl',
                                'USER_DIM6_ID', 'fem_user_dim6_tl',
                                'USER_DIM7_ID', 'fem_user_dim7_tl',
                                'USER_DIM8_ID', 'fem_user_dim8_tl',
                                'USER_DIM9_ID', 'fem_user_dim9_tl' ) table_name,
       DECODE(ftcb.column_name, 'CHANNEL_ID', 'fcht',
                                'COMPANY_COST_CENTER_ORG_ID', 'fcot',
                                'CUSTOMER_ID', 'fcut',
                                'FINANCIAL_ELEM_ID', 'ffet',
                                'INTERCOMPANY_ID', 'fcit',
                                'LINE_ITEM_ID', 'flit',
                                'NATURAL_ACCOUNT_ID', 'fnat',
                                'PRODUCT_ID', 'fpt',
                                'PROJECT_ID', 'fpjt',
                                'TASK_ID', 'ftt',
                                'USER_DIM10_ID', 'fu10t',
                                'USER_DIM1_ID', 'fu1t',
                                'USER_DIM2_ID', 'fu2t',
                                'USER_DIM3_ID', 'fu3t',
                                'USER_DIM4_ID', 'fu4t',
                                'USER_DIM5_ID', 'fu5t',
                                'USER_DIM6_ID', 'fu6t',
                                'USER_DIM7_ID', 'fu7t',
                                'USER_DIM8_ID', 'fu8t',
                                'USER_DIM9_ID', 'fu9t' ) table_alias,
       DECODE(ftcb.column_name, 'COMPANY_COST_CENTER_ORG_ID', 1,
              'LINE_ITEM_ID', 2,
              'USER_DIM10_ID', 4,
              'INTERCOMPANY_ID', 5, 3) column_order
  FROM fem_tab_columns_tl ftcb,
       fem_tab_column_prop ftcp
 WHERE ftcb.table_name           = 'FEM_BALANCES'
   AND ftcb.table_name           = ftcp.table_name
   AND ftcb.language             = userenv('LANG')
   AND ftcb.column_name          = ftcp.column_name
   AND ftcp.column_property_code = 'PROCESSING_KEY'
   AND ftcb.column_name IN ('CHANNEL_ID',
                            'COMPANY_COST_CENTER_ORG_ID',
                            'CUSTOMER_ID',
                            'FINANCIAL_ELEM_ID',
                            'INTERCOMPANY_ID',
                            'LINE_ITEM_ID',
                            'NATURAL_ACCOUNT_ID',
                            'PRODUCT_ID',
                            'PROJECT_ID',
                            'TASK_ID',
                            'USER_DIM10_ID',
                            'USER_DIM1_ID',
                            'USER_DIM2_ID',
                            'USER_DIM3_ID',
                            'USER_DIM4_ID',
                            'USER_DIM5_ID',
                            'USER_DIM6_ID',
                            'USER_DIM7_ID',
                            'USER_DIM8_ID',
                            'USER_DIM9_ID')
 ORDER BY 6, 1;

BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', '<<begin>>');
   END IF;

   -- Construct The FEM Active Dims Select/Table/Where List For Manipulation Use
   FOR v_active_dims IN c_active_dims LOOP
     -- Select list
     IF (v_active_dims.column_name = 'INTERCOMPANY_ID') THEN
       l_select_list_fem :=  l_select_list_fem || v_active_dims.table_alias || '.' || 'COMPANY_COST_CENTER_ORG_NAME ' || v_active_dims.dimension_name ||','||g_nl;
     ELSE
       l_select_list_fem :=  l_select_list_fem || v_active_dims.table_alias || '.' || v_active_dims.dimension_name ||','||g_nl;
     END IF;

     -- From clause
     l_from_list_fem :=  l_from_list_fem || v_active_dims.table_name || ' ' || v_active_dims.table_alias ||','||g_nl;

     -- Where clause
     IF (v_active_dims.column_name = 'INTERCOMPANY_ID') THEN
       l_where_clause_fem := l_where_clause_fem || ' AND gt.' || v_active_dims.column_name || '=' || v_active_dims.table_alias || '.COMPANY_COST_CENTER_ORG_ID'  ||g_nl
                             || ' AND ' || v_active_dims.table_alias || '.' || 'language = userenv(''LANG'')' || g_nl;
     ELSE
       l_where_clause_fem := l_where_clause_fem || ' AND gt.' || v_active_dims.column_name || '=' || v_active_dims.table_alias || '.' || v_active_dims.column_name ||g_nl
                             || ' AND ' || v_active_dims.table_alias || '.' || 'language = userenv(''LANG'')' || g_nl;
     END IF;

     -- XML structure elements
     l_element_list_fem := l_element_list_fem || '<element name="NAME" value="'||v_active_dims.dimension_name||'"/>'||g_nl;

     IF ( v_active_dims.column_name <> 'FINANCIAL_ELEM_ID' AND
          v_active_dims.column_name <> 'INTERCOMPANY_ID') THEN
       l_vsmp_xml_elem := l_vsmp_xml_elem ||
       '<group name="HEADER" source="S_'||v_active_dims.column_name||'">'||g_nl||
       ' <element name="DIMENSIONNAME" value="DIMENSION_NAME"/>'|| g_nl||
       ' <element name="VALUESETNAME" value="VALUE_SET_NAME"/>'|| g_nl||
       ' <group name="DETAILS" source="S_'||v_active_dims.column_name||'">'|| g_nl||
       '  <element name="NAME" value="DIM_MEMBER_NAME"/>'|| g_nl||
       '  <element name="DESCRIPTION" value="DESCRIPTION" />'|| g_nl||
       ' </group>'|| g_nl||
       '</group>'||g_nl;
     END IF;

   END LOOP;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_select_list_fem : '||l_select_list_fem);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_element_list_fem : '||l_element_list_fem);
   END IF;

   --Open DT Cursor And Loop Through Each Of The Templates
   --And Carry Out Specific Manipulations
   OPEN c_base_data_templates;
   FETCH c_base_data_templates BULK COLLECT INTO l_fem_base_datatemplates;

   -- Check if there's atleast one record to process
   IF (l_fem_base_datatemplates.FIRST IS NOT NULL AND l_fem_base_datatemplates.LAST IS NOT NULL) THEN

     -- Loop through each DT and manipulate it as required
     FOR l_index IN l_fem_base_datatemplates.FIRST .. l_fem_base_datatemplates.LAST LOOP

       l_base_templatecode := l_fem_base_datatemplates(l_index).template_code ;
       l_blob_in := l_fem_base_datatemplates(l_index).template_data ;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'DT manipulation loop for : ');
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_base_templatecode : '||l_base_templatecode);
       END IF;

           -- Reset all the offset positions
           l_start := 1;
           l_buffer := 32767;
           l_off_write := 1;
           l_amt_write := 32767;

           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Convert base DT blob to clob.');
           END IF;

           -- Create a temporary clob to hold manipulated contents
           DBMS_LOB.CREATETEMPORARY(l_clob, TRUE);

           FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(l_blob_in) / l_buffer) LOOP

             l_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(l_blob_in, l_buffer, l_start));
             DBMS_LOB.WRITEAPPEND(l_clob, LENGTH(l_varchar), l_varchar);
             l_start := l_start + l_buffer;

             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_varchar : '||l_varchar);
             END IF;

           END LOOP;

           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Converted base DT blob to clob and now pointing to target DT blob for manipulation.');
           END IF;

           -- Got the clob out of the base DT blob
           -- manipulate this clob as needed
           IF(l_base_templatecode = 'FEM_GL_WRTBK_ERROR_SOURCE_BASE') THEN

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'DT manipulation: '||l_base_templatecode);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startSelectList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endSelectList*/', 1, 1);
               l_start_tag_length := length('/*startSelectList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_select_list_fem);

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Select List literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startFromList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endFromList*/', 1, 1);
               l_start_tag_length := length('/*startFromList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_from_list_fem);

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'From List literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startWhereClause*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endWhereClause*/', 1, 1);
               l_start_tag_length := length('/*startWhereClause*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_where_clause_fem);

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Where Clause literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startElements-->', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '<!--endElements-->', 1, 1);
               l_start_tag_length := length('<!--startElements-->');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_element_list_fem);

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'XML SCHEMA ELEMENT (DIMENSION NAME COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startVSElements-->', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '<!--endVSElements-->', 1, 1);
               l_start_tag_length := length('<!--startVSElements-->');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_vsmp_xml_elem);

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'XML SCHEMA ELEMENT (DIMENSION NAME COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

           END IF;

           -- Finally write back temporary clob to destination blob
           l_start:=1;
           l_off_write:=1;
           DBMS_LOB.createtemporary(l_blob_out,TRUE);

           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Write back manipulated clob to target blob.');
           END IF;

           FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(l_clob) / l_buffer) LOOP

               DBMS_LOB.read ( l_clob, l_buffer, l_start, l_varchar );
               l_amt_write := utl_raw.length (utl_raw.cast_to_raw( l_varchar) );
               DBMS_LOB.write( l_blob_out, l_amt_write, l_off_write, utl_raw.cast_to_raw( l_varchar ) );
               l_off_write := l_off_write + l_amt_write;
               l_start := l_start + l_buffer;

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_start : '||l_start);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_buffer : '||l_buffer);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_amt_write : '||l_amt_write);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_off_write : '||l_off_write);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'l_varchar : '||l_varchar);
               END IF;

           END LOOP;

           UPDATE xdo_lobs
              SET file_data = l_blob_out
            WHERE application_short_name = 'FEM'
              AND lob_type = 'DATA_TEMPLATE'
              AND lob_code = SUBSTR(l_base_templatecode, 1, INSTR(l_base_templatecode,'_BASE')-1);

           DBMS_LOB.freetemporary(l_blob_out);
           DBMS_LOB.freetemporary(l_clob);

           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', 'Manipulated clob written back to target blob.');
           END IF;

     END LOOP; -- Loop for template cursor

   END IF;

   CLOSE c_base_data_templates;
   COMMIT;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_dt_proc', '<<end>>');
   END IF;

   EXCEPTION
          WHEN OTHERS THEN
          BEGIN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_ERROR) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_api || '.' || 'replace_dt_proc', substr(SQLERRM,1,255));
               END IF;
          END;

END replace_dt_proc;

END FEM_DATA_TEMPLATE_UTIL_PKG;

/
