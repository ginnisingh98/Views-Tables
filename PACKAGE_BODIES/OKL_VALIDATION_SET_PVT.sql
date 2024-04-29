--------------------------------------------------------
--  DDL for Package Body OKL_VALIDATION_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VALIDATION_SET_PVT" AS
/* $Header: OKLRVLSB.pls 120.6 2006/07/07 10:37:17 adagur noship $ */

 FUNCTION validate_header(p_vlsv_rec  IN  vlsv_rec_type) RETURN varchar2 IS

    CURSOR l_vls_csr IS
      SELECT 'x'
      FROM   OKL_VALIDATION_SETS_V
      WHERE  validation_set_name = p_vlsv_rec.validation_set_name
      AND    org_id              = mo_global.get_current_org_id();

    l_dummy_var              varchar2(1) := '?';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_header';

  BEGIN
    IF p_vlsv_rec.effective_from > p_vlsv_rec.effective_to  THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_VALID_TO');

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   --name,vls_ac_flag combination should be unique
    OPEN l_vls_csr;
    FETCH l_vls_csr INTO l_dummy_var ;
    CLOSE l_vls_csr;  -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             'OKL_DUPLICATE_NAME'
                         ,p_token1       =>             'NAME'
                         ,p_token1_value =>             p_vlsv_rec.validation_set_name);
      RAISE okl_api.g_exception_error;
    END IF;  --if value type=range data type should not be varchar2

    RETURN(x_return_status);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN okl_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        RETURN okl_api.g_ret_sts_unexp_error;
  END validate_header;

  FUNCTION validate_duplicates(p_vldv_tbl  IN  vldv_tbl_type) RETURN varchar2 IS

    lp_vldv_tbl1               vldv_tbl_type;
    lp_vldv_tbl2               vldv_tbl_type;
    l_dummy_var              varchar2(1) := '?';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_duplicate';
    i               INTEGER:=1;
    j               INTEGER:=1;
    breakLoop       boolean:=false;
  BEGIN  --name,vls_ac_flag combination should be unique
    lp_vldv_tbl1:=p_vldv_tbl;
    lp_vldv_tbl2:=p_vldv_tbl;
    IF p_vldv_tbl.COUNT > 0 THEN
     FOR i IN lp_vldv_tbl1.FIRST..lp_vldv_tbl1.LAST-1 LOOP
        FOR j IN i+1..lp_vldv_tbl2.LAST Loop
            --IF(j!=i AND lp_vldv_tbl2(j).function_id=lp_vldv_tbl1(i).function_id) THEN
            IF(lp_vldv_tbl2(j).function_id=lp_vldv_tbl1(i).function_id) THEN
               breakLoop:=true;
               l_dummy_var:='x';
            END IF;
               EXIT WHEN breakLoop;
        END LOOP;
            EXIT WHEN breakLoop;
    END LOOP;
  END IF;

    -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             'OKL_DUPLICATE_VALIDATION'
                         ,p_token1       =>             'NAME'
                         ,p_token1_value =>             lp_vldv_tbl2(j).description);
       RAISE okl_api.g_exception_error;
    END IF;  --if value type=range data type should not be varchar2
     RETURN(x_return_status);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN okl_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        RETURN okl_api.g_ret_sts_unexp_error;
  END validate_duplicates;

  PROCEDURE create_vls(p_api_version      IN          number
                      ,p_init_msg_list   IN          varchar2
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vlsv_rec        IN          vlsv_rec_type
                      ,x_vlsv_rec        OUT NOCOPY  vlsv_rec_type
                      ,p_vldv_tbl        IN          vldv_tbl_type
                      ,x_vldv_tbl        OUT NOCOPY  vldv_tbl_type) IS
    lp_vlsv_rec                    vlsv_rec_type;
    lx_vlsv_rec                    vlsv_rec_type;
    lp_vldv_tbl                    vldv_tbl_type;
    lx_vldv_tbl                    vldv_tbl_type;
    i                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VALIDATION_SET_PVT.create_vls';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'create_vls';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                        ,fnd_log.level_procedure);


    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRVLSB.pls call create_vls');
    END IF;  -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name=>l_api_name
                                             ,p_pkg_name=>G_PKG_NAME
                                             ,p_init_msg_list=>p_init_msg_list
                                             ,l_api_version=>l_api_version
                                             ,p_api_version=>p_api_version
                                             ,p_api_type=>G_API_TYPE
                                             ,x_return_status=>x_return_status);  -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lp_vlsv_rec := p_vlsv_rec;
    lp_vldv_tbl := p_vldv_tbl;  --validate header
    l_return_status := validate_header(lp_vlsv_rec);  -- write to log

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
    END IF;

    l_return_status := validate_duplicates(lp_vldv_tbl);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'Function okl_ecc_def_pvt.validate_duplicates returned with status ' ||
                              l_return_status);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    okl_vls_pvt.insert_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_vlsv_rec
                          ,lx_vlsv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_vls_pvt.insert_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN rvldrd type

    lp_vlsv_rec := lx_vlsv_rec;

    IF lp_vldv_tbl.COUNT > 0 THEN

      FOR i IN lp_vldv_tbl.FIRST..lp_vldv_tbl.LAST LOOP
        lp_vldv_tbl(i).validation_set_id := lp_vlsv_rec.id;
      END LOOP;
      okl_vld_pvt.insert_row(p_api_version
                            ,okl_api.g_false
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,lp_vldv_tbl
                            ,lx_vldv_tbl);  -- write to log

      IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_statement
                               ,l_module
                               ,'okl_vld_pvt.insert_row returned with status ' ||
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
    x_vlsv_rec := lx_vlsv_rec;
    x_vldv_tbl := lx_vldv_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKL_VALIDATION_SET_PVT.pls call create_vls');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN

        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                G_PKG_NAME
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                G_API_TYPE);

      WHEN okl_api.g_exception_unexpected_error THEN

        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                G_PKG_NAME
                                                    ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                G_API_TYPE);

      WHEN OTHERS THEN

        x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                    ,p_pkg_name  =>                G_PKG_NAME
                                                    ,p_exc_name  =>                'OTHERS'
                                                    ,x_msg_count =>                x_msg_count
                                                    ,x_msg_data  =>                x_msg_data
                                                    ,p_api_type  =>                G_API_TYPE);

  END create_vls;

  PROCEDURE update_vls(p_api_version       IN          number
                      ,p_init_msg_list     IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_vlsv_rec          IN          vlsv_rec_type
                      ,x_vlsv_rec          OUT NOCOPY  vlsv_rec_type
                      ,p_vldv_tbl           IN          vldv_tbl_type
                      ,x_vldv_tbl           OUT NOCOPY  vldv_tbl_type) IS
    lp_vlsv_rec                    vlsv_rec_type;
    lx_vlsv_rec                    vlsv_rec_type;
    lp_vldv_crt_tbl                vldv_tbl_type;
    lx_vldv_crt_tbl                vldv_tbl_type;
    lp_vldv_rmv_tbl                vldv_tbl_type;
    lx_vldv_rmv_tbl                vldv_tbl_type;
    lp_vldv_tbl                    vldv_tbl_type;
    lx_vldv_tbl                    vldv_tbl_type;
    i                              number;
    j                              number;
    l                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VALIDATION_SET_PVT.update_vls';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'update_vls';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKL_VALIDATION_SET_PVT.pls call update_vls');
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
    lp_vlsv_rec := p_vlsv_rec;
    lp_vldv_tbl := p_vldv_tbl;

    IF lp_vlsv_rec.effective_from > lp_vlsv_rec.effective_to  THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_VALID_TO');

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status :=validate_duplicates(lp_vldv_tbl);  -- write to log

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
    END IF;
    okl_vls_pvt.update_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_vlsv_rec
                          ,lx_vlsv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_vls_pvt.update_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN rvldrd type
    lp_vlsv_rec := lx_vlsv_rec;
    j := 1;
    l := 1;


/*
    --lp_vld_tbl contains objects to be newly applied (created) or to be un applied (removed)
    --there is no need to update existing applicable objects
*/
    IF lp_vldv_tbl.COUNT > 0 THEN

      FOR i IN lp_vldv_tbl.FIRST..lp_vldv_tbl.LAST LOOP
        IF lp_vldv_tbl(i).id IS NULL THEN
          lp_vldv_crt_tbl(j) := lp_vldv_tbl(i);
          lp_vldv_crt_tbl(j).validation_set_id := lp_vlsv_rec.id;
          j := j + 1;
        ELSIF lp_vldv_tbl(i).id IS NOT NULL THEN
          lp_vldv_rmv_tbl(l) := lp_vldv_tbl(i);
          lp_vldv_rmv_tbl(l).validation_set_id := lp_vlsv_rec.id;
          l := l + 1;
        END IF;
      END LOOP;

      IF lp_vldv_crt_tbl.COUNT > 0 THEN
        okl_vld_pvt.insert_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_vldv_crt_tbl
                              ,lx_vldv_crt_tbl);  -- write to log
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_vld_pvt.insert_row returned with status ' ||
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
      IF lp_vldv_rmv_tbl.COUNT > 0 THEN
        okl_vld_pvt.update_row(p_api_version
                              ,okl_api.g_false
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_vldv_rmv_tbl
                              ,lx_vldv_rmv_tbl);  -- write to log
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_vld_pvt.delete_row returned with status ' ||
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

    x_vlsv_rec := lx_vlsv_rec;
    x_vldv_tbl := lx_vldv_crt_tbl;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRvlsB.pls call update_vls');
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
  END update_vls;

  PROCEDURE delete_vls(p_api_version    IN          number
                      ,p_init_msg_list   IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vlsv_rec        IN          vlsv_rec_type) IS

    CURSOR l_vldv_csr(p_validation_set_id number) IS
      SELECT id
            ,object_version_number
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
            ,validation_set_id
            ,function_id
            ,failure_severity
            ,short_description
            ,description
            ,comments
      FROM   OKL_VALIDATIONS_V
      WHERE  validation_set_id=p_validation_set_id;
    i                              number:=0;
    lp_vlsv_rec                    vlsv_rec_type;
    lx_vlsv_rec                    vlsv_rec_type;
    lx_vldv_rec                    vldv_rec_type;
    lx_vldv_tbl                    vldv_tbl_type;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VALIDATION_SET_PVT.delete_vls';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'delete_vls';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKL_VALIDATION_SET_PVT.pls call delete_vls');
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
    lp_vlsv_rec := p_vlsv_rec;

    l_return_status := OKL_VALIDATION_SET_PVT.validate_header(lp_vlsv_rec);  -- write to log

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

    --Delete all the Records for Validation Set
    OPEN l_vldv_csr(lp_vlsv_rec.id);
    LOOP
    FETCH l_vldv_csr INTO lx_vldv_rec;
    EXIT WHEN l_vldv_csr%NOTFOUND;
    lx_vldv_tbl(i):=lx_vldv_rec;
    i:=i+1;
    END LOOP;
    okl_vld_pvt.delete_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lx_vldv_tbl);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_vls_pvt.delete_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN rvldrd type
   --Delete Parent If Child Are successfully Deleted
    okl_vls_pvt.delete_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_vlsv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_vls_pvt.delete_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN rvldrd type
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKL_VALIDATION_SET_PVT.pls call delete_vls');
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


    END delete_vls;

   PROCEDURE delete_vld(p_api_version   IN          number
                      ,p_init_msg_list   IN          varchar2     DEFAULT okl_api.g_false
                      ,x_return_status   OUT NOCOPY  varchar2
                      ,x_msg_count       OUT NOCOPY  number
                      ,x_msg_data        OUT NOCOPY  varchar2
                      ,p_vldv_rec        IN          vldv_rec_type) IS

    lp_vldv_rec                    vldv_rec_type;
    lx_vldv_rec                    vldv_rec_type;
    i                              number;
    j                              number;
    l                              number;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_VALIDATION_SET_PVT.delete_vld';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;
    l_api_name            CONSTANT varchar2(30) := 'delete_vld';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKL_VALIDATION_SET_PVT.pls call delete_vls');
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

    lp_vldv_rec := p_vldv_rec;
    okl_vld_pvt.delete_row(p_api_version
                          ,okl_api.g_false
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,lp_vldv_rec);  -- write to log

    IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_statement
                             ,l_module
                             ,'okl_vls_pvt.delete_row returned with status ' ||
                              l_return_status ||
                              ' x_msg_data ' ||
                              x_msg_data);
    END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;  --Copy value of OUT variable in the IN rvldrd type


    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKL_VALIDATION_SET_PVT.pls call create_vls');
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




    END delete_vld;


  END OKL_VALIDATION_SET_PVT;

/
