--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_RATE_FACTORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_RATE_FACTORS_PVT" AS
/* $Header: OKLRLRFB.pls 120.4 2006/03/27 05:34:04 asawanka noship $ */

  /**
      This procedure inserts/updates the lease rate factors and levels.
      If p_lrfv_tbl(i).IS_NEW_FLAG = 'Y' then record is inserted else updated.
      If p_lrlv_tbl(i).rate_Set_level_id=null then record is inserted else updated.
      p_lrlv_tbl(i).(i).rate_set_factor_id should be pointing to appropriate record in
      p_lrfv_tbl, to identify the levels corressponding to factor.
  **/

  PROCEDURE handle_lrf_ents(p_api_version    IN             number
                           ,p_init_msg_list  IN             varchar2      DEFAULT fnd_api.g_false
                           ,x_return_status     OUT NOCOPY  varchar2
                           ,x_msg_count         OUT NOCOPY  number
                           ,x_msg_data          OUT NOCOPY  varchar2
                           ,p_lrfv_tbl       IN             lrfv_tbl_type
                           ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                           ,p_lrlv_tbl       IN             okl_lrlv_tbl
                           ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl) IS
    lp_lrfv_tbl                    lrfv_tbl_type;
    lx_lrfv_tbl                    lrfv_tbl_type;
    lp_lrlv_tbl                    okl_lrlv_tbl;
    lx_lrlv_tbl                    okl_lrlv_tbl;
    lp_lrfv_crt_tbl                lrfv_tbl_type;
    lx_lrfv_crt_tbl                lrfv_tbl_type;
    lp_lrfv_upd_tbl                lrfv_tbl_type;
    lx_lrfv_upd_tbl                lrfv_tbl_type;
    l_api_name            CONSTANT varchar2(30) := 'handle_lrf_ents';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.handle_lrf_ents';
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
                             ,'begin debug OKLPLRFB.pls call handle_lrf_ents');
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
    lp_lrfv_tbl := p_lrfv_tbl;
    lp_lrlv_tbl := p_lrlv_tbl;  -- call validate_periods to see sum of periods = term/frequency

    FOR i IN lp_lrfv_tbl.FIRST..lp_lrfv_tbl.LAST LOOP

      IF (lp_lrfv_tbl(i).is_new_flag = 'Y') THEN
        okl_lrf_pvt.insert_row(l_api_version
                              ,g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_lrfv_tbl(i)
                              ,lx_lrfv_tbl(i));

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_lrf_pvt.insert_row with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
        FOR j IN lp_lrlv_tbl.FIRST..lp_lrlv_tbl.LAST LOOP

          --if the ecl_id in lp_ecv_tbl(i) is same as the id in the recently inserter record
          -- in okl_ec_lines table then

          IF (lp_lrlv_tbl(j).rate_set_factor_id = lp_lrfv_tbl(i).id) THEN

            --populate the ecl_id with the id of the recently inserted record in okl_ec_lines tablein the

            lp_lrlv_tbl(j).rate_set_factor_id := lx_lrfv_tbl(i).id;
            IF (lp_lrlv_tbl(j).rate_set_level_id IS NULL) THEN
              okl_lrl_pvt.insert_row(l_api_version
                                    ,g_false
                                    ,l_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,lp_lrlv_tbl(j)
                                    ,lx_lrlv_tbl(j));

              -- write to log

              IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'Procedure okl_lrl_pvt.insert_row with status ' ||
                                        l_return_status);
              END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
              END IF;
            ELSE
              okl_lrl_pvt.update_row(l_api_version
                                    ,g_false
                                    ,l_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,lp_lrlv_tbl(j)
                                    ,lx_lrlv_tbl(j));

              -- write to log

              IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'Procedure okl_lrl_pvt.update_row with status ' ||
                                        l_return_status);
              END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
              END IF;
            END IF;
          END IF;
        END LOOP;
      ELSE
        okl_lrf_pvt.update_row(l_api_version
                              ,g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_lrfv_tbl(i)
                              ,lx_lrfv_tbl(i));

        -- write to log

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'Procedure okl_lrf_pvt.update_row with status ' ||
                                  l_return_status);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
        FOR j IN lp_lrlv_tbl.FIRST..lp_lrlv_tbl.LAST LOOP

          --if the ecl_id in lp_ecv_tbl(i) is same as the id in the recently inserter record
          -- in okl_ec_lines table then

          IF (lp_lrlv_tbl(j).rate_set_factor_id = lp_lrfv_tbl(i).id) THEN  --populate the ecl_id with the id of the recently inserted record in okl_ec_lines tablein the
            lp_lrlv_tbl(j).rate_set_factor_id := lx_lrfv_tbl(i).id;
            IF (lp_lrlv_tbl(j).rate_set_level_id IS NULL) THEN
              okl_lrl_pvt.insert_row(l_api_version
                                    ,g_false
                                    ,l_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,lp_lrlv_tbl(j)
                                    ,lx_lrlv_tbl(j));

              -- write to log

              IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'Procedure okl_lrl_pvt.insert_row with status ' ||
                                        l_return_status);
              END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
              END IF;
            ELSE
              okl_lrl_pvt.update_row(l_api_version
                                    ,g_false
                                    ,l_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,lp_lrlv_tbl(j)
                                    ,lx_lrlv_tbl(j));

              -- write to log

              IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_statement
                                       ,l_module
                                       ,'Procedure okl_lrl_pvt.update_row with status ' ||
                                        l_return_status);
              END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
              IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;

    END LOOP;  --Assign value to OUT variables
    x_lrfv_tbl := lx_lrfv_tbl;
    x_lrlv_tbl := lx_lrlv_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call handle_lrf_ents');
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
  END handle_lrf_ents;
/**
    This procedure deletes all the lease rate factors and corressponding levels
    for rate set version id p_lrv_id.
**/

  PROCEDURE delete_lease_rate_factors(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrv_id         IN             number) IS
    l_lrv_id   number;
    l_lrlv_tbl okl_lrlv_tbl;
    l_lrfv_tbl lrfv_tbl_type;

    CURSOR get_lrf_tbl IS
      SELECT id
      FROM   okl_ls_rt_fctr_ents
      WHERE  rate_set_version_id = p_lrv_id;

    CURSOR get_lrl_tbl IS
      SELECT rate_set_level_id
      FROM   okl_fe_rate_set_levels
      WHERE  rate_set_version_id = p_lrv_id;
    i                              number;
    l_api_name            CONSTANT varchar2(30) := 'delete_lrf';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.delete_lease_rate_factors';
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
                             ,'begin debug OKLPLRFB.pls call delete_lease_rate_factors');
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
    l_lrv_id := p_lrv_id;

    --populate factors table with all the factors of rate_Set_version_id

    i := 1;

    FOR lrf_rec IN get_lrf_tbl LOOP
      l_lrfv_tbl(i).id := lrf_rec.id;
      i := i + 1;
    END LOOP;

    --populate levels table with all the levels of rate_Set_version_id

    i := 1;

    FOR lrl_rec IN get_lrl_tbl LOOP
      l_lrlv_tbl(i).rate_set_level_id := lrl_rec.rate_set_level_id;
      i := i + 1;
    END LOOP;

    --delete all levels

    IF l_lrlv_tbl.COUNT > 0 THEN
      okl_lrl_pvt.delete_row(p_api_version   =>  p_api_version
                            ,p_init_msg_list =>  okl_api.g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_lrlv_tbl      =>  l_lrlv_tbl);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure OKL_LRL_PVT.delete_row returned with status ' ||
                                l_return_status);
      END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;

    --delete all factors

    IF l_lrfv_tbl.COUNT > 0 THEN
      okl_lrf_pvt.delete_row(p_api_version   =>  p_api_version
                            ,p_init_msg_list =>  okl_api.g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_lrfv_tbl      =>  l_lrfv_tbl);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure OKL_LRF_PVT.delete_row returned with status ' ||
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
                             ,'end debug OKLRECVB.pls.pls call delete_lease_rate_factors');
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
  END delete_lease_rate_factors;
/**
    This procedure deletes the lease rate factor row and its corressponding
    levels.
 **/

  PROCEDURE remove_lrs_factor (p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT fnd_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrfv_rec       IN             lrfv_rec_type) IS
    l_lrfv_rec lrfv_rec_type;
    l_lrlv_tbl okl_lrlv_tbl;

    CURSOR get_lrl_tbl IS
      SELECT rate_set_level_id
      FROM   okl_fe_rate_set_levels
      WHERE  rate_set_factor_id = p_lrfv_rec.id;
    i                              number;
    l_api_name            CONSTANT varchar2(30) := 'rmv_lrs_factor';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.remove_lrs_factor';
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
                             ,'begin debug OKLPLRFB.pls call remove_lrs_factor');
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
    l_lrfv_rec := p_lrfv_rec;

    --populate levels table with all the levels of rate_Set_version_id

    i := 1;

    FOR lrl_rec IN get_lrl_tbl LOOP
      l_lrlv_tbl(i).rate_set_level_id := lrl_rec.rate_set_level_id;
      i := i + 1;
    END LOOP;

    --delete all levels

    IF l_lrlv_tbl.COUNT > 0 THEN
      okl_lrl_pvt.delete_row(p_api_version   =>  p_api_version
                            ,p_init_msg_list =>  okl_api.g_false
                            ,x_return_status =>  l_return_status
                            ,x_msg_count     =>  x_msg_count
                            ,x_msg_data      =>  x_msg_data
                            ,p_lrlv_tbl      =>  l_lrlv_tbl);
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;  --delete factor row
    okl_lrf_pvt.delete_row(p_api_version   =>  p_api_version
                          ,p_init_msg_list =>  okl_api.g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrfv_rec      =>  l_lrfv_rec);

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
                             ,'end debug OKLRECVB.pls.pls call remove_lrs_factor');
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
  END remove_lrs_factor;
/**
    This procedure deletes the lease rate factor level.
 **/

  PROCEDURE remove_lrs_level(p_api_version    IN             number
                            ,p_init_msg_list  IN             varchar2     DEFAULT fnd_api.g_false
                            ,x_return_status     OUT NOCOPY  varchar2
                            ,x_msg_count         OUT NOCOPY  number
                            ,x_msg_data          OUT NOCOPY  varchar2
                            ,p_lrlv_rec       IN             okl_lrlv_rec) IS
    l_lrlv_rec                     okl_lrlv_rec;
    l_api_name            CONSTANT varchar2(30) := 'rmv_lrs_level';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.remove_lrs_level';
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
                             ,'begin debug OKLPLRFB.pls call remove_lrs_level');
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
    l_lrlv_rec := p_lrlv_rec;
    okl_lrl_pvt.delete_row(p_api_version   =>  p_api_version
                          ,p_init_msg_list =>  okl_api.g_false
                          ,x_return_status =>  l_return_status
                          ,x_msg_count     =>  x_msg_count
                          ,x_msg_data      =>  x_msg_data
                          ,p_lrlv_rec      =>  l_lrlv_rec);

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
                             ,'end debug OKLRECVB.pls.pls call remove_lrs_level');
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
  END remove_lrs_level;
/**
    This function does the following validations:
    1. At least one lease rate factor row should be present.
    2. Term should be multiple of frequency.
    3. Sum of periods in all levels corressponding to the lease rate factor
       should be equal to the term.
 **/

  FUNCTION validate_factor_levels(p_lrfv_tbl  IN  lrfv_tbl_type
                                 ,p_lrlv_tbl  IN  okl_lrlv_tbl
                                 ,p_freq      IN  varchar2) RETURN varchar2 IS
    l_freq                         number;
    l_payments                     number;
    l_periods                      number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.validate_factor_levels';
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
                             ,'begin debug OKLPLRFB.pls call validate_factor_levels');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    --at least 1 rate factor should be present

    IF p_lrfv_tbl.COUNT = 0 THEN
      okl_api.set_message(p_app_name =>  g_app_name
                         ,p_msg_name =>  'OKL_RATE_FACTOR_NOT_PRESENT');
      RETURN okl_api.g_ret_sts_error;
    END IF;

    SELECT decode(p_freq, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)
    INTO   l_freq
    FROM   dual;

    FOR i IN p_lrfv_tbl.FIRST..p_lrfv_tbl.LAST LOOP

      --term should be exact multiple of frequency

      IF p_lrfv_tbl(i).term_in_months MOD l_freq <> 0 THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_TERM_NOT_MULT_OF_FREQ'
                           ,p_token1       =>  'TERM'
                           ,p_token1_value =>  p_lrfv_tbl(i).term_in_months);
        RETURN okl_api.g_ret_sts_error;
      END IF;
      l_payments := p_lrfv_tbl(i).term_in_months / l_freq;
      l_periods := 0;

      --at least 1 rate factor leval should be present

      IF p_lrlv_tbl.COUNT = 0 THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_LEVEL_NOT_PRESENT'
                           ,p_token1       =>  'TERM'
                           ,p_token1_value =>  p_lrfv_tbl(i).term_in_months);
        RETURN okl_api.g_ret_sts_error;
      END IF;  --sum of periods of all levels(of the factor) should be equal to total payments for the term

      FOR j IN p_lrlv_tbl.FIRST..p_lrlv_tbl.LAST LOOP

        IF p_lrlv_tbl(j).rate_set_factor_id = p_lrfv_tbl(i).id THEN
          l_periods := l_periods + p_lrlv_tbl(j).periods;
        END IF;

      END LOOP;

      IF l_payments <> l_periods THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_PERIODS_NOT_EQ_PAYMENTS'
                           ,p_token1       =>  'TERM'
                           ,p_token1_value =>  p_lrfv_tbl(i).term_in_months);
        RETURN okl_api.g_ret_sts_error;
      END IF;

    END LOOP;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call validate_factor_levels');
    END IF;
    RETURN okl_api.g_ret_sts_success;
  END validate_factor_levels;
/**
    This function validates whether the residual tolerance is less than or equal
    to the minimum of the difference between the residual values.
**/

  FUNCTION is_residual_tolerance_valid(p_lrfv_tbl            IN  lrfv_tbl_type
                                      ,p_residual_tolerance      number) RETURN boolean IS
    mindiff                        number;
    diffij                         number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.is_residual_tolerance_valid';
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
                             ,'begin debug OKLPLRFB.pls call is_residual_tolerance_valid');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    IF p_residual_tolerance = 0 OR p_lrfv_tbl.COUNT = 1 THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECVB.pls.pls call is_residual_tolerance_valid');
      END IF;
      RETURN true;
    END IF;
    mindiff := abs(p_lrfv_tbl(1).residual_value_percent - p_lrfv_tbl(2).residual_value_percent);

    --find the minimum difference between residual_value_percent

    FOR i IN p_lrfv_tbl.FIRST..p_lrfv_tbl.LAST - 1 LOOP
      FOR j IN i + 1..p_lrfv_tbl.LAST LOOP
        diffij := abs(p_lrfv_tbl(i).residual_value_percent - p_lrfv_tbl(j).residual_value_percent);

        IF diffij < mindiff THEN
          mindiff := diffij;
        END IF;

      END LOOP;
    END LOOP;

    IF p_residual_tolerance >= mindiff / 2 THEN
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECVB.pls.pls call is_residual_tolerance_valid');
      END IF;
      RETURN false;
    ELSE
      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'end debug OKLRECVB.pls.pls call is_residual_tolerance_valid');
      END IF;
      RETURN true;
    END IF;

  END is_residual_tolerance_valid;
/**
    This function returns the rate from the standard rate template version,
    If standard rate template is of type INDEX, it takes the rate from OKL_INDEX_VALUES.
**/

  FUNCTION get_rate_from_srt(p_srt_version_id  IN  number
                            ,p_lrs_eff_from    IN  date) RETURN number IS

    CURSOR get_srt_type_rate(csr_std_rate_tmpl_ver_id  IN  number) IS
      SELECT a.rate_type_code
            ,(b.srt_rate+nvl(b.spread,0)) srt_rate
            ,min_adj_rate
            ,max_adj_rate
      FROM   okl_fe_std_rt_tmp_v a
            ,okl_fe_std_rt_tmp_vers b
      WHERE  a.std_rate_tmpl_id = b.std_rate_tmpl_id
         AND b.std_rate_tmpl_ver_id = csr_std_rate_tmpl_ver_id;

    CURSOR get_srt_index_rate(csr_std_rate_tmpl_ver_id  IN  number
                             ,lrs_eff_from              IN  date) IS
      SELECT (c.value+nvl(b.spread,0)) value
      FROM   okl_fe_std_rt_tmp_v a
            ,okl_fe_std_rt_tmp_vers b
            ,okl_index_values c
      WHERE  a.std_rate_tmpl_id = b.std_rate_tmpl_id AND a.index_id = c.idx_id
         AND b.std_rate_tmpl_ver_id = csr_std_rate_tmpl_ver_id
         AND lrs_eff_from BETWEEN c.datetime_valid AND nvl(c.datetime_invalid, lrs_eff_from + 1);
    l_rate                         number;
    l_srt_type                     varchar2(30);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.get_rate_from_srt';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_min_adj_rate                 NUMBER;
    l_max_adj_rate                 NUMBER;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLPLRFB.pls call get_rate_from_srt');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);
    l_rate := NULL;
    OPEN get_srt_type_rate(p_srt_version_id);
    FETCH get_srt_type_rate INTO l_srt_type
                                ,l_rate
                                ,l_min_adj_rate
                                ,l_max_adj_rate ;
    CLOSE get_srt_type_rate;

    --if srt is of index rate type take rate from okl_index_values for lrs version effective from

    IF l_srt_type = 'INDEX' THEN
      OPEN get_srt_index_rate(p_srt_version_id, p_lrs_eff_from);
      FETCH get_srt_index_rate INTO l_rate ;
      CLOSE get_srt_index_rate;
    END IF;

    IF l_rate IS NOT NULL THEN
      IF l_min_adj_rate IS NOT NULL THEN
        IF l_rate < l_min_adj_rate THEN
         l_rate := l_min_adj_rate;
        END IF;
      END IF;
      IF l_max_adj_rate IS NOT NULL THEN
        IF l_rate > l_max_adj_rate THEN
         l_rate := l_max_adj_rate;
        END IF;
      END IF;
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call get_rate_from_srt');
    END IF;
    RETURN l_rate;
  END get_rate_from_srt;
/**
    This function validates if the term-value are unique or not.
**/

  FUNCTION validate_unique_term_values(p_lrfv_tbl  IN  lrfv_tbl_type) RETURN varchar2 IS
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.validate_unique_term_values';
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
                             ,'begin debug OKLPLRFB.pls call validate_unique_term_values');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    IF p_lrfv_tbl.COUNT > 0 THEN

      FOR i IN p_lrfv_tbl.FIRST..p_lrfv_tbl.LAST - 1 LOOP
        FOR j IN i + 1..p_lrfv_tbl.LAST LOOP
          IF p_lrfv_tbl(i).term_in_months = p_lrfv_tbl(j).term_in_months
             AND p_lrfv_tbl(i).residual_value_percent = p_lrfv_tbl(j).residual_value_percent THEN
            okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                               ,p_msg_name     =>  'OKL_DUPLICATE_TERM_VALUE'
                               ,p_token1       =>  'TERM'
                               ,p_token1_value =>  p_lrfv_tbl(i).term_in_months
                               ,p_token2       =>  'VALUE'
                               ,p_token2_value =>  p_lrfv_tbl(i).residual_value_percent);
            RETURN okl_api.g_ret_sts_error;
          END IF;
        END LOOP;
      END LOOP;

    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECVB.pls.pls call validate_unique_term_values');
    END IF;
    RETURN okl_api.g_ret_sts_success;
  END validate_unique_term_values;
/**
    This procedure deletes the existing lease rate factors for a lease rate set
    version.
**/

  PROCEDURE handle_lease_rate_factors(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,p_lrfv_tbl       IN             lrfv_tbl_type
                                     ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                                     ,p_lrlv_tbl       IN             okl_lrlv_tbl
                                     ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    lp_lrlv_tbl                    okl_lrlv_tbl;
    lp_lrfv_tbl                    lrfv_tbl_type;
    l_rate                         number;
    l_api_name            CONSTANT varchar2(30) := 'handle_lrf';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.handle_lease_rate_factors';
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
                             ,'begin debug OKLPLRFB.pls call handle_lease_rate_factors');
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
    lp_lrfv_tbl := p_lrfv_tbl;
    lp_lrlv_tbl := p_lrlv_tbl;

    --derive the rate from srt if no rate is present on lrs

    IF lp_lrvv_rec.lrs_rate IS NULL  OR lp_lrvv_rec.lrs_rate = okl_api.g_miss_num THEN
      l_rate := get_rate_from_srt(lp_lrvv_rec.std_rate_tmpl_ver_id
                                 ,lp_lrvv_rec.effective_from_date);
    ELSE
      l_rate := lp_lrvv_rec.lrs_rate;
    END IF;

    IF l_rate IS NULL THEN
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_RATE_UNDETERMINED_FOR_LRS');
      RAISE okl_api.g_exception_error;
    END IF;

    --validate that no duplicate term value pairs are present

    l_return_status := validate_unique_term_values(lp_lrfv_tbl);

    IF l_return_status = okl_api.g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --validate the rate factors and levels

    l_return_status := validate_factor_levels(p_lrfv_tbl =>  lp_lrfv_tbl
                                             ,p_lrlv_tbl =>  lp_lrlv_tbl
                                             ,p_freq     =>  lp_lrtv_rec.frq_code);

    -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Procedure validate_factor_levels with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --validate the residual tolerance
    --residual tolerance should not be greater than (min of difference between pairs of residual values)
    IF lp_lrvv_rec.residual_tolerance = okl_api.g_miss_num THEN
      lp_lrvv_rec.residual_tolerance := 0;
    END IF;
    IF NOT is_residual_tolerance_valid(lp_lrfv_tbl
                                      ,nvl(lp_lrvv_rec.residual_tolerance
                                          ,0)) THEN
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_INVALID_RESIDUAL_TOLERANCE');
      RAISE okl_api.g_exception_error;
    END IF;

    --set the foreign key values and interest rate

    FOR i IN lp_lrfv_tbl.FIRST..lp_lrfv_tbl.LAST LOOP
      lp_lrfv_tbl(i).is_new_flag := 'Y';
      lp_lrfv_tbl(i).lrt_id := lp_lrtv_rec.id;
      lp_lrfv_tbl(i).rate_set_version_id := lp_lrvv_rec.rate_set_version_id;
      lp_lrfv_tbl(i).interest_rate := l_rate;
    END LOOP;

    FOR i IN lp_lrlv_tbl.FIRST..lp_lrlv_tbl.LAST LOOP
      lp_lrlv_tbl(i).rate_set_level_id := NULL;
      lp_lrlv_tbl(i).rate_set_id := lp_lrtv_rec.id;
      lp_lrlv_tbl(i).rate_set_version_id := lp_lrvv_rec.rate_set_version_id;
    END LOOP;

    --delete existing rate factors for lp_lrvv_rec.rate_Set_version_id
    --we need to delete as eot version might have changed so existing lrfs, term value pairs  are not valid.
    --also user has changed the existing lrf values

    delete_lease_rate_factors(p_api_version   =>  p_api_version
                             ,p_init_msg_list =>  okl_api.g_false
                             ,x_return_status =>  l_return_status
                             ,x_msg_count     =>  x_msg_count
                             ,x_msg_data      =>  x_msg_data
                             ,p_lrv_id        =>  lp_lrvv_rec.rate_set_version_id);

    -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Procedure delete_lease_rate_factors with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --call handlelrf API  to insert levels and factors

    IF lp_lrfv_tbl.COUNT > 0 THEN
      handle_lrf_ents(p_api_version   =>  p_api_version
                     ,p_init_msg_list =>  okl_api.g_false
                     ,x_return_status =>  l_return_status
                     ,x_msg_count     =>  x_msg_count
                     ,x_msg_data      =>  x_msg_data
                     ,p_lrfv_tbl      =>  lp_lrfv_tbl
                     ,x_lrfv_tbl      =>  x_lrfv_tbl
                     ,p_lrlv_tbl      =>  lp_lrlv_tbl
                     ,x_lrlv_tbl      =>  x_lrlv_tbl);

      -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'Procedure handle_lrf_ents with status ' ||
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
                             ,'end debug OKLRECVB.pls.pls call handle_lease_rate_factors');
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
  END handle_lease_rate_factors;
/**
    This procedure is a wrapper to insert/update the lease rate factors and
    submit the lease rate set for approval.
 **/

  PROCEDURE handle_lrf_submit(p_api_version    IN             number
                             ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                             ,x_return_status     OUT NOCOPY  varchar2
                             ,x_msg_count         OUT NOCOPY  number
                             ,x_msg_data          OUT NOCOPY  varchar2
                             ,p_lrtv_rec       IN             lrtv_rec_type
                             ,p_lrvv_rec       IN             okl_lrvv_rec
                             ,p_lrfv_tbl       IN             lrfv_tbl_type
                             ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                             ,p_lrlv_tbl       IN             okl_lrlv_tbl
                             ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl) IS
    lp_lrvv_rec                    okl_lrvv_rec;
    lp_lrtv_rec                    lrtv_rec_type;
    lp_lrlv_tbl                    okl_lrlv_tbl;
    lp_lrfv_tbl                    lrfv_tbl_type;
    l_rate                         number;
    l_api_name            CONSTANT varchar2(30) := 'handle_lrf_submit';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lease_rate_factors_pvt.handle_lrf_submit';
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
                             ,'begin debug OKLPLRFB.pls call handle_lrf_submit');
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
    lp_lrfv_tbl := p_lrfv_tbl;
    lp_lrlv_tbl := p_lrlv_tbl;

    --derive the rate from srt if no rate is present on lrs

    IF lp_lrvv_rec.lrs_rate IS NULL OR lp_lrvv_rec.lrs_rate =  okl_api.g_miss_num THEN
      l_rate := get_rate_from_srt(lp_lrvv_rec.std_rate_tmpl_ver_id
                                 ,lp_lrvv_rec.effective_from_date);
    ELSE
      l_rate := lp_lrvv_rec.lrs_rate;
    END IF;

    IF l_rate IS NULL THEN
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_RATE_UNDETERMINED_FOR_LRS');
      RAISE okl_api.g_exception_error;
    END IF;

    --validate that no duplicate term value pairs are present

    l_return_status := validate_unique_term_values(lp_lrfv_tbl);

    IF l_return_status = okl_api.g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --validate the rate factors and levels

    l_return_status := validate_factor_levels(p_lrfv_tbl =>  lp_lrfv_tbl
                                             ,p_lrlv_tbl =>  lp_lrlv_tbl
                                             ,p_freq     =>  lp_lrtv_rec.frq_code);

    IF l_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --validate the residual tolerance
    --residual tolerance should not be greater than (min of difference between pairs of residual values)
    IF lp_lrvv_rec.residual_tolerance = okl_api.g_miss_num THEN
      lp_lrvv_rec.residual_tolerance := 0;
    END IF;
    IF NOT is_residual_tolerance_valid(lp_lrfv_tbl
                                      ,nvl(lp_lrvv_rec.residual_tolerance
                                          ,0)) THEN
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_INVALID_RESIDUAL_TOLERANCE');
      RAISE okl_api.g_exception_error;
    END IF;

    --set the foreign key values and interest rate

    FOR i IN lp_lrfv_tbl.FIRST..lp_lrfv_tbl.LAST LOOP
      lp_lrfv_tbl(i).is_new_flag := 'Y';
      lp_lrfv_tbl(i).lrt_id := lp_lrtv_rec.id;
      lp_lrfv_tbl(i).rate_set_version_id := lp_lrvv_rec.rate_set_version_id;
      lp_lrfv_tbl(i).interest_rate := l_rate;
    END LOOP;

    FOR i IN lp_lrlv_tbl.FIRST..lp_lrlv_tbl.LAST LOOP
      lp_lrlv_tbl(i).rate_set_level_id := NULL;
      lp_lrlv_tbl(i).rate_set_id := lp_lrtv_rec.id;
      lp_lrlv_tbl(i).rate_set_version_id := lp_lrvv_rec.rate_set_version_id;
    END LOOP;

    --delete existing rate factors for lp_lrvv_rec.rate_Set_version_id
    --we need to delete as eot version might have changed so existing lrfs,  term value pairs  are not valid.
    --also user has changed the existing lrf values

    delete_lease_rate_factors(p_api_version   =>  p_api_version
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

    --call handlelrf API  to insert levels and factors

    IF lp_lrfv_tbl.COUNT > 0 THEN
      handle_lrf_ents(p_api_version   =>  p_api_version
                     ,p_init_msg_list =>  okl_api.g_false
                     ,x_return_status =>  l_return_status
                     ,x_msg_count     =>  x_msg_count
                     ,x_msg_data      =>  x_msg_data
                     ,p_lrfv_tbl      =>  lp_lrfv_tbl
                     ,x_lrfv_tbl      =>  x_lrfv_tbl
                     ,p_lrlv_tbl      =>  lp_lrlv_tbl
                     ,x_lrlv_tbl      =>  x_lrlv_tbl);
      IF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;

    --submit the lrs

    okl_lease_rate_sets_pvt.submit_lease_rate_set(p_api_version         =>  g_api_version
                                                 ,p_init_msg_list       =>  g_false
                                                 ,x_return_status       =>  l_return_status
                                                 ,x_msg_count           =>  x_msg_count
                                                 ,x_msg_data            =>  x_msg_data
                                                 ,p_rate_set_version_id =>  lp_lrvv_rec.rate_set_version_id);

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
                             ,'end debug OKLRECVB.pls.pls call handle_lrf_submit');
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
  END handle_lrf_submit;

END okl_lease_rate_factors_pvt;

/
