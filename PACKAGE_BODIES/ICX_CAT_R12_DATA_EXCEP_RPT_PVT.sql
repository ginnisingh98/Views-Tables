--------------------------------------------------------
--  DDL for Package Body ICX_CAT_R12_DATA_EXCEP_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_R12_DATA_EXCEP_RPT_PVT" AS
/* $Header: ICXVDERB.pls 120.17 2006/07/21 10:04:28 mkohale noship $*/

--Constant for R12 used to
--populate Updated_by and Created_by Columns
UPGRADE_USER_ID NUMBER := -12;

-- Package name constant used in debug
g_pkg_name VARCHAR2(40) := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT';

/**
 ** Private functions used in Populating the XML Data
 **
 **/
-- Private Functions declaration Start
PROCEDURE generate_header_section(p_interface_header_id IN number, x_header_XML IN OUT NOCOPY CLOB) ;
PROCEDURE generate_lines_section(p_interface_header_id IN NUMBER,
                                 p_category_id IN NUMBER,
                                 p_language IN VARCHAR2,
                                 x_lines_XML IN OUT NOCOPY CLOB);
PROCEDURE populate_namevalue_xmltag(p_category_id IN NUMBER);
PROCEDURE populate_language_map;
PROCEDURE populate_upg_error_msgs(p_interface_header_id_tbl IN DBMS_SQL.NUMBER_TABLE);
-- Private Functions declaration End

/**
 ** Procedure : cleanup_tables
 ** Synopsis  : To delete the existing data from
 **             upgraded tables
 **/
PROCEDURE cleanup_tables
IS
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_proc_name varchar2(100) := 'cleanup_tables';
  l_icx_schema_name VARCHAR2(30) ;
  l_start_date          DATE;
  l_end_date            DATE;

BEGIN

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS'));
  END IF;

  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

  --Data removed from data migration tables
  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_icx_schema_name||'.ICX_CAT_R12_UPG_EXCEP_FILES';

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT.cleanup_tables deleting data
                     from icx_cat_r12_upg_error_msgs';
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module_name, l_log_string);
  END IF;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_icx_schema_name||'.ICX_CAT_R12_UPG_ERROR_MSGS';

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
END;

/**
 ** Procedure : populate_language_map
 ** Synopsis  : To populate the languages map
 **/
PROCEDURE populate_language_map
IS
  l_language_code_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_iso_territory_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_iso_language_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_nls_territory_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_nls_language_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_progress pls_integer;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_proc_name varchar2(100) := 'populate_language_map';

BEGIN
  l_progress := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT.populate_language_map started :--> '||
                    'l_progress:' ||l_progress;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module_name, l_log_string);
  END IF;

  -- Populating the territories list for each language
  -- This list is used while populating the Catalog XML File
  SELECT iso_territory, language_code, iso_language,nls_territory,nls_language BULK COLLECT INTO
         l_iso_territory_tbl,
         l_language_code_tbl,
         l_iso_language_tbl,
         l_nls_territory_tbl,
         l_nls_language_tbl
  FROM fnd_languages
  WHERE installed_flag in ('B','I');

  l_progress := 110;

  FOR i in 1..l_language_code_tbl.COUNT
  LOOP

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_string := 'populate_language_map: language code'||l_language_code_tbl(i)||
                      'iso territory' || l_iso_territory_tbl(i)||
                      'iso language'|| l_iso_language_tbl(i)||
                      'nls territory' || l_nls_territory_tbl(i)||
                      'nls language' || l_nls_language_tbl(i)||
                      'l_progress:' ||l_progress;
      l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
    END IF;

    g_territories(l_language_code_tbl(i)).iso_territory := l_iso_territory_tbl(i);
    g_territories(l_language_code_tbl(i)).iso_language := l_iso_language_tbl(i);
    g_territories(l_language_code_tbl(i)).nls_territory := l_nls_territory_tbl(i);
    g_territories(l_language_code_tbl(i)).nls_language := l_nls_language_tbl(i);

  END LOOP;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT.populate_language_map completed :--> '||
                    'l_progress:' ||l_progress;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module_name, l_log_string);
  END IF;

END;

/**
 ** Procedure : process_data_exceptions_report
 ** Synopsis  : Populates the exceptions file table
 **
 ** Parameter: p_batch_id--Batch_id
 **/
PROCEDURE process_data_exceptions_report(p_batch_id IN po_headers_interface.batch_id%TYPE)
IS

  --Cursor fetching data from po_headers_interface
  CURSOR interface_headers_cursor(p_batch_id NUMBER) IS
  SELECT distinct pohi.interface_header_id,
         pohi.vendor_id,
         pohi.vendor_site_id,
         pohi.org_id,
         pohi.currency_code,
         pohi.cpa_reference,
         poai.language
  FROM  po_headers_interface pohi,
        po_attr_values_tlp_interface poai
  WHERE pohi.batch_id = p_batch_id
  AND poai.interface_header_id = pohi.interface_header_id
  AND EXISTS (SELECT 1
              FROM po_interface_errors poie
              WHERE poie.interface_header_id = pohi.interface_header_id
                  -- to retireve only those languages for which
                  -- corresponding lines has errors
              AND (poie.interface_line_id IS NULL OR
                   poie.interface_line_id = poai.interface_line_id))
  AND NOT EXISTS (SELECT 1
	          FROM icx_cat_r12_upg_excep_files
		  WHERE interface_header_id =  pohi.interface_header_id
                  AND language = poai.language)
  ORDER BY pohi.interface_header_id;

  --Tables for fetching Individual values from cursor
  l_interface_header_id_tbl DBMS_SQL.NUMBER_TABLE;
  l_vendor_id_tbl DBMS_SQL.NUMBER_TABLE;
  l_vendor_site_id_tbl DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl  DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl  DBMS_SQL.VARCHAR2_TABLE;
  l_contract_num_tbl  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl  DBMS_SQL.VARCHAR2_TABLE;
  l_progress PLS_INTEGER;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_proc_name varchar2(100) := 'process_data_exceptions_report';
  l_start_date          DATE;
  l_end_date            DATE;

BEGIN
  l_progress := 100;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
        'Parameters: p_batch_id:' || p_batch_id);
  END IF;

  -- Set Batch Size if null
  IF (ICX_CAT_UTIL_PVT.g_batch_size IS NULL) THEN
    ICX_CAT_UTIL_PVT.setBatchSize();
  END IF;

  -- clear the data from the upgrade tables
  cleanup_tables;

  l_progress := 102;
  -- populate the maps used in generating the information
  populate_language_map;

  l_progress := 104;
  -- Prepare the attributes list for 0 category id
  populate_namevalue_xmltag(0);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'process_data_exceptions_report :'||'Processing exceptions report for Batch Id : '
                     ||p_batch_id||'l_progress:' ||l_progress;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
  END IF;

  l_progress := 110;
  OPEN interface_headers_cursor(p_batch_id);
  LOOP
    l_interface_header_id_tbl.DELETE;
    l_vendor_id_tbl.DELETE;
    l_vendor_site_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_contract_num_tbl.DELETE;
    l_language_tbl.DELETE;

    FETCH interface_headers_cursor BULK COLLECT INTO
          l_interface_header_id_tbl,
          l_vendor_id_tbl,
          l_vendor_site_id_tbl,
          l_org_id_tbl,
          l_currency_code_tbl,
          l_contract_num_tbl,
          l_language_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
    EXIT WHEN l_interface_header_id_tbl.COUNT = 0;

    BEGIN
      -- Inserting the data into Upgrade Exceptions File Table
      FORALL headers_index IN 1..l_interface_header_id_tbl.COUNT
        INSERT INTO icx_cat_r12_upg_excep_files (interface_header_id,
                                                 vendor_id,
                                                 vendor_site_id,
                                                 org_id,
                                                 currency_code,
                                                 contract_num,
                                                 language,
                                                 data_file,
                                                 creation_date,
                                                 created_by,
                                                 last_update_date,
                                                 last_updated_by)
         VALUES (l_interface_header_id_tbl(headers_index),
                 l_vendor_id_tbl(headers_index),
                 l_vendor_site_id_tbl(headers_index),
                 l_org_id_tbl(headers_index),
                 l_currency_code_tbl(headers_index),
                 l_contract_num_tbl(headers_index),
                 l_language_tbl(headers_index),
                 EMPTY_CLOB(),
                 SYSDATE,
                 UPGRADE_USER_ID,
                 SYSDATE,
                 UPGRADE_USER_ID);

      l_progress := 120;
      -- Populate the error messages table
      populate_upg_error_msgs(l_interface_header_id_tbl);

      -- invoke procedure to update the record with the XML file.
      populate_catalog_files(l_interface_header_id_tbl,
                             l_vendor_id_tbl,
                             l_vendor_site_id_tbl,
                             l_org_id_tbl,
                             l_currency_code_tbl,
                             l_contract_num_tbl,
                             l_language_tbl);

      COMMIT;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        -- delete the data for which the xml file is not
        -- yet generated. So that these lines can be
        -- retrieved again
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_string := 'process_data_exceptions_report : Snapshot too old encountered'||
                         'Deleting data from ICX_CAT_R12_UPG_EXCEP_FILES table'||
                         'l_progress:' ||l_progress ||' '||SQLERRM;
         l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module_name, l_log_string);
       END IF;
       DELETE FROM icx_cat_r12_upg_excep_files
       WHERE file_name is null;
       COMMIT;

        IF (interface_headers_cursor%ISOPEN) THEN
          CLOSE interface_headers_cursor;
          OPEN  interface_headers_cursor(p_batch_id);
        END IF;
    END;
  END LOOP;

  IF (interface_headers_cursor%ISOPEN) THEN
    CLOSE interface_headers_cursor;
  END IF;

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END process_data_exceptions_report;

/**
 ** Procedure : populate_catalog_files
 ** Synopsis  : Populates the exceptions file in XML Format
 **
 ** Parameter:
 **     IN     p_interface_header_id_tbl
 **            p_vendor_id_tbl
 **            p_vendor_site_id_tbl
 **            p_org_id_tbl
 **            p_currency_code_tbl
 **            p_contract_num_tbl
 **            p_language_tbl
 **/
PROCEDURE populate_catalog_files(p_interface_header_id_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_vendor_id_tbl           IN DBMS_SQL.NUMBER_TABLE,
                                 p_vendor_site_id_tbl      IN DBMS_SQL.NUMBER_TABLE,
                                 p_org_id_tbl              IN DBMS_SQL.NUMBER_TABLE,
                                 p_currency_code_tbl       IN DBMS_SQL.VARCHAR2_TABLE,
                                 p_contract_num_tbl        IN DBMS_SQL.NUMBER_TABLE,
                                 p_language_tbl            IN DBMS_SQL.VARCHAR2_TABLE)
IS
  -- List of category ids for which the line exists in
  -- interface errors and attr values tlp tables.
  Cursor category_ids_cursor(p_interface_header_id number,
                             p_language varchar2) is
    SELECT distinct poli.ip_category_id
    FROM   po_lines_interface poli
    WHERE  poli.interface_header_id = p_interface_header_id
      AND  EXISTS (SELECT 1
                   FROM  po_interface_errors poie
                   WHERE poie.interface_header_id = poli.interface_header_id
  	                 AND (poie.interface_line_id IS NULL OR
	                       poie.interface_line_id = poli.interface_line_id))
      AND  EXISTS (SELECT 1
                   FROM  po_attr_values_tlp_interface poai
                   WHERE poai.interface_header_id = poli.interface_header_id
                     AND poai.interface_line_id = poli.interface_line_id
	                   AND poai.language = p_language);

  l_ip_category_id_tbl DBMS_SQL.NUMBER_TABLE;
  l_mainXML CLOB;
  l_headerXML CLOB;
  l_linesXML CLOB;

  l_progress PLS_INTEGER;

  l_interface_header_id NUMBER;
  l_ip_category_id NUMBER;
  l_language icx_cat_r12_upg_excep_files.language%TYPE;

  langCount number := 1;
  l_file_name icx_cat_r12_upg_excep_files.file_name%TYPE;
  l_table_count NUMBER;
  l_prev_interface_header_id NUMBER := 0;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_proc_name varchar2(100) := 'populate_catalog_files';
  l_start_date          DATE;
  l_end_date            DATE;
  headers_index NUMBER := 1;
BEGIN
   l_progress := 100;

   l_start_date := sysdate;

   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;
   l_table_count := p_interface_header_id_tbl.COUNT;
   -- iterate through the interface headers in the PL/SQL table
   WHILE headers_index <= l_table_count  LOOP
     l_interface_header_id := p_interface_header_id_tbl(headers_index);
     l_language := p_language_tbl(headers_index);

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_string := 'populate_catalog_files; '||' interface header id '|| l_interface_header_id
                       ||'Session Alter to nls language'||g_territories(l_language).nls_language
                       ||'and nls territory'|| g_territories(l_language).nls_territory;
       l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
     END IF;

     EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE = '''|| g_territories(l_language).nls_language ||'''';
     EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TERRITORY ='''|| g_territories(l_language).nls_territory||'''';


     l_progress := 120;
     -- Prepare the XML containing header information
     IF ( l_interface_header_id <> l_prev_interface_header_id) THEN
       generate_header_section(l_interface_header_id, l_mainXML);
       l_prev_interface_header_id := l_interface_header_id;
     END IF;

     l_progress := 130;
     l_headerXML := l_mainXML;
     l_linesXML := EMPTY_CLOB();

     l_progress := 140;
     -- Prepare Line Level XML loop through the categories
     OPEN category_ids_cursor(l_interface_header_id, l_language);
     LOOP
       l_ip_category_id_tbl.DELETE;
       FETCH category_ids_cursor BULK COLLECT INTO
	     l_ip_category_id_tbl
       LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

       l_progress := 150;
       EXIT when l_ip_category_id_tbl.COUNT=0;

       l_progress := 160;
       -- Loop through each category
       FOR category_index in 1..l_ip_category_id_tbl.COUNT
       LOOP
         l_ip_category_id := l_ip_category_id_tbl(category_index);

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_string := 'populate_catalog_files; '||' category id '|| l_ip_category_id;
           l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
         END IF;

         l_progress := 170;
         -- Generate Lines section for the lines that have the category id
         -- as l_ip_category_id
         generate_lines_section(l_interface_header_id, l_ip_category_id, l_language,
                                l_linesXML);
         l_progress := 180;
       END LOOP;  -- end of categories FOR Loop
     END LOOP; -- end of categories lines cursor

     IF (category_ids_cursor%ISOPEN) THEN
       CLOSE category_ids_cursor;
     END IF;

     l_progress := 190;
     replace_clob('R12_ITEM_DET', l_linesXML, l_headerXML, false);
     replace_clob('<CATALOG>',
                  '<CATALOG xml:lang="'||
			g_territories(l_language).iso_language||'-'||
			g_territories(l_language).iso_territory||'">',
                  l_headerXML, false);
     l_file_name := 'ItemException_'||l_language||'.xml';
     -- if current language is same as the language in the PL/SQL Table
     -- then update the current row
     l_progress := 200;

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_string := 'populate_catalog_files : updating existing rows';
       l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
     END IF;
     --update the table

     UPDATE icx_cat_r12_upg_excep_files
     SET  file_name = l_file_name,
          data_file = l_headerXML
     WHERE interface_header_id = l_interface_header_id
       AND language = l_language;

    headers_index := headers_index + 1 ;
  END LOOP; -- end of interface header ids for loop

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END populate_catalog_files;

/**
 ** Procedure : populate_upg_error_msgs
 ** Synopsis  : Procedure For Populating
 **             ICX_CAT_R12_UPG_Error_Msgs Table.
 ** Parameter:
 **     IN     p_interface_header_id_tbl  --table of interface_header_ids
 **/
PROCEDURE populate_upg_error_msgs(p_interface_header_id_tbl IN DBMS_SQL.NUMBER_TABLE)
IS
  --cursor for fetching column value to be populated
  -- as token value in the error messages table
  CURSOR interface_errors_cursor(p_interface_header_id po_interface_errors.INTERFACE_HEADER_ID%TYPE)
  IS
   SELECT error_message_name,
          LTRIM(replace(MAX(SYS_CONNECT_BY_PATH(column_value, '**R12MDIGREPL**'))
          KEEP (DENSE_RANK LAST ORDER BY curr),'**R12MDIGREPL**', ','),',') AS token_value
   FROM (SELECT error_message_name,
                 column_value,
                 ROW_NUMBER() OVER (PARTITION BY error_message_name ORDER BY column_value) AS curr,
                 ROW_NUMBER() OVER (PARTITION BY error_message_name ORDER BY column_value) -1 AS prev
           FROM po_interface_errors
           WHERE interface_header_id = p_interface_header_id
             AND error_message_name <> 'ICX_CAT_UPG_ALL_LINES_FAILED'
           GROUP BY error_message_name, column_value)
    GROUP BY error_message_name
    CONNECT BY prev = PRIOR curr AND error_message_name = PRIOR error_message_name
    START WITH curr = 1;

  l_po_msg_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_column_value_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_interface_header_id NUMBER;
  l_prev_interface_header_id NUMBER := 0;
  l_progress PLS_integer;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_start_date          DATE;
  l_end_date            DATE;
  l_proc_name varchar2(100) := 'populate_upg_error_msgs';

BEGIN
  l_progress :=100;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
       ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS'));
  END IF;

  FOR header_id_index IN 1..p_interface_header_id_tbl.COUNT
  LOOP
    --Loop to through interface errors cursor
    l_interface_header_id := p_interface_header_id_tbl(header_id_index);

    IF (l_interface_header_id <> l_prev_interface_header_id) THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'populate_upg_error_msgs:'||'Inserting messages for interface header id'
                        ||l_interface_header_id|| 'l_progress:' ||l_progress;
        l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module_name, l_log_string);
      END IF;

      OPEN interface_errors_cursor(p_interface_header_id_tbl(header_id_index));
      LOOP
        FETCH interface_errors_cursor BULK COLLECT INTO
              l_po_msg_tbl,
              l_column_value_tbl
        LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

        l_progress := 110;
        EXIT WHEN l_po_msg_tbl.COUNT = 0;

        l_progress := 120;
        FORALL i IN 1..l_po_msg_tbl.COUNT
          INSERT INTO icx_cat_r12_upg_error_msgs(interface_header_id,
                                                 error_message_name,
                                                 token_value,
                                                 creation_date,
                                                 created_by,
                                                 last_update_date,
                                                 last_updated_by,
                                                 last_update_login)
          VALUES (p_interface_header_id_tbl(header_id_index),
                  l_po_msg_tbl(i),
                  l_column_value_tbl(i),
                  SYSDATE,
                  UPGRADE_USER_ID,
                  SYSDATE,
                  UPGRADE_USER_ID,
                  NULL);
      END LOOP;

      IF (interface_errors_cursor%ISOPEN) THEN
        CLOSE interface_errors_cursor;
      END IF;
    END IF;

     l_prev_interface_header_id := l_interface_header_id;

  END LOOP;

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END populate_upg_error_msgs;

/**
 ** Procedure : generate_header_section
 ** Synopsis  : Function that returns the XML containing
 **             Header details
 **
 ** Parameter:
 **     IN     p_interface_header_id  -- interface header id
 **     IN OUT
 **            x_header_XML         -- Clob containing header XML
 **/
PROCEDURE generate_header_section(p_interface_header_id IN number,
                                  x_header_XML IN OUT NOCOPY CLOB)
IS
  l_qryString VARCHAR2(4000);
  l_params xml_bind_params;
  l_progress PLS_INTEGER;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_start_date          DATE;
  l_end_date            DATE;
  l_proc_name varchar2(100) := 'generate_header_section';

BEGIN
  l_progress := 100;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
       ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
       'Parameters: p_interface_header_id:' || p_interface_header_id);
  END IF;

  l_qryString := 'SELECT XMLConcat(
              XMLElement("ADMIN",
 	       XMLElement("NAME", ''CATALOG EXT''),
	       XMLElement("INFORMATION",
	        XMLElement("SOURCE", ''RELEASE 12 UPGRADE''),
	        XMLElement("DATE", sysdate))),
               XMLElement("DATA",
	        XMLElement("DOCUMENT",
                 XMLAttributes(''GBPA'' as "type"),
	          XMLElement("HEADER",
                   XMLElement("DOCUMENT_NUMBER", pohi.document_num),
                   XMLElement("OPERATING_UNIT",
		   XMLElement("OWNING_ORG", hro.name)),
  		   XMLElement("SUPPLIER_NAME", pv.vendor_name),
                   XMLElement("SUPPLIER_SITE", pvs.vendor_site_Code),
 		   XMLElement("CURRENCY", pohi.currency_code)),
		   XMLElement("LINES", ''R12_ITEM_DET'')))) AS CATALOG
      FROM  po_headers_interface pohi, HR_ALL_ORGANIZATION_UNITS hro,
            po_vendors pv, po_vendor_sites_all pvs
      WHERE pohi.interface_header_id = :INTERFACE_HEADER_ID
        AND pohi.org_id = hro.organization_id (+)
        AND pohi.vendor_id = pv.vendor_id (+)
        AND pohi.vendor_site_id = pvs.vendor_site_id (+)';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_string := 'generate_lines_section:'||'Binding parameters :interface header id'
                   ||p_interface_header_id;
   l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
 END IF;

  -- Set the bind parameter values
  l_params := xml_bind_params(null);
  l_params(1).name := 'INTERFACE_HEADER_ID';
  l_params(1).value := to_char(p_interface_header_id);

  l_progress := 110;
  x_header_XML := get_xml(l_qryString, l_params);

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END generate_header_section;

/*
 ** Procedure : generate_lines_section
 ** Synopsis  : Function that returns the XML containing
 **             Line Level Data
 **
 ** Parameter:
 **     IN     p_interface_header_id  -- interface header id
 **            p_interface_line_id -- interface line id
 **            p_category_id       -- Category id
 **     IN OUT
 **            x_lines_XML         -- Clob containing Lines XML
 **/
PROCEDURE generate_lines_section(p_interface_header_id IN NUMBER,
                                 p_category_id IN NUMBER,
		                 p_language IN VARCHAR2,
		                 x_lines_XML IN OUT NOCOPY CLOB)
IS
  l_qryString varchar2(30000);
  l_params xml_bind_params;
  x_result CLOB;
  l_attr_list varchar2(18000);
  l_progress PLS_INTEGER;
  l_shopping_category icx_cat_categories_tl.key%TYPE;
  l_att_list_qry  varchar2(20000);
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_start_date          DATE;
  l_end_date            DATE;
  l_proc_name varchar2(100) := 'generate_lines_section';
BEGIN

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
       ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
       'Parameters: p_interface_header_id:' || p_interface_header_id||
       ',p_category_id'|| p_category_id||
       ',p_language'||p_language);
  END IF;

  l_progress := 100;
  -- Retrieve the descriptors list (NameValue string).
  -- If the lines in two different interface headers have the
  -- same category id then there is no need to populate the list
  -- again for the lines of second interface header id.
  -- Hence invoke the call to populate if data doesn't exist.
  BEGIN
    l_progress := 110;
    IF (p_category_id IS NULL) THEN
      l_attr_list := ' ';
    ELSE
      l_attr_list := g_descriptors_list(p_category_id);
    END IF;
  EXCEPTION
    when no_data_found then
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'generate_lines_section:'||'No data found in g_descriptors_list'||
                        'Invoking populate_namevalue_xmltag for category id'||p_category_id;
        l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name);
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module_name, l_log_string);
      END IF;
      populate_namevalue_xmltag(p_category_id);
      l_attr_list := g_descriptors_list(p_category_id);
  END;

  l_progress := 120;
  BEGIN
    SELECT distinct icat.key
    INTO l_shopping_category
    FROM icx_cat_categories_tl icat
    WHERE icat.rt_category_id = p_category_id;
  EXCEPTION
    when no_data_found then
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_string := 'generate_lines_section:'||'No data found in icx_cat_categories_tl'||
                        'Assigning '' '' to shopping category for category id :'||p_category_id;
        l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name);
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module_name, l_log_string);
      END IF;
      l_shopping_category := ' ';
  END;

  l_att_list_qry := ' ';
  if (length(l_attr_list) > 2) then
    l_att_list_qry :=
         'XMLElement("DMIG_NVP", '|| l_attr_list ||'),';
   end if;

   l_progress := 130;
   l_qryString :=
         'SELECT XMLAgg(
    	      XMLElement("ITEM",
  	      XMLAttributes(''SYNC'' as "action"),
              XMLElement("SHOPPING_CATEGORY", :SHOPPING_CAT),
	      XMLELEMENT("SUPPLIER_PART_NUM", nvl(to_char(poli.vendor_product_num), ''  '')),
              XMLElement("SUPPLIER_PART_AUXID", nvl(decode (poli.supplier_part_auxid,''##NULL##'','' '',
                                                            poli.supplier_part_auxid),''  '')),
	      XMLElement("DMIG_NVP", '|| g_descriptors_list(0) ||'),
	      '|| l_att_list_qry ||'
	      XMLElement("PRICE",
              XMLAttributes(nvl(poli.negotiated_by_preparer_flag, '' '') as "negotiated"),
 	      XMLElement("UNIT_PRICE", poli.unit_price),
	      XMLElement("UNIT_OF_MEASURE", poli.uom_code)
	      ))) AS ITEMS_INF
           FROM po_lines_interface poli, po_attr_values_tlp_interface poavti, po_attr_values_interface poavi
          WHERE poli.interface_header_id = :INTERFACE_HEADER_ID
            AND poli.ip_category_id = :IP_CATEGORY_ID
            AND poavi.interface_header_id = poli.interface_header_id
            AND poavi.interface_line_id = poli.interface_line_id
            AND poavti.interface_header_id = poli.interface_header_id
            AND poavti.interface_line_id = poli.interface_line_id
            AND poavti.language = :LANGUAGE
	    AND EXISTS (SELECT 1 FROM po_interface_errors poie
                         WHERE poie.interface_header_id = poli.interface_header_id
  	                   AND (poie.interface_line_id IS NULL OR
	                        poie.interface_line_id = poli.interface_line_id))';


 IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_string := 'generate_lines_section:'||'Binding parameters :interface header id'
                   ||p_interface_header_id||', IP CATEGORY ID:'|| p_category_id
                   ||', LANGUAGE'|| p_language ||', SHOPPING CATEGORY' || l_shopping_category;
   l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module_name, l_log_string);
 END IF;

  -- Set the bind parameter values
  l_params := xml_bind_params(null, null, null, null);
  l_params(1).name := 'SHOPPING_CAT';
  l_params(1).value := nvl(l_shopping_category, ' ');

  l_params(2).name := 'INTERFACE_HEADER_ID';
  l_params(2).value := to_char(p_interface_header_id);

  l_params(3).name := 'IP_CATEGORY_ID';
  l_params(3).value := to_char(p_category_id);

  l_params(4).name := 'LANGUAGE';
  l_params(4).value := to_char(p_language);

  l_progress := 140;
  x_result := get_xml(l_qryString, l_params);


  l_progress := 150;
  -- replace the <DMIG_NVP> tags with null. These are appeneded as
  -- a part of building the name value pair in the above query.
  replace_clob('<DMIG_NVP>', ' ', x_result);
  replace_clob('</DMIG_NVP>', ' ', x_result);
  replace_clob('<ITEMS_INF>', ' ', x_result);
  replace_clob('</ITEMS_INF>', ' ', x_result);
  replace_clob('<?xml version="1.0"?>', ' ', x_result, false);

  l_progress := 160;

  IF (dbms_lob.getlength(x_lines_XML) > 0) THEN
    dbms_lob.append(x_lines_XML, x_result);
  ELSE
     x_lines_XML := x_result;
  END IF;

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END generate_lines_section;

/**
 ** Procedure : get_xml
 ** Synopsis  : To create an XML
 **
 ** Parameter:
 **     IN     p_qryctx     --  Query String
 **            p_bind_params -- Bind Parameters for the XML Query
 **            p_row_tag     -- Row Tag to set, default NULL
 **            p_row_settag  -- Row SetTag to set, default NULL
 ** Retruns    XML object.
 **/
FUNCTION get_xml(p_qryString IN VARCHAR2,
 	               p_bind_params IN xml_bind_params,
 	               p_row_tag IN VARCHAR2,
 	               p_row_settag IN VARCHAR2)
  RETURN CLOB
IS
  x_result CLOB;
  l_progress PLS_INTEGER;
  l_qryctx DBMS_XMLGEN.ctxhandle;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_start_date          DATE;
  l_end_date            DATE;
  l_proc_name varchar2(100) := 'get_xml';
BEGIN
  l_progress := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
       ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS'));
  END IF;
  -- Set the bind parameters
  l_qryctx := DBMS_XMLGEN.newcontext(p_qryString);

  FOR i in 1..p_bind_params.COUNT
  LOOP
    DBMS_XMLGEN.setBindValue(l_qryctx, p_bind_params(i).name,
                             p_bind_params(i).value);
  END LOOP;

  l_progress := 110;
  -- Set the row tag and rowset tag
  DBMS_XMLGEN.setRowTag(l_qryctx, p_row_tag);
  DBMS_XMLGEN.setRowsetTag(l_qryctx, p_row_settag);

  DBMS_XMLGEN.setNullHandling(l_qryctx, DBMS_XMLGEN.EMPTY_TAG);
  DBMS_XMLGEN.setConvertSpecialChars(l_qryctx, TRUE);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'get_xml: Invoking XMLgen for XML generation';
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
  END IF;

  l_progress := 120;
  x_result:=DBMS_XMLGEN.getXML(l_qryctx);

  l_progress := 130;
  DBMS_XMLGEN.closecontext(l_qryctx);

  l_progress := 140;
  return x_result;

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END get_xml;

/**
 ** Procedure : populate_namevalue_xmltag
 ** Synopsis  : To Populate the Attribute Value List that contains
 **             key, stored in columns of both the translatable
 **             and non-translatable interface tables.
 **
 ** Parameter:
 **     IN     p_category_id -- Category Id
 **/
PROCEDURE populate_namevalue_xmltag(p_category_id IN NUMBER)
IS
  TYPE descriptors_rec_type IS RECORD(
           key              icx_cat_attributes_tl.KEY%TYPE,
	   stored_in_table  icx_cat_attributes_tl.STORED_IN_TABLE%TYPE,
	   stored_in_column icx_cat_attributes_tl.STORED_IN_COLUMN%TYPE);

  TYPE descriptors_tbl_type IS TABLE OF descriptors_rec_type;
  l_descriptors_tbl descriptors_tbl_type;

  l_attr_list VARCHAR2(18000);
  l_progress PLS_INTEGER;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_start_date          DATE;
  l_end_date            DATE;
  l_proc_name varchar2(100):= 'populate_namevalue_xmltag' ;
BEGIN
  l_progress := 100;

  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
       ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS'));
  END IF;

  -- Query to select the attributes of a category
  SELECT distinct replace(key, '''', ''''''),
	 decode(stored_in_table,
            'PO_ATTRIBUTE_VALUES', 'poavi',
            'PO_ATTRIBUTE_VALUES_TLP', 'poavti')
               stored_in_table,
	 stored_in_column
  BULK COLLECT INTO l_descriptors_tbl
  FROM icx_cat_attributes_tl
  WHERE rt_category_id = p_category_id
    AND stored_in_Table is not null
    AND stored_in_column is not null;

  l_progress := 110;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'populate_namevalue_xmltag: Concatenating values to generate XML Query String';
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module_name, l_log_string);
  END IF;

  IF (l_descriptors_tbl.COUNT = 0) THEN
    l_attr_list := ' ';
  ELSE
    l_progress := 120;
    -- Forming a string that contains the key, stored in columns as
    -- XMLElement("NAMEVALUE", XMLAttributes( key as "name),
    --      stored_in_table.stored_in_column)
    l_attr_list := 'XMLElement("NAMEVALUE", XMLAttributes('''||
                   l_descriptors_tbl(1).key||''' as "name"),'||
                   l_descriptors_tbl(1).stored_in_table||'.'||
                   l_descriptors_tbl(1).stored_in_column|| ')';

    FOR n in 2..l_descriptors_tbl.COUNT
    LOOP
      l_attr_list := l_attr_list || ', XMLElement("NAMEVALUE", XMLAttributes('''||
                     l_descriptors_tbl(n).key||''' as "name"),'||
                     l_descriptors_tbl(n).stored_in_table||'.'||
                     l_descriptors_tbl(n).stored_in_column|| ')';
    END LOOP;
  END IF;

  l_progress := 130;
  -- Assign this string to the descriptors list hash
  g_descriptors_list(p_category_id) := l_attr_list;

  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_proc_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END populate_namevalue_xmltag;

/*
 ** Procedure : replace_clob
 ** Synopsis  : Replaces the substring of the CLOB with
 **             given string
 **
 ** Parameter:
 **     IN     p_replace_str  -- String to be replaced
 **            p_replace_with -- String to replace with
 **     IN OUT p_src_clob     -- source object
 **/
PROCEDURE replace_clob (p_replace_str IN VARCHAR2,
                        p_replace_with IN CLOB,
                        p_src_clob IN OUT NOCOPY CLOB,
                        p_replace_mutliple_occurances IN BOOLEAN)
IS
  x_result CLOB := ' ';
  l_variablePosition number;
  l_new_variablePosition number;
  l_progress PLS_INTEGER;
  l_replace_str_length number;
  l_replace_with_length number;
  l_repeated_flag boolean := FALSE;
  l_log_string varchar2(400);
  l_module_name varchar2(200);
  l_proc_name varchar2(100):= 'replace_clob' ;

BEGIN
  l_progress := 110;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT.replace_clob started:-->'||
                  'l_progress:' ||l_progress;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module_name, l_log_string);
  END IF;

   IF (dbms_lob.getlength(p_src_clob) > 0 and length(p_replace_with) > 0)THEN
    dbms_lob.createtemporary(x_result, false);
    l_variablePosition := DBMS_LOB.INSTR(p_src_clob, p_replace_str );

   l_progress := 120;
   IF (l_variablePosition >=1) THEN
     l_replace_str_length := length(p_replace_str);
     l_replace_with_length := length(p_replace_with);

     l_progress := 130;
     IF (l_variablePosition > 1) THEN
       dbms_lob.copy(x_result, p_src_clob, l_variablePosition-1, 1, 1);
     END IF;
     l_progress := 140;
     dbms_lob.append(x_result,p_replace_with);
     l_progress := 150;
     l_variablePosition := l_variablePosition + l_replace_str_length;

      IF (p_replace_mutliple_occurances) THEN
        LOOP
          l_progress := 160;
          l_new_variablePosition := DBMS_LOB.INSTR(p_src_clob,
                                      p_replace_str, l_variablePosition);
          EXIT WHEN l_new_variablePosition < 1;

          l_progress := 170;
          IF (l_new_variablePosition > 1 and
            l_new_variablePosition <> l_variablePosition ) THEN
            dbms_lob.copy(x_result, p_src_clob,
            l_new_variablePosition - l_variablePosition,
            dbms_lob.getlength(x_result)+1, l_variablePosition);
          END IF;

          l_progress := 180;
          dbms_lob.writeappend(x_result, l_replace_with_length, p_replace_with);

          l_progress := 190;
          l_variablePosition := l_new_variablePosition + l_replace_str_length;
          l_repeated_flag := TRUE;
              END LOOP;
        IF (l_repeated_flag) THEN
          l_variablePosition := l_variablePosition + l_replace_str_length;
        END IF;
      END IF;

      l_progress := 200;
      IF ( (dbms_lob.getlength(p_src_clob)) - (l_variablePosition) > 0) then
        if (l_repeated_flag) then
          dbms_lob.copy(x_result, p_src_clob,
          dbms_lob.getlength(p_src_clob)-l_variablePosition+l_replace_str_length+1,
          dbms_lob.getlength(x_result)+1, l_variablePosition-l_replace_str_length);
        else
          dbms_lob.copy(x_result, p_src_clob,
          dbms_lob.getlength(p_src_clob)-l_variablePosition+1,
          dbms_lob.getlength(x_result)+1, l_variablePosition);
        end if;
      END IF;
      l_progress := 210;
      p_src_clob := x_result;
    END IF;
      dbms_lob.freetemporary(x_result);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'ICX_CAT_R12_DATA_EXCEP_RPT_PVT.replace_clob completed:-->'||
                  'l_progress:' ||l_progress;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name,l_proc_name);
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module_name, l_log_string);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  ICX_CAT_UTIL_PVT.logUnexpectedException(
      g_pkg_name, l_proc_name,' --> l_progress:' ||l_progress||' '|| SQLERRM);
  RAISE;
END replace_clob;

END ICX_CAT_R12_DATA_EXCEP_RPT_PVT;

/
