--------------------------------------------------------
--  DDL for Package Body JTY_MISC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_MISC_UTILS_PKG" AS
/* $Header: jtfmsutb.pls 120.1 2006/03/30 17:43:02 achanda noship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_MISC_UTILS_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package conatins utilities APIs for territory
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      08/16/2005  achanda       CREATED
--
--    End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

  G_PKG_NAME      CONSTANT VARCHAR2(30):='JTY_MISC_UTILS_PKG';

--    ***************************************************
--    API Body Definitions
--    ***************************************************

PROCEDURE alter_qual_denorm_tables
( x_success_flag               OUT NOCOPY  VARCHAR2,
  x_err_code                   OUT NOCOPY  VARCHAR2,
  p_qual_usg_id                IN          NUMBER,
  p_comp_op_col                IN          VARCHAR2,
  p_low_value_char_col         IN          VARCHAR2,
  p_high_value_char_col        IN          VARCHAR2,
  p_low_value_char_id_col      IN          VARCHAR2,
  p_low_value_number_col       IN          VARCHAR2,
  p_high_value_number_col      IN          VARCHAR2,
  p_interest_type_id_col       IN          VARCHAR2,
  p_primary_int_code_id_col    IN          VARCHAR2,
  p_secondary_int_code_id_col  IN          VARCHAR2,
  p_value1_id_col              IN          VARCHAR2,
  p_value2_id_col              IN          VARCHAR2,
  p_value3_id_col              IN          VARCHAR2,
  p_value4_id_col              IN          VARCHAR2,
  p_first_char_col             IN          VARCHAR2,
  p_cur_code_col               IN          VARCHAR2
) AS

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);
  l_table_name     VARCHAR2(30);
  l_dea_table_name VARCHAR2(30);

  l_stmt1          VARCHAR2(1000);
  l_stmt2          VARCHAR2(1000);
  l_stmt3          VARCHAR2(1000);

  L_SCHEMA_NOTFOUND  EXCEPTION;

BEGIN

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_MISC_UTILS_PKG.alter_qual_denorm_tables.begin',
                   'Start of the procedure JTY_MISC_UTILS_PKG.alter_qual_denorm_tables');
  END IF;

  IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  IF (l_jtf_schema IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  BEGIN
    SELECT c.denorm_value_table_name,
           c.denorm_dea_value_table_name
    INTO   l_table_name,
           l_dea_table_name
    FROM   jtf_qual_usgs_all a,
           jtf_qual_type_usgs_all b,
           jtf_sources_all c
    WHERE  a.qual_usg_id      = p_qual_usg_id
    AND    a.org_id           = -3113
    AND    a.qual_type_usg_id = b.qual_type_usg_id
    AND    b.source_id        = c.source_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  IF (p_comp_op_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_comp_op_col || ' VARCHAR2(30))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_comp_op_col || ' VARCHAR2(30))';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_comp_op_col || ' VARCHAR2(30))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_comp_op_col IS NOT NULL) */

  IF (p_low_value_char_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_low_value_char_col || ' VARCHAR2(360))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_low_value_char_col || ' VARCHAR2(360))';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_low_value_char_col || ' VARCHAR2(360))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_low_value_char_col IS NOT NULL) */

  IF (p_high_value_char_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_high_value_char_col || ' VARCHAR2(360))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_high_value_char_col || ' VARCHAR2(360))';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_high_value_char_col || ' VARCHAR2(360))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_high_value_char_col IS NOT NULL) */

  IF (p_low_value_char_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_low_value_char_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_low_value_char_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_low_value_char_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_low_value_char_id_col IS NOT NULL) */

  IF (p_low_value_number_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_low_value_number_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_low_value_number_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_low_value_number_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_low_value_number_col IS NOT NULL) */

  IF (p_high_value_number_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_high_value_number_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_high_value_number_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_high_value_number_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_high_value_number_col IS NOT NULL) */

  IF (p_interest_type_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_interest_type_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_interest_type_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_interest_type_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_interest_type_id_col IS NOT NULL) */

  IF (p_primary_int_code_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_primary_int_code_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_primary_int_code_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_primary_int_code_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_primary_int_code_id_col IS NOT NULL) */

  IF (p_secondary_int_code_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_secondary_int_code_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_secondary_int_code_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_secondary_int_code_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_secondary_int_code_id_col IS NOT NULL) */

  IF (p_value1_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_value1_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_value1_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_value1_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_value1_id_col IS NOT NULL) */

  IF (p_value2_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_value2_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_value2_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_value2_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_value2_id_col IS NOT NULL) */

  IF (p_value3_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_value3_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_value3_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_value3_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_value3_id_col IS NOT NULL) */

  IF (p_value4_id_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_value4_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_value4_id_col || ' NUMBER)';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_value4_id_col || ' NUMBER)';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_value4_id_col IS NOT NULL) */

  IF (p_first_char_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_first_char_col || ' VARCHAR2(3))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_first_char_col || ' VARCHAR2(3))';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_first_char_col || ' VARCHAR2(3))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_first_char_col IS NOT NULL) */

  IF (p_cur_code_col IS NOT NULL) THEN
    l_stmt1 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_table_name || ' ADD ( ' || p_cur_code_col || ' VARCHAR2(15))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (l_dea_table_name IS NOT NULL) THEN
      l_stmt2 := 'ALTER TABLE ' || l_jtf_schema || '.' || l_dea_table_name || ' ADD ( ' || p_cur_code_col || ' VARCHAR2(15))';
      BEGIN
        EXECUTE IMMEDIATE l_stmt2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    l_stmt3 := 'ALTER TABLE jty_denorm_terr_attr_values_gt ADD ( ' || p_cur_code_col || ' VARCHAR2(15))';
    BEGIN
      EXECUTE IMMEDIATE l_stmt3;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF; /* end IF (p_cur_code_col IS NOT NULL) */

  x_success_flag := 'Y';
  x_err_code     := null;

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_MISC_UTILS_PKG.alter_qual_denorm_tables.end',
                   'End of the procedure JTY_MISC_UTILS_PKG.alter_qual_denorm_tables');
  END IF;

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_success_flag := 'N';
    x_err_code     := 'JTF Schema not found';
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_MISC_UTILS_PKG.alter_qual_denorm_tables.l_schema_notfound',
                     'Schema name corresponding to JTF application not found');
    END IF;

  WHEN OTHERS THEN
    x_success_flag := 'N';
    x_err_code     := SQLCODE;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_MISC_UTILS_PKG.alter_qual_denorm_tables.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));
    END IF;

End  alter_qual_denorm_tables;

END JTY_MISC_UTILS_PKG;

/
