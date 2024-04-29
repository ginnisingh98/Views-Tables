--------------------------------------------------------
--  DDL for Package Body AZ_COMP_REPORTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_COMP_REPORTER" AS
  /* $Header: azcompreporterb.pls 120.20.12010000.2 2009/12/29 06:57:47 mugsrin ship $ */
   -- Private type declarations
  --  type <TypeName> is <Datatype>;

  -- Private constant declarations
  --DIFF_SCHEMA_URL   CONSTANT VARCHAR2(4000) :='http://isetup.oracle.com/2006/diffresultdata.xsd';
  diff_schema_url VARCHAR2(4000);

  exclude_details VARCHAR2(1);
  commit_batch_size NUMBER;
  v_dml_count NUMBER;

  c_log_head constant VARCHAR2(30) := 'az.plsql.AZ_COMP_REPORTER.';
  output_a_stylesheet constant VARCHAR2(4000) := '<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<H>
   <xsl:apply-templates/>
</H>
</xsl:template>
<xsl:template match="V">
  <xsl:element name="V">
      <xsl:attribute name="N">
        <xsl:value-of select="@N" />
      </xsl:attribute>
      <xsl:attribute name="D">
        <xsl:value-of select="@D" />
      </xsl:attribute>
      <xsl:if test="@U=''Y''">
        <xsl:attribute name="U">
          <xsl:value-of select="@U" />
        </xsl:attribute>
      </xsl:if >
      <xsl:copy-of select="A" />
      <B></B>
    </xsl:element>
</xsl:template>
</xsl:stylesheet>';

  output_b_stylesheet constant VARCHAR2(4000) := '<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<H>
   <xsl:apply-templates/>
</H>
</xsl:template>
<xsl:template match="V">
  <xsl:element name="V">
      <xsl:attribute name="N">
        <xsl:value-of select="@N" />
      </xsl:attribute>
      <xsl:attribute name="D">
        <xsl:value-of select="@D" />
      </xsl:attribute>
      <xsl:if test="@U=''Y''">
        <xsl:attribute name="U">
          <xsl:value-of select="@U" />
        </xsl:attribute>
      </xsl:if >
      <A>
      </A>
      <xsl:copy-of select="B" />
    </xsl:element>
</xsl:template>
</xsl:stylesheet>';

  --v_prim_xmltype xmltype:= xmltype.createXml(PRIM_STYLESHEET);
  v_a_xmltype xmltype := xmltype.createxml(output_a_stylesheet);
  v_b_xmltype xmltype := xmltype.createxml(output_b_stylesheet);

  --  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --  <VariableName> <Datatype>;

  -- Function and procedure implementations

  /*********************Procedure declarations*************************************/
PROCEDURE output_df(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_pid_a IN NUMBER,   p_data_pid_b IN NUMBER);

  PROCEDURE output_a_only(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_id IN NUMBER);

  PROCEDURE output_b_only(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_id IN NUMBER);

  PROCEDURE update_for_show_only_diff(p_request_id IN NUMBER,   p_source IN VARCHAR2);

  PROCEDURE raise_error_msg(errcode IN NUMBER,   errmsg IN VARCHAR2,   procedurename IN VARCHAR2,   statement IN VARCHAR2);

  PROCEDURE commit_if_required;

  PROCEDURE update_diff_type_counts(p_request_id IN NUMBER,   p_source IN VARCHAR2);

  /**********************************************************/

   PROCEDURE compare(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_diff_schema_url IN VARCHAR2,   p_exclude_details IN VARCHAR2) IS

  v_am_name_a VARCHAR2(4000);
  v_am_disp_name_a VARCHAR2(4000);
  v_results_id NUMBER := 1;
  -- id for az_diff_results
  -- v_attr_clob       CLOB;
  v_hcd_a VARCHAR2(4000);
  l_api_name constant VARCHAR2(30) := 'compare : ';
  BEGIN

    diff_schema_url := p_diff_schema_url;
    exclude_details := p_exclude_details;
    commit_batch_size := fnd_profile.VALUE('AZ_COMMIT_ROWCOUNT');
    v_dml_count := 0;

    SELECT name,
      display_name,
      hashcode_details
    INTO v_am_name_a,
      v_am_disp_name_a,
      v_hcd_a
    FROM az_reporter_data
    WHERE request_id = p_request_id
     AND source = p_source
     AND id = 1
     AND type = -1
     AND is_primary = 'Y';

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=''SIMILAR''';

    INSERT
    INTO az_diff_results(name,   display_name,   request_id,   source,   type,   id,   parent_id,   hashcode_details,   depth,   is_different,   is_transformed,   show_only_diff,   param2,   attr_diff)
    VALUES(v_am_name_a,   -- name
    v_am_disp_name_a,   p_request_id,   p_source,   -1,   -- type
    v_results_id,   0,   -- parent_id
    v_hcd_a,   1,   -- depth
    'N',   -- isdifferent
    'N',   -- istransformed
    'N',   -- show_only_diff
    'Y',   -- exclude details for AM
    NULL);
    -- attr_diff

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name || to_char(systimestamp),   'Inserting into az_diff_results for request_id: '
      || p_request_id || ' source: ' || p_source);
    END IF;

    v_dml_count := v_dml_count + 1;
    commit_if_required;

    UPDATE az_reporter_data
    SET deleted_flag = 'Y'
    WHERE request_id = p_request_id
     AND source = p_source
     AND id = 1
     AND is_primary = 'N';
    -- delete root AM in B

    v_dml_count := v_dml_count + 1;
    commit_if_required;

    v_results_id := v_results_id + 2;
    -- v_results_id 2 is skipped for Details of AM (which is not there)
    output_df(p_request_id,   p_source,

       /* v_attr_clob,*/ 2,

       /*depth*/ v_results_id,   1

     /*v_results_pid*/,   1

     /*v_data_pid_A*/,   1

     /*v_data_pid_B*/);
    COMMIT;
    update_for_show_only_diff(p_request_id,   p_source);
    ---LMATHUR - need to update the individual counts based on the number of differences
    update_diff_type_counts(p_request_id,   p_source);
    COMMIT;

  EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN others THEN
    raise_error_msg(SQLCODE,   sqlerrm,   'compare',   'procedure end');
  END compare;

  /* functionality of output_DF - output its children
   functionality of output_A_only - output this and its children
*/ PROCEDURE output_df(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_pid_a IN NUMBER,   p_data_pid_b IN NUMBER) IS
  -- its children have this ref entity counter

  v_matching_vo_id_b NUMBER;
  v_count NUMBER;
  v_type NUMBER;
  v_results_pid NUMBER;

  v_children_a_name_list typ_nest_tab_varchar;
  v_children_a_disp_name_list typ_nest_tab_varchar;
  v_children_a_id_list typ_nest_tab_number;
  v_children_a_hc_list typ_nest_tab_number;
  v_children_a_hcd_list typ_nest_tab_varchar;

  v_children_b_id_list typ_nest_tab_number;
  v_children_b_hc_list typ_nest_tab_number;
  v_children_b_hcd_list typ_nest_tab_varchar;

  v_matching_vos_of_b_list typ_nest_tab_number;
  v_attr_str VARCHAR2(32767);
  v_amount INTEGER;
  v_is_different VARCHAR2(1) := 'N';
  v_show_only_diff VARCHAR2(1) := 'N';
  v_debug_str VARCHAR2(32767);
  v_temp_xmltype xmltype;

  v_exclude_details VARCHAR2(1);
  v_exclude_details_temp VARCHAR2(1);
  l_api_name constant VARCHAR2(30) := 'output_DF : ';
  l_log_query VARCHAR2(32000);
  BEGIN
    SELECT name,
      display_name,
      id,
      hashcode,
      hashcode_details bulk collect
    INTO v_children_a_name_list,
      v_children_a_disp_name_list,
      v_children_a_id_list,
      v_children_a_hc_list,
      v_children_a_hcd_list
    FROM az_reporter_data
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = p_data_pid_a
     AND is_primary = 'Y';

    IF v_children_a_id_list.COUNT <> 0 THEN
      FOR i IN 1 .. v_children_a_id_list.COUNT
      LOOP
        BEGIN
          -- get matching VO of B
          SELECT id
          INTO v_matching_vo_id_b
          FROM az_reporter_data
          WHERE request_id = p_request_id
           AND source = p_source
           AND hashcode = v_children_a_hc_list(i)
           AND parent_id = p_data_pid_b
           AND is_primary = 'N'
           AND deleted_flag = 'N'
           AND rownum = 1;

          UPDATE az_reporter_data
          SET deleted_flag = 'Y'
          WHERE request_id = p_request_id
           AND source = p_source
           AND id = v_matching_vo_id_b
           AND is_primary = 'N';

          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
            || to_char(systimestamp),   'Updating v_children_A_ID_List_I:  '
            || v_children_a_hc_list(i) || ' p_data_pid_B: ' || p_data_pid_b
            || ' p_request_id: ' || p_request_id || ' v_matching_VO_id_B: ' || v_matching_vo_id_b);
          END IF;

          v_dml_count := v_dml_count + 1;
          commit_if_required;
          --------------------------------------------------------------------------------

          v_debug_str := '->A ID=' || v_children_a_id_list(i) || ',B ID=' || v_matching_vo_id_b;

            SELECT xmlquery('for $a in 1
              let $common := for $i in $PRIM/H/V, $j in $SEC/H/V
                       where ($i/@N eq $j/@N)
                       return
                            if ($i/@U = "Y")
                            then <V N="{$i/@N}" D="{$i/@D}" U="Y">{($i/A)}{($j/B)}</V>
                            else <V N="{$i/@N}" D="{$i/@D}">{($i/A)}{($j/B)}</V>
              let $exsec := for $j in $SEC/H/V
                          return
                            if ($common/@N = $j/@N)
                            then ""
                            else  $j
              let $exprim := for $j in $PRIM/H/V
                          return
                          if ($common/@N = $j/@N)
                            then ""
                          else $j
               return <H>{$common}{$exprim}{$exsec}</H>' passing
            PRIM.attributes as "PRIM", SEC.attributes as "SEC"
            returning content).createSchemaBasedXml(DIFF_SCHEMA_URL)
            into v_temp_xmltype
			from az_reporter_data PRIM,az_reporter_data SEC
            where PRIM.request_id = SEC.request_id
            and PRIM.source = SEC.source
            and PRIM.request_id = p_request_id
			and PRIM.source = p_source
            and PRIM.id=v_children_A_ID_List(i)
			and PRIM.is_primary='Y'
            and SEC.id = v_matching_VO_id_B
            and SEC.is_primary = 'N';

          SELECT decode(existsnode(v_temp_xmltype,   '/H/V[./A/text()!=./B/text() and not(@U="Y")]'),   1,   'C',   'N')
          INTO v_is_different
          FROM dual;

          SELECT existsnode(v_temp_xmltype,   '/H/V[not(@U="Y")]')
          INTO v_exclude_details_temp
          FROM dual;

          IF(v_exclude_details_temp = '0' OR exclude_details = 'Y') THEN
            v_exclude_details := 'Y';
          ELSE
            v_exclude_details := 'N';
          END IF;

          IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
            || to_char(systimestamp),   'Constructing exclude details and is different '
            || ' v_is_different: ' || v_is_different || ' v_exclude_details_temp: '
            || v_exclude_details_temp || ' v_exclude_details: ' || v_exclude_details);
          END IF;

          v_debug_str := v_debug_str || ',is_different=' || v_is_different;
          ---------------------------------------------------------------------------------

          IF p_results_pid = 1 THEN
            v_type := 0;
          ELSE
            v_type := 2;
          END IF;

          INSERT
          INTO az_diff_results(name,   display_name,   request_id,   source,   type,   id,   parent_id,   hashcode_details,   depth,   is_different,   is_transformed,   show_only_diff,   param2,   attr_diff)
          VALUES(v_children_a_name_list(i),   v_children_a_disp_name_list(i),   p_request_id,   p_source,   v_type,   p_results_id,   p_results_pid,   v_children_a_hcd_list(i),   p_depth,   -- depth
          v_is_different,   -- isdifferent
          'N',   -- istransformed
          decode(v_is_different,   'C',   'Y',   'N'),   --show only diff--v_show_only_diff, -- show_only_diff
          v_exclude_details,   v_temp_xmltype);

          v_dml_count := v_dml_count + 1;
          commit_if_required;

          v_results_pid := p_results_id;
          p_results_id := p_results_id + 2;
          v_is_different := 'N';
          v_show_only_diff := 'N';
          -- ************************************************************************

          output_df(p_request_id,   p_source,   p_depth + 1,   p_results_id,   v_results_pid

           /*results_pid*/,   v_children_a_id_list(i)

           /*data_pid_A*/,   v_matching_vo_id_b

           /*data_pid_B*/);

        EXCEPTION
        WHEN no_data_found THEN
          output_a_only(p_request_id,   p_source,   p_depth,   p_results_id,   p_results_pid,   v_children_a_id_list(i)

           /*p_data_id_A*/);
        WHEN application_exception THEN
          RAISE;
        WHEN others THEN
          raise_error_msg(SQLCODE,   sqlerrm,   'output_DF',   'get matching VO of B, collect attributes and insert');
        END;
      END LOOP;

      -- children A cursor loop
    END IF;

    -- children A count > 0

    SELECT id bulk collect
    INTO v_children_b_id_list
    FROM az_reporter_data
    WHERE request_id = p_request_id
     AND source = p_source
     AND parent_id = p_data_pid_b
     AND is_primary = 'N'
     AND deleted_flag = 'N';

    IF v_children_b_id_list.COUNT <> 0 THEN
      FOR i IN 1 .. v_children_b_id_list.COUNT
      LOOP
        output_b_only(p_request_id,   p_source,   p_depth,   p_results_id,   p_results_pid,   v_children_b_id_list(i)

         /*p_data_id_B*/);

      END LOOP;
    END IF;

    ----------------------------------------------

    EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN others THEN
      raise_error_msg(SQLCODE,   sqlerrm,   'output_DF',   'procedure end');
    END;

    -- output p_data_id and its children

    PROCEDURE output_a_only(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_id IN NUMBER) IS

    v_name_a VARCHAR2(4000);
    v_disp_name_a VARCHAR2(4000);
    v_id_a NUMBER;
    v_hc_a NUMBER;
    v_hcd_a VARCHAR2(4000);
    v_results_pid NUMBER;

    v_children_a_id_list typ_nest_tab_number;
    v_temp_xmltype xmltype;
    v_amount INTEGER;
    v_type NUMBER;

    v_exclude_details VARCHAR2(1);
    v_exclude_details_temp VARCHAR2(1);
    l_api_name constant VARCHAR2(30) := 'output_A_only : ';
    BEGIN
      -- output this

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
        || to_char(systimestamp),   'Called output_A_only with ' || ' p_request_id: '
        || p_request_id || ' p_source: ' || p_source || ' p_depth: ' || p_depth
        || ' p_data_id: ' || p_data_id);
      END IF;

      SELECT name,
        display_name,
        id,
        hashcode,
        hashcode_details
      INTO v_name_a,
        v_disp_name_a,
        v_id_a,
        v_hc_a,
        v_hcd_a
      FROM az_reporter_data
      WHERE request_id = p_request_id
       AND source = p_source
       AND id = p_data_id
       AND is_primary = 'Y';

      SELECT d.attributes.transform(v_a_xmltype)
      INTO v_temp_xmltype
      FROM az_reporter_data d
      WHERE request_id = p_request_id
       AND source = p_source
       AND id = p_data_id
       AND is_primary = 'Y';

      SELECT existsnode(v_temp_xmltype,   '/H/V[not(@U="Y")]')
      INTO v_exclude_details_temp
      FROM dual;

      IF(v_exclude_details_temp = '0' OR exclude_details = 'Y') THEN
        v_exclude_details := 'Y';
      ELSE
        v_exclude_details := 'N';
      END IF;

      IF p_results_pid = 1 THEN
        v_type := 0;
      ELSE
        v_type := 2;
      END IF;

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
--        IF(LENGTH(v_temp_xmltype.getClobVal()) > 0 ) THEN
--          fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
--          || to_char(systimestamp),   ' v_temp_xmltype: ' || v_temp_xmltype.getclobval());
--        END IF;
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
        || to_char(systimestamp),   'v_exclude_details: ' || v_exclude_details || ' p_results_pid: ' || p_results_pid);
      END IF;

      INSERT
      INTO az_diff_results(name,   display_name,   request_id,   source,   type,   id,   parent_id,   hashcode_details,   depth,   is_different,   is_transformed,   show_only_diff,   param2,   attr_diff)
      VALUES(v_name_a,   v_disp_name_a,   p_request_id,   p_source,   v_type,   p_results_id,   p_results_pid,   v_hcd_a,   p_depth,   -- depth
      'A',   -- isdifferent
      'N',   -- istransformed
      'Y',   -- show_diff_only
      v_exclude_details,   xmltype(v_temp_xmltype.getclobval(),   diff_schema_url,   1,   1));

      v_dml_count := v_dml_count + 1;
      commit_if_required;

      v_results_pid := p_results_id;
      p_results_id := p_results_id + 2;

      -- output children
      SELECT id bulk collect
      INTO v_children_a_id_list
      FROM az_reporter_data
      WHERE request_id = p_request_id
       AND source = p_source
       AND parent_id = p_data_id
       AND is_primary = 'Y';

      IF v_children_a_id_list.COUNT <> 0 THEN
        FOR i IN 1 .. v_children_a_id_list.COUNT
        LOOP
          output_a_only(p_request_id,   p_source,   p_depth + 1,   p_results_id,   v_results_pid,   v_children_a_id_list(i));
        END LOOP;

        -- children A cursor
      END IF;

    EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN others THEN
      raise_error_msg(SQLCODE,   sqlerrm,   'output_A_only',   'procedure end');
    END;

    -- output p_data_id and its children

    PROCEDURE output_b_only(p_request_id IN NUMBER,   p_source IN VARCHAR2,   p_depth IN NUMBER,   p_results_id IN OUT nocopy NUMBER,   p_results_pid IN NUMBER,   p_data_id IN NUMBER) IS

    v_name_b VARCHAR2(4000);
    v_disp_name_b VARCHAR2(4000);
    v_id_b NUMBER;
    v_hc_b NUMBER;
    v_hcd_b VARCHAR2(4000);
    v_results_pid NUMBER;

    v_children_b_id_list typ_nest_tab_number;

    v_attr_str VARCHAR2(32767);
    v_amount INTEGER;
    v_type NUMBER;
    v_temp_xmltype xmltype;
    v_exclude_details VARCHAR2(1);
    v_exclude_details_temp VARCHAR2(1);
    l_api_name constant VARCHAR2(30) := 'output_B_only : ';
    BEGIN
      -- output this

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
        || to_char(systimestamp),   'Called output_B_only with ' || ' p_request_id: ' || p_request_id
        || ' p_source: ' || p_source || ' p_depth: ' || p_depth || ' p_results_pid: ' || p_results_pid
        || ' p_data_id: ' || p_data_id);
      END IF;

      SELECT name,
        display_name,
        id,
        hashcode,
        hashcode_details
      INTO v_name_b,
        v_disp_name_b,
        v_id_b,
        v_hc_b,
        v_hcd_b
      FROM az_reporter_data
      WHERE request_id = p_request_id
       AND source = p_source
       AND id = p_data_id
       AND is_primary = 'N';

      SELECT d.attributes.transform(v_b_xmltype)
      INTO v_temp_xmltype
      FROM az_reporter_data d
      WHERE request_id = p_request_id
       AND source = p_source
       AND id = p_data_id
       AND is_primary = 'N';

      SELECT existsnode(v_temp_xmltype,   '/H/V[not(@U="Y")]')
      INTO v_exclude_details_temp
      FROM dual;

      IF(v_exclude_details_temp = '0' OR exclude_details = 'Y') THEN
        v_exclude_details := 'Y';
      ELSE
        v_exclude_details := 'N';
      END IF;

      IF p_results_pid = 1 THEN
        v_type := 0;
      ELSE
        v_type := 2;
      END IF;

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        IF(LENGTH(v_temp_xmltype.getClobVal()) > 0 ) THEN
          fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
          || to_char(systimestamp),   ' v_temp_xmltype: ' || v_temp_xmltype.getclobval());
        END IF;
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
        || to_char(systimestamp),   'v_exclude_details: ' || v_exclude_details || ' p_results_pid: '
        || p_results_pid);
      END IF;

      INSERT
      INTO az_diff_results(name,   display_name,   request_id,   source,   type,   id,   parent_id,   hashcode_details,   depth,   is_different,   is_transformed,   show_only_diff,   param2,   attr_diff)
      VALUES(v_name_b,   v_disp_name_b,   p_request_id,   p_source,   v_type,   p_results_id,   p_results_pid,   v_hcd_b,   p_depth,   -- depth
      'B',   -- isdifferent
      'N',   -- istransformed
      'Y',   -- show_diff_only
      v_exclude_details,   xmltype(v_temp_xmltype.getclobval(),   diff_schema_url,   1,   1));

      v_dml_count := v_dml_count + 1;
      commit_if_required;

      UPDATE az_reporter_data
      SET deleted_flag = 'Y'
      WHERE request_id = p_request_id
       AND source = p_source
       AND id = v_id_b
       AND is_primary = 'N';

      v_dml_count := v_dml_count + 1;
      commit_if_required;

      v_results_pid := p_results_id;
      p_results_id := p_results_id + 2;

      -- output children
      SELECT id bulk collect
      INTO v_children_b_id_list
      FROM az_reporter_data
      WHERE request_id = p_request_id
       AND source = p_source
       AND parent_id = p_data_id
       AND is_primary = 'N'
       AND deleted_flag = 'N';

      IF v_children_b_id_list.COUNT <> 0 THEN
        FOR i IN 1 .. v_children_b_id_list.COUNT
        LOOP
          output_b_only(p_request_id,   p_source,   p_depth + 1,   p_results_id,   v_results_pid,   v_children_b_id_list(i));
        END LOOP;

        -- children A cursor
      END IF;

    EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN others THEN
      raise_error_msg(SQLCODE,   sqlerrm,   'output_B_only',   'procedure end');
    END;

    PROCEDURE update_for_show_only_diff(p_request_id IN NUMBER,   p_source IN VARCHAR2) IS

    v_different_id_list typ_nest_tab_number;
    v_different_pid_list typ_nest_tab_number;
    v_show_only_diff VARCHAR2(1);
    v_parent_id NUMBER;
    v_id NUMBER;
    v_is_different VARCHAR2(1);
    l_api_name constant VARCHAR2(30) := 'update_for_show_only_diff : ';
    BEGIN
      SELECT id,
        parent_id bulk collect
      INTO v_different_id_list,
        v_different_pid_list
      FROM az_diff_results
      WHERE request_id = p_request_id
       AND source = p_source
       AND is_different <> 'N' -- gets you A, B or C
      ORDER BY depth;

      IF v_different_id_list.COUNT <> 0 THEN
        FOR i IN 1 .. v_different_id_list.COUNT
        LOOP
          v_show_only_diff := 'N';
          v_parent_id := v_different_pid_list(i);
          LOOP
            EXIT
          WHEN v_show_only_diff = 'Y';
          BEGIN
            v_id := v_parent_id;
            -- avoiding recursion
            SELECT parent_id,
              is_different,
              show_only_diff
            INTO v_parent_id,
              v_is_different,
              v_show_only_diff
            FROM az_diff_results
            WHERE request_id = p_request_id
             AND source = p_source
             AND id = v_id;

            IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name
					|| to_char(systimestamp),   'v_different_ID_List_I: ' || v_different_id_list(i)
					|| ' v_different_PID_List: ' || v_different_pid_list(i) || ' v_parent_id: ' || v_parent_id ||
				 ' v_is_different: ' || v_is_different || ' v_show_only_diff: ' || v_show_only_diff);
            END IF;

            -- if is_different is A, B or C let it remain as it is
            -- valid (is_different, show_only_diff) combinations till now - (A,Y), (B,Y), (C,Y), (N,N). introduce (D,Y) now.

            IF v_is_different = 'N'
             AND v_show_only_diff = 'N' THEN

              UPDATE az_diff_results
              SET show_only_diff = 'Y',
                is_different = 'D'
              WHERE request_id = p_request_id
               AND source = p_source
               AND id = v_id;

              v_dml_count := v_dml_count + 1;
              commit_if_required;

            END IF;

          EXCEPTION
          WHEN no_data_found THEN
            v_show_only_diff := 'Y';
            -- for AM
          WHEN others THEN
            raise_error_msg(SQLCODE,   sqlerrm,   'update_for_show_only_diff',   'select show_only_diff column of parents');
          END;
        END LOOP;
      END LOOP;

      -- for loop closes
    END IF;

    -- if count <>0

    EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN others THEN
      raise_error_msg(SQLCODE,   sqlerrm,   'update_for_show_only_diff',   'procedure end');

    END update_for_show_only_diff;

    PROCEDURE raise_error_msg (ErrCode		     IN NUMBER,
       	                         ErrMsg 		     IN VARCHAR2,
	                         ProcedureName   IN VARCHAR2,
                                                   Statement 	     IN VARCHAR2) IS

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


    PROCEDURE commit_if_required IS
    BEGIN

      IF MOD(v_dml_count,   commit_batch_size) = 0 THEN
        COMMIT;

        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,   c_log_head || 'commit_if_required : ' || to_char(systimestamp),   'Committed transaction');
        END IF;

      END IF;

    END commit_if_required;
    --LMATHUR added to update the record count in selection set XML for the given source, based on the type of differences
    PROCEDURE update_diff_type_counts(p_request_id IN NUMBER,   p_source IN VARCHAR2) IS

    v_diff_type_list typ_nest_tab_varchar;
    v_diff_count_list typ_nest_tab_varchar;
    v_transform_xml VARCHAR2(32767) := '';
    l_api_name constant VARCHAR2(40) := 'update_diff_type_counts : ';
    BEGIN

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name || to_char(systimestamp),   'update_diff_type_counts called with p_request_id: ' || p_request_id || ' p_source: ' || p_source);
      END IF;

      SELECT nvl(COUNT,   0),
        e.column_value.getrootelement() AS
      col_name bulk collect
      INTO v_diff_count_list,
        v_diff_type_list
      FROM
        (SELECT decode(is_different,    'A',    'P6',    'B',    'P7',    'C',    'P8',    'D',    'P8',    'N',    'P9') name,
           COUNT(is_different) COUNT
         FROM az_diff_results d
         WHERE request_id = p_request_id
         AND source = p_source
         AND parent_id = 1
         GROUP BY is_different)
      k,
        TABLE(xmlsequence(EXTRACT(xmltype('<Root><P6/><P7/><P8/><P9/></Root>'),   '/Root/node()'))) e
      WHERE e.column_value.getrootelement() = name(+);

      FOR i IN 1 .. v_diff_type_list.COUNT
      LOOP

        v_transform_xml := v_transform_xml || '<xsl:when test="name(.)=''''' || v_diff_type_list(i) || '''''">
                        <xsl:copy>
                        <xsl:choose>
                       <xsl:when test="./../V[@N=''''EntityOccuranceCode'''' and .=''''' || p_source || ''''']">' || v_diff_count_list(i) || '</xsl:when>
                       <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                       </xsl:choose>
                       </xsl:copy>

	  </xsl:when>';

      END LOOP;

      IF LENGTH(v_transform_xml) > 0 THEN
        v_transform_xml := '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
              <xsl:template match="EXT">
                  <xsl:copy>
                  <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                  </xsl:copy>
              </xsl:template>
              <xsl:template match="H">
              <xsl:copy>
              <xsl:copy-of select="@*"/>
              <xsl:for-each select="*">
                  <xsl:choose>' || v_transform_xml || '<xsl:otherwise>
                    <xsl:copy-of select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
             </xsl:for-each>
             </xsl:copy>
			 </xsl:template>
			</xsl:stylesheet>';

        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,   c_log_head || l_api_name ||
		  to_char(systimestamp),   'Query to update selection set with counts : update az_requests d set 	d.selection_set = d.selection_set.transform(xmltype(''' ||
		  v_transform_xml || ''')).createSchemabasedxml(d.selection_set.getSchemaURL()) WHERE request_id=' || p_request_id || ' and request_type=''C''');
        END IF;

        EXECUTE IMMEDIATE 'update az_requests d set d.selection_set = d.selection_set.transform(xmltype(''' || v_transform_xml || ''')).createSchemabasedxml(d.selection_set.getSchemaURL()) WHERE request_id=' || p_request_id || ' and request_type=''C''';
      END IF;

    EXCEPTION
    WHEN no_data_found THEN

      NULL;
    WHEN application_exception THEN
      RAISE;
    WHEN others THEN
      raise_error_msg(SQLCODE,   sqlerrm,   'update_diff_type_counts',   'Error while updating the count based on type of differences');

    END update_diff_type_counts;

  END az_comp_reporter;

/
