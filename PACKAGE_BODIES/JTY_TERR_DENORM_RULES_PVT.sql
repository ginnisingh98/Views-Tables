--------------------------------------------------------
--  DDL for Package Body JTY_TERR_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TERR_DENORM_RULES_PVT" AS
/* $Header: jtfytdrb.pls 120.17.12010000.29 2010/04/20 10:02:03 vpalle ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_DENORM_RULES_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used for the following prposes :
--      a) denormalize the territory hierarchy
--      b) denormalize the territory qualifier values
--      c) calculate absolute rank, number of qualifiers and qual relation product
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/13/05    ACHANDA         CREATED
--
--    End of Comments
--

  G_REQUEST_ID      NUMBER       := FND_GLOBAL.CONC_REQUEST_ID();
  G_PROGRAM_APPL_ID NUMBER       := FND_GLOBAL.PROG_APPL_ID();
  G_PROGRAM_ID      NUMBER       := FND_GLOBAL.CONC_PROGRAM_ID();
  G_USER_ID         NUMBER       := FND_GLOBAL.USER_ID();
  G_SYSDATE         DATE         := SYSDATE;
  G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
  G_NEW_LINE        VARCHAR2(02) := fnd_global.local_chr(10);

  G_COMMIT_SIZE  CONSTANT NUMBER := 20000;

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

PROCEDURE CREATE_DNMVAL_INDEX ( p_table_name    IN  VARCHAR2,
                                p_source_id     IN  NUMBER,
                                p_mode          IN  VARCHAR2,
                                x_Return_Status OUT NOCOPY VARCHAR2)
IS

  i           integer;
  j           integer;

  v_statement varchar2(9000);
  s_statement varchar2(4000);
  i_statement varchar2(2000);

  alter_statement varchar2(2000);

  l_table_tablespace  varchar2(100);
  l_idx_tablespace    varchar2(100);
  l_ora_username      varchar2(100);
  l_dop               NUMBER;

  Cursor getProductList(cl_source_id number) IS
  SELECT  A.terr_values_idx_header_id,
          A.index_name,
          A.qual_usg_id
  FROM    jty_terr_values_idx_header A
  WHERE   A.source_id = p_source_id
  AND     A.build_index_flag = 'Y'
  -- the condition below is necessary for incremental mode where the index may be already present
  AND     NOT EXISTS (
             SELECT 1
             FROM   dba_indexes B
             WHERE  B.index_name = A.index_name
             AND    B.owner = l_ora_username)
  ORDER BY A.index_name;

  Cursor  getFactorList(cl_tvhidpid number) IS
  SELECT  DISTINCT B.VALUES_COL_MAP, B.INPUT_SELECTIVITY
  FROM    jty_terr_values_idx_details B
  WHERE   B.terr_values_idx_header_id = cl_tvhidpid
  AND     B.values_col_map is not null
  ORDER BY input_selectivity;

  Cursor getDeaProductList(cl_source_id number) IS
  SELECT  A.dea_values_idx_header_id,
          A.index_name
  FROM    jty_dea_values_idx_header A
  WHERE   A.source_id = p_source_id
  AND     A.build_index_flag = 'Y';

  Cursor  getDeaFactorList(cl_tvhidpid number) IS
  SELECT  DISTINCT B.VALUES_COL_MAP, B.INPUT_SELECTIVITY
  FROM    jty_dea_values_idx_details B
  WHERE   B.dea_values_idx_header_id = cl_tvhidpid
  AND     B.values_col_map is not null
  ORDER BY input_selectivity;

  Cursor getDropIndexCandidates(cl_source_id in number, cl_owner in varchar2) IS
  SELECT  A.index_name,
          B.owner
  FROM    jty_terr_values_idx_header A,
          dba_indexes B
  WHERE   A.source_id = p_source_id
  AND     A.build_index_flag = 'N'
  AND     A.index_name = B.index_name
  AND     B.owner = cl_owner;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.begin',
                   'Start of the procedure jty_terr_denorm_rules_pvt.create_dnmval_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* In incremental mode mark all the qualifier combination present */
  /* in jtf_tae_qual_products as being used by active territories   */
  IF (p_mode = 'INCREMENTAL') THEN
    UPDATE jty_terr_values_idx_header a
    SET    a.delete_flag = 'N'
    WHERE  a.source_id = p_source_id
    AND    a.delete_flag = 'Y'
    AND    a.relation_product in (
            SELECT relation_product
            FROM   jtf_tae_qual_products
            WHERE  source_id = p_source_id );
  END IF;

  /* Calculate the selectivity of the columns in the denorm value table */
  jty_tae_index_creation_pvt.SELECTIVITY(p_TABLE_NAME    => p_table_name,
                                         p_mode          => p_mode,
                                         p_source_id     => p_source_id,
                                         x_return_status => x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.selectivity',
                     'API jty_tae_index_creation_pvt.SELECTIVITY has failed');
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  /* Determine the indexes that need to be created */
  IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN
    JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set (
      p_source_id     => p_source_id,
      p_mode          => p_mode,
      x_Return_Status => x_return_status );
  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set (
      p_source_id     => p_source_id,
      x_Return_Status => x_return_status );
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.reduce_dnmval_idx_set',
                     'API JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set has failed');
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  /* get default Degree of Parallelism */
  SELECT MIN(TO_NUMBER(v.value))
  INTO   l_dop
  FROM   v$parameter v
  WHERE  v.name = 'parallel_max_servers'
  OR     v.name = 'cpu_count';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.l_dop',
                   'Default degree of parallelism : ' || l_dop);

  /* get tablespace information */
  SELECT i.tablespace, i.index_tablespace, u.oracle_username
  INTO   l_table_tablespace, l_idx_tablespace, l_ora_username
  FROM   fnd_product_installations i, fnd_application a, fnd_oracle_userid u
  WHERE  a.application_short_name = 'JTF'
  AND    a.application_id = i.application_id
  AND    u.oracle_id = i.oracle_id;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.tablespace',
                   'Table tablespace : ' || l_table_tablespace || ' Index tablespace : ' || l_idx_tablespace ||
                   ' Schema Name : ' || l_ora_username);

  -- default INDEX STORAGE parameters
  s_statement := s_statement || ' TABLESPACE ' ||  l_idx_tablespace ;
  s_statement := s_statement || ' STORAGE(INITIAL 1M NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED ';
  s_statement := s_statement || ' PCTINCREASE 0 FREELISTS 4 FREELIST GROUPS 4 BUFFER_POOL DEFAULT) ';
  s_statement := s_statement || ' PCTFREE 10 INITRANS 10 MAXTRANS 255 ';
  s_statement := s_statement || ' COMPUTE STATISTICS ';
  s_statement := s_statement || ' NOLOGGING PARALLEL ' || l_dop;

  /* Create Qualifier Combination Dynamic Indexes */
  IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN
    FOR prd IN getProductList(p_source_id) LOOP

      v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || prd.index_name || ' ON ' || p_table_name || '( ';

      j:=1;
      i_statement := null;

      -- for each factor of product
      FOR factor IN getFactorList(prd.terr_values_idx_header_id) LOOP

        IF j<>1 THEN
          i_statement := i_statement || ',' ;
        END IF;
        i_statement := i_statement || factor.VALUES_COL_MAP;
        j:=j+1;
      END LOOP; /* end loop FOR factor IN getFactorList */

      IF (j > 1) THEN
         IF nvl(prd.qual_usg_id, -1) <> -1041 THEN  --Bug 7645026
                v_statement := v_statement || i_statement || ',source_id, trans_type_id, start_date, end_date, terr_id) ';
         ELSE
                v_statement := v_statement  || 'source_id, trans_type_id,' || i_statement ||',start_date, end_date, terr_id)';
         END IF;

        /* Append Storage Parameter Information to Index Definition */
        v_statement := v_statement || s_statement;

        -- debug message
          jty_log(FND_LOG.LEVEL_STATEMENT,
                         'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.index_creation',
                         'Index created with the statement : ' || v_statement);
        DECLARE  --Bug 7645026
            duplicate_index EXCEPTION;
            pragma EXCEPTION_INIT(duplicate_index, -1408);
        BEGIN
            EXECUTE IMMEDIATE v_statement;
            alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || ' NOPARALLEL';
            EXECUTE IMMEDIATE alter_statement;
        EXCEPTION
          WHEN duplicate_index THEN
            UPDATE  jty_terr_values_idx_header
            SET     BUILD_INDEX_FLAG = 'N'
            WHERE   terr_values_idx_header_id = prd.terr_values_idx_header_id;
        END;
      END IF; /* end IF (j > 1) */

    END LOOP; /* end loop  FOR prd IN getProductList */

    FOR idx IN getDropIndexCandidates(p_source_id, l_ora_username) LOOP
      v_statement := 'DROP INDEX ' || idx.owner || '.' || idx.index_name;

      BEGIN
        EXECUTE IMMEDIATE v_statement;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    END LOOP;

    IF (p_mode = 'INCREMENTAL') THEN
      DELETE jty_terr_values_idx_details dtl
      WHERE  EXISTS (
        SELECT 1
        FROM   jty_terr_values_idx_header hdr
        WHERE  dtl.terr_values_idx_header_id = hdr.terr_values_idx_header_id
        AND    hdr.source_id = p_source_id
        AND    hdr.delete_flag = 'Y');

      DELETE jty_terr_values_idx_header hdr
      WHERE  hdr.source_id = p_source_id
      AND    hdr.delete_flag = 'Y';

    END IF;

  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    FOR prd IN getDeaProductList(p_source_id) LOOP

      v_statement := 'CREATE INDEX '|| l_ora_username ||'.' || prd.index_name || ' ON ' || p_table_name || '( ';

      j:=1;
	  -- for each factor of product
      FOR factor IN getDeaFactorList(prd.dea_values_idx_header_id) LOOP

         IF j<>1 THEN
          v_statement := v_statement || ',' ;
        END IF;
        v_statement := v_statement || factor.VALUES_COL_MAP;
        j:=j+1;
      END LOOP; /* end loop FOR factor IN getDeaFactorList */

      IF (j > 1) THEN
	    v_statement := v_statement || ',source_id, trans_type_id, start_date, end_date, terr_id) ';
        /* Append Storage Parameter Information to Index Definition */
        v_statement := v_statement || s_statement;

        -- debug message
          jty_log(FND_LOG.LEVEL_STATEMENT,
                         'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.index_creation',
                         'Index created with the statement : ' || v_statement);
        DECLARE --Bug 7614496
            duplicate_index EXCEPTION;
            pragma EXCEPTION_INIT(duplicate_index, -1408);
        BEGIN
          EXECUTE IMMEDIATE v_statement;
          alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || prd.index_name || ' NOPARALLEL';
          EXECUTE IMMEDIATE alter_statement;
        EXCEPTION
          WHEN duplicate_index THEN /* Catch Duplicate Index Creation Exception */
            UPDATE jty_dea_values_idx_header
             SET     BUILD_INDEX_FLAG = 'N'
            WHERE   dea_values_idx_header_id = prd.dea_values_idx_header_id;
        END;
      END IF; /* end IF (j > 1) */

    END LOOP; /* end loop  FOR prd IN getDeaProductList */
  END IF; /* end IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.end',
                   'End of the procedure jty_terr_denorm_rules_pvt.create_dnmval_index ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.no_data_found',
                     'API jty_terr_denorm_rules_pvt.create_dnmval_index has failed with no_data_found');

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.g_exc_error',
                     'jty_terr_denorm_rules_pvt.create_dnmval_index has failed with G_EXC_ERROR exception');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jty_terr_denorm_rules_pvt.create_dnmval_index.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END CREATE_DNMVAL_INDEX;

/* This function returns the level of the territory from root (terr_id = 1) */
FUNCTION get_level_from_root(p_terr_id IN number) RETURN NUMBER IS

  l_level   NUMBER;

BEGIN

  l_level   := 0;

  IF (p_terr_id = 1) THEN
    RETURN 1;
  END IF;

  select max(level)
  into   l_level
  from   jtf_terr_all
  START WITH terr_id = p_terr_id
  CONNECT BY PRIOR parent_territory_id = terr_id AND terr_id <> 1;

  RETURN (l_level+1);

EXCEPTION
  WHEN OTHERS THEN
    return 1;
END get_level_from_root;

/* This procedure inserts the denormalized territory hierarchy informations  */
/* into the tables jtf_terr_denorm_rules_all, for total and incremental mode */
/* and the table jty_denorm_dea_rules_all for date effective mode            */
PROCEDURE update_denorm_table (
  p_source_id                 IN NUMBER,
  p_mode                      IN VARCHAR2,
  p_terr_id_tbl               IN OUT NOCOPY jtf_terr_number_list,
  p_related_terr_id_tbl       IN OUT NOCOPY jtf_terr_number_list,
  p_top_level_terr_id_tbl     IN OUT NOCOPY jtf_terr_number_list,
  p_num_winners_tbl           IN OUT NOCOPY jtf_terr_number_list,
  p_level_from_root_tbl       IN OUT NOCOPY jtf_terr_number_list,
  p_level_from_parent_tbl     IN OUT NOCOPY jtf_terr_number_list,
  p_terr_rank_tbl             IN OUT NOCOPY jtf_terr_number_list,
  p_immediate_parent_flag_tbl IN OUT NOCOPY jtf_terr_char_1list,
  p_org_id_tbl                IN OUT NOCOPY jtf_terr_number_list,
  p_start_date_tbl            IN OUT NOCOPY jtf_terr_date_list,
  p_end_date_tbl              IN OUT NOCOPY jtf_terr_date_list,
  errbuf                      OUT NOCOPY VARCHAR2,
  retcode                     OUT NOCOPY VARCHAR2)
IS

  l_no_of_records NUMBER;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_denorm_table.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.update_denorm_table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_no_of_records := p_terr_id_tbl.COUNT;

  IF (l_no_of_records > 0) THEN
    /* if mode is total or incremental, insert the denormalized */
    /* hierarchy information into jtf_terr_denorm_rules_all     */
    IF (p_mode IN ('TOTAL', 'INCREMENTAL')) THEN
      FORALL i IN p_terr_id_tbl.FIRST .. p_terr_id_tbl.LAST
        INSERT INTO jtf_terr_denorm_rules_all(
            source_id
          , qual_type_id
          , terr_id
          , rank
          , level_from_root
          , level_from_parent
          , related_terr_id
          , top_level_terr_id
          , num_winners
          , immediate_parent_flag
          , start_date
          , end_date
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_LOGIN
          , REQUEST_ID
          , PROGRAM_APPLICATION_ID
          , PROGRAM_ID
          , PROGRAM_UPDATE_DATE
          , ORG_ID
          , RESOURCE_EXISTS_FLAG
         -- , absolute_rank
          )
        VALUES  (
            p_source_id
          , -1
          , p_terr_id_tbl(i)
          , p_terr_rank_tbl(i)
          , p_level_from_root_tbl(i)
          , p_level_from_parent_tbl(i)
          , p_related_terr_id_tbl(i)
          , p_top_level_terr_id_tbl(i)
          , p_num_winners_tbl(i)
          , p_immediate_parent_flag_tbl(i)
          , p_start_date_tbl(i)
          , p_end_date_tbl(i)
          , G_SYSDATE
          , G_USER_ID
          , G_SYSDATE
          , G_USER_ID
          , G_USER_ID
          , G_REQUEST_ID
          , G_PROGRAM_APPL_ID
          , G_PROGRAM_ID
          , G_SYSDATE
          , p_org_id_tbl(i)
          , 'N'
         -- , (SELECT absolute_rank from jtf_terr_all where terr_id = p_terr_id_tbl(i))
         );

      -- debug message
        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_denorm_table.num_rows_inserted',
                       'Number of records inserted into jtf_terr_denorm_rules_all : ' || l_no_of_records);

    ELSE
    /* if mode is date effective, insert the denormalized  */
    /* hierarchy information into jty_denorm_dea_rules_all */
      FORALL i IN p_terr_id_tbl.FIRST .. p_terr_id_tbl.LAST
        INSERT INTO jty_denorm_dea_rules_all(
            source_id
          , terr_id
          , rank
          , level_from_root
          , level_from_parent
          , related_terr_id
          , top_level_terr_id
          , num_winners
          , immediate_parent_flag
          , start_date
          , end_date
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , CREATION_DATE
          , CREATED_BY
          , LAST_UPDATE_LOGIN
          , REQUEST_ID
          , PROGRAM_APPLICATION_ID
          , PROGRAM_ID
          , PROGRAM_UPDATE_DATE
          , ORG_ID
          --, absolute_rank
        )
        VALUES  (
            p_source_id
          , p_terr_id_tbl(i)
          , p_terr_rank_tbl(i)
          , p_level_from_root_tbl(i)
          , p_level_from_parent_tbl(i)
          , p_related_terr_id_tbl(i)
          , p_top_level_terr_id_tbl(i)
          , p_num_winners_tbl(i)
          , p_immediate_parent_flag_tbl(i)
          , p_start_date_tbl(i)
          , p_end_date_tbl(i)
          , G_SYSDATE
          , G_USER_ID
          , G_SYSDATE
          , G_USER_ID
          , G_USER_ID
          , G_REQUEST_ID
          , G_PROGRAM_APPL_ID
          , G_PROGRAM_ID
          , G_SYSDATE
          , p_org_id_tbl(i)
         -- , (SELECT absolute_rank from jtf_terr_all where terr_id = p_terr_id_tbl(i))
          );

      -- debug message
        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_denorm_table.num_rows_inserted',
                       'Number of records inserted into jty_denorm_dea_rules_all : ' || l_no_of_records);

    END IF; /* end IF (p_mode IN ('TOTAL', 'INCREMENTAL')) */

  END IF; /* end IF (l_no_of_records > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_denorm_table.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.update_denorm_table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_denorm_table.others',
                     substr(errbuf, 1, 4000));

END update_denorm_table;

/* This procedure updates the relative rank in the table jtf_terr_all */
PROCEDURE update_relative_rank (
  p_terr_id_tbl               IN OUT NOCOPY jtf_terr_number_list,
  p_relative_rank_tbl         IN OUT NOCOPY jtf_terr_number_list,
  errbuf                      OUT NOCOPY VARCHAR2,
  retcode                     OUT NOCOPY VARCHAR2)
IS

  l_no_of_records NUMBER;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_relative_rank.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.update_relative_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_no_of_records := p_terr_id_tbl.COUNT;

  /* update the relative rank of the territory in jtf_terr_all */
  IF (l_no_of_records > 0) THEN

    /* disable the trigger before update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD DISABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    FORALL i IN p_terr_id_tbl.FIRST .. p_terr_id_tbl.LAST
      UPDATE jtf_terr_all
      SET    relative_rank = p_relative_rank_tbl(i)
      WHERE  terr_id = p_terr_id_tbl(i);

    /* enable the trigger after update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD ENABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_relative_rank.num_rows_updated',
                     'Number of records updated in jtf_terr_all for relative rank : ' || l_no_of_records);

  END IF; /* end IF (l_no_of_records > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_relative_rank.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.update_relative_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_relative_rank.others',
                     substr(errbuf, 1, 4000));
END update_relative_rank;

/* This procedure updates the absolute rank in the table jtf_terr_all */
PROCEDURE update_absolute_rank (
  p_terr_id_tbl               IN OUT NOCOPY jtf_terr_number_list,
  p_mode                      IN VARCHAR2,
  p_table_name                IN VARCHAR2,
  errbuf                      OUT NOCOPY VARCHAR2,
  retcode                     OUT NOCOPY VARCHAR2)
IS
  l_dyn_str                  VARCHAR2(1000);
  l_no_of_records            NUMBER;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_absolute_rank.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.update_absolute_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_no_of_records := p_terr_id_tbl.COUNT;

  /* update the relative rank of the territory in jtf_terr_all */
  IF (l_no_of_records > 0) THEN

    /* disable the trigger before update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD DISABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    /* calculate the absolute rank */
    FORALL i IN p_terr_id_tbl.FIRST .. p_terr_id_tbl.LAST
      UPDATE  jtf_terr_all jta1
      SET     jta1.ABSOLUTE_RANK = (
                SELECT SUM(jta2.relative_rank)
                FROM   jtf_terr_all jta2
                WHERE  jta2.terr_id IN (
                         SELECT jt.terr_id
                         FROM jtf_terr_all jt
                         CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                         START WITH jt.terr_id = p_terr_id_tbl(i))),
              jta1.last_update_date = g_sysdate
      WHERE jta1.terr_id = p_terr_id_tbl(i);

    l_dyn_str :=
      'UPDATE ' || p_table_name || ' ' ||
      'SET   absolute_rank = ( ' ||
      '        SELECT absolute_rank ' ||
      '        FROM   jtf_terr_all  ' ||
      '        WHERE  terr_id = :1 ) ' ||
      'WHERE terr_id = :2 ';

    IF (p_mode = 'INCREMENTAL') THEN
      FORALL i IN p_terr_id_tbl.FIRST .. p_terr_id_tbl.LAST
        EXECUTE IMMEDIATE l_dyn_str USING p_terr_id_tbl(i), p_terr_id_tbl(i);
    END IF;

    /* enable the trigger after update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD ENABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_absolute_rank.num_rows_updated',
                     'Number of records updated in jtf_terr_all for absolute rank : ' || l_no_of_records);

  END IF; /* end IF (l_no_of_records > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_absolute_rank.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.update_absolute_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.update_absolute_rank.others',
                     substr(errbuf, 1, 4000));
END update_absolute_rank;

/* This procedure updates the denormalized territory qualifier value informations */
PROCEDURE process_attr_values (
  p_source_id        IN NUMBER,
  p_mode             IN VARCHAR2,
  p_table_name       IN VARCHAR2,
  p_terr_change_tab  IN JTY_TERR_ENGINE_GEN_PVT.terr_change_type,
  errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2 )
IS

  CURSOR c_qual_types(cl_source_id in number, cl_terr_id in number) IS
  SELECT a.qual_type_id
  FROM   jtf_qual_type_usgs_all a,
         jtf_terr_qtype_usgs_all b
  WHERE  b.terr_id          = cl_terr_id
  AND    b.qual_type_usg_id = a.qual_type_usg_id
  AND    a.source_id        = cl_source_id;

  CURSOR c_terr_qual_values(cl_terr_id in number, cl_source_id in number, cl_qual_type_id in number) IS
  SELECT jtqa.qual_usg_id,
         nvl(jqua.qual_relation_factor, 1),
         jtva.comparison_operator,
         jtva.low_value_char_id,
         decode(cl_source_id, -1001, upper(jtva.low_value_char), -1600, upper(jtva.low_value_char), jtva.low_value_char),
         decode(cl_source_id, -1001, upper(jtva.high_value_char), -1600, upper(jtva.high_value_char), jtva.high_value_char),
         jtva.low_value_number,
         jtva.high_value_number,
         jtva.interest_type_id,
         jtva.primary_interest_code_id,
         jtva.secondary_interest_code_id,
         jtva.currency_code,
         jtva.value1_id,
         jtva.value2_id,
         jtva.value3_id,
         jtva.value4_id,
         jtva.first_char,
         jqua.update_attr_val_stmt,
         jqua.insert_attr_val_stmt,
         jtdr.top_level_terr_id,
         jta.absolute_rank,
         jtdr.start_date,
         jtdr.end_date,
         count(*) over(partition by jtqa.qual_usg_id)
  FROM   jtf_terr_all               jta,
         jtf_terr_denorm_rules_all  jtdr,
         jtf_terr_qual_all          jtqa,
         jtf_terr_values_all        jtva,
         jtf_qual_usgs_all          jqua,
         jtf_qual_type_usgs_all     jqtu,
         jtf_qual_type_denorm_v     inlv
  WHERE  jta.terr_id = cl_terr_id
  AND    jtdr.terr_id = jta.terr_id
  AND    jtdr.related_terr_id = jtqa.terr_id
  AND    jtdr.source_id = cl_source_id
  AND    jtqa.terr_qual_id = jtva.terr_qual_id
  AND    jtqa.qual_usg_id = jqua.qual_usg_id
  AND    jqua.org_id = -3113
  AND    jqua.qual_type_usg_id = jqtu.qual_type_usg_id
  AND    jqtu.source_id = cl_source_id
  AND    jqtu.qual_type_id = inlv.related_id
  AND    inlv.qual_type_id = cl_qual_type_id
  AND    jtqa.qual_usg_id <> -1102  -- eliminate CNRG
  AND    EXISTS
         (SELECT 1
          FROM   jtf_terr_rsc_all jtr,
                 jtf_terr_rsc_access_all jtra,
                 jtf_qual_types_all jqta
          WHERE  jtr.terr_id = jta.terr_id
          AND    jtr.end_date_active >= sysdate
          AND    jtr.start_date_active <= sysdate
          AND    jtr.resource_type <> 'RS_ROLE'
          AND    jtr.terr_rsc_id = jtra.terr_rsc_id
          AND    jtra.access_type = jqta.name
          AND    jqta.qual_type_id = cl_qual_type_id
          AND    jtra.trans_access_code <> 'NONE')
  UNION ALL
  SELECT jtqa.qual_usg_id,
         nvl(jqua.qual_relation_factor, 1),
         cnrgv.comparison_operator,
         null,
         upper(cnrgv.low_value_char),
         upper(cnrgv.high_value_char),
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         CAST( SUBSTR(UPPER(cnrgv.low_value_char), 1, 1) AS VARCHAR2(3) ),
         jqua.update_attr_val_stmt,
         jqua.insert_attr_val_stmt,
         jtdr.top_level_terr_id,
         jta.absolute_rank,
         jtdr.start_date,
         jtdr.end_date,
         count(*) over(partition by jtqa.qual_usg_id)
  FROM   jtf_terr_all               jta,
         jtf_terr_denorm_rules_all  jtdr,
         jtf_terr_qual_all          jtqa,
         jtf_terr_values_all        jtva,
         jtf_qual_usgs_all          jqua,
         jtf_qual_type_usgs_all     jqtu,
         jtf_qual_type_denorm_v     inlv,
         jtf_terr_cnr_groups        cnrg,
         jtf_terr_cnr_group_values  cnrgv
  WHERE  jta.terr_id = cl_terr_id
  AND    jtdr.terr_id = jta.terr_id
  AND    jtdr.related_terr_id = jtqa.terr_id
  AND    jtdr.source_id = cl_source_id
  AND    jtqa.terr_qual_id = jtva.terr_qual_id
  AND    jtqa.qual_usg_id = jqua.qual_usg_id
  AND    jqua.org_id = -3113
  AND    jqua.qual_type_usg_id = jqtu.qual_type_usg_id
  AND    jqtu.source_id = cl_source_id
  AND    jqtu.qual_type_id = inlv.related_id
  AND    inlv.qual_type_id = cl_qual_type_id
  AND    jtqa.qual_usg_id = -1102  -- include CNRG
  AND    cnrg.cnr_group_id = jtva.low_value_char_id
  AND    cnrg.cnr_group_id = cnrgv.cnr_group_id
  AND    EXISTS
         (SELECT 1
          FROM   jtf_terr_rsc_all jtr,
                 jtf_terr_rsc_access_all jtra,
                 jtf_qual_types_all jqta
          WHERE  jtr.terr_id = jta.terr_id
          AND    jtr.end_date_active >= sysdate
          AND    jtr.start_date_active <= sysdate
          AND    jtr.resource_type <> 'RS_ROLE'
          AND    jtr.terr_rsc_id = jtra.terr_rsc_id
          AND    jtra.access_type = jqta.name
          AND    jqta.qual_type_id = cl_qual_type_id
          AND    jtra.trans_access_code <> 'NONE')
  ORDER BY 1;

  CURSOR c_terr_dea_qual_values(cl_terr_id in number, cl_source_id in number, cl_qual_type_id in number) IS
  SELECT /*+ leading(JTA) index(JTA JTF_TERR_U1) */ jtqa.qual_usg_id,
         nvl(jqua.qual_relation_factor, 1),
         jtva.comparison_operator,
         jtva.low_value_char_id,
         decode(cl_source_id, -1001, upper(jtva.low_value_char), -1600, upper(jtva.low_value_char), jtva.low_value_char),
         decode(cl_source_id, -1001, upper(jtva.high_value_char), -1600, upper(jtva.high_value_char), jtva.high_value_char),
         jtva.low_value_number,
         jtva.high_value_number,
         jtva.interest_type_id,
         jtva.primary_interest_code_id,
         jtva.secondary_interest_code_id,
         jtva.currency_code,
         jtva.value1_id,
         jtva.value2_id,
         jtva.value3_id,
         jtva.value4_id,
         jtva.first_char,
         jqua.update_attr_val_stmt,
         jqua.insert_attr_val_stmt,
         jtdr.top_level_terr_id,
         jta.absolute_rank,
         jtdr.start_date,
         jtdr.end_date,
         count(*) over(partition by jtqa.qual_usg_id)
  FROM   jtf_terr_all               jta,
         jty_denorm_dea_rules_all   jtdr,
         jtf_terr_qual_all          jtqa,
         jtf_terr_values_all        jtva,
         jtf_qual_usgs_all          jqua,
         jtf_qual_type_usgs_all     jqtu,
         jtf_qual_type_denorm_v     inlv
  WHERE  jta.terr_id = cl_terr_id
  AND    jtdr.terr_id = jta.terr_id
  AND    jtdr.related_terr_id = jtqa.terr_id
  AND    jtqa.terr_qual_id = jtva.terr_qual_id
  AND    jtqa.qual_usg_id = jqua.qual_usg_id
  AND    jqua.org_id = -3113
  AND    jqua.qual_type_usg_id = jqtu.qual_type_usg_id
  AND    jqtu.source_id = cl_source_id
  AND    jqtu.qual_type_id = inlv.related_id
  AND    inlv.qual_type_id = cl_qual_type_id
  AND    jtqa.qual_usg_id <> -1102  -- eliminate CNRG
  AND    EXISTS
         (SELECT 1
          FROM   jtf_terr_rsc_all jtr,
                 jtf_terr_rsc_access_all jtra,
                 jtf_qual_types_all jqta
          WHERE  jtr.terr_id = jta.terr_id
          AND    jtr.resource_type <> 'RS_ROLE'
          AND    jtr.terr_rsc_id = jtra.terr_rsc_id
          AND    jtra.access_type = jqta.name
          AND    jqta.qual_type_id + 0 = cl_qual_type_id
          AND    jtra.trans_access_code <> 'NONE')
  UNION ALL
  SELECT /*+ leading(JTA) index(JTA JTF_TERR_U1) */ jtqa.qual_usg_id,
         nvl(jqua.qual_relation_factor, 1),
         cnrgv.comparison_operator,
         null,
         upper(cnrgv.low_value_char),
         upper(cnrgv.high_value_char),
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         null,
         CAST( SUBSTR(UPPER(cnrgv.low_value_char), 1, 1) AS VARCHAR2(3) ),
         jqua.update_attr_val_stmt,
         jqua.insert_attr_val_stmt,
         jtdr.top_level_terr_id,
         jta.absolute_rank,
         jtdr.start_date,
         jtdr.end_date,
         count(*) over(partition by jtqa.qual_usg_id)
  FROM   jtf_terr_all               jta,
         jty_denorm_dea_rules_all   jtdr,
         jtf_terr_qual_all          jtqa,
         jtf_terr_values_all        jtva,
         jtf_qual_usgs_all          jqua,
         jtf_qual_type_usgs_all     jqtu,
         jtf_qual_type_denorm_v     inlv,
         jtf_terr_cnr_groups        cnrg,
         jtf_terr_cnr_group_values  cnrgv
  WHERE  jta.terr_id = cl_terr_id
  AND    jtdr.terr_id = jta.terr_id
  AND    jtdr.related_terr_id = jtqa.terr_id
  AND    jtqa.terr_qual_id = jtva.terr_qual_id
  AND    jtqa.qual_usg_id = jqua.qual_usg_id
  AND    jqua.org_id = -3113
  AND    jqua.qual_type_usg_id = jqtu.qual_type_usg_id
  AND    jqtu.source_id = cl_source_id
  AND    jqtu.qual_type_id = inlv.related_id
  AND    inlv.qual_type_id = cl_qual_type_id
  AND    jtqa.qual_usg_id = -1102  -- include CNRG
  AND    cnrg.cnr_group_id = jtva.low_value_char_id
  AND    cnrg.cnr_group_id = cnrgv.cnr_group_id
  AND    EXISTS
         (SELECT 1
          FROM   jtf_terr_rsc_all jtr,
                 jtf_terr_rsc_access_all jtra,
                 jtf_qual_types_all jqta
          WHERE  jtr.terr_id = jta.terr_id
          AND    jtr.resource_type <> 'RS_ROLE'
          AND    jtr.terr_rsc_id = jtra.terr_rsc_id
          AND    jtra.access_type = jqta.name
          AND    jqta.qual_type_id + 0 = cl_qual_type_id
          AND    jtra.trans_access_code <> 'NONE')
  ORDER BY 1;

  CURSOR c_column_names(p_table_name IN VARCHAR2, p_owner IN VARCHAR2) is
  SELECT column_name
  FROM  all_tab_columns
  WHERE table_name = p_table_name
  AND   owner      = p_owner
  AND   column_name not in ('SECURITY_GROUP_ID', 'OBJECT_VERSION_NUMBER', 'LAST_UPDATE_DATE',
                            'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN', 'REQUEST_ID',
                            'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE', 'DENORM_TERR_ATTR_VALUES_ID',
                            'DENORM_TERR_DEA_VALUES_ID');

  TYPE l_qtype_terr_id_tbl_type IS TABLE OF jtf_terr_all.terr_id%TYPE;
  TYPE l_qtype_trans_id_tbl_type IS TABLE OF jtf_qual_types_all.qual_type_id%TYPE;
  TYPE l_qtype_source_id_tbl_type IS TABLE OF jtf_sources_all.source_id%TYPE;
  TYPE l_qtype_num_qual_tbl_type IS TABLE OF jtf_terr_qtype_usgs_all.num_qual%TYPE;
  TYPE l_qtype_qual_prd_tbl_type IS TABLE OF jtf_terr_qtype_usgs_all.qual_relation_product%TYPE;

  TYPE l_qual_type_id_tbl_type IS TABLE OF jtf_qual_type_usgs_all.qual_type_id%TYPE;
  TYPE l_qual_usg_id_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_usg_id%TYPE;
  TYPE l_qual_rel_fac_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_relation_factor%TYPE;
  TYPE l_cop_tbl_type IS TABLE OF jtf_terr_values_all.comparison_operator%TYPE;
  TYPE l_lvc_id_tbl_type IS TABLE OF jtf_terr_values_all.low_value_char_id%TYPE;
  TYPE l_lvc_tbl_type IS TABLE OF jtf_terr_values_all.low_value_char%TYPE;
  TYPE l_hvc_tbl_type IS TABLE OF jtf_terr_values_all.high_value_char%TYPE;
  TYPE l_lvn_tbl_type IS TABLE OF jtf_terr_values_all.low_value_number%TYPE;
  TYPE l_hvn_tbl_type IS TABLE OF jtf_terr_values_all.high_value_number%TYPE;
  TYPE l_it_id_tbl_type IS TABLE OF jtf_terr_values_all.interest_type_id%TYPE;
  TYPE l_pic_id_tbl_type IS TABLE OF jtf_terr_values_all.primary_interest_code_id%TYPE;
  TYPE l_sic_id_tbl_type IS TABLE OF jtf_terr_values_all.secondary_interest_code_id%TYPE;
  TYPE l_curr_tbl_type IS TABLE OF jtf_terr_values_all.currency_code%TYPE;
  TYPE l_value1_id_tbl_type IS TABLE OF jtf_terr_values_all.value1_id%TYPE;
  TYPE l_value2_id_tbl_type IS TABLE OF jtf_terr_values_all.value2_id%TYPE;
  TYPE l_value3_id_tbl_type IS TABLE OF jtf_terr_values_all.value3_id%TYPE;
  TYPE l_value4_id_tbl_type IS TABLE OF jtf_terr_values_all.value4_id%TYPE;
  TYPE l_fc_tbl_type IS TABLE OF jtf_terr_values_all.first_char%TYPE;
  TYPE l_update_stmt_tbl_type IS TABLE OF jtf_qual_usgs_all.update_attr_val_stmt%TYPE;
  TYPE l_insert_stmt_tbl_type IS TABLE OF jtf_qual_usgs_all.insert_attr_val_stmt%TYPE;
  TYPE l_top_lvl_terr_id_tbl_type IS TABLE OF jtf_terr_denorm_rules_all.top_level_terr_id%TYPE;
  TYPE l_abs_rank_tbl_type IS TABLE OF jtf_terr_denorm_rules_all.absolute_rank%TYPE;
  TYPE l_start_date_tbl_type IS TABLE OF jtf_terr_denorm_rules_all.start_date%TYPE;
  TYPE l_end_date_tbl_type IS TABLE OF jtf_terr_denorm_rules_all.end_date%TYPE;
  TYPE l_no_of_val_tbl_type IS TABLE OF NUMBER;
  TYPE l_rowid_tbl_type IS TABLE OF ROWID;

  l_qual_type_id_tbl l_qual_type_id_tbl_type;
  l_qual_usg_id_tbl  l_qual_usg_id_tbl_type;
  l_qual_rel_fac_tbl l_qual_rel_fac_tbl_type;
  l_cop_tbl          l_cop_tbl_type;
  l_lvc_id_tbl       l_lvc_id_tbl_type;
  l_lvc_tbl          l_lvc_tbl_type;
  l_hvc_tbl          l_hvc_tbl_type;
  l_lvn_tbl          l_lvn_tbl_type;
  l_hvn_tbl          l_hvn_tbl_type;
  l_it_id_tbl        l_it_id_tbl_type;
  l_pic_id_tbl       l_pic_id_tbl_type;
  l_sic_id_tbl       l_sic_id_tbl_type;
  l_curr_tbl         l_curr_tbl_type;
  l_value1_id_tbl    l_value1_id_tbl_type;
  l_value2_id_tbl    l_value2_id_tbl_type;
  l_value3_id_tbl    l_value3_id_tbl_type;
  l_value4_id_tbl    l_value4_id_tbl_type;
  l_fc_tbl           l_fc_tbl_type;
  l_update_stmt_tbl  l_update_stmt_tbl_type;
  l_insert_stmt_tbl  l_insert_stmt_tbl_type;
  l_top_lvl_terr_id_tbl l_top_lvl_terr_id_tbl_type;
  l_abs_rank_tbl     l_abs_rank_tbl_type;
  l_start_date_tbl   l_start_date_tbl_type;
  l_end_date_tbl     l_end_date_tbl_type;
  l_no_of_val_tbl    l_no_of_val_tbl_type;
  l_rowid_tbl        l_rowid_tbl_type;

  l_qtype_terr_id_tbl   l_qtype_terr_id_tbl_type;
  l_qtype_trans_id_tbl  l_qtype_trans_id_tbl_type;
  l_qtype_source_id_tbl l_qtype_source_id_tbl_type;
  l_qtype_num_qual_tbl  l_qtype_num_qual_tbl_type;
  l_qtype_qual_prd_tbl  l_qtype_qual_prd_tbl_type;

  l_num_qual               NUMBER;
  l_qual_relation_product  NUMBER;
  l_terr_qval_counter      NUMBER;
  l_owner                  VARCHAR2(30);
  l_indent                 VARCHAR2(30);
  l_status                 VARCHAR2(30);
  l_industry               VARCHAR2(30);
  first_time               BOOLEAN;
  l_table_name             VARCHAR2(30);

  l_delete_stmt            VARCHAR2(200);
  l_update_stmt            VARCHAR2(3000);
  l_rowid_update_stmt      VARCHAR2(3000);
  l_rowid_insert_stmt      VARCHAR2(3000);
  l_insert_stmt            VARCHAR2(10000);
  l_select_stmt            VARCHAR2(10000);

  x_return_status          VARCHAR2(250);

  L_SCHEMA_NOTFOUND        EXCEPTION;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.process_attr_values ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* initialize the pl/sql tables */
  l_qtype_terr_id_tbl   := l_qtype_terr_id_tbl_type();
  l_qtype_trans_id_tbl  := l_qtype_trans_id_tbl_type();
  l_qtype_source_id_tbl := l_qtype_source_id_tbl_type();
  l_qtype_num_qual_tbl  := l_qtype_num_qual_tbl_type();
  l_qtype_qual_prd_tbl  := l_qtype_qual_prd_tbl_type();

  l_table_name := p_table_name;

  IF (p_terr_change_tab.terr_id.COUNT > 0) THEN

    /* delete the old data from global temp table */
    DELETE jty_denorm_terr_attr_values_gt;

    /* if mode is incremental, delete the old entries of the territory from the denorm table */
    IF (p_mode = 'INCREMENTAL') THEN
      l_delete_stmt := 'DELETE ' || l_table_name || ' where terr_id = :1 and :2 IN (''I'', ''D'') ';

      FOR i IN p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST LOOP
        execute immediate l_delete_stmt USING p_terr_change_tab.terr_id(i), p_terr_change_tab.attr_processing_flag(i);
      END LOOP;
    END IF;

    FOR i IN p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST LOOP

      IF (p_terr_change_tab.attr_processing_flag(i) IN ('I', 'D')) THEN

        /* Get all the transaction types for the territory */
        OPEN c_qual_types(p_source_id, p_terr_change_tab.terr_id(i));
        FETCH c_qual_types BULK COLLECT INTO l_qual_type_id_tbl;
        CLOSE c_qual_types;

        IF (l_qual_type_id_tbl.COUNT > 0) THEN
          /* for each transaction type calculate num_qual and qual_relation_product */
          /* and also denormalize the qualifier values for the territory            */
          FOR j IN l_qual_type_id_tbl.FIRST .. l_qual_type_id_tbl.LAST LOOP
            l_num_qual               := 0;
            l_qual_relation_product  := 1;

            /*  Get all the qualifiers and their values of the territory */
            IF (p_mode = 'DATE EFFECTIVE') THEN
              OPEN c_terr_dea_qual_values(p_terr_change_tab.terr_id(i), p_source_id, l_qual_type_id_tbl(j));
              FETCH c_terr_dea_qual_values BULK COLLECT INTO
                 l_qual_usg_id_tbl
                ,l_qual_rel_fac_tbl
                ,l_cop_tbl
                ,l_lvc_id_tbl
                ,l_lvc_tbl
                ,l_hvc_tbl
                ,l_lvn_tbl
                ,l_hvn_tbl
                ,l_it_id_tbl
                ,l_pic_id_tbl
                ,l_sic_id_tbl
                ,l_curr_tbl
                ,l_value1_id_tbl
                ,l_value2_id_tbl
                ,l_value3_id_tbl
                ,l_value4_id_tbl
                ,l_fc_tbl
                ,l_update_stmt_tbl
                ,l_insert_stmt_tbl
                ,l_top_lvl_terr_id_tbl
                ,l_abs_rank_tbl
                ,l_start_date_tbl
                ,l_end_date_tbl
                ,l_no_of_val_tbl;
              CLOSE c_terr_dea_qual_values;
            ELSE
              OPEN c_terr_qual_values(p_terr_change_tab.terr_id(i), p_source_id, l_qual_type_id_tbl(j));
              FETCH c_terr_qual_values BULK COLLECT INTO
                 l_qual_usg_id_tbl
                ,l_qual_rel_fac_tbl
                ,l_cop_tbl
                ,l_lvc_id_tbl
                ,l_lvc_tbl
                ,l_hvc_tbl
                ,l_lvn_tbl
                ,l_hvn_tbl
                ,l_it_id_tbl
                ,l_pic_id_tbl
                ,l_sic_id_tbl
                ,l_curr_tbl
                ,l_value1_id_tbl
                ,l_value2_id_tbl
                ,l_value3_id_tbl
                ,l_value4_id_tbl
                ,l_fc_tbl
                ,l_update_stmt_tbl
                ,l_insert_stmt_tbl
                ,l_top_lvl_terr_id_tbl
                ,l_abs_rank_tbl
                ,l_start_date_tbl
                ,l_end_date_tbl
                ,l_no_of_val_tbl;
              CLOSE c_terr_qual_values;
            END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */

            IF (l_qual_usg_id_tbl.COUNT > 0) THEN
              l_terr_qval_counter := l_qual_usg_id_tbl.FIRST;

              /* process each qualifier of the territory for the transaction type */
              WHILE l_terr_qval_counter IS NOT NULL LOOP
                /* for each qualifier, calcualte number of qualifiers and qual relation product */
                l_num_qual := l_num_qual + 1;
                l_qual_relation_product := l_qual_relation_product * l_qual_rel_fac_tbl(l_terr_qval_counter);

				 IF (l_no_of_val_tbl(l_terr_qval_counter) = 1) THEN

                  /* control reaching here means that the number of values for the qualifier is one  */
                  /* update the global temp table with the qualifier values, insert if no data found */
                  l_update_stmt := replace(l_update_stmt_tbl(l_terr_qval_counter),
                                      'UPDATE', 'UPDATE /*+ index(JTY_DENORM_TERR_ATTR_VALUES_GT jty_dnm_terr_values_gt_n1) */ ');
                  EXECUTE IMMEDIATE l_update_stmt USING
                     l_cop_tbl(l_terr_qval_counter)
                    ,l_lvc_id_tbl(l_terr_qval_counter)
                    ,l_lvc_tbl(l_terr_qval_counter)
                    ,l_hvc_tbl(l_terr_qval_counter)
                    ,l_lvn_tbl(l_terr_qval_counter)
                    ,l_hvn_tbl(l_terr_qval_counter)
                    ,l_it_id_tbl(l_terr_qval_counter)
                    ,l_pic_id_tbl(l_terr_qval_counter)
                    ,l_sic_id_tbl(l_terr_qval_counter)
                    ,l_curr_tbl(l_terr_qval_counter)
                    ,l_value1_id_tbl(l_terr_qval_counter)
                    ,l_value2_id_tbl(l_terr_qval_counter)
                    ,l_value3_id_tbl(l_terr_qval_counter)
                    ,l_value4_id_tbl(l_terr_qval_counter)
                    ,l_fc_tbl(l_terr_qval_counter)
                    ,p_terr_change_tab.terr_id(i)
                    ,p_source_id
                    ,l_qual_type_id_tbl(j);

                  IF (SQL%ROWCOUNT = 0) THEN
                    EXECUTE IMMEDIATE l_insert_stmt_tbl(l_terr_qval_counter) USING
                       p_terr_change_tab.terr_id(i)
                      ,l_start_date_tbl(l_terr_qval_counter)
                      ,l_end_date_tbl(l_terr_qval_counter)
                      ,p_source_id
                      ,l_qual_type_id_tbl(j)
                      ,G_SYSDATE
                      ,G_USER_ID
                      ,G_SYSDATE
                      ,G_USER_ID
                      ,G_USER_ID
                      ,l_abs_rank_tbl(l_terr_qval_counter)
                      ,l_top_lvl_terr_id_tbl(l_terr_qval_counter)
                      ,G_PROGRAM_ID
                      ,G_USER_ID
                      ,G_PROGRAM_APPL_ID
                      ,G_REQUEST_ID
                      ,G_SYSDATE
                      ,l_cop_tbl(l_terr_qval_counter)
                      ,l_lvc_id_tbl(l_terr_qval_counter)
                      ,l_lvc_tbl(l_terr_qval_counter)
                      ,l_hvc_tbl(l_terr_qval_counter)
                      ,l_lvn_tbl(l_terr_qval_counter)
                      ,l_hvn_tbl(l_terr_qval_counter)
                      ,l_it_id_tbl(l_terr_qval_counter)
                      ,l_pic_id_tbl(l_terr_qval_counter)
                      ,l_sic_id_tbl(l_terr_qval_counter)
                      ,l_curr_tbl(l_terr_qval_counter)
                      ,l_value1_id_tbl(l_terr_qval_counter)
                      ,l_value2_id_tbl(l_terr_qval_counter)
                      ,l_value3_id_tbl(l_terr_qval_counter)
                      ,l_value4_id_tbl(l_terr_qval_counter)
                      ,l_fc_tbl(l_terr_qval_counter);
                  END IF; /* end IF (SQL%ROWCOUNT = 0) */

                  l_terr_qval_counter := l_qual_usg_id_tbl.NEXT(l_terr_qval_counter);

                ELSE

                  /* control reaching here means that the number of values for the qualifier is more than one */
                  FOR k IN 1 .. l_no_of_val_tbl(l_terr_qval_counter) LOOP
                    IF (k = 1) THEN
                      l_rowid_update_stmt := replace(l_update_stmt_tbl(l_terr_qval_counter),
                                      'UPDATE', 'UPDATE /*+ index(JTY_DENORM_TERR_ATTR_VALUES_GT jty_dnm_terr_values_gt_n1) */ ') ||
                                                  ' returning rowid into :19 ';

                      /* for the first value, update the existing rows with the qualifier values */
                      /* if there is no row, insert a row for the qualifier values               */
                      EXECUTE IMMEDIATE l_rowid_update_stmt USING
                         l_cop_tbl(l_terr_qval_counter)
                        ,l_lvc_id_tbl(l_terr_qval_counter)
                        ,l_lvc_tbl(l_terr_qval_counter)
                        ,l_hvc_tbl(l_terr_qval_counter)
                        ,l_lvn_tbl(l_terr_qval_counter)
                        ,l_hvn_tbl(l_terr_qval_counter)
                        ,l_it_id_tbl(l_terr_qval_counter)
                        ,l_pic_id_tbl(l_terr_qval_counter)
                        ,l_sic_id_tbl(l_terr_qval_counter)
                        ,l_curr_tbl(l_terr_qval_counter)
                        ,l_value1_id_tbl(l_terr_qval_counter)
                        ,l_value2_id_tbl(l_terr_qval_counter)
                        ,l_value3_id_tbl(l_terr_qval_counter)
                        ,l_value4_id_tbl(l_terr_qval_counter)
                        ,l_fc_tbl(l_terr_qval_counter)
                        ,p_terr_change_tab.terr_id(i)
                        ,p_source_id
                        ,l_qual_type_id_tbl(j)
                      RETURNING BULK COLLECT INTO l_rowid_tbl;

                      IF (SQL%ROWCOUNT = 0) THEN
                        l_rowid_insert_stmt := l_insert_stmt_tbl(l_terr_qval_counter) ||
                                                  ' returning rowid into :33 ';

                        EXECUTE IMMEDIATE l_rowid_insert_stmt USING
                           p_terr_change_tab.terr_id(i)
                          ,l_start_date_tbl(l_terr_qval_counter)
                          ,l_end_date_tbl(l_terr_qval_counter)
                          ,p_source_id
                          ,l_qual_type_id_tbl(j)
                          ,G_SYSDATE
                          ,G_USER_ID
                          ,G_SYSDATE
                          ,G_USER_ID
                          ,G_USER_ID
                          ,l_abs_rank_tbl(l_terr_qval_counter)
                          ,l_top_lvl_terr_id_tbl(l_terr_qval_counter)
                          ,G_PROGRAM_ID
                          ,G_USER_ID
                          ,G_PROGRAM_APPL_ID
                          ,G_REQUEST_ID
                          ,G_SYSDATE
                          ,l_cop_tbl(l_terr_qval_counter)
                          ,l_lvc_id_tbl(l_terr_qval_counter)
                          ,l_lvc_tbl(l_terr_qval_counter)
                          ,l_hvc_tbl(l_terr_qval_counter)
                          ,l_lvn_tbl(l_terr_qval_counter)
                          ,l_hvn_tbl(l_terr_qval_counter)
                          ,l_it_id_tbl(l_terr_qval_counter)
                          ,l_pic_id_tbl(l_terr_qval_counter)
                          ,l_sic_id_tbl(l_terr_qval_counter)
                          ,l_curr_tbl(l_terr_qval_counter)
                          ,l_value1_id_tbl(l_terr_qval_counter)
                          ,l_value2_id_tbl(l_terr_qval_counter)
                          ,l_value3_id_tbl(l_terr_qval_counter)
                          ,l_value4_id_tbl(l_terr_qval_counter)
                          ,l_fc_tbl(l_terr_qval_counter)
                        RETURNING BULK COLLECT INTO l_rowid_tbl;
                      END IF; /* end IF (SQL%ROWCOUNT = 0) */

                      l_terr_qval_counter := l_qual_usg_id_tbl.NEXT(l_terr_qval_counter);

                    ELSE
                      /* for the second value onwards, duplicate the existing rows */
                      /* and update the existing rows with the qualifier values    */
                      /* duplicate the existing rows and update with the qualifier values */
                      FORALL l IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST
                        INSERT INTO jty_denorm_terr_attr_values_gt (
                          SELECT * FROM jty_denorm_terr_attr_values_gt
                          WHERE  rowid = l_rowid_tbl(l));

                      l_rowid_update_stmt := l_update_stmt_tbl(l_terr_qval_counter) ||
                                                  ' and rowid = :19 ';

                      FORALL l IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST
                        EXECUTE IMMEDIATE l_rowid_update_stmt USING
                           l_cop_tbl(l_terr_qval_counter)
                          ,l_lvc_id_tbl(l_terr_qval_counter)
                          ,l_lvc_tbl(l_terr_qval_counter)
                          ,l_hvc_tbl(l_terr_qval_counter)
                          ,l_lvn_tbl(l_terr_qval_counter)
                          ,l_hvn_tbl(l_terr_qval_counter)
                          ,l_it_id_tbl(l_terr_qval_counter)
                          ,l_pic_id_tbl(l_terr_qval_counter)
                          ,l_sic_id_tbl(l_terr_qval_counter)
                          ,l_curr_tbl(l_terr_qval_counter)
                          ,l_value1_id_tbl(l_terr_qval_counter)
                          ,l_value2_id_tbl(l_terr_qval_counter)
                          ,l_value3_id_tbl(l_terr_qval_counter)
                          ,l_value4_id_tbl(l_terr_qval_counter)
                          ,l_fc_tbl(l_terr_qval_counter)
                          ,p_terr_change_tab.terr_id(i)
                          ,p_source_id
                          ,l_qual_type_id_tbl(j)
                          ,l_rowid_tbl(l);

                      l_terr_qval_counter := l_qual_usg_id_tbl.NEXT(l_terr_qval_counter);

                    END IF; /* end IF (k = 1) */
                  END LOOP; /* end loop FOR k IN 1 .. l_no_of_val_tbl(l_terr_qval_counter) */

                END IF; /* end IF (l_no_of_val_tbl(l_terr_qval_counter) = 1) */

              END LOOP; /* end loop WHILE l_terr_qval_counter IS NOT NULL */
            END IF; /* end IF (l_qual_usg_id_tbl.COUNT > 0) */

            l_qtype_terr_id_tbl.EXTEND();
            l_qtype_trans_id_tbl.EXTEND();
            l_qtype_source_id_tbl.EXTEND();
            l_qtype_num_qual_tbl.EXTEND();
            l_qtype_qual_prd_tbl.EXTEND();

            l_qtype_terr_id_tbl(l_qtype_terr_id_tbl.COUNT) := p_terr_change_tab.terr_id(i);
            l_qtype_trans_id_tbl(l_qtype_trans_id_tbl.COUNT) := l_qual_type_id_tbl(j);
            l_qtype_source_id_tbl(l_qtype_source_id_tbl.COUNT) := p_source_id;
            l_qtype_num_qual_tbl(l_qtype_num_qual_tbl.COUNT) := l_num_qual;
            l_qtype_qual_prd_tbl(l_qtype_qual_prd_tbl.COUNT) := l_qual_relation_product;

          END LOOP; /* end loop  FOR j IN l_qual_type_id_tbl.FIRST .. l_qual_type_id_tbl.LAST */
        END IF; /* end IF (l_qual_type_id_tbl.COUNT > 0) */
      END IF; /* end IF (p_terr_change_tab.attr_processing_flag(i) IN ('I', 'D')) */

      /* update num_qual and qual_relation_product if # of rows > g_commit_size to avoid memory overflow */
      IF (l_qtype_terr_id_tbl.COUNT >= G_COMMIT_SIZE) THEN

        /* disable the trigger before update */
        BEGIN
          EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        /* update num_qual and qual_relation_product */
        FORALL l in l_qtype_terr_id_tbl.FIRST .. l_qtype_terr_id_tbl.LAST
          UPDATE jtf_terr_qtype_usgs_all
          SET    num_qual = l_qtype_num_qual_tbl(l),
                 qual_relation_product = l_qtype_qual_prd_tbl(l)
          WHERE  terr_id = l_qtype_terr_id_tbl(l)
          AND    qual_type_usg_id =
                    (SELECT qual_type_usg_id
                     FROM   jtf_qual_type_usgs_all
                     WHERE  source_id = l_qtype_source_id_tbl(l)
                     AND    qual_type_id = l_qtype_trans_id_tbl(l));

        /* enable the trigger after update */
        BEGIN
          EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

       /* l_qtype_terr_id_tbl.TRIM();
        l_qtype_trans_id_tbl.TRIM();
        l_qtype_source_id_tbl.TRIM();
        l_qtype_num_qual_tbl.TRIM();
        l_qtype_qual_prd_tbl.TRIM();
      Fix for bug 7240171 */
        l_qtype_terr_id_tbl.DELETE;
        l_qtype_trans_id_tbl.DELETE;
        l_qtype_source_id_tbl.DELETE;
        l_qtype_num_qual_tbl.DELETE;
        l_qtype_qual_prd_tbl.DELETE;

      END IF; /* end IF (l_qtype_terr_id_tbl.COUNT >= G_COMMIT_SIZE) */
    END LOOP; /* end loop FOR i IN p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST */
  END IF; /* end IF (p_terr_change_tab.terr_id.COUNT > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.denorm_value_gt',
                   'Done populating the global temp table with denormalised informations');

  /* Move the denormalized territory qualifier values from global temp table to the actual one */
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

  /* Form the insert statement to insert the denormalized informations from global temp table to physical table */
  l_insert_stmt := 'INSERT INTO ' || l_table_name || ' ( ';
  l_select_stmt := '(SELECT ';

  FOR column_names in c_column_names(l_table_name, l_owner) LOOP
    IF (first_time) THEN
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || column_names.column_name;
      first_time := FALSE;
    ELSE
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',' || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || ',' || column_names.column_name;
    END IF;
  END LOOP;

  /* Standard WHO columns */
  l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',CREATION_DATE ' ||
                     g_new_line || l_indent || ',CREATED_BY ' ||
                     g_new_line || l_indent || ',LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',REQUEST_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_UPDATE_DATE ) ';

  l_select_stmt := l_select_stmt || g_new_line || l_indent || ',:1' ||
                     g_new_line || l_indent || ',:2' ||
                     g_new_line || l_indent || ',:3' ||
                     g_new_line || l_indent || ',:4' ||
                     g_new_line || l_indent || ',:5' ||
                     g_new_line || l_indent || ',:6' ||
                     g_new_line || l_indent || ',:7' ||
                     g_new_line || l_indent || ',:8' ||
                     g_new_line || l_indent || ',:9' ||
                     g_new_line || l_indent || ' FROM jty_denorm_terr_attr_values_gt) ';

 jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.denorm_value',
                   'Start Insert into denormalized table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  EXECUTE IMMEDIATE l_insert_stmt || l_select_stmt USING
     g_sysdate
    ,g_user_id
    ,g_sysdate
    ,g_user_id
    ,g_login_id
    ,g_request_id
    ,g_program_appl_id
    ,g_program_id
    ,g_sysdate;

 jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.denorm_value',
                   'End Insert into denormalized table ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.denorm_value',
                   'Number of rows inserted : ' || SQL%ROWCOUNT);

  /* analyze the denorm value table to caluclate the selectivity of the columns */
  IF (p_mode <> 'INCREMENTAL') THEN
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                                 p_table_name    => l_table_name
                               , p_percent       => 20
                               , x_return_status => x_return_status );
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    retcode := 2;
    errbuf := 'JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for table ' || l_table_name;
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.analyze_table_index',
                         'ANALYZE_TABLE_INDEX API has failed');

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_qtype_terr_id_tbl.COUNT > 0) THEN
    /* disable the trigger before update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD DISABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    /* update num_qual and qual_relation_product */
    FORALL l in l_qtype_terr_id_tbl.FIRST .. l_qtype_terr_id_tbl.LAST
      UPDATE jtf_terr_qtype_usgs_all
      SET    num_qual = l_qtype_num_qual_tbl(l),
             qual_relation_product = l_qtype_qual_prd_tbl(l)
      WHERE  terr_id = l_qtype_terr_id_tbl(l)
      AND    qual_type_usg_id =
                    (SELECT qual_type_usg_id
                     FROM   jtf_qual_type_usgs_all
                     WHERE  source_id = l_qtype_source_id_tbl(l)
                     AND    qual_type_id = l_qtype_trans_id_tbl(l));

    /* enable the trigger before update */
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERR_QTYPE_USGS_BIUD ENABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

   /* l_qtype_terr_id_tbl.TRIM();
    l_qtype_trans_id_tbl.TRIM();
    l_qtype_source_id_tbl.TRIM();
    l_qtype_num_qual_tbl.TRIM();
    l_qtype_qual_prd_tbl.TRIM();
    Fix for bug 7240171 */
     l_qtype_terr_id_tbl.DELETE;
     l_qtype_trans_id_tbl.DELETE;
     l_qtype_source_id_tbl.DELETE;
     l_qtype_num_qual_tbl.DELETE;
     l_qtype_qual_prd_tbl.DELETE;

  END IF; /* end IF (l_qtype_terr_id_tbl.COUNT > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.update_num_qual',
                   'Done updating jtf_terr_qtype_usgs_all with num_qual and qual_relation_product');

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.process_attr_values ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.g_exc_error',
                     'API JTY_TERR_DENORM_RULES_PVT.process_attr_values has failed with FND_API.G_EXC_ERROR exception');

  WHEN L_SCHEMA_NOTFOUND THEN
    RETCODE := 2;
    ERRBUF  := 'JTY_TERR_DENORM_RULES_PVT.process_attr_values : SCHEMA NAME NOT FOUND CORRESPONDING TO JTF APPLICATION. ';
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.l_schema_notfound',
                     errbuf);

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_values.others',
                     substr(errbuf, 1, 4000));

END process_attr_values;

/* This procedure calculates relative rank and denormalized hierarchy informations */
PROCEDURE process_terr_rank (
  p_source_id        IN NUMBER,
  p_mode             IN VARCHAR2,
  p_terr_change_tab  IN JTY_TERR_ENGINE_GEN_PVT.terr_change_type,
  p_table_name       IN VARCHAR2,
  errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2 )
IS

  l_new_parent_territory_id  NUMBER;
  l_parent_terr_id           NUMBER;
  l_new_parent_num_winners   NUMBER;
  l_level_from_root          NUMBER;
  l_max_rank                 NUMBER;

  l_rows_inserted1           INTEGER;
  l_rows_inserted2           INTEGER;
  l_no_of_records            INTEGER;

  l_dyn_str                  VARCHAR2(1000);

  l_terr_id_tbl1                 jtf_terr_number_list := jtf_terr_number_list();
  l_related_terr_id_tbl          jtf_terr_number_list := jtf_terr_number_list();
  l_top_level_terr_id_tbl        jtf_terr_number_list := jtf_terr_number_list();
  l_num_winners_tbl              jtf_terr_number_list := jtf_terr_number_list();
  l_level_from_root_tbl          jtf_terr_number_list := jtf_terr_number_list();
  l_level_from_parent_tbl        jtf_terr_number_list := jtf_terr_number_list();
  l_terr_rank_tbl                jtf_terr_number_list := jtf_terr_number_list();
  l_immediate_parent_flag_tbl    jtf_terr_char_1list  := jtf_terr_char_1list();
  l_org_id_tbl                   jtf_terr_number_list := jtf_terr_number_list();
  l_start_date_tbl               jtf_terr_date_list   := jtf_terr_date_list();
  l_end_date_tbl                 jtf_terr_date_list   := jtf_terr_date_list();

  l_terr_id_tbl2                 jtf_terr_number_list := jtf_terr_number_list();
  l_relative_rank_tbl            jtf_terr_number_list := jtf_terr_number_list();

  l_qual_type_id_tbl             jtf_terr_number_list := jtf_terr_number_list();

  CURSOR c_get_qual_type_id (cl_source_id IN NUMBER) IS
  SELECT qual_type_id
  FROM   jtf_qual_type_usgs_all
  WHERE  source_id = cl_source_id
  AND    qual_type_id <> -1001;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.process_terr_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Get the maximum rank among the territories for the usage */
  BEGIN

    SELECT /*+ ORDERED */ nvl(MAX(j2.rank), 99)
    INTO l_max_rank
    FROM jtf_qual_type_usgs j1
       , jtf_terr_qtype_usgs_all j4
       , jtf_terr_all j2
    WHERE j2.terr_id <> 1
    AND j4.terr_id = j2.terr_id
    AND j4.qual_type_usg_id = j1.qual_type_usg_id
    AND j1.source_id = p_source_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_max_rank := 99;
  END;

  l_rows_inserted1 := 0;
  l_rows_inserted2 := 0;

  IF (p_terr_change_tab.terr_id.COUNT > 0) THEN

    FOR i IN p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST LOOP

      /* if mode is incremental, delete all entries from denorm table for the territory */
      IF ((p_terr_change_tab.hier_processing_flag(i) IN ('I', 'D')) AND (p_mode = 'INCREMENTAL')) THEN
        DELETE jtf_terr_denorm_rules_all
        WHERE  terr_id = p_terr_change_tab.terr_id(i);
      END IF;

      /* if the # of rows that need to updated for relative rank exceeds        */
      /* g_commit_size, then update the physical table to avoid memory overflow */
      IF (l_rows_inserted2 >= G_COMMIT_SIZE) THEN
        update_relative_rank (
          p_terr_id_tbl       => l_terr_id_tbl2,
          p_relative_rank_tbl => l_relative_rank_tbl,
          errbuf              => errbuf,
          retcode             => retcode);

        IF (retcode <> 0) THEN
          -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_relative_rank',
                           'update_relative_rank API has failed');

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

         update_absolute_rank (
          p_terr_id_tbl      => l_terr_id_tbl2,
          p_mode             => p_mode,
          p_table_name       => p_table_name,
          errbuf             => errbuf,
          retcode            => retcode);

        IF (retcode <> 0) THEN
          -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_absolute_rank',
                           'update_absolute_rank API has failed');

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

        l_terr_id_tbl2.TRIM(l_rows_inserted2);
        l_relative_rank_tbl.TRIM(l_rows_inserted2);

        l_rows_inserted2 := 0;
      END IF; /* end IF (l_rows_inserted2 >= G_COMMIT_SIZE) */

      /* if the # of rows that need to updated for denorm hier table exceeds    */
      /* g_commit_size, then update the physical table to avoid memory overflow */
      IF (l_rows_inserted1 >= G_COMMIT_SIZE) THEN
        update_denorm_table (
          p_source_id                 => p_source_id,
          p_mode                      => p_mode,
          p_terr_id_tbl               => l_terr_id_tbl1,
          p_related_terr_id_tbl       => l_related_terr_id_tbl,
          p_top_level_terr_id_tbl     => l_top_level_terr_id_tbl,
          p_num_winners_tbl           => l_num_winners_tbl,
          p_level_from_root_tbl       => l_level_from_root_tbl,
          p_level_from_parent_tbl     => l_level_from_parent_tbl,
          p_terr_rank_tbl             => l_terr_rank_tbl,
          p_immediate_parent_flag_tbl => l_immediate_parent_flag_tbl,
          p_org_id_tbl                => l_org_id_tbl,
          p_start_date_tbl            => l_start_date_tbl,
          p_end_date_tbl              => l_end_date_tbl,
          errbuf                      => errbuf,
          retcode                     => retcode);

        IF (retcode <> 0) THEN
          -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_denorm_table',
                           'update_denorm_table API has failed');

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

        l_terr_id_tbl1.TRIM(l_rows_inserted1);
        l_related_terr_id_tbl.TRIM(l_rows_inserted1);
        l_top_level_terr_id_tbl.TRIM(l_rows_inserted1);
        l_num_winners_tbl.TRIM(l_rows_inserted1);
        l_level_from_root_tbl.TRIM(l_rows_inserted1);
        l_level_from_parent_tbl.TRIM(l_rows_inserted1);
        l_terr_rank_tbl.TRIM(l_rows_inserted1);
        l_immediate_parent_flag_tbl.TRIM(l_rows_inserted1);
        l_org_id_tbl.TRIM(l_rows_inserted1);
        l_start_date_tbl.TRIM(l_rows_inserted1);
        l_end_date_tbl.TRIM(l_rows_inserted1);

        l_rows_inserted1 := 0;
      END IF;

      l_level_from_root := p_terr_change_tab.level_from_root(i);

      /* calculate the relative rank of the territory */
      IF (p_terr_change_tab.rank_calc_flag(i) = 'Y') THEN
        l_rows_inserted2 := l_rows_inserted2 + 1;

        l_terr_id_tbl2.EXTEND;
        l_terr_id_tbl2(l_rows_inserted2) := p_terr_change_tab.terr_id(i);

        l_relative_rank_tbl.EXTEND;
        l_relative_rank_tbl(l_rows_inserted2) := 1/(p_terr_change_tab.terr_rank(i) * POWER(l_max_rank, l_level_from_root));
      END IF;

      IF (p_terr_change_tab.hier_processing_flag(i) = 'I') THEN
        l_rows_inserted1 := l_rows_inserted1 + 1;

        /* insert row for itself */
        l_terr_id_tbl1.EXTEND;
        l_terr_id_tbl1(l_rows_inserted1) := p_terr_change_tab.terr_id(i);

        l_related_terr_id_tbl.EXTEND;
        l_related_terr_id_tbl(l_rows_inserted1) := p_terr_change_tab.terr_id(i);

        l_num_winners_tbl.EXTEND;
        l_top_level_terr_id_tbl.EXTEND;
        IF (p_source_id = -1001) THEN
          IF ((p_terr_change_tab.parent_terr_id(i) = 1) AND (p_terr_change_tab.num_winners(i) IS NULL)) THEN
            l_num_winners_tbl(l_rows_inserted1) := 1;
          ELSE
            l_num_winners_tbl(l_rows_inserted1) := p_terr_change_tab.num_winners(i);
          END IF;
        ELSE
          SELECT jt.terr_id, NVL(jt.num_winners, 1)
          INTO   l_top_level_terr_id_tbl(l_rows_inserted1), l_num_winners_tbl(l_rows_inserted1)
          FROM   jtf_terr_all jt
          WHERE  jt.parent_territory_id = 1
          AND   (jt.org_id <> -3114 OR jt.org_id IS NULL)
          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
          START WITH jt.terr_id = p_terr_change_tab.terr_id(i);
        END IF;

        l_level_from_parent_tbl.EXTEND;
        l_level_from_parent_tbl(l_rows_inserted1) := 0;

        l_level_from_root_tbl.EXTEND;
        l_level_from_root_tbl(l_rows_inserted1) := l_level_from_root;

        l_terr_rank_tbl.EXTEND;
        l_terr_rank_tbl(l_rows_inserted1) := p_terr_change_tab.terr_rank(i);

        l_immediate_parent_flag_tbl.EXTEND;
        l_immediate_parent_flag_tbl(l_rows_inserted1) := 'N';

        l_org_id_tbl.EXTEND;
        l_org_id_tbl(l_rows_inserted1) := p_terr_change_tab.org_id(i);

        l_org_id_tbl.EXTEND;
        l_org_id_tbl(l_rows_inserted1) := p_terr_change_tab.org_id(i);

        l_start_date_tbl.EXTEND;
        l_start_date_tbl(l_rows_inserted1) := p_terr_change_tab.start_date(i);

        l_end_date_tbl.EXTEND;
        l_end_date_tbl(l_rows_inserted1) := p_terr_change_tab.end_date(i);

        /* Insert row for immediate parent */
        IF (p_terr_change_tab.terr_id(i) <> 1 AND p_terr_change_tab.parent_terr_id(i) <> 1 ) THEN
          l_rows_inserted1 := l_rows_inserted1 + 1;

          l_terr_id_tbl1.EXTEND;
          l_terr_id_tbl1(l_rows_inserted1) := p_terr_change_tab.terr_id(i);

          l_related_terr_id_tbl.EXTEND;
          l_related_terr_id_tbl(l_rows_inserted1) := p_terr_change_tab.parent_terr_id(i);

          l_num_winners_tbl.EXTEND;
          l_num_winners_tbl(l_rows_inserted1) := p_terr_change_tab.parent_num_winners(i);

          l_top_level_terr_id_tbl.EXTEND;
          l_top_level_terr_id_tbl(l_rows_inserted1) := l_top_level_terr_id_tbl(l_rows_inserted1 - 1);

          l_level_from_parent_tbl.EXTEND;
          l_level_from_parent_tbl(l_rows_inserted1) := l_level_from_parent_tbl(l_rows_inserted1 - 1) + 1;

          l_level_from_root_tbl.EXTEND;
          l_level_from_root_tbl(l_rows_inserted1) := l_level_from_root_tbl(l_rows_inserted1 - 1) - 1;

          l_terr_rank_tbl.EXTEND;
          l_terr_rank_tbl(l_rows_inserted1) := p_terr_change_tab.terr_rank(i);

          l_immediate_parent_flag_tbl.EXTEND;
          l_immediate_parent_flag_tbl(l_rows_inserted1) := 'Y';

          l_org_id_tbl.EXTEND;
          l_org_id_tbl(l_rows_inserted1) := p_terr_change_tab.org_id(i);

          l_start_date_tbl.EXTEND;
          l_start_date_tbl(l_rows_inserted1) := p_terr_change_tab.start_date(i);

          l_end_date_tbl.EXTEND;
          l_end_date_tbl(l_rows_inserted1) := p_terr_change_tab.end_date(i);

          l_parent_terr_id := p_terr_change_tab.parent_terr_id(i);

          /* insert rows for the other parents */
          LOOP
            SELECT  /*+ index(TR1 JTF_TERR_U1) */ DISTINCT TR1.PARENT_TERRITORY_ID, TR2.NUM_WINNERS
            INTO    l_new_parent_territory_id, l_new_parent_num_winners
            FROM    jtf_terr_all TR1, jtf_terr_all TR2
            WHERE   TR2.terr_id = TR1.parent_territory_id
            AND     TR1.TERR_ID <> 1
            AND     TR1.TERR_ID = l_parent_terr_id;

            EXIT WHEN ( l_parent_terr_id = 1 OR l_new_parent_territory_id  = 1 );

            l_rows_inserted1 := l_rows_inserted1 + 1;

            l_terr_id_tbl1.EXTEND;
            l_terr_id_tbl1(l_rows_inserted1) := p_terr_change_tab.terr_id(i);

            l_related_terr_id_tbl.EXTEND;
            l_related_terr_id_tbl(l_rows_inserted1) := l_new_parent_territory_id;

            l_num_winners_tbl.EXTEND;
            l_num_winners_tbl(l_rows_inserted1) := l_new_parent_num_winners;

            l_top_level_terr_id_tbl.EXTEND;
            l_top_level_terr_id_tbl(l_rows_inserted1) := l_top_level_terr_id_tbl(l_rows_inserted1 - 1);

            l_level_from_parent_tbl.EXTEND;
            l_level_from_parent_tbl(l_rows_inserted1) := l_level_from_parent_tbl(l_rows_inserted1 - 1) + 1;

            l_level_from_root_tbl.EXTEND;
            l_level_from_root_tbl(l_rows_inserted1) := l_level_from_root_tbl(l_rows_inserted1 - 1) - 1;

            l_terr_rank_tbl.EXTEND;
            l_terr_rank_tbl(l_rows_inserted1) := p_terr_change_tab.terr_rank(i);

            l_immediate_parent_flag_tbl.EXTEND;
            l_immediate_parent_flag_tbl(l_rows_inserted1) := 'N';

            l_org_id_tbl.EXTEND;
            l_org_id_tbl(l_rows_inserted1) := p_terr_change_tab.org_id(i);

            l_start_date_tbl.EXTEND;
            l_start_date_tbl(l_rows_inserted1) := p_terr_change_tab.start_date(i);

            l_end_date_tbl.EXTEND;
            l_end_date_tbl(l_rows_inserted1) := p_terr_change_tab.end_date(i);

            l_parent_terr_id := l_new_parent_territory_id;

          END LOOP;

        END IF; /* end IF (p_terr_change_tab.terr_id(i) <> 1 AND p_terr_change_tab.parent_terr_id(i) <> 1 ) */
      END IF; /* end IF (p_terr_change_tab.hier_processing_flag = 'I') */
    END LOOP; /* end loop FOR i IN p_terr_change_tab.terr_id.FIRST .. p_terr_change_tab.terr_id.LAST */

    /* update relative rank */
    IF (l_rows_inserted2 > 0) THEN
      update_relative_rank (
        p_terr_id_tbl               => l_terr_id_tbl2,
        p_relative_rank_tbl         => l_relative_rank_tbl,
        errbuf                      => errbuf,
        retcode                     => retcode);

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_relative_rank',
                         'update_relative_rank API has failed');

        RAISE	FND_API.G_EXC_ERROR;
      END IF;

      /* update absolute rank */
      update_absolute_rank (
          p_terr_id_tbl       => l_terr_id_tbl2,
          p_mode              => p_mode,
          p_table_name        => p_table_name,
          errbuf              => errbuf,
          retcode             => retcode);

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_absolute_rank',
                         'update_absolute_rank API has failed');

        RAISE	FND_API.G_EXC_ERROR;
      END IF;

     l_terr_id_tbl2.TRIM(l_rows_inserted2);


      l_relative_rank_tbl.TRIM(l_rows_inserted2);

      l_rows_inserted2 := 0;
    END IF;

    /* update denorm hier table */
    IF (l_rows_inserted1 > 0) THEN
      update_denorm_table (
        p_source_id                 => p_source_id,
        p_mode                      => p_mode,
        p_terr_id_tbl               => l_terr_id_tbl1,
        p_related_terr_id_tbl       => l_related_terr_id_tbl,
        p_top_level_terr_id_tbl     => l_top_level_terr_id_tbl,
        p_num_winners_tbl           => l_num_winners_tbl,
        p_level_from_root_tbl       => l_level_from_root_tbl,
        p_level_from_parent_tbl     => l_level_from_parent_tbl,
        p_terr_rank_tbl             => l_terr_rank_tbl,
        p_immediate_parent_flag_tbl => l_immediate_parent_flag_tbl,
        p_org_id_tbl                => l_org_id_tbl,
        p_start_date_tbl            => l_start_date_tbl,
        p_end_date_tbl              => l_end_date_tbl,
        errbuf                      => errbuf,
        retcode                     => retcode);

      IF (retcode <> 0) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.update_denorm_table',
                         'update_denorm_table API has failed');

        RAISE	FND_API.G_EXC_ERROR;
      END IF;

      l_terr_id_tbl1.TRIM(l_rows_inserted1);
      l_related_terr_id_tbl.TRIM(l_rows_inserted1);
      l_top_level_terr_id_tbl.TRIM(l_rows_inserted1);
      l_num_winners_tbl.TRIM(l_rows_inserted1);
      l_level_from_root_tbl.TRIM(l_rows_inserted1);
      l_level_from_parent_tbl.TRIM(l_rows_inserted1);
      l_terr_rank_tbl.TRIM(l_rows_inserted1);
      l_immediate_parent_flag_tbl.TRIM(l_rows_inserted1);
      l_org_id_tbl.TRIM(l_rows_inserted1);
      l_start_date_tbl.TRIM(l_rows_inserted1);
      l_end_date_tbl.TRIM(l_rows_inserted1);

      l_rows_inserted1 := 0;
    END IF;

    /* disable the trigger before update */
   /* BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD DISABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;*/

    /* calculate the absolute rank */
    /*FORALL i IN l_terr_id_tbl2.FIRST .. l_terr_id_tbl2.LAST
      UPDATE  jtf_terr_all jta1
      SET     jta1.ABSOLUTE_RANK = (
                SELECT SUM(jta2.relative_rank)
                FROM   jtf_terr_all jta2
                WHERE  jta2.terr_id IN (
                         SELECT jt.terr_id
                         FROM jtf_terr_all jt
                         CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                         START WITH jt.terr_id = l_terr_id_tbl2(i))),
              jta1.last_update_date = g_sysdate
      WHERE jta1.terr_id = l_terr_id_tbl2(i);

    l_dyn_str :=
      'UPDATE ' || p_table_name || ' ' ||
      'SET   absolute_rank = ( ' ||
      '        SELECT absolute_rank ' ||
      '        FROM   jtf_terr_all  ' ||
      '        WHERE  terr_id = :1 ) ' ||
      'WHERE terr_id = :2 ';

    IF (p_mode = 'INCREMENTAL') THEN
      FORALL i IN l_terr_id_tbl2.FIRST .. l_terr_id_tbl2.LAST
        EXECUTE IMMEDIATE l_dyn_str USING l_terr_id_tbl2(i), l_terr_id_tbl2(i);
    END IF;

    l_terr_id_tbl2.TRIM(l_rows_inserted2);*/

    /* enable the trigger after update */
    /*BEGIN
      EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORIES_BIUD ENABLE';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;*/

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.rows_inserted',
                     'Finished inserting rows into denorm table and rank calculation');

  END IF; /* end IF (p_terr_change_tab.terr_id.COUNT > 0) */

  /* update the first_char column to improve performance of LIKE op */
  BEGIN

      OPEN c_get_qual_type_id(p_source_id);
      FETCH c_get_qual_type_id BULK COLLECT INTO l_qual_type_id_tbl;
      CLOSE c_get_qual_type_id;

      l_no_of_records := l_qual_type_id_tbl.COUNT;

      IF (l_no_of_records > 0) THEN

          BEGIN
              EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_VALUES_BIUD DISABLE';
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;

        FORALL i IN l_qual_type_id_tbl.FIRST .. l_qual_type_id_tbl.LAST
          UPDATE /*+ INDEX (o jtf_terr_values_n1) */ jtf_terr_values_all o
          SET o.first_char = SUBSTR(o.low_value_char, 1, 1)
          WHERE o.terr_qual_id IN (
               SELECT /*+ INDEX (i2 jtf_qual_usgs_n3) */
                    i1.terr_qual_id
               FROM jtf_terr_qual_all i1, jtf_qual_usgs_all i2, jtf_qual_type_usgs_all i3
               WHERE i1.qual_usg_id = i2.qual_usg_id
               AND i2.display_type = 'CHAR'
               AND i2.lov_sql IS NULL
               AND i2.org_id = -3113
               AND i2.qual_type_usg_id = i3.qual_type_usg_id
               AND i3.source_id = p_source_id
               AND i3.qual_type_id in (SELECT related_id
                                       FROM jtf_qual_type_denorm_v
                                       WHERE qual_type_id = l_qual_type_id_tbl(i)));

        l_qual_type_id_tbl.TRIM(l_no_of_records);

           BEGIN
              EXECUTE IMMEDIATE 'ALTER TRIGGER JTF_TERRITORY_VALUES_BIUD ENABLE';
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END;

      END IF; /* end IF (l_no_of_records > 0) */

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.process_terr_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.g_exc_error',
                     'API JTY_TERR_DENORM_RULES_PVT.process_terr_rank has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_terr_rank.others',
                     substr(errbuf, 1, 4000));

END process_terr_rank;

/* drop indexes of the denorm value table */
PROCEDURE DROP_DNMVAL_TABLE_INDEXES( p_table_name     IN          VARCHAR2
                                    ,p_mode           IN          VARCHAR2
                                    ,x_return_status  OUT NOCOPY  VARCHAR2 ) IS

  v_statement      varchar2(800);

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  Cursor getIndexList(cl_table_name IN VARCHAR2, cl_owner IN VARCHAR2) IS
  SELECT aidx.owner, aidx.INDEX_NAME
  FROM   DBA_INDEXES aidx
  WHERE  aidx.table_name  = cl_table_name
  AND    aidx.table_owner = cl_owner
  AND    aidx.index_name  like 'JTY_DNM_ATTR_VAL%';

  Cursor getDeaIndexList(cl_table_name IN VARCHAR2, cl_owner IN VARCHAR2) IS
  SELECT aidx.owner, aidx.INDEX_NAME
  FROM   DBA_INDEXES aidx
  WHERE  aidx.table_name  = cl_table_name
  AND    aidx.table_owner = cl_owner
  AND    aidx.index_name  like 'JTY_DEA_ATTR_VAL%';

  L_SCHEMA_NOTFOUND  EXCEPTION;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes.begin',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  -- for each index
  IF (p_mode = 'TOTAL') THEN
    FOR idx IN getIndexList(p_table_name, l_jtf_schema) LOOP
      v_statement := 'DROP INDEX ' || idx.owner || '.' || idx.index_name;

      BEGIN
        EXECUTE IMMEDIATE v_statement;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    END LOOP;
  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    FOR idx IN getDeaIndexList(p_table_name, l_jtf_schema) LOOP
      v_statement := 'DROP INDEX ' || idx.owner || '.' || idx.index_name;

      BEGIN
        EXECUTE IMMEDIATE v_statement;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    END LOOP;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.drop_dnmval_table_indexes.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END DROP_DNMVAL_TABLE_INDEXES;

/* entry point of this package */
PROCEDURE process_attr_and_rank (
  p_source_id        IN NUMBER,
  p_mode             IN VARCHAR2,
  p_terr_change_tab  IN JTY_TERR_ENGINE_GEN_PVT.terr_change_type,
  errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2 )
IS

  l_table_name     VARCHAR2(30);
  l_table_owner    VARCHAR2(30) := 'jtf' ;
  x_return_status  VARCHAR2(250);
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.start',
                   'Start of the procedure JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

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

  /* delete the old records from denormalized tables */
  IF (p_mode = 'TOTAL') THEN
    DELETE jtf_terr_denorm_rules_all
    WHERE  source_id = p_source_id;

    /* drop index on denorm value table */
    drop_dnmval_table_indexes (
      p_table_name      => l_table_name
     ,p_mode            => p_mode
     ,x_return_status   => x_return_status);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      retcode := 2;
      errbuf := 'drop_dnmval_table_indexes API has failed';
      -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.drop_dnmval_table_indexes',
                           'drop_dnmval_table_indexes API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    DELETE jty_terr_values_idx_details dtl
    WHERE  EXISTS (
      SELECT 1
      FROM   jty_terr_values_idx_header hdr
      WHERE  dtl.terr_values_idx_header_id = hdr.terr_values_idx_header_id
      AND    hdr.source_id = p_source_id );

    DELETE jty_terr_values_idx_header hdr
    WHERE  hdr.source_id = p_source_id;

    EXECUTE IMMEDIATE 'truncate table '||l_table_owner || '.' || l_table_name ;
  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    DELETE jty_denorm_dea_rules_all
    WHERE  source_id = p_source_id;

    /* drop index on denorm value table */
    drop_dnmval_table_indexes (
      p_table_name      => l_table_name
     ,p_mode            => p_mode
     ,x_return_status   => x_return_status);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      retcode := 2;
      errbuf := 'drop_dnmval_table_indexes API has failed';
      -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.drop_dnmval_table_indexes',
                           'drop_dnmval_table_indexes API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    DELETE jty_dea_values_idx_details dtl
    WHERE  EXISTS (
      SELECT 1
      FROM   jty_dea_values_idx_header hdr
      WHERE  dtl.dea_values_idx_header_id = hdr.dea_values_idx_header_id
      AND    hdr.source_id = p_source_id );

    DELETE jty_dea_values_idx_header hdr
    WHERE  hdr.source_id = p_source_id;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_table_owner || '.' || l_table_name;
  ELSIF (p_mode = 'INCREMENTAL') THEN
    EXECUTE IMMEDIATE 'delete ' || l_table_name || ' where source_id = :1 and (start_date > :2 or end_date < :3) ' USING p_source_id, g_sysdate, g_sysdate;

    DELETE jtf_terr_denorm_rules_all
    WHERE  source_id = p_source_id
    AND   (start_date > g_sysdate
    OR     end_date < g_sysdate);

    /* mark all the records to be deleted */
    /* delete_flag will be updated to 'N' for qualifiers that are used by active territories while generating real time matching sql */
    /* delete_flag will be updated to 'N' for qualifier combinations used by active territories after updating jtf_tae_qual_products */
    UPDATE jty_terr_values_idx_header
    SET    delete_flag = 'Y'
    WHERE  source_id = p_source_id;
  END IF;

  /* Denormalize the territory hierarchy and calculate rank */
  process_terr_rank (
     p_source_id       => p_source_id
    ,p_mode            => p_mode
    ,p_terr_change_tab => p_terr_change_tab
    ,p_table_name      => l_table_name
    ,errbuf            => errbuf
    ,retcode           => retcode);

  IF (retcode <> 0) THEN
    -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.process_terr_rank',
                         'process_terr_rank API has failed');

    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.process_terr_rank',
                   'API process_terr_rank completed successfully');

  /* Denormalize the qualifier values and calculate num_qual and qual_relation_product */
  process_attr_values (
     p_source_id       => p_source_id
    ,p_mode            => p_mode
    ,p_table_name      => l_table_name
    ,p_terr_change_tab => p_terr_change_tab
    ,errbuf            => errbuf
    ,retcode           => retcode);

  IF (retcode <> 0) THEN
    -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.process_attr_values',
                         'process_attr_values API has failed');

    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.process_attr_values',
                   'API process_attr_values completed successfully');

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.end',
                   'End of the procedure JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.g_exc_error',
                     'API JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_DENORM_RULES_PVT.process_attr_and_rank.others',
                     substr(errbuf, 1, 4000));

END process_attr_and_rank;

END JTY_TERR_DENORM_RULES_PVT;

/
