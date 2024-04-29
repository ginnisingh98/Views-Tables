--------------------------------------------------------
--  DDL for Package Body AZ_R12_TRANSFORM_CASCADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_R12_TRANSFORM_CASCADE" as
/* $Header: aztrfmcascadeb.pls 120.23 2008/05/30 11:29:39 hboda ship $ */

       -- Private type declarations
  TYPE TYP_ASSOC_ARR IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(4000);
  TYPE TYP_NEST_TAB_VARCHAR IS TABLE OF VARCHAR2(32767);

  -- Private constant declarations
  DIFF_SCHEMA_URL VARCHAR2(4000); -- global variable
  v_dml_count       NUMBER;
  commit_batch_size NUMBER;

  -- Private variable declarations
  FUNCTION GET_MAPPED_ATTRIBUTES(P_DEPENDANT_API_CODE IN VARCHAR2,
                                 P_REQUIRED_API_CODE  IN VARCHAR2)
    RETURN TYP_ASSOC_ARR;

  FUNCTION GET_TRANSFORM_SQL(P_REQUEST_ID       IN NUMBER,
                             P_DEPENDANT_SOURCE IN VARCHAR2,
                             P_XSL_STRING       IN VARCHAR2,
                             P_PARENT_ID        IN NUMBER,
                             P_MASTER_FLAG IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE APPLY_TRANSFORM(P_REQUEST_ID         IN NUMBER,
                            P_REQUIRED_API_CODE  IN VARCHAR2,
                            P_DEPENDANT_API_CODE IN VARCHAR2,
                            P_REQUIRED_SOURCE    IN VARCHAR2,
                            P_DEPENDANT_SOURCE   IN VARCHAR2,
                            P_DEPENDANT_eo_code   IN VARCHAR2);

  PROCEDURE RAISE_ERROR_MSG(ERRCODE       IN NUMBER,
                            ERRMSG        IN VARCHAR2,
                            PROCEDURENAME IN VARCHAR2,
                            STATEMENT     IN VARCHAR2);

  FUNCTION get_transform_all_sql(
                                 P_EXISTSNODE_STRING IN VARCHAR2,
                                 p_request_id           IN NUMBER,
                                 p_source               IN VARCHAR2)
    RETURN VARCHAR2;
  PROCEDURE update_master_flag(P_REQUEST_ID         IN NUMBER,
                            P_SOURCE    IN VARCHAR2,
                            p_column_name IN VARCHAR2,
                            p_id_list IN TYP_NEST_TAB_VARCHAR, p_upd_entire_tree_flag IN VARCHAR2);
    ---Proc to update the count in selection set XML
  PROCEDURE update_conflict_status(P_REQUEST_ID         IN NUMBER,
                            P_SOURCE    IN VARCHAR2);

  PROCEDURE UPDATE_XSL_EXISTSNODE_STR ( P_REQUEST_ID       IN NUMBER,
                             P_SOURCE IN VARCHAR2,
                             P_ATTR_NAME IN VARCHAR2,
                             P_ATTR_NEW_VALUE IN VARCHAR2,
                             P_PARENT_ATTR_NAME IN VARCHAR2,
                             P_UPDATE_XSL       IN OUT NOCOPY VARCHAR2,
                             P_EXISTSNODE_STRING IN OUT NOCOPY VARCHAR2);

  c_log_head constant VARCHAR2(200) := 'az.plsql.az_r12_transform_cascade.';

  -- Function and procedure implementations
  PROCEDURE apply_transform_to_tree(P_REQUEST_ID         IN NUMBER,
                            P_REQUIRED_API_CODE  IN VARCHAR2,
                            P_DEPENDANT_API_CODE IN VARCHAR2,
                            P_REQUIRED_SOURCE    IN VARCHAR2,
                            p_dependant_eo_code IN VARCHAR2,
                            p_diff_schema_url IN VARCHAR2) IS
  v_eo_name_List TYP_NEST_TAB_VARCHAR;
  v_eo_code_List TYP_NEST_TAB_VARCHAR;
  v_ref_eo_code_List TYP_NEST_TAB_VARCHAR;
  v_source_List TYP_NEST_TAB_VARCHAR;
  BEGIN

--      For logging
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',   'In apply_transform_to_tree procedure');
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'P_REQUEST_ID --->  '||P_REQUEST_ID);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'P_REQUIRED_API_CODE --->  '||P_REQUIRED_API_CODE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'P_DEPENDANT_API_CODE --->  '||P_DEPENDANT_API_CODE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'P_REQUIRED_SOURCE --->  '||P_REQUIRED_SOURCE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'p_dependant_eo_code --->  '||p_dependant_eo_code);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ',    'p_diff_schema_url --->  '||p_diff_schema_url);
      END IF;
--      For logging

      DIFF_SCHEMA_URL := p_diff_schema_url;
      commit_batch_size := fnd_profile.VALUE('AZ_COMMIT_ROWCOUNT');
      v_dml_count       := 0;

      select NAME, code, REF, SOURCE
      BULK COLLECT INTO
      v_eo_name_List, v_eo_code_List, v_ref_eo_code_List, v_source_List
      from (select extractValue(value(e),'/H/V[@N="EntityOccuranceName"]/text()') name,
      extractValue(value(e),'/H/V[@N="EntityOccuranceCode"]/text()') code,
      extractValue(value(e),'/H/V[@N="RefEntityOccuranceCode"]/text()') ref,
      extractValue(value(e),'/H/S/text()') source,
      to_number(extractValue(value(e),'/H/V[@N="SeqNum"]/text()')) seq_num
      FROM az_requests d,TABLE(XMLSequence(extract(d.selection_set,'/EXT/H/V[@N="EntityOccuranceCode" and .="'||p_dependant_eo_code||'"]/..'))) e
      where d.request_id=p_request_id AND d.request_type='T'
      union all
      select extractValue(value(e),'/H/V[@N="EntityOccuranceName"]/text()') name,
      extractValue(value(e),'/H/V[@N="EntityOccuranceCode"]/text()') code,
      extractValue(value(e),'/H/V[@N="RefEntityOccuranceCode"]/text()') ref,
      extractValue(value(e),'/H/S/text()') source,
      to_number(extractValue(value(e),'/H/V[@N="SeqNum"]/text()')) seq_num
      FROM az_requests d,TABLE(XMLSequence(extract(d.selection_set,'/EXT/H[@A3="Y"]/V[@N="EntityOccuranceName" or @N="EntityOccuranceCode" or @N="RefEntityOccuranceCode"]/..'))) e
      where d.request_id=p_request_id AND d.request_type='T' ) f
      start with f.code=p_dependant_eo_code
      connect by prior f.code=f.ref
      order siblings by f.seq_num;

      -- propogate the changed attributes to the child VOs (like TLs) for the given source
      FOR i IN 1 ..  v_eo_name_List.COUNT LOOP
          APPLY_TRANSFORM(p_request_id, P_REQUIRED_API_CODE, P_DEPENDANT_API_CODE, P_REQUIRED_SOURCE, v_source_List(i), v_eo_code_List(i));
      END LOOP;
      COMMIT;

--      For logging
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'apply_transform_to_tree :  ' || to_char(systimestamp),   'apply_transform_to_tree procedure is completed');
      END IF;
--      For logging

   EXCEPTION
     WHEN application_exception THEN
       RAISE;
     WHEN OTHERS THEN
       raise_error_msg(SQLCODE,
                       SQLERRM,
                       'apply_transform_to_tree',
                       'procedure end');
  END apply_transform_to_tree;

  PROCEDURE APPLY_TRANSFORM(P_REQUEST_ID         IN NUMBER,
                            P_REQUIRED_API_CODE  IN VARCHAR2,
                            P_DEPENDANT_API_CODE IN VARCHAR2,
                            P_REQUIRED_SOURCE    IN VARCHAR2,
                            P_DEPENDANT_SOURCE   IN VARCHAR2,
                            p_dependant_eo_code IN VARCHAR2) IS
    V_ATTRIBUTES_HASH             TYP_ASSOC_ARR;
    V_EXISTSNODE_STRING           VARCHAR2(32767);
    V_EXISTSNODE_NAMEVAL_STR           VARCHAR2(32767);
    V_CONFLICT_XSL                VARCHAR2(32767);
    V_TRANSFORM_SQL               VARCHAR2(32767);
    V_DEPENDANT_IDS_LIST          TYP_NEST_TAB_VARCHAR;
    V_PARENT_ID_LIST              TYP_NEST_TAB_VARCHAR;
    V_REQ_API_ATTR_NAME_LIST      TYP_NEST_TAB_VARCHAR;
    V_REQ_API_ATTR_NEW_VALUE_LIST TYP_NEST_TAB_VARCHAR;
    V_REQ_API_ATTR_OLD_VALUE_LIST TYP_NEST_TAB_VARCHAR;
    V_REQ_API_API_ATTR_NAME       VARCHAR2(300);
    V_DEPENDANT_API_ATTR_NAME     VARCHAR2(300);
    V_REQ_API_ATTR_NEW_VALUE      VARCHAR2(300);
    V_REQ_API_ATTR_OLD_VALUE      VARCHAR2(300);
    V_DEPENDANT_IDS_SQL           VARCHAR2(32767);
    V_DEPENDANT_CHILD_IDS_SQL     VARCHAR2(32767);
    V_DEP_DETAIL_CHILD_IDS_SQL     VARCHAR2(32767);
    V_DEPENDANT_CHILD_IDS_LIST    TYP_NEST_TAB_VARCHAR;
    V_CONFLICT_CHILD_IDS_LIST     TYP_NEST_TAB_VARCHAR;

    V_TEMP                        VARCHAR2(255);
    V_CHILD_ID_LIST               TYP_NEST_TAB_VARCHAR;
    V_CONFLICT_PARAM3_COUNT       NUMBER;
    V_CHILD_XSL_STRING varchar2(32767);
    V_TEMP_SQL VARCHAR2(32767);
    V_CHECK_TRFM_ALL_FLAG  NUMBER;

    --Introduced to take care of one-many mappings between mapped attributes
    V_DEP_API_MAP_ATTR_NAME_LIST TYP_NEST_TAB_VARCHAR;
    V_REQ_API_MAP_ATTR_NAME_LIST TYP_NEST_TAB_VARCHAR;

  BEGIN

--      For logging
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'In APPLY_TRANSFORM procedure');
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'P_REQUEST_ID --->  '||P_REQUEST_ID);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'P_REQUIRED_API_CODE --->  '||P_REQUIRED_API_CODE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'P_DEPENDANT_API_CODE --->  '||P_DEPENDANT_API_CODE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'P_REQUIRED_SOURCE --->  '||P_REQUIRED_SOURCE);
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',    'p_dependant_eo_code --->  '||p_dependant_eo_code);
      END IF;
--      For logging



    V_ATTRIBUTES_HASH := GET_MAPPED_ATTRIBUTES(P_DEPENDANT_API_CODE,
                                               P_REQUIRED_API_CODE);
    --Introduced to take care of one-many mappings between mapped attributes
    SELECT REQUIRED_API_ATTRIBUTE, DEPENDANT_API_ATTRIBUTE BULK COLLECT
      INTO V_REQ_API_MAP_ATTR_NAME_LIST, V_DEP_API_MAP_ATTR_NAME_LIST
      FROM AZ_API_DEPENDENCY_ATTRIBUTES
     WHERE REQUIRED_API_CODE = P_REQUIRED_API_CODE
       AND DEPENDANT_API_CODE = P_DEPENDANT_API_CODE;

    --Introduced to take care of one-many mappings between mapped attributes
    IF V_ATTRIBUTES_HASH.COUNT <> 0 THEN
        SELECT ID BULK COLLECT
          INTO V_PARENT_ID_LIST
          FROM AZ_DIFF_RESULTS
        WHERE REQUEST_ID = P_REQUEST_ID
           AND SOURCE = P_REQUIRED_SOURCE
           AND IS_TRANSFORMED = 'Y'
           AND PARENT_ID =1;  -- Newly added to ensure all top level VO's Childs are transformed


      SELECT count (distinct (EXTRACTVALUE(VALUE(E), '/V/B/text()')))
                  into V_CHECK_TRFM_ALL_FLAG
                    FROM AZ_DIFF_RESULTS D,
                         TABLE(XMLSEQUENCE(EXTRACT(D.ATTR_DIFF, '/H/V'))) E
                   WHERE D.REQUEST_ID = P_REQUEST_ID
                     AND D.SOURCE = P_REQUIRED_SOURCE
                     AND D.IS_TRANSFORMED = 'Y'
                     AND D.TYPE <> -1
                     AND existsNode(VALUE(E),'/V[@A2="Y"]') = 1;

--      For logging
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_CHECK_TRFM_ALL_FLAG -->  ' || V_CHECK_TRFM_ALL_FLAG);
      END IF;
--      For logging

      ---
      IF V_CHECK_TRFM_ALL_FLAG >1
      THEN
              SELECT ID BULK COLLECT
                INTO V_PARENT_ID_LIST
                FROM AZ_DIFF_RESULTS
              WHERE REQUEST_ID = P_REQUEST_ID
                 AND SOURCE = P_REQUIRED_SOURCE
                 AND IS_TRANSFORMED = 'Y'
                 AND PARENT_ID =1 ;  -- Newly added to ensure all top level VO's Childs are transformed
      ELSE

      --Smart optimization -- need not iterate all the parents in case of a transform all case
              SELECT ID BULK COLLECT
                INTO V_PARENT_ID_LIST
                FROM AZ_DIFF_RESULTS
              WHERE REQUEST_ID = P_REQUEST_ID
                 AND SOURCE = P_REQUIRED_SOURCE
                 AND IS_TRANSFORMED = 'Y'
                 AND PARENT_ID =1 and rownum < 2;
      END IF;


        FOR I IN 1 .. V_PARENT_ID_LIST.COUNT LOOP
            SELECT EXTRACTVALUE(VALUE(E), '/V/@N'),
                   EXTRACTVALUE(VALUE(E), '/V/B/text()'),
                   EXTRACTVALUE(VALUE(E), '/V/A/text()') BULK COLLECT
              INTO V_REQ_API_ATTR_NAME_LIST,
                   V_REQ_API_ATTR_NEW_VALUE_LIST,
                   V_REQ_API_ATTR_OLD_VALUE_LIST
              FROM AZ_DIFF_RESULTS D,
                   TABLE(XMLSEQUENCE(EXTRACT(D.ATTR_DIFF, '/H/V'))) E
             WHERE D.REQUEST_ID = P_REQUEST_ID
               AND D.SOURCE = P_REQUIRED_SOURCE
               AND D.IS_TRANSFORMED = 'Y'
               AND D.ID = V_PARENT_ID_LIST(I)
               AND D.TYPE <> -1
               AND existsNode(VALUE(E),'/V[@A2="Y"]') = 1;


          V_CHILD_XSL_STRING        := '';
          V_EXISTSNODE_STRING := '(';
          V_EXISTSNODE_NAMEVAL_STR := ' AND (';

          --lmathur adding the XSL to update T=1 for attributes which are marked as 'conflicting' for user to edit
          V_CONFLICT_XSL := '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:template match="H">
                  <H>
                          <xsl:for-each select="V">
                                  <V>
                                    <xsl:copy-of select="@*[not(name()= ''''T'''' or name()=''''A1'''')]"/>
                                          <xsl:choose>';
-- LMATHUR - added the copy-of for optimizing the stylesheet, need not copy all the attributes

--- Change to remove the excess table xmlsequence
          V_DEPENDANT_IDS_SQL := 'SELECT q.id FROM AZ_DIFF_RESULTS q ';
          V_DEPENDANT_IDS_SQL := V_DEPENDANT_IDS_SQL ||
                                 ' where q.request_id = ' || P_REQUEST_ID ||
                                 ' AND ';
          V_DEPENDANT_IDS_SQL := V_DEPENDANT_IDS_SQL || 'q.source = ''' ||
                                 P_DEPENDANT_SOURCE || ''' AND ';

          V_DEPENDANT_CHILD_IDS_SQL := V_DEPENDANT_IDS_SQL || '  ';

--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_REQ_API_ATTR_NAME_LIST Count -->  ' || V_REQ_API_ATTR_NAME_LIST.COUNT);
          END IF;
--      For logging

          FOR J IN 1 .. V_REQ_API_ATTR_NAME_LIST.COUNT LOOP

            BEGIN
              --      For logging
              IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For attribute name  -->  ' || V_REQ_API_ATTR_NAME_LIST(J));
              END IF;
              --      For logging

              V_REQ_API_API_ATTR_NAME   := V_REQ_API_ATTR_NAME_LIST(J);
              V_REQ_API_ATTR_NEW_VALUE  := V_REQ_API_ATTR_NEW_VALUE_LIST(J);
              V_REQ_API_ATTR_OLD_VALUE  := V_REQ_API_ATTR_OLD_VALUE_LIST(J);

              V_DEPENDANT_API_ATTR_NAME := V_ATTRIBUTES_HASH(V_REQ_API_API_ATTR_NAME);

              V_DEPENDANT_IDS_SQL :=  V_DEPENDANT_IDS_SQL||' ( ';

              --      For logging
              IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_REQ_API_MAP_ATTR_NAME_LIST Count -->  ' || V_REQ_API_MAP_ATTR_NAME_LIST.COUNT);
              END IF;
              --      For logging

              --Introduced to take care of one-many mappings between mapped attributes
              FOR K IN 1 .. V_REQ_API_MAP_ATTR_NAME_LIST.COUNT LOOP
              BEGIN

                IF  V_REQ_API_MAP_ATTR_NAME_LIST(K) = V_REQ_API_API_ATTR_NAME

                THEN
                  V_DEPENDANT_API_ATTR_NAME := V_DEP_API_MAP_ATTR_NAME_LIST(K);
                V_DEPENDANT_IDS_SQL       := V_DEPENDANT_IDS_SQL ||
                                             ' existsnode(q.attr_diff, ''/H/V[@N="' ||
                                             V_DEPENDANT_API_ATTR_NAME ||
                                             '"]/A[.="' ||
                                             V_REQ_API_ATTR_OLD_VALUE ||
                                             '"]/text()'')=1 OR ';

                V_CHILD_XSL_STRING :=       V_CHILD_XSL_STRING ||
                                             ' <xsl:when test="@N=''''' ||
                                             V_DEPENDANT_API_ATTR_NAME ||
                                             ''''' and ./B=''''' ||V_REQ_API_ATTR_OLD_VALUE||'''''">';
                V_CHILD_XSL_STRING :=        V_CHILD_XSL_STRING ||'<xsl:attribute name="A2">Y</xsl:attribute><xsl:copy-of select ="A"/> <xsl:element name="B">'||
                                             V_REQ_API_ATTR_NEW_VALUE ||
                                             '</xsl:element></xsl:when> ';

                V_EXISTSNODE_STRING       := V_EXISTSNODE_STRING||
                                            ' existsnode(q.attr_diff, ''/H/V[@N!="' ||
                                             V_DEPENDANT_API_ATTR_NAME ||
                                             '"]/B[.="' ||
                                             V_REQ_API_ATTR_OLD_VALUE ||
                                             '"]'')=1 OR ';

                V_EXISTSNODE_NAMEVAL_STR       := V_EXISTSNODE_NAMEVAL_STR||
                                            ' existsnode(e.attr_diff, ''/H/V[@N="' ||
                                             V_DEPENDANT_API_ATTR_NAME ||
                                             '"]/B[.="' ||
                                             V_REQ_API_ATTR_OLD_VALUE ||
                                             '"]'')=1 OR ';


                --construct the conflict XSL here
                V_CONFLICT_XSL       := V_CONFLICT_XSL||
                                            ' <xsl:when test="@N!='''''||V_DEPENDANT_API_ATTR_NAME||''''' and ./B/text()='''''||V_REQ_API_ATTR_OLD_VALUE||''''' "> '
                                            ||'    <xsl:attribute name="T">1</xsl:attribute>'
                                            ||'    <xsl:attribute name="A1">Y</xsl:attribute>'
                                            ||'</xsl:when>';
                END IF;
              END;
              END LOOP;
            V_DEPENDANT_IDS_SQL := V_DEPENDANT_IDS_SQL||' (1=0) ) AND ';

            EXCEPTION
              WHEN NO_DATA_FOUND THEN

                IF V_REQ_API_ATTR_NEW_VALUE <> V_REQ_API_ATTR_OLD_VALUE
                THEN
                  V_EXISTSNODE_STRING       := V_EXISTSNODE_STRING||
                                               ' existsnode(q.attr_diff, ''/H/V/B[.="' ||
                                               V_REQ_API_ATTR_OLD_VALUE ||
                                              '"]'')=1 OR ';

                  V_EXISTSNODE_NAMEVAL_STR       := V_EXISTSNODE_NAMEVAL_STR||
                                          ' existsnode(e.attr_diff, ''/H/V[@N="' ||
                                           V_REQ_API_API_ATTR_NAME ||
                                           '"]/B[.="' ||
                                           V_REQ_API_ATTR_OLD_VALUE ||
                                           '"]'')=1 OR ';
                  ---LMATHUR -- need not mark the attributes as Conflicting and transformable unless the value is different
                  -- putting it outside the IF was resulting in excess attributes being marked as Conflicting and transformable
                   V_CONFLICT_XSL            := V_CONFLICT_XSL||
                   '    <xsl:when test="./B/text()='''''||V_REQ_API_ATTR_OLD_VALUE||''''' ">
                                                    <xsl:attribute name="T">1</xsl:attribute>
                                  <xsl:attribute name="A1">Y</xsl:attribute>
                                            </xsl:when>';

              V_CHILD_XSL_STRING :=       V_CHILD_XSL_STRING ||
                                           ' <xsl:when test="@N=''''' ||
                                           V_REQ_API_API_ATTR_NAME ||
                                           '''''and ./B=''''' ||V_REQ_API_ATTR_OLD_VALUE||'''''">';
              V_CHILD_XSL_STRING :=        V_CHILD_XSL_STRING ||'<xsl:attribute name="A2">Y</xsl:attribute><xsl:copy-of select ="A"/> <xsl:element name="B">'||
                                           V_REQ_API_ATTR_NEW_VALUE ||
                                           '</xsl:element></xsl:when> ';

              END IF;

            END;
          END LOOP;



        IF V_REQ_API_ATTR_NAME_LIST.COUNT=0
        THEN
            V_EXISTSNODE_STRING := '';

            -- New changes for the single attribute transformation
           V_CONFLICT_XSL   := '';

        ELSE
            V_EXISTSNODE_STRING       := V_EXISTSNODE_STRING|| ' 1<>1 ) AND ';


            V_CONFLICT_XSL            := V_CONFLICT_XSL||
                                       ' <xsl:otherwise>
                                          <xsl:attribute name="T"><xsl:value-of select="@T"/></xsl:attribute>
                                        </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:copy-of  select="A"/>
                                        <xsl:copy-of select="B"/>
                                        </V>
                                        </xsl:for-each>
                                        </H>
                                        </xsl:template>
                                        </xsl:stylesheet>';

        END IF;

        --V_DEPENDANT_IDS_SQL := V_DEPENDANT_IDS_SQL||' 1=1 ';
        V_DEPENDANT_IDS_SQL := V_DEPENDANT_IDS_SQL||' 1=1 AND PARENT_ID=1 ';

--      For logging
        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_DEPENDANT_IDS_SQL -->  ' || V_DEPENDANT_IDS_SQL);
        END IF;
--      For logging

        EXECUTE IMMEDIATE V_DEPENDANT_IDS_SQL BULK COLLECT
          INTO V_DEPENDANT_IDS_LIST;

--      For logging
        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_DEPENDANT_IDS_LIST Count -->  ' || V_DEPENDANT_IDS_LIST.COUNT);
        END IF;
--      For logging

        V_EXISTSNODE_NAMEVAL_STR := V_EXISTSNODE_NAMEVAL_STR|| ' 1<>1 )';

        FOR K IN 1 .. V_DEPENDANT_IDS_LIST.COUNT LOOP
--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For V_DEPENDANT_IDS_LIST(K)-->  ' || V_DEPENDANT_IDS_LIST(K));
          END IF;
--      For logging
          V_TRANSFORM_SQL := GET_TRANSFORM_SQL(P_REQUEST_ID,
                                               P_DEPENDANT_SOURCE,
                                               V_CHILD_XSL_STRING,
                                               V_DEPENDANT_IDS_LIST(K),'Y');



          V_TRANSFORM_SQL := V_TRANSFORM_SQL||V_EXISTSNODE_NAMEVAL_STR;

--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_TRANSFORM_SQL -->  ' || V_TRANSFORM_SQL);
          END IF;
--      For logging

          EXECUTE IMMEDIATE V_TRANSFORM_SQL;

          v_dml_count := v_dml_count + 1;


          V_DEP_DETAIL_CHILD_IDS_SQL := '  q.parent_id in' ;
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                              (' ;
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                select id from' ;
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                (';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                   select id, parent_id from ';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                   (';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                       SELECT d.id id,';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                       d.parent_id parent_id';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                       FROM az_diff_results d ';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                       WHERE d.request_id = ' || p_request_id ;
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                      AND d.source = '''|| P_DEPENDANT_SOURCE || '''';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                    ) f START WITH f.id = ' || V_DEPENDANT_IDS_LIST(K) || ' CONNECT BY PRIOR f.id = f.parent_id';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                                  )';
          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEP_DETAIL_CHILD_IDS_SQL ||  '                              )';


          V_DEP_DETAIL_CHILD_IDS_SQL := V_DEPENDANT_CHILD_IDS_SQL || V_DEP_DETAIL_CHILD_IDS_SQL;

--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_DEP_DETAIL_CHILD_IDS_SQL -->  ' || V_DEP_DETAIL_CHILD_IDS_SQL);
          END IF;
--      For logging

          EXECUTE IMMEDIATE V_DEP_DETAIL_CHILD_IDS_SQL BULK COLLECT
            INTO V_DEPENDANT_CHILD_IDS_LIST;
--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_DEPENDANT_CHILD_IDS_LIST Count -->  ' || V_DEPENDANT_CHILD_IDS_LIST.COUNT);
          END IF;
--      For logging
            FOR Z IN 1 .. V_DEPENDANT_CHILD_IDS_LIST.COUNT LOOP
--      For logging
            IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For V_DEPENDANT_CHILD_IDS_LIST(Z)-->  ' || V_DEPENDANT_CHILD_IDS_LIST(Z));
            END IF;
--      For logging
              V_TRANSFORM_SQL := GET_TRANSFORM_SQL(P_REQUEST_ID,
                                                   P_DEPENDANT_SOURCE,
                                                   V_CHILD_XSL_STRING,
                                                   V_DEPENDANT_CHILD_IDS_LIST(Z),'N');
--      For logging
              IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'V_TRANSFORM_SQL  -->  ' || V_TRANSFORM_SQL);
              END IF;
--      For logging

              EXECUTE IMMEDIATE V_TRANSFORM_SQL;
            END LOOP;

          IF length(V_CONFLICT_XSL)>0
          THEN
          V_TEMP_SQL := 'UPDATE az_diff_results q SET param3 = ''Y'', q.attr_diff = q.attr_diff.transform(xmltype('''||V_CONFLICT_XSL||''')).createSchemaBasedXml(''' ||
                                DIFF_SCHEMA_URL || ''') WHERE '|| ' q.id = ' || V_DEPENDANT_IDS_LIST(K)
                                 ||' AND q.request_id = '||P_REQUEST_ID||
                                ' AND ' || V_EXISTSNODE_STRING || ' q.source = '''||p_dependant_source||'''';

--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For V_DEPENDANT_IDS_LIST(K) --> ' || V_DEPENDANT_IDS_LIST(K)||'V_TEMP_SQL   -->  ' || V_TEMP_SQL);
          END IF;
--      For logging


          EXECUTE IMMEDIATE  V_TEMP_SQL;

          select id BULK collect into V_CONFLICT_CHILD_IDS_LIST from (select id,parent_id from (SELECT d.id id,
                 d.parent_id parent_id
                 FROM az_diff_results d
                 WHERE d.request_id = P_REQUEST_ID
                AND d.source = p_dependant_source
              ) f START WITH f.id =  V_DEPENDANT_IDS_LIST(K) CONNECT BY PRIOR f.id = f.parent_id) ;
  --      For logging
            IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For V_DEPENDANT_IDS_LIST(K) --> ' || V_DEPENDANT_IDS_LIST(K)||'V_CONFLICT_CHILD_IDS_LIST.COUNT   -->  ' || V_CONFLICT_CHILD_IDS_LIST.COUNT);
            END IF;
  --      For logging

            FOR Y IN 1 .. V_CONFLICT_CHILD_IDS_LIST.COUNT LOOP
              V_TEMP_SQL :='UPDATE az_diff_results q SET param3 = ''Y'', q.attr_diff = q.attr_diff.transform(xmltype('''||V_CONFLICT_XSL||''')).createSchemaBasedXml(''' ||
                                  DIFF_SCHEMA_URL || ''') WHERE '|| ' q.id = ' || V_CONFLICT_CHILD_IDS_LIST(Y)
                                   ||'  AND q.request_id = '||P_REQUEST_ID||
                                  ' AND '|| V_EXISTSNODE_STRING || ' q.source = '''||p_dependant_source||'''';

      --      For logging
                IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,   c_log_head || 'APPLY_TRANSFORM :  ',   'For  V_CONFLICT_CHILD_IDS_LIST(Y) --> ' ||  V_CONFLICT_CHILD_IDS_LIST(Y)||'  V_TEMP_SQL   -->  ' || V_TEMP_SQL);
                END IF;
      --      For logging


              EXECUTE IMMEDIATE  V_TEMP_SQL;
            END LOOP;

            END IF; -- no need to do this if V_CONFLICT_XSL is zero length


          IF MOD(v_dml_count,
                 commit_batch_size) = 0 THEN
            COMMIT;
          END IF;
        END LOOP;

--        select id bulk collect into v_child_id_list
--        from az_diff_results where request_id=p_request_id and source=P_DEPENDANT_SOURCE
--        and param2 ='Y';
--        -- Now we need to update the master is_transformed flag for the changed child records
--        update_master_flag(p_request_id,P_DEPENDANT_SOURCE,'IS_TRANSFORMED',v_child_id_list,'N');
--        --update the param2 for the entire tree to denote the transformed records
--        update_master_flag(p_request_id,P_DEPENDANT_SOURCE,'PARAM2',v_child_id_list,'Y');
      END LOOP;

      IF V_PARENT_ID_LIST.COUNT >0
      then
          UPDATE_REGEN_REQD(P_REQUEST_ID, P_DEPENDANT_eo_code, p_dependant_source);
      END IF;
      IF length(V_EXISTSNODE_STRING) > 0
      THEN
        -- LMATHUR -> update T=1 for all the attributes which can be marked as conflicting so that they can be edited from the UI

--Redundancy removal
        -- LMATHUR -> Now Update the AZ_REQUESTS selection_set XML to ensure that the conflicted attributes are open for editing
--        select count(1) into V_CONFLICT_PARAM3_COUNT from az_diff_results d where d.param3 = 'Y' and
--        d.request_id = P_REQUEST_ID
--        and d.source=p_dependant_source;
--
--        IF V_CONFLICT_PARAM3_COUNT > 0
--        THEN
--            --LMATHUR - To show conflict icon in the VIEW mode, we need an indicator for conflicts- A5=C indicate conflicts
--            EXECUTE IMMEDIATE  'UPDATE az_requests d
--                                SET d.selection_set = updatexml(d.selection_set,   ''/EXT/H[S="'||p_dependant_source||'"]/@A5'',''C'')
--                                WHERE d.request_id = '||P_REQUEST_ID||
--                                ' AND d.request_type = ''T''';
--
--        END IF;

        select id bulk collect into v_child_id_list
        from az_diff_results where request_id=p_request_id and source=P_DEPENDANT_SOURCE
        and param3 ='Y';

        -- LMATHUR -Now we need to update the entire tree's param3 flag which are having conflicts in childs
        update_master_flag(p_request_id,P_DEPENDANT_SOURCE,'PARAM3',v_child_id_list,'Y');

        --LMATHUR and HBODA -- Changes to update the Conflict status in the selection Set XML so as to be used in UI
        update_conflict_status(p_request_id,P_DEPENDANT_SOURCE);

        COMMIT;
      END IF;


    END IF; -- IF V_ATTRIBUTES_HASH.COUNT <> 0 closes

  EXCEPTION
    WHEN APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      RAISE_ERROR_MSG(SQLCODE, SQLERRM, 'APPLY_TRANSFORM', 'procedure end');
  END APPLY_TRANSFORM;

  PROCEDURE UPDATE_REGEN_REQD(P_REQUEST_ID       IN NUMBER,
                                                P_DEPENDANT_eo_code IN VARCHAR2,
                                                p_dependant_source IN VARCHAR2) IS
    V_AUTO_SELECTED VARCHAR2(1);
    V_EO_CODE       VARCHAR2(4000);
    V_REF_EO_CODE   VARCHAR2(4000);
    v_count NUMBER;
  BEGIN

    SELECT EXTRACTVALUE(VALUE(E), '/H/@A2')
      INTO V_AUTO_SELECTED
      FROM AZ_REQUESTS D,
           TABLE(XMLSEQUENCE(EXTRACT(D.SELECTION_SET,
                                     '/EXT/H/V[@N="EntityOccuranceCode" and .="' || P_DEPENDANT_eo_code || '"]/..'))) E
     WHERE D.REQUEST_ID = P_REQUEST_ID
       AND D.REQUEST_TYPE = 'T';


   SELECT COUNT(*)
   INTO v_count
   FROM az_diff_results
     WHERE REQUEST_ID = P_REQUEST_ID
       AND SOURCE = p_dependant_source
       AND is_transformed='Y';

    IF v_count>0 THEN

      UPDATE AZ_REQUESTS D
         SET D.SELECTION_SET = UPDATEXML(D.SELECTION_SET,
                                         '/EXT/H[S="'||P_DEPENDANT_SOURCE||'"]/T/text()',v_count)
       WHERE D.REQUEST_ID = P_REQUEST_ID
         AND d.REQUEST_TYPE = 'T';
    END IF;


    IF V_AUTO_SELECTED = 'Y' AND v_count>0 THEN


      UPDATE AZ_REQUESTS D
         SET D.SELECTION_SET = UPDATEXML(D.SELECTION_SET,
                                         '/EXT/H/V[@N="EntityOccuranceCode" and .="' || P_DEPENDANT_eo_code || '"]/../@A4', 'Y')
       WHERE D.REQUEST_ID = P_REQUEST_ID
         AND D.REQUEST_TYPE = 'T';

    ELSIF  V_AUTO_SELECTED <> 'Y' AND v_count>0 THEN
      SELECT EXTRACTVALUE(VALUE(E), '/H/V[@N="EntityOccuranceCode"]/text()'),
             EXTRACTVALUE(VALUE(E), '/H/V[@N="RefEntityOccuranceCode"]/text()')
        INTO V_EO_CODE, V_REF_EO_CODE
        FROM AZ_REQUESTS D,
             TABLE(XMLSEQUENCE(EXTRACT(D.SELECTION_SET,
                                       '/EXT/H/V[@N="EntityOccuranceCode" and .="' || P_DEPENDANT_eo_code || '"]/..'))) E
       WHERE D.REQUEST_ID = P_REQUEST_ID
         AND D.REQUEST_TYPE = 'T';

      LOOP
        BEGIN
          SELECT EXTRACTVALUE(VALUE(E),
                              '/H/V[@N="EntityOccuranceCode"]/text()'),
                 EXTRACTVALUE(VALUE(E),
                              '/H/V[@N="RefEntityOccuranceCode"]/text()'),
                 EXTRACTVALUE(VALUE(E), '/H/@A2')
            INTO V_EO_CODE, V_REF_EO_CODE, V_AUTO_SELECTED
            FROM AZ_REQUESTS D,
                 TABLE(XMLSEQUENCE(EXTRACT(D.SELECTION_SET,
                                           '/EXT/H/V[@N="EntityOccuranceCode" and .="' ||
                                           V_REF_EO_CODE || '"]/..'))) E
           WHERE D.REQUEST_ID = P_REQUEST_ID
             AND D.REQUEST_TYPE = 'T';


          IF V_AUTO_SELECTED = 'Y' THEN


            UPDATE AZ_REQUESTS D
               SET D.SELECTION_SET = UPDATEXML(D.SELECTION_SET,
                                               '/EXT/H/V[@N="EntityOccuranceCode" and .="' ||
                                               V_EO_CODE || '"]/../@A4',
                                               'Y')
             WHERE D.REQUEST_ID = P_REQUEST_ID
               AND D.REQUEST_TYPE = 'T';
            EXIT;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      RAISE_ERROR_MSG(SQLCODE, SQLERRM, 'UPDATE_REGEN_REQD', 'procedure end');
  END UPDATE_REGEN_REQD;

  FUNCTION GET_MAPPED_ATTRIBUTES(P_DEPENDANT_API_CODE IN VARCHAR2,
                                 P_REQUIRED_API_CODE  IN VARCHAR2)
    RETURN TYP_ASSOC_ARR IS
    V_ATTRIBUTES_HASH   TYP_ASSOC_ARR;
    V_REQ_API_ATTR_LIST TYP_NEST_TAB_VARCHAR;
    V_DEP_API_ATTR_LIST TYP_NEST_TAB_VARCHAR;
  BEGIN

    SELECT REQUIRED_API_ATTRIBUTE, DEPENDANT_API_ATTRIBUTE BULK COLLECT
      INTO V_REQ_API_ATTR_LIST, V_DEP_API_ATTR_LIST
      FROM AZ_API_DEPENDENCY_ATTRIBUTES
     WHERE REQUIRED_API_CODE = P_REQUIRED_API_CODE
       AND DEPENDANT_API_CODE = P_DEPENDANT_API_CODE;

    FOR I IN 1 .. V_REQ_API_ATTR_LIST.COUNT LOOP
      V_ATTRIBUTES_HASH(V_REQ_API_ATTR_LIST(I)) := V_DEP_API_ATTR_LIST(I);
    END LOOP;



    RETURN V_ATTRIBUTES_HASH;
  EXCEPTION
    WHEN APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      RAISE_ERROR_MSG(SQLCODE,
                      SQLERRM,
                      'GET_MAPPED_ATTRIBUTES',
                      'procedure end');
  END;



  PROCEDURE transform_all(p_job_name        IN VARCHAR2,
                          p_request_id      IN NUMBER,
                          p_user_id         IN NUMBER,
                          p_source          IN VARCHAR2,
                          p_is_cascade      IN VARCHAR2,
                          p_diff_schema_url IN VARCHAR2) IS

    v_eo_code_list typ_nest_tab_varchar;

    v_ref_eo_code_list typ_nest_tab_varchar;

    v_source_list typ_nest_tab_varchar;

    v_attribute_name_list typ_nest_tab_varchar;

    v_child_attribute_name_list typ_nest_tab_varchar := typ_nest_tab_varchar();

   -- v_child_attribute_value_list typ_nest_tab_varchar := typ_nest_tab_varchar();

    v_attribute_value_list typ_nest_tab_varchar;

    v_entity_code_list typ_nest_tab_varchar;
    v_split_flag_list typ_nest_tab_varchar;
    v_master_ids_trans_list typ_nest_tab_varchar;

    v_transform_all_sql VARCHAR2(32767);

    v_parent_api_code VARCHAR2(255);

    v_current_api_code VARCHAR2(255);

    v_mapped_attributes_map typ_assoc_arr;

    v_child_attribute_name VARCHAR2(255);

    v_child_count NUMBER;

    --lmathur added
    V_EXISTSNODE_STRING   VARCHAR2(32767);
    V_UPDATE_XSL          CLOB := '';
    V_CHILD_ID_LIST       TYP_NEST_TAB_VARCHAR;
    V_ATTR_NAME           VARCHAR2(255);


    --Introduced to take care of one-many mappings between mapped attributes
    V_DEP_API_MAP_ATTR_NAME_LIST TYP_NEST_TAB_VARCHAR;
    V_REQ_API_MAP_ATTR_NAME_LIST TYP_NEST_TAB_VARCHAR;


  BEGIN

--      For logging
    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'In transform_all procedure ...');
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'p_job_name --->  '||p_job_name);
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'p_user_id --->  '||p_user_id);
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'p_source --->  '||p_source);
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'p_is_cascade --->  '||p_is_cascade);
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',    'p_diff_schema_url --->  '||p_diff_schema_url);
    END IF;
--      For logging

    diff_schema_url   := p_diff_schema_url;
    commit_batch_size := fnd_profile.VALUE('AZ_COMMIT_ROWCOUNT');
    v_dml_count       := 0;


    SELECT entity_occurance_code,
           ref_entity_occurance_code,
           SOURCE,
           entity_code,
           split_flag BULK COLLECT
      INTO v_eo_code_list,
           v_ref_eo_code_list,
           v_source_list,
           v_entity_code_list,
           v_split_flag_list
      FROM ( SELECT extractvalue(VALUE(e),
                                '/H/V[@N="EntityOccuranceName"]/text()'),
                   extractvalue(VALUE(e),
                                '/H/V[@N="EntityOccuranceCode"]/text()') entity_occurance_code,
                   extractvalue(VALUE(e),
                                '/H/V[@N="RefEntityOccuranceCode"]/text()') ref_entity_occurance_code,
                   extractvalue(VALUE(e),
                                '/H/V[@N="EntityCode"]/text()') entity_code,
                  extractvalue(VALUE(e),'/H/S/text()') SOURCE,
                  nvl(extractvalue(VALUE(e),'/H/@A3'),'N') split_flag

              FROM az_requests d,
                   TABLE(xmlsequence(extract(d.selection_set,
                                             '/EXT/H'))) e
             WHERE existsnode(VALUE(e),
                              '/H/V[@N="EntityOccuranceName" or @N="EntityOccuranceCode" or @N="RefEntityOccuranceCode"]') = 1
               AND
               existsnode(VALUE(e),
                              '/H[@A2="Y" or @A3="Y" or @A1="Y"]') = 1
               AND d.job_name = p_job_name
               AND d.request_type = 'T'
               AND d.user_id = p_user_id
          )
     START WITH SOURCE = p_source
    CONNECT BY PRIOR entity_occurance_code = ref_entity_occurance_code;


    SELECT extractvalue(VALUE(e),
                        '/V/@N'),
           extract(VALUE(e),
                        '/V/text()').getstringval() BULK COLLECT
      INTO v_attribute_name_list, v_attribute_value_list
      FROM az_requests d,
           TABLE(xmlsequence(extract(d.selection_set,
                                     '/EXT/H/S[.="' || p_source ||
                                     '"]/../V[@T="1"]'))) e
     WHERE job_name = p_job_name
       AND user_id = p_user_id
       AND request_type = 'T';

--      For logging
    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',   'v_eo_code_list.COUNT -->  '||v_eo_code_list.COUNT);
    END IF;
--      For logging

    FOR i IN 1 .. v_eo_code_list.COUNT
    LOOP
      IF p_source = v_source_list(i) THEN
      --This is the root source
        V_UPDATE_XSL := '';
        V_EXISTSNODE_STRING := '';

        FOR j IN 1 .. v_attribute_name_list.COUNT
        LOOP
          IF LENGTH(v_attribute_value_list(j))>0
          THEN
            IF LENGTH(V_EXISTSNODE_STRING)>0
              THEN
                 V_EXISTSNODE_STRING       := V_EXISTSNODE_STRING|| ' OR ';
            END IF;

            V_UPDATE_XSL := V_UPDATE_XSL  ||'<xsl:when test="@N='''||v_attribute_name_list(j)||'''"><xsl:attribute name = "A2">Y</xsl:attribute>
                            <xsl:copy-of select = "A"/>
                            <xsl:element name = "B">'
            ||v_attribute_value_list(j)||'</xsl:element></xsl:when>';
            V_EXISTSNODE_STRING := V_EXISTSNODE_STRING||'existsnode(e.attr_diff,''/H/V[@N="'||v_attribute_name_list(j)||'"] '')=1 ';

          END IF;
        END LOOP;

        IF LENGTH(V_UPDATE_XSL)>0
        THEN
          --LMATHUR -- added to prevent the varchar overflow for Xmltype
              V_UPDATE_XSL := '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                    <xsl:template match="H">
                      <xsl:copy>
                          <xsl:copy-of select="@*"/>
                          <xsl:apply-templates/>
                      </xsl:copy>
                    </xsl:template>
                    <xsl:template match="V">
                      <xsl:copy>
                      <xsl:copy-of select="@*[not(name()=''A2'')]"/>
                          <xsl:choose>'||V_UPDATE_XSL;

              V_UPDATE_XSL := V_UPDATE_XSL ||'<xsl:otherwise>
                                                <xsl:copy-of select="A"/><xsl:copy-of select="B"/>
                                      </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:copy>
                              </xsl:template>
                              </xsl:stylesheet>';
          v_transform_all_sql := get_transform_all_sql(
                                                     V_EXISTSNODE_STRING,
                                                     p_request_id,
                                                     v_source_list(i));

--      For logging
          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || 'transform_all :  ',   'For  -->  '||v_source_list(i)||' v_transform_all_sql --->  '||v_transform_all_sql );
          END IF;
--      For logging

          EXECUTE IMMEDIATE v_transform_all_sql using V_UPDATE_XSL;

          -- LMATHUR - now for the given source, update the IS_TRANSFORMED for the master records
          select d.id bulk collect into V_CHILD_ID_LIST
          from az_diff_results d where d.request_id=p_request_id and d.source=p_source
          and d.param2 = 'Y';
          update_master_flag(p_request_id,v_source_list(i),'IS_TRANSFORMED',v_child_id_list,'N');
        END IF;
        V_UPDATE_XSL :='';
        V_EXISTSNODE_STRING := '';
        --Now we need to mark conflicts and cascade values to the child VOs/TLs for the root source
        --mugsrin to transform all other matching attributes other than mapped attributes.
        SELECT ID bulk collect into v_master_ids_trans_list FROM AZ_DIFF_RESULTS
        WHERE REQUEST_ID = p_request_id
        AND SOURCE = p_source AND parent_id = 1;

        FOR i IN 1 .. v_master_ids_trans_list.COUNT
        LOOP

          TRANSFORM_ALL_ATTR_SOURCE(p_request_id, p_source, v_master_ids_trans_list(i), p_diff_schema_url);

        END LOOP;
      ELSE
        SELECT f.api_code
          INTO v_parent_api_code
          FROM az_requests d,
               TABLE(xmlsequence(extract(d.selection_set,
                                         '/EXT/H'))) e,
               az_structure_apis_b f
         WHERE existsnode(VALUE(e),
                          '/H/V[@N="EntityOccuranceName" or @N="EntityOccuranceCode" or @N="RefEntityOccuranceCode"]') = 1
--           AND existsnode(VALUE(e),
--                          '/H/V[@N="SelectionFlag" and .="Y"]') = 1
           AND extractvalue(VALUE(e),
                            '/H/V[@N="EntityOccuranceCode" and .="' ||
                            v_ref_eo_code_list(i) ||
                            '"]/../V[@N="EntityCode"]/text()') =
               f.entity_code
           AND extractvalue(d.selection_set,
                            '/EXT/H[N="SelectionSetsVO"]/V[@N="StructureCode"]/text()') =
               f.structure_code
           AND d.job_name = p_job_name
           AND d.request_type = 'T'
           AND d.user_id = p_user_id;
        ---here check if this is a split or an original entity
        if v_split_flag_list(i)='Y'
        then
            --Thy shalt retain thy Parent's API Code
            v_current_api_code := v_parent_api_code;
        else

              SELECT f.api_code
                  INTO v_current_api_code
                  FROM az_requests d,
                       TABLE(xmlsequence(extract(d.selection_set,
                                                 '/EXT/H'))) e,
                       az_structure_apis_b f
                 WHERE existsnode(VALUE(e),
                                  '/H/V[@N="EntityOccuranceName" or @N="EntityOccuranceCode" or @N="RefEntityOccuranceCode"]') = 1
--                   AND existsnode(VALUE(e),
--                                  '/H/V[@N="SelectionFlag" and .="Y"]') = 1
                   AND extractvalue(VALUE(e),
                                    '/H/V[@N="EntityOccuranceCode" and .="' ||
                                    v_eo_code_list(i) ||
                                    '"]/../V[@N="EntityCode"]/text()') =
                       f.entity_code
                   AND extractvalue(d.selection_set,
                                    '/EXT/H[N="SelectionSetsVO"]/V[@N="StructureCode"]/text()') =
                       f.structure_code
                   AND d.job_name = p_job_name
                   AND d.request_type = 'T'
                   AND d.user_id = p_user_id;

        end if;
                v_mapped_attributes_map := get_mapped_attributes(v_current_api_code,
                                                                 v_parent_api_code);
                v_child_attribute_name_list.TRIM(v_child_attribute_name_list.COUNT);
                v_child_count := 1;
        if v_mapped_attributes_map.COUNT>0
        then

        --Introduced to take care of one-many mappings between mapped attributes
        SELECT REQUIRED_API_ATTRIBUTE, DEPENDANT_API_ATTRIBUTE BULK COLLECT
          INTO V_REQ_API_MAP_ATTR_NAME_LIST, V_DEP_API_MAP_ATTR_NAME_LIST
          FROM AZ_API_DEPENDENCY_ATTRIBUTES
         WHERE REQUIRED_API_CODE = v_parent_api_code
           AND DEPENDANT_API_CODE = v_current_api_code;


                FOR j IN 1 .. v_attribute_name_list.COUNT
                LOOP
                  BEGIN
                    v_attr_name := v_attribute_name_list(j);
                    v_child_attribute_name := v_mapped_attributes_map(v_attr_name);

                    --Introduced to take care of one-many mappings between mapped attributes
                    FOR K IN 1 .. V_REQ_API_MAP_ATTR_NAME_LIST.COUNT LOOP
                      BEGIN
                            IF  V_REQ_API_MAP_ATTR_NAME_LIST(K) = v_attr_name

                            THEN
                                v_child_attribute_name_list.EXTEND;

                                v_child_attribute_name_list(v_child_count) := V_DEP_API_MAP_ATTR_NAME_LIST(K);

                                -- LMATHUR - for each of the mapped attribute get the set of values and construct the condition string
                                IF LENGTH(v_attribute_value_list(j))>0
                                THEN
                                  UPDATE_XSL_EXISTSNODE_STR(p_request_id, v_ref_eo_code_list(i), v_child_attribute_name_list(v_child_count),v_attribute_value_list(j), v_attribute_name_list(j), V_UPDATE_XSL,V_EXISTSNODE_STRING);
                                END IF;
                                v_child_count := v_child_count + 1;

                            END IF;
                      END;
                    END LOOP;

                  EXCEPTION
                    WHEN no_data_found THEN
                    ---LMATHUR - For Non-mapped attributes
                    IF LENGTH(v_attribute_value_list(j))>0
                    THEN
                      UPDATE_XSL_EXISTSNODE_STR(p_request_id, v_ref_eo_code_list(i), v_attribute_name_list(j),v_attribute_value_list(j),v_attribute_name_list(j), V_UPDATE_XSL,V_EXISTSNODE_STRING);
                    END IF;
                      --NULL;
                  END;
                END LOOP;
        IF LENGTH(V_UPDATE_XSL)>0
        THEN
                V_UPDATE_XSL := '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:template match="H">
                  <xsl:copy>
                      <xsl:copy-of select="@*"/>
                      <xsl:apply-templates/>
                  </xsl:copy>
                </xsl:template>
                <xsl:template match="V">
                  <xsl:copy>
                  <xsl:copy-of select="@*[not(name()=''A2'')]"/>
                      <xsl:choose>'||V_UPDATE_XSL;

                V_UPDATE_XSL := V_UPDATE_XSL ||'<xsl:otherwise>
                                                  <xsl:copy-of select="A"/><xsl:copy-of select="B"/>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                  </xsl:copy>
                                </xsl:template>
                                </xsl:stylesheet>';
          v_transform_all_sql := get_transform_all_sql(
                                                     V_EXISTSNODE_STRING,
                                                     p_request_id,
                                                     v_source_list(i));

          EXECUTE IMMEDIATE v_transform_all_sql using V_UPDATE_XSL;


          -- LMATHUR - now for the given source, update the IS_TRANSFORMED for the master records
          select d.id bulk collect into V_CHILD_ID_LIST
          from az_diff_results d where d.request_id=p_request_id and d.source=v_source_list(i)
          and d.param2 = 'Y';
          update_master_flag(p_request_id,v_source_list(i),'IS_TRANSFORMED',v_child_id_list,'N');

        END IF;
        V_UPDATE_XSL :='';
        V_EXISTSNODE_STRING := '';

        end if;
      END IF;

      update_regen_reqd(p_request_id,
                        v_eo_code_list(i),
                        v_source_list(i));

    END LOOP;

    COMMIT;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg(SQLCODE,
                      SQLERRM,
                      'transform_all',
                      'procedure end');

  END transform_all;

-- LMATHUR added - procedure to update the XSL String construction and modify the ExistsNode String while taking into consideration
--- the set of values for that attribute in the Parent.

  PROCEDURE UPDATE_XSL_EXISTSNODE_STR ( P_REQUEST_ID       IN NUMBER,
                             P_SOURCE IN VARCHAR2,
                             P_ATTR_NAME IN VARCHAR2,
                             P_ATTR_NEW_VALUE IN VARCHAR2,
                             P_PARENT_ATTR_NAME IN VARCHAR2,
                             P_UPDATE_XSL IN OUT NOCOPY VARCHAR2,
                             P_EXISTSNODE_STRING IN OUT NOCOPY VARCHAR2) IS

  v_child_attribute_value_list typ_nest_tab_varchar := typ_nest_tab_varchar();
  BEGIN
                      IF LENGTH(P_EXISTSNODE_STRING)>0
                        THEN
                          P_EXISTSNODE_STRING := P_EXISTSNODE_STRING|| ' OR ';
                      END IF;

                      P_UPDATE_XSL := P_UPDATE_XSL  ||'<xsl:when test="@N='''||p_attr_name||''' "><xsl:attribute name = "A2">Y</xsl:attribute>
                            <xsl:copy-of select = "A"/>
                            <xsl:element name = "B">'
                      ||P_ATTR_NEW_VALUE||'</xsl:element></xsl:when>';
                      P_EXISTSNODE_STRING := P_EXISTSNODE_STRING||'existsnode(e.attr_diff,''/H/V[@N="'||p_attr_name||'" ] '')=1 ';


  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      NULL;


  END UPDATE_XSL_EXISTSNODE_STR;

  FUNCTION GET_TRANSFORM_SQL(P_REQUEST_ID       IN NUMBER,
                             P_DEPENDANT_SOURCE IN VARCHAR2,
                             P_XSL_STRING       IN VARCHAR2,
                             P_PARENT_ID        IN NUMBER,
                             P_MASTER_FLAG IN VARCHAR2 ) RETURN VARCHAR2 IS
    V_TRANSFORM_SQL VARCHAR2(32767);
  BEGIN
    V_TRANSFORM_SQL := V_TRANSFORM_SQL ||
                       'update az_diff_results e set e.param2 = ''Y'',';

    IF P_MASTER_FLAG = 'Y'
    THEN
      V_TRANSFORM_SQL := V_TRANSFORM_SQL ||' IS_TRANSFORMED = ''Y'',';
    END IF;
    V_TRANSFORM_SQL := V_TRANSFORM_SQL ||' e.attr_diff = (select d.attr_diff.transform( xmltype(''<?xml version="1.0" ?> ';

    V_TRANSFORM_SQL := V_TRANSFORM_SQL ||
                       ' <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '   <xsl:template match="H"> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '       <H> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL ||
                       '           <xsl:for-each select="V"> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '           <V> ';

    v_transform_sql := v_transform_sql || '            <xsl:copy-of select="@*[not(name()=''''T'''' or name()=''''A2'''')]"/> ';
    v_transform_sql := v_transform_sql || '            <xsl:attribute name="T"> ';
    v_transform_sql := v_transform_sql || '                0 ';
    v_transform_sql := v_transform_sql || '            </xsl:attribute> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '          <xsl:choose> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || P_XSL_STRING;
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '        <xsl:otherwise> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL ||
                       '      <xsl:copy-of select ="A"/> <xsl:copy-of select ="B"/>';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '              </xsl:otherwise> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '        </xsl:choose> ';
  --  V_TRANSFORM_SQL := V_TRANSFORM_SQL || '        </B> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '    </V> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' </xsl:for-each> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '       </H> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || '   </xsl:template> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' </xsl:stylesheet> ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' '')).createSchemaBasedXml(''' ||
                       DIFF_SCHEMA_URL || ''')';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' from az_diff_results d  ';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' where d.request_id = ' ||
                       P_REQUEST_ID;
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' AND d.source = ''' ||
                       P_DEPENDANT_SOURCE || '''';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' and d.id = ' || P_PARENT_ID || ')';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' where e.request_id = ' ||
                       P_REQUEST_ID;
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' AND e.source = ''' ||
                       P_DEPENDANT_SOURCE || '''';
    V_TRANSFORM_SQL := V_TRANSFORM_SQL || ' AND e.id = ' || P_PARENT_ID;
    RETURN V_TRANSFORM_SQL;
  EXCEPTION
    WHEN APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
      RAISE_ERROR_MSG(SQLCODE,
                      SQLERRM,
                      'GET_TRANSFORM_SQL',
                      'procedure end');
  END;

  PROCEDURE raise_error_msg(errcode IN NUMBER,   errmsg IN VARCHAR2,   procedurename IN VARCHAR2,   statement IN VARCHAR2) IS

  v_message VARCHAR2(2048);

  BEGIN

    IF(fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
      fnd_message.set_name('AZ',   'AZ_R12_PLSQL_EXCEPTION');
      -- Seeded Message
      -- Runtime Information
      fnd_message.set_token('ERROR_CODE',   errcode);
      fnd_message.set_token('ERROR_MESG',   errmsg);
      fnd_message.set_token('ERROR_PROC',   'az_r12_transform_cascade.' || procedurename);

      IF(statement IS NOT NULL) THEN
        fnd_message.set_token('ERROR_STMT',   statement);
      ELSE
        fnd_message.set_token('ERROR_STMT',   'none');
      END IF;

      raise_application_error(-20001,   fnd_message.GET);
    END IF;

  END raise_error_msg;

  FUNCTION get_transform_all_sql(
                                 P_EXISTSNODE_STRING IN VARCHAR2,
                                 p_request_id           IN NUMBER,
                                 p_source               IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_transform_all_sql VARCHAR2(32767);
  BEGIN
   v_transform_all_sql := 'update az_diff_results e set e.param2 = ''Y'', e.attr_diff =e.attr_diff.transform( xmltype(:1';


    v_transform_all_sql := v_transform_all_sql ||
                           ')).createSchemaBasedXml(''' || diff_schema_url ||
                           ''')';
    v_transform_all_sql := v_transform_all_sql || ' where  e.request_id = ' ||
                           p_request_id || ' AND e.source ='''|| p_source ||''' and ('||P_EXISTSNODE_STRING||')';

    RETURN v_transform_all_sql;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg(SQLCODE,
                      SQLERRM,
                      'get_transform_all_sql',
                      'procedure end');

  END get_transform_all_sql;



--lmathur added
-- procedure to modify the attributes in the Child VOs of the Root Source based on the same attribute and value being present
-- This fixes the issue where the same attribute name-value is not transformed in the TL or child records for a given source
  -- Function and procedure implementations
  PROCEDURE TRANSFORM_ALL_ATTR_SOURCE(P_REQUEST_ID  IN NUMBER,
                            P_SOURCE IN VARCHAR2,
                            P_ID NUMBER,
                            p_diff_schema_url IN VARCHAR2) IS
  v_child_id_list TYP_NEST_TAB_VARCHAR;
  v_attr_name_list TYP_NEST_TAB_VARCHAR;
  v_attr_old_value_list TYP_NEST_TAB_VARCHAR;
  v_attr_new_value_list TYP_NEST_TAB_VARCHAR;
  V_EXISTSNODE_STRING           VARCHAR2(32767);
  V_CONFLICT_XSL                VARCHAR2(32767);
  V_CONFLICT_PARAM3_COUNT NUMBER;
  V_QUERY_STR VARCHAR2(32767);

  BEGIN


             SELECT EXTRACTVALUE(VALUE(E), '/V/@N'),
                   EXTRACTVALUE(VALUE(E), '/V/B/text()'),
                   EXTRACTVALUE(VALUE(E), '/V/A/text()') BULK COLLECT
              INTO v_attr_name_list,
                   v_attr_new_value_list,
                   v_attr_old_value_list
              FROM AZ_DIFF_RESULTS D,
                   TABLE(XMLSEQUENCE(EXTRACT(D.ATTR_DIFF, '/H/V'))) E
             WHERE D.REQUEST_ID = p_request_id
               AND D.SOURCE = p_source
               AND D.param2 = 'Y'
               AND D.ID = P_ID
               AND D.TYPE <> -1
               AND existsNode(VALUE(E),'/V[@A2="Y"]') = 1;


            -- populate the list of child VO IDs

            SELECT id BULK COLLECT INTO v_child_id_list
            FROM
              (SELECT d.id id,
                 d.parent_id parent_id
               FROM az_diff_results d
               WHERE d.request_id = p_request_id
               AND d.source = p_source)
            f START WITH f.id = P_ID CONNECT BY PRIOR f.id = f.parent_id
            ORDER BY f.parent_id;
          FOR j IN 1 ..  v_child_id_list.COUNT LOOP

              V_CONFLICT_XSL := '';
              V_EXISTSNODE_STRING := '';
                --- For each of the child, check and update for each of the transformed attribute
              FOR i IN 1 ..  v_attr_name_list.COUNT LOOP
                  UPDATE az_diff_results d
                    SET  d.attr_diff = updatexml(d.attr_diff,   '/H/V[@N="'||v_attr_name_list(i)||'" and ./A/text()="'||v_attr_old_value_list(i)||'"]/B/text()',v_attr_new_value_list(i) )
                    WHERE existsnode(d.attr_diff, '/H/V[@N="'||v_attr_name_list(i)||'" and ./A/text()="'||v_attr_old_value_list(i)||'"]') = 1
                     AND d.request_id = p_request_id
                     AND d.source = p_source
                     AND d.id = v_child_id_list(j);
                     ---Also create the conflict XSL and ExistsNode String
                      V_CONFLICT_XSL       := V_CONFLICT_XSL||
                      ' <xsl:when test="@N!='''''||v_attr_name_list(i)||''''' and ./B/text()='''''||v_attr_old_value_list(i)||''''' "> '
                      ||'    <xsl:attribute name="T">1</xsl:attribute>'
                      ||'    <xsl:if test="not(@A1)"><xsl:attribute name="A1">Y</xsl:attribute></xsl:if>'
                      ||'</xsl:when>';

                      IF LENGTH(V_EXISTSNODE_STRING) >0
                      THEN
                        V_EXISTSNODE_STRING := V_EXISTSNODE_STRING||' OR ';
                      END IF;
                      V_EXISTSNODE_STRING       := V_EXISTSNODE_STRING||
                      ' existsnode(d.attr_diff, ''/H/V[@N!="' ||
                       v_attr_name_list(i) ||
                       '"]/B[.="' ||
                       v_attr_old_value_list(i) ||
                       '"]'')=1 ';
              END LOOP;
          --LMATHUR  - Now for each of the CHILD, we need to update the PARAM3 and Conflicts at the attribute level, if exists
            IF LENGTH(V_CONFLICT_XSL)>0
            THEN
            --make the conflict XSL well-formed
            V_CONFLICT_XSL :='<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                                  <xsl:template match="H">
                                          <H>
                                                  <xsl:for-each select="V">
                                                          <V>
                                                                  <xsl:copy-of select="@*[not(name()=''''T'''')]"/>
                                                                  <xsl:choose>'||V_CONFLICT_XSL||
                                                                  ' <xsl:otherwise>
                                                                  <xsl:attribute name="T"><xsl:value-of select="@T"/></xsl:attribute>
                                                                  </xsl:otherwise>
                                                                  </xsl:choose>
                                                                  <xsl:copy-of  select="A"/>
                                                                  <xsl:copy-of select="B"/>
                                                                  </V>
                                                                  </xsl:for-each>
                                                                  </H>
                                                                  </xsl:template>
                                                                  </xsl:stylesheet>';
            V_EXISTSNODE_STRING       := '('||V_EXISTSNODE_STRING||')';
            V_QUERY_STR := 'UPDATE az_diff_results d
                SET  d.attr_diff = d.attr_diff.transform(xmltype('''||V_CONFLICT_XSL||''') ).createSchemaBasedXML('''||p_diff_schema_url||''')
                WHERE '||V_EXISTSNODE_STRING||'
                 AND d.request_id ='|| p_request_id||'
                 AND d.source ='''|| p_source||'''
                 AND d.id = '||v_child_id_list(j);

                EXECUTE IMMEDIATE V_QUERY_STR;

            END IF;
          END LOOP;
        -- Now we need to update the master is_transformed flag for the changed child records
        update_master_flag(p_request_id,p_source,'IS_TRANSFORMED',v_child_id_list,'N');


        -- Now we need to update the master record's param3 flag which are having conflicts in childs
        update_master_flag(p_request_id,p_source,'PARAM3',v_child_id_list,'Y');
---      Redundancy removal


        -- Check if there were any records which were marked for conflict as this is the basis for
        -- indicating the conflict flag (A5=C) in the Selection Set XML
--        select count(1) into V_CONFLICT_PARAM3_COUNT from az_diff_results d where d.param3 = 'Y' and
--        d.request_id = P_REQUEST_ID
--        and d.source=p_source;
--
--        IF V_CONFLICT_PARAM3_COUNT > 0
--        THEN
--            --LMATHUR - To show conflict icon in the VIEW mode, we need an indicator for conflicts- A5=C indicate conflicts
--            EXECUTE IMMEDIATE  'UPDATE az_requests d
--                                SET d.selection_set = updatexml(d.selection_set,   ''/EXT/H[S="'||p_source||'"]/@A5'',''C'')
--                                WHERE d.request_id = '||P_REQUEST_ID||
--                                ' AND d.request_type = ''T''';
--        END IF;
        --LMATHUR and HBODA -- Changes to update the Conflict count in the selection Set XML so as to be used in UI
        update_conflict_status(p_request_id,P_SOURCE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
    WHEN OTHERS THEN
      raise_error_msg(SQLCODE,
                      SQLERRM,
                      'TRANSFORM_ALL_ATTR_SOURCE',
                      'procedure end');


  END TRANSFORM_ALL_ATTR_SOURCE;
  PROCEDURE update_master_flag(P_REQUEST_ID         IN NUMBER,
                            P_SOURCE    IN VARCHAR2,
                            p_column_name IN VARCHAR2,
                            p_id_list IN TYP_NEST_TAB_VARCHAR,
                            p_upd_entire_tree_flag IN VARCHAR2 ) IS
  v_entire_tree_string varchar2(255) := ' k.parent_id = 1 AND ';
  v_has_conflicts varchar2(1) := 'Y';
  v_has_conflicts_sql varchar2(5000) := '';
  v_additional_where_clause varchar2(255) := 'Y';
  BEGIN
      IF p_upd_entire_tree_flag = 'Y'
      THEN
        v_entire_tree_string := '';
      END IF;
      --Change to ensure that the only those records flag are updated where the conflicts or transformation has actually happened
      IF p_column_name = 'PARAM3'
      THEN
       v_additional_where_clause := ' decode(existsNode(d.attr_diff, ''/H/V[@A1="Y"]''),''1'',''Y'',''N'') ';
      END IF;
      IF p_column_name = 'PARAM2'
      THEN
        v_additional_where_clause := ' decode(existsNode(d.attr_diff, ''/H/V[@T="1"]''),''1'',''Y'',''N'') ';
      END IF;

      FOR i IN 1 ..  p_id_list.COUNT LOOP
                        IF p_column_name <> 'IS_TRANSFORMED'
                        THEN

                          v_has_conflicts_sql := 'select ' || v_additional_where_clause || '
                                                  from az_diff_results d
                                                  WHERE d.request_id = '||p_request_id||'
                                                  AND d.source = '''||p_source||'''
                                                  AND d.id ='  || p_id_list(i) || '';
                          EXECUTE IMMEDIATE v_has_conflicts_sql into v_has_conflicts;

                        END IF;
                        IF v_has_conflicts = 'Y' THEN

                          EXECUTE IMMEDIATE 'UPDATE az_diff_results g
                          SET g.'||p_column_name||' = ''Y''
                          WHERE g.id in
                                    (SELECT k.id
                                    FROM
                                    (SELECT parent_id, id, '||p_column_name||'
                                                   FROM
                                                   (SELECT d.parent_id, d.id, d.'||p_column_name||'
                                                             FROM az_diff_results d
                                                             WHERE d.request_id = '||p_request_id||'
                                                             AND d.source = '''||p_source||'''
                                                             AND d.parent_id >0) f
                                          CONNECT BY PRIOR f.parent_id = f.id START WITH f.id = '||p_id_list(i)||') k
                                          WHERE '||v_entire_tree_string||' (k.'||p_column_name||' IS NULL OR k.'||p_column_name||' <> ''Y''))
                          AND g.request_id = '||p_request_id||'
                          AND g.source = '''||p_source||'''';
                        END IF;
      END LOOP;
  END update_master_flag;

PROCEDURE update_conflict_status(P_REQUEST_ID IN NUMBER, P_SOURCE    IN VARCHAR2) IS
  v_count number := 0;
  BEGIN
        select count(1) into v_count from az_diff_results e where request_id= p_request_id
        and source = p_source and existsnode(e.attr_diff,'/H/V[@A1="Y"]')=1;
        IF v_count >0 --this source atleast had one conflict
        THEN
            -- Now check if all the conflicts are resolved for this source
            select count(1) into v_count from az_diff_results e where request_id= p_request_id
            and source = p_source and existsnode(e.attr_diff,'/H/V[@A1="Y" and (./A/text()=./B/text())]') = 1;

            EXECUTE IMMEDIATE 'UPDATE az_requests g
            SET g.selection_set = updateXML(g.selection_set, ''/EXT/H/V[@N="EntityOccuranceCode" and .="'|| P_SOURCE||'"]/../@A5'',decode('||v_count||',0,''Y'',''C'') )
            WHERE g.request_id = '||p_request_id||' and  request_type=''T''';


        END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      RAISE_ERROR_MSG(SQLCODE,
                      SQLERRM,
                      'UPDATE_CONFLICT_STATUS: Could not update the conflict status for Source:'||p_source,
                      'UPDATE_CONFLICT_STATUS');
  END update_conflict_status;

END AZ_R12_TRANSFORM_CASCADE;



/
