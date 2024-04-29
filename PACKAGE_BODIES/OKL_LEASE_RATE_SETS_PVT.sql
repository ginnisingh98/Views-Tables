--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_RATE_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_RATE_SETS_PVT" AS
/* $Header: OKLRLRSB.pls 120.3 2006/07/21 13:12:18 akrangan noship $ */

  g_wf_evt_lrs_pending CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.fe.lrsapproval';
  g_wf_lrs_version_id  CONSTANT varchar2(50) := 'VERSION_ID';

  PROCEDURE create_lease_rate_set(p_api_version    IN             number
                                 ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                 ,x_return_status     OUT NOCOPY  varchar2
                                 ,x_msg_count         OUT NOCOPY  number
                                 ,x_msg_data          OUT NOCOPY  varchar2
                                 ,p_lrtv_rec       IN             lrtv_rec_type
                                 ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                 ,p_lrvv_rec       IN             okl_lrvv_rec
                                 ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS

    CURSOR lrs_unique_chk(p_name  IN  varchar2) IS
      SELECT 'x'
      FROM   okl_ls_rt_fctr_sets_v
      WHERE  name = p_name;

    CURSOR get_eot_version(p_eot_id        number
                          ,p_eff_from  IN  date) IS
      SELECT end_of_term_ver_id
      FROM   okl_fe_eo_term_vers
      WHERE  end_of_term_id = p_eot_id
         AND p_eff_from BETWEEN effective_from_date AND nvl(effective_to_date, p_eff_from + 1)
         AND sts_code = 'ACTIVE';
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_eot_ver_id                   number;
    l_dummy_var                    varchar2(1) := '?';
    l_api_name            CONSTANT varchar2(30) := 'create_lrs';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.create_lease_rate_set';
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
                             ,'begin debug OKLRECCB.pls call create_lease_rate_set');
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

    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --change the name to upper case
    lp_lrtv_rec.name := upper(lp_lrtv_rec.name);

    --check uniqueness of name
    OPEN lrs_unique_chk(lp_lrtv_rec.name);
    FETCH lrs_unique_chk INTO l_dummy_var ;
    CLOSE lrs_unique_chk;

    -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_DUPLICATE_NAME'
                         ,p_token1       =>  'NAME'
                         ,p_token1_value =>  lp_lrtv_rec.name);
      RAISE okl_api.g_exception_error;
    END IF;

    --if lrs type = 'Advance' advance payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'ADVANCE' THEN
      IF lp_lrvv_rec.advance_pmts IS NULL OR lp_lrvv_rec.advance_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.advance_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_ADVANCE_PAYMENTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.deferred_pmts := 0;
    END IF;

    --if lrs type = 'Deferred' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'DEFERRED' THEN
      IF lp_lrvv_rec.deferred_pmts IS NULL OR lp_lrvv_rec.deferred_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.deferred_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_DEFERRED_PMTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if lrs type = 'LEVEL' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'LEVEL' THEN
      lp_lrvv_rec.deferred_pmts := 0;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if no Eot version is available raise error

    l_eot_ver_id := NULL;
    OPEN get_eot_version(lp_lrtv_rec.end_of_term_id
                        ,lp_lrvv_rec.effective_from_date);
    FETCH get_eot_version INTO l_eot_ver_id ;
    CLOSE get_eot_version;

    IF l_eot_ver_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                         ,p_msg_name     =>  'OKL_NO_EOT_VERSION_AVAILABLE'
                         ,p_token1       =>  'EFFECTIVE_FROM'
                         ,p_token1_value =>  lp_lrvv_rec.effective_from_date);
      RAISE okl_api.g_exception_error;
    END IF;

    --set the available eot version id

    lp_lrvv_rec.end_of_term_ver_id := l_eot_ver_id;

    --while creating a new lrs the header status will be NEW
    --header eff from date = version eff from date
    --and header eff to date = version eff to date

    lp_lrtv_rec.sts_code := 'NEW';
    lp_lrtv_rec.start_date := lp_lrvv_rec.effective_from_date;

    IF lp_lrvv_rec.effective_to_date IS NULL OR lp_lrvv_rec.effective_to_date = okl_api.g_miss_date THEN
      lp_lrtv_rec.end_date := NULL;
    ELSE
      lp_lrtv_rec.end_date := lp_lrvv_rec.effective_to_date;
    END IF;

    --if id is not null then this duplicate

    IF lp_lrtv_rec.id IS NOT NULL THEN
      lp_lrtv_rec.orig_rate_set_id := lp_lrtv_rec.id;
    END IF;

    okl_lrt_pvt.insert_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    lp_lrvv_rec.rate_set_id := x_lrtv_rec.id;

    --version number is 1.0
    --version status is new

    lp_lrvv_rec.version_number := '1';
    lp_lrvv_rec.sts_code := 'NEW';
    okl_lrv_pvt.insert_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call create_lease_rate_set');
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
  END create_lease_rate_set;

  PROCEDURE update_lease_rate_set(p_api_version    IN             number
                                 ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                 ,x_return_status     OUT NOCOPY  varchar2
                                 ,x_msg_count         OUT NOCOPY  number
                                 ,x_msg_data          OUT NOCOPY  varchar2
                                 ,p_lrtv_rec       IN             lrtv_rec_type
                                 ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                 ,p_lrvv_rec       IN             okl_lrvv_rec
                                 ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS

    CURSOR get_eot_version(p_eot_id        number
                          ,p_eff_from  IN  date) IS
      SELECT end_of_term_ver_id
      FROM   okl_fe_eo_term_vers
      WHERE  end_of_term_id = p_eot_id
         AND p_eff_from BETWEEN effective_from_date AND nvl(effective_to_date, p_eff_from + 1)
         AND sts_code = 'ACTIVE';
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_old_eot_ver_id               number;
    l_new_eot_ver_id               number := NULL;
    l_min_end_date                 date;
    l_api_name            CONSTANT varchar2(30) := 'update_lrs';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.update_lease_rate_set';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_end_date_ec                  boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRECCB.pls call update_lease_rate_set');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;
    l_end_date_ec := false;
    l_old_eot_ver_id := lp_lrvv_rec.end_of_term_ver_id;

    --if lrs version status = 'ACTIVE' then do effective to validation
    --and if success then put hdr eff to = version eff to

    IF lp_lrvv_rec.sts_code = 'ACTIVE' AND lp_lrvv_rec.effective_to_date IS NOT NULL THEN

      -- if effective to entered by user is less than calculated eff_from -1 then throw error

      l_min_end_date := get_newversion_effective_from(lp_lrvv_rec.rate_set_version_id) - 1;
      IF lp_lrvv_rec.effective_to_date < l_min_end_date THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_INVALID_EFFECTIVE_TO_DATE'
                           ,p_token1       =>  'DATE'
                           ,p_token1_value =>  l_min_end_date);
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrtv_rec.end_date := lp_lrvv_rec.effective_to_date;
      l_end_date_ec := true;
    END IF;

    --if lrs type = 'Advance' advance payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'ADVANCE' THEN
      IF lp_lrvv_rec.advance_pmts IS NULL OR lp_lrvv_rec.advance_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.advance_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_ADVANCE_PAYMENTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.deferred_pmts := 0;
    END IF;

    --if lrs type = 'Deferred' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'DEFERRED' THEN
      IF lp_lrvv_rec.deferred_pmts IS NULL OR lp_lrvv_rec.deferred_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.deferred_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_DEFERRED_PMTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if lrs type = 'LEVEL' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'LEVEL' THEN
      lp_lrvv_rec.deferred_pmts := 0;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if no Eot version is available raise error

    OPEN get_eot_version(lp_lrtv_rec.end_of_term_id
                        ,lp_lrvv_rec.effective_from_date);
    FETCH get_eot_version INTO l_new_eot_ver_id ;
    CLOSE get_eot_version;

    IF l_new_eot_ver_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                         ,p_msg_name     =>  'OKL_NO_EOT_VERSION_AVAILABLE'
                         ,p_token1       =>  'EFFECTIVE_FROM'
                         ,p_token1_value =>  lp_lrvv_rec.effective_from_date);
      RAISE okl_api.g_exception_error;
    END IF;

    --if eot version has changed call remove lrf api to remove all lease rate factors

    IF l_old_eot_ver_id <> l_new_eot_ver_id THEN
      okl_lease_rate_factors_pvt.delete_lease_rate_factors(p_api_version   =>  p_api_version
                                                       ,p_init_msg_list =>  okl_api.g_false
                                                       ,x_return_status =>  l_return_status
                                                       ,x_msg_count     =>  x_msg_count
                                                       ,x_msg_data      =>  x_msg_data
                                                       ,p_lrv_id        =>  lp_lrvv_rec.rate_set_version_id);
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;

    --set the END_OF_TERM_VERSION_ID as the l_new_eot_ver_id

    lp_lrvv_rec.end_of_term_ver_id := l_new_eot_ver_id;

    --always update the header. status and effective dates will come from frontend
    --if hdr status=new then eff from of hdr=eff from of ver and eff to of hdr=eff to of ver

    IF lp_lrtv_rec.sts_code = 'NEW' THEN
      lp_lrtv_rec.start_date := lp_lrvv_rec.effective_from_date;
      IF lp_lrvv_rec.effective_to_date IS NULL OR lp_lrvv_rec.effective_to_date = okl_api.g_miss_date THEN

        -- make effective to date as g_miss_date to so that it nulls out in TAPI

        lp_lrtv_rec.end_date := okl_api.g_miss_date;
        lp_lrvv_rec.effective_to_date := okl_api.g_miss_date;
      ELSE
        lp_lrtv_rec.end_date := lp_lrvv_rec.effective_to_date;
      END IF;
    END IF;

    --update the header

    okl_lrt_pvt.update_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    lp_lrvv_rec.rate_set_id := x_lrtv_rec.id;


    IF lp_lrvv_rec.effective_to_date IS NULL THEN
      lp_lrvv_rec.effective_to_date := okl_api.g_miss_date;
    END IF;
    okl_lrv_pvt.update_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --if we have put end date to active version then we should end date to ec

    IF x_lrvv_rec.effective_to_date IS NOT NULL AND x_lrvv_rec.sts_code = 'ACTIVE' THEN

      --Eligibility Criteria attached to previous version should be end dated
      --with the end date of the previous version. if the end date of eligibility
      --criteria is null or greater than previous version end date, then the
      --api adjusts the end date to the end date of previous lrs version.

      okl_ecc_values_pvt.end_date_eligibility_criteria(p_api_version   =>  g_api_version
                                                      ,p_init_msg_list =>  g_false
                                                      ,x_return_status =>  l_return_status
                                                      ,x_msg_count     =>  x_msg_count
                                                      ,x_msg_data      =>  x_msg_data
                                                      ,p_source_id     =>  lp_lrvv_rec.rate_set_version_id
                                                      ,p_source_type   =>  'LRS'
                                                      ,p_end_date      =>  lp_lrvv_rec.effective_to_date);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ecc_values_pvt.end_date_eligibility_criteria returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call update_lease_rate_set');
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
  END update_lease_rate_set;

  --p_lrv_id is version id of the lrs  we want to version
  --this method should be called only if previous version is existing for the lrs

  FUNCTION get_newversion_effective_from(p_lrv_id   number) RETURN date IS

    -- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets

    CURSOR lrs_lq_csr IS
      SELECT max(qte.expected_start_date) start_date
      FROM   okl_lease_quotes_b qte
            ,okl_fe_rate_set_versions lrv
      WHERE  qte.rate_card_id = lrv.rate_set_version_id
         AND lrv.rate_set_version_id = p_lrv_id;

    -- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets

    CURSOR lrs_qq_csr IS
      SELECT max(qte.expected_start_date) start_date
      FROM   okl_quick_quotes_b qte
            ,okl_fe_rate_set_versions lrv
      WHERE  qte.rate_card_id = lrv.rate_set_version_id
         AND lrv.rate_set_version_id = p_lrv_id;

    --cursor to fetch previous version effective_from and to dates

    CURSOR get_prev_ver_eff_to IS
      SELECT effective_from_date
            ,effective_to_date
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_lrv_id;

    --cursor to fetch maximum of the start date of the eligibility criteria attached to
    --lease rate set.

    CURSOR get_elig_crit_start_date IS
      SELECT max(effective_from_date)
      FROM   okl_fe_criteria_set ech
            ,okl_fe_criteria ecl
      WHERE  ecl.criteria_set_id = ech.criteria_set_id
         AND ech.source_id = p_lrv_id AND source_object_code = 'LRS';
    l_prev_ver_eff_to              date := NULL;
    l_prev_ver_eff_from            date := NULL;
    l_calculated_eff_to            date := NULL;
    l_std_qte_eff_from             date := NULL;
    l_qk_qte_eff_from              date := NULL;
    l_ec_start_date                date := NULL;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.get_newversion_effective_from';
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
                             ,'begin debug OKLRECCB.pls call get_newversion_effective_from');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    --get the previous version effective from and to

    OPEN get_prev_ver_eff_to;
    FETCH get_prev_ver_eff_to INTO l_prev_ver_eff_from
                                  ,l_prev_ver_eff_to ;
    CLOSE get_prev_ver_eff_to;

    --if previous version has effective to date then return  new version effective from as this date+1

    IF l_prev_ver_eff_to IS NOT NULL THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLPLRTB.pls.pls call get_newversion_effective_from');
      END IF;
      RETURN l_prev_ver_eff_to + 1;
    END IF;

    --get max of start dates of standard quotes referencing the lrs header of this version

    OPEN lrs_lq_csr;
    FETCH lrs_lq_csr INTO l_std_qte_eff_from ;
    CLOSE lrs_lq_csr;

    --get max of start dates of quick quotes referencing the lrs header of this version

    OPEN lrs_qq_csr;
    FETCH lrs_qq_csr INTO l_qk_qte_eff_from ;
    CLOSE lrs_qq_csr;

    --take maximum of the above two dates into l_calculated_eff_to

    IF l_std_qte_eff_from IS NULL AND l_qk_qte_eff_from IS NULL THEN
      l_calculated_eff_to := NULL;
    ELSIF l_std_qte_eff_from IS NULL THEN
      l_calculated_eff_to := l_qk_qte_eff_from;
    ELSE
      l_calculated_eff_to := l_std_qte_eff_from;
    END IF;

    --Get the maximum of the start dates of the eligibility criteria
    --attached to lrs version.

    OPEN get_elig_crit_start_date;
    FETCH get_elig_crit_start_date INTO l_ec_start_date ;
    CLOSE get_elig_crit_start_date;

    IF l_ec_start_date IS NOT NULL THEN

      --make l_calculated_eff_to as this maximum start date of ec, if l_calculated_eff_to
      --is less than this maximum start date of ec

      IF l_calculated_eff_to IS NULL THEN
        l_calculated_eff_to := l_ec_start_date;
      ELSIF l_ec_start_date > l_calculated_eff_to THEN
        l_calculated_eff_to := l_ec_start_date;
      END IF;
    END IF;

    --if calculated eff to date and prev version eff to date are null return prev ver eff  from +1

    IF l_calculated_eff_to IS NULL AND l_prev_ver_eff_to IS NULL THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLPLRTB.pls.pls call get_newversion_effective_from');
      END IF;
      RETURN l_prev_ver_eff_from + 1;
    END IF;

    --if calculated eff to date is not null and prev version eff to date is null return calculated eff to date +1

    IF l_calculated_eff_to IS NOT NULL AND l_prev_ver_eff_to IS NULL THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLPLRTB.pls.pls call get_newversion_effective_from');
      END IF;
      RETURN l_calculated_eff_to + 1;
    END IF;

  END get_newversion_effective_from;

  FUNCTION get_lrtv_rec(p_rate_set_id    IN             number
                       ,x_no_data_found     OUT NOCOPY  boolean) RETURN lrtv_rec_type IS

    CURSOR lrtv_pk_csr(p_id  IN  number) IS
      SELECT id
            ,object_version_number
            ,sfwt_flag
            ,try_id
            ,pdt_id
            ,rate
            ,frq_code
            ,arrears_yn
            ,start_date
            ,end_date
            ,name
            ,description
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,sts_code
            ,org_id
            ,currency_code
            ,lrs_type_code
            ,end_of_term_id
      FROM   okl_ls_rt_fctr_sets_v lrtv
      WHERE  id = p_id;
    l_lrtv_rec                     lrtv_rec_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.get_lrtv_rec';
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
                             ,'begin debug OKLRECCB.pls call get_lrtv_rec');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    x_no_data_found := true;
    OPEN lrtv_pk_csr(p_rate_set_id);
    FETCH lrtv_pk_csr INTO l_lrtv_rec.id
                          ,l_lrtv_rec.object_version_number
                          ,l_lrtv_rec.sfwt_flag
                          ,l_lrtv_rec.try_id
                          ,l_lrtv_rec.pdt_id
                          ,l_lrtv_rec.rate
                          ,l_lrtv_rec.frq_code
                          ,l_lrtv_rec.arrears_yn
                          ,l_lrtv_rec.start_date
                          ,l_lrtv_rec.end_date
                          ,l_lrtv_rec.name
                          ,l_lrtv_rec.description
                          ,l_lrtv_rec.created_by
                          ,l_lrtv_rec.creation_date
                          ,l_lrtv_rec.last_updated_by
                          ,l_lrtv_rec.last_update_date
                          ,l_lrtv_rec.last_update_login
                          ,l_lrtv_rec.attribute_category
                          ,l_lrtv_rec.attribute1
                          ,l_lrtv_rec.attribute2
                          ,l_lrtv_rec.attribute3
                          ,l_lrtv_rec.attribute4
                          ,l_lrtv_rec.attribute5
                          ,l_lrtv_rec.attribute6
                          ,l_lrtv_rec.attribute7
                          ,l_lrtv_rec.attribute8
                          ,l_lrtv_rec.attribute9
                          ,l_lrtv_rec.attribute10
                          ,l_lrtv_rec.attribute11
                          ,l_lrtv_rec.attribute12
                          ,l_lrtv_rec.attribute13
                          ,l_lrtv_rec.attribute14
                          ,l_lrtv_rec.attribute15
                          ,l_lrtv_rec.sts_code
                          ,l_lrtv_rec.org_id
                          ,l_lrtv_rec.currency_code
                          ,l_lrtv_rec.lrs_type_code
                          ,l_lrtv_rec.end_of_term_id ;
    x_no_data_found := lrtv_pk_csr%NOTFOUND;
    CLOSE lrtv_pk_csr;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call get_lrtv_rec');
    END IF;
    RETURN(l_lrtv_rec);
  END get_lrtv_rec;

  FUNCTION get_lrvv_rec(p_lrvv_id        IN             number
                       ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_lrvv_rec IS

    CURSOR lrvv_pk_csr(p_id  IN  number) IS
      SELECT rate_set_version_id
            ,object_version_number
            ,arrears_yn
            ,effective_from_date
            ,effective_to_date
            ,rate_set_id
            ,end_of_term_ver_id
            ,std_rate_tmpl_ver_id
            ,adj_mat_version_id
            ,version_number
            ,lrs_rate
            ,rate_tolerance
            ,deferred_pmts
            ,advance_pmts
            ,sts_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
      FROM   okl_fe_rate_set_versions_v
      WHERE  rate_set_version_id = p_id;
    l_lrvv_pk                      lrvv_pk_csr%ROWTYPE;
    l_lrvv_rec                     okl_lrvv_rec;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.get_lrvv_rec';
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
                             ,'begin debug OKLRECCB.pls call get_lrvv_rec');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    x_no_data_found := true;

    --Get current data base values

    OPEN lrvv_pk_csr(p_lrvv_id);
    FETCH lrvv_pk_csr INTO l_lrvv_rec.rate_set_version_id
                          ,l_lrvv_rec.object_version_number
                          ,l_lrvv_rec.arrears_yn
                          ,l_lrvv_rec.effective_from_date
                          ,l_lrvv_rec.effective_to_date
                          ,l_lrvv_rec.rate_set_id
                          ,l_lrvv_rec.end_of_term_ver_id
                          ,l_lrvv_rec.std_rate_tmpl_ver_id
                          ,l_lrvv_rec.adj_mat_version_id
                          ,l_lrvv_rec.version_number
                          ,l_lrvv_rec.lrs_rate
                          ,l_lrvv_rec.rate_tolerance
                          ,l_lrvv_rec.deferred_pmts
                          ,l_lrvv_rec.advance_pmts
                          ,l_lrvv_rec.sts_code
                          ,l_lrvv_rec.created_by
                          ,l_lrvv_rec.creation_date
                          ,l_lrvv_rec.last_updated_by
                          ,l_lrvv_rec.last_update_date
                          ,l_lrvv_rec.last_update_login
                          ,l_lrvv_rec.attribute_category
                          ,l_lrvv_rec.attribute1
                          ,l_lrvv_rec.attribute2
                          ,l_lrvv_rec.attribute3
                          ,l_lrvv_rec.attribute4
                          ,l_lrvv_rec.attribute5
                          ,l_lrvv_rec.attribute6
                          ,l_lrvv_rec.attribute7
                          ,l_lrvv_rec.attribute8
                          ,l_lrvv_rec.attribute9
                          ,l_lrvv_rec.attribute10
                          ,l_lrvv_rec.attribute11
                          ,l_lrvv_rec.attribute12
                          ,l_lrvv_rec.attribute13
                          ,l_lrvv_rec.attribute14
                          ,l_lrvv_rec.attribute15 ;
    x_no_data_found := lrvv_pk_csr%NOTFOUND;
    CLOSE lrvv_pk_csr;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call get_lrvv_rec');
    END IF;
    RETURN(l_lrvv_rec);
  END get_lrvv_rec;

  PROCEDURE version_lease_rate_set(p_api_version    IN             number
                                  ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                  ,x_return_status     OUT NOCOPY  varchar2
                                  ,x_msg_count         OUT NOCOPY  number
                                  ,x_msg_data          OUT NOCOPY  varchar2
                                  ,p_lrtv_rec       IN             lrtv_rec_type
                                  ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                  ,p_lrvv_rec       IN             okl_lrvv_rec
                                  ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS

    CURSOR get_prev_ver_id(p_lrt_id          IN  number
                          ,p_version_number  IN  varchar2) IS
      SELECT rate_set_version_id
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_id = p_lrt_id AND version_number = p_version_number;

    CURSOR get_eot_version(p_eot_id        number
                          ,p_eff_from  IN  date) IS
      SELECT end_of_term_ver_id
      FROM   okl_fe_eo_term_vers
      WHERE  end_of_term_id = p_eot_id
         AND p_eff_from BETWEEN effective_from_date AND nvl(effective_to_date, p_eff_from + 1)
         AND sts_code = 'ACTIVE';
    l_ver_no                       varchar2(30);
    l_lrv_id_prev                  number;
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_lrvv_rec_prev                okl_lrvv_rec;
    x_lrvv_rec_prev                okl_lrvv_rec;
    l_no_data_found                boolean;
    l_eot_ver_id                   number;
    l_new_ver_eff_from             date;
    l_api_name            CONSTANT varchar2(30) := 'version_lrs';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.version_lease_rate_set';
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
                             ,'begin debug OKLRECCB.pls call version_lease_rate_set');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --if lrs type = 'Advance' advance payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'ADVANCE' THEN
      IF lp_lrvv_rec.advance_pmts IS NULL OR lp_lrvv_rec.advance_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.advance_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_ADVANCE_PAYMENTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.deferred_pmts := 0;
    END IF;

    --if lrs type = 'Deferred' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'DEFERRED' THEN
      IF lp_lrvv_rec.deferred_pmts IS NULL OR lp_lrvv_rec.deferred_pmts = okl_api.g_miss_num
         OR lp_lrvv_rec.deferred_pmts <= 0 THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_DEFERRED_PMTS_MANDATORY');
        RAISE okl_api.g_exception_error;
      END IF;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if lrs type = 'LEVEL' deferred payments should be present

    IF lp_lrtv_rec.lrs_type_code = 'LEVEL' THEN
      lp_lrvv_rec.deferred_pmts := 0;
      lp_lrvv_rec.advance_pmts := 0;
    END IF;

    --if no Eot version is available raise error

    OPEN get_eot_version(lp_lrtv_rec.end_of_term_id
                        ,lp_lrvv_rec.effective_from_date);
    FETCH get_eot_version INTO l_eot_ver_id ;
    CLOSE get_eot_version;

    IF l_eot_ver_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                         ,p_msg_name     =>  'OKL_NO_EOT_VERSION_AVAILABLE'
                         ,p_token1       =>  'EFFECTIVE_FROM'
                         ,p_token1_value =>  lp_lrvv_rec.effective_from_date);
      RAISE okl_api.g_exception_error;
    END IF;

    --set the available eot version id

    lp_lrvv_rec.end_of_term_ver_id := l_eot_ver_id;

    -- validate that eff_from of new version is greater than max referenced
    -- quote effective from and previous version effective to (if present)
    --get previous ver id


    l_ver_no := to_char(to_number(lp_lrvv_rec.version_number) - 1);

    OPEN get_prev_ver_id(lp_lrtv_rec.id, l_ver_no);
    FETCH get_prev_ver_id INTO l_lrv_id_prev ;
    CLOSE get_prev_ver_id;
    l_new_ver_eff_from := get_newversion_effective_from(l_lrv_id_prev);

    IF lp_lrvv_rec.effective_from_date < l_new_ver_eff_from THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_INVALID_EFF_FROM'
                         ,p_token1       =>  'MIN_DATE'
                         ,p_token1_value =>  l_new_ver_eff_from);
      RAISE okl_api.g_exception_error;
    END IF;

    --set header status = UNDER_REVISION and ver status =NEW

    lp_lrtv_rec.sts_code := 'UNDER_REVISION';
    lp_lrvv_rec.sts_code := 'NEW';

    --now call the update header to update the status code

    okl_lrt_pvt.update_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    lp_lrvv_rec.rate_set_id := x_lrtv_rec.id;

    --call insert row for creating new version

    okl_lrv_pvt.insert_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call version_lease_rate_set');
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
  END version_lease_rate_set;

  PROCEDURE submit_lease_rate_set(p_api_version          IN             number
                                 ,p_init_msg_list        IN             varchar2                                          DEFAULT okl_api.g_false
                                 ,x_return_status           OUT NOCOPY  varchar2
                                 ,x_msg_count               OUT NOCOPY  number
                                 ,x_msg_data                OUT NOCOPY  varchar2
                                 ,p_rate_set_version_id  IN             okl_fe_rate_set_versions.rate_set_version_id%TYPE) IS

    CURSOR get_prev_ver_id(p_lrt_id          IN  number
                          ,p_version_number  IN  varchar2) IS
      SELECT rate_set_version_id
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_id = p_lrt_id AND version_number = p_version_number;

    CURSOR get_rate_set_id(p_lrv_id  IN  number) IS
      SELECT rate_set_id
            ,effective_from_date
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_rate_set_version_id;

    CURSOR get_ver_no(p_lrv_id   number) IS
      SELECT version_number
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_lrv_id;
    l_ver_no                       varchar2(30);
    lp_lrvv_rec                    okl_lrvv_rec;
    x_lrvv_rec                     okl_lrvv_rec;
    l_prev_ver_no                  varchar2(30);
    l_lrv_id_prev                  number := NULL;
    l_rate_set_id                  number := NULL;
    l_eff_from                     date;
    l_new_ver_eff_from             date;
    l_prev_lrvv_rec                okl_lrvv_rec;
    l_parameter_list               wf_parameter_list_t;
    l_event_name                   wf_events.name%TYPE;
    l_approval_path                varchar2(30) DEFAULT 'NONE';
    l_api_name            CONSTANT varchar2(30) := 'submit_lrs';
    l_api_version         CONSTANT number := 1.0;
    x_no_data_found                boolean;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.submit_lease_rate_set';
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
                             ,'begin debug OKLRECCB.pls call submit_lease_rate_set');
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

    --get the header id from the version id

    OPEN get_rate_set_id(p_rate_set_version_id);
    FETCH get_rate_set_id INTO l_rate_set_id
                              ,l_eff_from ;
    CLOSE get_rate_set_id;

    --get the version number of version to be submitted

    OPEN get_ver_no(p_rate_set_version_id);
    FETCH get_ver_no INTO l_ver_no ;
    CLOSE get_ver_no;

    --if this is the first version then dont do the effective_from validation

    l_prev_ver_no := to_char(to_number(l_ver_no) - 1);
    OPEN get_prev_ver_id(l_rate_set_id, l_prev_ver_no);
    FETCH get_prev_ver_id INTO l_lrv_id_prev ;
    CLOSE get_prev_ver_id;

    --if prev ver id is null then this is the first version, so dont do eff from validation

    IF l_lrv_id_prev IS NOT NULL THEN

      -- if effective from entered by user is less than max of prev version eff_to(if present)
      --and calculated eff_from then throw error

      l_new_ver_eff_from := get_newversion_effective_from(l_lrv_id_prev);
      IF l_eff_from < l_new_ver_eff_from THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_INVALID_EFF_FROM'
                           ,p_token1       =>  'DATE'
                           ,p_token1_value =>  l_new_ver_eff_from);
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    lp_lrvv_rec := get_lrvv_rec(p_rate_set_version_id, x_no_data_found);

    IF (x_no_data_found = true) THEN

      okl_api.set_message(p_app_name =>  g_app_name
                         ,p_msg_name =>  'OKL_NO_VERSION_REC_FOUND');
      RAISE okl_api.g_exception_error;
    END IF;

    --Make version status submitted if it is NEW else raise error
    IF lp_lrvv_rec.sts_code = 'NEW' THEN

      lp_lrvv_rec.sts_code := 'SUBMITTED';
      --call  update row for lp_lrvv_rec

      okl_lrv_pvt.update_row(p_api_version   =>  g_api_version
                            ,p_init_msg_list =>  g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_lrvv_rec      =>  lp_lrvv_rec
                            ,x_lrvv_rec      =>  x_lrvv_rec);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_lrv_pvt.update_row returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

      --read profile for approval path
      l_approval_path := fnd_profile.value('OKL_PE_APPROVAL_PROCESS');

      IF nvl(l_approval_path, 'NONE') = 'NONE' THEN
        okl_lease_rate_sets_pvt.activate_lease_rate_set(p_api_version         =>  p_api_version
                                                       ,p_init_msg_list       =>  p_init_msg_list
                                                       ,x_return_status       =>  l_return_status
                                                       ,x_msg_count           =>  x_msg_count
                                                       ,x_msg_data            =>  x_msg_data
                                                       ,p_rate_set_version_id =>  p_rate_set_version_id);
        IF l_return_status = okl_api.g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      ELSIF nvl(l_approval_path, 'NONE') = 'WF' OR nvl(l_approval_path
                                                      ,'NONE') = 'AME' THEN

        --raise workflow submit event

        l_event_name := g_wf_evt_lrs_pending;

        wf_event.addparametertolist(g_wf_lrs_version_id
                                   ,p_rate_set_version_id
                                   ,l_parameter_list);
	--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);


        okl_wf_pvt.raise_event(p_api_version   =>  p_api_version
                              ,p_init_msg_list =>  p_init_msg_list
                              ,x_return_status =>  l_return_status
                              ,x_msg_count     =>  x_msg_count
                              ,x_msg_data      =>  x_msg_data
                              ,p_event_name    =>  l_event_name
                              ,p_parameters    =>  l_parameter_list);

        IF l_return_status = g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;
    ELSE
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_INVALID_LRS_STATUS');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;

    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call submit_lease_rate_set');
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
  END submit_lease_rate_set;

  PROCEDURE activate_lease_rate_set(p_api_version          IN             number
                                   ,p_init_msg_list        IN             varchar2                                          DEFAULT okl_api.g_false
                                   ,x_return_status           OUT NOCOPY  varchar2
                                   ,x_msg_count               OUT NOCOPY  number
                                   ,x_msg_data                OUT NOCOPY  varchar2
                                   ,p_rate_set_version_id  IN             okl_fe_rate_set_versions.rate_set_version_id%TYPE) IS
    lp_lrvv_rec         okl_lrvv_rec;
    l_prev_lrvv_rec     okl_lrvv_rec;
    x_lrvv_rec          okl_lrvv_rec;
    lp_lrtv_rec         lrtv_rec_type;
    x_lrtv_rec          lrtv_rec_type;
    l_lrv_id_prev       number := NULL;
    l_ver_no            varchar2(30);
    l_new_ver_eff_from  date;
    l_calculated_eff_to date;
    l_dummy             varchar2(1) := '?';
    x_no_data_found     boolean;
    l_rate_set_id       number;
    l_lrs_rate          number;

    CURSOR get_rate_set_id(p_lrv_id  IN  number) IS
      SELECT rate_set_id
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_lrv_id;

    CURSOR get_prev_ver_id(p_lrt_id          IN  number
                          ,p_version_number  IN  varchar2) IS
      SELECT rate_set_version_id
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_id = p_lrt_id AND version_number = p_version_number;

    CURSOR get_interest_rate(p_lrv_id  IN  number) IS
      SELECT nvl(lrs_rate,standard_rate) interest_rate
      FROM   okl_fe_rate_set_versions lrsv
      WHERE  lrsv.rate_set_version_id = p_lrv_id;
    l_ech_rec                      okl_ech_rec;
    l_ecl_tbl                      okl_ecl_tbl;
    l_ecv_tbl                      okl_ecv_tbl;
    lx_ech_rec                     okl_ech_rec;
    lx_ecl_tbl                     okl_ecl_tbl;
    lx_ecv_tbl                     okl_ecv_tbl;
    l_api_name            CONSTANT varchar2(30) := 'activate_lrs';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.activate_lease_rate_set';
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
                             ,'begin debug OKLPLRTB.pls call activate_lease_rate_set');
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

    --get the header id from the version id

    OPEN get_rate_set_id(p_rate_set_version_id);
    FETCH get_rate_set_id INTO l_rate_set_id ;
    CLOSE get_rate_set_id;

    --get the header and version records

    lp_lrtv_rec := get_lrtv_rec(l_rate_set_id, x_no_data_found);

    IF (x_no_data_found = true) THEN

      okl_api.set_message(p_app_name =>  g_app_name
                         ,p_msg_name =>  'OKL_NO_HEADER_REC_FOUND');
      RAISE okl_api.g_exception_error;
    END IF;
    lp_lrvv_rec := get_lrvv_rec(p_rate_set_version_id, x_no_data_found);

    IF (x_no_data_found = true) THEN

      okl_api.set_message(p_app_name =>  g_app_name
                         ,p_msg_name =>  'OKL_NO_VERSION_REC_FOUND');
      RAISE okl_api.g_exception_error;
    END IF;

    --1.Make version status active

    lp_lrvv_rec.sts_code := 'ACTIVE';

    --2.put header eff to date as eff to of this version
    --if eff to is nulkl then make header end date as G_MISS_DATE so that it
    --gets null out in TAPI

    IF lp_lrvv_rec.effective_to_date IS NULL THEN
      lp_lrtv_rec.end_date := okl_api.g_miss_date;
    ELSE
      lp_lrtv_rec.end_date := lp_lrvv_rec.effective_to_date;
    END IF;

    --3.if this is the first version then dont do the effective_from validation

   l_ver_no := to_char(to_number(lp_lrvv_rec.version_number) - 1);
    OPEN get_prev_ver_id(lp_lrtv_rec.id, l_ver_no);
    FETCH get_prev_ver_id INTO l_lrv_id_prev ;
    CLOSE get_prev_ver_id;

    --if prev ver id is null then this is the first version, so dont do eff from validation

    IF l_lrv_id_prev IS NOT NULL THEN

      -- if effective from entered by user is less than max of prev version eff_to(if present)
      --and calculated eff_from then throw error

      IF lp_lrvv_rec.effective_from_date < get_newversion_effective_from(l_lrv_id_prev) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_INVALID_EFF_FROM'
                           ,p_token1       =>  'DATE'
                           ,p_token1_value =>  lp_lrvv_rec.effective_from_date);
        RAISE okl_api.g_exception_error;
      END IF;

      --Put effective to date of previous version as new ver eff from -1

      l_prev_lrvv_rec := get_lrvv_rec(l_lrv_id_prev, x_no_data_found);
      IF (x_no_data_found = true) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
      l_prev_lrvv_rec.effective_to_date := lp_lrvv_rec.effective_from_date - 1;
    END IF;

    --make header status active

    lp_lrtv_rec.sts_code := 'ACTIVE';

    --get the interest rate for which the lease rate factors are calculated and put in version rec

    OPEN get_interest_rate(lp_lrvv_rec.rate_set_version_id);
    FETCH get_interest_rate INTO l_lrs_rate ;
    CLOSE get_interest_rate;

    --as the latest version is getting activated put this interest rate in header rec also

    lp_lrtv_rec.rate := l_lrs_rate;

    --if srt is present on the version to be activated copy ec from the srt to lrs

    IF lp_lrvv_rec.std_rate_tmpl_ver_id IS NOT NULL THEN

      --get the ec attached to srt


      okl_ecc_values_pvt.get_eligibility_criteria(p_api_version   =>  g_api_version
                                                 ,p_init_msg_list =>  g_false
                                                 ,x_return_status =>  l_return_status
                                                 ,x_msg_count     =>  x_msg_count
                                                 ,x_msg_data      =>  x_msg_data
                                                 ,p_source_id     =>  lp_lrvv_rec.std_rate_tmpl_ver_id
                                                 ,p_source_type   =>  'SRT'
                                                 ,p_eff_from      =>  lp_lrvv_rec.effective_from_date
                                                 ,p_eff_to        =>  lp_lrvv_rec.effective_to_date
                                                 ,x_ech_rec       =>  l_ech_rec
                                                 ,x_ecl_tbl       =>  l_ecl_tbl
                                                 ,x_ecv_tbl       =>  l_ecv_tbl);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ecc_values_pvt.get_eligibility_criteria returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

      --delete existing EC on LRS if any


      okl_ecc_values_pvt.delete_eligibility_criteria(p_api_version   =>  p_api_version
                                                    ,p_init_msg_list =>  okl_api.g_false
                                                    ,x_return_status =>  l_return_status
                                                    ,x_msg_count     =>  x_msg_count
                                                    ,x_msg_data      =>  x_msg_data
                                                    ,p_source_id     =>  lp_lrvv_rec.rate_set_version_id
                                                    ,p_source_type   =>  'LRS');

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ecc_values_pvt.delete_eligibility_criteria returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

      --insert the ec only if some ec exists on srt

      IF l_ecl_tbl.COUNT > 0 THEN

        --make the fetched ec as ec of lrs

        l_ech_rec.source_id := lp_lrvv_rec.rate_set_version_id;
        l_ech_rec.source_object_code := 'LRS';

        --prepare ec data to get inserted


        l_ech_rec.criteria_set_id := NULL;

        FOR i IN l_ecl_tbl.FIRST..l_ecl_tbl.LAST LOOP
          l_ecl_tbl(i).is_new_flag := 'Y';
        END LOOP;

        FOR i IN l_ecv_tbl.FIRST..l_ecv_tbl.LAST LOOP
          l_ecv_tbl(i).criterion_value_id := NULL;
          l_ecv_tbl(i).validate_record := 'N';
        END LOOP;

        --call handle_eligibility_criteria

        okl_ecc_values_pvt.handle_eligibility_criteria(p_api_version     =>  g_api_version
                                                      ,p_init_msg_list   =>  g_false
                                                      ,x_return_status   =>  l_return_status
                                                      ,x_msg_count       =>  x_msg_count
                                                      ,x_msg_data        =>  x_msg_data
                                                      ,p_source_eff_from =>  lp_lrvv_rec.effective_from_date
                                                      ,p_source_eff_to   =>  lp_lrvv_rec.effective_to_date
                                                      ,x_ech_rec         =>  lx_ech_rec
                                                      ,x_ecl_tbl         =>  lx_ecl_tbl
                                                      ,x_ecv_tbl         =>  lx_ecv_tbl
                                                      ,p_ech_rec         =>  l_ech_rec
                                                      ,p_ecl_tbl         =>  l_ecl_tbl
                                                      ,p_ecv_tbl         =>  l_ecv_tbl);

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_ecc_values_pvt.handle_eligibility_criteria returned with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF l_return_status = g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;
    END IF;

    IF l_lrv_id_prev IS NOT NULL THEN

      --call update_row for l_prev_lrvv_rec


      okl_lrv_pvt.update_row(p_api_version   =>  g_api_version
                            ,p_init_msg_list =>  g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_lrvv_rec      =>  l_prev_lrvv_rec
                            ,x_lrvv_rec      =>  x_lrvv_rec);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_lrv_pvt.update_row returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

      --Eligibility Criteria attached to previous version should be end dated
      --with the end date of the previous version. if the end date of eligibility
      --criteria is null or greater than previous version end date, then the
      --api adjusts the end date to the end date of previous lrs version.

      okl_ecc_values_pvt.end_date_eligibility_criteria(p_api_version   =>  g_api_version
                                                      ,p_init_msg_list =>  g_false
                                                      ,x_return_status =>  l_return_status
                                                      ,x_msg_count     =>  x_msg_count
                                                      ,x_msg_data      =>  x_msg_data
                                                      ,p_source_id     =>  l_lrv_id_prev
                                                      ,p_source_type   =>  'LRS'
                                                      ,p_end_date      =>  l_prev_lrvv_rec.effective_to_date);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure okl_ecc_values_pvt.end_date_eligibility_criteria returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;

    -- call update row for lp_lrtv_rec
    --update the header

    okl_lrt_pvt.update_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec);

    -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Procedure okl_lrt_pvt.update_row returned with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --call  update row for lp_lrvv_rec

    okl_lrv_pvt.update_row(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Procedure okl_lrv_pvt.update_row returned with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call activate_lease_rate_set');
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
  END activate_lease_rate_set;

  --createAndGenFctrs
  --updateAndGenFctrs
  --versionAndGenFctrs
  --createGenFctrAndSubmit
  --updateGenFctrAndSubmit
  --versionGenFctrAndSubmit

  PROCEDURE create_lrs_gen_lrf(p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrtv_rec       IN             lrtv_rec_type
                              ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                              ,p_lrvv_rec       IN             okl_lrvv_rec
                              ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'create_lrs_gen';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.create_lrs_gen_lrf';
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
                             ,'begin debug OKLRECCB.pls call create_lrs_gen_lrf');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --create the lease rate set

    create_lease_rate_set(p_api_version   =>  g_api_version
                         ,p_init_msg_list =>  g_false
                         ,x_return_status =>  l_return_status
                         ,x_msg_count     =>  x_msg_count
                         ,x_msg_data      =>  x_msg_data
                         ,p_lrtv_rec      =>  lp_lrtv_rec
                         ,x_lrtv_rec      =>  x_lrtv_rec
                         ,p_lrvv_rec      =>  lp_lrvv_rec
                         ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call create_lrs_gen_lrf');
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
  END create_lrs_gen_lrf;

  PROCEDURE update_lrs_gen_lrf(p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrtv_rec       IN             lrtv_rec_type
                              ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                              ,p_lrvv_rec       IN             okl_lrvv_rec
                              ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'update_lrs_gen';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.update_lrs_gen_lrf';
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
                             ,'begin debug OKLRECCB.pls call update_lrs_gen_lrf');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --update the lease rate set

    update_lease_rate_set(p_api_version   =>  g_api_version
                         ,p_init_msg_list =>  g_false
                         ,x_return_status =>  l_return_status
                         ,x_msg_count     =>  x_msg_count
                         ,x_msg_data      =>  x_msg_data
                         ,p_lrtv_rec      =>  lp_lrtv_rec
                         ,x_lrtv_rec      =>  x_lrtv_rec
                         ,p_lrvv_rec      =>  lp_lrvv_rec
                         ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call update_lrs_gen_lrf');
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
  END update_lrs_gen_lrf;

  PROCEDURE version_lrs_gen_lrf(p_api_version    IN             number
                               ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                               ,x_return_status     OUT NOCOPY  varchar2
                               ,x_msg_count         OUT NOCOPY  number
                               ,x_msg_data          OUT NOCOPY  varchar2
                               ,p_lrtv_rec       IN             lrtv_rec_type
                               ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                               ,p_lrvv_rec       IN             okl_lrvv_rec
                               ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'version_lrs_gen';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.version_lrs_gen_lrf';
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
                             ,'begin debug OKLRECCB.pls call version_lrs_gen_lrf');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --version the lease rate set

    version_lease_rate_set(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call version_lrs_gen_lrf');
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
  END version_lrs_gen_lrf;

  PROCEDURE create_lrs_gen_lrf_submit(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'crt_lrs_gen_sub';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.create_lrs_gen_lrf_submit';
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
                             ,'begin debug OKLRECCB.pls call create_lrs_gen_lrf_submit');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --create the lease rate set

    create_lease_rate_set(p_api_version   =>  g_api_version
                         ,p_init_msg_list =>  g_false
                         ,x_return_status =>  l_return_status
                         ,x_msg_count     =>  x_msg_count
                         ,x_msg_data      =>  x_msg_data
                         ,p_lrtv_rec      =>  lp_lrtv_rec
                         ,x_lrtv_rec      =>  x_lrtv_rec
                         ,p_lrvv_rec      =>  lp_lrvv_rec
                         ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --submit the lrs

    submit_lease_rate_set(p_api_version         =>  g_api_version
                         ,p_init_msg_list       =>  g_false
                         ,x_return_status       =>  l_return_status
                         ,x_msg_count           =>  x_msg_count
                         ,x_msg_data            =>  x_msg_data
                         ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call create_lrs_gen_lrf_submit');
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
  END create_lrs_gen_lrf_submit;

  PROCEDURE update_lrs_gen_lrf_submit(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'upd_lrs_gen_sub';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.update_lrs_gen_lrf_submit';
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
                             ,'begin debug OKLRECCB.pls call update_lrs_gen_lrf_submit');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --update the lease rate set

    update_lease_rate_set(p_api_version   =>  g_api_version
                         ,p_init_msg_list =>  g_false
                         ,x_return_status =>  l_return_status
                         ,x_msg_count     =>  x_msg_count
                         ,x_msg_data      =>  x_msg_data
                         ,p_lrtv_rec      =>  lp_lrtv_rec
                         ,x_lrtv_rec      =>  x_lrtv_rec
                         ,p_lrvv_rec      =>  lp_lrvv_rec
                         ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --submit the lrs

    submit_lease_rate_set(p_api_version         =>  g_api_version
                         ,p_init_msg_list       =>  g_false
                         ,x_return_status       =>  l_return_status
                         ,x_msg_count           =>  x_msg_count
                         ,x_msg_data            =>  x_msg_data
                         ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call update_lrs_gen_lrf_submit');
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
  END update_lrs_gen_lrf_submit;

  PROCEDURE version_lrs_gen_lrf_submit(p_api_version    IN             number
                                      ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                      ,x_return_status     OUT NOCOPY  varchar2
                                      ,x_msg_count         OUT NOCOPY  number
                                      ,x_msg_data          OUT NOCOPY  varchar2
                                      ,p_lrtv_rec       IN             lrtv_rec_type
                                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                      ,p_lrvv_rec       IN             okl_lrvv_rec
                                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    l_api_name            CONSTANT varchar2(30) := 'HANDLE_ELIG_CRITERIA';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.version_lrs_gen_lrf_submit';
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
                             ,'begin debug OKLRECCB.pls call version_lrs_gen_lrf_submit');
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
    lp_lrvv_rec := p_lrvv_rec;
    lp_lrtv_rec := p_lrtv_rec;

    --version the lease rate set

    version_lease_rate_set(p_api_version   =>  g_api_version
                          ,p_init_msg_list =>  g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrtv_rec      =>  lp_lrtv_rec
                          ,x_lrtv_rec      =>  x_lrtv_rec
                          ,p_lrvv_rec      =>  lp_lrvv_rec
                          ,x_lrvv_rec      =>  x_lrvv_rec);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --generate lease rate factors

    okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                    ,p_init_msg_list       =>  g_false
                                                    ,x_return_status       =>  l_return_status
                                                    ,x_msg_count           =>  x_msg_count
                                                    ,x_msg_data            =>  x_msg_data
                                                    ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --submit the lrs

    submit_lease_rate_set(p_api_version         =>  g_api_version
                         ,p_init_msg_list       =>  g_false
                         ,x_return_status       =>  l_return_status
                         ,x_msg_count           =>  x_msg_count
                         ,x_msg_data            =>  x_msg_data
                         ,p_rate_set_version_id =>  x_lrvv_rec.rate_set_version_id);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call version_lrs_gen_lrf_submit');
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
  END version_lrs_gen_lrf_submit;

  PROCEDURE validate_eot_version(p_api_version          IN             number
                                ,p_init_msg_list        IN             varchar2 DEFAULT okl_api.g_false
                                ,x_return_status           OUT NOCOPY  varchar2
                                ,x_msg_count               OUT NOCOPY  number
                                ,x_msg_data                OUT NOCOPY  varchar2
                                ,p_eot_id               IN             number
                                ,p_effective_from       IN             date
                                ,p_eot_ver_id           IN             number
                                ,p_rate_set_version_id  IN             number
                                ,x_eot_ver_id              OUT NOCOPY  number
                                ,x_version_number          OUT NOCOPY  varchar2) IS

    CURSOR get_eot_version IS
      SELECT end_of_term_ver_id
            ,version_number
      FROM   okl_fe_eo_term_vers
      WHERE  end_of_term_id = p_eot_id
         AND p_effective_from BETWEEN effective_from_date AND nvl(effective_to_date, p_effective_from + 1)
         AND sts_code = 'ACTIVE';
    l_eot_ver_id                   number;
    l_version_number               varchar2(40);
    l_api_name            CONSTANT varchar2(30) := 'get_eot_ver';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.validate_eot_version';
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
                             ,'begin debug OKLRECCB.pls call validate_eot_version');
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

    --if no Eot version is available raise error

    OPEN get_eot_version;
    FETCH get_eot_version INTO l_eot_ver_id
                              ,l_version_number ;
    CLOSE get_eot_version;

    IF l_eot_ver_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                         ,p_msg_name     =>  'OKL_NO_EOT_VERSION_AVAILABLE'
                         ,p_token1       =>  'EFFECTIVE_FROM'
                         ,p_token1_value =>  p_effective_from);
      RAISE okl_api.g_exception_error;
    END IF;

    IF p_eot_ver_id <> l_eot_ver_id AND p_rate_set_version_id <> NULL THEN


      --delete lrf lines and corressponding levels from the okl_ls_rt_fctr_ents_b and okl_fe_rate_set_levels table for this lrs version

      okl_lease_rate_factors_pvt.delete_lease_rate_factors(p_api_version   =>  p_api_version
                                                       ,p_init_msg_list =>  okl_api.g_false
                                                       ,x_return_status =>  x_return_status
                                                       ,x_msg_count     =>  x_msg_count
                                                       ,x_msg_data      =>  x_msg_data
                                                       ,p_lrv_id        =>  p_rate_set_version_id);
      IF x_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF x_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;
    x_eot_ver_id := l_eot_ver_id;
    x_version_number := l_version_number;
    x_return_status := g_ret_sts_success;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call validate_eot_version');
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
  END validate_eot_version;

  --this api should be called to end date any ACTIVE lrs version

  PROCEDURE enddate_lease_rate_set(p_api_version    IN             number
                                  ,p_init_msg_list  IN             varchar2         DEFAULT okl_api.g_false
                                  ,x_return_status     OUT NOCOPY  varchar2
                                  ,x_msg_count         OUT NOCOPY  number
                                  ,x_msg_data          OUT NOCOPY  varchar2
                                  ,p_lrv_id_tbl     IN             okl_number_table
                                  ,p_end_date       IN             date) IS

    CURSOR is_latest_version(p_rate_set_version_id  IN  number
                            ,p_rate_set_id          IN  number) IS
      SELECT 'X'
      FROM   okl_fe_rate_set_versions
      WHERE  version_number =  (SELECT max(to_number(version_number))
              FROM   okl_fe_rate_set_versions
              WHERE  rate_set_id = p_rate_set_id)
         AND rate_set_version_id = p_rate_set_version_id;

    CURSOR get_not_abn_versions(p_rate_set_version_id  IN  number
                               ,p_rate_set_id          IN  number) IS
      SELECT 'X'
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_id = p_rate_set_id
         AND rate_set_version_id <> p_rate_set_version_id
         AND sts_code <> 'ABANDONED';
    lp_lrvv_rec                    okl_lrvv_rec;
    lx_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    lx_lrtv_rec                    lrtv_rec_type;
    l_lrv_id_list                  varchar2(4000);
    l_no_data_found                boolean;
    l_update_header                boolean;
    l_update_version               boolean;
    l_api_name            CONSTANT varchar2(30) := 'enddate_lrs';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_dummy                        varchar2(1) := '?';
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_sets_pvt.enddate_lease_rate_set';
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
                             ,'begin debug OKLRECCB.pls call enddate_lease_rate_set');
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

    FOR i IN p_lrv_id_tbl.FIRST..p_lrv_id_tbl.LAST LOOP
      lp_lrvv_rec := get_lrvv_rec(p_lrv_id_tbl(i), l_no_data_found);

      IF (l_no_data_found = true) THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_NO_VERSION_REC_FOUND');
        RAISE okl_api.g_exception_error;
      END IF;
      l_update_header := false;
      l_update_version := false;

      IF lp_lrvv_rec.effective_from_date <= p_end_date THEN
        IF lp_lrvv_rec.effective_to_date IS NULL THEN
          lp_lrvv_rec.effective_to_date := p_end_date;
          l_update_version := true;

          --if this is the latest version then put end date on header
          l_dummy := '?';
          OPEN is_latest_version(lp_lrvv_rec.rate_set_version_id
                                ,lp_lrvv_rec.rate_set_id);
          FETCH is_latest_version INTO l_dummy ;
          CLOSE is_latest_version;
          IF l_dummy <> '?' THEN
            lp_lrtv_rec := get_lrtv_rec(lp_lrvv_rec.rate_set_id
                                       ,l_no_data_found);
            IF (l_no_data_found = true) THEN
              okl_api.set_message(p_app_name =>  g_app_name
                                 ,p_msg_name =>  'OKL_NO_HEADER_REC_FOUND');
              RAISE okl_api.g_exception_error;
            END IF;
            lp_lrtv_rec.end_date := p_end_date;
            l_update_header := true;
          END IF;
        END IF;
      ELSE
        lp_lrvv_rec.sts_code := 'ABANDONED';
        l_update_version := true;

        --if all versions are abandoned then make header status as abandoned
        l_dummy := '?';
        OPEN get_not_abn_versions(lp_lrvv_rec.rate_set_version_id
                                 ,lp_lrvv_rec.rate_set_id);
        FETCH get_not_abn_versions INTO l_dummy ;
        CLOSE get_not_abn_versions;
        IF l_dummy = '?' THEN
          lp_lrtv_rec := get_lrtv_rec(lp_lrvv_rec.rate_set_id
                                     ,l_no_data_found);
          IF (l_no_data_found = true) THEN
            okl_api.set_message(p_app_name =>  g_app_name
                               ,p_msg_name =>  'OKL_NO_HEADER_REC_FOUND');
            RAISE okl_api.g_exception_error;
          END IF;
          lp_lrtv_rec.sts_code := 'ABANDONED';
          l_update_header := true;
        END IF;

        --if this is the latest version then put end date on header and version
        l_dummy := '?';
        OPEN is_latest_version(lp_lrvv_rec.rate_set_version_id
                              ,lp_lrvv_rec.rate_set_id);
        FETCH is_latest_version INTO l_dummy ;
        CLOSE is_latest_version;
        IF l_dummy <> '?' THEN

          --put end date on version

          lp_lrvv_rec.effective_to_date := lp_lrvv_rec.effective_from_date;
          l_update_version := true;

          --if header record is not retrieved in previous if condition then
          --retrieve it now

          IF NOT l_update_header THEN
            lp_lrtv_rec := get_lrtv_rec(lp_lrvv_rec.rate_set_id
                                       ,l_no_data_found);
            IF (l_no_data_found = true) THEN
              okl_api.set_message(p_app_name =>  g_app_name
                                 ,p_msg_name =>  'OKL_NO_HEADER_REC_FOUND');
              RAISE okl_api.g_exception_error;
            END IF;
          END IF;

          --put end date on version

          lp_lrtv_rec.end_date := lp_lrvv_rec.effective_from_date;
          l_update_header := true;
        END IF;
      END IF;

      --update the version

      IF l_update_version THEN
        okl_lrv_pvt.update_row(p_api_version   =>  g_api_version
                              ,p_init_msg_list =>  p_init_msg_list
                              ,x_return_status =>  l_return_status
                              ,x_msg_count     =>  x_msg_count
                              ,x_msg_data      =>  x_msg_data
                              ,p_lrvv_rec      =>  lp_lrvv_rec
                              ,x_lrvv_rec      =>  lx_lrvv_rec);
        IF l_return_status = g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;

      --update the header

      IF l_update_header THEN
        okl_lrt_pvt.update_row(p_api_version   =>  g_api_version
                              ,p_init_msg_list =>  p_init_msg_list
                              ,x_return_status =>  l_return_status
                              ,x_msg_count     =>  x_msg_count
                              ,x_msg_data      =>  x_msg_data
                              ,p_lrtv_rec      =>  lp_lrtv_rec
                              ,x_lrtv_rec      =>  lx_lrtv_rec);
        IF l_return_status = g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;

    END LOOP;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLPLRTB.pls.pls call enddate_lease_rate_set');
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
  END enddate_lease_rate_set;

END okl_lease_rate_sets_pvt;

/
