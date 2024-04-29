--------------------------------------------------------
--  DDL for Package Body OKL_LRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRV_PVT" AS
/* $Header: OKLSLRVB.pls 120.2 2005/09/30 11:01:07 asawanka noship $ */

  --------------------------------------------------------------------------------
  --PACKAGE CONSTANTS
  --------------------------------------------------------------------------------

  g_ret_sts_success     CONSTANT varchar2(1) := okl_api.g_ret_sts_success;
  g_ret_sts_unexp_error CONSTANT varchar2(1) := okl_api.g_ret_sts_unexp_error;
  g_ret_sts_error       CONSTANT varchar2(1) := okl_api.g_ret_sts_error;
  g_db_error            CONSTANT varchar2(12) := 'OKL_DB_ERROR';
  g_prog_name_token     CONSTANT varchar2(9) := 'PROG_NAME';
  g_miss_char           CONSTANT varchar2(1) := okl_api.g_miss_char;
  g_miss_num            CONSTANT number := okl_api.g_miss_num;
  g_miss_date           CONSTANT date := okl_api.g_miss_date;
  g_no_parent_record    CONSTANT varchar2(200) := 'OKC_NO_PARENT_RECORD';
  g_unexpected_error    CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token       CONSTANT varchar2(200) := 'SQLerrm';
  g_sqlcode_token       CONSTANT varchar2(200) := 'SQLcode';
  g_exception_halt_validation EXCEPTION;

  PROCEDURE api_copy IS

  BEGIN
    NULL;
  END api_copy;

  PROCEDURE change_version IS

  BEGIN
    NULL;
  END change_version;

  ---------------------------------------
  -- lock_row for:OKL_FE_RATE_SET_VERSIONS --
  ---------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrvv_rec       IN             okl_lrvv_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_lrvv_rec  IN  okl_lrvv_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_rate_set_versions
      WHERE         rate_set_version_id = p_lrvv_rec.rate_set_version_id
                AND object_version_number = p_lrvv_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_lrvv_rec  IN  okl_lrvv_rec) IS
      SELECT object_version_number
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_lrvv_rec.rate_set_version_id;
    l_api_version            CONSTANT number := 1;
    l_api_name               CONSTANT varchar2(30) := 'V_lock_row';
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_rate_set_versions.object_version_number%TYPE;
    lc_object_version_number          okl_fe_rate_set_versions.object_version_number%TYPE;
    l_row_notfound                    boolean := false;
    lc_row_notfound                   boolean := false;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,p_init_msg_list
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    BEGIN
      OPEN lock_csr(p_lrvv_rec);
      FETCH lock_csr INTO l_object_version_number ;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
      EXCEPTION
        WHEN e_resource_busy THEN

          IF (lock_csr%ISOPEN) THEN
            CLOSE lock_csr;
          END IF;
          okl_api.set_message(g_fnd_app, g_form_unable_to_reserve_rec);
          RAISE app_exceptions.record_lock_exception;
    END;

    IF (l_row_notfound) THEN
      OPEN lchk_csr(p_lrvv_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_lrvv_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_lrvv_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okl_api.set_message(g_app_name, g_record_logically_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END lock_row;

  --------------------------------------------------
  -- PL/SQL TBL lock_row for: OKL_ITM_RSD_HDR --
  --------------------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrvv_tbl       IN             okl_lrvv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'tbl_lock_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;

    -- Begin Post-Generation Change
    -- overall error status

    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

    -- End Post-Generation Change

    i                         number := 0;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_lrvv_tbl.COUNT > 0) THEN
      i := p_lrvv_tbl.FIRST;

      LOOP
        lock_row(p_init_msg_list =>  okl_api.g_false
                ,x_return_status =>  x_return_status
                ,x_msg_count     =>  x_msg_count
                ,x_msg_data      =>  x_msg_data
                ,p_lrvv_rec      =>  p_lrvv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_lrvv_tbl.LAST);
        i := p_lrvv_tbl.next(i);
      END LOOP;

      -- Begin Post-Generation Change
      -- return overall status

      x_return_status := l_overall_status;

    -- End Post-Generation Change

    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END lock_row;

  -------------------------------------
  -- Function Name  : validate_id
  -------------------------------------

  FUNCTION validate_id(p_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_id';

  BEGIN


    -- data is required

    IF (p_id IS NULL) OR (p_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'id');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_id;

  -------------------------------------------
  -- Function validate_object_version_number
  -------------------------------------------

  FUNCTION validate_object_version_number(p_object_version_number  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_version_number';

  BEGIN

    IF (p_object_version_number IS NULL) OR (p_object_version_number = g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'object_version_number');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_object_version_number;

  --------------------------------------------
  -- Function Name  : validate_RATE_SET_ID
  --------------------------------------------

  FUNCTION validate_rate_set_id(p_rate_set_id  IN  number) RETURN varchar2 IS
    l_dummy_var          varchar2(1) := '?';
    l_api_name  CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_RATE_SET_ID';

    -- select the ID of the parent record from the parent table

    CURSOR l_lrs_hdr_csr IS
      SELECT 'x'
      FROM   okl_ls_rt_fctr_sets_b
      WHERE  id = p_rate_set_id;

  BEGIN


    -- data is required

    IF (p_rate_set_id IS NULL) OR (p_rate_set_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'RATE_SET_ID');
      RAISE okl_api.g_exception_error;
    END IF;

    -- enforce foreign key

    OPEN l_lrs_hdr_csr;
    FETCH l_lrs_hdr_csr INTO l_dummy_var ;
    CLOSE l_lrs_hdr_csr;

    -- if l_dummy_var is still set to default, data was not found

    IF (l_dummy_var = '?') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_no_parent_record
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'RATE_SET_ID'
                         ,p_token2       =>  g_child_table_token
                         ,p_token2_value =>  'OKL_FE_RATE_SET_VERSIONS'
                         ,p_token3       =>  g_parent_table_token
                         ,p_token3_value =>  'OKL_LS_RT_FCTR_SETS_B');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN

        -- verify that cursor was closed

        IF l_lrs_hdr_csr%ISOPEN THEN
          CLOSE l_lrs_hdr_csr;
        END IF;
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN

        -- verify that cursor was closed

        IF l_lrs_hdr_csr%ISOPEN THEN
          CLOSE l_lrs_hdr_csr;
        END IF;
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN

        -- verify that cursor was closed

        IF l_lrs_hdr_csr%ISOPEN THEN
          CLOSE l_lrs_hdr_csr;
        END IF;
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_rate_set_id;

  ---------------------------------------------------
  -- Function Name  : validate_EFFECTIVE_FROM_DATE
  ---------------------------------------------------

  FUNCTION validate_effective_from_date(p_effective_from_date  IN  date) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_EFFECTIVE_FROM_DATE';

  BEGIN


    -- data is required

    IF (p_effective_from_date IS NULL) OR (p_effective_from_date = okl_api.g_miss_date) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'EFFECTIVE_FROM_DATE');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_effective_from_date;

  -----------------------------------------------------
  -- Function Name  : validate_arrears_yn
  -----------------------------------------------------

  FUNCTION validate_arrears_yn(p_arrears_yn  IN  varchar2) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_arrears_yn';

  BEGIN


    -- data is required

    IF (p_arrears_yn IS NULL) OR (p_arrears_yn = okl_api.g_miss_char) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := okl_util.check_lookup_code(p_lookup_type =>  'OKL_YES_NO'
                                                 ,p_lookup_code =>  p_arrears_yn);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'arrears_yn');
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_arrears_yn;

  -----------------------------------------------------
  -- Function Name  : validate_sts_code
  -----------------------------------------------------

  FUNCTION validate_sts_code(p_sts_code  IN  varchar2) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_sts_code';

  BEGIN

    -- data is required

    IF (p_sts_code IS NULL) OR (p_sts_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'sts_code');
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := okl_util.check_lookup_code(p_lookup_type =>  'OKL_PRC_STATUS'
                                                 ,p_lookup_code =>  p_sts_code);


    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'sts_code');
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_sts_code;

  ---------------------------------------------------
  -- Function Name  : validate_version_number
  ---------------------------------------------------

  FUNCTION validate_version_number(p_version_number  IN  varchar2) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_version_number';

  BEGIN


    -- data is required

    IF (p_version_number IS NULL) OR (p_version_number = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'version_number');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_version_number;

  ---------------------------------------------------
  -- Function Name  : validate_rate
  ---------------------------------------------------

  FUNCTION validate_lrs_rate(p_lrs_rate  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_LRS_RATE';

  BEGIN

    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_lrs_rate;

  FUNCTION validate_residual_tolerance(p_residual_tolerance  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_residual_tolerance';

  BEGIN


    IF (p_residual_tolerance IS NOT NULL) AND (p_residual_tolerance <> okl_api.g_miss_num) THEN
      IF (p_residual_tolerance > 100 OR p_residual_tolerance < 0) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'residual_tolerance');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_residual_tolerance;

  FUNCTION validate_rate_tolerance(p_rate_tolerance  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_rate_tolerance';

  BEGIN


    IF (p_rate_tolerance IS NOT NULL) AND (p_rate_tolerance <> okl_api.g_miss_num) THEN
      IF (p_rate_tolerance > 100 OR p_rate_tolerance < 0) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'rate_tolerance');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_rate_tolerance;


  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_RATE_SET_VERSIONS_V
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_lrvv_rec       IN             okl_lrvv_rec
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
            ,residual_tolerance
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
            ,standard_rate
      FROM   okl_fe_rate_set_versions_v
      WHERE  rate_set_version_id = p_id;
    l_lrvv_pk  lrvv_pk_csr%ROWTYPE;
    l_lrvv_rec okl_lrvv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values


    OPEN lrvv_pk_csr(p_lrvv_rec.rate_set_version_id);
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
                          ,l_lrvv_rec.residual_tolerance
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
                          ,l_lrvv_rec.attribute15
                          ,l_lrvv_rec.standard_rate;
    x_no_data_found := lrvv_pk_csr%NOTFOUND;
    CLOSE lrvv_pk_csr;
    RETURN(l_lrvv_rec);
  END get_rec;

  FUNCTION get_rec(p_lrvv_rec  IN  okl_lrvv_rec) RETURN okl_lrvv_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_lrvv_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_lrvv_rec  IN  okl_lrvv_rec) RETURN okl_lrvv_rec IS
    l_lrvv_rec okl_lrvv_rec := p_lrvv_rec;

  BEGIN

    IF (l_lrvv_rec.rate_set_version_id = okl_api.g_miss_num) THEN
      l_lrvv_rec.rate_set_version_id := NULL;
    END IF;

    IF (l_lrvv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_lrvv_rec.object_version_number := NULL;
    END IF;

    IF (l_lrvv_rec.arrears_yn = okl_api.g_miss_char) THEN
      l_lrvv_rec.arrears_yn := NULL;
    END IF;

    IF (l_lrvv_rec.effective_from_date = okl_api.g_miss_date) THEN
      l_lrvv_rec.effective_from_date := NULL;
    END IF;

    IF (l_lrvv_rec.effective_to_date = okl_api.g_miss_date) THEN
      l_lrvv_rec.effective_to_date := NULL;
    END IF;

    IF (l_lrvv_rec.rate_set_id = okl_api.g_miss_num) THEN
      l_lrvv_rec.rate_set_id := NULL;
    END IF;

    IF (l_lrvv_rec.end_of_term_ver_id = okl_api.g_miss_num) THEN
      l_lrvv_rec.end_of_term_ver_id := NULL;
    END IF;

    IF (l_lrvv_rec.std_rate_tmpl_ver_id = okl_api.g_miss_num) THEN
      l_lrvv_rec.std_rate_tmpl_ver_id := NULL;
    END IF;

    IF (l_lrvv_rec.adj_mat_version_id = okl_api.g_miss_num) THEN
      l_lrvv_rec.adj_mat_version_id := NULL;
    END IF;

    IF (l_lrvv_rec.version_number = okl_api.g_miss_char) THEN
      l_lrvv_rec.version_number := NULL;
    END IF;

    IF (l_lrvv_rec.lrs_rate = okl_api.g_miss_num) THEN
      l_lrvv_rec.lrs_rate := NULL;
    END IF;

    IF (l_lrvv_rec.rate_tolerance = okl_api.g_miss_num) THEN
      l_lrvv_rec.rate_tolerance := NULL;
    END IF;

    IF (l_lrvv_rec.residual_tolerance = okl_api.g_miss_num) THEN
      l_lrvv_rec.residual_tolerance := NULL;
    END IF;

    IF (l_lrvv_rec.deferred_pmts = okl_api.g_miss_num) THEN
      l_lrvv_rec.deferred_pmts := NULL;
    END IF;

    IF (l_lrvv_rec.advance_pmts = okl_api.g_miss_num) THEN
      l_lrvv_rec.advance_pmts := NULL;
    END IF;

    IF (l_lrvv_rec.sts_code = okl_api.g_miss_char) THEN
      l_lrvv_rec.sts_code := NULL;
    END IF;

    IF (l_lrvv_rec.created_by = okl_api.g_miss_num) THEN
      l_lrvv_rec.created_by := NULL;
    END IF;

    IF (l_lrvv_rec.creation_date = okl_api.g_miss_date) THEN
      l_lrvv_rec.creation_date := NULL;
    END IF;

    IF (l_lrvv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_lrvv_rec.last_updated_by := NULL;
    END IF;

    IF (l_lrvv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_lrvv_rec.last_update_date := NULL;
    END IF;

    IF (l_lrvv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_lrvv_rec.last_update_login := NULL;
    END IF;

    IF (l_lrvv_rec.attribute_category = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute_category := NULL;
    END IF;

    IF (l_lrvv_rec.attribute1 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute1 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute2 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute2 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute3 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute3 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute4 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute4 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute5 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute5 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute6 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute6 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute7 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute7 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute8 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute8 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute9 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute9 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute10 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute10 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute11 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute11 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute12 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute12 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute13 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute13 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute14 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute14 := NULL;
    END IF;

    IF (l_lrvv_rec.attribute15 = okl_api.g_miss_char) THEN
      l_lrvv_rec.attribute15 := NULL;
    END IF;

    IF (l_lrvv_rec.standard_rate = okl_api.g_miss_num) THEN
      l_lrvv_rec.standard_rate := NULL;
    END IF;
    RETURN(l_lrvv_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN number IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_attributes(p_lrvv_rec  IN  okl_lrvv_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN

    -- call each column-level validation


    l_return_status := validate_id(p_lrvv_rec.rate_set_version_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_object_version_number(p_lrvv_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_arrears_yn(p_lrvv_rec.arrears_yn);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_effective_from_date(p_lrvv_rec.effective_from_date);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_rate_set_id(p_lrvv_rec.rate_set_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_rate_tolerance(p_lrvv_rec.rate_tolerance);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_residual_tolerance(p_lrvv_rec.residual_tolerance);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_lrs_rate(p_lrvv_rec.lrs_rate);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_sts_code(p_lrvv_rec.sts_code);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_version_number(p_lrvv_rec.version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_attributes;

  FUNCTION validate_record(p_lrvv_rec  IN  okl_lrvv_rec) RETURN varchar2 IS

    CURSOR l_pve_csr IS
      SELECT 'x'
      FROM   okl_fe_eo_term_vers
      WHERE  end_of_term_ver_id = p_lrvv_rec.end_of_term_ver_id
         AND p_lrvv_rec.effective_from_date BETWEEN effective_from_date AND nvl(effective_to_date, p_lrvv_rec.effective_from_date + 1);

    CURSOR l_srv_csr IS
      SELECT 'x'
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_ver_id = p_lrvv_rec.std_rate_tmpl_ver_id
         AND p_lrvv_rec.effective_from_date BETWEEN effective_from_date AND nvl(effective_to_date, p_lrvv_rec.effective_from_date + 1);

    CURSOR l_pal_csr IS
      SELECT 'x'
      FROM   okl_fe_adj_mat_versions
      WHERE  adj_mat_version_id = p_lrvv_rec.adj_mat_version_id
         AND p_lrvv_rec.effective_from_date BETWEEN effective_from_date AND nvl(effective_to_date, p_lrvv_rec.effective_from_date + 1);
    l_dummy_var              varchar2(1) := '?';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_record';

  BEGIN

    --If eff_to is not null then if eff_from > eff_to, its error

    IF p_lrvv_rec.effective_to_date IS NOT NULL THEN
      IF p_lrvv_rec.effective_from_date > p_lrvv_rec.effective_to_date THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'Effective To');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    --validate that the eff_from of lrs is between purchase option version eff from and to

    OPEN l_pve_csr;
    FETCH l_pve_csr INTO l_dummy_var ;
    CLOSE l_pve_csr;

    -- if l_dummy_var is still set to default, data was not found

    IF (l_dummy_var = '?') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_no_parent_record
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'END_OF_TERM_VER_ID'
                         ,p_token2       =>  g_child_table_token
                         ,p_token2_value =>  'OKL_FE_RATE_SET_VERSIONS'
                         ,p_token3       =>  g_parent_table_token
                         ,p_token3_value =>  'OKL_FE_EO_TERM_VERS');
      RAISE okl_api.g_exception_error;
    END IF;
    l_dummy_var := '?';

    --validate that the eff_from of lrs is between srt version eff from and to

    IF p_lrvv_rec.std_rate_tmpl_ver_id IS NOT NULL AND p_lrvv_rec.std_rate_tmpl_ver_id <> g_miss_num THEN
      OPEN l_srv_csr;
      FETCH l_srv_csr INTO l_dummy_var ;
      CLOSE l_srv_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_no_parent_record
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'STD_RATE_TMPL_VER_ID'
                           ,p_token2       =>  g_child_table_token
                           ,p_token2_value =>  'OKL_FE_RATE_SET_VERSIONS'
                           ,p_token3       =>  g_parent_table_token
                           ,p_token3_value =>  'OKL_FE_SRT_VERSIONS');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;
    l_dummy_var := '?';


    --validate that the eff_from of lrs is between pam version eff from and to

    IF p_lrvv_rec.adj_mat_version_id IS NOT NULL AND p_lrvv_rec.adj_mat_version_id <> g_miss_num THEN
      OPEN l_pal_csr;
      FETCH l_pal_csr INTO l_dummy_var ;
      CLOSE l_pal_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_no_parent_record
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'PAM_VERSION_ID'
                           ,p_token2       =>  g_child_table_token
                           ,p_token2_value =>  'OKL_FE_RATE_SET_VERSIONS'
                           ,p_token3       =>  g_parent_table_token
                           ,p_token3_value =>  'OKL_FE_ADJ_MAT_VERSIONS');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    --validate that either of srt verion or rate are present

    IF p_lrvv_rec.lrs_rate IS NULL OR p_lrvv_rec.lrs_rate = g_miss_num THEN
      IF p_lrvv_rec.std_rate_tmpl_ver_id IS NULL OR p_lrvv_rec.std_rate_tmpl_ver_id = g_miss_num THEN
        okl_api.set_message(p_app_name =>  g_app_name
                           ,p_msg_name =>  'OKL_SRT_OR_RATE_SHUD_EXISTS');
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  'SQLCODE'
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  'SQLERRM'
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_record;

  --------------------------------------------------------------------------------
  -- Procedure insert_row_V
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec
                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_lrvv_rec               okl_lrvv_rec := p_lrvv_rec;
    l_def_lrvv_rec           okl_lrvv_rec;

    FUNCTION fill_who_columns(p_lrvv_rec  IN  okl_lrvv_rec) RETURN okl_lrvv_rec IS
      l_lrvv_rec okl_lrvv_rec := p_lrvv_rec;

    BEGIN
      l_lrvv_rec.creation_date := sysdate;
      l_lrvv_rec.created_by := fnd_global.user_id;
      l_lrvv_rec.last_update_date := sysdate;
      l_lrvv_rec.last_updated_by := fnd_global.user_id;
      l_lrvv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_lrvv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_lrvv_rec  IN             okl_lrvv_rec
                           ,x_lrvv_rec     OUT NOCOPY  okl_lrvv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_lrvv_rec := p_lrvv_rec;
      x_lrvv_rec.object_version_number := 1;

      -- Set Primary key value

      x_lrvv_rec.rate_set_version_id := get_seq_id;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out defaults

    l_lrvv_rec := null_out_defaults(p_lrvv_rec);

    --Setting Item Attributes

    l_return_status := set_attributes(l_lrvv_rec, l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --fill who columns

    l_def_lrvv_rec := fill_who_columns(l_def_lrvv_rec);

    --validate attributes


    l_return_status := validate_attributes(l_def_lrvv_rec);


    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record


    l_return_status := validate_record(l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --insert into table

    INSERT INTO okl_fe_rate_set_versions
               (rate_set_version_id
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
               ,residual_tolerance
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
               ,standard_rate)
    VALUES     (l_def_lrvv_rec.rate_set_version_id
               ,l_def_lrvv_rec.object_version_number
               ,l_def_lrvv_rec.arrears_yn
               ,l_def_lrvv_rec.effective_from_date
               ,l_def_lrvv_rec.effective_to_date
               ,l_def_lrvv_rec.rate_set_id
               ,l_def_lrvv_rec.end_of_term_ver_id
               ,l_def_lrvv_rec.std_rate_tmpl_ver_id
               ,l_def_lrvv_rec.adj_mat_version_id
               ,l_def_lrvv_rec.version_number
               ,l_def_lrvv_rec.lrs_rate
               ,l_def_lrvv_rec.rate_tolerance
               ,l_def_lrvv_rec.residual_tolerance
               ,l_def_lrvv_rec.deferred_pmts
               ,l_def_lrvv_rec.advance_pmts
               ,l_def_lrvv_rec.sts_code
               ,l_def_lrvv_rec.created_by
               ,l_def_lrvv_rec.creation_date
               ,l_def_lrvv_rec.last_updated_by
               ,l_def_lrvv_rec.last_update_date
               ,l_def_lrvv_rec.last_update_login
               ,l_def_lrvv_rec.attribute_category
               ,l_def_lrvv_rec.attribute1
               ,l_def_lrvv_rec.attribute2
               ,l_def_lrvv_rec.attribute3
               ,l_def_lrvv_rec.attribute4
               ,l_def_lrvv_rec.attribute5
               ,l_def_lrvv_rec.attribute6
               ,l_def_lrvv_rec.attribute7
               ,l_def_lrvv_rec.attribute8
               ,l_def_lrvv_rec.attribute9
               ,l_def_lrvv_rec.attribute10
               ,l_def_lrvv_rec.attribute11
               ,l_def_lrvv_rec.attribute12
               ,l_def_lrvv_rec.attribute13
               ,l_def_lrvv_rec.attribute14
               ,l_def_lrvv_rec.attribute15
               ,l_def_lrvv_rec.standard_rate);

    --Set OUT Values

    x_lrvv_rec := l_def_lrvv_rec;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END insert_row;

  --------------------------------------------------------------------------------
  -- Procedure insert_row_tbl
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl
                      ,x_lrvv_tbl          OUT NOCOPY  okl_lrvv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'v_insert_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_lrvv_tbl.COUNT > 0) THEN
      i := p_lrvv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_lrvv_rec      =>  p_lrvv_tbl(i)
                  ,x_lrvv_rec      =>  x_lrvv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_lrvv_tbl.LAST);
        i := p_lrvv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END insert_row;

  --------------------------------------------------------------------------------
  -- Procedure update_row
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec
                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_lrvv_rec               okl_lrvv_rec := p_lrvv_rec;
    l_def_lrvv_rec           okl_lrvv_rec;
    l_row_notfound           boolean := true;

    FUNCTION fill_who_columns(p_lrvv_rec  IN  okl_lrvv_rec) RETURN okl_lrvv_rec IS
      l_lrvv_rec okl_lrvv_rec := p_lrvv_rec;

    BEGIN
      l_lrvv_rec.last_update_date := sysdate;
      l_lrvv_rec.last_updated_by := fnd_global.user_id;
      l_lrvv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_lrvv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_lrvv_rec  IN             okl_lrvv_rec
                                ,x_lrvv_rec     OUT NOCOPY  okl_lrvv_rec) RETURN varchar2 IS
      l_lrvv_rec      okl_lrvv_rec;
      l_row_notfound  boolean := true;
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_lrvv_rec := p_lrvv_rec;

      --Get current database values

      l_lrvv_rec := get_rec(p_lrvv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_lrvv_rec.rate_set_version_id IS NULL) THEN
        x_lrvv_rec.rate_set_version_id := l_lrvv_rec.rate_set_version_id;
      END IF;

      IF (x_lrvv_rec.arrears_yn IS NULL) THEN
        x_lrvv_rec.arrears_yn := l_lrvv_rec.arrears_yn;
      END IF;

      IF (x_lrvv_rec.effective_from_date IS NULL) THEN
        x_lrvv_rec.effective_from_date := l_lrvv_rec.effective_from_date;
      END IF;

      IF (x_lrvv_rec.effective_to_date IS NULL) THEN
        x_lrvv_rec.effective_to_date := l_lrvv_rec.effective_to_date;
      END IF;

      IF (x_lrvv_rec.rate_set_id IS NULL) THEN
        x_lrvv_rec.rate_set_id := l_lrvv_rec.rate_set_id;
      END IF;

      IF (x_lrvv_rec.end_of_term_ver_id IS NULL) THEN
        x_lrvv_rec.end_of_term_ver_id := l_lrvv_rec.end_of_term_ver_id;
      END IF;

      IF (x_lrvv_rec.std_rate_tmpl_ver_id IS NULL) THEN
        x_lrvv_rec.std_rate_tmpl_ver_id := l_lrvv_rec.std_rate_tmpl_ver_id;
      END IF;

      IF (x_lrvv_rec.adj_mat_version_id IS NULL) THEN
        x_lrvv_rec.adj_mat_version_id := l_lrvv_rec.adj_mat_version_id;
      END IF;

      IF (x_lrvv_rec.version_number IS NULL) THEN
        x_lrvv_rec.version_number := l_lrvv_rec.version_number;
      END IF;

      IF (x_lrvv_rec.lrs_rate IS NULL) THEN
        x_lrvv_rec.lrs_rate := l_lrvv_rec.lrs_rate;
      END IF;

      IF (x_lrvv_rec.rate_tolerance IS NULL) THEN
        x_lrvv_rec.rate_tolerance := l_lrvv_rec.rate_tolerance;
      END IF;

      IF (x_lrvv_rec.residual_tolerance IS NULL) THEN
        x_lrvv_rec.residual_tolerance := l_lrvv_rec.residual_tolerance;
      END IF;

      IF (x_lrvv_rec.deferred_pmts IS NULL) THEN
        x_lrvv_rec.deferred_pmts := l_lrvv_rec.deferred_pmts;
      END IF;

      IF (x_lrvv_rec.advance_pmts IS NULL) THEN
        x_lrvv_rec.advance_pmts := l_lrvv_rec.advance_pmts;
      END IF;

      IF (x_lrvv_rec.sts_code IS NULL) THEN
        x_lrvv_rec.sts_code := l_lrvv_rec.sts_code;
      END IF;

      IF (x_lrvv_rec.created_by IS NULL) THEN
        x_lrvv_rec.created_by := l_lrvv_rec.created_by;
      END IF;

      IF (x_lrvv_rec.creation_date IS NULL) THEN
        x_lrvv_rec.creation_date := l_lrvv_rec.creation_date;
      END IF;

      IF (x_lrvv_rec.last_updated_by IS NULL) THEN
        x_lrvv_rec.last_updated_by := l_lrvv_rec.last_updated_by;
      END IF;

      IF (x_lrvv_rec.last_update_date IS NULL) THEN
        x_lrvv_rec.last_update_date := l_lrvv_rec.last_update_date;
      END IF;

      IF (x_lrvv_rec.last_update_login IS NULL) THEN
        x_lrvv_rec.last_update_login := l_lrvv_rec.last_update_login;
      END IF;

      IF (x_lrvv_rec.attribute_category IS NULL) THEN
        x_lrvv_rec.attribute_category := l_lrvv_rec.attribute_category;
      END IF;

      IF (x_lrvv_rec.attribute1 IS NULL) THEN
        x_lrvv_rec.attribute1 := l_lrvv_rec.attribute1;
      END IF;

      IF (x_lrvv_rec.attribute2 IS NULL) THEN
        x_lrvv_rec.attribute2 := l_lrvv_rec.attribute2;
      END IF;

      IF (x_lrvv_rec.attribute3 IS NULL) THEN
        x_lrvv_rec.attribute3 := l_lrvv_rec.attribute3;
      END IF;

      IF (x_lrvv_rec.attribute4 IS NULL) THEN
        x_lrvv_rec.attribute4 := l_lrvv_rec.attribute4;
      END IF;

      IF (x_lrvv_rec.attribute5 IS NULL) THEN
        x_lrvv_rec.attribute5 := l_lrvv_rec.attribute5;
      END IF;

      IF (x_lrvv_rec.attribute6 IS NULL) THEN
        x_lrvv_rec.attribute6 := l_lrvv_rec.attribute6;
      END IF;

      IF (x_lrvv_rec.attribute7 IS NULL) THEN
        x_lrvv_rec.attribute7 := l_lrvv_rec.attribute7;
      END IF;

      IF (x_lrvv_rec.attribute8 IS NULL) THEN
        x_lrvv_rec.attribute8 := l_lrvv_rec.attribute8;
      END IF;

      IF (x_lrvv_rec.attribute9 IS NULL) THEN
        x_lrvv_rec.attribute9 := l_lrvv_rec.attribute9;
      END IF;

      IF (x_lrvv_rec.attribute10 IS NULL) THEN
        x_lrvv_rec.attribute10 := l_lrvv_rec.attribute10;
      END IF;

      IF (x_lrvv_rec.attribute11 IS NULL) THEN
        x_lrvv_rec.attribute11 := l_lrvv_rec.attribute11;
      END IF;

      IF (x_lrvv_rec.attribute12 IS NULL) THEN
        x_lrvv_rec.attribute12 := l_lrvv_rec.attribute12;
      END IF;

      IF (x_lrvv_rec.attribute13 IS NULL) THEN
        x_lrvv_rec.attribute13 := l_lrvv_rec.attribute13;
      END IF;

      IF (x_lrvv_rec.attribute14 IS NULL) THEN
        x_lrvv_rec.attribute14 := l_lrvv_rec.attribute14;
      END IF;

      IF (x_lrvv_rec.attribute15 IS NULL) THEN
        x_lrvv_rec.attribute15 := l_lrvv_rec.attribute15;
      END IF;

      IF (x_lrvv_rec.standard_rate IS NULL) THEN
        x_lrvv_rec.standard_rate := l_lrvv_rec.standard_rate;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_lrvv_rec  IN             okl_lrvv_rec
                           ,x_lrvv_rec     OUT NOCOPY  okl_lrvv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_lrvv_rec := p_lrvv_rec;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_lrvv_rec, l_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --populate new record

    l_return_status := populate_new_record(l_lrvv_rec, l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out g miss values

    l_def_lrvv_rec := null_out_defaults(l_def_lrvv_rec);

    --fill who columns


    l_def_lrvv_rec := fill_who_columns(l_def_lrvv_rec);


    --validate attributes

    l_return_status := validate_attributes(l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;


    --validate record

    l_return_status := validate_record(l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --lock the row

    lock_row(p_init_msg_list =>  okl_api.g_false
            ,x_return_status =>  l_return_status
            ,x_msg_count     =>  x_msg_count
            ,x_msg_data      =>  x_msg_data
            ,p_lrvv_rec      =>  l_def_lrvv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
      --update the record

    UPDATE okl_fe_rate_set_versions
    SET    rate_set_version_id = l_def_lrvv_rec.rate_set_version_id
          ,object_version_number = l_def_lrvv_rec.object_version_number + 1
          ,arrears_yn = l_def_lrvv_rec.arrears_yn
          ,effective_from_date = l_def_lrvv_rec.effective_from_date
          ,effective_to_date = l_def_lrvv_rec.effective_to_date
          ,rate_set_id = l_def_lrvv_rec.rate_set_id
          ,end_of_term_ver_id = l_def_lrvv_rec.end_of_term_ver_id
          ,std_rate_tmpl_ver_id = l_def_lrvv_rec.std_rate_tmpl_ver_id
          ,adj_mat_version_id = l_def_lrvv_rec.adj_mat_version_id
          ,version_number = l_def_lrvv_rec.version_number
          ,lrs_rate = l_def_lrvv_rec.lrs_rate
          ,rate_tolerance = l_def_lrvv_rec.rate_tolerance
          ,residual_tolerance = l_def_lrvv_rec.residual_tolerance
          ,deferred_pmts = l_def_lrvv_rec.deferred_pmts
          ,advance_pmts = l_def_lrvv_rec.advance_pmts
          ,sts_code = l_def_lrvv_rec.sts_code
          ,created_by = l_def_lrvv_rec.created_by
          ,creation_date = l_def_lrvv_rec.creation_date
          ,last_updated_by = l_def_lrvv_rec.last_updated_by
          ,last_update_date = l_def_lrvv_rec.last_update_date
          ,last_update_login = l_def_lrvv_rec.last_update_login
          ,attribute_category = l_def_lrvv_rec.attribute_category
          ,attribute1 = l_def_lrvv_rec.attribute1
          ,attribute2 = l_def_lrvv_rec.attribute2
          ,attribute3 = l_def_lrvv_rec.attribute3
          ,attribute4 = l_def_lrvv_rec.attribute4
          ,attribute5 = l_def_lrvv_rec.attribute5
          ,attribute6 = l_def_lrvv_rec.attribute6
          ,attribute7 = l_def_lrvv_rec.attribute7
          ,attribute8 = l_def_lrvv_rec.attribute8
          ,attribute9 = l_def_lrvv_rec.attribute9
          ,attribute10 = l_def_lrvv_rec.attribute10
          ,attribute11 = l_def_lrvv_rec.attribute11
          ,attribute12 = l_def_lrvv_rec.attribute12
          ,attribute13 = l_def_lrvv_rec.attribute13
          ,attribute14 = l_def_lrvv_rec.attribute14
          ,attribute15 = l_def_lrvv_rec.attribute15
          ,standard_rate = l_def_lrvv_rec.standard_rate
    WHERE  rate_set_version_id = l_def_lrvv_rec.rate_set_version_id;

    --Set OUT Values

    x_lrvv_rec := l_def_lrvv_rec;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count, x_msg_data);

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END update_row;

  --------------------------------------------------------------------------------
  -- Procedure insert_row_tbl
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl
                      ,x_lrvv_tbl          OUT NOCOPY  okl_lrvv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'v_update_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_lrvv_tbl.COUNT > 0) THEN
      i := p_lrvv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_lrvv_rec      =>  p_lrvv_tbl(i)
                  ,x_lrvv_rec      =>  x_lrvv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_lrvv_tbl.LAST);
        i := p_lrvv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END update_row;

  --------------------------------------------------------------------------------
  -- Procedure delete_row
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_lrvv_rec               okl_lrvv_rec := p_lrvv_rec;
    l_row_notfound           boolean := true;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_rate_set_versions
    WHERE       rate_set_version_id = l_lrvv_rec.rate_set_version_id;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END delete_row;

  --------------------------------------------------------------------------------
  -- Procedure delete_row_tbl
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'v_delete_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_lrvv_tbl.COUNT > 0) THEN
      i := p_lrvv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_lrvv_rec      =>  p_lrvv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_lrvv_tbl.LAST);
        i := p_lrvv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END delete_row;

END okl_lrv_pvt;

/
