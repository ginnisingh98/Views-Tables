--------------------------------------------------------
--  DDL for Package Body OKL_ECV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECV_PVT" AS
/* $Header: OKLSECVB.pls 120.1 2005/10/30 04:59:23 appldev noship $ */

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
  -- lock_row for:OKL_FE_CRITERION_VALUES --
  ---------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_ecv_rec        IN             okl_ecv_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_ecv_rec  IN  okl_ecv_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_criterion_values
      WHERE         criterion_value_id = p_ecv_rec.criterion_value_id
                AND object_version_number = p_ecv_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_ecv_rec  IN  okl_ecv_rec) IS
      SELECT object_version_number
      FROM   okl_fe_criterion_values
      WHERE  criterion_value_id = p_ecv_rec.criterion_value_id;
    l_api_version            CONSTANT number := 1;
    l_api_name               CONSTANT varchar2(30) := 'B_lock_row';
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_criterion_values.object_version_number%TYPE;
    lc_object_version_number          okl_fe_criterion_values.object_version_number%TYPE;
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
      OPEN lock_csr(p_ecv_rec);
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
      OPEN lchk_csr(p_ecv_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_ecv_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_ecv_rec.object_version_number THEN
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
  -- PL/SQL TBL lock_row for: OKL_FE_CRITERION_VALUES --
  --------------------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_ecv_tbl        IN             okl_ecv_tbl) IS
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

    IF (p_ecv_tbl.COUNT > 0) THEN
      i := p_ecv_tbl.FIRST;

      LOOP
        lock_row(p_init_msg_list =>  okl_api.g_false
                ,x_return_status =>  x_return_status
                ,x_msg_count     =>  x_msg_count
                ,x_msg_data      =>  x_msg_data
                ,p_ecv_rec       =>  p_ecv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_ecv_tbl.LAST);
        i := p_ecv_tbl.next(i);
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

  FUNCTION validate_criterion_value_id(p_criterion_value_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_CRITERION_VALUE_ID';

  BEGIN

    --
    -- data is required

    IF (p_criterion_value_id IS NULL) OR (p_criterion_value_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'CRITERION_VALUE_ID');
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
  END validate_criterion_value_id;

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

  ------------------------------------------
  -- Function Name  : validate_CRITERIA_ID
  ------------------------------------------

  FUNCTION validate_criteria_id(p_criteria_id  IN  number) RETURN varchar2 IS
    l_dummy_var          varchar2(1) := '?';
    l_api_name  CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_CRITERIA_ID';

    -- select the ID of the parent record from the parent table

    CURSOR l_ecl_csr IS
      SELECT 'x'
      FROM   okl_fe_criteria
      WHERE  criteria_id = p_criteria_id;

  BEGIN

    --
    -- data is required

    IF (p_criteria_id IS NULL) OR (p_criteria_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'CRITERIA_ID');
      RAISE okl_api.g_exception_error;
    END IF;

    -- enforce foreign key

    OPEN l_ecl_csr;
    FETCH l_ecl_csr INTO l_dummy_var ;
    CLOSE l_ecl_csr;

    -- if l_dummy_var is still set to default, data was not found

    IF (l_dummy_var = '?') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_no_parent_record
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'CRITERIA_ID'
                         ,p_token2       =>  g_child_table_token
                         ,p_token2_value =>  'OKL_FE_CRITERION_VALUES'
                         ,p_token3       =>  g_parent_table_token
                         ,p_token3_value =>  'OKL_FE_CRITERIA');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN

        -- verify that cursor was closed

        IF l_ecl_csr%ISOPEN THEN
          CLOSE l_ecl_csr;
        END IF;
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN

        -- verify that cursor was closed

        IF l_ecl_csr%ISOPEN THEN
          CLOSE l_ecl_csr;
        END IF;
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN

        -- verify that cursor was closed

        IF l_ecl_csr%ISOPEN THEN
          CLOSE l_ecl_csr;
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
  END validate_criteria_id;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_CRITERION_VALUES
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ecv_rec        IN             okl_ecv_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_ecv_rec IS

    CURSOR ecv_pk_csr(p_id  IN  number) IS
      SELECT criterion_value_id
            ,object_version_number
            ,criteria_id
            ,operator_code
            ,crit_cat_value2
            ,crit_cat_value1
            ,adjustment_factor
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
      FROM   okl_fe_criterion_values
      WHERE  okl_fe_criterion_values.criterion_value_id = p_id;
    l_ecv_pk  ecv_pk_csr%ROWTYPE;
    l_ecv_rec okl_ecv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN ecv_pk_csr(p_ecv_rec.criterion_value_id);
    FETCH ecv_pk_csr INTO l_ecv_rec.criterion_value_id
                         ,l_ecv_rec.object_version_number
                         ,l_ecv_rec.criteria_id
                         ,l_ecv_rec.operator_code
                         ,l_ecv_rec.crit_cat_value2
                         ,l_ecv_rec.crit_cat_value1
                         ,l_ecv_rec.adjustment_factor
                         ,l_ecv_rec.created_by
                         ,l_ecv_rec.creation_date
                         ,l_ecv_rec.last_updated_by
                         ,l_ecv_rec.last_update_date
                         ,l_ecv_rec.last_update_login
                         ,l_ecv_rec.attribute_category
                         ,l_ecv_rec.attribute1
                         ,l_ecv_rec.attribute2
                         ,l_ecv_rec.attribute3
                         ,l_ecv_rec.attribute4
                         ,l_ecv_rec.attribute5
                         ,l_ecv_rec.attribute6
                         ,l_ecv_rec.attribute7
                         ,l_ecv_rec.attribute8
                         ,l_ecv_rec.attribute9
                         ,l_ecv_rec.attribute10
                         ,l_ecv_rec.attribute11
                         ,l_ecv_rec.attribute12
                         ,l_ecv_rec.attribute13
                         ,l_ecv_rec.attribute14
                         ,l_ecv_rec.attribute15 ;
    x_no_data_found := ecv_pk_csr%NOTFOUND;
    CLOSE ecv_pk_csr;
    RETURN(l_ecv_rec);
  END get_rec;

  FUNCTION get_rec(p_ecv_rec  IN  okl_ecv_rec) RETURN okl_ecv_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_ecv_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_ecv_rec  IN  okl_ecv_rec) RETURN okl_ecv_rec IS
    l_ecv_rec okl_ecv_rec := p_ecv_rec;

  BEGIN

    IF (l_ecv_rec.criterion_value_id = okl_api.g_miss_num) THEN
      l_ecv_rec.criterion_value_id := NULL;
    END IF;

    IF (l_ecv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_ecv_rec.object_version_number := NULL;
    END IF;

    IF (l_ecv_rec.criteria_id = okl_api.g_miss_num) THEN
      l_ecv_rec.criteria_id := NULL;
    END IF;

    IF (l_ecv_rec.operator_code = okl_api.g_miss_char) THEN
      l_ecv_rec.operator_code := NULL;
    END IF;

    IF (l_ecv_rec.crit_cat_value2 = okl_api.g_miss_char) THEN
      l_ecv_rec.crit_cat_value2 := NULL;
    END IF;

    IF (l_ecv_rec.crit_cat_value1 = okl_api.g_miss_char) THEN
      l_ecv_rec.crit_cat_value1 := NULL;
    END IF;

    IF (l_ecv_rec.adjustment_factor = okl_api.g_miss_num) THEN
      l_ecv_rec.adjustment_factor := NULL;
    END IF;

    IF (l_ecv_rec.created_by = okl_api.g_miss_num) THEN
      l_ecv_rec.created_by := NULL;
    END IF;

    IF (l_ecv_rec.creation_date = okl_api.g_miss_date) THEN
      l_ecv_rec.creation_date := NULL;
    END IF;

    IF (l_ecv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_ecv_rec.last_updated_by := NULL;
    END IF;

    IF (l_ecv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_ecv_rec.last_update_date := NULL;
    END IF;

    IF (l_ecv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_ecv_rec.last_update_login := NULL;
    END IF;

    IF (l_ecv_rec.attribute_category = g_miss_char) THEN
      l_ecv_rec.attribute_category := NULL;
    END IF;

    IF (l_ecv_rec.attribute1 = g_miss_char) THEN
      l_ecv_rec.attribute1 := NULL;
    END IF;

    IF (l_ecv_rec.attribute2 = g_miss_char) THEN
      l_ecv_rec.attribute2 := NULL;
    END IF;

    IF (l_ecv_rec.attribute3 = g_miss_char) THEN
      l_ecv_rec.attribute3 := NULL;
    END IF;

    IF (l_ecv_rec.attribute4 = g_miss_char) THEN
      l_ecv_rec.attribute4 := NULL;
    END IF;

    IF (l_ecv_rec.attribute5 = g_miss_char) THEN
      l_ecv_rec.attribute5 := NULL;
    END IF;

    IF (l_ecv_rec.attribute6 = g_miss_char) THEN
      l_ecv_rec.attribute6 := NULL;
    END IF;

    IF (l_ecv_rec.attribute7 = g_miss_char) THEN
      l_ecv_rec.attribute7 := NULL;
    END IF;

    IF (l_ecv_rec.attribute8 = g_miss_char) THEN
      l_ecv_rec.attribute8 := NULL;
    END IF;

    IF (l_ecv_rec.attribute9 = g_miss_char) THEN
      l_ecv_rec.attribute9 := NULL;
    END IF;

    IF (l_ecv_rec.attribute10 = g_miss_char) THEN
      l_ecv_rec.attribute10 := NULL;
    END IF;

    IF (l_ecv_rec.attribute11 = g_miss_char) THEN
      l_ecv_rec.attribute11 := NULL;
    END IF;

    IF (l_ecv_rec.attribute12 = g_miss_char) THEN
      l_ecv_rec.attribute12 := NULL;
    END IF;

    IF (l_ecv_rec.attribute13 = g_miss_char) THEN
      l_ecv_rec.attribute13 := NULL;
    END IF;

    IF (l_ecv_rec.attribute14 = g_miss_char) THEN
      l_ecv_rec.attribute14 := NULL;
    END IF;

    IF (l_ecv_rec.attribute15 = g_miss_char) THEN
      l_ecv_rec.attribute15 := NULL;
    END IF;
    RETURN(l_ecv_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN number IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_attributes(p_ecv_rec  IN  okl_ecv_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN

    -- call each column-level validation
    --

    --validate CRITERION_VALUE_ID

    l_return_status := validate_criterion_value_id(p_ecv_rec.criterion_value_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate object version number

    l_return_status := validate_object_version_number(p_ecv_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate CRITERIA_ID

    l_return_status := validate_criteria_id(p_ecv_rec.criteria_id);

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

  FUNCTION validate_record(p_ecv_rec  IN OUT NOCOPY okl_ecv_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';
    i                        number;
    d                        date;

  BEGIN

    --do all the validations only if p_ecv_rec.validate_record = 'Y'
    --in other cases data is coming from database and not from screen so CRIT_CAT_NUMVAL,
    --CRIT_CAT_DATEVAL will not be present. so no need to the validations

    IF p_ecv_rec.validate_record = 'Y' THEN
      IF p_ecv_rec.data_type_code = 'NUMBER' THEN
        IF p_ecv_rec.crit_cat_numval1 IS NULL OR p_ecv_rec.crit_cat_numval1 = okl_api.g_miss_num THEN
          okl_api.set_message(p_app_name     =>  g_app_name
                             ,p_msg_name     =>  g_required_value
                             ,p_token1       =>  g_col_name_token
                             ,p_token1_value =>  'CRIT_CAT_NUMVAL1');
          RAISE okl_api.g_exception_error;
        ELSE
          p_ecv_rec.crit_cat_value1 := fnd_number.number_to_canonical(p_ecv_rec.crit_cat_numval1);
          IF p_ecv_rec.crit_cat_numval2 IS NOT NULL AND NOT p_ecv_rec.crit_cat_numval2 = g_miss_num THEN
            p_ecv_rec.crit_cat_value2 := fnd_number.number_to_canonical(p_ecv_rec.crit_cat_numval2);
          ELSE
            p_ecv_rec.crit_cat_value2 := NULL;
          END IF;
        END IF;
      ELSIF p_ecv_rec.data_type_code = 'DATE' THEN
        IF p_ecv_rec.crit_cat_dateval1 IS NULL OR p_ecv_rec.crit_cat_dateval1 = okl_api.g_miss_date THEN
          okl_api.set_message(p_app_name     =>  g_app_name
                             ,p_msg_name     =>  g_required_value
                             ,p_token1       =>  g_col_name_token
                             ,p_token1_value =>  'CRIT_CAT_DATEVAL1');
          RAISE okl_api.g_exception_error;
        ELSE
          p_ecv_rec.crit_cat_value1 := fnd_date.date_to_canonical(p_ecv_rec.crit_cat_dateval1);
          IF p_ecv_rec.crit_cat_dateval2 IS NOT NULL AND NOT p_ecv_rec.crit_cat_dateval2 = g_miss_date THEN
            p_ecv_rec.crit_cat_value2 := fnd_date.date_to_canonical(p_ecv_rec.crit_cat_dateval2);
          ELSE
            p_ecv_rec.crit_cat_value2 := NULL;
          END IF;
        END IF;
      ELSIF p_ecv_rec.data_type_code = 'VARCHAR2' THEN
        IF p_ecv_rec.crit_cat_value1 IS NULL OR p_ecv_rec.crit_cat_value1 = okl_api.g_miss_char THEN
          okl_api.set_message(p_app_name     =>  g_app_name
                             ,p_msg_name     =>  g_required_value
                             ,p_token1       =>  g_col_name_token
                             ,p_token1_value =>  'CRIT_CAT_VALUE1');
          RAISE okl_api.g_exception_error;
        END IF;
      END IF;

      --if value type code is RANGE then min should be < than max

      IF p_ecv_rec.value_type_code = 'RANGE' THEN
        IF p_ecv_rec.data_type_code = 'NUMBER' THEN

          --CRIT_CAT_NUMVAL2 is required for Range and Number

          IF p_ecv_rec.crit_cat_numval2 IS NULL OR p_ecv_rec.crit_cat_numval2 = g_miss_num THEN
            okl_api.set_message(p_app_name     =>  g_app_name
                               ,p_msg_name     =>  g_required_value
                               ,p_token1       =>  g_col_name_token
                               ,p_token1_value =>  'CRIT_CAT_NUMVAL2');
            RAISE okl_api.g_exception_error;
          END IF;
          IF p_ecv_rec.crit_cat_numval1 > p_ecv_rec.crit_cat_numval2 THEN
            okl_api.set_message(p_app_name =>  g_app_name
                               ,p_msg_name =>  'OKL_MIN_VAL_GRTR_THAN_MAX_VAL');
            RAISE okl_api.g_exception_error;
          END IF;
        ELSIF p_ecv_rec.data_type_code = 'DATE' THEN

          --CRIT_CAT_DATEVAL2 is required for Range and Number

          IF p_ecv_rec.crit_cat_dateval2 IS NULL OR p_ecv_rec.crit_cat_dateval2 = g_miss_date THEN
            okl_api.set_message(p_app_name     =>  g_app_name
                               ,p_msg_name     =>  g_required_value
                               ,p_token1       =>  g_col_name_token
                               ,p_token1_value =>  'CRIT_CAT_DATEVAL2');
            RAISE okl_api.g_exception_error;
          END IF;
          IF p_ecv_rec.crit_cat_dateval1 > p_ecv_rec.crit_cat_dateval2 THEN
            okl_api.set_message(p_app_name =>  g_app_name
                               ,p_msg_name =>  'OKL_MIN_VAL_GRTR_THAN_MAX_VAL');
            RAISE okl_api.g_exception_error;
          END IF;
        END IF;
      END IF;

      --validate that if data type='VARCHAR2' and VALUE type = 'SINGLE then operator must be in (EQ,NE)

      IF p_ecv_rec.data_type_code = 'VARCHAR2' THEN
        IF p_ecv_rec.value_type_code = 'SINGLE' THEN
          IF p_ecv_rec.operator_code NOT IN('EQ', 'NE') THEN
            okl_api.set_message(p_app_name =>  g_app_name
                               ,p_msg_name =>  'OKL_INVALID_OP_SINGLE_VARCHAR2');
            RAISE okl_api.g_exception_error;
          END IF;
        END IF;
      END IF;
    END IF;

    --if value type = multiple and source_yn=n then populate crit_cat_value1 into crit_Cat_value2

    IF p_ecv_rec.value_type_code = 'MULTIPLE' AND p_ecv_rec.source_yn = 'N' THEN
      p_ecv_rec.crit_cat_value2 := p_ecv_rec.crit_cat_value1;
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
  -- Procedure insert_row
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_rec        IN             okl_ecv_rec
                      ,x_ecv_rec           OUT NOCOPY  okl_ecv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecv_rec                okl_ecv_rec;
    l_def_ecv_rec            okl_ecv_rec;

    FUNCTION fill_who_columns(p_ecv_rec  IN  okl_ecv_rec) RETURN okl_ecv_rec IS
      l_ecv_rec okl_ecv_rec := p_ecv_rec;

    BEGIN
      l_ecv_rec.creation_date := sysdate;
      l_ecv_rec.created_by := fnd_global.user_id;
      l_ecv_rec.last_update_date := sysdate;
      l_ecv_rec.last_updated_by := fnd_global.user_id;
      l_ecv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ecv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_ecv_rec  IN             okl_ecv_rec
                           ,x_ecv_rec     OUT NOCOPY  okl_ecv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecv_rec := p_ecv_rec;
      x_ecv_rec.object_version_number := 1;

      -- Set Primary key value

      x_ecv_rec.criterion_value_id := get_seq_id;
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

    l_ecv_rec := null_out_defaults(p_ecv_rec);

    --Setting Item Attributes

    l_return_status := set_attributes(l_ecv_rec, l_def_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --fill who columns

    l_def_ecv_rec := fill_who_columns(l_def_ecv_rec);

    --validate attributes
    --

    l_return_status := validate_attributes(l_def_ecv_rec);

    --

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record
    --

    l_return_status := validate_record(l_def_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;  --insert into table

    INSERT INTO okl_fe_criterion_values
               (criterion_value_id
               ,object_version_number
               ,criteria_id
               ,operator_code
               ,crit_cat_value2
               ,crit_cat_value1
               ,adjustment_factor
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
               ,attribute15)
    VALUES     (l_def_ecv_rec.criterion_value_id
               ,l_def_ecv_rec.object_version_number
               ,l_def_ecv_rec.criteria_id
               ,l_def_ecv_rec.operator_code
               ,l_def_ecv_rec.crit_cat_value2
               ,l_def_ecv_rec.crit_cat_value1
               ,l_def_ecv_rec.adjustment_factor
               ,l_def_ecv_rec.created_by
               ,l_def_ecv_rec.creation_date
               ,l_def_ecv_rec.last_updated_by
               ,l_def_ecv_rec.last_update_date
               ,l_def_ecv_rec.last_update_login
               ,l_def_ecv_rec.attribute_category
               ,l_def_ecv_rec.attribute1
               ,l_def_ecv_rec.attribute2
               ,l_def_ecv_rec.attribute3
               ,l_def_ecv_rec.attribute4
               ,l_def_ecv_rec.attribute5
               ,l_def_ecv_rec.attribute6
               ,l_def_ecv_rec.attribute7
               ,l_def_ecv_rec.attribute8
               ,l_def_ecv_rec.attribute9
               ,l_def_ecv_rec.attribute10
               ,l_def_ecv_rec.attribute11
               ,l_def_ecv_rec.attribute12
               ,l_def_ecv_rec.attribute13
               ,l_def_ecv_rec.attribute14
               ,l_def_ecv_rec.attribute15);

    --Set OUT Values

    x_ecv_rec := l_def_ecv_rec;
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
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl
                      ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'insert_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ecv_tbl.COUNT > 0) THEN
      i := p_ecv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ecv_rec       =>  p_ecv_tbl(i)
                  ,x_ecv_rec       =>  x_ecv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ecv_tbl.LAST);
        i := p_ecv_tbl.next(i);
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
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_rec        IN             okl_ecv_rec
                      ,x_ecv_rec           OUT NOCOPY  okl_ecv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecv_rec                okl_ecv_rec := p_ecv_rec;
    l_def_ecv_rec            okl_ecv_rec;
    l_row_notfound           boolean := true;

    FUNCTION fill_who_columns(p_ecv_rec  IN  okl_ecv_rec) RETURN okl_ecv_rec IS
      l_ecv_rec okl_ecv_rec := p_ecv_rec;

    BEGIN
      l_ecv_rec.last_update_date := sysdate;
      l_ecv_rec.last_updated_by := fnd_global.user_id;
      l_ecv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ecv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_ecv_rec  IN             okl_ecv_rec
                                ,x_ecv_rec     OUT NOCOPY  okl_ecv_rec) RETURN varchar2 IS
      l_ecv_rec       okl_ecv_rec;
      l_row_notfound  boolean := true;
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecv_rec := p_ecv_rec;

      --Get current database values

      l_ecv_rec := get_rec(p_ecv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        okl_api.set_message(g_fnd_app, g_form_record_deleted);
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_ecv_rec.criterion_value_id IS NULL) THEN
        x_ecv_rec.criterion_value_id := l_ecv_rec.criterion_value_id;
      END IF;

      IF (x_ecv_rec.criteria_id IS NULL) THEN
        x_ecv_rec.criteria_id := l_ecv_rec.criteria_id;
      END IF;

      IF (x_ecv_rec.operator_code IS NULL) THEN
        x_ecv_rec.operator_code := l_ecv_rec.operator_code;
      END IF;

      IF (x_ecv_rec.crit_cat_value2 IS NULL) THEN
        x_ecv_rec.crit_cat_value2 := l_ecv_rec.crit_cat_value2;
      END IF;

      IF (x_ecv_rec.crit_cat_value1 IS NULL) THEN
        x_ecv_rec.crit_cat_value1 := l_ecv_rec.crit_cat_value1;
      END IF;

      IF (x_ecv_rec.adjustment_factor IS NULL) THEN
        x_ecv_rec.adjustment_factor := l_ecv_rec.adjustment_factor;
      END IF;

      IF (x_ecv_rec.created_by IS NULL) THEN
        x_ecv_rec.created_by := l_ecv_rec.created_by;
      END IF;

      IF (x_ecv_rec.creation_date IS NULL) THEN
        x_ecv_rec.creation_date := l_ecv_rec.creation_date;
      END IF;

      IF (x_ecv_rec.attribute_category IS NULL) THEN
        x_ecv_rec.attribute_category := l_ecv_rec.attribute_category;
      END IF;

      IF (x_ecv_rec.attribute1 IS NULL) THEN
        x_ecv_rec.attribute1 := l_ecv_rec.attribute1;
      END IF;

      IF (x_ecv_rec.attribute2 IS NULL) THEN
        x_ecv_rec.attribute2 := l_ecv_rec.attribute2;
      END IF;

      IF (x_ecv_rec.attribute3 IS NULL) THEN
        x_ecv_rec.attribute3 := l_ecv_rec.attribute3;
      END IF;

      IF (x_ecv_rec.attribute4 IS NULL) THEN
        x_ecv_rec.attribute4 := l_ecv_rec.attribute4;
      END IF;

      IF (x_ecv_rec.attribute5 IS NULL) THEN
        x_ecv_rec.attribute5 := l_ecv_rec.attribute5;
      END IF;

      IF (x_ecv_rec.attribute6 IS NULL) THEN
        x_ecv_rec.attribute6 := l_ecv_rec.attribute6;
      END IF;

      IF (x_ecv_rec.attribute7 IS NULL) THEN
        x_ecv_rec.attribute7 := l_ecv_rec.attribute7;
      END IF;

      IF (x_ecv_rec.attribute8 IS NULL) THEN
        x_ecv_rec.attribute8 := l_ecv_rec.attribute8;
      END IF;

      IF (x_ecv_rec.attribute9 IS NULL) THEN
        x_ecv_rec.attribute9 := l_ecv_rec.attribute9;
      END IF;

      IF (x_ecv_rec.attribute10 IS NULL) THEN
        x_ecv_rec.attribute10 := l_ecv_rec.attribute10;
      END IF;

      IF (x_ecv_rec.attribute11 IS NULL) THEN
        x_ecv_rec.attribute11 := l_ecv_rec.attribute11;
      END IF;

      IF (x_ecv_rec.attribute12 IS NULL) THEN
        x_ecv_rec.attribute12 := l_ecv_rec.attribute12;
      END IF;

      IF (x_ecv_rec.attribute13 IS NULL) THEN
        x_ecv_rec.attribute13 := l_ecv_rec.attribute13;
      END IF;

      IF (x_ecv_rec.attribute14 IS NULL) THEN
        x_ecv_rec.attribute14 := l_ecv_rec.attribute14;
      END IF;

      IF (x_ecv_rec.attribute15 IS NULL) THEN
        x_ecv_rec.attribute15 := l_ecv_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_ecv_rec  IN             okl_ecv_rec
                           ,x_ecv_rec     OUT NOCOPY  okl_ecv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecv_rec := p_ecv_rec;

      --  x_ecv_rec.OBJECT_VERSION_NUMBER := NVL(x_ecv_rec.OBJECT_VERSION_NUMBER,0)+1;

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

    l_return_status := set_attributes(p_ecv_rec, l_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --populate new record

    l_return_status := populate_new_record(l_ecv_rec, l_def_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out g_miss_values

    l_def_ecv_rec := null_out_defaults(l_def_ecv_rec);

    --fill who columns
    --

    l_def_ecv_rec := fill_who_columns(l_def_ecv_rec);

    --
    --validate attributes

    l_return_status := validate_attributes(l_def_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --
    --validate record
    --

    l_return_status := validate_record(l_def_ecv_rec);

    --

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
            ,p_ecv_rec       =>  l_def_ecv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --
    --update the record

    UPDATE okl_fe_criterion_values
    SET    criterion_value_id = l_def_ecv_rec.criterion_value_id
          ,object_version_number = l_def_ecv_rec.object_version_number + 1
          ,criteria_id = l_def_ecv_rec.criteria_id
          ,operator_code = l_def_ecv_rec.operator_code
          ,crit_cat_value2 = l_def_ecv_rec.crit_cat_value2
          ,crit_cat_value1 = l_def_ecv_rec.crit_cat_value1
          ,adjustment_factor = l_def_ecv_rec.adjustment_factor
          ,created_by = l_def_ecv_rec.created_by
          ,creation_date = l_def_ecv_rec.creation_date
          ,last_updated_by = l_def_ecv_rec.last_updated_by
          ,last_update_date = l_def_ecv_rec.last_update_date
          ,last_update_login = l_def_ecv_rec.last_update_login
          ,attribute_category = l_def_ecv_rec.attribute_category
          ,attribute1 = l_def_ecv_rec.attribute1
          ,attribute2 = l_def_ecv_rec.attribute2
          ,attribute3 = l_def_ecv_rec.attribute3
          ,attribute4 = l_def_ecv_rec.attribute4
          ,attribute5 = l_def_ecv_rec.attribute5
          ,attribute6 = l_def_ecv_rec.attribute6
          ,attribute7 = l_def_ecv_rec.attribute7
          ,attribute8 = l_def_ecv_rec.attribute8
          ,attribute9 = l_def_ecv_rec.attribute9
          ,attribute10 = l_def_ecv_rec.attribute10
          ,attribute11 = l_def_ecv_rec.attribute11
          ,attribute12 = l_def_ecv_rec.attribute12
          ,attribute13 = l_def_ecv_rec.attribute13
          ,attribute14 = l_def_ecv_rec.attribute14
          ,attribute15 = l_def_ecv_rec.attribute15
    WHERE  criterion_value_id = l_def_ecv_rec.criterion_value_id;

    --Set OUT Values

    x_ecv_rec := l_def_ecv_rec;
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
  -- Procedure update_row_tbl
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl
                      ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'update_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ecv_tbl.COUNT > 0) THEN
      i := p_ecv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ecv_rec       =>  p_ecv_tbl(i)
                  ,x_ecv_rec       =>  x_ecv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ecv_tbl.LAST);
        i := p_ecv_tbl.next(i);
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
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_rec        IN             okl_ecv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecv_rec                okl_ecv_rec := p_ecv_rec;
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

    DELETE FROM okl_fe_criterion_values
    WHERE       criterion_value_id = l_ecv_rec.criterion_value_id;
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
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'v_delete_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ecv_tbl.COUNT > 0) THEN
      i := p_ecv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ecv_rec       =>  p_ecv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ecv_tbl.LAST);
        i := p_ecv_tbl.next(i);
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

END okl_ecv_pvt;

/
