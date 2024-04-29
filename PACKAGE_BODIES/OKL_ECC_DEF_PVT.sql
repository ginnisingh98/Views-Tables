--------------------------------------------------------
--  DDL for Package Body OKL_ECC_DEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_DEF_PVT" AS
/* $Header: OKLRECCB.pls 120.1 2005/10/30 04:58:54 appldev noship $ */

  -------------------
  ---parse_sql
  -------------------
  FUNCTION parse_sql(p_sql  IN  varchar2) RETURN varchar2 IS
    cur    integer;
    i      number;
    lp_sql varchar2(4000);

  BEGIN
    lp_sql := p_sql;
    cur := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(cur, lp_sql, DBMS_SQL.native);
    DBMS_SQL.close_cursor (cur);
    lp_sql := upper(lp_sql);

    SELECT instr(lp_sql, ' ID,')
    INTO   i
    FROM   dual;

    IF i = 0 THEN
      RAISE okl_api.g_exception_error;
    END IF;

    SELECT instr(lp_sql, ' NAME ')
    INTO   i
    FROM   dual;

    IF i = 0 THEN
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN okl_api.g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN OTHERS THEN
        DBMS_SQL.close_cursor (cur);
        RETURN okl_api.g_ret_sts_error;
  END parse_sql;  /*header is validated only while creating criteria category as no fields except
enabled_yn are updatable after that*/

  FUNCTION validate_header(p_eccv_rec  IN  okl_eccv_rec) RETURN varchar2 IS

    CURSOR l_ecc_csr IS
      SELECT 'x'
      FROM   okl_fe_crit_cat_def_v
      WHERE  crit_cat_name = p_eccv_rec.crit_cat_name
         AND ecc_ac_flag = p_eccv_rec.ecc_ac_flag;
    l_dummy_var              varchar2(1) := '?';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN  --name,ecc_ac_flag combination should be unique
    OPEN l_ecc_csr;
    FETCH l_ecc_csr INTO l_dummy_var ;
    CLOSE l_ecc_csr;  -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             'OKL_DUPLICATE_NAME'
                         ,p_token1       =>             'NAME'
                         ,p_token1_value =>             p_eccv_rec.crit_cat_name);
      RAISE okl_api.g_exception_error;
    END IF;  --if value type=range data type should not be varchar2

    IF p_eccv_rec.value_type_code = 'RANGE' AND p_eccv_rec.data_type_code = 'VARCHAR2' THEN
      okl_api.set_message(p_app_name =>                 g_app_name
                         ,p_msg_name =>                 'OKL_INVALID_DATATYPE_RANGE_CMB');
      RAISE okl_api.g_exception_error;
    END IF;  --if value type=range source should not be Yes

    IF p_eccv_rec.value_type_code = 'RANGE' AND p_eccv_rec.source_yn = 'Y' THEN
      okl_api.set_message(p_app_name =>                 g_app_name
                         ,p_msg_name =>                 'OKL_INVALID_SOURCE_RANGE_CMB');
      RAISE okl_api.g_exception_error;
    END IF;  --source=yes data type should be varchar2

    IF p_eccv_rec.source_yn = 'Y' AND NOT p_eccv_rec.data_type_code = 'VARCHAR2' THEN
      okl_api.set_message(p_app_name =>                 g_app_name
                         ,p_msg_name =>                 'OKL_INVALID_DATATYPE_SRC_CMB');
      RAISE okl_api.g_exception_error;
    END IF;

    --if source is yes VALID sql_statement should be present
    --sql statement shuuld have alias ID and NAME in SELECT clause and commma (,)
    -- should immediately follow ID

    IF ((p_eccv_rec.source_yn IS NOT NULL) OR (p_eccv_rec.source_yn <> okl_api.g_miss_char)) THEN
      IF p_eccv_rec.source_yn = 'Y' THEN  --sql_statement should be present
        IF p_eccv_rec.sql_statement IS NULL THEN
          okl_api.set_message(p_app_name =>                 g_app_name
                             ,p_msg_name =>                 'OKL_INVALID_SQL_STATEMENT');
          RAISE okl_api.g_exception_error;  --sql statement should contain ID and NAME as alias in Select clause
        ELSE
          l_return_status := parse_sql(p_eccv_rec.sql_statement);
          IF l_return_status = okl_api.g_ret_sts_error THEN
            okl_api.set_message(p_app_name =>                 g_app_name
                               ,p_msg_name =>                 'OKL_MANDATORY_SQL_STATEMENT');
            RAISE okl_api.g_exception_error;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN okl_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        RETURN okl_api.g_ret_sts_unexp_error;
  END validate_header;

  PROCEDURE create_ecc(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl) IS
    lp_eccv_rec                    okl_eccv_rec;
    lx_eccv_rec                    okl_eccv_rec;
    lp_eco_tbl                     okl_eco_tbl;
    lx_eco_tbl                     okl_eco_tbl;
    i                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_ECC_DEF_PVT.CREATE_ECC';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'create_ecc';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call create_ecc');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lp_eccv_rec := p_eccv_rec;
    lp_eco_tbl := p_eco_tbl;  --validate header
    l_return_status := validate_header(lp_eccv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Function okl_ecc_def_pvt.validate_header returned with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;  --if crit_cat_def_id is present it means we are duplicating so populate orig_crit_Cat_Def_id

    IF ((lp_eccv_rec.crit_cat_def_id IS NOT NULL) AND (lp_eccv_rec.crit_cat_def_id <> okl_api.g_miss_num)) THEN
      lp_eccv_rec.orig_crit_cat_def_id := lp_eccv_rec.crit_cat_def_id;
    END IF;
    okl_ecc_pvt.insert_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_eccv_rec
                          ,lx_eccv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_ecc_pvt.insert_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN record type
    lp_eccv_rec := lx_eccv_rec;

    IF lp_eco_tbl.COUNT > 0 THEN

      FOR i IN lp_eco_tbl.FIRST..lp_eco_tbl.LAST LOOP
        lp_eco_tbl(i).crit_cat_def_id := lp_eccv_rec.crit_cat_def_id;
      END LOOP;
      okl_eco_pvt.insert_row(p_api_version
                            ,okl_api.g_false
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,lp_eco_tbl
                            ,lx_eco_tbl);  -- write to log
      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'okl_eco_pvt.insert_row returned with status ' ||
                                l_return_status ||
                                ' x_msg_data ' ||
                                x_msg_data);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;  --Assign value to OUT variables
    x_eccv_rec := lx_eccv_rec;
    x_eco_tbl := lx_eco_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECCB.pls call create_ecc');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END create_ecc;

  PROCEDURE update_ecc(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl) IS
    lp_eccv_rec                    okl_eccv_rec;
    lx_eccv_rec                    okl_eccv_rec;
    lp_eco_crt_tbl                 okl_eco_tbl;
    lx_eco_crt_tbl                 okl_eco_tbl;
    lp_eco_rmv_tbl                 okl_eco_tbl;
    lp_eco_tbl                     okl_eco_tbl;
    lx_eco_tbl                     okl_eco_tbl;
    i                              number;
    j                              number;
    l                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_ECC_DEF_PVT.UPDATE_ECC';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'update_ecc';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call update_ecc');
    END IF;  -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>            l_api_name
                                             ,p_pkg_name      =>            g_pkg_name
                                             ,p_init_msg_list =>            p_init_msg_list
                                             ,l_api_version   =>            l_api_version
                                             ,p_api_version   =>            p_api_version
                                             ,p_api_type      =>            g_api_type
                                             ,x_return_status =>            x_return_status);  -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lp_eccv_rec := p_eccv_rec;
    lp_eco_tbl := p_eco_tbl;
    okl_ecc_pvt.update_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_eccv_rec
                          ,lx_eccv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_ecc_pvt.update_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN record type
    lp_eccv_rec := lx_eccv_rec;
    j := 1;
    l := 1;

    --lp_eco_tbl contains objects to be newly applied (created) or to be un applied (removed)
    --there is no need to update existing applicable objects

    IF lp_eco_tbl.COUNT > 0 THEN

      FOR i IN lp_eco_tbl.FIRST..lp_eco_tbl.LAST LOOP
        IF lp_eco_tbl(i).is_applicable = 'Y' THEN
          lp_eco_crt_tbl(j) := lp_eco_tbl(i);
          lp_eco_crt_tbl(j).crit_cat_def_id := lp_eccv_rec.crit_cat_def_id;
          j := j + 1;
        ELSIF lp_eco_tbl(i).is_applicable = 'N' THEN
          lp_eco_rmv_tbl(l) := lp_eco_tbl(i);
          lp_eco_rmv_tbl(l).crit_cat_def_id := lp_eccv_rec.crit_cat_def_id;
          l := l + 1;
        END IF;
      END LOOP;

      IF lp_eco_crt_tbl.COUNT > 0 THEN
        okl_eco_pvt.insert_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_eco_crt_tbl
                              ,lx_eco_crt_tbl);  -- write to log
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_eco_pvt.insert_row returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;
      IF lp_eco_rmv_tbl.COUNT > 0 THEN
        okl_eco_pvt.delete_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_eco_rmv_tbl);  -- write to log
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_eco_pvt.delete_row returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;
    END IF;  --Assign value to OUT variables
    x_eccv_rec := lx_eccv_rec;
    x_eco_tbl := lx_eco_crt_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECCB.pls call update_ecc');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                g_pkg_name
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                g_api_type);
  END update_ecc;

END okl_ecc_def_pvt;

/
