--------------------------------------------------------
--  DDL for Package Body OKL_ECH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECH_PVT" AS
/* $Header: OKLSECHB.pls 120.1 2005/10/30 04:59:14 appldev noship $ */

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
  -- lock_row for:OKL_FE_CRITERIA_SET --
  ---------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_ech_rec        IN             okl_ech_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_ech_rec  IN  okl_ech_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_criteria_set
      WHERE         criteria_set_id = p_ech_rec.criteria_set_id
                AND object_version_number = p_ech_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_ech_rec  IN  okl_ech_rec) IS
      SELECT object_version_number
      FROM   okl_fe_criteria_set
      WHERE  criteria_set_id = p_ech_rec.criteria_set_id;
    l_api_version            CONSTANT number := 1;
    l_api_name               CONSTANT varchar2(30) := 'B_lock_row';
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_criteria_set.object_version_number%TYPE;
    lc_object_version_number          okl_fe_criteria_set.object_version_number%TYPE;
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
      OPEN lock_csr(p_ech_rec);
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
      OPEN lchk_csr(p_ech_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_ech_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_ech_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okl_api.set_message(g_app_name, g_record_logically_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count, x_msg_data);
    x_return_status := l_return_status;

    --

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
  -- PL/SQL TBL lock_row for: OKL_FE_CRITERIA_SET --
  --------------------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_ech_tbl        IN             okl_ech_tbl) IS
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

    IF (p_ech_tbl.COUNT > 0) THEN
      i := p_ech_tbl.FIRST;

      LOOP
        lock_row(p_init_msg_list =>  okl_api.g_false
                ,x_return_status =>  x_return_status
                ,x_msg_count     =>  x_msg_count
                ,x_msg_data      =>  x_msg_data
                ,p_ech_rec       =>  p_ech_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_ech_tbl.LAST);
        i := p_ech_tbl.next(i);
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

  -----------------------------------
  -- Function Name  : validate_CRITERIA_SET_ID
  -----------------------------------

  FUNCTION validate_criteria_set_id(p_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_CRITERIA_SET_ID';

  BEGIN

    --
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
  END validate_criteria_set_id;

  ----------------------------------------------------
  -- Function Name  : validate_object_version_number
  ----------------------------------------------------

  FUNCTION validate_object_version_number(p_object_version_number  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_version_number';

  BEGIN

    --
    -- data is required

    IF (p_object_version_number IS NULL) OR (p_object_version_number = okl_api.g_miss_num) THEN
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

  ---------------------------------------------
  -- Function Name  : validate_SOURCE_ID
  ---------------------------------------------

  FUNCTION validate_source_id(p_source_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_source_id';

  BEGIN

    --
    -- data is required

    IF (p_source_id IS NULL) OR (p_source_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'SOURCE_ID');
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
  END validate_source_id;

  ------------------------------------------------
  -- Function Name  : validate_SOURCE_OBJECT_CODE
  ------------------------------------------------

  FUNCTION validate_source_object_code(p_source_object_code  IN  varchar2) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_SOURCE_OBJECT_CODE';

  BEGIN

    --
    -- data is required

    IF (p_source_object_code IS NULL) OR (p_source_object_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'SOURCE_OBJECT_CODE');
      RAISE okl_api.g_exception_error;
    END IF;

    --if source object is not Adjustment MAtrix then it should belong to lookup OKL_ECC_OBJECT_CLASSES

    IF p_source_object_code <> 'PAM' THEN
      l_return_status := okl_util.check_lookup_code(p_lookup_type =>  'OKL_ECC_OBJECT_CLASSES'
                                                   ,p_lookup_code =>  p_source_object_code);
      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'SOURCE_OBJECT_CODE');
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
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
  END validate_source_object_code;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_CRITERIA_SET
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ech_rec        IN             okl_ech_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_ech_rec IS

    CURSOR ech_pk_csr(p_id  IN  number) IS
      SELECT criteria_set_id
            ,object_version_number
            ,source_id
            ,source_object_code
            ,match_criteria_code
            ,validation_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_criteria_set
      WHERE  okl_fe_criteria_set.criteria_set_id = p_id;
    l_ech_pk  ech_pk_csr%ROWTYPE;
    l_ech_rec okl_ech_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN ech_pk_csr(p_ech_rec.criteria_set_id);
    FETCH ech_pk_csr INTO l_ech_rec.criteria_set_id
                         ,l_ech_rec.object_version_number
                         ,l_ech_rec.source_id
                         ,l_ech_rec.source_object_code
                         ,l_ech_rec.match_criteria_code
                         ,l_ech_rec.validation_code
                         ,l_ech_rec.created_by
                         ,l_ech_rec.creation_date
                         ,l_ech_rec.last_updated_by
                         ,l_ech_rec.last_update_date
                         ,l_ech_rec.last_update_login ;
    x_no_data_found := ech_pk_csr%NOTFOUND;
    CLOSE ech_pk_csr;
    RETURN(l_ech_rec);
  END get_rec;

  FUNCTION get_rec(p_ech_rec  IN  okl_ech_rec) RETURN okl_ech_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_ech_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_ech_rec  IN  okl_ech_rec) RETURN okl_ech_rec IS
    l_ech_rec okl_ech_rec := p_ech_rec;

  BEGIN

    IF (l_ech_rec.criteria_set_id = okl_api.g_miss_num) THEN
      l_ech_rec.criteria_set_id := NULL;
    END IF;

    IF (l_ech_rec.object_version_number = okl_api.g_miss_num) THEN
      l_ech_rec.object_version_number := NULL;
    END IF;

    IF (l_ech_rec.source_id = okl_api.g_miss_num) THEN
      l_ech_rec.source_id := NULL;
    END IF;

    IF (l_ech_rec.source_object_code = okl_api.g_miss_char) THEN
      l_ech_rec.source_object_code := NULL;
    END IF;

    IF (l_ech_rec.match_criteria_code = okl_api.g_miss_char) THEN
      l_ech_rec.match_criteria_code := NULL;
    END IF;

    IF (l_ech_rec.validation_code = okl_api.g_miss_char) THEN
      l_ech_rec.validation_code := NULL;
    END IF;

    IF (l_ech_rec.created_by = okl_api.g_miss_num) THEN
      l_ech_rec.created_by := NULL;
    END IF;

    IF (l_ech_rec.creation_date = okl_api.g_miss_date) THEN
      l_ech_rec.creation_date := NULL;
    END IF;

    IF (l_ech_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_ech_rec.last_updated_by := NULL;
    END IF;

    IF (l_ech_rec.last_update_date = okl_api.g_miss_date) THEN
      l_ech_rec.last_update_date := NULL;
    END IF;

    IF (l_ech_rec.last_update_login = okl_api.g_miss_num) THEN
      l_ech_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ech_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN number IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_attributes(p_ech_rec  IN  okl_ech_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN

    --

    l_return_status := validate_criteria_set_id(p_ech_rec.criteria_set_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_object_version_number(p_ech_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_source_id(p_ech_rec.source_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_source_object_code(p_ech_rec.source_object_code);

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

  FUNCTION validate_record(p_ech_rec  IN  okl_ech_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'Validate_Record';

  BEGIN

    IF p_ech_rec.source_object_code <> 'PAM' THEN

      --validate match_criteria_code

      IF (p_ech_rec.match_criteria_code IS NULL) OR (p_ech_rec.match_criteria_code = okl_api.g_miss_char) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_required_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'MATCH_CRITERIA_CODE');
        RAISE okl_api.g_exception_error;
      END IF;
      l_return_status := okl_util.check_lookup_code(p_lookup_type =>  'OKL_EC_MATCH_CRITERIA'
                                                   ,p_lookup_code =>  p_ech_rec.match_criteria_code);
      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'MATCH_CRITERIA_CODE');
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;

      --validate validation_code

      IF (p_ech_rec.validation_code IS NULL) OR (p_ech_rec.validation_code = okl_api.g_miss_char) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_required_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'validation');
        RAISE okl_api.g_exception_error;
      END IF;
      l_return_status := okl_util.check_lookup_code(p_lookup_type =>  'OKL_EC_VALIDATIONS'
                                                   ,p_lookup_code =>  p_ech_rec.validation_code);
      IF (l_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_invalid_value
                           ,p_token1       =>  g_col_name_token
                           ,p_token1_value =>  'validation');
        RAISE okl_api.g_exception_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      END IF;
    END IF;
    RETURN(x_return_status);
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
  END validate_record;

  --------------------------------------------------------------------------------
  -- Procedure insert_row
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ech_rec        IN             okl_ech_rec
                      ,x_ech_rec           OUT NOCOPY  okl_ech_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ech_rec                okl_ech_rec;
    l_def_ech_rec            okl_ech_rec;

    FUNCTION fill_who_columns(p_ech_rec  IN  okl_ech_rec) RETURN okl_ech_rec IS
      l_ech_rec okl_ech_rec := p_ech_rec;

    BEGIN
      l_ech_rec.creation_date := sysdate;
      l_ech_rec.created_by := fnd_global.user_id;
      l_ech_rec.last_update_date := sysdate;
      l_ech_rec.last_updated_by := fnd_global.user_id;
      l_ech_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ech_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_ech_rec  IN             okl_ech_rec
                           ,x_ech_rec     OUT NOCOPY  okl_ech_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ech_rec := p_ech_rec;
      x_ech_rec.object_version_number := 1;

      -- Set Primary key value

      x_ech_rec.criteria_set_id := get_seq_id;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN

    --

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

    --
    --null out defaults

    l_ech_rec := null_out_defaults(p_ech_rec);

    --
    --Setting Item Attributes

    l_return_status := set_attributes(l_ech_rec, l_def_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --
    --fill who columns

    l_def_ech_rec := fill_who_columns(l_def_ech_rec);

    --validate attributes
    --

    l_return_status := validate_attributes(l_def_ech_rec);

    --

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record
    --

    l_return_status := validate_record(l_def_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;  --insert into table

    INSERT INTO okl_fe_criteria_set
               (criteria_set_id
               ,object_version_number
               ,source_id
               ,source_object_code
               ,match_criteria_code
               ,validation_code
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login)
    VALUES     (l_def_ech_rec.criteria_set_id
               ,l_def_ech_rec.object_version_number
               ,l_def_ech_rec.source_id
               ,l_def_ech_rec.source_object_code
               ,l_def_ech_rec.match_criteria_code
               ,l_def_ech_rec.validation_code
               ,l_def_ech_rec.created_by
               ,l_def_ech_rec.creation_date
               ,l_def_ech_rec.last_updated_by
               ,l_def_ech_rec.last_update_date
               ,l_def_ech_rec.last_update_login);

    --Set OUT Values

    x_ech_rec := l_def_ech_rec;
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
                      ,p_ech_tbl        IN             okl_ech_tbl
                      ,x_ech_tbl           OUT NOCOPY  okl_ech_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'insert_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ech_tbl.COUNT > 0) THEN
      i := p_ech_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ech_rec       =>  p_ech_tbl(i)
                  ,x_ech_rec       =>  x_ech_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ech_tbl.LAST);
        i := p_ech_tbl.next(i);
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
                      ,p_ech_rec        IN             okl_ech_rec
                      ,x_ech_rec           OUT NOCOPY  okl_ech_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ech_rec                okl_ech_rec := p_ech_rec;
    l_def_ech_rec            okl_ech_rec;
    l_row_notfound           boolean := true;

    FUNCTION fill_who_columns(p_ech_rec  IN  okl_ech_rec) RETURN okl_ech_rec IS
      l_ech_rec okl_ech_rec := p_ech_rec;

    BEGIN
      l_ech_rec.last_update_date := sysdate;
      l_ech_rec.last_updated_by := fnd_global.user_id;
      l_ech_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ech_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_ech_rec  IN             okl_ech_rec
                                ,x_ech_rec     OUT NOCOPY  okl_ech_rec) RETURN varchar2 IS
      l_ech_rec       okl_ech_rec;
      l_row_notfound  boolean := true;
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ech_rec := p_ech_rec;

      --Get current database values

      l_ech_rec := get_rec(p_ech_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_ech_rec.criteria_set_id IS NULL) THEN
        x_ech_rec.criteria_set_id := l_ech_rec.criteria_set_id;
      END IF;

      IF (x_ech_rec.source_id IS NULL) THEN
        x_ech_rec.source_id := l_ech_rec.source_id;
      END IF;

      IF (x_ech_rec.source_object_code IS NULL) THEN
        x_ech_rec.source_object_code := l_ech_rec.source_object_code;
      END IF;

      IF (x_ech_rec.match_criteria_code IS NULL) THEN
        x_ech_rec.match_criteria_code := l_ech_rec.match_criteria_code;
      END IF;

      IF (x_ech_rec.validation_code IS NULL) THEN
        x_ech_rec.validation_code := l_ech_rec.validation_code;
      END IF;

      IF (x_ech_rec.created_by IS NULL) THEN
        x_ech_rec.created_by := l_ech_rec.created_by;
      END IF;

      IF (x_ech_rec.creation_date IS NULL) THEN
        x_ech_rec.creation_date := l_ech_rec.creation_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_ech_rec  IN             okl_ech_rec
                           ,x_ech_rec     OUT NOCOPY  okl_ech_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ech_rec := p_ech_rec;
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

    l_return_status := set_attributes(p_ech_rec, l_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    l_return_status := populate_new_record(l_ech_rec, l_def_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out G miss values

    l_def_ech_rec := null_out_defaults(l_def_ech_rec);

    --fill who columns


    l_def_ech_rec := fill_who_columns(l_def_ech_rec);


    --validate attributes

    l_return_status := validate_attributes(l_def_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;


    --validate record

    l_return_status := validate_record(l_def_ech_rec);

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
            ,p_ech_rec       =>  l_def_ech_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --update the record



    UPDATE okl_fe_criteria_set
    SET    criteria_set_id = l_def_ech_rec.criteria_set_id
          ,object_version_number = l_def_ech_rec.object_version_number + 1
          ,source_id = l_def_ech_rec.source_id
          ,source_object_code = l_def_ech_rec.source_object_code
          ,match_criteria_code = l_def_ech_rec.match_criteria_code
          ,validation_code = l_def_ech_rec.validation_code
          ,created_by = l_def_ech_rec.created_by
          ,creation_date = l_def_ech_rec.creation_date
          ,last_updated_by = l_def_ech_rec.last_updated_by
          ,last_update_date = l_def_ech_rec.last_update_date
          ,last_update_login = l_def_ech_rec.last_update_login
    WHERE  criteria_set_id = l_def_ech_rec.criteria_set_id;


    --Set OUT Values

    x_ech_rec := l_def_ech_rec;
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
                      ,p_ech_tbl        IN             okl_ech_tbl
                      ,x_ech_tbl           OUT NOCOPY  okl_ech_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'update_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ech_tbl.COUNT > 0) THEN
      i := p_ech_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ech_rec       =>  p_ech_tbl(i)
                  ,x_ech_rec       =>  x_ech_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ech_tbl.LAST);
        i := p_ech_tbl.next(i);
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
                      ,p_ech_rec        IN             okl_ech_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ech_rec                okl_ech_rec := p_ech_rec;
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

    DELETE FROM okl_fe_criteria_set
    WHERE       criteria_set_id = l_ech_rec.criteria_set_id;
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
                      ,p_ech_tbl        IN             okl_ech_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'delete_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ech_tbl.COUNT > 0) THEN
      i := p_ech_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>  p_api_version
                  ,p_init_msg_list =>  okl_api.g_false
                  ,x_return_status =>  x_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_ech_rec       =>  p_ech_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ech_tbl.LAST);
        i := p_ech_tbl.next(i);
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

END okl_ech_pvt;

/
