--------------------------------------------------------
--  DDL for Package Body GCS_DATA_TEMPLATE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DATA_TEMPLATE_UTIL_PKG" AS
/* $Header: gcsdtmanipb.pls 120.17 2007/02/27 14:46:06 sangarg ship $ */

g_api varchar2(50) := 'gcs.plsql.GCS_DATA_TEMPLATE_UTIL_PKG';

-- PRIVATE PROCEDURE
-- Used by value set map template manipulation
PROCEDURE replace_clob ( p_src_clob        IN OUT NOCOPY CLOB,
                         p_replace_with    IN VARCHAR2,
                         p_first_Offset    IN INTEGER,
                         p_second_variable IN VARCHAR2
                       )
IS

 l_buffer     INTEGER := 30000;
 l_vs_map_clob      CLOB := EMPTY_CLOB;
 l_varchar    VARCHAR2(32767);
 l_start      NUMBER;
 l_read_length NUMBER;

BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', '<<begin>>');
   END IF;

   DBMS_LOB.createtemporary(l_vs_map_clob,TRUE);
   l_start:=1;
   l_read_length := LENGTH( DBMS_LOB.SUBSTR(p_src_clob, l_buffer, l_start));
   -- WRITE THE FIRST PART OF THE CLOB
   FOR i IN 1..CEIL(p_first_Offset/l_read_length) LOOP

      IF(l_start+l_read_length > p_first_Offset) THEN
         l_buffer := p_first_Offset-l_start;
      END IF;

      l_varchar := DBMS_LOB.SUBSTR(p_src_clob, l_buffer, l_start);
      DBMS_LOB.WRITEAPPEND(l_vs_map_clob, LENGTH(l_varchar), l_varchar);
      l_start := l_start + LENGTH(l_varchar);

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', 'l_start : '||l_start);
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', 'l_read_length : '||l_read_length);
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', 'p_first_Offset : '||p_first_Offset);
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', 'l_buffer : '||l_buffer);
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', 'l_varchar : '||l_varchar);
      END IF;

   END LOOP;

   -- WRITE THE REPLACEMENT
   DBMS_LOB.writeappend(l_vs_map_clob, length(p_replace_with), p_replace_with);
   DBMS_LOB.writeappend(l_vs_map_clob, LENGTH(p_second_variable), p_second_variable);
   p_src_clob:=l_vs_map_clob;
   DBMS_LOB.freetemporary(l_vs_map_clob);

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'replace_clob', '<<end>>');
   END IF;

   EXCEPTION
        WHEN OTHERS THEN
        BEGIN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_ERROR) THEN
                  FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_api || '.' || 'replace_clob', substr(SQLERRM,1,255));
           END IF;
        END;
END replace_clob;

--
-- Procedure
--   GCS_REPLACE_DT_PROC
-- Purpose
--   Data Template Replacement Procedure.
-- Arguments
--   * None *
-- Example
--   GCS_DATA_TEMPLATE_UTIL_PKG.GCS_REPLACE_DT_PROC;
-- Notes
--
PROCEDURE gcs_replace_dt_proc( x_errbuf  OUT NOCOPY VARCHAR2,
                               x_retcode OUT NOCOPY VARCHAR2
                              )
IS

  TYPE r_gcs_datatemplates IS RECORD
                                (
                                  template_code          VARCHAR2(150),
                                  template_data          BLOB
                                 );

  TYPE t_gcs_datatemplates	IS TABLE OF r_gcs_datatemplates;

  l_gcs_base_datatemplates t_gcs_datatemplates;
  l_gcs_datatemplates t_gcs_datatemplates;

  l_select_list_gcs     VARCHAR2(10000);
  l_select_list_dstb    VARCHAR2(10000);
  l_select_list_dsload  VARCHAR2(10000);
  l_gl_posted_select_list VARCHAR2(10000);

  l_table_list_gcs      VARCHAR2(10000);
  l_table_list_dstb     VARCHAR2(10000);
  --fix 5351083
  --l_table_list_dsload   VARCHAR2(10000);

  l_where_list_gcs      VARCHAR2(10000);
  --fix 5351083
  --l_where_list_dsload   VARCHAR2(10000);
  l_where_list_dstb     VARCHAR2(10000);
  --fix 5351083
  --l_group_by_list       VARCHAR2(10000);
  l_dstb_group_by_list  VARCHAR2(10000);
  l_gl_posted_group_list VARCHAR2(10000);

  l_element_list_gcs    VARCHAR2(10000);
  l_element_list_dsload VARCHAR2(10000);
  --fix 5351083
  --l_element_list_dstb   VARCHAR2(10000);

  l_orderby_list_gcs    VARCHAR2(10000);
  l_orderby_list_dsload VARCHAR2(10000);
  l_orderby_list_dstb   VARCHAR2(10000);

  l_vs_group_list       VARCHAR2(32767);
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
           WHERE application_short_name = 'GCS'
             AND lob_type = 'DATA_TEMPLATE'
             AND lob_code IN ('GCS_DS_LOAD_SOURCE_BASE',
                              'GCS_DS_TB_SOURCE_BASE',
                              'GCS_AD_TB_SOURCE_BASE',
                              'GCS_ENTRY_SOURCE_BASE',
                              'GCS_VS_MAP_SOURCE_BASE',
                              'GCS_INTER_COMP_SOURCE_BASE',
                              'GCS_DS_IMPACTED_BAL_SOURCE_BASE',
                              --Bugfix: 5861665
                              'GCS_CONS_INTER_COMP_SOURCE_BASE')
             AND EXISTS (SELECT 1 FROM gcs_system_options);

BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', '<<begin>>');
   END IF;

   -- JOB 1 : CONSTRUCT THE GCS/FEM ACTIVE DIMS SELECT/TABLE/WHERE/ORDER/GROUP LIST FOR MANIPULATION USE
   -- select lists
   l_select_list_gcs :=  gcs_xml_utility_pkg.g_gcs_dims_select_list;
   l_select_list_dstb :=  gcs_xml_utility_pkg.g_fem_dims_select_list_dstb;
   l_select_list_dsload :=  gcs_xml_utility_pkg.g_fem_dims_select_list_dsload;
   l_gl_posted_select_list := gcs_xml_utility_pkg.g_fem_nonposted_select_stmnt;

   -- table lists
   l_table_list_gcs  :=  gcs_xml_utility_pkg.g_gcs_dims_table_list;
   l_table_list_dstb  :=  gcs_xml_utility_pkg.g_fem_dims_table_list_dstb;
   --fix 5351083
   --l_table_list_dsload  :=  gcs_xml_utility_pkg.g_fem_dims_table_list_dsload;
   -- where lists
   l_where_list_gcs  :=  gcs_xml_utility_pkg.g_gcs_dims_where_clause;
   --fix 5351083
   --l_where_list_dsload := gcs_xml_utility_pkg.g_fem_dims_dsload_where_clause;
   l_where_list_dstb :=gcs_xml_utility_pkg.g_fem_dims_dstb_where_clause;
   -- group by lists
   --fix 5351083
   --l_group_by_list := gcs_xml_utility_pkg.g_group_by_stmnt;
   l_dstb_group_by_list := gcs_xml_utility_pkg.g_group_by_stmnt;
   l_gl_posted_group_list := gcs_xml_utility_pkg.g_fem_nonposted_group_stmnt;
   -- element list
   l_element_list_gcs := gcs_xml_utility_pkg.g_gcs_dims_xml_elem;
   l_element_list_dsload := gcs_xml_utility_pkg.g_fem_dims_xml_elem;
   --fix 5351083
   --l_element_list_dstb := gcs_xml_utility_pkg.p_element_list_dstb;
   -- order by list
   l_orderby_list_gcs := gcs_xml_utility_pkg.g_gcs_dims_select_list;
   --Santosh -- bug 5234796
   l_orderby_list_dsload := gcs_xml_utility_pkg.g_fem_dims_dsload_order_clause;
   l_orderby_list_dstb := gcs_xml_utility_pkg.g_fem_dims_select_list_dstb;
   -- special list for vs map
   l_vs_group_list := gcs_xml_utility_pkg.g_gcs_vsmp_xml_elem;

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_select_list_gcs : '||l_select_list_gcs);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_select_list_dstb : '||l_select_list_dstb);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_select_list_dsload : '||l_select_list_dsload);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_gl_posted_select_list : '||l_gl_posted_select_list);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_table_list_gcs : '||l_table_list_gcs);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_table_list_dstb : '||l_table_list_dstb);
       --FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_table_list_dsload : '||l_table_list_dsload);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_where_list_gcs : '||l_where_list_gcs);
       --FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_where_list_dsload : '||l_where_list_dsload);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_where_list_dstb : '||l_where_list_dstb);
       --FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_group_by_list : '||l_group_by_list);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_dstb_group_by_list : '||l_dstb_group_by_list);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_gl_posted_group_list : '||l_gl_posted_group_list);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_element_list_gcs : '||l_element_list_gcs);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_element_list_dsload : '||l_element_list_dsload);
       --FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_element_list_dstb : '||l_element_list_dstb);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_orderby_list_gcs : '||l_orderby_list_gcs);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_orderby_list_dsload : '||l_orderby_list_dsload);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_orderby_list_dstb : '||l_orderby_list_dstb);
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_vs_group_list : '||l_vs_group_list);
   END IF;

   -- JOB 2 : OPEN CURSORS AND LOOP THROUGH EACH OF THE TEMPLATES
   -- AND CARRY OUT REPORT-SPECIFIC MANIPULATIONS TO THEM
   OPEN c_base_data_templates;
   FETCH c_base_data_templates BULK COLLECT INTO l_gcs_base_datatemplates;

   -- Check if there's atleast one record to process
   IF (l_gcs_base_datatemplates.FIRST IS NOT NULL AND l_gcs_base_datatemplates.LAST IS NOT NULL) THEN

     -- Loop through each dt one by one and manipulate it as required
     FOR l_index IN l_gcs_base_datatemplates.FIRST .. l_gcs_base_datatemplates.LAST LOOP

       l_base_templatecode := l_gcs_base_datatemplates(l_index).template_code ;
       l_blob_in := l_gcs_base_datatemplates(l_index).template_data ;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'DT manipulation loop for : ');
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_base_templatecode : '||l_base_templatecode);
       END IF;

           -- Reset all the offsets
           l_start := 1;
           l_buffer := 32767;
           l_off_write := 1;
           l_amt_write := 32767;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'Convert base DT blob to clob.');
           END IF;
           -- Create a temporary clob to hold manipulated contents
           DBMS_LOB.CREATETEMPORARY(l_clob, TRUE);
           FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(l_blob_in) / l_buffer) LOOP
             l_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(l_blob_in, l_buffer, l_start));
             DBMS_LOB.WRITEAPPEND(l_clob, LENGTH(l_varchar), l_varchar);
             l_start := l_start + l_buffer;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_varchar : '||l_varchar);
             END IF;
           END LOOP;

           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'Converted base DT blob to clob and now pointing to target DT blob for manipulation.');
           END IF;

           -- Got the clob out of the base dt blob
           -- manipulate this clob as needed
           -- Bugfix: 5861665
           IF(l_base_templatecode = 'GCS_ENTRY_SOURCE_BASE'
              OR l_base_templatecode = 'GCS_AD_TB_SOURCE_BASE'
              OR l_base_templatecode = 'GCS_INTER_COMP_SOURCE_BASE'
              OR l_base_templatecode = 'GCS_CONS_INTER_COMP_SOURCE_BASE') THEN

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'DT manipulation: '||l_base_templatecode);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startSelectList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endSelectList*/', 1, 1);
               l_start_tag_length := length('/*startSelectList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_select_list_gcs);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'SELECT literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startFromList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endFromList*/', 1, 1);
               l_start_tag_length := length('/*startFromList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_table_list_gcs);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'FROM literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startWhereClause*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endWhereClause*/', 1, 1);
               l_start_tag_length := length('/*startWhereClause*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_where_list_gcs);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'WHERE literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startOrderClause*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endOrderClause*/', 1, 1);
               l_start_tag_length := length('/*startOrderClause*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob :=replace(l_clob,l_sub_string, l_orderby_list_gcs);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'ORDER literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startElements-->', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '<!--endElements-->', 1, 1);
               l_start_tag_length := length('<!--startElements-->');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_element_list_gcs);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'XML SCHEMA ELEMENT literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

           ELSIF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE' OR l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE'
                 OR l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'DT manipulation: '||l_base_templatecode);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startSelectList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endSelectList*/', 1, 1);
               l_start_tag_length := length('/*startSelectList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               IF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_select_list_dsload);
               ELSIF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_select_list_dstb);
               ELSIF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_select_list_dstb);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'SELECT (DIMENSION NAME COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startSelectIdList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endSelectIdList*/', 1, 1);
               l_start_tag_length := length('/*startSelectIdList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);

               IF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_gl_posted_select_list);
               --fix 5351083
               --ELSE
               --   l_clob := replace(l_clob,l_sub_string, l_group_by_list);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'SELECT (DIMENSION ID COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startFromList*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endFromList*/', 1, 1);
               l_start_tag_length := length('/*startFromList*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               --fix 5351083
               --IF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE') THEN
                 --l_clob := replace(l_clob,l_sub_string, l_table_list_dsload);
               --ELSIF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
               IF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
                 l_clob := replace(l_clob,l_sub_string, l_table_list_dstb);
               ELSIF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                 l_clob := replace(l_clob,l_sub_string, l_table_list_dstb);
		           END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'FROM literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startWhereClause*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endWhereClause*/', 1, 1);
               l_start_tag_length := length('/*startWhereClause*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               --fix 5351083
               --IF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE') THEN
               --  l_clob := replace(l_clob,l_sub_string, l_where_list_dsload);
               --ELSIF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
               IF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
                 l_clob := replace(l_clob,l_sub_string, l_where_list_dstb);
               ELSIF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                 l_clob := replace(l_clob,l_sub_string, l_where_list_dstb);
	             END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'WHERE literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startDSTBGroupbyName*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endDSTBGroupbyName*/', 1, 1);
               l_start_tag_length := length('/*startDSTBGroupbyName*/');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               --fix 5351083
               --IF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE') THEN
                 -- l_clob := replace(l_clob,l_sub_string, l_select_list_dsload);
               --ELSIF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
                 -- l_clob := replace(l_clob,l_sub_string, l_select_list_dstb);
               --ELSIF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
               IF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_gl_posted_group_list);
	             END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'GROUP BY (DIMENSION NAME COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startDSTBGroupbyId*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endDSTBGroupbyId*/', 1, 1);
               l_start_tag_length := length('/*startDSTBGroupbyId*/');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               IF(l_base_templatecode = 'GCS_DS_IMPACTED_BAL_SOURCE_BASE') THEN
                  l_clob := replace(l_clob,l_sub_string, l_dstb_group_by_list);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'GROUP BY (DIMENSION ID COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '/*startOrderClause*/', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '/*endOrderClause*/', 1, 1);
               l_start_tag_length := length('/*startOrderClause*/');
               l_sub_string:=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               IF(l_base_templatecode = 'GCS_DS_LOAD_SOURCE_BASE') THEN
                  l_clob :=replace(l_clob,l_sub_string, l_orderby_list_dsload);
               ELSIF(l_base_templatecode = 'GCS_DS_TB_SOURCE_BASE') THEN
               l_clob :=replace(l_clob,l_sub_string, l_orderby_list_dstb);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'ORDER literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startElements-->', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '<!--endElements-->', 1, 1);
               l_start_tag_length := length('<!--startElements-->');
               l_sub_string :=  DBMS_LOB.substr(l_clob,(l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob,l_sub_string, l_element_list_dsload);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'XML SCHEMA ELEMENT (DIMENSION NAME COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;
               --fix 5351083
               /*
               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startDSTBIDElements-->', 1, 1);
               l_end_tag := DBMS_LOB.instr(l_clob, '<!--endDSTBIDElements-->', 1, 1);
               l_start_tag_length := length('<!--startDSTBIDElements-->');
               l_sub_string :=  DBMS_LOB.substr(l_clob, (l_end_tag - (l_start_tag+l_start_tag_length) ), l_start_tag+l_start_tag_length);
               l_clob := replace(l_clob, l_sub_string, l_element_list_dstb);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'XML SCHEMA ELEMENT (DIMENSION ID COLUMNS) literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;
               */

               ELSIF(l_base_templatecode = 'GCS_VS_MAP_SOURCE_BASE') THEN

               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'DT manipulation: '||l_base_templatecode);
               END IF;

               l_start_tag := DBMS_LOB.instr(l_clob, '<!--startVSElements-->', 1, 1);
               l_start_tag_length := length('<!--startVSElements-->');
               l_remaining_str:='<!--endVSElements--></dataStructure></dataTemplate>';
          	   replace_clob(l_clob, l_vs_group_list, l_start_tag+l_start_tag_length, l_remaining_str);
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'XML SCHEMA ELEMENT literal replacement.');
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag : '||l_start_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_end_tag : '||l_end_tag);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start_tag_length : '||l_start_tag_length);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_sub_string : '||l_sub_string);
               END IF;

           END IF;

           -- Finally write back temporary clob to destination blob
           l_start:=1;
           l_off_write:=1;
           DBMS_LOB.createtemporary(l_blob_out,TRUE);
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'Write back manipulated clob to target blob.');
           END IF;

           FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(l_clob) / l_buffer) LOOP

               DBMS_LOB.read ( l_clob, l_buffer, l_start, l_varchar );
               l_amt_write := utl_raw.length (utl_raw.cast_to_raw( l_varchar) );
               DBMS_LOB.write( l_blob_out, l_amt_write, l_off_write, utl_raw.cast_to_raw( l_varchar ) );
               l_off_write := l_off_write + l_amt_write;
               l_start := l_start + l_buffer;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_start : '||l_start);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_buffer : '||l_buffer);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_amt_write : '||l_amt_write);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_off_write : '||l_off_write);
                   FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'l_varchar : '||l_varchar);
               END IF;
           END LOOP;

           UPDATE xdo_lobs
              SET file_data = l_blob_out
            WHERE application_short_name = 'GCS'
              AND lob_type = 'DATA_TEMPLATE'
              AND lob_code = SUBSTR(l_base_templatecode, 1, INSTR(l_base_templatecode,'_BASE')-1);

           DBMS_LOB.freetemporary(l_blob_out);
           DBMS_LOB.freetemporary(l_clob);
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', 'Manipulated clob written back to target blob.');
           END IF;

     END LOOP; -- Loop for template cursor

   END IF;

   CLOSE c_base_data_templates;
   COMMIT;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, g_api || '.' || 'gcs_replace_dt_proc', '<<end>>');
   END IF;

   EXCEPTION
          WHEN OTHERS THEN
          BEGIN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_ERROR) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, g_api || '.' || 'gcs_replace_dt_proc', substr(SQLERRM,1,255));
               END IF;
          END;

END gcs_replace_dt_proc;

END GCS_DATA_TEMPLATE_UTIL_PKG;

/
