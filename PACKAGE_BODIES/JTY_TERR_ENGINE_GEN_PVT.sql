--------------------------------------------------------
--  DDL for Package Body JTY_TERR_ENGINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TERR_ENGINE_GEN_PVT" AS
/* $Header: jtfytegb.pls 120.9.12010000.13 2009/04/08 13:28:06 sseshaiy ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the complete territory
--      Engine based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/27/05    ACHANDA         Created
--
--    End of Comments
--
--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

   /* Global System Variables */
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_SYSDATE         DATE         := SYSDATE;

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
/* this procedure looks at the table jty_changed_terrs and retrive the master */
/* list that need to be processed by incremental star                         */
PROCEDURE get_terr_for_incr_star (
  p_source_id       IN  NUMBER,
  p_request_id      IN  NUMBER,
  p_terr_change_tab OUT NOCOPY terr_change_type,
  retcode           OUT NOCOPY VARCHAR2,
  errbuf            OUT NOCOPY VARCHAR2
)
AS

  CURSOR c_changed_terrs (cl_request_id IN NUMBER) IS
  SELECT a.terr_id,
         a.rank_calc_flag,
         a.process_attr_values_flag,
         a.matching_sql_flag,
         a.hier_processing_flag
  FROM   jty_changed_terrs a
  WHERE  a.star_request_id = cl_request_id
  AND    a.source_id = p_source_id
  AND   (a.rank_calc_flag <> 'N' OR a.process_attr_values_flag <> 'N' OR
         a.matching_sql_flag <> 'N' OR a.hier_processing_flag <> 'N')
  AND   NOT EXISTS (
                    SELECT jt.terr_id
                    FROM   jtf_terr_all jt
                    WHERE  jt.end_date_active < sysdate
                    OR     jt.start_date_active > sysdate
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = a.terr_id )
  UNION ALL
  SELECT a.terr_id,
         'N',
         'D',
         'Y',
         'D'
  FROM   jtf_terr_all a
  WHERE  (a.start_date_active > sysdate
  OR     a.end_date_active < sysdate)
  AND    exists (
           SELECT 1
           FROM   jty_changed_terrs b
           WHERE  b.terr_id = a.terr_id
           AND    b.star_request_id = cl_request_id
           AND    b.source_id = p_source_id);

  CURSOR c_child_terrs (cl_terr_id IN NUMBER) IS
  SELECT terr_id
  FROM  jtf_terr_all
  START WITH terr_id = cl_terr_id
  CONNECT BY PRIOR terr_id = parent_territory_id;

  TYPE l_terr_id_tbl_type IS TABLE OF jty_changed_terrs.terr_id%TYPE;
  TYPE l_rank_tbl_type IS TABLE OF jty_changed_terrs.rank_calc_flag%TYPE;
  TYPE l_attr_values_tbl_type IS TABLE OF jty_changed_terrs.process_attr_values_flag%TYPE;
  TYPE l_match_sql_tbl_type IS TABLE OF jty_changed_terrs.matching_sql_flag%TYPE;
  TYPE l_hier_tbl_type IS TABLE OF jty_changed_terrs.hier_processing_flag%TYPE;

  l_terr_id_tbl     l_terr_id_tbl_type;
  l_rank_tbl        l_rank_tbl_type;
  l_attr_values_tbl l_attr_values_tbl_type;
  l_match_sql_tbl   l_match_sql_tbl_type;
  l_hier_tbl        l_hier_tbl_type;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.get_terr_for_incr_star.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN_PVT.get_terr_for_incr_star ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Insert into jty_changed_terrs the territories that */
  /* have become active after the last run of STAR      */
  MERGE INTO jty_changed_terrs A
  USING
    ( SELECT
         a.terr_id terr_id,
         b.source_id source_id
      FROM   jtf_terr_all a,
             jtf_terr_usgs_all b
      WHERE  a.terr_id = b.terr_id
      AND    b.source_id = p_source_id
      AND    a.start_date_active >
              (SELECT max(end_date)
               FROM   jty_conc_req_summ a
               WHERE  a.program_name = 'JTY_STAR'
               AND    a.param1       = to_char(p_source_id)
               AND    a.retcode      = 0)
      AND    a.start_date_active < sysdate
      AND    a.end_date_active   > sysdate
      AND    NOT EXISTS (
                        SELECT jt.terr_id
                        FROM   jtf_terr_all jt
                        WHERE  jt.end_date_active < sysdate
                        OR     jt.start_date_active > sysdate
                        CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                        START WITH jt.terr_id = a.terr_id ) ) S
  ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
  WHEN MATCHED THEN
    UPDATE SET
       A.rank_calc_flag = 'Y'
      ,A.process_attr_values_flag = 'I'
      ,A.matching_sql_flag = 'Y'
      ,A.hier_processing_flag = 'I'
  WHEN NOT MATCHED THEN
    INSERT (
       A.CHANGED_TERRITORY_ID
      ,A.OBJECT_VERSION_NUMBER
      ,A.TERR_ID
      ,A.SOURCE_ID
      ,A.CHANGE_TYPE
      ,A.RANK_CALC_FLAG
      ,A.PROCESS_ATTR_VALUES_FLAG
      ,A.MATCHING_SQL_FLAG
      ,A.HIER_PROCESSING_FLAG)
    VALUES (
       jty_changed_terrs_s.nextval
      ,0
      ,S.terr_id
      ,S.source_id
      ,'UPDATE'
      ,'Y'
      ,'I'
      ,'Y'
      ,'I');

  /* Insert into jty_changed_terrs the territories that */
  /* have become inactive after the last run of STAR    */
  MERGE INTO jty_changed_terrs A
  USING
    ( SELECT
         a.terr_id terr_id,
         b.source_id source_id
      FROM   jtf_terr_all a,
             jtf_terr_usgs_all b
      WHERE  a.terr_id = b.terr_id
      AND    b.source_id = p_source_id
      AND    a.end_date_active >
              (SELECT max(end_date)
               FROM   jty_conc_req_summ a
               WHERE  a.program_name = 'JTY_STAR'
               AND    a.param1       = to_char(p_source_id)
               AND    a.retcode      = 0)
      AND    a.end_date_active < sysdate ) S
  ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
  WHEN MATCHED THEN
    UPDATE SET
       A.rank_calc_flag = 'N'
      ,A.process_attr_values_flag = 'D'
      ,A.matching_sql_flag = 'Y'
      ,A.hier_processing_flag = 'D'
  WHEN NOT MATCHED THEN
    INSERT (
       A.CHANGED_TERRITORY_ID
      ,A.OBJECT_VERSION_NUMBER
      ,A.TERR_ID
      ,A.SOURCE_ID
      ,A.CHANGE_TYPE
      ,A.RANK_CALC_FLAG
      ,A.PROCESS_ATTR_VALUES_FLAG
      ,A.MATCHING_SQL_FLAG
      ,A.HIER_PROCESSING_FLAG)
    VALUES (
       jty_changed_terrs_s.nextval
      ,0
      ,S.terr_id
      ,S.source_id
      ,'UPDATE'
      ,'N'
      ,'D'
      ,'Y'
      ,'D');

  DELETE jty_changed_terrs_gt;

  UPDATE jty_changed_terrs a
  SET    a.star_request_id = p_request_id
  WHERE  a.star_request_id IS NULL
  AND    a.source_id = p_source_id;

  OPEN c_changed_terrs(p_request_id);
  FETCH c_changed_terrs BULK COLLECT INTO
    l_terr_id_tbl,
    l_rank_tbl,
    l_attr_values_tbl,
    l_match_sql_tbl,
    l_hier_tbl;
  CLOSE c_changed_terrs;

  IF (l_terr_id_tbl.COUNT > 0) THEN
    FOR i IN l_terr_id_tbl.FIRST .. l_terr_id_tbl.LAST LOOP
      INSERT INTO jty_changed_terrs_gt (
         terr_id
        ,rank_calc_flag
        ,process_attr_values_flag
        ,matching_sql_flag
        ,hier_processing_flag)
      VALUES (
         l_terr_id_tbl(i)
        ,l_rank_tbl(i)
        ,l_attr_values_tbl(i)
        ,l_match_sql_tbl(i)
        ,l_hier_tbl(i));

      FOR child_terrs IN c_child_terrs (l_terr_id_tbl(i)) LOOP
        UPDATE jty_changed_terrs_gt
        SET    rank_calc_flag = decode(rank_calc_flag, 'Y', 'Y', l_rank_tbl(i)),
               process_attr_values_flag =
                           decode(process_attr_values_flag,
                                    'I', 'I',
                                    'D', decode(l_attr_values_tbl(i), 'I', 'I', 'D'),
                                    l_attr_values_tbl(i)),
               matching_sql_flag = decode(matching_sql_flag, 'Y', 'Y', l_match_sql_tbl(i)),
               hier_processing_flag =
                           decode(hier_processing_flag,
                                    'I', 'I',
                                    'D', decode(l_hier_tbl(i), 'I', 'I', 'D'),
                                    l_hier_tbl(i))
        WHERE  terr_id = child_terrs.terr_id;

        IF (SQL%ROWCOUNT = 0) THEN
          INSERT INTO jty_changed_terrs_gt (
             terr_id
            ,rank_calc_flag
            ,process_attr_values_flag
            ,matching_sql_flag
            ,hier_processing_flag)
          VALUES (
             child_terrs.terr_id
            ,l_rank_tbl(i)
            ,l_attr_values_tbl(i)
            ,l_match_sql_tbl(i)
            ,l_hier_tbl(i));
        END IF;

      END LOOP; /* end loop FOR child_terrs IN c_child_terrs (l_terr_id_tbl(i)) */
    END LOOP; /* end loop FOR i IN l_terr_id_tbl.FIRST .. l_terr_id_tbl.LAST */
  END IF; /* end IF (l_terr_id_tbl.COUNT > 0) */

  SELECT
    a.terr_id
   ,a.rank_calc_flag
   ,a.process_attr_values_flag
   ,a.matching_sql_flag
   ,a.hier_processing_flag
   ,b.rank
   ,b.parent_territory_id
   ,JTY_TERR_DENORM_RULES_PVT.get_level_from_root(a.terr_id)
   ,b.num_winners
   ,b.org_id
   ,c.num_winners
   ,b.start_date_active
   ,b.end_date_active
  BULK COLLECT INTO
    p_terr_change_tab.terr_id
   ,p_terr_change_tab.rank_calc_flag
   ,p_terr_change_tab.attr_processing_flag
   ,p_terr_change_tab.matching_sql_flag
   ,p_terr_change_tab.hier_processing_flag
   ,p_terr_change_tab.terr_rank
   ,p_terr_change_tab.parent_terr_id
   ,p_terr_change_tab.level_from_root
   ,p_terr_change_tab.num_winners
   ,p_terr_change_tab.org_id
   ,p_terr_change_tab.parent_num_winners
   ,p_terr_change_tab.start_date
   ,p_terr_change_tab.end_date
  FROM
     jty_changed_terrs_gt a
    ,jtf_terr_all b
    ,jtf_terr_all c
  WHERE a.terr_id = b.terr_id(+)
  AND   b.parent_territory_id = c.terr_id(+)
  AND   b.org_id = c.org_id(+);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.get_terr_for_incr_star.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN_PVT.get_terr_for_incr_star ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.get_terr_for_incr_star.others',
                     substr(errbuf, 1, 4000));

END get_terr_for_incr_star;

/* this procedure calls APIs to generate real time and batch matching SQLs */
PROCEDURE gen_matching_sql (
  p_source_id       IN NUMBER,
  p_mode            IN VARCHAR2,
  p_terr_change_tab terr_change_type,
  p_start_date      IN DATE,
  p_end_date        IN DATE,
  x_Return_Status   OUT NOCOPY VARCHAR2,
  x_Msg_Count       OUT NOCOPY NUMBER,
  x_Msg_Data        OUT NOCOPY VARCHAR2,
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2
)
AS

  CURSOR c_trans_types (cl_source_id NUMBER) IS
  SELECT qual_type_id
  FROM   jtf_qual_type_usgs_all
  WHERE  source_id = cl_source_id
  AND    qual_type_id <> -1001;

  CURSOR c_qual_rel_sets(cl_source_id number, cl_qual_type_id number) is
  select distinct jtqu.qual_relation_product
  from jtf_terr_qtype_usgs_all jtqu
      ,jtf_qual_type_usgs_all jqtu
  where jqtu.source_id = cl_source_id
  and jqtu.qual_type_id = cl_qual_type_id
  and jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
  and jtqu.qual_relation_product <> 1
  and exists (
          select /*+ index_ffs(jtdr jtf_terr_denorm_rules_n1) */ 1
		  from   jtf_terr_denorm_rules_all jtdr
		  where  jtdr.terr_id = jtqu.terr_id
		  and    jtqu.terr_id = jtdr.related_terr_id );

  CURSOR c_dea_qual_rel_sets(cl_source_id number, cl_qual_type_id number) is
  select distinct jtqu.qual_relation_product
  from jtf_terr_qtype_usgs_all jtqu
      ,jtf_qual_type_usgs_all jqtu
  where jqtu.source_id = cl_source_id
  and jqtu.qual_type_id = cl_qual_type_id
  and jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
  and jtqu.qual_relation_product <> 1
  and exists (
          select /*+ index_ffs(jtdr jty_denorm_dea_rules_n1) */ 1
		  from   jty_denorm_dea_rules_all jtdr
		  where  jtdr.terr_id = jtqu.terr_id
		  and    jtqu.terr_id = jtdr.related_terr_id );

  TYPE l_qual_type_id_tbl_type IS TABLE OF jtf_qual_type_usgs_all.qual_type_id%TYPE;

  l_qual_type_id_tbl l_qual_type_id_tbl_type;
  l_qual_prd_tbl     qual_prd_tbl_type;

  l_new_qual_prd           BOOLEAN;
  l_sysdate                DATE;
  l_qual_relation_product  NUMBER;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_sysdate      := SYSDATE;
  l_qual_prd_tbl := qual_prd_tbl_type();

  /* get all the transaction types */
  OPEN c_trans_types(p_source_id);
  FETCH c_trans_types BULK COLLECT INTO
    l_qual_type_id_tbl;
  CLOSE c_trans_types;

  IF (l_qual_type_id_tbl.COUNT > 0) THEN
    FOR i IN l_qual_type_id_tbl.FIRST .. l_qual_type_id_tbl.LAST LOOP

      /* always generate the real time matching sql */
      JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql (
        p_source_id  => p_source_id,
        p_trans_id   => l_qual_type_id_tbl(i),
        p_mode       => p_mode,
        p_start_date => p_start_date,
        p_end_date   => p_end_date,
        errbuf       => errbuf,
        retcode      => retcode);
      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.gen_real_time_sql',
                         'JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql API has failed');

        RAISE  FND_API.G_EXC_ERROR;
      END IF;


      /* delete the old records from the tables jtf_tae_qual_products, jtf_tae_qual_factors */
      /* and jtf_tae_qual_prod_factors if mode is total or incremental                      */
      /* delete the old records from the tables jtf_dea_attr_products, jtf_dea_attr_factors */
      /* and jtf_dea_attr_prod_factors if mode is date effective                            */
      JTY_TAE_CONTROL_PVT.delete_combinations(
        p_source_id     => p_source_id,
        p_trans_id      => l_qual_type_id_tbl(i),
        p_mode          => p_mode,
        x_Return_Status => x_return_status,
        x_Msg_Count     => x_msg_count,
        x_Msg_Data      => x_msg_data,
        ERRBUF          => errbuf,
        RETCODE         => retcode);

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.delete_combinations',
                         'JTY_TAE_CONTROL_PVT.delete_combinations API has failed');

        RAISE	FND_API.G_EXC_ERROR;
      END IF;

      /* if mode is total or date effective, get all the qualifier combinations for the active territories */
      /* if mode is incremental, get all the distinct qualifier comb for the territories with              */
      /* matching_sql_flag = 'Y' in p_terr_change_tab                                                      */
      IF (p_mode = 'TOTAL') THEN
        OPEN c_qual_rel_sets(p_source_id, l_qual_type_id_tbl(i));
        FETCH c_qual_rel_sets BULK COLLECT INTO
           l_qual_prd_tbl;
        CLOSE c_qual_rel_sets;
      ELSIF (p_mode = 'DATE EFFECTIVE') THEN
        OPEN c_dea_qual_rel_sets(p_source_id, l_qual_type_id_tbl(i));
        FETCH c_dea_qual_rel_sets BULK COLLECT INTO
           l_qual_prd_tbl;
        CLOSE c_dea_qual_rel_sets;
      ELSIF (p_mode = 'INCREMENTAL') THEN
        FOR j in p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST LOOP
          IF (p_terr_change_tab.matching_sql_flag(j) = 'Y') THEN

            BEGIN
              SELECT a.qual_relation_product
              INTO   l_qual_relation_product
              FROM   jtf_terr_qtype_usgs_all a,
                     jtf_qual_type_usgs_all  b,
                     jtf_terr_all c
              WHERE  a.qual_type_usg_id = b.qual_type_usg_id
              AND    b.source_id = p_source_id
              AND    b.qual_type_id = l_qual_type_id_tbl(i)
              AND    a.terr_id = p_terr_change_tab.terr_id(j)
              AND    c.terr_id = a.terr_id
              AND    c.start_date_active < sysdate
              AND    c.end_date_active > sysdate
              AND    a.qual_relation_product <> 1
              AND    NOT EXISTS (
                           SELECT 1
                           FROM   jtf_tae_qual_products c
                           WHERE  c.source_id = p_source_id
                           AND    c.trans_object_type_id = l_qual_type_id_tbl(i)
                           AND    c.relation_product = a.qual_relation_product);

              /* check if the qual rel prd alreday exists in the pl/sql table that will be processed */
              l_new_qual_prd := TRUE;
              IF (l_qual_prd_tbl.COUNT > 0) THEN
                FOR k in l_qual_prd_tbl.FIRST .. l_qual_prd_tbl.LAST LOOP
                  IF (l_qual_relation_product = l_qual_prd_tbl(k)) THEN
                    l_new_qual_prd := FALSE;
                    exit;
                  END IF;
                END LOOP;
              END IF;

              /* insert the current qual rel prd into the pl/sql table only if it does not exist */
              IF (l_new_qual_prd) THEN
                l_qual_prd_tbl.EXTEND();
                l_qual_prd_tbl(l_qual_prd_tbl.COUNT) := l_qual_relation_product;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;

          END IF; /* end IF (p_terr_change_tab.matching_sql_flag = 'Y') */
        END LOOP; /* end loop FOR j in p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST */
      END IF; /* end IF (p_mode = 'TOTAL') */

      /* generate the batch matching sql for all qualifier combinations present in l_qual_type_id_tbl */
      IF (l_qual_prd_tbl.COUNT > 0) THEN
        jty_tae_gen_pvt.gen_batch_sql(
          p_source_id     => p_source_id,
          p_trans_id      => l_qual_type_id_tbl(i),
          p_mode          => p_mode,
          p_qual_prd_tbl  => l_qual_prd_tbl,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          errbuf          => errbuf,
          retcode         => retcode);

        IF (retcode <> 0) THEN
          -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.gen_batch_sql',
                           'jty_tae_gen_pvt.gen_batch_sql API has failed');

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

      END IF; /* end IF (l_qual_prd_tbl.COUNT > 0) */

      l_qual_prd_tbl.TRIM(l_qual_prd_tbl.COUNT);

    END LOOP; /* end loop FOR i IN l_qual_type_id_tbl.FIRST .. l_qual_type_id_tbl.LAST */
  END IF; /* end IF (l_qual_type_id_tbl.COUNT > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.g_exc_error',
                     'API JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_matching_sql.others',
                     substr(errbuf, 1, 4000));

END gen_matching_sql;

/* entry point of the concurrent program STAR */
PROCEDURE gen_rule_engine (
  errbuf       OUT NOCOPY VARCHAR2,
  retcode      OUT NOCOPY VARCHAR2,
  p_source_id  IN         NUMBER,
  p_mode       IN         VARCHAR2,
  p_start_date IN         VARCHAR2,
  p_end_date   IN         VARCHAR2
)
AS

  CURSOR csr_get_terr(lp_source_id NUMBER, lp_start_date DATE, lp_end_date DATE) IS
  SELECT /* index(JTA2 JTF_TERR_U1) */  jta1.terr_id                terr_id
        ,NVL(jta1.rank, 999999999)  rank
        ,jta1.num_winners           num_winners
        ,jta1.org_id                org_id
        ,jta1.parent_territory_id   parent_territory_id
        ,JTY_TERR_DENORM_RULES_PVT.get_level_from_root(jta1.terr_id) level_from_root
        ,jta2.num_winners           parent_num_winners
        ,'Y'                        rank_calc_flag
        ,'I'                        attr_processing_flag
        ,'I'                        hier_processing_flag
        ,'Y'                        matching_sql_flag
        ,jta1.start_date_active     start_date
        ,jta1.end_date_active       end_date
  FROM   jtf_terr_usgs_all jtu
       , jtf_terr_all jta1
       , jtf_terr_all jta2
  WHERE jtu.source_id = lp_source_id
  AND   jtu.terr_id = jta1.terr_id
  AND   jta1.terr_id <> 1
  AND   jta1.end_date_active >= lp_start_date
  AND   jta1.start_date_active <= lp_end_date
  AND   jta2.terr_id = jta1.parent_territory_id
  AND   ( jta1.org_id = jta2.org_id OR
            (jta1.org_id IS NULL AND jta2.org_id IS NULL) )
  AND   NOT EXISTS (
                    SELECT /* index(JT JTF_TERR_U1) */ jt.terr_id
                    FROM   jtf_terr_all jt
                    WHERE  jt.end_date_active < lp_start_date
                    OR     jt.start_date_active > lp_end_date
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = jta1.terr_id );

  l_terr_change_tab  terr_change_type;
  l_no_of_records    NUMBER;
  l_batch_enabled    NUMBER;
  l_count            NUMBER;
  l_table_name       VARCHAR2(30);

  l_return_status    VARCHAR2(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  l_resp_appl_id     NUMBER;
  l_resp_id          NUMBER;
  l_user_id          NUMBER;
  l_login_id         NUMBER;
  l_sysdate          DATE;
  l_start_date       DATE;
  l_end_date         DATE;
  l_pgm_appl_id      NUMBER;
  l_pgm_name         VARCHAR2(360);
  l_conc_pgm_id      NUMBER;

  l_param_start_date DATE;
  l_param_end_date   DATE;
  l_denorm_count     NUMBER;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Initialize audit columns */
  l_start_date   := SYSDATE;
  l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
  l_resp_id      := FND_GLOBAL.RESP_ID;
  l_user_id      := FND_GLOBAL.USER_ID;
  l_login_id     := FND_GLOBAL.CONC_LOGIN_ID;
  l_pgm_appl_id  := FND_GLOBAL.PROG_APPL_ID;
  l_conc_pgm_id  := FND_GLOBAL.CONC_PROGRAM_ID;
  l_pgm_name     := 'JTY_STAR';

  l_param_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  l_param_end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

  /* mark the records in the changed table that will be processed */
  IF (p_mode = 'TOTAL') THEN
    UPDATE jty_changed_terrs
    SET    star_request_id = g_request_id
    WHERE  source_id = p_source_id
    AND    star_request_id IS NULL;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.param_values',
                   'Source : ' || p_source_id || ' Mode : ' || p_mode || ' Start Date : ' || p_start_date ||
                       ' End Date : ' || p_end_date);

  /* if mode = incremental , get all the territories that need to be processed from incr_gtp                            */
  /* if mode = total , get all the active territories , as of sysdate, from jtf_terr_all                                */
  /* if mode = date effective , get all the active territories , between p_start_date and p_end_date, from jtf_terr_all */
  IF (p_mode = 'INCREMENTAL') THEN
    BEGIN
      SELECT count(*)
      INTO   l_count
      FROM   jty_conc_req_summ a
      WHERE  a.program_name = 'JTY_STAR'
      AND    a.param1       = p_source_id
      AND    a.param2       = 'TOTAL'
      AND    a.retcode      = 0;

      IF (l_count = 0) THEN
        -- debug message
        retcode := 2;
        errbuf  := 'STAR should be run at least once in TOTAL mode before INCREMENTAL mode';
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.check_total_mode',
                         errbuf);

        RAISE	FND_API.G_EXC_ERROR;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;

    get_terr_for_incr_star (
      p_source_id       => p_source_id,
      p_request_id      => g_request_id,
      p_terr_change_tab => l_terr_change_tab,
      retcode           => retcode,
      errbuf            => errbuf);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.get_terr_for_incr_star',
                       'get_terr_for_incr_star API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  ELSE
    IF (p_mode = 'TOTAL') THEN
      OPEN csr_get_terr(p_source_id, g_sysdate, g_sysdate);
    ELSIF (p_mode = 'DATE EFFECTIVE') THEN
      OPEN csr_get_terr(p_source_id, l_param_start_date, l_param_end_date);
    END IF;

    FETCH csr_get_terr BULK COLLECT INTO
       l_terr_change_tab.terr_id
      ,l_terr_change_tab.terr_rank
      ,l_terr_change_tab.num_winners
      ,l_terr_change_tab.org_id
      ,l_terr_change_tab.parent_terr_id
      ,l_terr_change_tab.level_from_root
      ,l_terr_change_tab.parent_num_winners
      ,l_terr_change_tab.rank_calc_flag
      ,l_terr_change_tab.attr_processing_flag
      ,l_terr_change_tab.hier_processing_flag
      ,l_terr_change_tab.matching_sql_flag
      ,l_terr_change_tab.start_date
      ,l_terr_change_tab.end_date;

    CLOSE csr_get_terr;
  END IF; /* end IF (p_mode = 'INCREMENTAL') */

  l_no_of_records := l_terr_change_tab.terr_id.COUNT;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.no_of_terr',
                   'Number of territories to be processed : ' || l_no_of_records);

  IF (l_no_of_records > 0) THEN
    /* Calculate rank, denormalize hierarchy and qualifier values */
    JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank (
      p_source_id       => p_source_id,
      p_mode            => p_mode,
      p_terr_change_tab => l_terr_change_tab,
      errbuf            => errbuf,
      retcode           => retcode);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.process_attr_and_rank',
                       'process_attr_and_rank API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.process_attr_and_rank',
                     'process_attr_and_rank API has completed with success');

    /* Generate real time and batch matching SQLs */
    gen_matching_sql (
      p_source_id       => p_source_id,
      p_mode            => p_mode,
      p_terr_change_tab => l_terr_change_tab,
      p_start_date      => l_param_start_date,
      p_end_date        => l_param_end_date,
      x_Return_Status   => l_Return_Status,
      x_Msg_Count       => l_Msg_Count,
      x_Msg_Data        => l_Msg_Data,
      errbuf            => errbuf,
      retcode           => retcode);

    IF (retcode <> 0) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.gen_matching_sql',
                       'gen_matching_sql API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.gen_matching_sql',
                     'gen_matching_sql API has completed with success');

    /* PERSON_ID required for OSO TAP */
/*    IF (p_source_id = -1001) THEN
      BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD DISABLE';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      FORALL i IN l_terr_change_tab.terr_id.FIRST .. l_terr_change_tab.terr_id.LAST
        UPDATE jtf_terr_rsc_all jtr
        SET    jtr.person_id =
                  ( SELECT jrrev.source_id
                    FROM   jtf_rs_resource_extns_vl jrrev
                    WHERE  jrrev.category = 'EMPLOYEE'
                    AND    jrrev.resource_id = jtr.resource_id )
        WHERE  jtr.resource_type= 'RS_EMPLOYEE'
        AND    jtr.terr_id = l_terr_change_tab.terr_id(i);

      BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_RSC_BIUD ENABLE';
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    END IF;*/ -- COmmented for bug 8295746

    IF (p_mode = 'DATE EFFECTIVE') THEN
      SELECT denorm_dea_value_table_name
      INTO   l_table_name
      FROM   jtf_sources_all
      WHERE  source_id = p_source_id;
    ELSE
      SELECT denorm_value_table_name
      INTO   l_table_name
      FROM   jtf_sources_all
      WHERE  source_id = p_source_id;
    END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */

    -- Update theabsolute rank in jtf_terr_denorm_rules_all for all service territories when the STAR is run for Service.
    IF (p_source_id = -1002) THEN
        UPDATE jtf_terr_denorm_rules_all jtda
        SET absolute_rank = ( select absolute_rank from jtf_terr_all jta where jta.terr_id = jtda.terr_id)
        where jtda.source_id = -1002;
     END IF;

    IF ( p_source_id = -1002 ) THEN
      l_denorm_count := 0 ;
      EXECUTE IMMEDIATE 'SELECT count(*) FROM ' || l_table_name || ' where ROWNUM = 1' INTO l_denorm_count;
      /* Create index on the denorm value table */
      /* Dont create the index on the denorm table if the there are no rows in the denorm table*/
      IF ( l_denorm_count = 1  ) THEN
        JTY_TERR_DENORM_RULES_PVT.CREATE_DNMVAL_INDEX (
          p_table_name      => l_table_name,
          p_source_id       => p_source_id,
          p_mode            => p_mode,
          x_Return_Status   => l_Return_Status);
      END IF;
    ELSE
    /* Create index on the denorm value table */
    JTY_TERR_DENORM_RULES_PVT.CREATE_DNMVAL_INDEX (
      p_table_name      => l_table_name,
      p_source_id       => p_source_id,
      p_mode            => p_mode,
      x_Return_Status   => l_Return_Status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.CREATE_DNMVAL_INDEX',
                       'JTY_TERR_DENORM_RULES_PVT.CREATE_DNMVAL_INDEX API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  ELSE
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.no_of_terr',
                     'No territories processed');

  END IF; /* IF (l_no_of_records > 0) */

  /* Following procedure call has been added to set the geo_flag value in jtf_terr_all table
     based on wether a territory has geographical qualifiers or not */
/*
  JTY_TERR_MAP_PVT.set_terr_geo_flag ( p_source_id => p_source_id,
                                       p_mode => p_mode,
                                       p_terr_change_tab => l_terr_change_tab,
                                       errbuf => errbuf, retcode => retcode );
  IF (retcode <> 0) THEN
    -- debug message
    jty_log(FND_LOG.LEVEL_EXCEPTION, 'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine', 'JTY_TERR_MAP_PVT.set_terr_geo_flag API has failed');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
*/
  /* if batch mode is not enabled for the usage, delete all the entries processed from the changed table */
  IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN
    SELECT count(*)
    INTO   l_batch_enabled
    FROM   jty_trans_usg_pgm_details a
    WHERE  a.source_id = p_source_id
    AND    a.batch_enable_flag = 'Y';

    IF (l_batch_enabled = 0) THEN
      DELETE jty_changed_terrs
      WHERE  star_request_id = g_request_id;
    END IF;
  END IF;

  retcode    := 0;
  errbuf     := null;
  l_end_date := SYSDATE;

  UPDATE JTY_CONC_REQ_SUMM
  SET   requested_by = l_user_id
       ,request_date = l_start_date
       ,responsibility_application_id = l_resp_appl_id
       ,responsibility_id = l_resp_id
       ,last_updated_by = l_user_id
       ,last_update_date = l_start_date
       ,last_update_login = l_login_id
       ,start_date = l_start_date
       ,end_date = l_end_date
       ,param2 = p_mode
       ,param3 = TO_CHAR(l_param_start_date, 'DD/MM/YYYY HH24:MI:SS')
       ,param4 = TO_CHAR(l_param_end_date, 'DD/MM/YYYY HH24:MI:SS')
       ,param5 = null
       ,program_application_id = l_pgm_appl_id
       ,errbuf = errbuf
       ,request_id = g_request_id
       ,conc_program_id = l_conc_pgm_id
  WHERE program_name = 'JTY_STAR'
  AND   param1       = to_char(p_source_id)
  AND   retcode      = retcode
  AND   param2       = p_mode;

  IF (SQL%ROWCOUNT = 0) THEN
    INSERT INTO JTY_CONC_REQ_SUMM (
       conc_req_id
      ,requested_by
      ,request_date
      ,responsibility_application_id
      ,responsibility_id
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,start_date
      ,end_date
      ,param1
      ,param2
      ,param3
      ,param4
      ,param5
      ,program_application_id
      ,program_name
      ,retcode
      ,errbuf
      ,request_id
      ,conc_program_id
      ,object_version_number)
    VALUES (
       jty_conc_req_summ_s.nextval
      ,l_user_id
      ,l_start_date
      ,l_resp_appl_id
      ,l_resp_id
      ,l_user_id
      ,l_start_date
      ,l_login_id
      ,l_start_date
      ,l_end_date
      ,TO_CHAR(p_source_id)
      ,p_mode
      ,TO_CHAR(l_param_start_date, 'DD/MM/YYYY HH24:MI:SS')
      ,TO_CHAR(l_param_end_date, 'DD/MM/YYYY HH24:MI:SS')
      ,null
      ,l_pgm_appl_id
      ,l_pgm_name
      ,retcode
      ,errbuf
      ,g_request_id
      ,l_conc_pgm_id
      ,0);
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.g_exc_error',
                     'API JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN_PVT.gen_rule_engine.others',
                     substr(errbuf, 1, 4000));

END gen_rule_engine;

PROCEDURE update_resource_person_id(p_terr_id  IN NUMBER)
IS

BEGIN

      UPDATE jtf_terr_rsc_all jtr
        SET    jtr.person_id =
                  ( SELECT jrrev.source_id
                    FROM   jtf_rs_resource_extns_vl jrrev
                    WHERE  jrrev.category = 'EMPLOYEE'
                    AND    jrrev.resource_id = jtr.resource_id )
        WHERE  jtr.resource_type= 'RS_EMPLOYEE'
        AND    jtr.terr_id = p_terr_id;

END update_resource_person_id;


END JTY_TERR_ENGINE_GEN_PVT;

/
