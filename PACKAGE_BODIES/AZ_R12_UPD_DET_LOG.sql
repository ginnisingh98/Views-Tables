--------------------------------------------------------
--  DDL for Package Body AZ_R12_UPD_DET_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_R12_UPD_DET_LOG" AS
  /* $Header: azr12detlog.plb 120.12 2008/05/30 11:34:36 gnamasiv noship $ */ -- Author  : LMATHUR
  -- Created : 12/2/2007 2:22:06 PM
  -- Purpose : Update the status for the detailed logging records
  -- Function and procedure implementations

  /*********************Procedure declarations*************************************/

   PROCEDURE raise_error_msg(errcode IN NUMBER,   errmsg IN VARCHAR2,   procedurename IN VARCHAR2,   statement IN VARCHAR2);

  PROCEDURE update_master_status(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_log_status IN VARCHAR2,   p_status_check_clause IN VARCHAR2,   p_id_list IN typ_nest_tab_number);

  c_log_head constant VARCHAR2(30) := 'az.plsql.az_r12_upd_det_log.';

  /**********************************************************/

   PROCEDURE update_status(p_request_id IN NUMBER,   p_source IN VARCHAR2) IS

  v_current_id NUMBER := 2;
  --starting ID
  v_commit_marker_id_list typ_nest_tab_number;
  v_last_commit_marker_id NUMBER;
  v_error_id NUMBER;
  v_commit_marker_name VARCHAR2(255) := 'AZ_CommitMarker';
  l_api_name constant VARCHAR2(70) := 'update_status : ';
  l_log_query VARCHAR2(32000);
  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=''SIMILAR''';

    BEGIN

      SELECT MAX(id)
      INTO v_last_commit_marker_id
      FROM az_diff_results
      WHERE request_id = p_request_id
       AND source = p_source
       AND name = v_commit_marker_name
      ORDER BY id;

    EXCEPTION
    WHEN no_data_found THEN
      v_last_commit_marker_id := v_current_id;
    END;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name
	|| to_char(systimestamp), 'Getting Max Commit marker id for p_request_id: ' || p_request_id
        || ' p_source: ' || p_source || ' v_last_commit_marker_id: ' || v_last_commit_marker_id);
    end if;

    DELETE FROM az_diff_results
    WHERE request_id = p_request_id
     AND source = p_source
     AND name = v_commit_marker_name;

    -- there are no commit markers, hence update the status as SP for all records

    UPDATE az_diff_results
    SET detail_log_status = 'SP'
    WHERE request_id = p_request_id
     AND source = p_source
     AND id > v_last_commit_marker_id
     AND detail_log_status IN('I',   'U',   'IW',   'UW')
     AND detail_log_status <> 'SP';

    COMMIT;

    -- Now update the entire tree for records which are Skipped with Warning
    SELECT id bulk collect
    INTO v_commit_marker_id_list
    FROM az_diff_results
    WHERE request_id = p_request_id
     AND source = p_source
     AND detail_log_status = 'SW'
    ORDER BY id;

    IF v_commit_marker_id_list.COUNT <> 0 THEN
      update_master_status(p_request_id,   p_source,   'concat(g.detail_log_status,''W'')',   ' not in (''IW'',''UW'',''SW'')',   v_commit_marker_id_list);
    END IF;

    ------------------------------------------------------------------------------
    -- Now update the entire tree for records which are Skipped with Warning
    SELECT id bulk collect
    INTO v_commit_marker_id_list
    FROM az_diff_results
    WHERE request_id = p_request_id
     AND source = p_source
     AND detail_log_status = 'E'
    ORDER BY id;

    IF v_commit_marker_id_list.COUNT <> 0 THEN
      update_master_status(p_request_id,   p_source,   '''SE''',   ' not in (''E'',''SE'')',   v_commit_marker_id_list);
    END IF;

    --CALLED EXTERNALLY---update_det_log_counts(p_request_id, p_source);
    COMMIT;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  WHEN application_exception THEN
    RAISE;
  WHEN others THEN
    raise_error_msg(SQLCODE,   sqlerrm,   'update_status',   'procedure end');

  END update_status;

  PROCEDURE update_master_status(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_log_status IN VARCHAR2,   p_status_check_clause IN VARCHAR2,   p_id_list IN typ_nest_tab_number) IS
  l_api_name constant VARCHAR2(30) := 'update_master_status : ';
  l_log_query VARCHAR2(4000);
  BEGIN

    FOR i IN 1 .. p_id_list.COUNT
    LOOP
      l_log_query := 'UPDATE az_diff_results g
                          SET g.detail_log_status = ' || p_log_status || '
                          WHERE g.id in
                                    (SELECT k.id
                                    FROM
                                                  (SELECT parent_id, id, detail_log_status
                                                   FROM
                                                            (SELECT d.parent_id, d.id, d.detail_log_status
                                                             FROM az_diff_results d
                                                             WHERE d.request_id = ' || p_request_id || '
                                                             AND d.source = ''' || p_source || '''
                                                             AND d.parent_id >0) f
                                          CONNECT BY PRIOR f.parent_id = f.id START WITH f.id = ' || p_id_list(i) || ') k

                                          WHERE (k.detail_log_status ' || p_status_check_clause || '))
                          AND g.request_id = ' || p_request_id || '
                          AND g.source = ''' || p_source || '''';

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
        || to_char(systimestamp),   'Executing update master status query: ' || l_log_query);
      END IF;

      EXECUTE IMMEDIATE l_log_query;
    END LOOP;
  END update_master_status;

  PROCEDURE raise_error_msg (ErrCode               IN NUMBER,
                                 ErrMsg                      IN VARCHAR2,
                                 ProcedureName   IN VARCHAR2,
                                 Statement         IN VARCHAR2) IS

                                 v_message VARCHAR2(2048);

        BEGIN

        if( FND_LOG.LEVEL_UNEXPECTED >=
            FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_MESSAGE.SET_NAME('AZ', 'AZ_R12_PLSQL_EXCEPTION'); -- Seeded Message
           -- Runtime Information
           FND_MESSAGE.SET_TOKEN('ERROR_CODE', ErrCode);
           FND_MESSAGE.SET_TOKEN('ERROR_MESG', ErrMsg);
           FND_MESSAGE.SET_TOKEN('ERROR_PROC', 'az_comp_reporter.' || ProcedureName);
           IF (Statement IS NOT NULL) THEN
               FND_MESSAGE.SET_TOKEN('ERROR_STMT', Statement);
           ELSE
              FND_MESSAGE.SET_TOKEN('ERROR_STMT', 'none');
           END IF;
           raise_application_error(-20001, FND_MESSAGE.GET);
        end if;
    END raise_error_msg;


  PROCEDURE update_det_log_counts(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_update_xsl OUT nocopy VARCHAR2) IS

  v_diff_type_list typ_nest_tab_varchar;
  v_diff_count_list typ_nest_tab_varchar;

  v_rows_count NUMBER;
  v_update_xsl VARCHAR2(32767);
  l_api_name constant VARCHAR2(50) := 'update_det_log_counts : ';
  BEGIN

    v_update_xsl := '';
    v_update_xsl := v_update_xsl || '<?xml version="1.0" ?> ';
    v_update_xsl := v_update_xsl || '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> ';
    v_update_xsl := v_update_xsl || '<xsl:template match="EXT">  ';
    v_update_xsl := v_update_xsl || '<EXT>  ';
    v_update_xsl := v_update_xsl || '<xsl:copy-of select="@*"/>   ';
    v_update_xsl := v_update_xsl || '<xsl:apply-templates/>  ';
    v_update_xsl := v_update_xsl || '</EXT>  ';
    v_update_xsl := v_update_xsl || '</xsl:template>  ';
    v_update_xsl := v_update_xsl || '<xsl:template match="H">  ';
    v_update_xsl := v_update_xsl || '<H>  ';
    v_update_xsl := v_update_xsl || '<xsl:copy-of select="@*"/>   ';
    v_update_xsl := v_update_xsl || '<xsl:copy-of select="*[not(name()=''V'')]"/> ';
    v_update_xsl := v_update_xsl || '<xsl:for-each select="V">   ';
    v_update_xsl := v_update_xsl || '<V>  ';
    v_update_xsl := v_update_xsl || '<xsl:copy-of select="@*"/>   ';
    v_update_xsl := v_update_xsl || '<xsl:choose>   ';

    ---Rows Inserted
    SELECT COUNT(1)
    INTO v_rows_count
    FROM az_diff_results d
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = 1
     AND detail_log_status = 'I';

    v_update_xsl := v_update_xsl || '<xsl:when test="@N=''RowsInserted'' and ../V[@N=''EntityOccuranceCode'' and .=''';
    v_update_xsl := v_update_xsl || p_source || ''']">';
    v_update_xsl := v_update_xsl || v_rows_count || '</xsl:when>';

    ---Rows Updated
    SELECT COUNT(1)
    INTO v_rows_count
    FROM az_diff_results d
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = 1
     AND detail_log_status = 'U';

    v_update_xsl := v_update_xsl || '<xsl:when test="@N=''RowsUpdated'' and ../V[@N=''EntityOccuranceCode'' and .=''';
    v_update_xsl := v_update_xsl || p_source || ''']">';
    v_update_xsl := v_update_xsl || v_rows_count || '</xsl:when>';

    SELECT COUNT(1)
    INTO v_rows_count
    FROM az_diff_results d
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = 1
     AND(detail_log_status LIKE 'S%' OR detail_log_status = 'E');

    v_update_xsl := v_update_xsl || '<xsl:when test="@N=''RowsSkipped'' and ../V[@N=''EntityOccuranceCode'' and .=''';
    v_update_xsl := v_update_xsl || p_source || ''']">';
    v_update_xsl := v_update_xsl || v_rows_count || '</xsl:when>';

    ---Rows RowsPartiallyInserted
    SELECT COUNT(1)
    INTO v_rows_count
    FROM az_diff_results d
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = 1
     AND detail_log_status = 'IW';

    v_update_xsl := v_update_xsl || '<xsl:when test="@N=''RowsPartiallyInserted'' and ../V[@N=''EntityOccuranceCode'' and .=''';
    v_update_xsl := v_update_xsl || p_source || ''']">';
    v_update_xsl := v_update_xsl || v_rows_count || '</xsl:when>';

    ---Rows RowsPartiallyUpdated
    SELECT COUNT(1)
    INTO v_rows_count
    FROM az_diff_results d
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = 1
     AND detail_log_status = 'UW';

    v_update_xsl := v_update_xsl || '<xsl:when test="@N=''RowsPartiallyUpdated'' and ../V[@N=''EntityOccuranceCode'' and .=''';
    v_update_xsl := v_update_xsl || p_source || ''']">';
    v_update_xsl := v_update_xsl || v_rows_count || '</xsl:when>';

    v_update_xsl := v_update_xsl || '<xsl:otherwise>   ';
    v_update_xsl := v_update_xsl || '<xsl:value-of select ="."/>  ';
    v_update_xsl := v_update_xsl || '</xsl:otherwise>  ';
    v_update_xsl := v_update_xsl || '</xsl:choose>   ';
    v_update_xsl := v_update_xsl || '</V>  ';
    v_update_xsl := v_update_xsl || '</xsl:for-each>  ';
    v_update_xsl := v_update_xsl || '</H>  ';
    v_update_xsl := v_update_xsl || '</xsl:template>  ';
    v_update_xsl := v_update_xsl || '</xsl:stylesheet>  ';

    p_update_xsl := v_update_xsl;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement, c_log_head || l_api_name
      || to_char(systimestamp) , 'Generated  v_update_xsl: ' || v_update_xsl);
    end if;

  EXCEPTION
  WHEN no_data_found THEN

    NULL;
  WHEN application_exception THEN
    RAISE;
  WHEN others THEN
    raise_error_msg(SQLCODE,   sqlerrm,   'update_det_log_counts',   'Error while updating the count based on type of status');

  END update_det_log_counts;

END az_r12_upd_det_log;



/
