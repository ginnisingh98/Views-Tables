--------------------------------------------------------
--  DDL for Package Body OKL_ECC_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_VALUES_PVT" AS
/* $Header: OKLRECVB.pls 120.1 2005/10/30 04:58:59 appldev noship $ */

  --------------------------------------------------------------------------------
  --PACKAGE CONSTANTS
  --------------------------------------------------------------------------------

  g_db_error        CONSTANT varchar2(12) := 'OKL_DB_ERROR';
  g_prog_name_token CONSTANT varchar2(9) := 'PROG_NAME';


  FUNCTION validate_effective_dates(p_ecl_tbl          IN  okl_ecl_tbl
                                   ,p_source_eff_from  IN  date
                                   ,p_source_eff_to    IN  date) RETURN varchar2 IS

    CURSOR l_crit_cat_name_csr(p_crit_cat_def_id  IN  number) IS
      SELECT crit_cat_name
            ,ecc_ac_flag
      FROM   okl_fe_crit_cat_def_v
      WHERE  crit_cat_def_id = p_crit_cat_def_id;
    i                              number;
    j                              number;
    l_api_name            CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_effective_dates';
    l_crit_cat                     varchar2(40);
    l_crit_cat_name                okl_fe_crit_cat_def_v.crit_cat_name%TYPE;
    l_ecc_ac_flag                  okl_fe_crit_cat_def_b.ecc_ac_flag%TYPE;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.validate_effective_dates';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call validate_effective_dates');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    i := p_ecl_tbl.FIRST;

    WHILE(i <= p_ecl_tbl.LAST) LOOP

      -- eff from and to dates of eligibility criteria should lie beween eff from and to dates of source

      IF (p_ecl_tbl(i).effective_from_date NOT BETWEEN p_source_eff_from AND nvl(p_source_eff_to
                                                                                ,to_date('01-01-9999'
                                                                                        ,'dd-mm-yyyy')))
         OR (nvl(p_ecl_tbl(i).effective_to_date
                ,to_date('01-01-9999', 'dd-mm-yyyy')) NOT BETWEEN p_source_eff_from AND nvl(p_source_eff_to
                                                                                           ,to_date('01-01-9999'
                                                                                                   ,'dd-mm-yyyy'))) THEN
        OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
        FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                      ,l_ecc_ac_flag ;
        CLOSE l_crit_cat_name_csr;
        IF l_ecc_ac_flag = 'ECC' THEN
          l_crit_cat := 'Eligibility Criteria Category';
        ELSE
          l_crit_cat := 'Adjustment Category';
        END IF;
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_INVALID_EFFECTIVE_DATES'
                           ,p_token1       =>  'CRIT_CAT'
                           ,p_token1_value =>  l_crit_cat
                           ,p_token2       =>  'NAME'
                           ,p_token2_value =>  l_crit_cat_name);
        RAISE okl_api.g_exception_error;
      END IF;
      j := i + 1;
      WHILE(j <= p_ecl_tbl.LAST) LOOP

        IF (p_ecl_tbl(i).crit_cat_def_id = p_ecl_tbl(j).crit_cat_def_id) THEN

          -- both finite

          IF (p_ecl_tbl(i).effective_to_date IS NOT NULL AND p_ecl_tbl(j).effective_to_date IS NOT NULL) THEN
            IF (p_ecl_tbl(j).effective_from_date BETWEEN p_ecl_tbl(i).effective_from_date AND p_ecl_tbl(i).effective_to_date) THEN
              OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
              FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                            ,l_ecc_ac_flag ;
              CLOSE l_crit_cat_name_csr;
              IF l_ecc_ac_flag = 'ECC' THEN
                l_crit_cat := 'Eligibility Criteria Category';
              ELSE
                l_crit_cat := 'Adjustment Category';
              END IF;
              okl_api.set_message(p_app_name     =>  g_app_name
                                 ,p_msg_name     =>  'OKL_CRITCAT_OVERLAPPING_DATES'
                                 ,p_token1       =>  'CRIT_CAT'
                                 ,p_token1_value =>  l_crit_cat
                                 ,p_token2       =>  'NAME'
                                 ,p_token2_value =>  l_crit_cat_name);
              RAISE okl_api.g_exception_error;
            END IF;
            IF (p_ecl_tbl(j).effective_to_date BETWEEN p_ecl_tbl(i).effective_from_date AND p_ecl_tbl(i).effective_to_date) THEN
              OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
              FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                            ,l_ecc_ac_flag ;
              CLOSE l_crit_cat_name_csr;
              IF l_ecc_ac_flag = 'ECC' THEN
                l_crit_cat := 'Eligibility Criteria Category';
              ELSE
                l_crit_cat := 'Adjustment Category';
              END IF;
              okl_api.set_message(p_app_name     =>  g_app_name
                                 ,p_msg_name     =>  'OKL_CRITCAT_OVERLAPPING_DATES'
                                 ,p_token1       =>  'CRIT_CAT'
                                 ,p_token1_value =>  l_crit_cat
                                 ,p_token2       =>  'NAME'
                                 ,p_token2_value =>  l_crit_cat_name);
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;

          -- Both Open End

          IF (p_ecl_tbl(i).effective_to_date IS NULL AND p_ecl_tbl(j).effective_to_date IS NULL) THEN
            OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
            FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                          ,l_ecc_ac_flag ;
            CLOSE l_crit_cat_name_csr;
            IF l_ecc_ac_flag = 'ECC' THEN
              l_crit_cat := 'Eligibility Criteria Category';
            ELSE
              l_crit_cat := 'Adjustment Category';
            END IF;
            okl_api.set_message(p_app_name     =>  g_app_name
                               ,p_msg_name     =>  'OKL_CRITCAT_OVERLAPPING_DATES'
                               ,p_token1       =>  'CRIT_CAT'
                               ,p_token1_value =>  l_crit_cat
                               ,p_token2       =>  'NAME'
                               ,p_token2_value =>  l_crit_cat_name);
            RAISE okl_api.g_exception_error;
          END IF;

          -- p_ecl_tbl(i) is open end and p_ecl_tbl(j) is finite

          IF (p_ecl_tbl(i).effective_to_date IS NULL AND p_ecl_tbl(j).effective_to_date IS NOT NULL) THEN
            IF (p_ecl_tbl(j).effective_to_date >= p_ecl_tbl(i).effective_from_date) THEN
              OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
              FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                            ,l_ecc_ac_flag ;
              CLOSE l_crit_cat_name_csr;
              IF l_ecc_ac_flag = 'ECC' THEN
                l_crit_cat := 'Eligibility Criteria Category';
              ELSE
                l_crit_cat := 'Adjustment Category';
              END IF;
              okl_api.set_message(p_app_name     =>  g_app_name
                                 ,p_msg_name     =>  'OKL_CRITCAT_OVERLAPPING_DATES'
                                 ,p_token1       =>  'CRIT_CAT'
                                 ,p_token1_value =>  l_crit_cat
                                 ,p_token2       =>  'NAME'
                                 ,p_token2_value =>  l_crit_cat_name);
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;

          -- p_ecl_tbl(i) is finite end and p_ecl_tbl(j) is open end

          IF (p_ecl_tbl(i).effective_to_date IS NOT NULL AND p_ecl_tbl(j).effective_to_date IS NULL) THEN
            IF (p_ecl_tbl(j).effective_from_date <= p_ecl_tbl(i).effective_to_date) THEN
              OPEN l_crit_cat_name_csr(p_ecl_tbl(i).crit_cat_def_id);
              FETCH l_crit_cat_name_csr INTO l_crit_cat_name
                                            ,l_ecc_ac_flag ;
              CLOSE l_crit_cat_name_csr;
              IF l_ecc_ac_flag = 'ECC' THEN
                l_crit_cat := 'Eligibility Criteria Category';
              ELSE
                l_crit_cat := 'Adjustment Category';
              END IF;
              okl_api.set_message(p_app_name     =>  g_app_name
                                 ,p_msg_name     =>  'OKL_CRITCAT_OVERLAPPING_DATES'
                                 ,p_token1       =>  'CRIT_CAT'
                                 ,p_token1_value =>  l_crit_cat
                                 ,p_token2       =>  'NAME'
                                 ,p_token2_value =>  l_crit_cat_name);
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;
        END IF;
        j := j + 1;
      END LOOP;
      i := i + 1;
    END LOOP;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call validate_effective_dates');
    END IF;
    RETURN okl_api.g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN okl_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        RETURN okl_api.g_ret_sts_unexp_error;
  END validate_effective_dates;

 /**
     This procedure deletes the Eligibility criteria attached to a particular
     source object identified by p_source_id and p_source_type.
 **/

  PROCEDURE delete_eligibility_criteria(p_api_version    IN             number
                                       ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                       ,x_return_status     OUT NOCOPY  varchar2
                                       ,x_msg_count         OUT NOCOPY  number
                                       ,x_msg_data          OUT NOCOPY  varchar2
                                       ,p_source_id      IN             number
                                       ,p_source_type    IN             varchar2) IS
    l_source_id number;
    lp_ech_rec  okl_ech_rec;
    lx_ech_rec  okl_ech_rec;
    lp_ecl_tbl  okl_ecl_tbl;
    lx_ecl_tbl  okl_ecl_tbl;
    lp_ecv_tbl  okl_ecv_tbl;
    lx_ecv_tbl  okl_ecv_tbl;

    CURSOR get_ech_rec IS
      SELECT criteria_set_id
      FROM   okl_fe_criteria_set
      WHERE  source_id = p_source_id AND source_object_code = p_source_type;

    CURSOR get_ecl_tbl(p_criteria_set_id  IN  number) IS
      SELECT criteria_id
      FROM   okl_fe_criteria
      WHERE  criteria_set_id = p_criteria_set_id;

    CURSOR get_ecv_tbl(p_criteria_id  IN  number) IS
      SELECT criterion_value_id
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = p_criteria_id;
    i                              number;
    j                              number;
    l_api_name            CONSTANT varchar2(30) := 'DELETE_ELIG_CRITERIA';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_ec_found                     boolean;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.delete_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call delete_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_source_id := p_source_id;
    OPEN get_ech_rec;
    FETCH get_ech_rec INTO lp_ech_rec.criteria_set_id ;
    l_ec_found := get_ech_rec%FOUND;
    CLOSE get_ech_rec;
    i := 1;
    j := 1;

    IF l_ec_found THEN

      FOR ecl_rec IN get_ecl_tbl(lp_ech_rec.criteria_set_id) LOOP
        lp_ecl_tbl(i).criteria_id := ecl_rec.criteria_id;
        FOR ecv_rec IN get_ecv_tbl(lp_ecl_tbl(i).criteria_id) LOOP
          lp_ecv_tbl(i).criterion_value_id := ecv_rec.criterion_value_id;
          j := j + 1;
        END LOOP;
        i := i + 1;
      END LOOP;

      --delete header

      okl_ech_pvt.delete_row(p_api_version   =>  p_api_version
                            ,p_init_msg_list =>  okl_api.g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_ech_rec       =>  lp_ech_rec);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ech_pvt.delete_row  returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = okl_api.g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
      IF lp_ecl_tbl.COUNT > 0 THEN

        --delete lines

        okl_ecl_pvt.delete_row(p_api_version   =>  p_api_version
                              ,p_init_msg_list =>  okl_api.g_false
                              ,x_return_status =>  l_return_status
                              ,x_msg_count     =>  x_msg_count
                              ,x_msg_data      =>  x_msg_data
                              ,p_ecl_tbl       =>  lp_ecl_tbl);

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_ecl_pvt.delete_row returned with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF l_return_status = okl_api.g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
        IF lp_ecv_tbl.COUNT > 0 THEN

          --delete line values

          okl_ecv_pvt.delete_row(p_api_version   =>  p_api_version
                                ,p_init_msg_list =>  okl_api.g_false
                                ,x_return_status =>  l_return_status
                                ,x_msg_count     =>  x_msg_count
                                ,x_msg_data      =>  x_msg_data
                                ,p_ecv_tbl       =>  lp_ecv_tbl);

          -- write to log

          IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_statement
                                   ,l_module
                                   ,'Procedure okl_ecv_pvt.delete_row returned with status ' ||
                                    l_return_status);
          END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
          IF l_return_status = okl_api.g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          END IF;
        END IF;
      END IF;
    END IF;
    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call delete_eligibility_criteria');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END delete_eligibility_criteria;
 /**
    This procedure do insert/update of eligibility criteria passed to it as
    parameters.  The is_new_flag='Y' in p_ecl_tbl(i) signifies insert of Criteria.
    p_ech_rec.criteria_Set_id = null signifies insert of Criteria set record.
    p_ecv_tbl(i).criterion_value_id signifies insert of criterion value record.
    p_ecv_tbl(i).criteria_id should be pointing to p_ecl_tbl(i).criteria_id,
    to identify the criterion value rows corressponding to a particular criterion
    line.
 **/

  PROCEDURE handle_eligibility_criteria(p_api_version      IN             number
                                       ,p_init_msg_list    IN             varchar2    DEFAULT okl_api.g_false
                                       ,x_return_status       OUT NOCOPY  varchar2
                                       ,x_msg_count           OUT NOCOPY  number
                                       ,x_msg_data            OUT NOCOPY  varchar2
                                       ,p_ech_rec          IN             okl_ech_rec
                                       ,x_ech_rec             OUT NOCOPY  okl_ech_rec
                                       ,p_ecl_tbl          IN             okl_ecl_tbl
                                       ,x_ecl_tbl             OUT NOCOPY  okl_ecl_tbl
                                       ,p_ecv_tbl          IN             okl_ecv_tbl
                                       ,x_ecv_tbl             OUT NOCOPY  okl_ecv_tbl
                                       ,p_source_eff_from  IN             date
                                       ,p_source_eff_to    IN             date) IS

    CURSOR l_data_type_csr(p_crit_cat_def_id  IN  number) IS
      SELECT data_type_code
            ,value_type_code
            ,source_yn
      FROM   okl_fe_crit_cat_def_b
      WHERE  crit_cat_def_id = p_crit_cat_def_id;
    lp_ech_rec                     okl_ech_rec;
    lx_ech_rec                     okl_ech_rec;
    lp_ecl_tbl                     okl_ecl_tbl;
    lx_ecl_tbl                     okl_ecl_tbl;
    lp_ecv_tbl                     okl_ecv_tbl;
    lx_ecv_tbl                     okl_ecv_tbl;
    lx_ecv_cons_tbl                okl_ecv_tbl;
    lp_ecl_crt_tbl                 okl_ecl_tbl;
    lx_ecl_crt_tbl                 okl_ecl_tbl;
    lp_ecl_upd_tbl                 okl_ecl_tbl;
    lx_ecl_upd_tbl                 okl_ecl_tbl;
    l_ecl_child_tbl                okl_ecl_tbl;
    l_ecv_child_tbl                okl_ecv_tbl;
    l_data_type_code               varchar2(30);
    l_value_type_code              varchar2(30);
    l_source_yn                    varchar2(30);
    l_criteria_set_id              number;
    l_validation_code              varchar2(30);
    l_mc_code                      varchar2(30);
    i                              number;
    j                              number;
    k                              number;
    l_child_ec_exists              boolean;
    l_api_name            CONSTANT varchar2(30) := 'HANDLE_ELIG_CRITERIA';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.handle_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call handle_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lp_ech_rec := p_ech_rec;
    lp_ecl_tbl := p_ecl_tbl;
    lp_ecv_tbl := p_ecv_tbl;

    --validate effective dates

    l_return_status := validate_effective_dates(lp_ecl_tbl
                                               ,p_source_eff_from
                                               ,p_source_eff_to);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --insert/update EC only if some criteria lines are present

    IF lp_ecl_tbl.COUNT > 0 THEN
      k := 1;
      IF lp_ech_rec.criteria_set_id IS NULL THEN

        --insert criteria set header

        okl_ech_pvt.insert_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_ech_rec
                              ,lx_ech_rec);

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_ech_pvt.insert_row returned with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      ELSE

        --update criteria set header

        okl_ech_pvt.update_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_ech_rec
                              ,lx_ech_rec);

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_ech_pvt.update_row returned with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;

      --Copy value of OUT variable in the IN record type

      lp_ech_rec := lx_ech_rec;

      FOR i IN lp_ecl_tbl.FIRST..lp_ecl_tbl.LAST LOOP
        lp_ecl_tbl(i).criteria_set_id := lx_ech_rec.criteria_set_id;

        --if effective date has to get null out then initialize it to
        --g_miss_date

        IF lp_ecl_tbl(i).effective_to_date IS NULL THEN
          lp_ecl_tbl(i).effective_to_date := okl_api.g_miss_date;
        END IF;
        IF lp_ecl_tbl(i).is_new_flag = 'Y' THEN
          okl_ecl_pvt.insert_row(p_api_version
                                ,okl_api.g_false
                                ,l_return_status
                                ,x_msg_count
                                ,x_msg_data
                                ,lp_ecl_tbl(i)
                                ,lx_ecl_tbl(i));

          -- write to log

          IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_statement
                                   ,l_module
                                   ,'Procedure okl_ecl_pvt.insert_row returned with status ' ||
                                    l_return_status);
          END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
          IF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          END IF;
          OPEN l_data_type_csr(lp_ecl_tbl(i).crit_cat_def_id);
          FETCH l_data_type_csr INTO l_data_type_code
                                    ,l_value_type_code
                                    ,l_source_yn ;
          CLOSE l_data_type_csr;
          FOR j IN lp_ecv_tbl.FIRST..lp_ecv_tbl.LAST LOOP

            --if the criteria_id in lp_ecv_tbl(i) is same as the id in the recently inserted record
            -- in okl_ec_criteria table then

            IF (lp_ecv_tbl(j).criteria_id = lp_ecl_tbl(i).criteria_id) THEN

              --populate the criteria_id with the id of the recently inserted record in okl_ec_lines tablein the

              lp_ecv_tbl(j).criteria_id := lx_ecl_tbl(i).criteria_id;
              lp_ecv_tbl(j).data_type_code := l_data_type_code;
              lp_ecv_tbl(j).value_type_code := l_value_type_code;
              lp_ecv_tbl(j).source_yn := l_source_yn;
              IF lp_ecv_tbl(j).criterion_value_id IS NULL THEN
                okl_ecv_pvt.insert_row(p_api_version
                                      ,okl_api.g_false
                                      ,l_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,lp_ecv_tbl(j)
                                      ,lx_ecv_tbl(j));

                -- write to log

                IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_statement
                                         ,l_module
                                         ,'Procedure okl_ecv_pvt.insert_row returned with status ' ||
                                          l_return_status);
                END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
                IF (l_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
                ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
                END IF;
              ELSE
                okl_ecv_pvt.update_row(p_api_version
                                      ,okl_api.g_false
                                      ,l_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,lp_ecv_tbl(j)
                                      ,lx_ecv_tbl(j));

                -- write to log

                IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_statement
                                         ,l_module
                                         ,'Procedure okl_ecv_pvt.update_row returned with status ' ||
                                          l_return_status);
                END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
                IF (l_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
                ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
                END IF;
              END IF;
              lx_ecv_cons_tbl(k) := lx_ecv_tbl(j);
              k := k + 1;
            END IF;
          END LOOP;  --of Line values
        ELSE
          okl_ecl_pvt.update_row(p_api_version
                                ,okl_api.g_false
                                ,l_return_status
                                ,x_msg_count
                                ,x_msg_data
                                ,lp_ecl_tbl(i)
                                ,lx_ecl_tbl(i));

          -- write to log

          IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_statement
                                   ,l_module
                                   ,'Procedure okl_ecl_pvt.update_row returned with status ' ||
                                    l_return_status);
          END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
          IF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          END IF;
          OPEN l_data_type_csr(lp_ecl_tbl(i).crit_cat_def_id);
          FETCH l_data_type_csr INTO l_data_type_code
                                    ,l_value_type_code
                                    ,l_source_yn ;
          CLOSE l_data_type_csr;
          FOR j IN lp_ecv_tbl.FIRST..lp_ecv_tbl.LAST LOOP

            --if the criteria_id in lp_ecv_tbl(i) is same as the id in the recently inserted record
            -- in okl_ec_criteria table then

            IF (lp_ecv_tbl(j).criteria_id = lp_ecl_tbl(i).criteria_id) THEN

              --populate the criteria_id with the id of the recently inserted record in okl_ec_lines tablein the

              lp_ecv_tbl(j).criteria_id := lx_ecl_tbl(i).criteria_id;
              lp_ecv_tbl(j).data_type_code := l_data_type_code;
              lp_ecv_tbl(j).value_type_code := l_value_type_code;
              lp_ecv_tbl(j).source_yn := l_source_yn;
              IF lp_ecv_tbl(j).criterion_value_id IS NULL THEN
                okl_ecv_pvt.insert_row(p_api_version
                                      ,okl_api.g_false
                                      ,l_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,lp_ecv_tbl(j)
                                      ,lx_ecv_tbl(j));

                -- write to log

                IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_statement
                                         ,l_module
                                         ,'Procedure okl_ecv_pvt.insert_row returned with status ' ||
                                          l_return_status);
                END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
                IF (l_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
                ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
                END IF;
              ELSE
                okl_ecv_pvt.update_row(p_api_version
                                      ,okl_api.g_false
                                      ,l_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,lp_ecv_tbl(j)
                                      ,lx_ecv_tbl(j));

                -- write to log

                IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                  okl_debug_pub.log_debug(fnd_log.level_statement
                                         ,l_module
                                         ,'Procedure okl_ecv_pvt.update_row returned with status ' ||
                                          l_return_status);
                END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
                IF (l_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
                ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
                END IF;
              END IF;
              lx_ecv_cons_tbl(k) := lx_ecv_tbl(j);
              k := k + 1;
            END IF;
          END LOOP;  --of Line values
        END IF;
      END LOOP;  --of lines

    ELSE

      --if no lines are present delete header, if header exists

      IF lp_ech_rec.criteria_set_id IS NOT NULL AND lp_ech_rec.criteria_set_id <> okl_api.g_miss_num THEN

        --delete criteria set header

        okl_ech_pvt.delete_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_ech_rec);

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_ech_pvt.delete_row returned with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;
    END IF;

    -- of If lp_ecl_tbl.counbt > 0
    --Assign value to OUT variables

    x_ech_rec := lx_ech_rec;
    x_ecl_tbl := lx_ecl_tbl;
    x_ecv_tbl := lx_ecv_cons_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call handle_eligibility_criteria');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END handle_eligibility_criteria;
/**
    This procedure removes the the criteria line record.
 **/

  PROCEDURE remove_ec_line(p_api_version    IN             number
                          ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                          ,x_return_status     OUT NOCOPY  varchar2
                          ,x_msg_count         OUT NOCOPY  number
                          ,x_msg_data          OUT NOCOPY  varchar2
                          ,p_ecl_rec        IN             okl_ecl_rec) IS
    lp_ecl_rec okl_ecl_rec;
    l_ecv_rec  okl_ecv_rec;

    CURSOR get_lines_values(p_line_id  IN  number) IS
      SELECT criterion_value_id
      FROM   okl_fe_criterion_values
      WHERE  okl_fe_criterion_values.criteria_id = p_line_id;
    l_api_name            CONSTANT varchar2(30) := 'REMOVE_EC_LINE(REC)';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.remove_ec_line';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call remove_ec_line');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lp_ecl_rec := p_ecl_rec;

    --delete line values

    FOR l_ecv_csr_rec IN get_lines_values(lp_ecl_rec.criteria_id) LOOP
      l_ecv_rec.criterion_value_id := l_ecv_csr_rec.criterion_value_id;
      okl_ecv_pvt.delete_row(p_api_version
                            ,okl_api.g_false
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_ecv_rec);

      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

    END LOOP;

    --delete line

    okl_ecl_pvt.delete_row(p_api_version   =>  p_api_version
                          ,p_init_msg_list =>  okl_api.g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_ecl_rec       =>  lp_ecl_rec);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --Assign value to OUT variables

    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call remove_ec_line');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END remove_ec_line;
/**
   This Procedure returns the eligibility criteria attached to source object
   identified by  p_source_id and p_source_type, such that there is overlap
   between p_eff_From-p_eff_to range and the eligibility criteria eff_from
   and eff_to range.
   It also adjusts the effective dates of eligibility criteria to make it fall
   within p_eff_From and p_eff_to.
   This procedure is primarily provided for Standard Rate Template on Lease Rate
   Set scenario, wherein all the eligibility criteria attached to Standard Rate
   Template are queried to attach them to Lease Rate Set.
**/

  PROCEDURE get_eligibility_criteria(p_api_version    IN             number
                                    ,p_init_msg_list  IN             varchar2    DEFAULT fnd_api.g_false
                                    ,x_return_status     OUT NOCOPY  varchar2
                                    ,x_msg_count         OUT NOCOPY  number
                                    ,x_msg_data          OUT NOCOPY  varchar2
                                    ,p_source_id      IN             number
                                    ,p_source_type    IN             varchar2
                                    ,p_eff_from       IN             date
                                    ,p_eff_to         IN             date
                                    ,x_ech_rec           OUT NOCOPY  okl_ech_rec
                                    ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl
                                    ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl) IS
    l_source_id number;

    CURSOR get_ech_rec IS
      SELECT criteria_set_id
            ,object_version_number
            ,match_criteria_code
            ,validation_code
      FROM   okl_fe_criteria_set
      WHERE  source_id = p_source_id AND source_object_code = p_source_type;

    CURSOR get_ecl_tbl(p_criteria_set_id  IN  number) IS
      SELECT criteria_id
            ,object_version_number
            ,criteria_set_id
            ,crit_cat_def_id
            ,match_criteria_code
            ,effective_from_date
            ,effective_to_date
      FROM   okl_fe_criteria
      WHERE  criteria_set_id = p_criteria_set_id;

    CURSOR get_ecv_tbl(p_criteria_id  IN  number) IS
      SELECT criterion_value_id
            ,object_version_number
            ,criteria_id
            ,operator_code
            ,crit_cat_value1
            ,crit_cat_value2
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = p_criteria_id;
    i                              number;
    j                              number;
    l_api_name            CONSTANT varchar2(30) := 'GET_ELIG_CRIT_DT';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_ec_found                     boolean;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.get_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call get_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_source_id := p_source_id;
    OPEN get_ech_rec;
    FETCH get_ech_rec INTO x_ech_rec.criteria_set_id
                          ,x_ech_rec.object_version_number
                          ,x_ech_rec.match_criteria_code
                          ,x_ech_rec.validation_code ;
    l_ec_found := get_ech_rec%FOUND;
    CLOSE get_ech_rec;
    i := 1;
    j := 1;

    IF l_ec_found THEN

      FOR ecl_rec IN get_ecl_tbl(x_ech_rec.criteria_set_id) LOOP

        --if there is overlap of effective dates then only we need to copy

        IF p_eff_from BETWEEN ecl_rec.effective_from_date AND nvl(ecl_rec.effective_to_date
                                                                 ,to_date('01-01-9999'
                                                                         ,'dd-mm-yyyy'))
           OR ecl_rec.effective_from_date BETWEEN p_eff_from AND nvl(p_eff_to
                                                                    ,to_date('01-01-9999'
                                                                            ,'dd-mm-yyyy')) THEN
          x_ecl_tbl(i).criteria_id := ecl_rec.criteria_id;
          x_ecl_tbl(i).object_version_number := ecl_rec.object_version_number;
          x_ecl_tbl(i).criteria_set_id := ecl_rec.criteria_set_id;
          x_ecl_tbl(i).crit_cat_def_id := ecl_rec.crit_cat_def_id;
          x_ecl_tbl(i).match_criteria_code := ecl_rec.match_criteria_code;

          --make effective from consistent with p_eff_From
          --put greater of the two effective from dates as the effective from of fetched ec

          IF ecl_rec.effective_from_date < p_eff_from THEN
            x_ecl_tbl(i).effective_from_date := p_eff_from;
          ELSE
            x_ecl_tbl(i).effective_from_date := ecl_rec.effective_from_date;
          END IF;

          --make effective to consistent with p_eff_to

          x_ecl_tbl(i).effective_to_date := NULL;

          --if both effective dates are null then put effective to of fetched ec as null

          IF p_eff_to IS NULL AND ecl_rec.effective_to_date IS NULL THEN
            x_ecl_tbl(i).effective_to_date := NULL;
          END IF;

          --if one of the eff to dates is null put other as effective to of fetched ec

          IF p_eff_to IS NOT NULL AND ecl_rec.effective_to_date IS NULL THEN
            x_ecl_tbl(i).effective_to_date := p_eff_to;
          END IF;
          IF p_eff_to IS NULL AND ecl_rec.effective_to_date IS NOT NULL THEN
            x_ecl_tbl(i).effective_to_date := ecl_rec.effective_to_date;
          END IF;

          --if both dates are present put whichever is less as effective to of fetched ec

          IF p_eff_to < ecl_rec.effective_to_date THEN
            x_ecl_tbl(i).effective_to_date := p_eff_to;
          END IF;
          IF p_eff_to >= ecl_rec.effective_to_date THEN
            x_ecl_tbl(i).effective_to_date := ecl_rec.effective_to_date;
          END IF;
          FOR ecv_rec IN get_ecv_tbl(x_ecl_tbl(i).criteria_id) LOOP
            x_ecv_tbl(i).criterion_value_id := ecv_rec.criterion_value_id;
            x_ecv_tbl(i).object_version_number := ecv_rec.object_version_number;
            x_ecv_tbl(i).criteria_id := ecv_rec.criteria_id;
            x_ecv_tbl(i).operator_code := ecv_rec.operator_code;
            x_ecv_tbl(i).crit_cat_value1 := ecv_rec.crit_cat_value1;
            x_ecv_tbl(i).crit_cat_value2 := ecv_rec.crit_cat_value2;
            j := j + 1;
          END LOOP;
          i := i + 1;
        END IF;
      END LOOP;

    END IF;
    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call get_eligibility_criteria');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END get_eligibility_criteria;
/**
    This Procedure returns eligibility criteria attached to source object
    identified by  p_source_id and p_source_type
    This procedure can be used wherein all the eligibility criteria  attached
    to a source object are required.
  **/

  PROCEDURE get_eligibility_criteria(p_api_version    IN             number
                                    ,p_init_msg_list  IN             varchar2    DEFAULT fnd_api.g_false
                                    ,x_return_status     OUT NOCOPY  varchar2
                                    ,x_msg_count         OUT NOCOPY  number
                                    ,x_msg_data          OUT NOCOPY  varchar2
                                    ,p_source_id      IN             number
                                    ,p_source_type    IN             varchar2
                                    ,x_ech_rec           OUT NOCOPY  okl_ech_rec
                                    ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl
                                    ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl) IS

    CURSOR get_ech_rec IS
      SELECT criteria_set_id
            ,object_version_number
            ,match_criteria_code
            ,validation_code
      FROM   okl_fe_criteria_set
      WHERE  source_id = p_source_id AND source_object_code = p_source_type;

    CURSOR get_ecl_tbl(p_criteria_set_id  IN  number) IS
      SELECT criteria_id
            ,object_version_number
            ,criteria_set_id
            ,crit_cat_def_id
            ,match_criteria_code
            ,effective_from_date
            ,effective_to_date
      FROM   okl_fe_criteria
      WHERE  criteria_set_id = p_criteria_set_id;

    CURSOR get_ecv_tbl(p_criteria_id  IN  number) IS
      SELECT criterion_value_id
            ,object_version_number
            ,criteria_id
            ,operator_code
            ,crit_cat_value1
            ,crit_cat_value2
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = p_criteria_id;
    i                              number;
    j                              number;
    l_source_id                    number;
    l_source_type                  varchar2(30);
    l_api_name            CONSTANT varchar2(30) := 'GET_ELIG_CRITERIA';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_ec_found                     boolean;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.get_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call get_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_source_id := p_source_id;
    l_source_type := p_source_type;
    OPEN get_ech_rec;
    FETCH get_ech_rec INTO x_ech_rec.criteria_set_id
                          ,x_ech_rec.object_version_number
                          ,x_ech_rec.match_criteria_code
                          ,x_ech_rec.validation_code ;
    l_ec_found := get_ech_rec%FOUND;
    CLOSE get_ech_rec;
    i := 1;
    j := 1;

    IF l_ec_found THEN
      x_ech_rec.source_id := l_source_id;
      x_ech_rec.source_object_code := l_source_type;

      FOR ecl_rec IN get_ecl_tbl(x_ech_rec.criteria_set_id) LOOP
        x_ecl_tbl(i).criteria_id := ecl_rec.criteria_id;
        x_ecl_tbl(i).object_version_number := ecl_rec.object_version_number;
        x_ecl_tbl(i).criteria_set_id := ecl_rec.criteria_set_id;
        x_ecl_tbl(i).crit_cat_def_id := ecl_rec.crit_cat_def_id;
        x_ecl_tbl(i).match_criteria_code := ecl_rec.match_criteria_code;
        x_ecl_tbl(i).effective_from_date := ecl_rec.effective_from_date;
        x_ecl_tbl(i).effective_to_date := ecl_rec.effective_to_date;
        x_ecl_tbl(i).is_new_flag := 'N';
        FOR ecv_rec IN get_ecv_tbl(x_ecl_tbl(i).criteria_id) LOOP
          x_ecv_tbl(i).criterion_value_id := ecv_rec.criterion_value_id;
          x_ecv_tbl(i).object_version_number := ecv_rec.object_version_number;
          x_ecv_tbl(i).criteria_id := ecv_rec.criteria_id;
          x_ecv_tbl(i).operator_code := ecv_rec.operator_code;
          x_ecv_tbl(i).crit_cat_value1 := ecv_rec.crit_cat_value1;
          x_ecv_tbl(i).crit_cat_value2 := ecv_rec.crit_cat_value2;
          j := j + 1;
        END LOOP;
        i := i + 1;
      END LOOP;

    END IF;
    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call get_eligibility_criteria');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END get_eligibility_criteria;
/**
    This procedure puts an end date on the eligibility criteria of the source
    object identified by p_source_id and p_source_type.
    The end date is put only if the current end date is null or is greater than
    the end date that has to be put.
 **/

  PROCEDURE end_date_eligibility_criteria(p_api_version    IN             number
                                         ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                         ,x_return_status     OUT NOCOPY  varchar2
                                         ,x_msg_count         OUT NOCOPY  number
                                         ,x_msg_data          OUT NOCOPY  varchar2
                                         ,p_source_id      IN             number
                                         ,p_source_type    IN             varchar2
                                         ,p_end_date       IN             date) IS

    CURSOR get_ecl_tbl IS
      SELECT ecl.criteria_id
            ,ecl.criteria_set_id
            ,ecl.crit_cat_def_id
            ,ecl.match_criteria_code
            ,ecl.effective_from_date
            ,ecl.effective_to_date
            ,ecl.object_version_number
      FROM   okl_fe_criteria ecl
            ,okl_fe_criteria_set ech
      WHERE  ech.source_id = p_source_id
         AND ech.source_object_code = p_source_type
         AND ecl.criteria_set_id = ech.criteria_set_id;
    i                              number;
    l_source_id                    number;
    l_source_type                  varchar2(30);
    l_ecl_tbl                      okl_ecl_tbl;
    lx_ecl_tbl                     okl_ecl_tbl;
    l_api_name            CONSTANT varchar2(30) := 'END_DT_ELIG_CRIT';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_ec_values_pvt.end_date_eligibility_criteria';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call end_date_eligibility_criteria');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_source_id := p_source_id;
    l_source_type := p_source_type;
    i := 1;

    FOR ecl_rec IN get_ecl_tbl LOOP
      l_ecl_tbl(i).criteria_id := ecl_rec.criteria_id;
      l_ecl_tbl(i).object_version_number := ecl_rec.object_version_number;
      l_ecl_tbl(i).criteria_set_id := ecl_rec.criteria_set_id;
      l_ecl_tbl(i).crit_cat_def_id := ecl_rec.crit_cat_def_id;
      l_ecl_tbl(i).match_criteria_code := ecl_rec.match_criteria_code;
      l_ecl_tbl(i).effective_from_date := ecl_rec.effective_from_date;

      IF ecl_rec.effective_to_date IS NULL THEN
        l_ecl_tbl(i).effective_to_date := p_end_date;
      ELSIF ecl_rec.effective_to_date > p_end_date THEN
        l_ecl_tbl(i).effective_to_date := p_end_date;
      ELSE
        l_ecl_tbl(i).effective_to_date := ecl_rec.effective_to_date;
      END IF;
      l_ecl_tbl(i).is_new_flag := 'N';
      i := i + 1;
    END LOOP;

    IF l_ecl_tbl.COUNT > 0 THEN
      okl_ecl_pvt.update_row(p_api_version
                            ,p_init_msg_list
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_ecl_tbl
                            ,lx_ecl_tbl);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ecl_pvt.update_row returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;
    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call end_date_eligibility_criteria');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END end_date_eligibility_criteria;

END okl_ecc_values_pvt;

/
