--------------------------------------------------------
--  DDL for Package Body JTY_TAE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TAE_CONTROL_PVT" AS
/* $Header: jtfyaecb.pls 120.4.12010000.4 2008/12/23 10:47:47 ppillai ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TAE_CONTROL_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      Classify territories before mass assignment
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for public use
--
--    HISTORY
--      07/10/2005  ACHANDA Created.
--

  G_USER_ID         NUMBER       := FND_GLOBAL.USER_ID();
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

PROCEDURE delete_combinations
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_mode                   IN  VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 )
IS

  TYPE l_qual_prd_id_tbl_type IS TABLE OF jtf_tae_qual_products.qual_product_id%TYPE;
  TYPE l_rel_prd_tbl_type IS TABLE OF jtf_tae_qual_products.relation_product%TYPE;

  l_qual_prd_id_tbl  l_qual_prd_id_tbl_type;
  l_rel_prd_tbl      l_rel_prd_tbl_type;
BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.delete_combinations.begin',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.delete_combinations ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_mode = 'TOTAL') THEN
    BEGIN

      DELETE FROM jtf_tae_qual_prod_factors
      WHERE qual_product_id IN
                    ( SELECT qual_product_id
                      FROM   jtf_tae_qual_products
                      WHERE  source_id = p_source_id
                      AND    trans_object_type_id = p_trans_id);

      DELETE FROM jtf_tae_qual_products
      WHERE source_id = p_source_id
      AND trans_object_type_id = p_trans_id;

      DELETE FROM jtf_tae_qual_factors o
      WHERE NOT EXISTS
                    ( SELECT NULL
                      FROM jtf_tae_qual_products i
                      WHERE MOD(i.relation_product, o.relation_factor) = 0 );

      DELETE FROM jty_tae_attr_products_sql
      WHERE  source_id = p_source_id
      AND    trans_type_id = p_trans_id
      AND    keep_flag <> 'Y';

    EXCEPTION
      WHEN OTHERS THEN
	    x_msg_data := SQLCODE || ' : ' || SQLERRM;
        RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    BEGIN

      DELETE FROM jty_dea_attr_prod_factors
      WHERE dea_attr_products_id IN
                    ( SELECT dea_attr_products_id
                      FROM   jty_dea_attr_products
                      WHERE  source_id = p_source_id
                      AND    trans_type_id = p_trans_id);

      DELETE FROM jty_dea_attr_products
      WHERE source_id = p_source_id
      AND trans_type_id = p_trans_id;

      DELETE FROM jty_dea_attr_factors o
      WHERE NOT EXISTS
                    ( SELECT NULL
                      FROM jty_dea_attr_products i
                      WHERE MOD(i.attr_relation_product, o.relation_factor) = 0 );

      DELETE FROM jty_dea_attr_products_sql
      WHERE  source_id = p_source_id
      AND    trans_type_id = p_trans_id
      AND    keep_flag <> 'Y';

    EXCEPTION

      WHEN OTHERS THEN
	    x_msg_data := SQLCODE || ' : ' || SQLERRM;
        RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  ELSIF (p_mode = 'INCREMENTAL') THEN
    BEGIN

      DELETE FROM jtf_tae_qual_products
      WHERE source_id = p_source_id
      AND trans_object_type_id = p_trans_id
      AND relation_product not in (
            SELECT qual_relation_product
            FROM   jtf_terr_qtype_usgs_all a,
                   jtf_qual_type_usgs_all  b
            WHERE  a.qual_type_usg_id = b.qual_type_usg_id
            AND    b.source_id = p_source_id
            AND    b.qual_type_id = p_trans_id)
      RETURNING qual_product_id, relation_product BULK COLLECT INTO l_qual_prd_id_tbl, l_rel_prd_tbl;

      IF (l_qual_prd_id_tbl.COUNT > 0) THEN
        FORALL i IN l_qual_prd_id_tbl.FIRST .. l_qual_prd_id_tbl.LAST
          DELETE FROM jtf_tae_qual_prod_factors
          WHERE qual_product_id = l_qual_prd_id_tbl(i);
      END IF;

      DELETE FROM jtf_tae_qual_factors o
      WHERE NOT EXISTS
                    ( SELECT NULL
                      FROM jtf_tae_qual_products i
                      WHERE MOD(i.relation_product, o.relation_factor) = 0 );

      IF (l_rel_prd_tbl.COUNT > 0) THEN
        FORALL i IN l_rel_prd_tbl.FIRST .. l_rel_prd_tbl.LAST
          DELETE FROM jty_tae_attr_products_sql
          WHERE  source_id = p_source_id
          AND    trans_type_id = p_trans_id
          AND    attr_relation_product = l_rel_prd_tbl(i)
          AND    keep_flag <> 'Y';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
	    x_msg_data := SQLCODE || ' : ' || SQLERRM;
        RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF; /* end IF (p_mode = 'TOTAL') */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.delete_combinations.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.delete_combinations ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_tae_cpntrol_pvt.delete_combinations.g_exc_unexpected_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.delete_combinations.other',
                     substr(x_msg_data, 1, 4000));

END delete_combinations;

PROCEDURE Classify_Territories
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_mode                   IN  VARCHAR2,
  p_qual_prd_tbl           IN  JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 )
IS

  l_terr_analyze_id         number;
  l_qual_factor_id          number;
  l_qual_product_id         number;
  l_qual_prod_factor_id     number;
  l_counter                 number;
  l_exist_qual_detail_count number;
  l_qual_type_usg_id        number;

  l_no_of_records NUMBER;
  l_header_seq    NUMBER;
  l_index_name    varchar2(30);

  cursor quals_used(cl_qual_relation_product number) is
  select qual_usg_id
  from jtf_qual_usgs_all jqua
  where mod(cl_qual_relation_product, jqua.qual_relation_factor) = 0
  and org_id = -3113;

  cursor qual_details(cl_qual_usg_id number) is
  select * from jtf_qual_usgs_all
  where qual_usg_id = cl_qual_usg_id
  and org_id = -3113;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.begin',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.classify_territories ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in table jtf_qual_type_usgs_all corresponding to source : ' || p_source_id || ' and transaction : ' ||
                     p_trans_id;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.no_qual_type_usg_id',
                       x_msg_data);
      RAISE;
  END;

  BEGIN
    SELECT max(to_number(substr(index_name, instr(index_name, '_N') +2)))
    INTO   l_counter
    FROM   jtf_tae_qual_products
    WHERE  source_id = p_source_id
    AND    trans_object_type_id = p_trans_id;

    IF (l_counter IS NULL) THEN
      l_counter := 0;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_counter := 0;
    WHEN OTHERS THEN
      RAISE;
  END;

  /* Create Combinations in Product and Factor Tables */
  SELECT JTF_TAE_ANALYZE_TERR_S.NEXTVAL
  INTO l_terr_analyze_id
  FROM dual;

  IF (p_qual_prd_tbl.COUNT > 0) THEN
    FOR i IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST LOOP
      l_counter := l_counter + 1;

      SELECT JTF_TAE_QUAL_PRODUCTS_S.NEXTVAL
      INTO   l_qual_product_id
      FROM   dual;

      -- POPULATE PRODUCTS
      IF ((p_qual_prd_tbl(i) <> 1) AND (p_qual_prd_tbl(i) IS NOT NULL)) THEN

        BEGIN

          INSERT INTO JTF_TAE_QUAL_products
          (   QUAL_PRODUCT_ID,
              RELATION_PRODUCT,
              SOURCE_ID,
              TRANS_OBJECT_TYPE_ID,
              INDEX_NAME,
              FIRST_CHAR_FLAG,
              BUILD_INDEX_FLAG,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              TERR_ANALYZE_ID
          )
          VALUES
          (   l_qual_product_id,                    --QUAL_PRODUCT_ID,
              p_qual_prd_tbl(i),		            --RELATION_PRODUCT,
              p_source_id,                          --SOURCE_ID,
              p_trans_id,                           --TRANS_OBJECT_TYPE_ID,
              'JTF_TAE_TN' || TO_CHAR(ABS(l_qual_type_usg_id)) || '_N'|| TO_CHAR(l_counter),          --INDEX_NAME,
              'N',                                   --FIRST_CHAR,
              'Y',                                   --BUILD_INDEX_FLAG,
              sysdate,                               --LAST_UPDATE_DATE,
              1,                                     --LAST_UPDATED_BY,
              sysdate,                               --CREATION_DATE,
              1,                                     --CREATED_BY,
              1,                                     --LAST_UPDATE_LOGIN)
              l_terr_analyze_id                      --TERR_ANALYZE_ID,
          );

        EXCEPTION
          WHEN OTHERS THEN
            x_msg_data := SQLCODE || ' : ' || SQLERRM;
            RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        l_no_of_records := 0;

        SELECT count(*)
        INTO   l_no_of_records
        FROM   jty_terr_values_idx_header
        WHERE  source_id = p_source_id
        AND    relation_product = p_qual_prd_tbl(i);

        IF (l_no_of_records = 0) THEN

          SELECT jty_terr_values_idx_header_s.nextval
          INTO   l_header_seq
          FROM   dual;

          SELECT 'JTY_DNM_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_BN' ||
                                   (nvl(max(to_number(substr(index_name, instr(index_name, '_BN')+3))), 0) + 1)
          INTO   l_index_name
          FROM   jty_terr_values_idx_header
          WHERE  index_name like 'JTY_DNM_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_BN%';

          INSERT INTO jty_terr_values_idx_header (
             terr_values_idx_header_id
            ,source_id
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,relation_product
            ,index_name
            ,build_index_flag
            ,delete_flag )
          VALUES (
             l_header_seq
            ,p_source_id
            ,G_SYSDATE
            ,G_USER_ID
            ,G_SYSDATE
            ,G_USER_ID
            ,G_USER_ID
            ,p_qual_prd_tbl(i)
            ,l_index_name
            ,'Y'
            ,'N');

        END IF; /* end IF (l_no_of_records = 0) */

        FOR qual_name in quals_used(p_qual_prd_tbl(i)) LOOP

          FOR q_detail in qual_details(qual_name.qual_usg_id) LOOP

            SELECT count(*)
            INTO l_exist_qual_detail_count
            FROM JTF_TAE_QUAL_factors
            WHERE qual_usg_id = q_detail.qual_usg_id;

            IF l_exist_qual_detail_count = 0 THEN

              BEGIN

                SELECT JTF_TAE_QUAL_factors_s.NEXTVAL
                INTO l_qual_factor_id
                FROM dual;

                INSERT INTO JTF_TAE_QUAL_factors
                ( QUAL_FACTOR_ID,
                  RELATION_FACTOR,
                  QUAL_USG_ID,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_LOGIN,
                  TERR_ANALYZE_ID,
                  TAE_COL_MAP,
                  TAE_REC_MAP,
                  USE_TAE_COL_IN_INDEX_FLAG,
                  UPDATE_SELECTIVITY_FLAG,
                  INPUT_SELECTIVITY,
                  INPUT_ORDINAL_SELECTIVITY,
                  INPUT_DEVIATION,
                  ORG_ID,
                  OBJECT_VERSION_NUMBER
                )
                VALUES
                ( l_qual_factor_id,                   -- QUAL_FACTOR_ID
                  q_detail.qual_relation_factor,       -- RELATION_FACTOR
                  q_detail.qual_usg_id,               -- QUAL_USG_ID
                  0,                                  -- LAST_UPDATED_BY
                  sysdate,                            -- LAST_UPDATE_DATE
                  0,                                  -- CREATED_BY
                  sysdate,                            -- CREATION_DATE
                  0,                                  -- LAST_UPDATE_LOGIN
                  l_terr_analyze_id,                  -- TERR_ANALYZE_ID
                  q_detail.qual_col1,                 -- TAE_COL_MAP
                  q_detail.qual_col1_alias,           -- TAE_REC_MAP
                  'Y',                                -- USE_TAE_COL_IN_INDEX_FLAG
                  'Y',                                -- UPDATE_SELECTIVITY_FLAG
                  null,                               -- INPUT_SELECTIVITY
                  null,                               -- INPUT_ORDINAL_SELECTIVITY
                  null,                               -- INPUT_DEVIATION
                  null,                               -- ORG_ID
                  null                                -- OBJECT_VERSION_NUMBER
                );

                COMMIT;

              EXCEPTION
                WHEN OTHERS THEN
                  x_msg_data := SQLCODE || ' : ' || SQLERRM;
                  RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
              END;

            END IF; /* end IF l_exist_qual_detail_count = 0 */

            IF (l_no_of_records = 0) THEN
              IF (q_detail.comparison_operator IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.comparison_operator
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_char_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_char_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_char IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_char
                  ,null
                  ,null);
              END IF;

              IF (q_detail.high_value_char IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.high_value_char
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_number IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_number
                  ,null
                  ,null);
              END IF;

              IF (q_detail.high_value_number IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.high_value_number
                  ,null
                  ,null);
              END IF;

              IF (q_detail.interest_type_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.interest_type_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.primary_interest_code_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.primary_interest_code_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.secondary_interest_code_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.secondary_interest_code_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.currency_code IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.currency_code
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value1_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value1_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value2_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value2_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value3_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value3_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value4_id IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value4_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.first_char IS NOT NULL) THEN
                INSERT INTO jty_terr_values_idx_details (
                   terr_values_idx_details_id
                  ,terr_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_terr_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.first_char
                  ,null
                  ,null);
              END IF;
            END IF; /* end IF (l_no_of_records = 0) */

          END LOOP; /* end loop FOR q_detail in qual_details(qual_name.qual_usg_id) */
        END LOOP; /* end loop FOR qual_name in quals_used(rel_set.qual_relation_product) */

        FOR qual_name in quals_used(p_qual_prd_tbl(i)) LOOP

          BEGIN

            SELECT qual_factor_id
            INTO l_qual_factor_id
            FROM JTF_TAE_QUAL_factors
            WHERE qual_usg_id = qual_name.qual_usg_id
			AND rownum < 2;

            SELECT JTF_TAE_QUAL_PROD_FACTORS_S.NEXTVAL
            INTO l_qual_prod_factor_id
            FROM dual;

            INSERT INTO JTF_TAE_QUAL_prod_factors
            ( QUAL_PROD_FACTOR_ID,
              QUAL_PRODUCT_ID,
              QUAL_FACTOR_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              TERR_ANALYZE_ID,
              ORG_ID,
              OBJECT_VERSION_NUMBER
            )
            VALUES
            ( l_qual_prod_factor_id, --QUAL_PROD_FACTOR_ID,
              l_qual_product_id,   --QUAL_PRODUCT_ID,
              l_qual_factor_id,                   --QUAL_FACTOR_ID
              sysdate,                  		    --LAST_UPDATE_DATE,
              0,                           		--LAST_UPDATED_BY,
              sysdate,                            --CREATION_DATE,
              0,                                  --CREATED_BY,
              0,                                  --LAST_UPDATE_LOGIN,
              l_terr_analyze_id,                  --TERR_ANALYZE_ID,
              null,                               --ORG_ID,
              null                                --OBJECT_VERSION_NUMBER
            );

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              x_msg_data := 'Populating JTF_TAE_QUAL_PROD_FACTORS table : Error no_data_found.';
              RAISE	FND_API.G_EXC_ERROR;

            WHEN OTHERS THEN
              x_msg_data := SQLCODE || ' : ' || SQLERRM;
              RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

        END LOOP; /* end loop FOR qual_name in quals_used(rel_set.qual_relation_product) */
      END IF; /* end IF ((p_qual_prd_tbl(i) <> 1) AND (p_qual_prd_tbl(i) IS NOT NULL)) */
    END LOOP; /* end loop FOR i IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST */
  END IF; /* end IF (p_qual_prd_tbl.COUNT > 0) */

  /* no need to build the index for the qualifiers with no column mapped to TRANS table */
  update JTF_TAE_QUAL_factors
  set    UPDATE_SELECTIVITY_FLAG = 'N',
         USE_TAE_COL_IN_INDEX_FLAG = 'N'
  where  TAE_COL_MAP is null;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.classify_territories ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.no_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.g_exc_error',
                     x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_tae_cpntrol_pvt.classify_territories.g_exc_unexpected_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_territories.other',
                     substr(x_msg_data, 1, 4000));

END Classify_Territories;

PROCEDURE Classify_dea_Territories
( p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_qual_prd_tbl           IN  JTY_TERR_ENGINE_GEN_PVT.qual_prd_tbl_type,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 )
IS

  l_terr_analyze_id         number;
  l_qual_factor_id          number;
  l_qual_product_id         number;
  l_qual_prod_factor_id     number;
  l_counter                 number;
  l_exist_qual_detail_count number;
  l_qual_type_usg_id        number;

  l_no_of_records           NUMBER;
  l_header_seq              NUMBER;

  cursor quals_used(cl_qual_relation_product number) is
  select qual_usg_id
  from jtf_qual_usgs_all jqua
  where mod(cl_qual_relation_product, jqua.qual_relation_factor) = 0
  and org_id = -3113;

  cursor qual_details(cl_qual_usg_id number) is
  select * from jtf_qual_usgs_all
  where qual_usg_id = cl_qual_usg_id
  and org_id = -3113;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.begin',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.classify_dea_territories ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in table jtf_qual_type_usgs_all corresponding to source : ' || p_source_id || ' and transaction : ' ||
                     p_trans_id;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.no_qual_type_usg_id',
                       x_msg_data);

      RAISE;
  END;

  /* Create Combinations in Product and Factor Tables */
  SELECT JTF_TAE_ANALYZE_TERR_S.NEXTVAL
  INTO l_terr_analyze_id
  FROM dual;

  l_counter := 0;

  IF (p_qual_prd_tbl.COUNT > 0) THEN
    FOR i IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST LOOP
      l_counter := l_counter + 1;

      SELECT JTY_DEA_ATTR_PRODUCTS_S.NEXTVAL
      INTO   l_qual_product_id
      FROM   dual;

      -- POPULATE PRODUCTS
      IF ((p_qual_prd_tbl(i) <> 1) AND (p_qual_prd_tbl(i) IS NOT NULL)) THEN

        BEGIN

          INSERT INTO JTY_DEA_ATTR_PRODUCTS
          (   DEA_ATTR_PRODUCTS_ID,
              ATTR_RELATION_PRODUCT,
              SOURCE_ID,
              TRANS_TYPE_ID,
              INDEX_NAME,
              FIRST_CHAR_FLAG,
              BUILD_INDEX_FLAG,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              TERR_ANALYZE_ID
          )
          VALUES
          (   l_qual_product_id,                     --QUAL_PRODUCT_ID,
              p_qual_prd_tbl(i),		             --RELATION_PRODUCT,
              p_source_id,                           --SOURCE_ID,
              p_trans_id,                            --TRANS_OBJECT_TYPE_ID,
              'JTF_TAE_DE' || TO_CHAR(ABS(l_qual_type_usg_id)) || '_N'|| TO_CHAR(l_counter) || '_',          --INDEX_NAME,
              'N',                                   --FIRST_CHAR,
              'Y',                                   --BUILD_INDEX_FLAG,
              sysdate,                               --LAST_UPDATE_DATE,
              1,                                     --LAST_UPDATED_BY,
              sysdate,                               --CREATION_DATE,
              1,                                     --CREATED_BY,
              1,                                     --LAST_UPDATE_LOGIN)
              l_terr_analyze_id                      --TERR_ANALYZE_ID,
          );

        EXCEPTION
          WHEN OTHERS THEN
            x_msg_data := SQLCODE || ' : ' || SQLERRM;
            RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        l_no_of_records := 0;

        SELECT count(*)
        INTO   l_no_of_records
        FROM   jty_dea_values_idx_header
        WHERE  source_id = p_source_id
        AND    relation_product = p_qual_prd_tbl(i);

        IF (l_no_of_records = 0) THEN

          SELECT jty_dea_values_idx_header_s.nextval
          INTO   l_header_seq
          FROM   dual;

          INSERT INTO jty_dea_values_idx_header (
             dea_values_idx_header_id
            ,source_id
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,relation_product
            ,index_name
            ,build_index_flag )
          VALUES (
             l_header_seq
            ,p_source_id
            ,G_SYSDATE
            ,G_USER_ID
            ,G_SYSDATE
            ,G_USER_ID
            ,G_USER_ID
            ,p_qual_prd_tbl(i)
            ,'JTY_DEA_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_BN' || i
            ,'Y');

        END IF; /* end IF (l_no_of_records = 0) */

        FOR qual_name in quals_used(p_qual_prd_tbl(i)) LOOP

          FOR q_detail in qual_details(qual_name.qual_usg_id) LOOP

            SELECT count(*)
            INTO l_exist_qual_detail_count
            FROM jty_dea_attr_factors
            WHERE qual_usg_id = q_detail.qual_usg_id;

            IF l_exist_qual_detail_count = 0 THEN

              BEGIN

                SELECT JTY_DEA_ATTR_FACTORS_S.NEXTVAL
                INTO l_qual_factor_id
                FROM dual;

                INSERT INTO JTY_DEA_ATTR_FACTORS
                ( DEA_ATTR_FACTORS_ID,
                  RELATION_FACTOR,
                  QUAL_USG_ID,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_LOGIN,
                  TERR_ANALYZE_ID,
                  TAE_COL_MAP,
                  TAE_REC_MAP,
                  USE_TAE_COL_IN_INDEX_FLAG,
                  UPDATE_SELECTIVITY_FLAG,
                  INPUT_SELECTIVITY,
                  INPUT_ORDINAL_SELECTIVITY,
                  INPUT_DEVIATION,
                  OBJECT_VERSION_NUMBER
                )
                VALUES
                ( l_qual_factor_id,                   -- QUAL_FACTOR_ID
                  q_detail.qual_relation_factor,       -- RELATION_FACTOR
                  q_detail.qual_usg_id,               -- QUAL_USG_ID
                  0,                                  -- LAST_UPDATED_BY
                  sysdate,                            -- LAST_UPDATE_DATE
                  0,                                  -- CREATED_BY
                  sysdate,                            -- CREATION_DATE
                  0,                                  -- LAST_UPDATE_LOGIN
                  l_terr_analyze_id,                  -- TERR_ANALYZE_ID
                  q_detail.qual_col1,                 -- TAE_COL_MAP
                  q_detail.qual_col1_alias,           -- TAE_REC_MAP
                  'Y',                                -- USE_TAE_COL_IN_INDEX_FLAG
                  'Y',                                -- UPDATE_SELECTIVITY_FLAG
                  null,                               -- INPUT_SELECTIVITY
                  null,                               -- INPUT_ORDINAL_SELECTIVITY
                  null,                               -- INPUT_DEVIATION
                  null                                -- OBJECT_VERSION_NUMBER
                );

                COMMIT;

              EXCEPTION
                WHEN OTHERS THEN
                  x_msg_data := SQLCODE || ' : ' || SQLERRM;
                  RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
              END;

            END IF; /* end IF l_exist_qual_detail_count = 0 */

            IF (l_no_of_records = 0) THEN
              IF (q_detail.comparison_operator IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.comparison_operator
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_char_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_char_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_char IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_char
                  ,null
                  ,null);
              END IF;

              IF (q_detail.high_value_char IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.high_value_char
                  ,null
                  ,null);
              END IF;

              IF (q_detail.low_value_number IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.low_value_number
                  ,null
                  ,null);
              END IF;

              IF (q_detail.high_value_number IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.high_value_number
                  ,null
                  ,null);
              END IF;

              IF (q_detail.interest_type_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.interest_type_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.primary_interest_code_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.primary_interest_code_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.secondary_interest_code_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.secondary_interest_code_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.currency_code IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.currency_code
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value1_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value1_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value2_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value2_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value3_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value3_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.value4_id IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.value4_id
                  ,null
                  ,null);
              END IF;

              IF (q_detail.first_char IS NOT NULL) THEN
                INSERT INTO jty_dea_values_idx_details (
                   dea_values_idx_details_id
                  ,dea_values_idx_header_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,values_col_map
                  ,input_selectivity
                  ,input_ordinal_selectivity )
                VALUES (
                   jty_dea_values_idx_details_s.nextval
                  ,l_header_seq
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_SYSDATE
                  ,G_USER_ID
                  ,G_USER_ID
                  ,q_detail.first_char
                  ,null
                  ,null);
              END IF;
            END IF; /* end IF (l_no_of_records = 0) */

          END LOOP; /* end loop FOR q_detail in qual_details(qual_name.qual_usg_id) */
        END LOOP; /* end loop FOR qual_name in quals_used(rel_set.qual_relation_product) */

        FOR qual_name in quals_used(p_qual_prd_tbl(i)) LOOP

          BEGIN

            SELECT dea_attr_factors_id
            INTO l_qual_factor_id
            FROM jty_dea_attr_factors
            WHERE qual_usg_id = qual_name.qual_usg_id
			AND rownum < 2;

            SELECT JTY_DEA_ATTR_PROD_FACTORS_S.NEXTVAL
            INTO l_qual_prod_factor_id
            FROM dual;

            INSERT INTO JTY_DEA_ATTR_PROD_FACTORS
            ( DEA_ATTR_PROD_FACTORS_ID,
              DEA_ATTR_PRODUCTS_ID,
              DEA_ATTR_FACTORS_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              TERR_ANALYZE_ID,
              OBJECT_VERSION_NUMBER
            )
            VALUES
            ( l_qual_prod_factor_id, --QUAL_PROD_FACTOR_ID,
              l_qual_product_id,   --QUAL_PRODUCT_ID,
              l_qual_factor_id,                   --QUAL_FACTOR_ID
              sysdate,                  		    --LAST_UPDATE_DATE,
              0,                           		--LAST_UPDATED_BY,
              sysdate,                            --CREATION_DATE,
              0,                                  --CREATED_BY,
              0,                                  --LAST_UPDATE_LOGIN,
              l_terr_analyze_id,                  --TERR_ANALYZE_ID,
              null                                --OBJECT_VERSION_NUMBER
            );

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              x_msg_data := 'Populating JTY_DEA_ATTR_PROD_FACTORS table : Error no_data_found.';
              RAISE	FND_API.G_EXC_ERROR;

            WHEN OTHERS THEN
              x_msg_data := SQLCODE || ' : ' || SQLERRM;
              RAISE	FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

        END LOOP; /* end loop FOR qual_name in quals_used(rel_set.qual_relation_product) */
      END IF; /* end IF ((p_qual_prd_tbl(i) <> 1) AND (p_qual_prd_tbl(i) IS NOT NULL)) */
    END LOOP; /* end loop FOR i IN p_qual_prd_tbl.FIRST .. p_qual_prd_tbl.LAST */
  END IF; /* end IF (p_qual_prd_tbl.COUNT > 0) */

  /* no need to build the index for the qualifiers with no column mapped to TRANS table */
  update JTY_DEA_ATTR_FACTORS
  set    UPDATE_SELECTIVITY_FLAG = 'N',
         USE_TAE_COL_IN_INDEX_FLAG = 'N'
  where  TAE_COL_MAP is null;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.classify_dea_territories ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.no_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.g_exc_error',
                     x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_tae_cpntrol_pvt.classify_dea_territories.g_exc_unexpected_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.classify_dea_territories.other',
                     substr(x_msg_data, 1, 4000));

END Classify_dea_Territories;

PROCEDURE reduce_deaval_idx_set
( p_source_id              IN  NUMBER,
  x_Return_Status          OUT NOCOPY VARCHAR2)
IS

  S_element_ord_subset_L_count NUMBER;
  S_subset_L                   VARCHAR2(1);

  CURSOR all_sets(cl_source_id number) is
  SELECT A.dea_values_idx_header_id, count(*) num_components
  FROM   jty_dea_values_idx_header A,
         jty_dea_values_idx_details B
  WHERE  A.source_id = cl_source_id
  AND    A.dea_values_idx_header_id = B.dea_values_idx_header_id
  AND    B.values_col_map is not null
  GROUP BY A.dea_values_idx_header_id
  ORDER BY 2;

  CURSOR larger_or_eq_sets( cl_size IN NUMBER
                          , cl_source_id IN NUMBER
                          , cl_dea_values_idx_header_id IN NUMBER) is
  SELECT * FROM (
    SELECT  A.dea_values_idx_header_id, count(*) num_components
    FROM   jty_dea_values_idx_header A,
           jty_dea_values_idx_details B
    WHERE  A.source_id = cl_source_id
    AND    A.dea_values_idx_header_id <> cl_dea_values_idx_header_id
    AND    A.dea_values_idx_header_id = B.dea_values_idx_header_id
    AND    B.values_col_map is not null
    AND    A.build_index_flag = 'Y'
    GROUP BY A.dea_values_idx_header_id )
  WHERE num_components >= cl_size
  ORDER BY 2 DESC;


BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set.start',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status              := FND_API.G_RET_STS_SUCCESS;
  S_element_ord_subset_L_count := 0;
  S_subset_L                   := 'N';

  FOR cl_set_S in all_sets( p_source_id )  LOOP
    S_subset_L := 'N';

    FOR cl_set_L IN larger_or_eq_sets( cl_set_S.num_components
                                     , p_source_id
                                     , cl_set_s.dea_values_idx_header_id) LOOP

      SELECT COUNT(*)
      INTO S_element_ord_subset_L_count
      FROM (
             SELECT rownum row_count, values_col_map, input_selectivity
             FROM (
               SELECT B.values_col_map, B.input_selectivity
               FROM   jty_dea_values_idx_details B
               WHERE  B.dea_values_idx_header_id = cl_set_S.dea_values_idx_header_id
               AND    B.values_col_map IS NOT NULL
               ORDER BY B.input_selectivity )) S,
           (
             SELECT rownum row_count, values_col_map, input_selectivity
             FROM (
               SELECT B.values_col_map, B.input_selectivity
               FROM   jty_dea_values_idx_details B
               WHERE  B.dea_values_idx_header_id = cl_set_L.dea_values_idx_header_id
               AND    B.values_col_map IS NOT NULL
               ORDER BY B.input_selectivity )) L
      WHERE S.values_col_map = L.values_col_map
      AND  S.row_count = L.row_count;

      IF S_element_ord_subset_L_count = cl_set_S.num_components THEN
        S_subset_L := 'Y';
        exit;
      ELSE
        S_subset_L := 'N';
      END IF;

    END LOOP; /* end loop FOR cl_set_L IN larger_or_eq_sets */

    IF S_subset_L = 'Y' THEN
      UPDATE  jty_dea_values_idx_header
      SET     BUILD_INDEX_FLAG = 'N'
      WHERE   dea_values_idx_header_id = cl_set_S.dea_values_idx_header_id;

    END IF;

  END LOOP; /* end loop FOR cl_set_S in all_sets */

  COMMIT;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_deaval_idx_set.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

end reduce_deaval_idx_set;

PROCEDURE reduce_dnmval_idx_set
( p_source_id              IN  NUMBER,
  p_mode                   IN  VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2)
IS

  S_element_ord_subset_L_count NUMBER;
  S_subset_L                   VARCHAR2(1);

  CURSOR all_sets(cl_source_id number) is
  SELECT A.terr_values_idx_header_id, count(*) num_components
  FROM   jty_terr_values_idx_header A,
         jty_terr_values_idx_details B
  WHERE  A.source_id = cl_source_id
  AND    A.build_index_flag = 'Y'
  AND    A.terr_values_idx_header_id = B.terr_values_idx_header_id
  AND    B.values_col_map is not null
  GROUP BY A.terr_values_idx_header_id
  ORDER BY 2;

  CURSOR larger_or_eq_sets( cl_size IN NUMBER
                          , cl_source_id IN NUMBER
                          , cl_terr_values_idx_header_id IN NUMBER) is
  SELECT * FROM (
    SELECT  A.terr_values_idx_header_id, count(*) num_components
    FROM   jty_terr_values_idx_header A,
           jty_terr_values_idx_details B
    WHERE  A.source_id = cl_source_id
    AND    A.terr_values_idx_header_id <> cl_terr_values_idx_header_id
    AND    A.terr_values_idx_header_id = B.terr_values_idx_header_id
    AND    B.values_col_map is not null
    AND    A.build_index_flag = 'Y'
    GROUP BY A.terr_values_idx_header_id )
  WHERE num_components >= cl_size
  ORDER BY 2 DESC;


BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set.start',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status              := FND_API.G_RET_STS_SUCCESS;
  S_element_ord_subset_L_count := 0;
  S_subset_L                   := 'N';

  /* mark the indexes as obsolete for qualifers and qualifier combinations */
  /* that have beeen marked deleted in incremental mode                    */
  IF (p_mode = 'INCREMENTAL') THEN
    UPDATE jty_terr_values_idx_header
    SET    build_index_flag = 'N'
    WHERE  source_id = p_source_id
    AND    delete_flag = 'Y';
  END IF;

  FOR cl_set_S in all_sets( p_source_id )  LOOP
    S_subset_L := 'N';

    FOR cl_set_L IN larger_or_eq_sets( cl_set_S.num_components
                                     , p_source_id
                                     , cl_set_s.terr_values_idx_header_id) LOOP

      SELECT COUNT(*)
      INTO S_element_ord_subset_L_count
      FROM (
             SELECT rownum row_count, values_col_map, input_selectivity
             FROM (
               SELECT B.values_col_map, B.input_selectivity
               FROM   jty_terr_values_idx_details B
               WHERE  B.terr_values_idx_header_id = cl_set_S.terr_values_idx_header_id
               AND    B.values_col_map IS NOT NULL
               ORDER BY B.input_selectivity )) S,
           (
             SELECT rownum row_count, values_col_map, input_selectivity
             FROM (
               SELECT B.values_col_map, B.input_selectivity
               FROM   jty_terr_values_idx_details B
               WHERE  B.terr_values_idx_header_id = cl_set_L.terr_values_idx_header_id
               AND    B.values_col_map IS NOT NULL
               ORDER BY B.input_selectivity )) L
      WHERE S.values_col_map = L.values_col_map
      AND  S.row_count = L.row_count;

      IF S_element_ord_subset_L_count = cl_set_S.num_components THEN
        S_subset_L := 'Y';
        exit;
      ELSE
        S_subset_L := 'N';
      END IF;

    END LOOP; /* end loop FOR cl_set_L IN larger_or_eq_sets */

    IF S_subset_L = 'Y' THEN
      UPDATE  jty_terr_values_idx_header
      SET     BUILD_INDEX_FLAG = 'N'
      WHERE   terr_values_idx_header_id = cl_set_S.terr_values_idx_header_id;

    END IF;

  END LOOP; /* end loop FOR cl_set_S in all_sets */

  COMMIT;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.reduce_dnmval_idx_set.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

end reduce_dnmval_idx_set;


PROCEDURE Reduce_TX_OIN_Index_Set
( p_Api_Version_Number     IN  NUMBER,
  p_Init_Msg_List          IN  VARCHAR2,
  p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2)
IS

  l_first_char_flag            VARCHAR2(1);
  S_element_ord_subset_L_count NUMBER;
  S_subset_L                   VARCHAR2(1);
  l_first_char_flag_count      NUMBER;

  CURSOR all_sets(cl_source_id number, cl_trans_id number) is
  SELECT p.trans_object_type_id, count(*) num_components, p.qual_product_id qual_product_id, p.relation_product
  FROM JTF_TAE_QUAL_products p,
       JTF_TAE_QUAL_prod_factors pf,
       JTF_TAE_QUAL_factors f
  WHERE p.qual_product_id = pf.qual_product_id
  AND pf.qual_factor_id = f.qual_factor_id
  AND f.tae_col_map is not null
  AND p.source_id = cl_source_id
  AND p.trans_object_type_id = cl_trans_id
  GROUP BY p.trans_object_type_id, p.qual_product_id, p.relation_product
  ORDER BY p.relation_product;

  CURSOR larger_or_eq_sets( cl_size NUMBER
						  , cl_relation_product NUMBER
                          , cl_source_id NUMBER
                          , cl_trans_id NUMBER ) is
  SELECT * FROM (
    SELECT count(*) num_components, p.qual_product_id qual_product_id, p.relation_product
    FROM JTF_TAE_QUAL_products p,
         JTF_TAE_QUAL_prod_factors pf
    WHERE p.qual_product_id = pf.qual_product_id
    AND p.source_id = cl_source_id
    AND p.trans_object_type_id = cl_trans_id
    GROUP BY p.qual_product_id, p.relation_product )
  WHERE num_components >= cl_size
  AND relation_product > cl_relation_product
  ORDER BY 1 DESC, qual_product_id ASC;

  CURSOR all_empty_column_indexes(cl_source_id number, cl_trans_id number) is
  SELECT p.trans_object_type_id, p.qual_product_id, p.relation_product
  FROM JTF_TAE_QUAL_products p
  WHERE NOT EXISTS (SELECT *
                    FROM JTF_TAE_QUAL_products ip,
                         JTF_TAE_QUAL_prod_factors ipf,
                         JTF_TAE_QUAL_factors ifc
                    WHERE use_tae_col_in_index_flag = 'Y'
                    AND ip.qual_product_id = ipf.qual_product_id
                    AND ipf.qual_factor_id = ifc.qual_factor_id
                    AND ip.qual_product_id = p.qual_product_id)
  AND p.source_id = cl_source_id
  AND p.trans_object_type_id = cl_trans_id;


BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set.start',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_first_char_flag            := 'N';
  S_element_ord_subset_L_count := 0;
  S_subset_L                   := 'N';

  FOR cl_set_S in all_sets( p_source_id
                          , p_trans_id )  LOOP
    S_subset_L := 'N';

    FOR cl_set_L IN larger_or_eq_sets( cl_set_S.num_components
									 , cl_set_S.relation_product
                                     , p_source_id
                                     , p_trans_id ) LOOP

      SELECT COUNT(*)
      INTO S_element_ord_subset_L_count
      FROM (
             SELECT rownum row_count, tae_col_map, input_selectivity
             FROM (
               SELECT DISTINCT p.relation_product, f.tae_col_map, f.input_selectivity
               FROM JTF_TAE_QUAL_products p,
                    JTF_TAE_QUAL_prod_factors pf,
                    JTF_TAE_QUAL_factors f
               WHERE f.qual_factor_id = pf.qual_factor_id
               AND pf.qual_product_id = p.qual_product_id
               AND p.relation_product = cl_set_S.relation_product
               AND f.tae_col_map is not null
               AND p.source_id = p_source_id
               AND p.trans_object_type_id = p_trans_id
               ORDER BY input_selectivity )) S,
           (
             SELECT rownum row_count, tae_col_map, input_selectivity
             FROM (
               SELECT DISTINCT p.relation_product, f.tae_col_map, f.input_selectivity
               FROM JTF_TAE_QUAL_products p,
                    JTF_TAE_QUAL_prod_factors pf,
                    JTF_TAE_QUAL_factors f
               WHERE f.qual_factor_id = pf.qual_factor_id
               AND pf.qual_product_id = p.qual_product_id
               AND p.relation_product = cl_set_L.relation_product
               AND f.tae_col_map is not null
               AND p.source_id = p_source_id
               AND p.trans_object_type_id = p_trans_id
               ORDER BY input_selectivity)) L
      WHERE S.tae_col_map = L.tae_col_map
      AND  S.row_count = L.row_count;

      IF S_element_ord_subset_L_count = cl_set_S.num_components THEN
        S_subset_L := 'Y';
        exit;
      ELSE
        S_subset_L := 'N';
      END IF;

    END LOOP; /* end loop FOR cl_set_L IN larger_or_eq_sets */

    -- set FIRST_CHAR_FLAG for created index
    SELECT count(*)
    INTO l_first_char_flag_count
    FROM (
           SELECT qual_usg_id, tae_col_map, rownum row_count
           FROM (
                  SELECT f.qual_usg_id, f.relation_factor, f.tae_col_map
                  FROM JTF_TAE_QUAL_prod_factors pf,
                       JTF_TAE_QUAL_factors f
                  WHERE pf.qual_factor_id = f.qual_factor_id
                  AND pf.qual_product_id = cl_set_S.qual_product_id
                  ORDER BY f.input_selectivity)) ilv1,
         (
           SELECT qual_usg_id, 1 row_count
           FROM jtf_qual_usgs_all
           WHERE org_id = -3113
           AND seeded_qual_id = -1012) ilv2
    WHERE ilv1.qual_usg_id = ilv2.qual_usg_id
    AND ilv1.row_count = ilv2.row_count;

    IF l_first_char_flag_count >  0 THEN
      l_first_char_flag := 'Y';
    ELSE
      l_first_char_flag := 'N';
    END IF;

    IF S_subset_L = 'Y' THEN
      UPDATE  JTF_TAE_QUAL_PRODUCTS
      SET     BUILD_INDEX_FLAG = 'N', FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   qual_product_id = cl_set_S.qual_product_id
      AND RELATION_PRODUCT NOT IN (4841, 324347);

      UPDATE   JTF_TAE_QUAL_PRODUCTS
      SET   FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   qual_product_id = cl_set_S.qual_product_id
      AND   RELATION_PRODUCT IN (4841, 324347);
    ELSE
      UPDATE  JTF_TAE_QUAL_PRODUCTS
      SET     BUILD_INDEX_FLAG = 'Y', FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   qual_product_id = cl_set_S.qual_product_id;
    END IF;

	UPDATE   JTF_TAE_QUAL_PRODUCTS
    SET   FIRST_CHAR_FLAG = 'Y'
    WHERE   qual_product_id = cl_set_S.qual_product_id
	AND   RELATION_PRODUCT = 353393;

  END LOOP; /* end loop FOR cl_set_S in all_sets */

  -- Set reduction complete
  -- Set build_index_flag = 'N' for all empty column indexes combinations
  FOR empty_column_index in all_empty_column_indexes(p_source_id, p_trans_id) LOOP
    UPDATE JTF_TAE_QUAL_PRODUCTS p
    SET BUILD_INDEX_FLAG = 'N'
    WHERE p.qual_product_id = empty_column_index.qual_product_id;
  END LOOP;

  COMMIT;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set.other',
                     substr(x_msg_data, 1, 4000));

end Reduce_TX_OIN_Index_Set;

PROCEDURE dea_Reduce_TX_OIN_Index_Set
( p_Api_Version_Number     IN  NUMBER,
  p_Init_Msg_List          IN  VARCHAR2,
  p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2)
IS

  l_first_char_flag            VARCHAR2(1);
  S_element_ord_subset_L_count NUMBER;
  S_subset_L                   VARCHAR2(1);
  l_first_char_flag_count      NUMBER;

  CURSOR all_sets(cl_source_id number, cl_trans_id number) is
  SELECT p.trans_type_id, count(*) num_components, p.dea_attr_products_id dea_attr_products_id, p.attr_relation_product
  FROM jty_dea_attr_products p,
       jty_dea_attr_prod_factors pf,
       jty_dea_attr_factors f
  WHERE p.dea_attr_products_id = pf.dea_attr_products_id
  AND pf.dea_attr_factors_id = f.dea_attr_factors_id
  AND f.tae_col_map is not null
  AND p.source_id = cl_source_id
  AND p.trans_type_id = cl_trans_id
  GROUP BY p.trans_type_id, p.dea_attr_products_id, p.attr_relation_product
  ORDER BY p.attr_relation_product;

  CURSOR larger_or_eq_sets( cl_size NUMBER
						  , cl_relation_product NUMBER
                          , cl_source_id NUMBER
                          , cl_trans_id NUMBER ) is
  SELECT * FROM (
    SELECT count(*) num_components, p.dea_attr_products_id dea_attr_products_id, p.attr_relation_product
    FROM jty_dea_attr_products p,
         jty_dea_attr_prod_factors pf
    WHERE p.dea_attr_products_id = pf.dea_attr_products_id
    AND p.source_id = cl_source_id
    AND p.trans_type_id = cl_trans_id
    GROUP BY p.dea_attr_products_id, p.attr_relation_product )
  WHERE num_components >= cl_size
  AND attr_relation_product > cl_relation_product
  ORDER BY 1 DESC, dea_attr_products_id ASC;

  CURSOR all_empty_column_indexes(cl_source_id number, cl_trans_id number) is
  SELECT p.trans_type_id, p.dea_attr_products_id, p.attr_relation_product
  FROM jty_dea_attr_products p
  WHERE NOT EXISTS (SELECT *
                    FROM jty_dea_attr_products ip,
                         jty_dea_attr_prod_factors ipf,
                         jty_dea_attr_factors ifc
                    WHERE use_tae_col_in_index_flag = 'Y'
                    AND ip.dea_attr_products_id = ipf.dea_attr_products_id
                    AND ipf.dea_attr_factors_id = ifc.dea_attr_factors_id
                    AND ip.dea_attr_products_id = p.dea_attr_products_id)
  AND p.source_id = cl_source_id
  AND p.trans_type_id = cl_trans_id;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set.start',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status              := FND_API.G_RET_STS_SUCCESS;
  l_first_char_flag            := 'N';
  S_element_ord_subset_L_count := 0;
  S_subset_L                   := 'N';

  FOR cl_set_S in all_sets( p_source_id
                          , p_trans_id )  LOOP
    S_subset_L := 'N';

    FOR cl_set_L IN larger_or_eq_sets( cl_set_S.num_components
									 , cl_set_S.attr_relation_product
                                     , p_source_id
                                     , p_trans_id ) LOOP

      SELECT COUNT(*)
      INTO S_element_ord_subset_L_count
      FROM (
             SELECT rownum row_count, tae_col_map, input_selectivity
             FROM (
               SELECT DISTINCT p.attr_relation_product, f.tae_col_map, f.input_selectivity
               FROM jty_dea_attr_products p,
                    jty_dea_attr_prod_factors pf,
                    jty_dea_attr_factors f
               WHERE f.dea_attr_factors_id = pf.dea_attr_factors_id
               AND pf.dea_attr_products_id = p.dea_attr_products_id
               AND p.attr_relation_product = cl_set_S.attr_relation_product
               AND f.tae_col_map is not null
               AND p.source_id = p_source_id
               AND p.trans_type_id = p_trans_id
               ORDER BY input_selectivity )) S,
           (
             SELECT rownum row_count, tae_col_map, input_selectivity
             FROM (
               SELECT DISTINCT p.attr_relation_product, f.tae_col_map, f.input_selectivity
               FROM jty_dea_attr_products p,
                    jty_dea_attr_prod_factors pf,
                    jty_dea_attr_factors f
               WHERE f.dea_attr_factors_id = pf.dea_attr_factors_id
               AND pf.dea_attr_products_id = p.dea_attr_products_id
               AND p.attr_relation_product = cl_set_L.attr_relation_product
               AND f.tae_col_map is not null
               AND p.source_id = p_source_id
               AND p.trans_type_id = p_trans_id
               ORDER BY input_selectivity)) L
      WHERE S.tae_col_map = L.tae_col_map
      AND  S.row_count = L.row_count;

      IF S_element_ord_subset_L_count = cl_set_S.num_components THEN
        S_subset_L := 'Y';
        exit;
      ELSE
        S_subset_L := 'N';
      END IF;

    END LOOP; /* end loop FOR cl_set_L IN larger_or_eq_sets */

    -- set FIRST_CHAR_FLAG for created index
    SELECT count(*)
    INTO l_first_char_flag_count
    FROM (
           SELECT qual_usg_id, tae_col_map, rownum row_count
           FROM (
                  SELECT f.qual_usg_id, f.relation_factor, f.tae_col_map
                  FROM jty_dea_attr_prod_factors pf,
                       jty_dea_attr_factors f
                  WHERE pf.dea_attr_factors_id = f.dea_attr_factors_id
                  AND pf.dea_attr_products_id = cl_set_S.dea_attr_products_id
                  ORDER BY f.input_selectivity)) ilv1,
         (
           SELECT qual_usg_id, 1 row_count
           FROM jtf_qual_usgs_all
           WHERE org_id = -3113
           AND seeded_qual_id = -1012) ilv2
    WHERE ilv1.qual_usg_id = ilv2.qual_usg_id
    AND ilv1.row_count = ilv2.row_count;

    IF l_first_char_flag_count >  0 THEN
      l_first_char_flag := 'Y';
    ELSE
      l_first_char_flag := 'N';
    END IF;

    IF S_subset_L = 'Y' THEN
      UPDATE  JTY_DEA_ATTR_PRODUCTS
      SET     BUILD_INDEX_FLAG = 'N', FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   dea_attr_products_id = cl_set_S.dea_attr_products_id
      AND attr_relation_product NOT IN (4841, 324347);

      UPDATE   JTY_DEA_ATTR_PRODUCTS
      SET   FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   dea_attr_products_id = cl_set_S.dea_attr_products_id
      AND   attr_relation_product IN (4841, 324347);
    ELSE
      UPDATE  JTY_DEA_ATTR_PRODUCTS
      SET     BUILD_INDEX_FLAG = 'Y', FIRST_CHAR_FLAG = l_first_char_flag
      WHERE   dea_attr_products_id = cl_set_S.dea_attr_products_id;
    END IF;

	UPDATE JTY_DEA_ATTR_PRODUCTS
    SET    FIRST_CHAR_FLAG = 'Y'
    WHERE  dea_attr_products_id = cl_set_S.dea_attr_products_id
	AND    attr_relation_product = 353393;

  END LOOP; /* end loop FOR cl_set_S in all_sets */

  -- Set reduction complete
  -- Set build_index_flag = 'N' for all empty column indexes combinations
  FOR empty_column_index in all_empty_column_indexes(p_source_id, p_trans_id) LOOP
    UPDATE JTY_DEA_ATTR_PRODUCTS p
    SET BUILD_INDEX_FLAG = 'N'
    WHERE p.dea_attr_products_id = empty_column_index.dea_attr_products_id;
  END LOOP;

  COMMIT;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set.other',
                     substr(x_msg_data, 1, 4000));

end dea_Reduce_TX_OIN_Index_Set;

PROCEDURE Decompose_Terr_Defns
( p_Api_Version_Number     IN  NUMBER,
  p_Init_Msg_List          IN  VARCHAR2,
  p_trans_target           IN  VARCHAR2,
  p_classify_terr_comb     IN  VARCHAR2,
  p_process_tx_oin_sel     IN  VARCHAR2,
  p_generate_indexes       IN  VARCHAR2,
  p_source_id              IN  NUMBER,
  p_trans_id               IN  NUMBER,
  p_program_name           IN  VARCHAR2,
  p_mode                   IN  VARCHAR2,
  x_Return_Status          OUT NOCOPY VARCHAR2,
  x_Msg_Count              OUT NOCOPY NUMBER,
  x_Msg_Data               OUT NOCOPY VARCHAR2,
  ERRBUF                   OUT NOCOPY VARCHAR2,
  RETCODE                  OUT NOCOPY VARCHAR2 )

IS
  l_selectivity_return_val NUMBER;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.begin',
                   'Start of the procedure JTY_TAE_CONTROL_PVT.decompose_terr_defns ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- ANALYSIS OF TERRITORY DEFINITION FOR DYN PACKAGE GENERATION
  IF (p_classify_terr_comb = 'Y') THEN
    NULL;
  END IF;

  -- OPTIMIZATION OF DATABASE OBJECTS
  IF ((p_process_tx_oin_sel = 'Y') OR (p_process_tx_oin_sel = 'R')) THEN
    IF (p_process_tx_oin_sel = 'Y') THEN
      -- Analyze Selectivity and Get ordinals
      IF (p_mode = 'DATE EFFECTIVE') THEN
        jty_tae_index_creation_pvt.dea_selectivity(p_trans_target, x_return_status);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_data := 'API jty_tae_index_creation_pvt.dea_selectivity has failed';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        jty_tae_index_creation_pvt.selectivity(p_trans_target, p_mode, null, x_return_status);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_data := 'API jty_tae_index_creation_pvt.selectivity has failed';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */

    END IF; /* end IF (p_process_tx_oin_sel = 'Y') */

    IF (p_mode = 'DATE EFFECTIVE') THEN
      -- Reduce Sets
      dea_Reduce_TX_OIN_Index_Set
      ( p_Api_Version_Number =>    1.0,
        p_Init_Msg_List      =>    FND_API.G_FALSE,
        p_source_id          =>    p_source_id,
        p_trans_id           =>    p_trans_id,
        x_Return_Status      =>    x_return_status,
        x_Msg_Count          =>    x_msg_count,
        x_Msg_Data           =>    x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_data := 'CALL to JTY_TAE_CONTROL_PVT.dea_Reduce_TX_OIN_Index_Set API has failed.';
        RAISE	FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      -- Reduce Sets
      Reduce_TX_OIN_Index_Set
      ( p_Api_Version_Number =>    1.0,
        p_Init_Msg_List      =>    FND_API.G_FALSE,
        p_source_id          =>    p_source_id,
        p_trans_id           =>    p_trans_id,
        x_Return_Status      =>    x_return_status,
        x_Msg_Count          =>    x_msg_count,
        x_Msg_Data           =>    x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_data := 'CALL to JTY_TAE_CONTROL_PVT.Reduce_TX_OIN_Index_Set API has failed.';
        RAISE	FND_API.G_EXC_ERROR;
      END IF;
    END IF; /* end IF (p_mode = 'DATE EFFECTIVE') */

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.reduce_tx_oin_index_set',
                     'API JTY_TAE_CONTROL_PVT.reduce_tx_oin_index_set ended with success');
  END IF; /* end IF ((p_process_tx_oin_sel = 'Y') OR (p_process_tx_oin_sel = 'R')) */

  IF (p_generate_indexes = 'Y') THEN
    jty_tae_index_creation_pvt.drop_table_indexes(
        p_table_name => p_trans_target
      , x_return_status => x_return_status);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'CALL to JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed.';
      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- Build Indexes
    IF (p_mode = 'DATE EFFECTIVE') THEN
      jty_tae_index_creation_pvt.create_index( p_trans_target
                                             , p_trans_id
                                             , p_source_id
                                             , p_program_name
                                             , p_mode
                                             , x_return_status
                                             , 'DEA_TRANS');
    ELSE
      jty_tae_index_creation_pvt.create_index( p_trans_target
                                             , p_trans_id
                                             , p_source_id
                                             , p_program_name
                                             , p_mode
                                             , x_return_status
                                             , 'TRANS');
    END IF;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'CALL to JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed.';
      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.create_index',
                     'API jty_tae_index_creation_pvt.create_index ended with success');
  END IF; /* end IF (p_generate_indexes = 'Y') */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.end',
                   'End of the procedure JTY_TAE_CONTROL_PVT.decompose_terr_defns ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.decompose_terr_defns.other',
                     substr(x_msg_data, 1, 4000));

END Decompose_Terr_Defns;

PROCEDURE set_table_nologging( p_table_name VARCHAR2 ) AS

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  v_statement      varchar2(800);

  L_SCHEMA_NOTFOUND  EXCEPTION;

BEGIN

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  v_statement := 'ALTER TABLE ' || l_jtf_schema || '.' || p_table_name || ' NOLOGGING ';
  EXECUTE IMMEDIATE v_statement;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.set_table_nologging.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');

  WHEN OTHERS THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TAE_CONTROL_PVT.set_table_nologging.others',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));
END set_table_nologging;

END JTY_TAE_CONTROL_PVT;

/
