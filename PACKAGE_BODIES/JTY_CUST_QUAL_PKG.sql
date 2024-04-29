--------------------------------------------------------
--  DDL for Package Body JTY_CUST_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_CUST_QUAL_PKG" AS
/* $Header: jtfcusqb.pls 120.2 2006/09/22 22:16:45 chchandr noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_CUST_QUAL_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to create custom qualifiers
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/08/05    ACHANDA         Created
--
--    End of Comments
--

  G_NEW_LINE    VARCHAR2(02) := fnd_global.local_chr(10);

/* this procedure forms the insert and update statement for the columns UPDATE_ATTR_VAL_STMT */
/* and UPDATE_ATTR_VAL_STMT in the table jtf_qual_usgs_all                                   */
PROCEDURE get_attr_val_stmt(
  p_comparison_operator        IN VARCHAR2,
  p_low_value_char             IN VARCHAR2,
  p_high_value_char            IN VARCHAR2,
  p_low_value_char_id          IN VARCHAR2,
  p_low_value_number           IN VARCHAR2,
  p_high_value_number          IN VARCHAR2,
  p_interest_type_id           IN VARCHAR2,
  p_primary_interest_code_id   IN VARCHAR2,
  p_secondary_interest_code_id IN VARCHAR2,
  p_value1_id                  IN VARCHAR2,
  p_value2_id                  IN VARCHAR2,
  p_value3_id                  IN VARCHAR2,
  p_value4_id                  IN VARCHAR2,
  p_first_char                 IN VARCHAR2,
  p_currency_code              IN VARCHAR2,
  p_update_stmt                OUT NOCOPY VARCHAR2,
  p_insert_stmt                OUT NOCOPY VARCHAR2,
  retcode                      OUT NOCOPY VARCHAR2,
  errbuf                       OUT NOCOPY VARCHAR2) IS
BEGIN
  p_insert_stmt :=
    'INSERT into jty_denorm_terr_attr_values_gt( ' || g_new_line ||
    '   terr_id' || g_new_line ||
    '  ,start_date' || g_new_line ||
    '  ,end_date' || g_new_line ||
    '  ,source_id' || g_new_line ||
    '  ,trans_type_id' || g_new_line ||
    '  ,creation_date' || g_new_line ||
    '  ,created_by' || g_new_line ||
    '  ,last_update_date' || g_new_line ||
    '  ,last_updated_by' || g_new_line ||
    '  ,last_update_login' || g_new_line ||
    '  ,absolute_rank' || g_new_line ||
    '  ,top_level_terr_id' || g_new_line ||
    '  ,program_id' || g_new_line ||
    '  ,program_login_id' || g_new_line ||
    '  ,program_application_id' || g_new_line ||
    '  ,request_id' || g_new_line ||
    '  ,program_update_date' || g_new_line;

  p_update_stmt := 'UPDATE jty_denorm_terr_attr_values_gt ' || g_new_line || 'SET ';

  p_insert_stmt := p_insert_stmt || '  ,' || p_comparison_operator || g_new_line;

  p_update_stmt := p_update_stmt || p_comparison_operator || ' = :1,' || g_new_line;

  if (p_low_value_char_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_low_value_char_id || g_new_line;
	p_update_stmt := p_update_stmt || p_low_value_char_id || ' = :2,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy1' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy1 = :2, ' || g_new_line;
  end if;

  if (p_low_value_char is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_low_value_char || g_new_line;
	p_update_stmt := p_update_stmt || p_low_value_char || ' = :3,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy2' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy2 = :3, ' || g_new_line;
  end if;

  if (p_high_value_char is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_high_value_char || g_new_line;
	p_update_stmt := p_update_stmt || p_high_value_char || ' = :4,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy3' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy3 = :4, ' || g_new_line;
  end if;

  if (p_low_value_number is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_low_value_number || g_new_line;
	p_update_stmt := p_update_stmt || p_low_value_number || ' = :5,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy4' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy4 = :5, ' || g_new_line;
  end if;

  if (p_high_value_number is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_high_value_number || g_new_line;
	p_update_stmt := p_update_stmt || p_high_value_number || ' = :6,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy5' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy5 = :6, ' || g_new_line;
  end if;

  if (p_interest_type_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_interest_type_id || g_new_line;
	p_update_stmt := p_update_stmt || p_interest_type_id || ' = :7,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy6' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy6 = :7, ' || g_new_line;
  end if;

  if (p_primary_interest_code_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_primary_interest_code_id || g_new_line;
	p_update_stmt := p_update_stmt || p_primary_interest_code_id || ' = :8,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy7' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy7 = :8, ' || g_new_line;
  end if;

  if (p_secondary_interest_code_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_secondary_interest_code_id || g_new_line;
	p_update_stmt := p_update_stmt || p_secondary_interest_code_id || ' = :9,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy8' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy8 = :9, ' || g_new_line;
  end if;

  if (p_currency_code is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_currency_code || g_new_line;
	p_update_stmt := p_update_stmt || p_currency_code || ' = :10,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy9' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy9 = :10, ' || g_new_line;
  end if;

  if (p_value1_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_value1_id || g_new_line;
	p_update_stmt := p_update_stmt || p_value1_id || ' = :11,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy10' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy10 = :11, ' || g_new_line;
  end if;

  if (p_value2_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_value2_id || g_new_line;
	p_update_stmt := p_update_stmt || p_value2_id || ' = :12,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy11' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy11 = :12, ' || g_new_line;
  end if;

  if (p_value3_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_value3_id || g_new_line;
	p_update_stmt := p_update_stmt || p_value3_id || ' = :13,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy12' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy12 = :13, ' || g_new_line;
  end if;

  if (p_value4_id is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_value4_id || g_new_line;
	p_update_stmt := p_update_stmt || p_value4_id || ' = :14,' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy13' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy13 = :14, ' || g_new_line;
  end if;

  if (p_first_char is not null) then
    p_insert_stmt := p_insert_stmt || '  ,' || p_first_char || g_new_line;
	p_update_stmt := p_update_stmt || p_first_char || ' = :15' || g_new_line;
  else
    p_insert_stmt := p_insert_stmt || '  ,dummy14' || g_new_line;
	p_update_stmt := p_update_stmt || 'dummy14 = :15 ' || g_new_line;
  end if;

  p_insert_stmt := p_insert_stmt || ')' || g_new_line;
  p_insert_stmt := p_insert_stmt || 'VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, ' ||
    ':16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, :31, :32)';

  p_update_stmt := p_update_stmt || 'where terr_id = :16' || g_new_line ||
                                    'and source_id = :17' || g_new_line ||
                                    'and trans_type_id = :18';

  retcode := 0;
  errbuf  := null;
EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    errbuf  := 'Error in generating insert and update attribute values statement';
END get_attr_val_stmt;

PROCEDURE create_qual(
  p_seeded_qual_id             IN NUMBER,
  p_name                       IN VARCHAR2,
  p_description                IN VARCHAR2,
  p_language                   IN VARCHAR2,
  p_source_id                  IN NUMBER,
  p_trans_type_id              IN NUMBER,
  p_enabled_flag               IN VARCHAR2,
  p_qual_col1                  IN VARCHAR2,
  p_convert_to_id_flag         IN VARCHAR2,
  p_display_type               IN VARCHAR2,
  p_alias_rule1                IN VARCHAR2,
  p_op_eql                     IN VARCHAR2,
  p_op_like                    IN VARCHAR2,
  p_op_between                 IN VARCHAR2,
  p_op_common_where            IN VARCHAR2,
  p_qual_relation_factor       IN NUMBER,
  p_comparison_operator        IN VARCHAR2,
  p_low_value_char             IN VARCHAR2,
  p_high_value_char            IN VARCHAR2,
  p_low_value_char_id          IN VARCHAR2,
  p_low_value_number           IN VARCHAR2,
  p_high_value_number          IN VARCHAR2,
  p_interest_type_id           IN VARCHAR2,
  p_primary_interest_code_id   IN VARCHAR2,
  p_sec_interest_code_id       IN VARCHAR2,
  p_value1_id                  IN VARCHAR2,
  p_value2_id                  IN VARCHAR2,
  p_value3_id                  IN VARCHAR2,
  p_value4_id                  IN VARCHAR2,
  p_first_char                 IN VARCHAR2,
  p_currency_code              IN VARCHAR2,
  p_real_time_select           IN VARCHAR2,
  p_real_time_where            IN VARCHAR2,
  p_real_time_from             IN VARCHAR2,
  p_html_lov_sql1              IN VARCHAR2,
  p_html_lov_sql2              IN VARCHAR2,
  p_html_lov_sql3              IN VARCHAR2,
  p_display_sql1               IN VARCHAR2,
  p_display_sql2               IN VARCHAR2,
  p_display_sql3               IN VARCHAR2,
  p_hierarchy_type             IN VARCHAR2,
  p_equal_flag                 IN VARCHAR2,
  p_like_flag                  IN VARCHAR2,
  p_between_flag               IN VARCHAR2,
  retcode                      OUT NOCOPY VARCHAR2,
  errbuf                       OUT NOCOPY VARCHAR2) IS

  l_count            NUMBER;
  l_insert_stmt      VARCHAR2(2000);
  l_update_stmt      VARCHAR2(2000);
  l_qual_type_usg_id NUMBER;

  l_user_id          NUMBER;
  l_login_id         NUMBER;
  l_sysdate          DATE;

  l_success_flag     VARCHAR2(250);
  l_error_code       VARCHAR2(250);
BEGIN
  l_user_id  := FND_GLOBAL.USER_ID;
  l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
  l_sysdate  := sysdate;

  /* Check to see if the unique id is alreday present in jtf_seeded_qual_all_b */
  SELECT count(*)
  INTO   l_count
  FROM   jtf_seeded_qual_all_b
  WHERE  seeded_qual_id = p_seeded_qual_id;

  IF (l_count > 0) THEN
    retcode := 2;
    errbuf  := 'Unique ID alreday present in jtf_seeded_qual_all_b';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Check to see if the unique id is alreday present in jtf_qual_usgs_all */
  SELECT count(*)
  INTO   l_count
  FROM   jtf_qual_usgs_all
  WHERE  qual_usg_id = p_seeded_qual_id;

  IF (l_count > 0) THEN
    retcode := 2;
    errbuf  := 'Unique ID alreday present in jtf_qual_usgs_all';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* get the qual_type_usg_id corr to source and transaction type */
  BEGIN
    SELECT qual_type_usg_id
    INTO   l_qual_type_usg_id
    FROM   jtf_qual_type_usgs_all
    WHERE  source_id = p_source_id
    AND    qual_type_id = p_trans_type_id;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := 'Error in getting qual_type_usg_id from source_id and trans_type_id';
      RAISE FND_API.G_EXC_ERROR;
  END;

  /* get the attribute value insert and update statement */
  get_attr_val_stmt(
    p_comparison_operator        => p_comparison_operator,
    p_low_value_char             => p_low_value_char,
    p_high_value_char            => p_high_value_char,
    p_low_value_char_id          => p_low_value_char_id,
    p_low_value_number           => p_low_value_number,
    p_high_value_number          => p_high_value_number,
    p_interest_type_id           => p_interest_type_id,
    p_primary_interest_code_id   => p_primary_interest_code_id,
    p_secondary_interest_code_id => p_sec_interest_code_id,
    p_value1_id                  => p_value1_id,
    p_value2_id                  => p_value2_id,
    p_value3_id                  => p_value3_id,
    p_value4_id                  => p_value4_id,
    p_first_char                 => p_first_char,
    p_currency_code              => p_currency_code,
    p_update_stmt                => l_update_stmt,
    p_insert_stmt                => l_insert_stmt,
    retcode                      => retcode,
    errbuf                       => errbuf);

  IF (retcode <> 0) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Check if a qualifier exists with the same name */
  SELECT count(*)
  INTO   l_count
  FROM   jtf_seeded_qual_all_b
  WHERE  upper(name) = upper(p_name);

  IF (l_count > 0) THEN
    retcode := 2;
    errbuf  := 'Qualifier exist with the same name';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  INSERT INTO JTF_SEEDED_QUAL_ALL_B (
    SEEDED_QUAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    ORG_ID,
    SECURITY_GROUP_ID )
  VALUES (
    p_seeded_qual_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_id,
    l_login_id,
    p_name,
    p_description,
    null,
    null);

  INSERT INTO JTF_SEEDED_QUAL_ALL_TL (
    SEEDED_QUAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    NAME,
    DESCRIPTION,
    ORG_ID,
    SECURITY_GROUP_ID )
  VALUES (
    p_seeded_qual_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_id,
    l_login_id,
    p_language,
    p_language,
    p_name,
    p_description,
    null,
    null);

  INSERT INTO JTF_QUAL_USGS_ALL (
    QUAL_USG_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    APPLICATION_SHORT_NAME,
    SEEDED_QUAL_ID,
    QUAL_TYPE_USG_ID,
    ENABLED_FLAG,
    QUAL_COL1,
    QUAL_COL1_ALIAS,
    SEEDED_FLAG,
    CONVERT_TO_ID_FLAG,
    DISPLAY_TYPE,
    ORG_ID,
    ALIAS_RULE1,
    OP_EQL,
    OP_LIKE,
    OP_BETWEEN,
    OP_COMMON_WHERE,
    QUAL_RELATION_FACTOR,
    OBJECT_VERSION_NUMBER,
    COMPARISON_OPERATOR,
    LOW_VALUE_CHAR,
    HIGH_VALUE_CHAR,
    LOW_VALUE_CHAR_ID,
    LOW_VALUE_NUMBER,
    HIGH_VALUE_NUMBER,
    INTEREST_TYPE_ID,
    PRIMARY_INTEREST_CODE_ID,
    SECONDARY_INTEREST_CODE_ID,
    VALUE1_ID,
    VALUE2_ID,
    VALUE3_ID,
    VALUE4_ID,
    FIRST_CHAR,
    CURRENCY_CODE,
    REAL_TIME_SELECT,
    REAL_TIME_WHERE,
    REAL_TIME_FROM,
    UPDATE_ATTR_VAL_STMT,
    INSERT_ATTR_VAL_STMT,
    HTML_LOV_SQL1,
    HTML_LOV_SQL2,
    HTML_LOV_SQL3,
    DISPLAY_SQL1,
    DISPLAY_SQL2,
    DISPLAY_SQL3,
    HIERARCHY_TYPE,
    EQUAL_FLAG,
    LIKE_FLAG,
    BETWEEN_FLAG )
  VALUES (
    p_seeded_qual_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_id,
    l_login_id,
    'JTF',
    p_seeded_qual_id,
    l_qual_type_usg_id,
    p_enabled_flag,
    p_qual_col1,
    p_qual_col1,
    'N',
    p_convert_to_id_flag,
    p_display_type,
    -3113,
    p_alias_rule1,
    p_op_eql,
    p_op_like,
    p_op_between,
    p_op_common_where,
    p_qual_relation_factor,
    null,
    p_comparison_operator,
    p_low_value_char,
    p_high_value_char,
    p_low_value_char_id,
    p_low_value_number,
    p_high_value_number,
    p_interest_type_id,
    p_primary_interest_code_id,
    p_sec_interest_code_id,
    p_value1_id,
    p_value2_id,
    p_value3_id,
    p_value4_id,
    p_first_char,
    p_currency_code,
    p_real_time_select,
    p_real_time_where,
    p_real_time_from,
    l_update_stmt,
    l_insert_stmt,
    p_html_lov_sql1,
    p_html_lov_sql2,
    p_html_lov_sql3,
    p_display_sql1,
    p_display_sql2,
    p_display_sql3,
    p_hierarchy_type,
    p_equal_flag,
    p_like_flag,
    p_between_flag);

  /* if the qualifier is enabled , then add the columns to the denorm tables */
  IF (p_enabled_flag = 'Y') THEN
    JTY_MISC_UTILS_PKG.alter_qual_denorm_tables (
      x_success_flag               => l_success_flag,
      x_err_code                   => l_error_code,
      p_qual_usg_id		   => p_seeded_qual_id,
      p_comp_op_col                => p_comparison_operator,
      p_low_value_char_col         => p_low_value_char,
      p_high_value_char_col        => p_high_value_char,
      p_low_value_char_id_col      => p_low_value_char_id,
      p_low_value_number_col       => p_low_value_number,
      p_high_value_number_col      => p_high_value_number,
      p_interest_type_id_col       => p_interest_type_id,
      p_primary_int_code_id_col    => p_primary_interest_code_id,
      p_secondary_int_code_id_col  => p_sec_interest_code_id,
      p_value1_id_col              => p_value1_id,
      p_value2_id_col              => p_value2_id,
      p_value3_id_col              => p_value3_id,
      p_value4_id_col              => p_value4_id,
      p_first_char_col             => p_first_char,
      p_cur_code_col               => p_currency_code);

    IF (l_success_flag <> 'Y') THEN
      retcode := 2;
      errbuf  := 'Error adding columns to the denorm value tables';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  retcode := 0;
  errbuf  := null;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    NULL;

  WHEN OTHERS THEN
    retcode := 2;
    errbuf  := SQLCODE || ' : ' || SQLERRM;
END create_qual;
END JTY_CUST_QUAL_PKG;

/
