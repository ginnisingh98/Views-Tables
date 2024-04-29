--------------------------------------------------------
--  DDL for Package Body JTY_TERR_ENGINE_GEN2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TERR_ENGINE_GEN2_PVT" AS
/* $Header: jtfytseb.pls 120.5.12010000.15 2009/11/16 09:05:27 vpalle ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the real time matching SQL
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      07/11/05    ACHANDA  Created
--
--    End of Comments
--

  G_USER_ID         NUMBER       := FND_GLOBAL.USER_ID();
  G_SYSDATE         DATE         := SYSDATE;

  TYPE g_qual_usg_id_tbl_type IS TABLE OF jtf_qual_usgs_all.qual_usg_id%TYPE;
  TYPE g_cp_tbl_type IS TABLE OF jtf_qual_usgs_all.comparison_operator%TYPE;
  TYPE g_lvc_id_tbl_type IS TABLE OF jtf_qual_usgs_all.low_value_char_id%TYPE;
  TYPE g_lvc_tbl_type IS TABLE OF jtf_qual_usgs_all.low_value_char%TYPE;
  TYPE g_hvc_tbl_type IS TABLE OF jtf_qual_usgs_all.high_value_char%TYPE;
  TYPE g_lvn_tbl_type IS TABLE OF jtf_qual_usgs_all.low_value_number%TYPE;
  TYPE g_hvn_tbl_type IS TABLE OF jtf_qual_usgs_all.high_value_number%TYPE;
  TYPE g_it_id_tbl_type IS TABLE OF jtf_qual_usgs_all.interest_type_id%TYPE;
  TYPE g_pic_id_tbl_type IS TABLE OF jtf_qual_usgs_all.primary_interest_code_id%TYPE;
  TYPE g_sic_id_tbl_type IS TABLE OF jtf_qual_usgs_all.secondary_interest_code_id%TYPE;
  TYPE g_curr_tbl_type IS TABLE OF jtf_qual_usgs_all.currency_code%TYPE;
  TYPE g_value1_id_tbl_type IS TABLE OF jtf_qual_usgs_all.value1_id%TYPE;
  TYPE g_value2_id_tbl_type IS TABLE OF jtf_qual_usgs_all.value2_id%TYPE;
  TYPE g_value3_id_tbl_type IS TABLE OF jtf_qual_usgs_all.value3_id%TYPE;
  TYPE g_value4_id_tbl_type IS TABLE OF jtf_qual_usgs_all.value4_id%TYPE;
  TYPE g_fc_tbl_type IS TABLE OF jtf_qual_usgs_all.first_char%TYPE;

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

PROCEDURE populate_index_info (
  p_source_id       IN  NUMBER,
  p_trans_id        IN  NUMBER,
  p_mode            IN  VARCHAR2,
  p_qual_usg_id_tbl IN g_qual_usg_id_tbl_type,
  p_cp_tbl          IN g_cp_tbl_type,
  p_lvc_id_tbl      IN g_lvc_id_tbl_type,
  p_lvc_tbl         IN g_lvc_tbl_type,
  p_hvc_tbl         IN g_hvc_tbl_type,
  p_lvn_tbl         IN g_lvn_tbl_type,
  p_hvn_tbl         IN g_hvn_tbl_type,
  p_it_id_tbl       IN g_it_id_tbl_type,
  p_pic_id_tbl      IN g_pic_id_tbl_type,
  p_sic_id_tbl      IN g_sic_id_tbl_type,
  p_curr_tbl        IN g_curr_tbl_type,
  p_value1_id_tbl   IN g_value1_id_tbl_type,
  p_value2_id_tbl   IN g_value2_id_tbl_type,
  p_value3_id_tbl   IN g_value3_id_tbl_type,
  p_value4_id_tbl   IN g_value4_id_tbl_type,
  p_fc_tbl          IN g_fc_tbl_type,
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2
)
AS
  l_no_of_records NUMBER;
  l_header_seq    NUMBER;

  l_qual_type_usg_id NUMBER;
  l_index_name       varchar2(30);

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_index_info.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN2_PVT.populate_index_info ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF (p_qual_usg_id_tbl.COUNT > 0) THEN

    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_id;

    FOR i IN p_qual_usg_id_tbl.FIRST .. p_qual_usg_id_tbl.LAST LOOP
      l_no_of_records := 0;

      SELECT count(*)
      INTO   l_no_of_records
      FROM   jty_terr_values_idx_header
      WHERE  source_id = p_source_id
      AND    qual_usg_id = p_qual_usg_id_tbl(i);

      IF (l_no_of_records = 0) THEN

        SELECT jty_terr_values_idx_header_s.nextval
        INTO   l_header_seq
        FROM   dual;

        SELECT 'JTY_DNM_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_RN' ||
                                 (nvl(max(to_number(substr(index_name, instr(index_name, '_RN')+3))), 0) + 1)
        INTO   l_index_name
        FROM   jty_terr_values_idx_header
        WHERE  index_name like 'JTY_DNM_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_RN%';

        INSERT INTO jty_terr_values_idx_header (
           terr_values_idx_header_id
          ,source_id
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,qual_usg_id
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
          ,p_qual_usg_id_tbl(i)
          ,l_index_name
          ,'Y'
          ,'N');

        IF (p_cp_tbl(i) IS NOT NULL) THEN
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
            ,p_cp_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvc_id_tbl(i) IS NOT NULL) THEN
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
            ,p_lvc_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvc_tbl(i) IS NOT NULL) THEN
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
            ,p_lvc_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_hvc_tbl(i) IS NOT NULL) THEN
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
            ,p_hvc_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvn_tbl(i) IS NOT NULL) THEN
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
            ,p_lvn_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_hvn_tbl(i) IS NOT NULL) THEN
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
            ,p_hvn_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_it_id_tbl(i) IS NOT NULL) THEN
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
            ,p_it_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_pic_id_tbl(i) IS NOT NULL) THEN
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
            ,p_pic_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_sic_id_tbl(i) IS NOT NULL) THEN
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
            ,p_sic_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_curr_tbl(i) IS NOT NULL) THEN
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
            ,p_curr_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value1_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value1_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value2_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value2_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value3_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value3_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value4_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value4_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_fc_tbl(i) IS NOT NULL) THEN
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
            ,p_fc_tbl(i)
            ,null
            ,null);
        END IF;

      ELSE

        /* in incremental mode , if the qualifier is alreday present */
        /* then mark it as being used by active territory            */
        IF (p_mode = 'INCREMENTAL') THEN
          UPDATE jty_terr_values_idx_header
          SET    delete_flag = 'N'
          WHERE  source_id = p_source_id
          AND    qual_usg_id = p_qual_usg_id_tbl(i);
        END IF; -- END IF (p_mode = 'INCREMENTAL')

      END IF; -- END IF (l_no_of_records = 0)
    END LOOP; -- END FOR i IN p_qual_usg_id_tbl.FIRST .. p_qual_usg_id_tbl.LAST

  END IF; -- IF (p_qual_usg_id_tbl.COUNT > 0)

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_index_info.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN2_PVT.populate_index_info ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_index_info.others',
                     substr(errbuf, 1, 4000));

END populate_index_info;

PROCEDURE populate_dea_index_info (
  p_source_id       IN  NUMBER,
  p_trans_id        IN  NUMBER,
  p_qual_usg_id_tbl IN g_qual_usg_id_tbl_type,
  p_cp_tbl          IN g_cp_tbl_type,
  p_lvc_id_tbl      IN g_lvc_id_tbl_type,
  p_lvc_tbl         IN g_lvc_tbl_type,
  p_hvc_tbl         IN g_hvc_tbl_type,
  p_lvn_tbl         IN g_lvn_tbl_type,
  p_hvn_tbl         IN g_hvn_tbl_type,
  p_it_id_tbl       IN g_it_id_tbl_type,
  p_pic_id_tbl      IN g_pic_id_tbl_type,
  p_sic_id_tbl      IN g_sic_id_tbl_type,
  p_curr_tbl        IN g_curr_tbl_type,
  p_value1_id_tbl   IN g_value1_id_tbl_type,
  p_value2_id_tbl   IN g_value2_id_tbl_type,
  p_value3_id_tbl   IN g_value3_id_tbl_type,
  p_value4_id_tbl   IN g_value4_id_tbl_type,
  p_fc_tbl          IN g_fc_tbl_type,
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2
)
AS
  l_no_of_records NUMBER;
  l_header_seq    NUMBER;

  l_qual_type_usg_id NUMBER;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_dea_index_info.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN2_PVT.populate_dea_index_info ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  IF (p_qual_usg_id_tbl.COUNT > 0) THEN

    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_id;

    FOR i IN p_qual_usg_id_tbl.FIRST .. p_qual_usg_id_tbl.LAST LOOP
      l_no_of_records := 0;

      SELECT count(*)
      INTO   l_no_of_records
      FROM   jty_dea_values_idx_header
      WHERE  source_id = p_source_id
      AND    qual_usg_id = p_qual_usg_id_tbl(i);

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
          ,qual_usg_id
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
          ,p_qual_usg_id_tbl(i)
          ,'JTY_DEA_ATTR_VAL_' || abs(l_qual_type_usg_id) || '_RN' || i
          ,'Y');

        IF (p_cp_tbl(i) IS NOT NULL) THEN
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
            ,p_cp_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvc_id_tbl(i) IS NOT NULL) THEN
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
            ,p_lvc_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvc_tbl(i) IS NOT NULL) THEN
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
            ,p_lvc_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_hvc_tbl(i) IS NOT NULL) THEN
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
            ,p_hvc_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_lvn_tbl(i) IS NOT NULL) THEN
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
            ,p_lvn_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_hvn_tbl(i) IS NOT NULL) THEN
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
            ,p_hvn_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_it_id_tbl(i) IS NOT NULL) THEN
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
            ,p_it_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_pic_id_tbl(i) IS NOT NULL) THEN
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
            ,p_pic_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_sic_id_tbl(i) IS NOT NULL) THEN
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
            ,p_sic_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_curr_tbl(i) IS NOT NULL) THEN
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
            ,p_curr_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value1_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value1_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value2_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value2_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value3_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value3_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_value4_id_tbl(i) IS NOT NULL) THEN
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
            ,p_value4_id_tbl(i)
            ,null
            ,null);
        END IF;

        IF (p_fc_tbl(i) IS NOT NULL) THEN
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
            ,p_fc_tbl(i)
            ,null
            ,null);
        END IF;

      END IF; -- IF (l_no_of_records = 0)
    END LOOP; -- FOR i IN p_qual_usg_id_tbl.FIRST .. p_qual_usg_id_tbl.LAST

  END IF; -- IF (p_qual_usg_id_tbl.COUNT > 0)

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_dea_index_info.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN2_PVT.populate_dea_index_info ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.populate_dea_index_info.others',
                     substr(errbuf, 1, 4000));

END populate_dea_index_info;

/* this procedure generates the real time matching SQL for a transaction type */
PROCEDURE gen_terr_rules_recurse (
  p_source_id  IN  NUMBER,
  p_trans_id   IN  NUMBER,
  p_mode       IN  VARCHAR2,
  p_start_date IN  DATE,
  p_end_date   IN  DATE,
  errbuf       OUT NOCOPY VARCHAR2,
  retcode      OUT NOCOPY VARCHAR2
)
AS
  CURSOR c_terr_qual( lp_source_id  NUMBER
                     ,lp_trans_id   NUMBER
                     ,lp_start_date DATE
                     ,lp_end_date   DATE) IS
  SELECT  jqu.qual_usg_id
         ,jqu.real_time_select
         ,jqu.real_time_from
         ,jqu.real_time_where
         ,jqu.comparison_operator
         ,jqu.low_value_char_id
         ,jqu.low_value_char
         ,jqu.high_value_char
         ,jqu.low_value_number
         ,jqu.high_value_number
         ,jqu.interest_type_id
         ,jqu.primary_interest_code_id
         ,jqu.secondary_interest_code_id
         ,jqu.currency_code
         ,jqu.value1_id
         ,jqu.value2_id
         ,jqu.value3_id
         ,jqu.value4_id
         ,jqu.first_char
  FROM    jtf_qual_usgs_all jqu
         ,jtf_qual_type_usgs jqtu
         ,jtf_qual_type_denorm_v v
  WHERE jqu.org_id = -3113
  AND   jqu.qual_type_usg_id = jqtu.qual_type_usg_id
  AND   jqtu.source_id = lp_source_id
  AND   jqtu.qual_type_id = v.related_id
  AND   jqu.real_time_select IS NOT NULL
  AND   v.qual_type_id = lp_trans_id
  AND EXISTS ( SELECT jtq.terr_id
               FROM   jtf_terr_qtype_usgs_all jtqu
                     ,jtf_terr_all jt
                     ,jtf_terr_qual_all jtq
                     ,jtf_qual_type_usgs jqtu
               WHERE jt.end_date_active >= lp_start_date
               AND   jt.start_date_active <= lp_end_date
               AND   jtqu.terr_id = jt.terr_id
               AND   jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
               AND   jqtu.qual_type_id = lp_trans_id
               AND   jtqu.terr_id = jtq.terr_id
               AND   jtq.qual_usg_id = jqu.qual_usg_id);

  CURSOR c_trans_details( lp_source_id NUMBER
                         ,lp_trans_id NUMBER) IS
  SELECT  program_name
         ,real_time_trans_table_name
  FROM   jty_trans_usg_pgm_details
  WHERE  source_id = lp_source_id
  AND    trans_type_id = lp_trans_id;

  TYPE l_rts_tbl_type IS TABLE OF jtf_qual_usgs_all.real_time_select%TYPE;
  TYPE l_rtf_tbl_type IS TABLE OF jtf_qual_usgs_all.real_time_from%TYPE;
  TYPE l_rtw_tbl_type IS TABLE OF jtf_qual_usgs_all.real_time_where%TYPE;

  TYPE l_pgm_name_tbl_type IS TABLE OF jty_trans_usg_pgm_details.program_name%TYPE;
  TYPE l_trans_name_tbl_type IS TABLE OF jty_trans_usg_pgm_details.real_time_trans_table_name%TYPE;

  l_qual_usg_id_tbl  g_qual_usg_id_tbl_type;
  l_rts_tbl          l_rts_tbl_type;
  l_rtf_tbl          l_rtf_tbl_type;
  l_rtw_tbl          l_rtw_tbl_type;
  l_cp_tbl           g_cp_tbl_type;
  l_lvc_id_tbl       g_lvc_id_tbl_type;
  l_lvc_tbl          g_lvc_tbl_type;
  l_hvc_tbl          g_hvc_tbl_type;
  l_lvn_tbl          g_lvn_tbl_type;
  l_hvn_tbl          g_hvn_tbl_type;
  l_it_id_tbl        g_it_id_tbl_type;
  l_pic_id_tbl       g_pic_id_tbl_type;
  l_sic_id_tbl       g_sic_id_tbl_type;
  l_curr_tbl         g_curr_tbl_type;
  l_value1_id_tbl    g_value1_id_tbl_type;
  l_value2_id_tbl    g_value2_id_tbl_type;
  l_value3_id_tbl    g_value3_id_tbl_type;
  l_value4_id_tbl    g_value4_id_tbl_type;
  l_fc_tbl           g_fc_tbl_type;

  l_pgm_name_tbl    l_pgm_name_tbl_type;
  l_trans_name_tbl  l_trans_name_tbl_type;

  l_table_name      VARCHAR2(30);
  l_insert_stmt     VARCHAR2(32767);
  l_qual_rules      VARCHAR2(32767);
  l_group_by        VARCHAR2(32767);
  l_counter         NUMBER;
  l_realtime_sql    CLOB;

  l_newline        VARCHAR2(2);

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */

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

  /* get all the qualifiers and its real time rules, used by the active territories */
  OPEN c_terr_qual(p_source_id, p_trans_id, p_start_date, p_end_date);
  FETCH c_terr_qual BULK COLLECT INTO
     l_qual_usg_id_tbl
    ,l_rts_tbl
    ,l_rtf_tbl
    ,l_rtw_tbl
    ,l_cp_tbl
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
    ,l_fc_tbl;
  CLOSE c_terr_qual;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.num_qual',
                   'Number of qualifiers used by valid territories : ' || l_qual_usg_id_tbl.COUNT);

  /* get all the program name and its corresponding real time trans table for the usage and txn type */
  OPEN c_trans_details(p_source_id, p_trans_id);
  FETCH c_trans_details BULK COLLECT INTO
     l_pgm_name_tbl
    ,l_trans_name_tbl;
  CLOSE c_trans_details;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.num_program',
                   'Number of programs for the usage and transaction type : ' || l_pgm_name_tbl.COUNT);

  /* generic insert statement */
  l_insert_stmt :=
    'INSERT INTO jtf_terr_results_GT_MT jtr ' ||
    '( ' ||
    '   trans_id ' ||
    '  ,source_id ' ||
    '  ,qual_type_id ' ||
    '  ,trans_object_id ' ||
    '  ,trans_detail_object_id ' ||
    '  ,txn_date ' ||
    '  ,terr_id ' ||
    '  ,absolute_rank ' ||
    '  ,top_level_terr_id ' ||
    '  ,num_winners ' ||
    '  ,worker_id ' ||
    ') ' ||
    'SELECT ' ||
    ' ' || p_trans_id || ' ' ||
    ' ,' || p_source_id || ' ' ||
    ' ,' || p_trans_id || ' ' ||
    '  ,ILV.trans_object_id ' ||
    '  ,ILV.trans_detail_object_id ' ||
    '  ,ILV.txn_date ' ||
    '  ,ILV.terr_id ' ||
    '  ,ILV.absolute_rank ' ||
    '  ,ILV.top_level_terr_id ' ||
    '  ,ILV.num_winners ' ||
    '  ,1 ' ||
    'FROM ( ';

  /* generic group by clause */
  l_group_by :=
    ' ) ILV ' ||
    'GROUP BY ilv.trans_object_id, ilv.trans_detail_object_id, ilv.txn_date, ' ||
    'ilv.terr_id, ilv.absolute_rank, ilv.top_level_terr_id, ilv.num_winners ' ||
    'HAVING (ILV.terr_id, COUNT(*)) IN ( ' ||
    '    SELECT ' ||
    '       jua.terr_id ' ||
    '      ,jua.num_qual ' ||
    '    FROM  jtf_terr_qtype_usgs_all jua ' ||
    '         ,jtf_qual_type_usgs_all jqa ' ||
    '    WHERE jqa.source_id = ' || p_source_id || ' ' ||
    '    AND   jqa.qual_type_id = ' || p_trans_id || ' ' ||
    '    AND   jua.qual_type_usg_id = jqa.qual_type_usg_id ' ||
    '    AND   jua.terr_id = ilv.terr_id ) ';

  IF (l_pgm_name_tbl.COUNT > 0) THEN

    /* repeat for each program name */
    FOR i IN l_pgm_name_tbl.FIRST .. l_pgm_name_tbl.LAST LOOP
      IF (l_qual_usg_id_tbl.COUNT > 0) THEN

        l_counter := 1;
        l_qual_rules := null;

        /* repeat for each qualifier */
        FOR j IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST LOOP

          -- City           -1040
          -- Postal Code    -1041
          -- State          -1042
          -- County         -1044
          -- Request Type   -1048
          -- Inventory Item -1096
          -- Code changes done to the above qualifiers . Bug 7368422.


          -- Country  			-1038
          -- Task Status 		-1061
          -- Task Type  		-1060
          -- Area Code  		-1043
          -- Request Creation Channel  	-1095
          -- Problem Code  		-1051
          -- Request Urgency            -1050
          -- Customer Name 		-1037
          -- Code changes done to the above qualifiers . Bug 8317860.

          -- Product Category/ Product -1210
          -- Customer Name Range       -1045
          -- Code changes done to the above qualifiers. Bug 9032760

          IF  l_qual_usg_id_tbl(j) in ( '-1040','-1041','-1042','-1044','-1048','-1096',
                           '-1037','-1038','-1043','-1050','-1051','-1060','-1061','-1095', '-1210', '-1045')  THEN

            IF (l_counter > 1) THEN
              l_qual_rules :=  l_qual_rules || l_newline || ' UNION ALL ' || l_newline;
            END IF;
            l_qual_rules :=  l_qual_rules || l_rts_tbl(j) || l_newline || ' FROM ' || l_trans_name_tbl(i) || ' A ';
            /* add the denorm value table name */
            l_qual_rules := l_qual_rules || l_newline || ' , jtf_terr_values_all jtv, jtf_terr_denorm_rules_all B, jtf_terr_qual_all jtq ';
            IF (l_rtf_tbl(j) IS NOT NULL) THEN
              l_qual_rules := l_qual_rules || l_newline || ' ,' || l_rtf_tbl(j) || ' ';
            END IF;
            l_qual_rules := l_qual_rules || l_newline || l_rtw_tbl(j) || l_newline || ' ';

          ELSE

            IF (l_counter > 1) THEN
              l_qual_rules :=  l_qual_rules || l_newline || ' UNION ALL ' || l_newline;
            END IF;
            l_qual_rules :=  l_qual_rules || l_rts_tbl(j) || l_newline || ' FROM ' || l_trans_name_tbl(i) || ' A ';
            /* add the denorm value table name */
            l_qual_rules := l_qual_rules || l_newline || ' ,' || l_table_name || ' B ';
            IF (l_rtf_tbl(j) IS NOT NULL) THEN
              l_qual_rules := l_qual_rules || l_newline || ' ,' || l_rtf_tbl(j) || ' ';
            END IF;
            l_qual_rules := l_qual_rules || l_newline || l_rtw_tbl(j) || l_newline || ' AND B.trans_type_id = ' || p_trans_id;

          END IF;
          l_counter := l_counter + 1;

        END LOOP; /* end loop FOR j IN l_qual_usg_id_tbl.FIRST .. l_qual_usg_id_tbl.LAST */
      END IF; /* end IF (l_qual_usg_id_tbl.COUNT > 0) */

      l_realtime_sql := l_insert_stmt || l_qual_rules || l_group_by;

      /* if mode is date effective, update the column real_time_match_dea_sql */
      IF (p_mode = 'DATE EFFECTIVE') THEN
        UPDATE jty_trans_usg_pgm_details
        SET    real_time_match_dea_sql = l_realtime_sql,
               last_update_date = sysdate
        WHERE  source_id = p_source_id
        AND    trans_type_id = p_trans_id
        AND    program_name = l_pgm_name_tbl(i);
      ELSE
      /* if mode is total or incremental, update the column real_time_match_sql */
        UPDATE jty_trans_usg_pgm_details
        SET    real_time_match_sql = l_realtime_sql,
               last_update_date = sysdate
        WHERE  source_id = p_source_id
        AND    trans_type_id = p_trans_id
        AND    program_name = l_pgm_name_tbl(i);
      END IF;

    END LOOP; /* end loop FOR i IN l_pgm_name_tbl.FIRST .. l_pgm_name_tbl.LAST */
  END IF; /* end IF (l_pgm_name_tbl.COUNT > 0) */

  /* Populate the index informations for all the qualifiers */
  IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN
    populate_index_info (
      p_source_id       => p_source_id,
      p_trans_id        => p_trans_id,
      p_mode            => p_mode,
      p_qual_usg_id_tbl => l_qual_usg_id_tbl,
      p_cp_tbl          => l_cp_tbl,
      p_lvc_id_tbl      => l_lvc_id_tbl,
      p_lvc_tbl         => l_lvc_tbl,
      p_hvc_tbl         => l_hvc_tbl,
      p_lvn_tbl         => l_lvn_tbl,
      p_hvn_tbl         => l_hvn_tbl,
      p_it_id_tbl       => l_it_id_tbl,
      p_pic_id_tbl      => l_pic_id_tbl,
      p_sic_id_tbl      => l_sic_id_tbl,
      p_curr_tbl        => l_curr_tbl,
      p_value1_id_tbl   => l_value1_id_tbl,
      p_value2_id_tbl   => l_value2_id_tbl,
      p_value3_id_tbl   => l_value3_id_tbl,
      p_value4_id_tbl   => l_value4_id_tbl,
      p_fc_tbl          => l_fc_tbl,
      errbuf            => errbuf,
      retcode           => retcode
    );
  ELSIF (p_mode = 'DATE EFFECTIVE') THEN
    populate_dea_index_info (
      p_source_id       => p_source_id,
      p_trans_id        => p_trans_id,
      p_qual_usg_id_tbl => l_qual_usg_id_tbl,
      p_cp_tbl          => l_cp_tbl,
      p_lvc_id_tbl      => l_lvc_id_tbl,
      p_lvc_tbl         => l_lvc_tbl,
      p_hvc_tbl         => l_hvc_tbl,
      p_lvn_tbl         => l_lvn_tbl,
      p_hvn_tbl         => l_hvn_tbl,
      p_it_id_tbl       => l_it_id_tbl,
      p_pic_id_tbl      => l_pic_id_tbl,
      p_sic_id_tbl      => l_sic_id_tbl,
      p_curr_tbl        => l_curr_tbl,
      p_value1_id_tbl   => l_value1_id_tbl,
      p_value2_id_tbl   => l_value2_id_tbl,
      p_value3_id_tbl   => l_value3_id_tbl,
      p_value4_id_tbl   => l_value4_id_tbl,
      p_fc_tbl          => l_fc_tbl,
      errbuf            => errbuf,
      retcode           => retcode
    );
  END IF;

  IF (retcode <> 0) THEN
    -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.populate_index_info',
                         'populate_index_info API has failed');

    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.g_exc_error',
                     'API JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse.others',
                     substr(errbuf, 1, 4000));

END gen_terr_rules_recurse;


/* entry point of this package to generate the real time matching SQL */
PROCEDURE gen_real_time_sql (
  p_source_id  IN  NUMBER,
  p_trans_id   IN  NUMBER,
  p_mode       IN  VARCHAR2,
  p_start_date IN  DATE,
  p_end_date   IN  DATE,
  errbuf       OUT NOCOPY VARCHAR2,
  retcode      OUT NOCOPY VARCHAR2
)
AS
  l_num_of_terr NUMBER;
  l_start_date  DATE;
  l_end_date    DATE;

BEGIN
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.start',
                   'Start of the procedure JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.parameters',
                   'p_source_id : ' || p_source_id || ' p_trans_id : ' || p_trans_id || ' p_mode : ' || p_mode ||
                   ' p_start_date : ' || p_start_date || ' p_end_date : ' || p_end_date);

  /* if mode is date effective consider the territories active between p_start_date and p_end_date */
  /* else if mode is total or incremental consider the territories active as of sysdate            */
  IF (p_mode = 'DATE EFFECTIVE') THEN
    l_start_date := p_start_date;
    l_end_date   := p_end_date;
  ELSE
    l_start_date := sysdate;
    l_end_date   := sysdate;
  END IF;

  /* Check for the number of territories for this usage and transaction type */
  IF (p_mode = 'DATE EFFECTIVE') THEN
    SELECT COUNT (jt1.terr_id)
    INTO   l_num_of_terr
    FROM   jtf_terr_qtype_usgs_all jtqu
         , jtf_terr_all jt1
         , jtf_qual_type_usgs jqtu
    WHERE jtqu.terr_id = jt1.terr_id
    AND   jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
    AND   jqtu.qual_type_id = p_trans_id
    AND   jqtu.source_id = p_source_id
    AND   jt1.end_date_active >= l_start_date
    AND   jt1.start_date_active <= l_end_date
    AND EXISTS (
            SELECT 1
            FROM   jtf_terr_rsc_all jtr,
                   jtf_terr_rsc_access_all jtra,
                   jtf_qual_types_all jqta
            WHERE  jtr.terr_id = jt1.terr_id
            AND    jtr.end_date_active >= l_start_date
            AND    jtr.start_date_active <= l_end_date
            AND    jtr.resource_type <> 'RS_ROLE'
            AND    jtr.terr_rsc_id = jtra.terr_rsc_id
            AND    jtra.access_type = jqta.name
            AND    jqta.qual_type_id = p_trans_id
            AND    jtra.trans_access_code <> 'NONE')
    AND EXISTS (
            SELECT 1
            FROM   jty_denorm_dea_rules_all jtdr
            WHERE  jtdr.terr_id = jt1.terr_id
            AND    jtdr.terr_id = jtdr.related_terr_id)
    AND jqtu.qual_type_id <> -1001
    AND rownum < 2;
  ELSE
    SELECT COUNT(jt1.terr_id)
    INTO   l_num_of_terr
    FROM   jtf_terr_qtype_usgs_all jtqu
         , jtf_terr_all jt1
         , jtf_qual_type_usgs jqtu
    WHERE jtqu.terr_id = jt1.terr_id
    AND   jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
    AND   jqtu.qual_type_id = p_trans_id
    AND   jqtu.source_id = p_source_id
    AND   jt1.end_date_active >= l_start_date
    AND   jt1.start_date_active <= l_end_date
    AND EXISTS (
            SELECT 1
            FROM   jtf_terr_rsc_all jtr,
                   jtf_terr_rsc_access_all jtra,
                   jtf_qual_types_all jqta
            WHERE  jtr.terr_id = jt1.terr_id
            AND    jtr.end_date_active >= l_start_date
            AND    jtr.start_date_active <= l_end_date
            AND    jtr.resource_type <> 'RS_ROLE'
            AND    jtr.terr_rsc_id = jtra.terr_rsc_id
            AND    jtra.access_type = jqta.name
            AND    jqta.qual_type_id = p_trans_id
            AND    jtra.trans_access_code <> 'NONE')
    AND EXISTS (
            SELECT 1
            FROM   jtf_terr_denorm_rules_all jtdr
            WHERE  jtdr.terr_id = jt1.terr_id
            AND    jtdr.terr_id = jtdr.related_terr_id)
    AND jqtu.qual_type_id <> -1001
    AND rownum < 2;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.num_terr',
                   'Number of territories for this usage and transaction type : ' || l_num_of_terr);

  /* territories exist for this USAGE/TRANSACTION TYPE combination */
  IF (l_num_of_terr > 0) THEN

    /* generate real time matching sql */
    gen_terr_rules_recurse (
      p_source_id  => p_source_id,
      p_trans_id   => p_trans_id,
      p_mode       => p_mode,
      p_start_date => l_start_date,
      p_end_date   => l_end_date,
      errbuf       => errbuf,
      retcode      => retcode);

    IF (retcode <> 0) THEN
      -- debug message
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                           'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.gen_terr_rules_recurse',
                           'gen_terr_rules_recurse API has failed');

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  ELSE
    -- debug message
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.no_real_time_sql',
                     'No valid territories for this usage and transaction type');

  END IF; /* end if(num_of_terr > 0) */

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.end',
                   'End of the procedure JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.g_exc_error',
                     'API JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql has failed with FND_API.G_EXC_ERROR exception');

  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF  := SQLCODE || ' : ' || SQLERRM;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_ENGINE_GEN2_PVT.gen_real_time_sql.others',
                     substr(errbuf, 1, 4000));

END gen_real_time_sql;

END JTY_TERR_ENGINE_GEN2_PVT;

/
