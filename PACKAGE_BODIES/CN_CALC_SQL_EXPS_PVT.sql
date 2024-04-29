--------------------------------------------------------
--  DDL for Package Body CN_CALC_SQL_EXPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SQL_EXPS_PVT" AS
  /*$Header: cnvcexpb.pls 120.10.12010000.4 2010/03/15 18:36:42 rnagired ship $*/
  g_pkg_name CONSTANT VARCHAR2(30) := 'CN_CALC_SQL_EXPS_PVT';

  g_original_node_type      VARCHAR2(2000);
  g_original_node_id        NUMBER;
  g_node_type               VARCHAR2(2000);
  g_current_id              NUMBER;
  g_level                   NUMBER;
  g_pe_arr                  num_tbl_type;

  PROCEDURE get_usage_info(
    p_exp_type_code IN            cn_calc_sql_exps.exp_type_code%TYPE
  , x_usage_info    OUT NOCOPY    VARCHAR2
  ) IS
  BEGIN
    x_usage_info  := fnd_message.get_string('CN', p_exp_type_code);
  EXCEPTION
    WHEN OTHERS THEN
      x_usage_info  := NULL;
  END get_usage_info;

  PROCEDURE classify_expression(
    p_org_id           IN            cn_calc_sql_exps.org_id%TYPE
  , p_sql_select       IN            VARCHAR2
  , p_sql_from         IN            VARCHAR2
  , p_piped_sql_select IN            VARCHAR2
  , p_piped_sql_from   IN            VARCHAR2
  , x_status           IN OUT NOCOPY cn_calc_sql_exps.status%TYPE
  , x_exp_type_code    IN OUT NOCOPY cn_calc_sql_exps.exp_type_code%TYPE
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_dummy   PLS_INTEGER;
    l_pos     PLS_INTEGER;
    l_alias   VARCHAR2(30);
    l_new_sql VARCHAR2(4100);
    l_pe_tbl  num_tbl_type;

    CURSOR external_table IS
      SELECT 1
        FROM cn_calc_ext_tables
       WHERE alias = l_alias
         AND (org_id = p_org_id)
         AND internal_table_id IN(
               SELECT object_id
                 FROM cn_objects
                WHERE (NAME = 'CN_COMMISSION_LINES' OR NAME = 'CN_COMMISSION_HEADERS')
                  AND object_type = 'TBL'
                  AND (org_id = p_org_id));
  BEGIN
    -- parse the expression
    IF LENGTH(p_sql_select) + LENGTH(p_sql_from) > 4000 THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_EXP_TOO_LONG');
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    DECLARE
      l_sql_statement VARCHAR2(4100);

      TYPE rc IS REF CURSOR;

      dummy_cur       rc;
      dummy_val       VARCHAR2(4000);
    BEGIN
      x_status         := 'VALID';
      l_sql_statement  :=
                         'select ' || p_sql_select || ' from ' || p_sql_from || ' where rownum < 1';
      l_sql_statement  :=
        REPLACE(
          REPLACE(REPLACE(l_sql_statement, 'p_commission_line_id', '100'), 'RateResult', '100')
        , 'ForecastAmount'
        , '100'
        );
      -- if we see anything like [PlanElementID]PE.[something], replace it
      -- with a constant 0
      parse_plan_elements(l_sql_statement, l_pe_tbl, l_new_sql);
      l_sql_statement  := l_new_sql;

      OPEN dummy_cur FOR l_sql_statement;
      FETCH dummy_cur INTO dummy_val;
      CLOSE dummy_cur;
    EXCEPTION
      WHEN OTHERS THEN
        x_status  := 'INVALID';

        IF dummy_cur%ISOPEN THEN
          CLOSE dummy_cur;
        END IF;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('CN', 'CN_INVALID_EXP');
          fnd_message.set_token('EXPRESSION', SQLERRM);
          fnd_msg_pub.ADD;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
        , p_encoded                    => fnd_api.g_false);
    END;

    IF (p_piped_sql_select IS NULL OR p_piped_sql_from IS NULL) THEN
      RETURN;
    END IF;

    -- check whether there is a column from cn_commission_lines/headers
    -- or if there is a plan element
    IF (
           INSTR(p_piped_sql_select, 'CL.', 1, 1) = 1
        OR INSTR(p_piped_sql_select, '|CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '(CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '+CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '-CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '*CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '/CL.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'CH.', 1, 1) = 1
        OR INSTR(p_piped_sql_select, '|CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '(CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '+CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '-CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '*CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, '/CH.', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'p_commission_line_id', 1, 1) > 0
       ) THEN
      x_exp_type_code  := 'Y';
    ELSE
      x_exp_type_code  := 'N';
    END IF;

    -- check whether there is any column from a table which is mapped to cn_commission_lines/headers.
    -- if there is any such column, the expression is considered trx_based.
    IF (INSTR(x_exp_type_code, 'N', 1, 1) = 1) THEN
      l_pos  := 1;

      LOOP
        l_pos    := INSTR(p_piped_sql_from, ' ', l_pos, 1);

        IF (l_pos = 0) THEN
          EXIT;
        END IF;

        l_pos    := l_pos + 1;
        l_alias  := SUBSTR(p_piped_sql_from, l_pos, INSTR(p_piped_sql_from, '|', l_pos, 1) - l_pos);

        OPEN external_table;
        FETCH external_table INTO l_dummy;
        CLOSE external_table;

        IF (l_dummy = 1) THEN
          x_exp_type_code  := 'Y';
          EXIT;
        END IF;
      END LOOP;
    END IF;

    -- check whether there is group function in the sql statement
    IF (
           INSTR(p_piped_sql_select, 'AVG(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'COUNT(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'MIN(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'MAX(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'STDDEV(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'SUM(', 1, 1) > 0
        OR INSTR(p_piped_sql_select, 'VARIANCE(', 1, 1) > 0
       ) THEN
      x_exp_type_code  := x_exp_type_code || 'Y';
    ELSE
      x_exp_type_code  := x_exp_type_code || 'N';
    END IF;

    -- check whether RateResult is used
    l_pos  := INSTR(p_piped_sql_select, 'RateResult', 1, 1);

    IF (l_pos > 0) THEN
      x_exp_type_code  := x_exp_type_code || 'Y';
    ELSE
      x_exp_type_code  := x_exp_type_code || 'N';
    END IF;

    -- check whether RateResult is the first component and is used only once
    IF (l_pos = 1 AND INSTR(p_piped_sql_select, 'RateResult', 11, 1) = 0) THEN
      x_exp_type_code  := x_exp_type_code || 'Y';
    ELSE
      -- deal with unnecessary leading and ending parentheses
      x_exp_type_code  := x_exp_type_code || 'N';
    END IF;

    -- check whether there is embedded formula
    IF (INSTR(p_piped_sql_select, 'p_commission_line_id', 1, 1) > 0) THEN
      x_exp_type_code  := x_exp_type_code || 'Y';
    ELSE
      x_exp_type_code  := x_exp_type_code || 'N';
    END IF;

    -- check whether ForecastAmount is used
    IF (INSTR(p_piped_sql_select, 'ForecastAmount', 1, 1) > 0) THEN
      x_exp_type_code  := x_exp_type_code || 'Y';
    ELSE
      x_exp_type_code  := x_exp_type_code || 'N';
    END IF;

    -- check whether the embedded formulas have the following flag setting:
    -- trx_group_code = 'INDIVIDUAL', cumulative_flag = 'N' and itd_flag = 'N'
    -- and threshold_all_tier_flag = 'N'
    NULL;   -- to be added later

    -- convert x_exp_type_code to something that is easy to understand
    IF (x_exp_type_code IN('YNYYYN', 'YNYYNN')) THEN
      x_exp_type_code  := 'IO';
    ELSIF(x_exp_type_code IN('YNYNYN', 'YNYNNN')) THEN
      x_exp_type_code  := 'IO_ITDN';
    ELSIF(x_exp_type_code IN('YYYYYN', 'YYYYNN', 'YYYNYN', 'YYYNNN')) THEN
      x_exp_type_code  := 'GO';
    ELSIF(x_exp_type_code IN('YYNNYN', 'YYNNNN')) THEN
      x_exp_type_code  := 'GIGO';
    ELSIF(x_exp_type_code = 'YNNNYN') THEN
      x_exp_type_code  := 'IIIO';
    ELSIF(x_exp_type_code = 'YNNNNN') THEN
      x_exp_type_code  := 'IIIOIPGP';
    ELSIF(x_exp_type_code IN('NNYYNY', 'NNYNNY')) THEN
      x_exp_type_code  := 'FO';
    ELSIF(x_exp_type_code IN('NNYYNN', 'NNYNNN')) THEN
      x_exp_type_code  := 'IOGOBOFO';
    ELSIF(x_exp_type_code = 'NNNNNY') THEN
      x_exp_type_code  := 'FIFO';
    ELSIF(x_exp_type_code = 'NNNNNN') THEN
      x_exp_type_code  := 'IRIOIPGOGPBIBOBPFRFO';
    ELSE
      x_exp_type_code  := NULL;
    END IF;

    -- check whether it can be used in dynamic rate tables also
    IF (x_exp_type_code = 'IRIOIPGOGPBIBOBPFRFO') THEN
      -- if all the tables used are only from cn_quotas_v, cn_period_quotas, cn_srp_quota_assigns,
      -- and cn_srp_period_quotas, then it can be used in dynamic dimension tiers also
      IF (p_piped_sql_from = 'DUAL|' OR p_piped_sql_from = 'SYS.DUAL|') THEN
        x_exp_type_code  := x_exp_type_code || 'DDT';
      ELSE
        l_pos  := 1;

        LOOP
          l_pos    := INSTR(p_piped_sql_from, ' ', l_pos, 1);

          IF (l_pos = 0) THEN
            x_exp_type_code  := x_exp_type_code || 'DDT';
            EXIT;
          END IF;

          l_pos    := l_pos + 1;
          l_alias  := SUBSTR(p_piped_sql_from, l_pos, INSTR(p_piped_sql_from, '|', l_pos, 1) - l_pos);

          IF (l_alias NOT IN('CQ', 'CPQ', 'CSQA', 'CSPQ')) THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END IF;

    -- see if expression includes plan element references
    IF l_pe_tbl.COUNT > 0 THEN
      IF x_exp_type_code IN('FO', 'FIFO') THEN
        -- forecast and DDT expressions cannot be used with plan elements
        x_exp_type_code  := NULL;
      ELSIF x_exp_type_code IN('IRIOIPGOGPBIBOBPFRFODDT', 'IRIOIPGOGPBIBOBPFRFO') THEN
        x_exp_type_code  := 'IIIOIPGOGPBIBOBP';
      ELSIF x_exp_type_code = 'IOGOBOFO' THEN
        x_exp_type_code  := 'IOGOBO';
      END IF;
    END IF;
  END classify_expression;

  -- Start of comments
  --    API name        : Create_Expression
  --    Type            : Private.
  --    Function        :
  --    Pre-reqs        : None.
  --    Parameters      :
  --    IN              : p_api_version         IN      NUMBER       Required
  --                      p_init_msg_list       IN      VARCHAR2     Optional
  --                        Default = FND_API.G_FALSE
  --                      p_commit              IN      VARCHAR2     Optional
  --                        Default = FND_API.G_FALSE
  --                      p_validation_level    IN      NUMBER       Optional
  --                        Default = FND_API.G_VALID_LEVEL_FULL
  --                      p_name                IN      VARCHAR2     Required
  --                      p_description         IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_expression_disp     IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_sql_select          IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_sql_from            IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_expression_disp IN    VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_sql_select    IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_sql_from      IN      VARCHAR2     Optional
  --                        Default = null
  --    OUT             : x_calc_sql_exp_id     OUT     NUMBER
  --                      x_exp_type_code       OUT     VARCHAR2(30)
  --                      x_status              OUT     VARCHAR2(30)
  --                      x_return_status       OUT     VARCHAR2(1)
  --                      x_msg_count           OUT     NUMBER
  --                      x_msg_data            OUT     VARCHAR2(4000)
  --    Version :         Current version       1.0
  --                      Initial version       1.0
  --
  --    Notes           : Create SQL expressions that will be used in calculation.
  --                      1) Validate the expression and return the result in x_status (Valid or Invalid)
  --                      2) Classify expressions into sub types for formula validation and dynamic rate table validation
  --                      3) If there are embedded expressions, record the embedding relations in cn_calc_edges
  --
  -- End of comments
  PROCEDURE create_expression(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_org_id                IN            cn_calc_sql_exps.org_id%TYPE
  , p_name                  IN            cn_calc_sql_exps.NAME%TYPE
  , p_description           IN            cn_calc_sql_exps.description%TYPE := NULL
  , p_expression_disp       IN            VARCHAR2 := NULL
  ,   -- CLOBs
    p_sql_select            IN            VARCHAR2 := NULL
  , p_sql_from              IN            VARCHAR2 := NULL
  , p_piped_expression_disp IN            VARCHAR2 := NULL
  , p_piped_sql_select      IN            VARCHAR2 := NULL
  , p_piped_sql_from        IN            VARCHAR2 := NULL
  , x_calc_sql_exp_id       IN OUT NOCOPY cn_calc_sql_exps.calc_sql_exp_id%TYPE
  , x_exp_type_code         OUT NOCOPY    cn_calc_sql_exps.exp_type_code%TYPE
  , x_status                OUT NOCOPY    cn_calc_sql_exps.status%TYPE
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number OUT NOCOPY    cn_calc_sql_exps.object_version_number%TYPE
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)                            := 'Create_Expression';
    l_api_version CONSTANT NUMBER                                  := 1.0;
    l_prompt               cn_lookups.meaning%TYPE;
    l_dummy                PLS_INTEGER;
    l_disp_start           PLS_INTEGER;
    l_select_start         PLS_INTEGER;
    l_disp_end             PLS_INTEGER;
    l_select_end           PLS_INTEGER;
    l_token                VARCHAR2(4000);
    l_calc_formula_id      cn_calc_formulas.calc_formula_id%TYPE;

    CURSOR exp_exists IS
      SELECT 1
        FROM cn_calc_sql_exps
       WHERE NAME = p_name AND org_id = p_org_id;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT create_expression;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    IF (p_name IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        l_prompt  := cn_api.get_lkup_meaning('EXP_NAME', 'CN_PROMPTS');
        fnd_message.set_name('CN', 'CN_CANNOT_NULL');
        fnd_message.set_token('OBJ_NAME', l_prompt);
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    OPEN exp_exists;
    FETCH exp_exists INTO l_dummy;
    CLOSE exp_exists;

    IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_NAME_NOT_UNIQUE');
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- make sure name isn't too long
    IF LENGTH(p_name) > 30 THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_NAME_TOO_LONG');
        fnd_message.set_token('LENGTH', 30);
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- parse the expression and classify it into sub types
    classify_expression(
      p_org_id                     => p_org_id
    , p_sql_select                 => p_sql_select
    , p_sql_from                   => p_sql_from
    , p_piped_sql_select           => p_piped_sql_select
    , p_piped_sql_from             => p_piped_sql_from
    , x_status                     => x_status
    , x_exp_type_code              => x_exp_type_code
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );
    -- call table handler to create the expression
    cn_calc_sql_exps_pkg.insert_row(
      x_org_id                     => p_org_id
    , x_calc_sql_exp_id            => x_calc_sql_exp_id
    , x_name                       => p_name
    , x_description                => p_description
    , x_status                     => x_status
    , x_exp_type_code              => x_exp_type_code
    , x_expression_disp            => p_expression_disp
    , x_sql_select                 => p_sql_select
    , x_sql_from                   => p_sql_from
    , x_piped_sql_select           => p_piped_sql_select
    , x_piped_sql_from             => p_piped_sql_from
    , x_piped_expression_disp      => p_piped_expression_disp
    , x_object_version_number      => x_object_version_number
    );
    -- record calc edges
    l_disp_start     := 1;
    l_select_start   := 1;

    LOOP
      l_disp_end      := INSTR(p_piped_expression_disp, '|', l_disp_start, 1);

      IF (l_disp_end IS NULL OR l_disp_end = 0) THEN
        EXIT;
      END IF;

      l_token         := SUBSTR(p_piped_expression_disp, l_disp_start, l_disp_end - l_disp_start);
      l_disp_start    := l_disp_end + 1;
      l_select_end    := INSTR(p_piped_sql_select, '|', l_select_start, 1);

      -- if the corresponding piped select part is in parenthesis, it is an embedded expression
      IF (
              INSTR(p_piped_sql_select, '(', l_select_start, 1) = l_select_start
          AND (l_select_end - l_select_start) > 1
         ) THEN
        -- insert calc edges (calc edges has no table handler)
        INSERT INTO cn_calc_edges
                    (
                     org_id
                   , calc_edge_id
                   , parent_id
                   , child_id
                   , edge_type
                   , creation_date
                   , created_by
                   , last_update_login
                   , last_update_date
                   , last_updated_by
                    )
          SELECT org_id
               , cn_calc_edges_s.NEXTVAL
               , x_calc_sql_exp_id
               , calc_sql_exp_id
               , 'EE'
               , SYSDATE
               , fnd_global.user_id
               , fnd_global.login_id
               , SYSDATE
               , fnd_global.user_id
            FROM cn_calc_sql_exps
           WHERE NAME = l_token
 			AND org_id=p_org_id;
      ELSIF(INSTR(p_piped_sql_select, 'cn_formula', l_select_start, 1) = l_select_start) THEN
        l_dummy            := INSTR(p_piped_sql_select, '_', l_select_start, 2) + 1;
        l_calc_formula_id  :=
          TO_NUMBER(
            SUBSTR(p_piped_sql_select, l_dummy, INSTR(p_piped_sql_select, '_', l_dummy, 1) - l_dummy)
          );

        INSERT INTO cn_calc_edges
                    (
                     org_id
                   , calc_edge_id
                   , parent_id
                   , child_id
                   , edge_type
                   , creation_date
                   , created_by
                   , last_update_login
                   , last_update_date
                   , last_updated_by
                    )
             VALUES (
                     p_org_id
                   , cn_calc_edges_s.NEXTVAL
                   , x_calc_sql_exp_id
                   , l_calc_formula_id
                   , 'FE'
                   , SYSDATE
                   , fnd_global.user_id
                   , fnd_global.login_id
                   , SYSDATE
                   , fnd_global.user_id
                    );
      END IF;

      l_select_start  := l_select_end + 1;
    END LOOP;

    -- End of API body.

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_expression;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      ROLLBACK TO create_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END create_expression;

  -- Start of comments
  --    API name        : Update_Expressions
  --    Type            : Private.
  --    Function        :
  --    Pre-reqs        : None.
  --    Parameters      :
  --    IN              : p_api_version         IN      NUMBER       Required
  --                      p_init_msg_list       IN      VARCHAR2     Optional
  --                        Default = FND_API.G_FALSE
  --                      p_commit              IN      VARCHAR2     Optional
  --                        Default = FND_API.G_FALSE
  --                      p_validation_level    IN      NUMBER       Optional
  --                        Default = FND_API.G_VALID_LEVEL_FULL
  --                      p_update_parent_also  IN      VARCHAR2     Optional
  --                        Default = FND_API.G_FALSE
  --                      p_calc_sql_exp_id     IN      NUMBER       Required
  --                      p_name                IN      VARCHAR2     Required
  --                      p_description         IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_expression_disp     IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_sql_select          IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_sql_from            IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_expression_disp IN    VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_sql_select    IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_piped_sql_from      IN      VARCHAR2     Optional
  --                        Default = null
  --                      p_ovn                 IN      NUMBER       Required
  --    OUT             : x_exp_type_code       OUT     VARCHAR2(30)
  --                      x_status              OUT     VARCHAR2(30)
  --                      x_return_status       OUT     VARCHAR2(1)
  --                      x_msg_count           OUT     NUMBER
  --                      x_msg_data            OUT     VARCHAR2(4000)
  --    Version :         Current version       1.0
  --                      Initial version       1.0
  --
  --    Notes           : Update SQL expressions that will be used in calculation.
  --                      1) validate the expression and return the result in x_status (Valid or Invalid)
  --                      2) re-classify expressions into sub types for formula validation and dynamic rate table validation
  --                      3) adjust the corresponding embedding relations in cn_calc_edges
  --                      4) if the expression is used, update the parent expressions, formulas accordingly
  --
  -- End of comments
  PROCEDURE update_expression(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_update_parent_also    IN            VARCHAR2 := fnd_api.g_false
  , p_org_id                IN            cn_calc_sql_exps.org_id%TYPE
  , p_calc_sql_exp_id       IN            cn_calc_sql_exps.calc_sql_exp_id%TYPE
  , p_name                  IN            cn_calc_sql_exps.NAME%TYPE
  , p_description           IN            cn_calc_sql_exps.description%TYPE := NULL
  , p_expression_disp       IN            VARCHAR2 := NULL
  ,   -- CLOBs
    p_sql_select            IN            VARCHAR2 := NULL
  , p_sql_from              IN            VARCHAR2 := NULL
  , p_piped_expression_disp IN            VARCHAR2 := NULL
  , p_piped_sql_select      IN            VARCHAR2 := NULL
  , p_piped_sql_from        IN            VARCHAR2 := NULL
  , p_ovn                   IN OUT NOCOPY cn_calc_sql_exps.object_version_number%TYPE
  , x_exp_type_code         OUT NOCOPY    cn_calc_sql_exps.exp_type_code%TYPE
  , x_status                OUT NOCOPY    cn_calc_sql_exps.status%TYPE
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)                            := 'Update_Expression';
    l_api_version CONSTANT NUMBER                                  := 1.0;
    l_prompt               cn_lookups.meaning%TYPE;
    l_dummy                PLS_INTEGER;
    l_disp_start           PLS_INTEGER;
    l_select_start         PLS_INTEGER;
    l_disp_end             PLS_INTEGER;
    l_select_end           PLS_INTEGER;
    l_token                VARCHAR2(4000);
    l_calc_formula_id      cn_calc_formulas.calc_formula_id%TYPE;
    l_exp_names            VARCHAR2(4000)                          := '|';
    l_formula_ids          VARCHAR2(4000)                          := '|';

    CURSOR parent_exist IS
      SELECT 1
        FROM DUAL
       WHERE (EXISTS(SELECT 1
                       FROM cn_calc_edges
                      WHERE child_id = p_calc_sql_exp_id AND edge_type = 'EE'))
          OR (
              EXISTS(SELECT 1
                       FROM cn_calc_formulas
                      WHERE perf_measure_id = p_calc_sql_exp_id OR output_exp_id = p_calc_sql_exp_id)
             )
          OR (
              EXISTS(
                  SELECT 1
                    FROM cn_formula_inputs
                   WHERE calc_sql_exp_id = p_calc_sql_exp_id
                         OR f_calc_sql_exp_id = p_calc_sql_exp_id)
             )
          OR (EXISTS(SELECT 1
                       FROM cn_rate_dim_tiers
                      WHERE min_exp_id = p_calc_sql_exp_id OR max_exp_id = p_calc_sql_exp_id));

    CURSOR exp_exists IS
      SELECT 1
        FROM cn_calc_sql_exps
       WHERE NAME = p_name AND org_id = p_org_id AND calc_sql_exp_id <> p_calc_sql_exp_id;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_expression;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    IF (p_name IS NULL) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        l_prompt  := cn_api.get_lkup_meaning('EXP_NAME', 'CN_PROMPTS');
        fnd_message.set_name('CN', 'CN_CANNOT_NULL');
        fnd_message.set_token('OBJ_NAME', l_prompt);
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    OPEN exp_exists;
    FETCH exp_exists INTO l_dummy;
    CLOSE exp_exists;

    IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_NAME_NOT_UNIQUE');
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- see if expression is in use
    OPEN parent_exist;
    FETCH parent_exist INTO l_dummy;
    CLOSE parent_exist;

    IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_EXP_IN_USE');
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- parse the expression and classify it into sub types
    classify_expression(
      p_org_id                     => p_org_id
    , p_sql_select                 => p_sql_select
    , p_sql_from                   => p_sql_from
    , p_piped_sql_select           => p_piped_sql_select
    , p_piped_sql_from             => p_piped_sql_from
    , x_status                     => x_status
    , x_exp_type_code              => x_exp_type_code
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );
    -- check ovn
    cn_calc_sql_exps_pkg.lock_row(p_calc_sql_exp_id, p_ovn);
    -- do update
    cn_calc_sql_exps_pkg.update_row(
      x_org_id                     => p_org_id
    , x_calc_sql_exp_id            => p_calc_sql_exp_id
    , x_name                       => p_name
    , x_description                => p_description
    , x_status                     => x_status
    , x_exp_type_code              => x_exp_type_code
    , x_expression_disp            => p_expression_disp
    , x_sql_select                 => p_sql_select
    , x_sql_from                   => p_sql_from
    , x_piped_sql_select           => p_piped_sql_select
    , x_piped_sql_from             => p_piped_sql_from
    , x_piped_expression_disp      => p_piped_expression_disp
    , x_object_version_number      => p_ovn
    );
    -- insert new calc edges
    l_disp_start     := 1;
    l_select_start   := 1;

    LOOP
      l_disp_end      := INSTR(p_piped_expression_disp, '|', l_disp_start, 1);

      IF (l_disp_end IS NULL OR l_disp_end = 0) THEN
        EXIT;
      END IF;

      l_token         := SUBSTR(p_piped_expression_disp, l_disp_start, l_disp_end - l_disp_start);
      l_disp_start    := l_disp_end + 1;
      l_select_end    := INSTR(p_piped_sql_select, '|', l_select_start, 1);

      -- if the corresponding piped select part is in parenthesis, it is an embedded expression
      IF (
              INSTR(p_piped_sql_select, '(', l_select_start, 1) = l_select_start
          AND (l_select_end - l_select_start) > 1
         ) THEN
        l_exp_names  := l_exp_names || l_token || '|';

        INSERT INTO cn_calc_edges
                    (
                     org_id
                   , calc_edge_id
                   , parent_id
                   , child_id
                   , edge_type
                   , creation_date
                   , created_by
                   , last_update_login
                   , last_update_date
                   , last_updated_by
                    )
          SELECT org_id
               , cn_calc_edges_s.NEXTVAL
               , p_calc_sql_exp_id
               , calc_sql_exp_id
               , 'EE'
               , SYSDATE
               , fnd_global.user_id
               , fnd_global.login_id
               , SYSDATE
               , fnd_global.user_id
            FROM cn_calc_sql_exps
           WHERE NAME = l_token
           AND   org_id= p_org_id
             AND NOT EXISTS(
                   SELECT 1
                     FROM cn_calc_edges
                    WHERE parent_id = p_calc_sql_exp_id
                      AND child_id = (SELECT calc_sql_exp_id
                                        FROM cn_calc_sql_exps
									   WHERE NAME = l_token AND org_id = p_org_id AND edge_type = 'EE'));
      ELSIF(INSTR(p_piped_sql_select, 'cn_formula', l_select_start, 1) = l_select_start) THEN
        l_dummy            := INSTR(p_piped_sql_select, '_', l_select_start, 2) + 1;
        l_calc_formula_id  :=
          TO_NUMBER(
            SUBSTR(p_piped_sql_select, l_dummy, INSTR(p_piped_sql_select, '_', l_dummy, 1) - l_dummy)
          );
        l_formula_ids      := l_formula_ids || l_calc_formula_id || '|';

        INSERT INTO cn_calc_edges
                    (
                     org_id
                   , calc_edge_id
                   , parent_id
                   , child_id
                   , edge_type
                   , creation_date
                   , created_by
                   , last_update_login
                   , last_update_date
                   , last_updated_by
                    )
          SELECT p_org_id
               , cn_calc_edges_s.NEXTVAL
               , p_calc_sql_exp_id
               , l_calc_formula_id
               , 'FE'
               , SYSDATE
               , fnd_global.user_id
               , fnd_global.login_id
               , SYSDATE
               , fnd_global.user_id
            FROM DUAL
           WHERE NOT EXISTS(
                   SELECT 1
                     FROM cn_calc_edges
                    WHERE parent_id = p_calc_sql_exp_id
                      AND child_id = l_calc_formula_id
                      AND edge_type = 'FE');
      END IF;

      l_select_start  := l_select_end + 1;
    END LOOP;

    -- delete obsolete calc edges
    --IF (l_formula_ids <> '|') THEN
    DELETE FROM cn_calc_edges
          WHERE parent_id = p_calc_sql_exp_id
            AND INSTR(l_formula_ids, '|' || child_id || '|', 1, 1) = 0
            AND edge_type = 'FE';

    --END IF;

    --IF (l_exp_names <> '|') THEN
    DELETE FROM cn_calc_edges a
          WHERE a.parent_id = p_calc_sql_exp_id
            AND a.edge_type = 'EE'
            AND NOT EXISTS(
                  SELECT 1
                    FROM cn_calc_sql_exps b
                   WHERE a.child_id = b.calc_sql_exp_id
                     AND INSTR(l_exp_names, '|' || b.NAME || '|', 1, 1) > 0);

    --END IF;

    -- update parent expressions and formulas also
    IF (fnd_api.to_boolean(p_update_parent_also)) THEN
      NULL;
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_expression;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      ROLLBACK TO update_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END update_expression;

  -- Start of comments
  --      API name        : Delete_Expression
  --      Type            : Private.
  --      Function        :
  --      Pre-reqs        : None.
  --      Parameters      :
  --      IN              : p_api_version        IN      NUMBER       Required
  --                        p_init_msg_list      IN      VARCHAR2     Optional
  --                          Default = FND_API.G_FALSE
  --                        p_commit             IN      VARCHAR2     Optional
  --                          Default = FND_API.G_FALSE
  --                        p_validation_level   IN      NUMBER       Optional
  --                          Default = FND_API.G_VALID_LEVEL_FULL
  --                        p_calc_sql_exp_id    IN      NUMBER
  --      OUT             : x_return_status      OUT     VARCHAR2(1)
  --                        x_msg_count          OUT     NUMBER
  --                        x_msg_data           OUT     VARCHAR2(4000)
  --      Version :         Current version      1.0
  --                        Initial version      1.0
  --
  --      Notes           : Delete an expression
  --                        1) if it is used, it can not be deleted
  --                        2) delete the embedding relations in cn_calc_edges if there is any
  --
  -- End of comments
  PROCEDURE delete_expression(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2 := fnd_api.g_false
  , p_commit           IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level IN            NUMBER := fnd_api.g_valid_level_full
  , p_calc_sql_exp_id  IN            cn_calc_sql_exps.calc_sql_exp_id%TYPE
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Expression';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_dummy                PLS_INTEGER;

    CURSOR parent_exist IS
      SELECT 1
        FROM DUAL
       WHERE (EXISTS(SELECT 1
                       FROM cn_calc_edges
                      WHERE child_id = p_calc_sql_exp_id AND edge_type = 'EE'))
          OR (
              EXISTS(SELECT 1
                       FROM cn_calc_formulas
                      WHERE perf_measure_id = p_calc_sql_exp_id OR output_exp_id = p_calc_sql_exp_id)
             )
          OR (
              EXISTS(
                  SELECT 1
                    FROM cn_formula_inputs
                   WHERE calc_sql_exp_id = p_calc_sql_exp_id
                         OR f_calc_sql_exp_id = p_calc_sql_exp_id)
             )
          OR (EXISTS(SELECT 1
                       FROM cn_rate_dim_tiers
                      WHERE min_exp_id = p_calc_sql_exp_id OR max_exp_id = p_calc_sql_exp_id));
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_expression;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    OPEN parent_exist;
    FETCH parent_exist INTO l_dummy;
    CLOSE parent_exist;

    IF (l_dummy = 1) THEN
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)) THEN
        fnd_message.set_name('CN', 'CN_EXP_IN_USE');
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    cn_calc_sql_exps_pkg.delete_row(x_calc_sql_exp_id => p_calc_sql_exp_id);

    DELETE FROM cn_calc_edges e
          WHERE edge_type IN('EE', 'FE') AND NOT EXISTS(SELECT 1
                                                          FROM cn_calc_sql_exps
                                                         WHERE calc_sql_exp_id = e.parent_id);

    -- End of API body.

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_expression;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      ROLLBACK TO delete_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END delete_expression;

  /*-- Start of comments
  --      API name        : Get_Parent_Expressions
  --      Type            : Private.
  --      Function        :
  --      Pre-reqs        : None.
  --      Parameters      :
  --      IN              : p_api_version        IN      NUMBER       Required
  --                        p_init_msg_list      IN      VARCHAR2     Optional
  --                          Default = FND_API.G_FALSE
  --                        p_commit             IN      VARCHAR2     Optional
  --                          Default = FND_API.G_FALSE
  --                        p_validation_level   IN      NUMBER       Optional
  --                          Default = FND_API.G_VALID_LEVEL_FULL
  --                        p_calc_sql_exp_id    IN      NUMBER
  --      OUT             : x_parents_tbl        OUT     expression_tbl_type
  --                        x_return_status      OUT     VARCHAR2(1)
  --                        x_msg_count          OUT     NUMBER
  --                        x_msg_data           OUT     VARCHAR2(4000)
  --      Version :         Current version      1.0
  --                        Initial version      1.0
  --
  --      Notes           : Get parent expressions if there is any
  --
  -- End of comments
  PROCEDURE Get_Parent_Expressions
    (p_api_version                  IN      NUMBER                          ,
     p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
     p_commit                       IN      VARCHAR2 := FND_API.G_FALSE     ,
     p_validation_level             IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL ,
     p_calc_sql_exp_id              IN      CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
     x_parents_tbl                  OUT NOCOPY     parent_expression_tbl_type      ,
     x_return_status                OUT NOCOPY     VARCHAR2                        ,
     x_msg_count                    OUT NOCOPY     NUMBER                          ,
     x_msg_data                     OUT NOCOPY     VARCHAR2                        )
    IS
       l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Parent_Expressions';
       l_api_version               CONSTANT NUMBER       := 1.0;

       i                           pls_integer           := 0;

       -- names of parent performance measures and formulas and dimensions
       CURSOR parent_names IS
    SELECT name
      FROM cn_calc_sql_exps
      WHERE calc_sql_exp_id IN (SELECT parent_id
              FROM cn_calc_edges
              CONNECT BY child_id = PRIOR parent_id
              AND edge_type = 'EE'
              START WITH child_id = p_calc_sql_exp_id
              AND edge_type = 'EE')
      UNION ALL
      SELECT name
      FROM cn_rate_dimensions
      WHERE rate_dimension_id in (SELECT rate_dimension_id
                  FROM cn_rate_dim_tiers
                 WHERE min_exp_id = p_calc_sql_exp_id
                OR max_exp_id = p_calc_sql_exp_id)
      UNION ALL
      SELECT name
      FROM cn_calc_formulas
      WHERE perf_measure_id = p_calc_sql_exp_id
      OR output_exp_id = p_calc_sql_exp_id
      OR f_output_exp_id = p_calc_sql_exp_id
      OR (calc_formula_id IN (SELECT calc_formula_id FROM cn_formula_inputs
            WHERE calc_sql_exp_id = p_calc_sql_exp_id
            OR  f_calc_sql_exp_id = p_calc_sql_exp_id));

  BEGIN
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call
       (l_api_version           ,
        p_api_version           ,
        l_api_name              ,
        G_PKG_NAME )
       THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
     FOR parent_name IN parent_names LOOP
        x_parents_tbl(i) := parent_name.name;
        i := i + 1;
     END LOOP;

     -- End of API body.

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.count_and_get
       (p_count                 =>      x_msg_count             ,
        p_data                  =>      x_msg_data              ,
        p_encoded               =>      FND_API.G_FALSE         );
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.count_and_get
    (p_count                 =>      x_msg_count             ,
     p_data                  =>      x_msg_data              ,
     p_encoded               =>      FND_API.G_FALSE         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.count_and_get
    (p_count                 =>      x_msg_count             ,
     p_data                  =>      x_msg_data              ,
     p_encoded               =>      FND_API.G_FALSE         );
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.check_msg_level
    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
     FND_MSG_PUB.add_exc_msg
       (G_PKG_NAME          ,
        l_api_name           );
        END IF;
        FND_MSG_PUB.count_and_get
    (p_count                 =>      x_msg_count             ,
     p_data                  =>      x_msg_data              ,
     p_encoded               =>      FND_API.G_FALSE         );
  END Get_Parent_Expressions; */

  /* PROCEDURE get_expr_summary
    (p_first                        IN      NUMBER,
     p_last                         IN      NUMBER,
     p_srch_name                    IN      VARCHAR2 := '%',
     x_total_rows                   OUT NOCOPY     NUMBER,
     x_result_tbl                   OUT NOCOPY     calc_expression_tbl_type) IS

    l_count                         NUMBER := 0;
    l_srch_name                     varchar2(31) := upper(p_srch_name) || '%';

    CURSOR get_rows IS
    select calc_sql_exp_id, name, description, status, exp_type_code
      from cn_calc_sql_exps
     where upper(name) like l_srch_name
     order by 2;
    CURSOR count_rows IS select count(1) from cn_calc_sql_exps
     where upper(name) like l_srch_name;

  BEGIN
     open  count_rows;
     fetch count_rows into x_total_rows;
     close count_rows;
     for c in get_rows loop
        l_count := l_count + 1;
        if l_count >= p_first then
     x_result_tbl(l_count) := c;  -- record copy ok because of %types
        end if;
        if l_count = p_last then
     exit;
        end if;
     end loop;
  END get_expr_summary; */

  /* PROCEDURE get_expr_detail
    (p_calc_sql_exp_id              IN     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
     x_name                         OUT NOCOPY    CN_CALC_SQL_EXPS.NAME%TYPE,
     x_description                  OUT NOCOPY    CN_CALC_SQL_EXPS.DESCRIPTION%TYPE,
     x_status                       OUT NOCOPY    CN_CALC_SQL_EXPS.STATUS%TYPE,
     x_exp_type_code                OUT NOCOPY    CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
     x_expression_disp              OUT NOCOPY    VARCHAR2, -- CLOBs
     x_sql_select                   OUT NOCOPY    VARCHAR2,
     x_sql_from                     OUT NOCOPY    VARCHAR2,
     x_piped_sql_select             OUT NOCOPY    VARCHAR2,
     x_piped_sql_from               OUT NOCOPY    VARCHAR2,
     x_piped_expression_disp        OUT NOCOPY    VARCHAR2,
     x_ovn                          OUT NOCOPY    CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE) IS

     CURSOR get_data IS
        select name, description, status, exp_type_code,
         dbms_lob.substr(expression_disp),
         dbms_lob.substr(sql_select),
           dbms_lob.substr(sql_from),
         dbms_lob.substr(piped_sql_select),
         dbms_lob.substr(piped_sql_from),
         dbms_lob.substr(piped_expression_disp),
         object_version_number
    from cn_calc_sql_exps where calc_sql_exp_id = p_calc_sql_exp_id;
  BEGIN
     OPEN  get_data;
     FETCH get_data INTO x_name, x_description, x_status, x_exp_type_code,
           x_expression_disp, x_sql_select, x_sql_from,
           x_piped_sql_select, x_piped_sql_from, x_piped_expression_disp, x_ovn;
     CLOSE get_data;
  END get_expr_detail; */

  /* FUNCTION add_tree_node(node_value                     VARCHAR2,
             node_label                     VARCHAR2,
             parent_node_value              VARCHAR2,
             element                        VARCHAR2)
    RETURN expr_type_rec_type IS
     l_rec   expr_type_rec_type;
  BEGIN
     l_rec.node_value        := node_value;
     l_rec.node_label        := nvl(node_label, node_value);
     l_rec.parent_node_value := parent_node_value;
     l_rec.element           := element;
     return l_rec;
  END add_tree_node; */

  /* PROCEDURE get_type_tree
    (x_types                        OUT NOCOPY    expr_type_tbl_type) IS
      cursor osc_elements is
      select user_name, name, alias, object_id
        from cn_objects
       where calc_eligible_flag = 'Y'
         and object_type in ('TBL', 'VIEW')
         and user_name is not null
         and object_id < 0
         and name like 'CN%'
         and alias is not null
    order by user_name;

      cursor table_columns(p_table_id number) is
      select user_name, name
        from cn_objects
       where table_id = p_table_id
         and calc_formula_flag = 'Y'
         and object_type = 'COL'
    order by user_name;

      cursor calc_expressions is
      select calc_sql_exp_id, name, dbms_lob.substr(sql_select) node_value
        from cn_calc_sql_exps
       where status = 'VALID'
         and dbms_lob.getlength(sql_select) < 3999
    order by name;

      cursor calc_formulas is
      select name, 'cn_formula_' || abs(calc_formula_id) || '_' || abs(org_id) ||
             '_pkg.get_result(p_commission_line_id)' node_value
        from cn_calc_formulas
       where formula_status = 'COMPLETE'
         and cumulative_flag = 'N'
         and trx_group_code = 'INDIVIDUAL'
         and itd_flag = 'N'
         and formula_type = 'C'
    order by name;

      cursor ext_elements is
      select user_name, name, alias, object_id
        from cn_objects
       where calc_eligible_flag = 'Y'
         and object_type in ('TBL', 'VIEW')
         and user_name is not null
         and object_id > 0
    order by user_name;

      cursor plan_elements is
      select quota_id, name
        from cn_quotas_v
    order by name;



     TYPE vt is table of varchar2(30);
     num_functions vt := vt('ABS', 'CEIL', 'EXP', 'FLOOR', 'GREATEST', 'LEAST',
          'MOD', 'POWER', 'ROUND', 'SIGN', 'SQRT', 'TO_NUMBER', 'TRUNC');
     grp_functions vt := vt('AVG', 'COUNT', 'MAX', 'MIN', 'STDDEV',
          'SUM', 'VARIANCE');
     oth_functions vt := vt('DECODE', 'NVL');
     pe_columns    vt := vt('TARGET_AMOUNT', 'COMMISSION_PAYED_PTD','ITD_TARGET',
          'PERIOD_PAYMENT', 'ITD_PAYMENT',
          'COMMISSION_PAYED_ITD', 'INPUT_ACHIEVED_PTD',
          'INPUT_ACHIEVED_ITD', 'PERF_ACHIEVED_PTD',
          'PERF_ACHIEVED_ITD');
     l_count       number := 0;
  BEGIN
     -- add nodes of calculation value tree in DFS order
     x_types(l_count) :=
       add_tree_node('OSC_ELEMENTS',
         cn_api.get_lkup_meaning('OSC_ELEMENTS', 'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     for t in osc_elements loop
        x_types(l_count) :=
    add_tree_node(t.name || '|' ||t.alias,t.user_name,'OSC_ELEMENTS',null);
        l_count := l_count + 1;
        for c in table_columns(t.object_id) loop
     x_types(l_count) :=
       add_tree_node(t.user_name || '.' || c.user_name,c.user_name, t.name,
         t.alias || '.' || c.name);
     l_count := l_count + 1;
        end loop;
     end loop;

     x_types(l_count) :=
       add_tree_node('EXPRESSIONS',
         cn_api.get_lkup_meaning('EXPRESSIONS', 'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     for e in calc_expressions loop
        x_types(l_count) :=
    add_tree_node(e.name, e.name, 'EXPRESSIONS', '(' ||e.node_value|| ')');
        l_count := l_count + 1;
     end loop;

     x_types(l_count) :=
       add_tree_node('FORMULAS',
         cn_api.get_lkup_meaning('FORMULAS', 'EXPRESSION_TYPE'),null,
         null);
     l_count := l_count + 1;
     for f in calc_formulas loop
        x_types(l_count) :=
    add_tree_node(f.name, f.name, 'FORMULAS', f.node_value);
        l_count := l_count + 1;
     end loop;

     x_types(l_count) :=
       add_tree_node('EXTERNAL_ELEMENTS',
         cn_api.get_lkup_meaning('EXTERNAL_ELEMENTS',
               'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     for x in ext_elements loop
        x_types(l_count) :=
    add_tree_node(x.name || '|' || x.alias, x.user_name,
            'EXTERNAL_ELEMENTS',
            null);
        l_count := l_count + 1;
        for c in table_columns(x.object_id) loop
     x_types(l_count) :=
       add_tree_node(x.user_name || '.' || c.user_name,c.user_name, x.name,
         x.alias || '.' || c.name);
     l_count := l_count + 1;
        end loop;
     end loop;

     x_types(l_count) :=
       add_tree_node('SQL_FUNCTIONS', cn_api.get_lkup_meaning('SQL_FUNCTIONS',
                    'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     x_types(l_count) :=
       add_tree_node('NUMBER_FUNCTIONS',
         cn_api.get_lkup_meaning('NUMBER_FUNCTIONS',
               'EXPRESSION_TYPE'),
         'SQL_FUNCTIONS', null);
     l_count := l_count + 1;
     for i in num_functions.first..num_functions.last loop
        x_types(l_count) :=
    add_tree_node(num_functions(i) || '(', num_functions(i),
            'NUMBER_FUNCTIONS', num_functions(i) || '(');
        l_count := l_count + 1;
     end loop;
     x_types(l_count) :=
       add_tree_node('GROUP_FUNCTIONS',
         cn_api.get_lkup_meaning('GROUP_FUNCTIONS',
               'EXPRESSION_TYPE'),
         'SQL_FUNCTIONS', null);
     l_count := l_count + 1;
     for i in grp_functions.first..grp_functions.last loop
        x_types(l_count) :=
    add_tree_node(grp_functions(i) || '(', grp_functions(i) || '()',
            'GROUP_FUNCTIONS', grp_functions(i) || '(');
        l_count := l_count + 1;
     end loop;

     x_types(l_count) :=
       add_tree_node('OTHER_FUNCTIONS',
         cn_api.get_lkup_meaning('OTHERS', 'EXPRESSION_TYPE'),
         'SQL_FUNCTIONS', null);
     l_count := l_count + 1;
     for i in oth_functions.first..oth_functions.last loop
        x_types(l_count) :=
    add_tree_node(oth_functions(i) || '(', oth_functions(i) || '()',
            'OTHER_FUNCTIONS',
            oth_functions(i) || '(');
        l_count := l_count + 1;
     end loop;

  -- Previously Commented out - START

     x_types(l_count) :=
       add_tree_node('PLAN_ELEMENTS',
         cn_api.get_lkup_meaning('PLAN_ELTS', 'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     for i in plan_elements loop
        x_types(l_count) :=
    add_tree_node(i.quota_id || 'PE', i.name, 'PLAN_ELEMENTS', null);
        l_count := l_count + 1;
        for j in pe_columns.first..pe_columns.last loop
     x_types(l_count) :=
       add_tree_node(i.name || '.' || pe_columns(j),
         i.name || '.' || pe_columns(j),
         i.quota_id || 'PE',
         '(' || i.quota_id || 'PE.' || pe_columns(j) || ')');
     l_count := l_count + 1;
        end loop;
     end loop;

  -- Previously Commented out - END

     x_types(l_count) :=
       add_tree_node('OTHERS', cn_api.get_lkup_meaning('OTHERS',
                   'EXPRESSION_TYPE'),
         null, null);
     l_count := l_count + 1;
     x_types(l_count) :=
       add_tree_node(cn_api.get_lkup_meaning('RATE_TABLE_RESULT',
               'EXPRESSION_TYPE'),
         cn_api.get_lkup_meaning('RATE_TABLE_RESULT',
               'EXPRESSION_TYPE'),
         'OTHERS', 'RateResult');
     l_count := l_count + 1;
     x_types(l_count) :=
       add_tree_node(cn_api.get_lkup_meaning('FORECAST_AMOUNT',
               'EXPRESSION_TYPE'),
         cn_api.get_lkup_meaning('FORECAST_AMOUNT',
               'EXPRESSION_TYPE'),
         'OTHERS', 'ForecastAmount');
     l_count := l_count + 1;
  END get_type_tree; */

  -- parse a sql select statement looking for included plan elements
  -- of the form (1234PE.COLUMN_NAME).  if any are found, include them in
  -- the x_plan_elt_tbl and provide a parsed version of the sql select.
  PROCEDURE parse_plan_elements(
    p_sql_select        IN            VARCHAR2
  , x_plan_elt_tbl      OUT NOCOPY    num_tbl_type
  , x_parsed_sql_select OUT NOCOPY    VARCHAR2
  ) IS
    s        VARCHAR2(1);   -- character before 'PE'
    pe       VARCHAR2(30);   -- plan element ID
    i        NUMBER       := 0;   -- index vars
    ix       NUMBER;
    openpar  NUMBER;   -- looking for parenthesis
    clspar   NUMBER;
    CONTINUE BOOLEAN      := TRUE;
  BEGIN
    ix                   := 0;
    x_parsed_sql_select  := p_sql_select;

    WHILE CONTINUE LOOP
      i  := INSTR(x_parsed_sql_select, 'PE.', i + 1);

      IF i = 0 THEN
        CONTINUE  := FALSE;
      ELSE
        -- see if character before 'PE' is a number...
        -- if so then it's a plan element
        s  := SUBSTR(x_parsed_sql_select, i - 1, 1);

        IF s BETWEEN '0' AND '9' THEN
          -- get surrounding parenthesis
          openpar              := INSTR(x_parsed_sql_select, '(', i - LENGTH(x_parsed_sql_select));
          clspar               := INSTR(x_parsed_sql_select, ')', i);
          pe                   := SUBSTR(x_parsed_sql_select, openpar + 1, i - openpar - 1);
          x_parsed_sql_select  :=
               SUBSTR(x_parsed_sql_select, 1, openpar) || '0'
               || SUBSTR(x_parsed_sql_select, clspar);
          ix                   := ix + 1;
          x_plan_elt_tbl(ix)   := pe;
        END IF;
      END IF;
    END LOOP;
  END parse_plan_elements;

  -- private procedure used in get_dependent_plan_elts
  PROCEDURE dfs(
    p_original_node_type               VARCHAR2
  , p_original_node_id                 NUMBER
  , p_node_type                        VARCHAR2
  , p_current_id                       NUMBER
  , p_level                            NUMBER
  , p_pe_arr             IN OUT NOCOPY num_tbl_type
  ) IS
    CURSOR get_formula_id IS
      SELECT calc_formula_id
        FROM cn_quotas_v
       WHERE quota_id = p_current_id;

    CURSOR get_exp_ids IS
      SELECT ccse.calc_sql_exp_id
        FROM cn_calc_sql_exps ccse, cn_calc_formulas ccf, cn_formula_inputs cfi
       WHERE (
                 (ccse.calc_sql_exp_id = ccf.perf_measure_id)
              OR (ccse.calc_sql_exp_id = ccf.output_exp_id)
              OR (ccse.calc_sql_exp_id = cfi.calc_sql_exp_id)
              OR (ccse.calc_sql_exp_id = cfi.f_calc_sql_exp_id)
             )
         AND cfi.calc_formula_id = ccf.calc_formula_id
         AND ccf.calc_formula_id = p_current_id;

    CURSOR get_child_edges IS
      SELECT child_id
        FROM cn_calc_edges
       WHERE edge_type = 'FE' AND parent_id = p_current_id;

    CURSOR get_sql_sel IS
      SELECT DBMS_LOB.SUBSTR(sql_select)
        FROM cn_calc_sql_exps
       WHERE calc_sql_exp_id = p_current_id;

    l_current_id NUMBER;
    l_pe_tbl     cn_calc_sql_exps_pvt.num_tbl_type;
    l_sql_sel    VARCHAR2(4000);
    l_junk       VARCHAR2(4000);
  BEGIN
    IF p_node_type = p_original_node_type AND p_current_id = p_original_node_id AND p_level > 0 THEN
      fnd_message.set_name('CN', 'CN_PE_CANNOT_REF_ITSEF');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_node_type = 'P' THEN
      IF p_level > 0 THEN
        -- don't return the root as a dependence
        p_pe_arr(p_pe_arr.COUNT)  := p_current_id;
      END IF;

      l_current_id  := NULL;

      OPEN get_formula_id;
      FETCH get_formula_id INTO l_current_id;
      CLOSE get_formula_id;

      IF l_current_id IS NOT NULL THEN
        dfs(p_original_node_type, p_original_node_id, 'F', l_current_id, p_level + 1, p_pe_arr);
      END IF;
    ELSIF p_node_type = 'F' THEN
      FOR x IN get_exp_ids LOOP
        dfs(p_original_node_type, p_original_node_id, 'E', x.calc_sql_exp_id, p_level + 1, p_pe_arr);
      END LOOP;
    ELSIF p_node_type = 'E' THEN
      OPEN get_sql_sel;
      FETCH get_sql_sel INTO l_sql_sel;
      CLOSE get_sql_sel;

      cn_calc_sql_exps_pvt.parse_plan_elements(l_sql_sel, l_pe_tbl, l_junk);

      FOR x IN 1 .. l_pe_tbl.COUNT LOOP
        dfs(p_original_node_type, p_original_node_id, 'P', l_pe_tbl(x), p_level + 1, p_pe_arr);
      END LOOP;

      FOR x IN get_child_edges LOOP
        dfs(p_original_node_type, p_original_node_id, 'F', x.child_id, p_level + 1, p_pe_arr);
      END LOOP;
    END IF;
  END dfs;

  -- given a plan element, formula, or expression, determine all the plan
  -- elements referenced directly or indirectly
  -- pass in a node type (formula=F, plan element=P, expression=E), and the ID
  PROCEDURE get_dependent_plan_elts(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2 := fnd_api.g_false
  , p_commit           IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level IN            NUMBER := fnd_api.g_valid_level_full
  , p_node_type        IN            VARCHAR2
  , p_node_id          IN            NUMBER
  , x_plan_elt_id_tbl  OUT NOCOPY    num_tbl_type
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'get_dependent_plan_elts';
    l_api_version CONSTANT NUMBER       := 1.0;
  BEGIN
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- API body
    dfs(p_node_type, p_node_id, p_node_type, p_node_id, 0, x_plan_elt_id_tbl);

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END get_dependent_plan_elts;

  -- private procedure used in get_parent_plan_elts
  PROCEDURE dfs2(
    p_original_node_type               VARCHAR2
  , p_original_node_id                 NUMBER
  , p_node_type                        VARCHAR2
  , p_current_id                       NUMBER
  , p_level                            NUMBER
  , p_pe_arr             IN OUT NOCOPY num_tbl_type
  ) IS
    CURSOR get_quota_ids IS
      SELECT quota_id
        FROM cn_quotas_v
       WHERE calc_formula_id = p_current_id;

    CURSOR get_exp_ids IS
      SELECT calc_sql_exp_id
        FROM cn_calc_sql_exps
       WHERE DBMS_LOB.SUBSTR(sql_select) LIKE '%(' || p_current_id || 'PE.%';

    CURSOR get_formulas IS
      SELECT calc_formula_id
        FROM cn_formula_inputs
       WHERE calc_sql_exp_id = p_current_id OR f_calc_sql_exp_id = p_current_id
      UNION ALL
      SELECT calc_formula_id
        FROM cn_calc_formulas
       WHERE output_exp_id = p_current_id
          OR f_output_exp_id = p_current_id
          OR perf_measure_id = p_current_id;

    CURSOR get_parent_exps IS
      SELECT parent_id exp_id
        FROM cn_calc_edges
       WHERE edge_type = 'FE' AND child_id = p_current_id;

    l_current_id NUMBER;
    l_pe_tbl     cn_calc_sql_exps_pvt.num_tbl_type;
  BEGIN
    IF p_node_type = p_original_node_type AND p_current_id = p_original_node_id AND p_level > 0 THEN
      fnd_message.set_name('CN', 'CN_PE_CANNOT_REF_ITSEF');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_node_type = g_node_type AND
       p_original_node_type = g_original_node_type AND
       p_current_id = g_current_id AND
       p_original_node_id = g_original_node_id AND
       p_level = g_level THEN
       p_pe_arr := g_pe_arr;
   ELSE
      IF p_node_type = 'P' THEN
        -- Don't return the root as a dependence
        IF p_level > 0 THEN
          -- Dont add Duplicate Entries
          FOR i IN 0..p_pe_arr.COUNT LOOP
            -- If we have reached the end of the table, then we can add our element
            IF i = p_pe_arr.COUNT THEN
              p_pe_arr(p_pe_arr.COUNT)  := p_current_id;
              EXIT;
            END IF;

            EXIT WHEN p_pe_arr(i) = p_current_id;
          END LOOP;
        END IF;

        FOR x IN get_exp_ids LOOP
          dfs2(p_original_node_type, p_original_node_id, 'E', x.calc_sql_exp_id, p_level + 1, p_pe_arr);
        END LOOP;
      ELSIF p_node_type = 'E' THEN
        FOR f IN get_formulas LOOP
          dfs2(p_original_node_type, p_original_node_id, 'F', f.calc_formula_id, p_level + 1, p_pe_arr);
        END LOOP;
      ELSIF p_node_type = 'F' THEN
        FOR x IN get_parent_exps LOOP
          dfs2(p_original_node_type, p_original_node_id, 'E', x.exp_id, p_level + 1, p_pe_arr);
        END LOOP;

        FOR x IN get_quota_ids LOOP
          dfs2(p_original_node_type, p_original_node_id, 'P', x.quota_id, p_level + 1, p_pe_arr);
        END LOOP;
      END IF;
      g_original_node_type      := p_original_node_type;
      g_original_node_id        := p_original_node_id;
      g_node_type               := p_node_type;
      g_current_id              := p_current_id;
      g_level                   := p_level;
      g_pe_arr                  := p_pe_arr;
    END IF;
  END dfs2;

  -- given a plan element, formula, or expression, determine all the plan
  -- elements that reference it directly or indirectly
  -- pass in a node type (formula=F, plan element=P, expression=E), and the ID
  PROCEDURE get_parent_plan_elts(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2 := fnd_api.g_false
  , p_commit           IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level IN            NUMBER := fnd_api.g_valid_level_full
  , p_node_type        IN            VARCHAR2
  , p_node_id          IN            NUMBER
  , x_plan_elt_id_tbl  OUT NOCOPY    num_tbl_type
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'get_parent_plan_elts';
    l_api_version CONSTANT NUMBER       := 1.0;
  BEGIN
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- API body
    dfs2(p_node_type, p_node_id, p_node_type, p_node_id, 0, x_plan_elt_id_tbl);

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END get_parent_plan_elts;

  PROCEDURE parse_sql_select(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2 := fnd_api.g_false
  , p_commit           IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level IN            NUMBER := fnd_api.g_valid_level_full
  , p_sql_select       IN OUT NOCOPY VARCHAR2
  , x_piped_sql_select OUT NOCOPY    VARCHAR2
  , x_expr_disp        OUT NOCOPY    VARCHAR2
  , x_piped_expr_disp  OUT NOCOPY    VARCHAR2
  , x_sql_from         OUT NOCOPY    VARCHAR2
  , x_piped_sql_from   OUT NOCOPY    VARCHAR2
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_sql_select_left      VARCHAR2(4000) := p_sql_select;
    l_ix                   NUMBER;
    l_seg                  VARCHAR2(4000);
    l_ix2                  NUMBER;
    l_seg2                 VARCHAR2(4000);
    l_disp_seg             VARCHAR2(4000);
    l_table_id             NUMBER;
    l_table_name           VARCHAR2(80);

    TYPE vt IS TABLE OF VARCHAR2(80);

    sel_pieces             vt
      := vt(
          'RateResult'
        , 'ForecastAmount'
        , 'ABS('
        , 'CEIL('
        , 'EXP('
        , 'FLOOR('
        , 'GREATEST('
        , 'LEAST('
        , 'MOD('
        , 'POWER('
        , 'ROUND('
        , 'SIGN('
        , 'SQRT('
        , 'TO_NUMBER('
        , 'TRUNC('
        , 'AVG('
        , 'COUNT('
        , 'MAX('
        , 'MIN('
        , 'STDDEV('
        , 'SUM('
        , 'VARIANCE('
        , 'DECODE('
        , 'NVL('
        , '*'
        , '/'
        , '.'
        , '-'
        , '+'
        , ','
        , ')'
        , '('
        );
    disp_pieces            vt             := sel_pieces;   -- almost the same
    opers                  vt             := vt('/', '+', '*', '-', ' ', ',', ')');
    ct                     NUMBER         := 0;
    success                BOOLEAN;
    found_num              BOOLEAN;
    l_api_name    CONSTANT VARCHAR2(30)   := 'parse_sql_select';
    l_api_version CONSTANT NUMBER         := 1.0;

    CURSOR get_formula_name(l_segment IN VARCHAR2) IS
      SELECT NAME
        FROM cn_calc_formulas
       WHERE    'cn_formula_'
             || calc_formula_id
             || '_'
             || org_id
             || '_pkg.get_result(p_commission_line_id)' = l_segment;

    CURSOR get_pe_name(l_segment IN VARCHAR2) IS
      SELECT NAME
        FROM cn_quotas_v
       WHERE quota_id || 'PE' = l_segment;

    CURSOR get_tbl(l_segment IN VARCHAR2) IS
      SELECT user_name
           , object_id
           , NAME
        FROM cn_objects
       WHERE calc_eligible_flag = 'Y'
         AND object_type IN('TBL', 'VIEW')
         AND user_name IS NOT NULL
         AND alias = l_segment;

    CURSOR get_col(l_segment IN VARCHAR2, l_table_id IN NUMBER) IS
      SELECT user_name
        FROM cn_objects
       WHERE table_id = l_table_id
         AND calc_formula_flag = 'Y'
         AND object_type = 'COL'
         AND user_name IS NOT NULL
         AND NAME = l_segment;

    CURSOR get_user_funcs IS
      SELECT object_name
        FROM user_objects
       WHERE object_type = 'FUNCTION' AND status = 'VALID';
  BEGIN
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- translate RateResult and ForecastAmount
    disp_pieces(1)   := cn_api.get_lkup_meaning('RATE_TABLE_RESULT', 'EXPRESSION_TYPE');
    disp_pieces(2)   := cn_api.get_lkup_meaning('FORECAST_AMOUNT', 'EXPRESSION_TYPE');

    -- Bug 2295522
    -- set p_sql_select to upper
    SELECT UPPER(p_sql_select)
      INTO l_sql_select_left
      FROM DUAL;

    -- next build piped sql select
    LOOP
      ct       := ct + 1;   -- defend against infinite loop
      success  := FALSE;

      -- look for plan element
      IF SUBSTR(l_sql_select_left, 1, 1) = '(' THEN
        -- get close parenthesis
        l_ix        := INSTR(l_sql_select_left, '.');
        l_seg       := SUBSTR(l_sql_select_left, 2, l_ix - 2);
        l_ix2       := INSTR(l_sql_select_left, ')');
        l_seg2      := SUBSTR(l_sql_select_left, l_ix + 1, l_ix2 - l_ix - 1);
        l_disp_seg  := NULL;

        OPEN get_pe_name(l_seg);   -- get display name of PE
        FETCH get_pe_name INTO l_disp_seg;
        CLOSE get_pe_name;

        IF l_disp_seg IS NOT NULL THEN
          l_sql_select_left   := SUBSTR(l_sql_select_left, l_ix2 + 1);
          x_piped_sql_select  := x_piped_sql_select || '(' || l_seg || '.' || l_seg2 || ')|';
          x_piped_expr_disp   := x_piped_expr_disp || l_disp_seg || '.' || l_seg2 || '|';
          success             := TRUE;
        END IF;
      END IF;

      -- look for quoted constant
      IF SUBSTR(l_sql_select_left, 1, 1) = '''' AND success = FALSE THEN
        -- get close quote
        l_ix                := INSTR(l_sql_select_left, '''', 2);

        IF l_ix = 0 THEN
          fnd_message.set_name('CN', 'CN_SQL_SELECT_PARSE_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        x_piped_sql_select  := x_piped_sql_select || SUBSTR(l_sql_select_left, 1, l_ix) || '|';
        x_piped_expr_disp   := x_piped_expr_disp || SUBSTR(l_sql_select_left, 1, l_ix) || '|';
        l_sql_select_left   := SUBSTR(l_sql_select_left, l_ix + 1);
        success             := TRUE;
      END IF;

      -- look for numeric value
      IF success = FALSE THEN
        found_num  := FALSE;

        WHILE SUBSTR(l_sql_select_left, 1, 1) BETWEEN '0' AND '9'
          OR SUBSTR(l_sql_select_left, 1, 1) = '.' LOOP
          x_piped_sql_select  := x_piped_sql_select || SUBSTR(l_sql_select_left, 1, 1);
          x_piped_expr_disp   := x_piped_expr_disp || SUBSTR(l_sql_select_left, 1, 1);
          l_sql_select_left   := SUBSTR(l_sql_select_left, 2);
          found_num           := TRUE;
          success             := TRUE;
        END LOOP;

        IF found_num THEN
          x_piped_expr_disp   := x_piped_expr_disp || '|';
          x_piped_sql_select  := x_piped_sql_select || '|';
        END IF;
      END IF;

      -- look for canned value
      IF success = FALSE THEN
        FOR i IN 1 .. sel_pieces.COUNT LOOP
          IF SUBSTR(l_sql_select_left, 1, LENGTH(sel_pieces(i))) = UPPER(sel_pieces(i)) THEN
            l_sql_select_left   := SUBSTR(l_sql_select_left, LENGTH(sel_pieces(i)) + 1);
            x_piped_sql_select  := x_piped_sql_select || sel_pieces(i) || '|';
            x_piped_expr_disp   := x_piped_expr_disp || disp_pieces(i) || '|';
            success             := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      -- look for formula value
      IF success = FALSE AND SUBSTR(l_sql_select_left, 1, 10) = 'cn_formula' THEN
        -- look for p_commission_line_id
        l_ix                := INSTR(l_sql_select_left, 'p_commission_line_id');
        l_seg               := SUBSTR(l_sql_select_left, 1, l_ix + 20);
        l_sql_select_left   := SUBSTR(l_sql_select_left, l_ix + 21);
        x_piped_sql_select  := x_piped_sql_select || l_seg || '|';

        OPEN get_formula_name(l_seg);
        FETCH get_formula_name INTO l_seg;
        CLOSE get_formula_name;

        x_piped_expr_disp   := x_piped_expr_disp || l_seg || '|';
        success             := TRUE;
      END IF;

      -- look for user-defined function
      IF success = FALSE THEN
        FOR f IN get_user_funcs LOOP
          IF SUBSTR(l_sql_select_left, 1, LENGTH(f.object_name) + 1) = UPPER(f.object_name) || '(' THEN
            -- found a function
            x_piped_sql_select  := x_piped_sql_select || f.object_name || '(|';
            x_piped_expr_disp   := x_piped_expr_disp || f.object_name || '(|';
            l_sql_select_left   := SUBSTR(l_sql_select_left, LENGTH(f.object_name) + 2);
            success             := TRUE;
          END IF;
        END LOOP;
      END IF;

      -- trim spaces
      IF success = FALSE AND SUBSTR(l_sql_select_left, 1, 1) = ' ' THEN
        l_sql_select_left  := SUBSTR(l_sql_select_left, 2);
        success            := TRUE;
      END IF;

      -- now look for elements like [something].[something else]
      IF success = FALSE AND l_sql_select_left IS NOT NULL THEN
        -- look for dot and table alias
        l_ix                := INSTR(l_sql_select_left, '.');
        l_seg               := SUBSTR(l_sql_select_left, 1, l_ix - 1);   -- the alias
        l_disp_seg          := NULL;

        OPEN get_tbl(l_seg);
        FETCH get_tbl INTO l_disp_seg, l_table_id, l_table_name;
        CLOSE get_tbl;

        IF l_disp_seg IS NULL THEN
          fnd_message.set_name('CN', 'CN_SQL_SELECT_PARSE_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- add to sql from
        IF (x_piped_sql_from IS NULL OR INSTR(x_piped_sql_from, l_table_name) = 0) THEN
          x_piped_sql_from  := x_piped_sql_from || l_table_name || ' ' || l_seg || '|';   -- don't include the same table twice
        END IF;

        x_piped_sql_select  := x_piped_sql_select || l_seg;
        x_piped_expr_disp   := x_piped_expr_disp || l_disp_seg;
        l_sql_select_left   := SUBSTR(l_sql_select_left, l_ix + 1);
        l_ix                := LENGTH(l_sql_select_left) + 1;

        FOR c IN 1 .. opers.COUNT LOOP
          IF INSTR(l_sql_select_left, opers(c)) BETWEEN 1 AND l_ix THEN
            l_ix  := INSTR(l_sql_select_left, opers(c));
          END IF;
        END LOOP;

        l_seg               := SUBSTR(l_sql_select_left, 1, l_ix - 1);
        l_disp_seg          := NULL;

        OPEN get_col(l_seg, l_table_id);
        FETCH get_col INTO l_disp_seg;
        CLOSE get_col;

        IF l_disp_seg IS NULL THEN
          fnd_message.set_name('CN', 'CN_SQL_SELECT_PARSE_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        x_piped_sql_select  := x_piped_sql_select || '.' || l_seg || '|';
        x_piped_expr_disp   := x_piped_expr_disp || '.' || l_disp_seg || '|';
        l_sql_select_left   := SUBSTR(l_sql_select_left, l_ix);
        success             := TRUE;
      END IF;

      IF ct = 400 THEN
        fnd_message.set_name('CN', 'CN_SQL_SELECT_PARSE_ERR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF success = FALSE THEN
        EXIT;
      END IF;   -- we're done
    END LOOP;

    x_expr_disp      := REPLACE(x_piped_expr_disp, '|', '');
    p_sql_select     := REPLACE(x_piped_sql_select, '|', '');

    IF x_piped_sql_from IS NULL THEN
      x_piped_sql_from  := 'DUAL|';
    END IF;

    x_sql_from       := REPLACE(SUBSTR(x_piped_sql_from, 1, LENGTH(x_piped_sql_from) - 1), '|'
                       , ', ');   -- trim last comma

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END parse_sql_select;

  PROCEDURE import(
    errbuf          OUT NOCOPY    VARCHAR2
  , retcode         OUT NOCOPY    VARCHAR2
  , p_imp_header_id IN            NUMBER
  , p_org_id        IN            NUMBER
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)                                  := 'import';
    l_status_code           cn_imp_lines.status_code%TYPE                 := 'STAGE';
    l_imp_header            cn_imp_headers_pvt.imp_headers_rec_type
                                                       := cn_imp_headers_pvt.g_miss_imp_headers_rec;
    l_process_audit_id      cn_process_audits.process_audit_id%TYPE;
    err_num                 NUMBER;
    l_msg_count             NUMBER                                        := 0;
    l_exp_id                NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_processed_row         NUMBER                                        := 0;
    l_failed_row            NUMBER                                        := 0;
    l_message               VARCHAR2(4000);
    l_app_sn                VARCHAR2(30);
    l_error_code            VARCHAR2(4000);
    l_header_list           VARCHAR2(4000);
    l_sql_stmt              VARCHAR2(4000);
    l_return_status         VARCHAR2(1);
    l_type_code             cn_calc_sql_exps.exp_type_code%TYPE;
    my_message              VARCHAR2(4000);
    l_status                VARCHAR2(30);
    l_sql_from              VARCHAR2(4000);
    l_piped_sql_from        VARCHAR2(4000);
    l_piped_sql_select      VARCHAR2(4000);
    l_piped_expr_disp       VARCHAR2(4000);
    l_expr_disp             VARCHAR2(4000);
    l_object_version_number cn_calc_sql_exps.object_version_number%TYPE;

    CURSOR get_api_recs IS
      SELECT *
        FROM cn_exp_api_imp_v
       WHERE imp_header_id = p_imp_header_id AND status_code = l_status_code;

    l_api_rec               get_api_recs%ROWTYPE;
  BEGIN
    retcode                  := 0;
    l_object_version_number  := 0;

    -- Get imp_header info
    SELECT NAME
         , status_code
         , server_flag
         , imp_map_id
         , source_column_num
         , import_type_code
      INTO l_imp_header.NAME
         , l_imp_header.status_code
         , l_imp_header.server_flag
         , l_imp_header.imp_map_id
         , l_imp_header.source_column_num
         , l_imp_header.import_type_code
      FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

    -- open process audit batch
    cn_message_pkg.begin_batch(
      x_process_type               => l_imp_header.import_type_code
    , x_parent_proc_audit_id       => p_imp_header_id
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => NULL
    , p_org_id                     => p_org_id
    );
    cn_message_pkg.WRITE(
      p_message_text =>    'CALCEXPIMP: Start Transfer Data. imp_header_id = ' || TO_CHAR(p_imp_header_id)
    , p_message_type => 'MILESTONE'
    );
    -- Get source column name list and target column dynamic sql statement
    cn_import_pvt.build_error_rec(p_imp_header_id => p_imp_header_id
    , x_header_list                => l_header_list, x_sql_stmt => l_sql_stmt);

    OPEN get_api_recs;

    LOOP
      FETCH get_api_recs INTO l_api_rec;

      EXIT WHEN get_api_recs%NOTFOUND;

      BEGIN
        l_processed_row  := l_processed_row + 1;
        l_error_code     := NULL;   -- reset error code
        cn_message_pkg.WRITE(
          p_message_text               =>    'CALCEXPIMP:Record '
                                          || TO_CHAR(l_processed_row)
                                          || ' imp_line_id = '
                                          || TO_CHAR(l_api_rec.imp_line_id)
        , p_message_type               => 'DEBUG'
        );

        -- -------- Checking for all required fields ----------------- --
        -- Check required field
        IF l_api_rec.expression_name IS NULL OR l_api_rec.sql_select IS NULL THEN
          l_failed_row  := l_failed_row + 1;
          l_error_code  := 'CN_IMP_MISS_REQUIRED';
          l_message     := fnd_message.get_string('CN', 'CN_IMP_MISS_REQUIRED');
          cn_import_pvt.update_imp_lines(
            p_imp_line_id                => l_api_rec.imp_line_id
          , p_status_code                => 'FAIL'
          , p_error_code                 => l_error_code
          );
          cn_import_pvt.update_imp_headers(
            p_imp_header_id              => p_imp_header_id
          , p_status_code                => 'IMPORT_FAIL'
          , p_failed_row                 => l_failed_row
          );
          cn_message_pkg.WRITE(
            p_message_text               => 'Record ' || TO_CHAR(l_processed_row) || ':'
                                            || l_message
          , p_message_type               => 'ERROR'
          );
          cn_import_pvt.write_error_rec(
            p_imp_header_id              => p_imp_header_id
          , p_imp_line_id                => l_api_rec.imp_line_id
          , p_header_list                => l_header_list
          , p_sql_stmt                   => l_sql_stmt
          );
          retcode       := 2;
          errbuf        := l_message;
          GOTO end_loop;
        END IF;

        -- build components of record
        parse_sql_select(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_true
        , p_sql_select                 => l_api_rec.sql_select
        , x_piped_sql_select           => l_piped_sql_select
        , x_expr_disp                  => l_expr_disp
        , x_piped_expr_disp            => l_piped_expr_disp
        , x_sql_from                   => l_sql_from
        , x_piped_sql_from             => l_piped_sql_from
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        );

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          -- do import here
          l_exp_id  := NULL;
          create_expression(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_org_id                     => p_org_id
          , p_name                       => l_api_rec.expression_name
          , p_description                => l_api_rec.description
          , p_expression_disp            => l_expr_disp
          , p_sql_select                 => l_api_rec.sql_select
          , p_sql_from                   => l_sql_from
          , p_piped_expression_disp      => l_piped_expr_disp
          , p_piped_sql_select           => l_piped_sql_select
          , p_piped_sql_from             => l_piped_sql_from
          , x_calc_sql_exp_id            => l_exp_id
          , x_exp_type_code              => l_type_code
          , x_status                     => l_status
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_object_version_number      => l_object_version_number
          );

          IF l_return_status = fnd_api.g_ret_sts_success THEN
            -- update attribute values appropriately since API doesn't
            -- handle flexfields
            UPDATE cn_calc_sql_exps
               SET attribute_category = l_api_rec.attribute_category
                 , attribute1 = l_api_rec.attribute1
                 , attribute2 = l_api_rec.attribute2
                 , attribute3 = l_api_rec.attribute3
                 , attribute4 = l_api_rec.attribute4
                 , attribute5 = l_api_rec.attribute5
                 , attribute6 = l_api_rec.attribute6
                 , attribute7 = l_api_rec.attribute7
                 , attribute8 = l_api_rec.attribute8
                 , attribute9 = l_api_rec.attribute9
                 , attribute10 = l_api_rec.attribute10
                 , attribute11 = l_api_rec.attribute11
                 , attribute12 = l_api_rec.attribute12
                 , attribute13 = l_api_rec.attribute13
                 , attribute14 = l_api_rec.attribute14
                 , attribute15 = l_api_rec.attribute15
             WHERE calc_sql_exp_id = l_exp_id;
          END IF;
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          -- try to get correct message
          l_failed_row  := l_failed_row + 1;
          my_message    :=
                  fnd_msg_pub.get(p_msg_index    => fnd_msg_pub.g_first
                  , p_encoded                    => fnd_api.g_false);

          WHILE(my_message IS NOT NULL) LOOP
            l_error_code  := my_message;
            my_message    := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          END LOOP;

          cn_import_pvt.update_imp_lines(
            p_imp_line_id                => l_api_rec.imp_line_id
          , p_status_code                => 'FAIL'
          , p_error_code                 => NULL
          , p_error_msg                  => NVL(l_error_code, 'Unexpected Error')
          );
          cn_import_pvt.update_imp_headers(
            p_imp_header_id              => p_imp_header_id
          , p_status_code                => 'IMPORT_FAIL'
          , p_failed_row                 => l_failed_row
          );
          cn_message_pkg.WRITE(
            p_message_text               => 'Record ' || TO_CHAR(l_processed_row) || ':'
                                            || l_message
          , p_message_type               => 'ERROR'
          );
          cn_import_pvt.write_error_rec(
            p_imp_header_id              => p_imp_header_id
          , p_imp_line_id                => l_api_rec.imp_line_id
          , p_header_list                => l_header_list
          , p_sql_stmt                   => l_sql_stmt
          );
          retcode       := 2;
          errbuf        := l_message;
          GOTO end_loop;
        ELSE
          l_error_code  := '';
          cn_import_pvt.update_imp_lines(
            p_imp_line_id                => l_api_rec.imp_line_id
          , p_status_code                => 'COMPLETE'
          , p_error_code                 => l_error_code
          );
          cn_message_pkg.WRITE(
            p_message_text               =>    'CALCEXPIMP:Import completed. exp id = '
                                            || TO_CHAR(l_exp_id)
          , p_message_type               => 'DEBUG'
          );
        END IF;

        <<end_loop>>
        -- update update_imp_headers:process_row
        cn_import_pvt.update_imp_headers(
          p_imp_header_id              => p_imp_header_id
        , p_status_code                => NULL
        , p_processed_row              => l_processed_row
        );
      EXCEPTION
        WHEN OTHERS THEN
          l_failed_row  := l_failed_row + 1;
          l_error_code  := SQLCODE;
          l_message     := SUBSTR(SQLERRM, 1, 2000);
          cn_import_pvt.update_imp_lines(
            p_imp_line_id                => l_api_rec.imp_line_id
          , p_status_code                => 'FAIL'
          , p_error_code                 => NULL
          , p_error_msg                  => l_message
          );
          cn_import_pvt.update_imp_headers(
            p_imp_header_id              => p_imp_header_id
          , p_status_code                => 'IMPORT_FAIL'
          , p_processed_row              => l_processed_row
          , p_failed_row                 => l_failed_row
          );
          cn_message_pkg.WRITE(
            p_message_text               => 'Record ' || TO_CHAR(l_processed_row) || ':'
                                            || l_message
          , p_message_type               => 'ERROR'
          );
          cn_import_pvt.write_error_rec(
            p_imp_header_id              => p_imp_header_id
          , p_imp_line_id                => l_api_rec.imp_line_id
          , p_header_list                => l_header_list
          , p_sql_stmt                   => l_sql_stmt
          );
          retcode       := 2;
          errbuf        := l_message;
      END;
    END LOOP;   -- get_api_recs

    IF get_api_recs%ROWCOUNT = 0 THEN
      l_processed_row  := 0;
    END IF;

    CLOSE get_api_recs;

    IF l_failed_row = 0 AND retcode = 0 THEN
      -- update update_imp_headers
      cn_import_pvt.update_imp_headers(
        p_imp_header_id              => p_imp_header_id
      , p_status_code                => 'COMPLETE'
      , p_processed_row              => l_processed_row
      , p_failed_row                 => l_failed_row
      );
    END IF;

    cn_message_pkg.WRITE(
      p_message_text               =>    'CALCEXPIMP: End Transfer Data. imp_header_id = '
                                      || TO_CHAR(p_imp_header_id)
    , p_message_type               => 'MILESTONE'
    );
    -- close process batch
    cn_message_pkg.end_batch(l_process_audit_id);
    -- Commit all imports
    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      retcode  := 2;
      cn_message_pkg.end_batch(l_process_audit_id);
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => errbuf
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      err_num  := SQLCODE;

      IF err_num = -6501 THEN
        retcode  := 2;
        errbuf   := fnd_program.MESSAGE;
      ELSE
        retcode  := 2;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => errbuf
        , p_encoded                    => fnd_api.g_false);
      END IF;

      cn_message_pkg.set_error(l_api_name, errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);
  END import;

  -- export
  PROCEDURE export(
    errbuf          OUT NOCOPY    VARCHAR2
  , retcode         OUT NOCOPY    VARCHAR2
  , p_imp_header_id IN            NUMBER
  , p_org_id        IN            NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30)                              := 'Export';
    l_process_audit_id  cn_process_audits.process_audit_id%TYPE;
    l_return_status     VARCHAR2(1);
    l_msg_data          VARCHAR2(4000);
    l_msg_count         NUMBER;
    l_col_names         cn_import_pvt.char_data_set_type;
    l_data              cn_import_pvt.char_data_set_type;
    l_rowcount          NUMBER                                    := 0;
    l_longcount         NUMBER                                    := 0;
    l_rec_num           NUMBER                                    := 0;
    l_message           VARCHAR2(4000);
    l_name              VARCHAR2(30);
    l_type              VARCHAR2(30);
    l_view_name         VARCHAR2(30);
    my_message          VARCHAR2(4000);
    err_num             NUMBER;
    g_max_field_length  NUMBER                                    := 150;

    -- this is a workaround since you cannot declare arrays of a
    -- type declared remotely
    TYPE vt IS TABLE OF VARCHAR2(30);

    l_col_names_tmp     vt
      := vt(
          'RECORD_NUM'
        , 'EXPRESSION_NAME'
        , 'DESCRIPTION'
        , 'SQL_SELECT'
        , 'ATTRIBUTE_CATEGORY'
        , 'ATTRIBUTE1'
        , 'ATTRIBUTE2'
        , 'ATTRIBUTE3'
        , 'ATTRIBUTE4'
        , 'ATTRIBUTE5'
        , 'ATTRIBUTE6'
        , 'ATTRIBUTE7'
        , 'ATTRIBUTE8'
        , 'ATTRIBUTE9'
        , 'ATTRIBUTE10'
        , 'ATTRIBUTE11'
        , 'ATTRIBUTE12'
        , 'ATTRIBUTE13'
        , 'ATTRIBUTE14'
        , 'ATTRIBUTE15'
        );

    CURSOR get_expressions IS
      SELECT   NAME expression_name
             , description
             , DBMS_LOB.SUBSTR(sql_select, g_max_field_length) sql_select
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
          FROM cn_calc_sql_exps
         WHERE org_id = p_org_id
      ORDER BY 1;

    CURSOR get_rowcount IS
      SELECT COUNT(1)
        FROM cn_calc_sql_exps
       WHERE org_id = p_org_id;

    CURSOR get_long_rowcount IS
      SELECT COUNT(1)
        FROM cn_calc_sql_exps
       WHERE DBMS_LOB.getlength(sql_select) > g_max_field_length AND org_id = p_org_id;
  BEGIN
    retcode  := 0;

    -- Get imp_header info
    SELECT h.NAME
         , h.import_type_code
         , t.view_name
      INTO l_name
         , l_type
         , l_view_name
      FROM cn_imp_headers h, cn_import_types t
     WHERE h.imp_header_id = p_imp_header_id AND t.import_type_code = h.import_type_code;

    -- open process audit batch
    cn_message_pkg.begin_batch(
      x_process_type               => l_type
    , x_parent_proc_audit_id       => p_imp_header_id
    , x_process_audit_id           => l_process_audit_id
    , x_request_id                 => NULL
    , p_org_id                     => p_org_id
    );
    cn_message_pkg.WRITE
                       (
      p_message_text               =>    'CN_EXPCALCEXP: Start Transfer Data. imp_header_id = '
                                      || TO_CHAR(p_imp_header_id)
    , p_message_type               => 'MILESTONE'
    );

    -- API call here
    -- get column names
    FOR i IN 1 .. l_col_names_tmp.COUNT LOOP
      l_col_names(i)  := l_col_names_tmp(i);
    END LOOP;

    -- we have to get the rowcount first - since the data must be applied
    -- sequentially by column... indexes are like
    -- 1 n+1 ... 19n+1  (there are 20 columns)
    -- 2 n+2 ... 19n+2
    -- n 2n  ... 20n
    OPEN get_rowcount;
    FETCH get_rowcount INTO l_rowcount;
    CLOSE get_rowcount;

    OPEN get_long_rowcount;
    FETCH get_long_rowcount INTO l_longcount;
    CLOSE get_long_rowcount;

    -- now populate the data
    FOR EXP IN get_expressions LOOP
      l_rec_num                            := l_rec_num + 1;
      l_data(l_rowcount * 0 + l_rec_num)   := l_rec_num;
      l_data(l_rowcount * 1 + l_rec_num)   := EXP.expression_name;
      l_data(l_rowcount * 2 + l_rec_num)   := EXP.description;
      l_data(l_rowcount * 3 + l_rec_num)   := EXP.sql_select;
      l_data(l_rowcount * 4 + l_rec_num)   := EXP.attribute_category;
      l_data(l_rowcount * 5 + l_rec_num)   := EXP.attribute1;
      l_data(l_rowcount * 6 + l_rec_num)   := EXP.attribute2;
      l_data(l_rowcount * 7 + l_rec_num)   := EXP.attribute3;
      l_data(l_rowcount * 8 + l_rec_num)   := EXP.attribute4;
      l_data(l_rowcount * 9 + l_rec_num)   := EXP.attribute5;
      l_data(l_rowcount * 10 + l_rec_num)  := EXP.attribute6;
      l_data(l_rowcount * 11 + l_rec_num)  := EXP.attribute7;
      l_data(l_rowcount * 12 + l_rec_num)  := EXP.attribute8;
      l_data(l_rowcount * 13 + l_rec_num)  := EXP.attribute9;
      l_data(l_rowcount * 14 + l_rec_num)  := EXP.attribute10;
      l_data(l_rowcount * 15 + l_rec_num)  := EXP.attribute11;
      l_data(l_rowcount * 16 + l_rec_num)  := EXP.attribute12;
      l_data(l_rowcount * 17 + l_rec_num)  := EXP.attribute13;
      l_data(l_rowcount * 18 + l_rec_num)  := EXP.attribute14;
      l_data(l_rowcount * 19 + l_rec_num)  := EXP.attribute15;
    END LOOP;

    cn_import_client_pvt.insert_data(
      p_api_version                => 1.0
    , p_imp_header_id              => p_imp_header_id
    , p_import_type_code           => l_type
    , p_table_name                 => l_view_name
    , p_col_names                  => l_col_names
    , p_data                       => l_data
    , p_row_count                  => l_rowcount
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      cn_import_pvt.update_imp_headers(p_imp_header_id => p_imp_header_id, p_status_code => 'FAIL'
      , p_failed_row                 => l_rowcount);
      cn_message_pkg.WRITE(
        p_message_text               => 'Export threw exception : rts sts ' || l_return_status
      , p_message_type               => 'ERROR'
      );
      my_message  := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

      WHILE(my_message IS NOT NULL) LOOP
        l_message   := l_message || my_message || '; ';
        my_message  := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
      END LOOP;

      cn_message_pkg.WRITE(p_message_text => l_message, p_message_type => 'ERROR');
      retcode     := 2;
      errbuf      := l_message;
    ELSE
      -- normal completion
      cn_import_pvt.update_imp_headers(
        p_imp_header_id              => p_imp_header_id
      , p_status_code                => 'COMPLETE'
      , p_processed_row              => l_rowcount
      , p_staged_row                 => l_rowcount - l_longcount
      , p_failed_row                 => l_longcount
      );

      -- set cn_imp_lines records status = 'COMPLETE'
      UPDATE cn_exp_api_imp_v
         SET status_code = 'COMPLETE'
       WHERE imp_header_id = p_imp_header_id;

      -- set failed records - where expression was too long
      fnd_message.set_name('CN', 'CN_EXPORT_FIELD_TOO_LONG');
      fnd_message.set_token('LENGTH', g_max_field_length);
      my_message  := fnd_message.get;

      UPDATE cn_exp_api_imp_v
         SET status_code = 'FAIL'
           , error_msg = my_message
       WHERE imp_header_id = p_imp_header_id
         AND expression_name IN(SELECT NAME
                                  FROM cn_calc_sql_exps
                                 WHERE DBMS_LOB.getlength(sql_select) > g_max_field_length);

      cn_message_pkg.WRITE
                         (
        p_message_text               =>    'CN_EXPCALCEXP: End Transfer Data. imp_header_id = '
                                        || TO_CHAR(p_imp_header_id)
      , p_message_type               => 'MILESTONE'
      );
    END IF;

    -- close process batch
    cn_message_pkg.end_batch(l_process_audit_id);
    -- Commit all imports
    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      retcode  := 2;
      cn_message_pkg.end_batch(l_process_audit_id);
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => errbuf
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      err_num  := SQLCODE;

      IF err_num = -6501 THEN
        retcode  := 2;
        errbuf   := fnd_program.MESSAGE;
      ELSE
        retcode  := 2;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => errbuf
        , p_encoded                    => fnd_api.g_false);
      END IF;

      cn_message_pkg.set_error(l_api_name, errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);
  END export;

  PROCEDURE duplicate_expression(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2 := fnd_api.g_false
  , p_commit           IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level IN            NUMBER := fnd_api.g_valid_level_full
  , p_old_expr_id      IN            NUMBER
  , x_new_expr_id      OUT NOCOPY    NUMBER
  , x_new_expr_name    OUT NOCOPY    cn_calc_sql_exps.NAME%TYPE
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)                                  := 'Duplicate_Expression';
    l_api_version  CONSTANT NUMBER                                        := 1.0;
    l_org_id                cn_calc_sql_exps.org_id%TYPE;
    l_description           cn_calc_sql_exps.description%TYPE;
    l_expression_disp       VARCHAR2(32767);
    l_sql_select            VARCHAR2(32767);
    l_sql_from              VARCHAR2(32767);
    l_piped_expression_disp VARCHAR2(32767);
    l_piped_sql_select      VARCHAR2(32767);
    l_piped_sql_from        VARCHAR2(32767);
    x_exp_type_code         cn_calc_sql_exps.exp_type_code%TYPE;
    x_status                cn_calc_sql_exps.status%TYPE;
    x_object_version_number cn_calc_sql_exps.object_version_number%TYPE;
    l_suffix                VARCHAR2(10)                                  := NULL;
    l_prefix                VARCHAR2(10)                                  := NULL;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT create_expression;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT org_id
         , NAME
         , description
         , expression_disp
         , sql_select
         , sql_from
         , piped_expression_disp
         , piped_sql_select
         , piped_sql_from
      INTO l_org_id
         , x_new_expr_name
         , l_description
         , l_expression_disp
         , l_sql_select
         , l_sql_from
         , l_piped_expression_disp
         , l_piped_sql_select
         , l_piped_sql_from
      FROM cn_calc_sql_exps
     WHERE calc_sql_exp_id = p_old_expr_id;

    -- x_new_expr_name := x_new_expr_name || '_2';
    cn_plancopy_util_pvt.get_unique_name_for_component(
      p_id                         => p_old_expr_id
    , p_org_id                     => l_org_id
    , p_type                       => 'EXPRESSION'
    , p_suffix                     => l_suffix
    , p_prefix                     => l_prefix
    , x_name                       => x_new_expr_name
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    create_expression(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_validation_level           => p_validation_level
    , p_org_id                     => l_org_id
    , p_name                       => x_new_expr_name
    , p_description                => l_description
    , p_expression_disp            => l_expression_disp
    , p_sql_select                 => l_sql_select
    , p_sql_from                   => l_sql_from
    , p_piped_expression_disp      => l_piped_expression_disp
    , p_piped_sql_select           => l_piped_sql_select
    , p_piped_sql_from             => l_piped_sql_from
    , x_calc_sql_exp_id            => x_new_expr_id
    , x_exp_type_code              => x_exp_type_code
    , x_status                     => x_status
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_object_version_number      => x_object_version_number
    );

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
    , p_encoded                    => fnd_api.g_false);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO duplicate_expression;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO duplicate_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
    WHEN OTHERS THEN
      ROLLBACK TO duplicate_expression;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data
      , p_encoded                    => fnd_api.g_false);
  END duplicate_expression;
END cn_calc_sql_exps_pvt;

/
