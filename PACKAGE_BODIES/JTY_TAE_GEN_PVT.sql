--------------------------------------------------------
--  DDL for Package Body JTY_TAE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TAE_GEN_PVT" AS
/* $Header: jtfytaeb.pls 120.8.12010000.6 2009/10/29 11:55:05 rajukum ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TAE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the batch matching SQLs for all qualifier combinations.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      07/25/05    ACHANDA  Created
--
--    End of Comments
--

--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

   G_INDENT         VARCHAR2(30)  := '            ';
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.CONC_REQUEST_ID();
   G_PROGRAM_APPL_ID NUMBER       := FND_GLOBAL.PROG_APPL_ID();
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.CONC_PROGRAM_ID();
   G_USER_ID         NUMBER       := FND_GLOBAL.USER_ID();
   G_SYSDATE         DATE         := SYSDATE;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_NEW_LINE        VARCHAR2(02) := fnd_global.local_chr(10);

PROCEDURE jty_log(p_log_level IN NUMBER
			 ,p_module    IN VARCHAR2
			 ,p_message   IN VARCHAR2)
IS
pragma autonomous_transaction;
BEGIN
IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(p_log_level, p_module, p_message);
 commit;
 END IF;
END;

/* this procedure builds the where clause of a qualifier depending on its rule */
FUNCTION build_predicate_for_operator(
   p_op_common_where VARCHAR2
  ,p_op_eql VARCHAR2
  ,p_op_like VARCHAR2
  ,p_op_between VARCHAR2
  ,p_newline VARCHAR2)
RETURN VARCHAR2 AS

  l_result  CLOB;
  l_counter NUMBER;

BEGIN
  l_counter := 1;

  IF (p_op_eql IS NOT NULL) THEN
    l_result := p_newline || 'AND ( ' || p_op_eql;
    l_counter := l_counter + 1;
  END IF;

  IF p_op_like IS NOT NULL THEN
    IF  (l_counter = 1) THEN
      l_result := p_newline ||  'AND ( ' || p_op_like;
    ELSE
      l_result := l_result || p_newline || ' OR ' || p_newline || p_op_like;
    END IF;
    l_counter := l_counter + 1;
  END IF;

  IF p_op_between IS NOT NULL THEN
    IF  (l_counter = 1) THEN
      l_result := p_newline ||  'AND ( ' || p_op_between;
    ELSE
      l_result := l_result || p_newline || ' OR ' || p_newline || p_op_between;
    END IF;
    l_counter := l_counter + 1;
  END IF;

  l_result := l_result || p_newline || '     )';

  IF (p_op_common_where IS NOT NULL) THEN
    l_result := l_result || p_newline || ' AND ' || p_op_common_where || p_newline;
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN OTHERS THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_predicate_for_operator.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));
    RAISE;
END build_predicate_for_operator;


/* this function retuens the inline view of the matching SQL that returns */
/* all the valid territories having a particular qualifier combination    */
FUNCTION append_inlineview(
  p_source_id         IN NUMBER,
  p_trans_id          IN NUMBER,
  p_mode              IN VARCHAR2,
  p_qual_relation_prd IN NUMBER,
  p_from_str          IN VARCHAR2,
  p_new_mode_fetch    IN VARCHAR2)
RETURN VARCHAR2 AS

BEGIN
  IF (p_mode = 'DATE EFFECTIVE') THEN

    RETURN p_from_str || g_new_line || g_new_line ||
           G_INDENT || '   , /* INLINE VIEW */' || g_new_line ||
           G_INDENT || '     ( SELECT /*+ NO_MERGE use_nl(jqtu jtdr)*/               ' || g_new_line ||
           G_INDENT || '              jtdr.terr_id                  ' || g_new_line ||
           G_INDENT || '            , jtdr.source_id                ' || g_new_line ||
           G_INDENT || '            , jqtu.qual_type_id             ' || g_new_line ||
           G_INDENT || '            , jtdr.top_level_terr_id        ' || g_new_line ||
           G_INDENT || '            , jta.absolute_rank             ' || g_new_line ||
           G_INDENT || '            , jta.num_winners               ' || g_new_line ||
           G_INDENT || '            , jta.org_id                    ' || g_new_line ||
           G_INDENT || '       FROM  jty_denorm_dea_rules_all jtdr  ' || g_new_line ||
           G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_new_line ||
           G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_new_line ||
           G_INDENT || '            ,jtf_terr_all jta               ' || g_new_line ||
           G_INDENT || '       WHERE jtdr.source_id = ' || p_source_id || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id= jtdr.related_terr_id' || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id= jta.terr_id' || g_new_line ||
           G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_new_line ||
           G_INDENT || '         AND jqtu.qual_type_id = ' || p_trans_id || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id = jtqu.terr_id ' || g_new_line ||
           G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_new_line ||
           G_INDENT || '         --AND jtdr.resource_exists_flag = ''Y'' '|| g_new_line ||
           G_INDENT || '         AND jtqu.qual_relation_product = ' || p_qual_relation_prd || g_new_line ||
           G_INDENT || '     ) ILV' || g_new_line;

  ELSE
    IF (p_new_mode_fetch <> 'Y') THEN

      RETURN p_from_str || g_new_line || g_new_line ||
           G_INDENT || '   , /* INLINE VIEW */' || g_new_line ||
           G_INDENT || '     ( SELECT /*+ NO_MERGE */               ' || g_new_line ||
           G_INDENT || '              jtdr.terr_id                  ' || g_new_line ||
           G_INDENT || '            , jtdr.source_id                ' || g_new_line ||
           G_INDENT || '            , jqtu.qual_type_id             ' || g_new_line ||
           G_INDENT || '            , jtdr.top_level_terr_id        ' || g_new_line ||
           G_INDENT || '            , jta.absolute_rank            ' || g_new_line ||
           G_INDENT || '            , jta.num_winners              ' || g_new_line ||
           G_INDENT || '            , jta.org_id                   ' || g_new_line ||
           G_INDENT || '       FROM  jtf_terr_denorm_rules_all jtdr ' || g_new_line ||
           G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_new_line ||
           G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_new_line ||
           G_INDENT || '            ,jtf_terr_all jta               ' || g_new_line ||
           G_INDENT || '       WHERE jtdr.source_id = ' || p_source_id || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id= jtdr.related_terr_id' || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id= jta.terr_id' || g_new_line ||
           G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_new_line ||
           G_INDENT || '         AND jqtu.qual_type_id = ' || p_trans_id || g_new_line ||
           G_INDENT || '         AND jtdr.terr_id = jtqu.terr_id ' || g_new_line ||
           G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_new_line ||
           G_INDENT || '         --AND jtdr.resource_exists_flag = ''Y'' '|| g_new_line ||
           G_INDENT || '         AND jtqu.qual_relation_product = ' || p_qual_relation_prd || g_new_line ||
           G_INDENT || '     ) ILV' || g_new_line;

    ELSE

      RETURN p_from_str || g_new_line || g_new_line ||
          G_INDENT || '   , /* INLINE VIEW */' || g_new_line ||
          G_INDENT || '     ( SELECT /*+ NO_MERGE */ DISTINCT      ' || g_new_line ||
          G_INDENT || '              jtdr.terr_id                  ' || g_new_line ||
          G_INDENT || '            , jtdr.source_id                ' || g_new_line ||
          G_INDENT || '            , jqtu.qual_type_id             ' || g_new_line ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_new_line ||
          G_INDENT || '            , jta.absolute_rank            ' || g_new_line ||
          G_INDENT || '            , jta.num_winners              ' || g_new_line ||
          G_INDENT || '            , jta.org_id                   ' || g_new_line ||
          G_INDENT || '       FROM  jtf_terr_denorm_rules_all jtdr ' || g_new_line ||
          G_INDENT || '            ,jty_changed_terrs jct          ' || g_new_line ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_new_line ||
          G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_new_line ||
          G_INDENT || '            ,jtf_terr_all jta               ' || g_new_line ||
          G_INDENT || '       WHERE jqtu.source_id = ' || p_source_id || g_new_line ||
          G_INDENT || '         AND jtdr.terr_id= jct.terr_id      ' || g_new_line ||
          G_INDENT || '         AND jtdr.terr_id= jtdr.related_terr_id' || g_new_line ||
          G_INDENT || '         AND jtdr.terr_id= jta.terr_id' || g_new_line ||
          G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_new_line ||
          G_INDENT || '         AND jqtu.qual_type_id = ' || p_trans_id || g_new_line ||
          G_INDENT || '         AND jct.terr_id = jtqu.terr_id ' || g_new_line ||
          G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_new_line ||
--          G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_new_line ||
          G_INDENT || '         AND jct.tap_request_id = :REQUEST_ID ' || g_new_line ||
          G_INDENT || '         AND :CURR_DATE BETWEEN jtdr.start_date and jtdr.end_date ' || g_new_line ||
          G_INDENT || '         AND jtqu.qual_relation_product = ' || p_qual_relation_prd || g_new_line ||
          G_INDENT || '     ) ILV'||g_new_line;

    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.append_inlineview.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));
    RAISE;

END append_inlineview;

/* this procedure returns the insert and select clause of the SQL */
/* statement that inserts objects into NM_TRANS from TRANS table  */
PROCEDURE get_insert_select_nmtrans(
  p_match_table_name  IN  VARCHAR2,
  p_insert_stmt       OUT NOCOPY VARCHAR2,
  p_select_stmt       OUT NOCOPY VARCHAR2,
  errbuf              OUT NOCOPY VARCHAR2,
  retcode             OUT NOCOPY VARCHAR2)
AS
  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_owner    VARCHAR2(30);
  first_time BOOLEAN;
  l_indent   VARCHAR2(30);

  CURSOR c_column_names(cl_table_name IN VARCHAR2, cl_owner IN VARCHAR2) is
  SELECT column_name
  FROM   all_tab_columns
  WHERE  table_name = cl_table_name
  AND    owner      = cl_owner
  AND    column_name not in ('LAST_UPDATE_DATE', 'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN',
                             'REQUEST_ID', 'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE');

  L_SCHEMA_NOTFOUND EXCEPTION;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.get_insert_select_nmtrans.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.get_insert_select_nmtrans ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Get the schema name corresponding to JTF application */
  IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_owner)) THEN
    NULL;
  END IF;

  IF (l_owner IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Initialize local variables */
  first_time := TRUE;
  l_indent   := '  ';

  /* Form the insert statement to insert transaction objects into TRANS table */
  p_insert_stmt := 'INSERT INTO ' || p_match_table_name || '(';
  p_select_stmt := 'SELECT DISTINCT ';

  FOR column_names in c_column_names(p_match_table_name, l_owner) LOOP
    IF (first_time) THEN
      p_insert_stmt := p_insert_stmt || g_new_line || l_indent || column_names.column_name;
      p_select_stmt := p_select_stmt || g_new_line || l_indent || 'A.' || column_names.column_name;
      first_time := FALSE;
    ELSE
      p_insert_stmt := p_insert_stmt || g_new_line || l_indent || ',' || column_names.column_name;
      p_select_stmt := p_select_stmt || g_new_line || l_indent || ',' || 'A.' || column_names.column_name;
    END IF;
  END LOOP;

  /* Standard WHO columns */
  p_insert_stmt := p_insert_stmt || g_new_line || l_indent || ',LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',CREATION_DATE ' ||
                     g_new_line || l_indent || ',CREATED_BY ' ||
                     g_new_line || l_indent || ',LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',REQUEST_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_UPDATE_DATE ' ||
                     g_new_line || ')';

  p_select_stmt := p_select_stmt || g_new_line || l_indent || ',:LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',:LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',:CREATION_DATE ' ||
                     g_new_line || l_indent || ',:CREATED_BY ' ||
                     g_new_line || l_indent || ',:LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',:REQUEST_ID ' ||
                     g_new_line || l_indent || ',:PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',:PROGRAM_ID ' ||
                     g_new_line || l_indent || ',:PROGRAM_UPDATE_DATE ' ||
                     ' FROM ';

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.get_insert_select_nmtrans.end',
                   'End of the procedure JTY_TAE_GEN_PVT.get_insert_select_nmtrans ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    errbuf := 'Schema name corresponding to JTF application not found';
    retcode := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.get_insert_select_nmtrans.l_schema_notfound',
                     errbuf);

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.others',
                     substr(errbuf, 1, 4000));
END get_insert_select_nmtrans;


/* this procedure builds inline view for qualifiers */
PROCEDURE build_ilv1(
  p_source_id          IN NUMBER,
  p_trans_id           IN NUMBER,
  p_qual_relation_prd  IN NUMBER,
  p_relation_factor    IN NUMBER,
  p_mode               IN VARCHAR2,
  p_denorm_table_name  IN VARCHAR2,
  p_new_mode_fetch     IN VARCHAR2,
  p_sql                OUT NOCOPY  VARCHAR2,
  retcode              OUT NOCOPY VARCHAR2,
  errbuf               OUT NOCOPY VARCHAR2)
AS
  l_from_str       CLOB;
  l_where_str      CLOB;
  l_predicate      CLOB;
  l_select         CLOB;

  CURSOR c_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number) IS
  SELECT distinct
     jtqf.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM jtf_qual_usgs_all jqu,
       jtf_tae_qual_factors jtqf,
       jtf_tae_qual_products jtqp,
       jtf_tae_qual_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.qual_factor_id = jtqf.qual_factor_id
  AND   jtqf.relation_factor = cl_relation_factor
  AND   jtqp.qual_product_id = jtpf.qual_product_id
  AND   jtqp.relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_object_type_id = cl_trans_id
  AND   jqu.op_not_eql IS NULL
  AND   jqu.op_not_like IS NULL
  AND   jqu.op_not_between IS NULL
  ORDER BY jtqf.qual_usg_id;

  CURSOR c_dea_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number) IS
  SELECT distinct
     jtqf.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM jtf_qual_usgs_all jqu,
       jty_dea_attr_factors jtqf,
       jty_dea_attr_products jtqp,
       jty_dea_attr_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.dea_attr_factors_id = jtqf.dea_attr_factors_id
  AND   jtqf.relation_factor = cl_relation_factor
  AND   jtqp.dea_attr_products_id = jtpf.dea_attr_products_id
  AND   jtqp.attr_relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_type_id = cl_trans_id
  AND   jqu.op_not_eql IS NULL
  AND   jqu.op_not_like IS NULL
  AND   jqu.op_not_between IS NULL
  ORDER BY jtqf.qual_usg_id;

  TYPE l_qual_usg_id_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_usg_id%TYPE;
  TYPE l_alias_rule1_tbl_type IS TABLE OF jtf_qual_usgs_all.alias_rule1%TYPE;
  TYPE l_op_eql_tbl_type IS TABLE OF jtf_qual_usgs_all.op_eql%TYPE;
  TYPE l_op_like_tbl_type IS TABLE OF jtf_qual_usgs_all.op_like%TYPE;
  TYPE l_op_between_tbl_type IS TABLE OF jtf_qual_usgs_all.op_between%TYPE;
  TYPE l_op_where_tbl_type IS TABLE OF jtf_qual_usgs_all.op_common_where%TYPE;

  l_qual_usg_id_tbl l_qual_usg_id_tbl_type;
  l_alias_rule1_tbl l_alias_rule1_tbl_type;
  l_op_eql_tbl      l_op_eql_tbl_type;
  l_op_like_tbl     l_op_like_tbl_type;
  l_op_between_tbl  l_op_between_tbl_type;
  l_op_where_tbl    l_op_where_tbl_type;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv1.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.build_ilv1 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF (p_mode = 'DATE EFFECTIVE') THEN
    OPEN c_dea_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_dea_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_dea_rel_prod_detail;
  ELSE
    OPEN c_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_rel_prod_detail;
  END IF;

  FOR i IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST LOOP
    IF mod(p_qual_relation_prd,79) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       AI.customer_id' || g_new_line ||
                  G_INDENT || '     , AI.address_id'  || g_new_line;
    ELSIF mod(p_qual_relation_prd,137) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       ASLLP.sales_lead_id' || g_new_line ||
                  G_INDENT || '     , ASLLP.sales_lead_line_id'  || g_new_line;
    ELSIF mod(p_qual_relation_prd,113) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       ASLL.sales_lead_id' || g_new_line ||
                  G_INDENT || '     , ASLL.sales_lead_line_id'  || g_new_line;
    ELSIF mod(p_qual_relation_prd,131) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       ASLLI.sales_lead_id' || g_new_line ||
                  G_INDENT || '     , ASLLI.sales_lead_line_id'  || g_new_line;
    ELSIF mod(p_qual_relation_prd,139) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       ALLP.lead_id' || g_new_line ||
                  G_INDENT || '     , ALLP.lead_line_id' || g_new_line;
    ELSIF mod(p_qual_relation_prd,163) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       ALLI.lead_id' || g_new_line ||
                  G_INDENT || '     , ALLI.lead_line_id' || g_new_line;
    ELSIF mod(p_qual_relation_prd,167) = 0 THEN
      l_select := G_INDENT || 'SELECT ' || g_new_line ||
                  G_INDENT || '       OAI.lead_id' || g_new_line ;
    END IF;

    l_select := l_select ||
      G_INDENT || '     , ILV.terr_id                  ' || g_new_line ||
      G_INDENT || '     , ILV.top_level_terr_id        ' || g_new_line ||
      G_INDENT || '     , ILV.absolute_rank            ' || g_new_line ||
      G_INDENT || '     , ILV.num_winners              ' || g_new_line ||
      G_INDENT || '     , ILV.org_id                   ' || g_new_line;

    l_from_str := G_INDENT || 'FROM ' || l_alias_rule1_tbl(i) || ', ' || p_denorm_table_name || ' B ';

    l_from_str := append_inlineview(
                    p_source_id         => p_source_id,
                    p_trans_id          => p_trans_id,
                    p_mode              => p_mode,
                    p_qual_relation_prd => p_qual_relation_prd,
                    p_from_str          => l_from_str,
                    p_new_mode_fetch    => p_new_mode_fetch);

    l_where_str := g_new_line || G_INDENT || 'WHERE 1 = 1 ' ;

    l_predicate := g_new_line ||
                     build_predicate_for_operator(
                       p_op_common_where => l_op_where_tbl(i),
                       p_op_eql          => l_op_eql_tbl(i),
                       p_op_like         => l_op_like_tbl(i),
                       p_op_between      => l_op_between_tbl(i),
                       p_newline         => g_new_line);

    IF  mod(p_qual_relation_prd,79) = 0 THEN
      l_predicate := replace(l_predicate,'(  A.SQUAL_NUM02 IS NULL AND AI.address_id IS NULL )','');
      l_predicate := replace(l_predicate,'OR ( A.SQUAL_NUM02 = AI.address_id )'       , '1=1');
      l_predicate := replace(l_predicate,'A.SQUAL_NUM01 = AI.customer_id','1=1');
    ELSIF mod(p_qual_relation_prd,137) = 0 THEN
      l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ASLLP.SALES_LEAD_ID','1=1');
    ELSIF mod(p_qual_relation_prd,113) = 0 THEN
      l_predicate := replace(l_predicate,'ASLL.SALES_LEAD_ID = A.TRANS_OBJECT_ID','1=1');
      l_predicate := replace(l_predicate,'a.squal_curc03 = Q1022R1.currency_code','1=1');
    ELSIF mod(p_qual_relation_prd,131) = 0 THEN
      l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ASLLI.SALES_LEAD_ID','1=1');
    ELSIF mod(p_qual_relation_prd,139) = 0 THEN
      l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ALLP.LEAD_ID','1=1');
    ELSIF mod(p_qual_relation_prd,163) = 0 THEN
      l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ALLI.LEAD_ID','1=1');
    ELSIF mod(p_qual_relation_prd,167) = 0 THEN
      l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = OAI.LEAD_ID','1=1');
    END IF;

    EXIT;
  END LOOP;

  p_sql := l_select || g_new_line ||
             l_from_str || g_new_line ||
             l_where_str || g_new_line ||
             l_predicate;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv1.end',
                   'End of the procedure JTY_TAE_GEN_PVT.build_ilv1 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv1.others',
                     substr(errbuf, 1, 4000));

END build_ilv1;

/* this procedure builds inline view for qualifiers */
PROCEDURE build_ilv2(
  p_source_id         IN          NUMBER,
  p_trans_id          IN          NUMBER,
  p_program_name      IN          VARCHAR2,
  p_mode              IN          VARCHAR2,
  p_qual_relation_prd IN          NUMBER,
  p_relation_factor   IN          NUMBER,
  p_trans_table_name  IN          VARCHAR2,
  p_match_table_name  IN          VARCHAR2,
  p_denorm_table_name IN          VARCHAR2,
  p_new_mode_fetch    IN          VARCHAR2,
  p_sql               OUT NOCOPY  VARCHAR2,
  retcode             OUT NOCOPY  VARCHAR2,
  errbuf              OUT NOCOPY  VARCHAR2)
AS

  CURSOR c_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number)
  IS
  SELECT DISTINCT
     jqu.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM
     jtf_qual_usgs_all jqu
    ,jtf_tae_qual_factors jtqf
    ,jtf_tae_qual_products jtqp
    ,jtf_tae_qual_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.qual_factor_id= jtqf.qual_factor_id
  AND   jtqf.relation_factor <> cl_relation_factor
  AND   jtqp.qual_product_id = jtpf.qual_product_id
  AND   jtqp.relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_object_type_id= cl_trans_id
  ORDER BY jqu.qual_usg_id;

  CURSOR c_dea_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number)
  IS
  SELECT DISTINCT
     jqu.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM
     jtf_qual_usgs_all jqu
    ,jty_dea_attr_factors jtqf
    ,jty_dea_attr_products jtqp
    ,jty_dea_attr_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.dea_attr_factors_id = jtqf.dea_attr_factors_id
  AND   jtqf.relation_factor <> cl_relation_factor
  AND   jtqp.dea_attr_products_id = jtpf.dea_attr_products_id
  AND   jtqp.attr_relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_type_id= cl_trans_id
  ORDER BY jqu.qual_usg_id;

  TYPE l_qual_usg_id_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_usg_id%TYPE;
  TYPE l_alias_rule1_tbl_type IS TABLE OF jtf_qual_usgs_all.alias_rule1%TYPE;
  TYPE l_op_eql_tbl_type IS TABLE OF jtf_qual_usgs_all.op_eql%TYPE;
  TYPE l_op_like_tbl_type IS TABLE OF jtf_qual_usgs_all.op_like%TYPE;
  TYPE l_op_between_tbl_type IS TABLE OF jtf_qual_usgs_all.op_between%TYPE;
  TYPE l_op_where_tbl_type IS TABLE OF jtf_qual_usgs_all.op_common_where%TYPE;

  l_qual_usg_id_tbl  l_qual_usg_id_tbl_type;
  l_alias_rule1_tbl  l_alias_rule1_tbl_type;
  l_op_eql_tbl       l_op_eql_tbl_type;
  l_op_like_tbl      l_op_like_tbl_type;
  l_op_between_tbl   l_op_between_tbl_type;
  l_op_where_tbl     l_op_where_tbl_type;

  l_counter          NUMBER;
  l_relation_product NUMBER;

  l_from_str         CLOB;
  l_where_str        CLOB;
  l_predicate        CLOB;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv2.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.build_ilv2 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_relation_product := p_qual_relation_prd/p_relation_factor;
  l_counter := 1;

  IF (p_mode = 'DATE EFFECTIVE') THEN
    OPEN c_dea_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_dea_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_dea_rel_prod_detail;
  ELSE
    OPEN c_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_rel_prod_detail;
  END IF;

  IF (l_qual_usg_id_tbl.COUNT > 0) THEN
    FOR i IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST LOOP

      IF (l_counter = 1) THEN
        l_from_str := g_new_line || p_trans_table_name || ' A ' || g_new_line || ',' || p_denorm_table_name || ' B ';
        IF (l_alias_rule1_tbl(i) IS NOT NULL) THEN
          l_from_str := l_from_str || g_new_line || ',' || l_alias_rule1_tbl(i);
        END IF;

        l_where_str := g_new_line || 'WHERE 1 = 1';
        IF (p_new_mode_fetch <> 'Y') THEN
          l_where_str := l_where_str  || g_new_line || 'AND a.worker_id = :p_worker_id ';
        END IF;

        l_predicate := g_new_line ||
                         build_predicate_for_operator(
                            l_op_where_tbl(i)
                           ,l_op_eql_tbl(i)
                           ,l_op_like_tbl(i)
                           ,l_op_between_tbl(i)
                           ,g_new_line);
      ELSE
        IF (l_alias_rule1_tbl(i) IS NOT NULL) THEN
          l_from_str := l_from_str || g_new_line || ',' || l_alias_rule1_tbl(i);
        END IF;

        l_predicate := l_predicate || g_new_line ||
                         build_predicate_for_operator(
                            l_op_where_tbl(i)
                           ,l_op_eql_tbl(i)
                           ,l_op_like_tbl(i)
                           ,l_op_between_tbl(i)
                           ,g_new_line);
      END IF; /* end IF (l_counter = 1) */

      l_counter := l_counter + 1;
    END LOOP; /* end loop  FOR i IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST */
  END IF; /* end IF (l_qual_usg_id_tbl.COUNT > 0) */

  l_from_str :=
    append_inlineview(
      p_source_id         => p_source_id,
      p_trans_id          => p_trans_id,
      p_mode              => p_mode,
      p_qual_relation_prd => p_qual_relation_prd,
      p_from_str          => l_from_str,
      p_new_mode_fetch    => p_new_mode_fetch);

  IF (p_new_mode_fetch = 'Y') THEN
    p_sql := 'SELECT A.*,ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners FROM ';
  ELSE
    IF (mod(p_qual_relation_prd, 79) = 0) THEN
      p_sql := 'SELECT a.trans_object_id,a.trans_detail_object_id,a.worker_id,a.txn_date, ' ||
	              'ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners,ILV.org_id, A.SQUAL_NUM01, A.SQUAL_NUM02 FROM ' ;
    ELSE
      p_sql := 'SELECT a.trans_object_id,a.trans_detail_object_id,a.worker_id,a.txn_date, ' ||
	              'ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners,ILV.org_id FROM ' ;
    END IF;

  END IF;

  p_sql := p_sql || l_from_str || g_new_line || l_where_str || g_new_line || l_predicate || g_new_line ||
           'AND ILV.terr_id = B.terr_id ' || g_new_line ||
           'AND A.txn_date BETWEEN B.start_date and B.end_date ' || g_new_line ||
           'AND B.source_id = ' || p_source_id || g_new_line ||
           'AND B.trans_type_id = ' || p_trans_id;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv2.end',
                   'End of the procedure JTY_TAE_GEN_PVT.build_ilv2 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;
EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_ilv2.others',
                     substr(errbuf, 1, 4000));

END build_ilv2;

/* this procedure build the matching sql based on rules for qualifier combinations */
PROCEDURE build_qualifier_rules(
  p_source_id         IN          NUMBER,
  p_trans_id          IN          NUMBER,
  p_program_name      IN          VARCHAR2,
  p_mode              IN          VARCHAR2,
  p_qual_relation_prd IN          NUMBER,
  p_relation_factor   IN          NUMBER,
  p_trans_table_name  IN          VARCHAR2,
  p_match_table_name  IN          VARCHAR2,
  p_denorm_table_name IN          VARCHAR2,
  p_new_mode_fetch    IN          VARCHAR2,
  p_sql               OUT NOCOPY  CLOB,
  retcode             OUT NOCOPY  VARCHAR2,
  errbuf              OUT NOCOPY  VARCHAR2)
AS

  CURSOR c_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number)
  IS
  SELECT DISTINCT
     jqu.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM
     jtf_qual_usgs_all jqu
    ,jtf_tae_qual_factors jtqf
    ,jtf_tae_qual_products jtqp
    ,jtf_tae_qual_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.qual_factor_id= jtqf.qual_factor_id
  AND   jtqf.relation_factor <> cl_relation_factor
  AND   jtqp.qual_product_id = jtpf.qual_product_id
  AND   jtqp.relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_object_type_id= cl_trans_id
  ORDER BY jqu.qual_usg_id;

  CURSOR c_dea_rel_prod_detail(cl_source_id number, cl_trans_id number, cl_relation_product number, cl_relation_factor number)
  IS
  SELECT DISTINCT
     jqu.qual_usg_id
    ,jqu.alias_rule1
    ,jqu.op_eql
    ,jqu.op_like
    ,jqu.op_between
    ,jqu.op_common_where
  FROM
     jtf_qual_usgs_all jqu
    ,jty_dea_attr_factors jtqf
    ,jty_dea_attr_products jtqp
    ,jty_dea_attr_prod_factors jtpf
  WHERE jqu.org_id = -3113
  AND   jqu.qual_usg_id = jtqf.qual_usg_id
  AND   jtpf.dea_attr_factors_id = jtqf.dea_attr_factors_id
  AND   jtqf.relation_factor <> cl_relation_factor
  AND   jtqp.dea_attr_products_id = jtpf.dea_attr_products_id
  AND   jtqp.attr_relation_product = cl_relation_product
  AND   jtqp.source_id = cl_source_id
  AND   jtqp.trans_type_id= cl_trans_id
  ORDER BY jqu.qual_usg_id;

  TYPE l_qual_usg_id_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_usg_id%TYPE;
  TYPE l_alias_rule1_tbl_type IS TABLE OF jtf_qual_usgs_all.alias_rule1%TYPE;
  TYPE l_op_eql_tbl_type IS TABLE OF jtf_qual_usgs_all.op_eql%TYPE;
  TYPE l_op_like_tbl_type IS TABLE OF jtf_qual_usgs_all.op_like%TYPE;
  TYPE l_op_between_tbl_type IS TABLE OF jtf_qual_usgs_all.op_between%TYPE;
  TYPE l_op_where_tbl_type IS TABLE OF jtf_qual_usgs_all.op_common_where%TYPE;

  l_qual_usg_id_tbl  l_qual_usg_id_tbl_type;
  l_alias_rule1_tbl  l_alias_rule1_tbl_type;
  l_op_eql_tbl       l_op_eql_tbl_type;
  l_op_like_tbl      l_op_like_tbl_type;
  l_op_between_tbl   l_op_between_tbl_type;
  l_op_where_tbl     l_op_where_tbl_type;

  l_counter          NUMBER;

  l_from_str         CLOB;
  l_where_str        CLOB;
  l_predicate        CLOB;
  l_alias_rule1      jtf_qual_usgs_all.alias_rule1%TYPE;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.build_qualifier_rules ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'source_id='|| p_source_id || ',trans_id='|| p_trans_id
                   || ',qual_relation_prd='|| p_qual_relation_prd
                   || ',relation_factor='||p_relation_factor);

  l_counter := 1;

  IF (p_mode = 'DATE EFFECTIVE') THEN
    OPEN c_dea_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_dea_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_dea_rel_prod_detail;
  ELSE
    OPEN c_rel_prod_detail(p_source_id, p_trans_id, p_qual_relation_prd, p_relation_factor);
    FETCH c_rel_prod_detail BULK COLLECT INTO
       l_qual_usg_id_tbl
      ,l_alias_rule1_tbl
      ,l_op_eql_tbl
      ,l_op_like_tbl
      ,l_op_between_tbl
      ,l_op_where_tbl;
    CLOSE c_rel_prod_detail;
  END IF;

  IF (l_qual_usg_id_tbl.COUNT > 0) THEN
    l_alias_rule1 := 'ABC';
    FOR i IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST LOOP
      -- debug message
        jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   l_counter || ',l_alias_rule1='|| l_alias_rule1
                   || ',l_alias_rule1_tbl('||i||')='|| l_alias_rule1_tbl(i)
                   || ',p_trans_table_name='|| p_trans_table_name
                   || ',p_denorm_table_name='|| p_denorm_table_name);
      IF (l_counter = 1) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'enter l_counter=1');
        l_from_str := g_new_line || p_trans_table_name || ' A ' || g_new_line || ',' || p_denorm_table_name || ' B ';
        IF (l_alias_rule1_tbl(i) IS NOT NULL) THEN
          l_from_str := l_from_str || g_new_line || ',' || l_alias_rule1_tbl(i);
        END IF;

        l_where_str := g_new_line || 'WHERE 1 = 1';
        IF (p_new_mode_fetch <> 'Y') THEN
          l_where_str := l_where_str  || g_new_line || 'AND a.worker_id = :p_worker_id ';
        END IF;

        l_predicate := g_new_line ||
                         build_predicate_for_operator(
                            l_op_where_tbl(i)
                           ,l_op_eql_tbl(i)
                           ,l_op_like_tbl(i)
                           ,l_op_between_tbl(i)
                           ,g_new_line);
        -- debug message
          jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'l_predicate='||l_predicate);
      -- SOLIN
      ELSIF l_alias_rule1 = l_alias_rule1_tbl(i)
      THEN
          NULL;
      ELSE
      -- SOLIN end
--      ELSIF l_alias_rule1 <> l_alias_rule1_tbl(i)
        -- debug message
          jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'enter l_alias_rule1<>l_alias_rule1_tbl(i)');
        IF (l_alias_rule1_tbl(i) IS NOT NULL) THEN
          l_from_str := l_from_str || g_new_line || ',' || l_alias_rule1_tbl(i);
        END IF;

        l_predicate := l_predicate || g_new_line ||
                         build_predicate_for_operator(
                            l_op_where_tbl(i)
                           ,l_op_eql_tbl(i)
                           ,l_op_like_tbl(i)
                           ,l_op_between_tbl(i)
                           ,g_new_line);
        -- debug message
          jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'l_predicate='||l_predicate);
      END IF; /* end IF (l_counter = 1) */
      l_counter := l_counter + 1;
      l_alias_rule1 := l_alias_rule1_tbl(i);
    END LOOP; /* end loop  FOR i IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST */
  END IF; /* end IF (l_qual_usg_id_tbl.COUNT > 0) */

  -- debug message
      jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'l_from_str1='|| l_from_str
                   || ',l_predicate='|| l_predicate);
  l_from_str :=
    append_inlineview(
      p_source_id         => p_source_id,
      p_trans_id          => p_trans_id,
      p_mode              => p_mode,
      p_qual_relation_prd => p_qual_relation_prd,
      p_from_str          => l_from_str,
      p_new_mode_fetch    => p_new_mode_fetch);
  -- debug message
      jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules',
                   'l_from_str2='|| l_from_str);

  p_sql := l_from_str || g_new_line || l_where_str || g_new_line || l_predicate || g_new_line ||
           'AND ILV.terr_id = B.terr_id ' || g_new_line ||
           'AND A.txn_date BETWEEN B.start_date and B.end_date ' || g_new_line ||
           'AND B.source_id = ' || p_source_id || g_new_line ||
           'AND B.trans_type_id = ' || p_trans_id;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules.end',
                   'End of the procedure JTY_TAE_GEN_PVT.build_qualifier_rules ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;
EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules.others',
                     substr(errbuf, 1, 4000));

END build_qualifier_rules;


/* this procedure build the matching sql based on rules for qualifier combinations */
PROCEDURE build_qualifier_rules1(
  p_source_id         IN          NUMBER,
  p_trans_id          IN          NUMBER,
  p_program_name      IN          VARCHAR2,
  p_mode              IN          VARCHAR2,
  p_qual_relation_prd IN          NUMBER,
  p_trans_table_name  IN          VARCHAR2,
  p_match_table_name  IN          VARCHAR2,
  p_denorm_table_name IN          VARCHAR2,
  p_new_mode_fetch    IN          VARCHAR2,
  p_sql               OUT NOCOPY  CLOB,
  retcode             OUT NOCOPY  VARCHAR2,
  errbuf              OUT NOCOPY  VARCHAR2)
AS
  l_ilv1_sql           CLOB;
  l_ilv2_sql           CLOB;
  l_rel_prod1          NUMBER;

  l_status   VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_owner    VARCHAR2(30);
  first_time BOOLEAN;
  l_indent   VARCHAR2(30);

  CURSOR c_column_names(cl_table_name IN VARCHAR2, cl_owner IN VARCHAR2) is
  SELECT column_name
  FROM   all_tab_columns
  WHERE  table_name = cl_table_name
  AND    owner      = cl_owner
  AND    column_name not in ('LAST_UPDATE_DATE', 'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN',
                             'REQUEST_ID', 'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE');

  L_SCHEMA_NOTFOUND EXCEPTION;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.build_qualifier_rules1 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF mod(p_qual_relation_prd,79) = 0 THEN
         l_rel_prod1 := 79;
  ELSIF  mod(p_qual_relation_prd,137) = 0 THEN
         l_rel_prod1 := 137;
  ELSIF  mod(p_qual_relation_prd,113) = 0 THEN
         l_rel_prod1 := 113;
  ELSIF  mod(p_qual_relation_prd,131) = 0 THEN
         l_rel_prod1 := 131;
  ELSIF  mod(p_qual_relation_prd,139) = 0 THEN
         l_rel_prod1 := 139;
  ELSIF  mod(p_qual_relation_prd,163) = 0 THEN
         l_rel_prod1 := 163;
  ELSIF  mod(p_qual_relation_prd,167) = 0 THEN
         l_rel_prod1 := 167;
  END IF;

  p_sql := 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) USE_HASH(ILV1 ILV2) */ ';

  IF (p_new_mode_fetch = 'Y') THEN
    /* Get the schema name corresponding to JTF application */
    IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_owner)) THEN
      NULL;
    END IF;

    IF (l_owner IS NULL) THEN
      RAISE L_SCHEMA_NOTFOUND;
    END IF;

    /* Initialize local variables */
    first_time := TRUE;
    l_indent   := '  ';

    FOR column_names in c_column_names(p_trans_table_name, l_owner) LOOP
      IF (first_time) THEN
        p_sql := p_sql || g_new_line || l_indent || 'ILV2.' || column_names.column_name;
        first_time := FALSE;
      ELSE
        p_sql := p_sql || g_new_line || l_indent || ',' || 'ILV2.' || column_names.column_name;
      END IF;
    END LOOP;

    p_sql := p_sql || g_new_line || l_indent || ', ILV2.TERR_ID'
                   || g_new_line || l_indent || ', ILV2.ABSOLUTE_RANK'
                   || g_new_line || l_indent || ', ILV2.TOP_LEVEL_TERR_ID'
                   || g_new_line || l_indent || ', ILV2.NUM_WINNERS';
  ELSE
    p_sql := p_sql || g_new_line || l_indent || '  ILV2.trans_object_id'
                   || g_new_line || l_indent || ', ILV2.trans_detail_object_id'
                   || g_new_line || l_indent || ', ILV2.worker_id'
                   || g_new_line || l_indent || ', ILV2.terr_id'
                   || g_new_line || l_indent || ', ILV2.absolute_rank'
                   || g_new_line || l_indent || ', ILV2.top_level_terr_id'
                   || g_new_line || l_indent || ', ILV2.num_winners'
                   || g_new_line || l_indent || ', ILV2.org_id'
                   || g_new_line || l_indent || ', ILV2.txn_date';
  END IF; /* end IF (p_new_mode_fetch = 'Y') */

  p_sql := p_sql || g_new_line || l_indent || '  FROM ( /* INLINE VIEW1 */ ';

  build_ilv1(
    p_source_id          => p_source_id,
    p_trans_id           => p_trans_id,
    p_qual_relation_prd  => p_qual_relation_prd,
    p_relation_factor    => l_rel_prod1,
    p_mode               => p_mode,
    p_denorm_table_name  => p_denorm_table_name,
    p_new_mode_fetch     => p_new_mode_fetch,
    p_sql                => l_ilv1_sql,
    retcode              => retcode,
    errbuf               => errbuf);

  IF (retcode <> 0) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.build_ilv1',
                     'JTY_TAE_GEN_PVT.build_ilv1 API has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;


  p_sql := p_sql || l_ilv1_sql;

  p_sql := p_sql || g_new_line || l_indent || '       ) ILV1, ';
  p_sql := p_sql || g_new_line || l_indent || '       ( /* INLINE VIEW2 */ ';

  build_ilv2(
    p_source_id         => p_source_id,
    p_trans_id          => p_trans_id,
    p_program_name      => p_program_name,
    p_mode              => p_mode,
    p_qual_relation_prd => p_qual_relation_prd,
    p_relation_factor   => l_rel_prod1,
    p_trans_table_name  => p_trans_table_name,
    p_match_table_name  => p_match_table_name,
    p_denorm_table_name => p_denorm_table_name,
    p_new_mode_fetch    => p_new_mode_fetch,
    p_sql               => l_ilv2_sql,
    retcode             => retcode,
    errbuf              => errbuf);

  IF (retcode <> 0) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.build_qualifier_rules',
                     'JTY_TAE_GEN_PVT.build_qualifier_rules API has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  p_sql := p_sql || l_ilv2_sql;

  p_sql := p_sql || g_new_line || l_indent || '       ) ILV2 ';
  p_sql := p_sql || g_new_line || l_indent || '       WHERE ILV1.terr_id = ILV2.terr_id ';

  IF l_rel_prod1 = 79 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.customer_id = ILV2.squal_num01';
    p_sql := p_sql || g_new_line || l_indent || '         AND ( (ILV1.address_id IS NULL )';
    p_sql := p_sql || g_new_line || l_indent || '               OR ';
    p_sql := p_sql || g_new_line || l_indent || '               (ILV1.address_id= ILV2.squal_num02)';
    p_sql := p_sql || g_new_line || l_indent || '             )';
  ELSIF l_rel_prod1 = 137 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.sales_lead_id = ILV2.trans_object_id';
  ELSIF l_rel_prod1 = 113 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.sales_lead_id = ILV2.trans_object_id';
  ELSIF l_rel_prod1 = 131 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.sales_lead_id = ILV2.trans_object_id';
  ELSIF l_rel_prod1 = 139 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.lead_id = ILV2.trans_object_id';
  ELSIF l_rel_prod1 = 163 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.lead_id = ILV2.trans_object_id';
  ELSIF l_rel_prod1 = 167 THEN
    p_sql := p_sql || g_new_line || l_indent || '         AND ILV1.lead_id = ILV2.trans_object_id';
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.end',
                   'End of the procedure JTY_TAE_GEN_PVT.build_qualifier_rules1 ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.g_exc_error',
                     'API JTY_TAE_GEN_PVT..build_qualifier_rules1 has failed with FND_API.G_EXC_ERROR exception');

  WHEN L_SCHEMA_NOTFOUND THEN
    errbuf := 'Schema name corresponding to JTF application not found';
    retcode := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.l_schema_notfound',
                     errbuf);

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.build_qualifier_rules1.others',
                     substr(errbuf, 1, 4000));

END build_qualifier_rules1;

/* thie procedure builds the matching sql for qualifier combinations */
PROCEDURE gen_terr_rules_recurse (
  p_source_id         IN NUMBER,
  p_trans_id          IN NUMBER,
  p_program_name      IN VARCHAR2,
  p_mode              IN VARCHAR2,
  p_qual_relation_prd IN NUMBER,
  p_trans_table_name  IN VARCHAR2,
  p_match_table_name  IN VARCHAR2,
  p_denorm_table_name IN VARCHAR2,
  p_new_mode_fetch    IN VARCHAR2,
  p_match_sql         OUT NOCOPY CLOB,
  retcode             OUT NOCOPY VARCHAR2,
  errbuf              OUT NOCOPY VARCHAR2)
AS

  l_procedure_name       VARCHAR2(30);
  l_procedure_desc       VARCHAR2(255);
  l_parameter_list1      VARCHAR2(255);
  l_parameter_list2      VARCHAR2(360);

  l_str_len        NUMBER;
  l_start          NUMBER;
  l_get_nchar      NUMBER;
  l_next_newline   NUMBER;
  l_rule_str       VARCHAR2(256);
  l_indent         VARCHAR2(30);

  l_insert_nm_trans  VARCHAR2(3000);
  l_select_nm_trans  VARCHAR2(3000);

  l_match_sql        CLOB;
  l_sql              CLOB;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.gen_terr_rules_recurse ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF (p_new_mode_fetch = 'Y') THEN
    get_insert_select_nmtrans(
      p_match_table_name  => p_match_table_name,
      p_insert_stmt       => l_insert_nm_trans,
      p_select_stmt       => l_select_nm_trans,
      errbuf              => errbuf,
      retcode             => retcode);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.get_insert_select_nmtrans',
                       'JTY_TAE_GEN_PVT.get_insert_select_nmtrans API has failed');

      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF (p_new_mode_fetch = 'Y') THEN
    l_match_sql := l_insert_nm_trans;
  ELSE
      l_match_sql :=
        ' INSERT INTO  '|| p_match_table_name || ' i' ||
        ' ('  ||
        '   trans_object_id' ||
        '  ,trans_detail_object_id' ||
        '  ,worker_id' ||
        '  ,source_id' ||
        '  ,trans_object_type_id' ||
        '  ,last_update_date' ||
        '  ,last_updated_by' ||
        '  ,creation_date' ||
        '  ,created_by' ||
        '  ,last_update_login' ||
        '  ,request_id' ||
        '  ,program_application_id' ||
        '  ,program_id' ||
        '  ,program_update_date' ||
        '  ,terr_id' ||
        '  ,absolute_rank' ||
        '  ,top_level_terr_id' ||
        '  ,num_winners' ||
        '  ,org_id' ||
        '  ,txn_date' ||
        ' )' ;
  END IF; /* end IF ((p_new_mode_fetch = 'Y') AND (p_qual_relation_prd <> 4841)) */

  IF (p_new_mode_fetch = 'Y') THEN
    l_match_sql := l_match_sql || ' ' || l_select_nm_trans;
  ELSE
    IF ((mod(p_qual_relation_prd,79) = 0 and p_qual_relation_prd/79 <> 1) or       -- account classification
        (mod(p_qual_relation_prd,137) = 0 and p_qual_relation_prd/137 <> 1) or     -- lead expected purchase
        (mod(p_qual_relation_prd,113) = 0 and p_qual_relation_prd/113 <> 1) or     -- purchase amount
        (mod(p_qual_relation_prd,131) = 0 and p_qual_relation_prd/131 <> 1) or     -- lead inventory item
        (mod(p_qual_relation_prd,163) = 0 and p_qual_relation_prd/163 <> 1) or     -- opportunity inventory item
        (mod(p_qual_relation_prd,167) = 0 and p_qual_relation_prd/167 <> 1) or     -- opportunity classification
        (mod(p_qual_relation_prd,139) = 0 and p_qual_relation_prd/139 <> 1)) THEN  -- opportunity expected purchase

      l_match_sql := l_match_sql ||
                       ' SELECT /*+ USE_CONCAT */ DISTINCT ' ||
                       '    ILV2.trans_object_id' ||
                       '   ,ILV2.trans_detail_object_id' ||
                       '   ,ILV2.worker_id' ||
                       '   ,' || p_source_id ||
                       '   ,' || p_trans_id ||
                       '   ,:LAST_UPDATED_DATE ' ||
                       '   ,:LAST_UPDATED_BY ' ||
                       '   ,:CREATION_DATE ' ||
                       '   ,:CREATED_BY ' ||
                       '   ,:LAST_UPDATE_LOGIN ' ||
                       '   ,:REQUEST_ID ' ||
                       '   ,:PROGRAM_APPLICATION_ID ' ||
                       '   ,:PROGRAM_ID ' ||
                       '   ,:PROGRAM_UPDATE_DATE ' ||
                       '   ,ILV2.terr_id' ||
                       '   ,ILV2.absolute_rank' ||
                       '   ,ILV2.top_level_terr_id' ||
                       '   ,ILV2.num_winners' ||
                       '   ,ILV2.org_id' ||
                       '   ,ILV2.txn_date' ||
                       ' FROM  ';
    ELSE
      l_match_sql := l_match_sql ||
                       ' SELECT /*+ USE_CONCAT */ DISTINCT ' ||
                       '    A.trans_object_id' ||
                       '   ,A.trans_detail_object_id' ||
                       '   ,A.worker_id' ||
                       '   ,' || p_source_id ||
                       '   ,' || p_trans_id ||
                       '   ,:LAST_UPDATED_DATE ' ||
                       '   ,:LAST_UPDATED_BY ' ||
                       '   ,:CREATION_DATE ' ||
                       '   ,:CREATED_BY ' ||
                       '   ,:LAST_UPDATE_LOGIN ' ||
                       '   ,:REQUEST_ID ' ||
                       '   ,:PROGRAM_APPLICATION_ID ' ||
                       '   ,:PROGRAM_ID ' ||
                       '   ,:PROGRAM_UPDATE_DATE ' ||
                       '   ,ILV.terr_id' ||
                       '   ,ILV.absolute_rank' ||
                       '   ,ILV.top_level_terr_id' ||
                       '   ,ILV.num_winners' ||
                       '   ,ILV.org_id' ||
                       '   ,A.txn_date' ||
                       ' FROM  ';
    END IF;
  END IF; /* end if (p_new_mode_fetch = 'Y') */

  IF ((mod(p_qual_relation_prd,79) = 0 and p_qual_relation_prd/79 <> 1) or       -- account classification
      (mod(p_qual_relation_prd,137) = 0 and p_qual_relation_prd/137 <> 1) or     -- lead expected purchase
      (mod(p_qual_relation_prd,113) = 0 and p_qual_relation_prd/113 <> 1) or     -- purchase amount
      (mod(p_qual_relation_prd,131) = 0 and p_qual_relation_prd/131 <> 1) or     -- lead inventory item
      (mod(p_qual_relation_prd,163) = 0 and p_qual_relation_prd/163 <> 1) or     -- opportunity inventory item
      (mod(p_qual_relation_prd,167) = 0 and p_qual_relation_prd/167 <> 1) or     -- opportunity classification
      (mod(p_qual_relation_prd,139) = 0 and p_qual_relation_prd/139 <> 1)) THEN  -- opportunity expected purchase

    /* need bracket */
    l_match_sql := l_match_sql || ' ( ';

    Build_Qualifier_Rules1(
       p_source_id         => p_source_id
      ,p_trans_id          => p_trans_id
      ,p_program_name      => p_program_name
      ,p_mode              => p_mode
      ,p_qual_relation_prd => p_qual_relation_prd
      ,p_trans_table_name  => p_trans_table_name
      ,p_match_table_name  => p_match_table_name
      ,p_denorm_table_name => p_denorm_table_name
      ,p_new_mode_fetch    => p_new_mode_fetch
      ,p_sql               => l_sql
      ,retcode             => retcode
      ,errbuf              => errbuf);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.Build_Qualifier_Rules1',
                       'JTY_TAE_GEN_PVT.Build_Qualifier_Rules1 API has failed');

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_match_sql := l_match_sql || l_sql;

    IF p_new_mode_fetch = 'Y' THEN
      l_match_sql := l_match_sql || ' ) A  ';
    ELSE
      l_match_sql := l_match_sql || ' ) ILV2 ';
    END IF;
  ELSE
    /* brackets are not needed after FROM clause */
    Build_Qualifier_Rules(
       p_source_id         => p_source_id
      ,p_trans_id          => p_trans_id
      ,p_program_name      => p_program_name
      ,p_mode              => p_mode
      ,p_qual_relation_prd => p_qual_relation_prd
      ,p_relation_factor   => 1
      ,p_trans_table_name  => p_trans_table_name
      ,p_match_table_name  => p_match_table_name
      ,p_denorm_table_name => p_denorm_table_name
      ,p_new_mode_fetch    => p_new_mode_fetch
      ,p_sql               => l_sql
      ,retcode             => retcode
      ,errbuf              => errbuf);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.Build_Qualifier_Rules',
                       'JTY_TAE_GEN_PVT.Build_Qualifier_Rules API has failed');

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_match_sql := l_match_sql || l_sql;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.end',
                   'End of the procedure JTY_TAE_GEN_PVT.gen_terr_rules_recurse ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  p_match_sql := l_match_sql;

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.g_exc_error',
                     'API JTY_TAE_GEN_PVT.gen_terr_rules_recurse has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_terr_rules_recurse.others',
                     substr(errbuf, 1, 4000));

END gen_terr_rules_recurse;


/* entry point of this package, that generates the batch matching sql */
PROCEDURE gen_batch_sql (
  p_source_id       IN NUMBER,
  p_trans_id        IN NUMBER,
  p_mode            IN VARCHAR2,
  p_qual_prd_tbl    IN JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status   OUT NOCOPY VARCHAR2,
  x_Msg_Count       OUT NOCOPY NUMBER,
  x_Msg_Data        OUT NOCOPY VARCHAR2,
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2)

AS

  CURSOR c_pgm_details (cl_mode VARCHAR2, cl_source_id NUMBER, cl_trans_id NUMBER) IS
  select
     a.program_name
    ,decode(cl_mode, 'DATE EFFECTIVE', a.batch_dea_trans_table_name, a.batch_trans_table_name)
    ,a.batch_nm_trans_table_name
    ,a.batch_match_table_name
  from  jty_trans_usg_pgm_details a
  where a.source_id = cl_source_id
  and   a.trans_type_id = cl_trans_id
  and   a.batch_enable_flag = 'Y';

  TYPE l_pgm_name_tbl_type IS TABLE OF jty_trans_usg_pgm_details.program_name%TYPE;
  TYPE l_trans_tbl_type IS TABLE OF jty_trans_usg_pgm_details.batch_trans_table_name%TYPE;
  TYPE l_nm_trans_tbl_type IS TABLE OF jty_trans_usg_pgm_details.batch_nm_trans_table_name%TYPE;
  TYPE l_match_tbl_type IS TABLE OF jty_trans_usg_pgm_details.batch_match_table_name%TYPE;

  l_pgm_name_tbl  l_pgm_name_tbl_type;
  l_trans_tbl     l_trans_tbl_type;
  l_nm_trans_tbl  l_nm_trans_tbl_type;
  l_match_tbl     l_match_tbl_type;

  l_denorm_table_name  VARCHAR2(50);
  l_no_of_records      NUMBER;
  l_match_sql          CLOB;
  l_nm_match_sql       CLOB;
  l_nmc_match_sql      CLOB;
  l_match_sql_terr_based  CLOB;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.start',
                   'Start of the procedure JTY_TAE_GEN_PVT.gen_batch_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF (p_qual_prd_tbl.COUNT = 0) THEN
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.no_qual_product',
                     'JTY_TAE_GEN_PVT.gen_batch_sql API has failed as there is no qual product to be processed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_mode = 'DATE EFFECTIVE') THEN
    SELECT denorm_dea_value_table_name
    INTO   l_denorm_table_name
    FROM   jtf_sources_all
    WHERE  source_id = p_source_id;

    jty_tae_control_pvt.Classify_dea_Territories (
      p_source_id     => p_source_id,
      p_trans_id      => p_trans_id,
      p_qual_prd_tbl  => p_qual_prd_tbl,
      x_Return_Status => x_Return_Status,
      x_Msg_Count     => x_Msg_Count,
      x_Msg_Data      => x_Msg_Data,
      ERRBUF          => errbuf,
      RETCODE         => retcode );

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.Classify_dea_Territories',
                         'jty_tae_control_pvt.Classify_dea_Territories API has failed');

        RAISE FND_API.G_EXC_ERROR;
      END IF;
  ELSE
    SELECT denorm_value_table_name
    INTO   l_denorm_table_name
    FROM   jtf_sources_all
    WHERE  source_id = p_source_id;

    jty_tae_control_pvt.Classify_Territories (
      p_source_id     => p_source_id,
      p_trans_id      => p_trans_id,
      p_mode          => p_mode,
      p_qual_prd_tbl  => p_qual_prd_tbl,
      x_Return_Status => x_Return_Status,
      x_Msg_Count     => x_Msg_Count,
      x_Msg_Data      => x_Msg_Data,
      ERRBUF          => errbuf,
      RETCODE         => retcode );

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.Classify_Territories',
                         'jty_tae_control_pvt.Classify_Territories API has failed');

        RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */

  OPEN c_pgm_details(p_mode, p_source_id, p_trans_id);
  FETCH c_pgm_details BULK COLLECT INTO
     l_pgm_name_tbl
    ,l_trans_tbl
    ,l_nm_trans_tbl
    ,l_match_tbl;
  CLOSE c_pgm_details;

  IF (l_pgm_name_tbl.COUNT > 0) THEN
    FOR i IN l_pgm_name_tbl.FIRST .. l_pgm_name_tbl.LAST LOOP
      FOR j IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST LOOP

        IF (p_mode = 'DATE EFFECTIVE') THEN
          SELECT count(*)
          INTO   l_no_of_records
          FROM   jty_dea_attr_products_sql
          WHERE  source_id = p_source_id
          AND    trans_type_id = p_trans_id
          AND    program_name = l_pgm_name_tbl(i)
          AND    attr_relation_product = p_qual_prd_tbl(j);
        ELSE
          SELECT count(*)
          INTO   l_no_of_records
          FROM   jty_tae_attr_products_sql
          WHERE  source_id = p_source_id
          AND    trans_type_id = p_trans_id
          AND    program_name = l_pgm_name_tbl(i)
          AND    attr_relation_product = p_qual_prd_tbl(j);
        END IF;

        IF (l_no_of_records = 0) THEN
          gen_terr_rules_recurse (
            p_source_id         => p_source_id,
            p_trans_id          => p_trans_id,
            p_program_name      => l_pgm_name_tbl(i),
            p_mode              => p_mode,
            p_qual_relation_prd => p_qual_prd_tbl(j),
            p_trans_table_name  => l_trans_tbl(i),
            p_match_table_name  => l_match_tbl(i),
            p_denorm_table_name => l_denorm_table_name,
            p_new_mode_fetch    => 'N',
            p_match_sql         => l_match_sql,
            retcode             => retcode,
            errbuf              => errbuf);

          IF (retcode <> 0) THEN
            -- debug message
              jty_log(FND_LOG.LEVEL_EXCEPTION,
                             'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.gen_terr_rules_recurse1',
                             'JTY_TAE_GEN_PVT.gen_terr_rules_recurse API has failed');

            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_mode <> 'DATE EFFECTIVE') THEN
            gen_terr_rules_recurse (
              p_source_id         => p_source_id,
              p_trans_id          => p_trans_id,
              p_program_name      => l_pgm_name_tbl(i),
              p_mode              => p_mode,
              p_qual_relation_prd => p_qual_prd_tbl(j),
              p_trans_table_name  => l_trans_tbl(i),
              p_match_table_name  => l_nm_trans_tbl(i),
              p_denorm_table_name => l_denorm_table_name,
              p_new_mode_fetch    => 'Y',
              p_match_sql         => l_nmc_match_sql,
              retcode             => retcode,
              errbuf              => errbuf);

            IF (retcode <> 0) THEN
              -- debug message
                jty_log(FND_LOG.LEVEL_EXCEPTION,
                               'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.gen_terr_rules_recurse2',
                               'JTY_TAE_GEN_PVT.gen_terr_rules_recurse API has failed');

              RAISE FND_API.G_EXC_ERROR;
            END IF;

            gen_terr_rules_recurse (
              p_source_id         => p_source_id,
              p_trans_id          => p_trans_id,
              p_program_name      => l_pgm_name_tbl(i),
              p_mode              => p_mode,
              p_qual_relation_prd => p_qual_prd_tbl(j),
              p_trans_table_name  => l_nm_trans_tbl(i),
              p_match_table_name  => l_match_tbl(i),
              p_denorm_table_name => l_denorm_table_name,
              p_new_mode_fetch    => 'N',
              p_match_sql         => l_nm_match_sql,
              retcode             => retcode,
              errbuf              => errbuf);

            IF (retcode <> 0) THEN
              -- debug message
                jty_log(FND_LOG.LEVEL_EXCEPTION,
                               'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.gen_terr_rules_recurse3',
                               'JTY_TAE_GEN_PVT.gen_terr_rules_recurse API has failed');

              RAISE FND_API.G_EXC_ERROR;
            END IF;

            INSERT INTO JTY_TAE_ATTR_PRODUCTS_SQL(
               ATTR_PRODUCTS_SQL_ID
              ,SOURCE_ID
              ,TRANS_TYPE_ID
              ,PROGRAM_NAME
              ,ATTR_RELATION_PRODUCT
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,BATCH_MATCH_SQL
              ,BATCH_NM_MATCH_SQL
              ,BATCH_NMC_MATCH_SQL
              ,KEEP_FLAG
              ,PROGRAM_ID
              ,PROGRAM_LOGIN_ID
              ,PROGRAM_APPLICATION_ID
              ,REQUEST_ID
              ,PROGRAM_UPDATE_DATE)
            VALUES(
               JTY_TAE_ATTR_PRODUCTS_SQL_S.NEXTVAL
              ,p_source_id
              ,p_trans_id
              ,l_pgm_name_tbl(i)
              ,p_qual_prd_tbl(j)
              ,G_SYSDATE
              ,G_USER_ID
              ,G_SYSDATE
              ,G_USER_ID
              ,G_USER_ID
              ,l_match_sql
              ,l_nm_match_sql
              ,l_nmc_match_sql
              ,'N'
              ,G_REQUEST_ID
              ,G_PROGRAM_APPL_ID
              ,G_PROGRAM_ID
              ,G_REQUEST_ID
              ,G_SYSDATE
            );

          ELSE
		  l_match_sql_terr_based := l_match_sql || ' AND B.terr_id = :p_territory_id';
            INSERT INTO JTY_DEA_ATTR_PRODUCTS_SQL(
               DEA_ATTR_PRODUCTS_SQL_ID
              ,SOURCE_ID
              ,TRANS_TYPE_ID
              ,PROGRAM_NAME
              ,ATTR_RELATION_PRODUCT
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,BATCH_DEA_MATCH_SQL
              ,KEEP_FLAG
              ,PROGRAM_ID
              ,PROGRAM_LOGIN_ID
              ,PROGRAM_APPLICATION_ID
              ,REQUEST_ID
              ,PROGRAM_UPDATE_DATE
			  ,BATCH_DEA_MATCH_SQL_WITH_TERR)
            VALUES(
               JTY_DEA_ATTR_PRODUCTS_SQL_S.NEXTVAL
              ,p_source_id
              ,p_trans_id
              ,l_pgm_name_tbl(i)
              ,p_qual_prd_tbl(j)
              ,G_SYSDATE
              ,G_USER_ID
              ,G_SYSDATE
              ,G_USER_ID
              ,G_USER_ID
              ,l_match_sql
              ,'N'
              ,G_REQUEST_ID
              ,G_PROGRAM_APPL_ID
              ,G_PROGRAM_ID
              ,G_REQUEST_ID
              ,G_SYSDATE
			  ,l_match_sql_terr_based
            );
          END IF; /* end IF (p_mode <> 'DATE EFFECTIVE') */
        END IF; /* end IF (l_no_of_records = 0) */
      END LOOP; /* end loop FOR j IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST */
    END LOOP; /* end loop FOR i IN l_pgm_name_tbl.FIRST .. l_pgm_name_tbl.LAST */
  END IF; /* end IF (l_pgm_name_tbl.COUNT > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.end',
                   'End of the procedure JTY_TAE_GEN_PVT.gen_batch_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.g_exc_error',
                     'API JTY_TAE_GEN_PVT.gen_batch_sql has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_GEN_PVT.gen_batch_sql.others',
                     substr(errbuf, 1, 4000));
END gen_batch_sql;

END JTY_TAE_GEN_PVT;

/
