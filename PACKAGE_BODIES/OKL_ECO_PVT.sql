--------------------------------------------------------
--  DDL for Package Body OKL_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECO_PVT" AS
/* $Header: OKLSECOB.pls 120.3 2006/12/07 08:58:16 ssdeshpa noship $ */

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

  -------------------------------------------
  -- lock_row for:OKL_FE_CRIT_CAT_OBJECTS --
  -------------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_eco_rec        IN             okl_eco_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_eco_rec  IN  okl_eco_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_crit_cat_objects
      WHERE         object_class_id = p_eco_rec.object_class_id
                AND object_version_number = p_eco_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_eco_rec  IN  okl_eco_rec) IS
      SELECT object_version_number
      FROM   okl_fe_crit_cat_objects
      WHERE  object_class_id = p_eco_rec.object_class_id;
    l_api_version            CONSTANT number := 1;
    l_api_name               CONSTANT varchar2(30) := 'B_lock_row';
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_crit_cat_objects.object_version_number%TYPE;
    lc_object_version_number          okl_fe_crit_cat_objects.object_version_number%TYPE;
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
      OPEN lock_csr(p_eco_rec);
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
      OPEN lchk_csr(p_eco_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_eco_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_eco_rec.object_version_number THEN
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
  -- PL/SQL TBL lock_row for: OKL_FE_CRIT_CAT_OBJECTS --
  --------------------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_eco_tbl        IN             okl_eco_tbl) IS
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

    IF (p_eco_tbl.COUNT > 0) THEN
      i := p_eco_tbl.FIRST;

      LOOP
        lock_row(p_init_msg_list =>            okl_api.g_false
                ,x_return_status =>            x_return_status
                ,x_msg_count     =>            x_msg_count
                ,x_msg_data      =>            x_msg_data
                ,p_eco_rec       =>            p_eco_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_eco_tbl.LAST);
        i := p_eco_tbl.next(i);
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

  --------------------------------------------------
  -- Function Name  : validate_object_class_id
  ---------------------------------------------------

  FUNCTION validate_object_class_id(p_object_class_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_class_id';

  BEGIN

    -- object_class_id is required

    IF (p_object_class_id IS NULL) OR (p_object_class_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'object_class_id');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             'SQLCODE'
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             'SQLERRM'
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_object_class_id;

  ---------------------------------------------------
  -- Function Name  : validate_object_version_number
  ---------------------------------------------------

  FUNCTION validate_object_version_number(p_object_version_number  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_version_number';

  BEGIN

    -- object_version_numbe is required

    IF (p_object_version_number IS NULL) OR (p_object_version_number = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'object_version_number');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             'SQLCODE'
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             'SQLERRM'
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_object_version_number;

  ----------------------------------------------
  -- Function Name  : validate_object_class_code
  ----------------------------------------------

  FUNCTION validate_object_class_code(p_object_class_code  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_class_code';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- object_class_code is required

    IF (p_object_class_code IS NULL) OR (p_object_class_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'object_class_code');
      RAISE okl_api.g_exception_error;
    END IF;

    --object_class_code should belong to llokup type OKL_ECC_OBJECT_CLASSES

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_ECC_OBJECT_CLASSES'
                                                 ,p_lookup_code =>              p_object_class_code);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'object_class_code');
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
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             'SQLCODE'
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             'SQLERRM'
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_object_class_code;

  -------------------------------------------------
  -- Function Name  : validate_crit_cat_def_id
  -------------------------------------------------

  FUNCTION validate_crit_cat_def_id(p_crit_cat_def_id  IN  number) RETURN varchar2 IS
    l_api_name  CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_crit_cat_def_id';
    l_dummy_var          varchar2(1) := '?';

    -- select the ID of the parent record from the parent table

    CURSOR l_ecc_csr IS
      SELECT 'x'
      FROM   okl_fe_crit_cat_def_v
      WHERE  crit_cat_def_id = p_crit_cat_def_id;

  BEGIN

    -- crit_cat_def_id is required

    IF (p_crit_cat_def_id IS NULL) OR (p_crit_cat_def_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'CRIT_CAT_DEF_IDUPD');

      -- halt further validation of this column

      RAISE okl_api.g_exception_error;
    END IF;

    -- enforce foreign key

    OPEN l_ecc_csr;
    FETCH l_ecc_csr INTO l_dummy_var ;
    CLOSE l_ecc_csr;

    -- if l_dummy_var is still set to default, data was not found

    IF (l_dummy_var = '?') THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_no_parent_record
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'CRIT_CAT_DEF_ID'
                         ,p_token2       =>             g_child_table_token
                         ,p_token2_value =>             'OKL_FE_CRIT_CAT_OBJECTS'
                         ,p_token3       =>             g_parent_table_token
                         ,p_token3_value =>             'OKL_FE_CRIT_CAT_DEF_V');
      RAISE okl_api.g_exception_error;
    END IF;
    RETURN g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN

        -- verify that cursor was closed

        IF l_ecc_csr%ISOPEN THEN
          CLOSE l_ecc_csr;
        END IF;
        RETURN g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN

        -- verify that cursor was closed

        IF l_ecc_csr%ISOPEN THEN
          CLOSE l_ecc_csr;
        END IF;
        RETURN g_ret_sts_unexp_error;
      WHEN OTHERS THEN

        -- verify that cursor was closed

        IF l_ecc_csr%ISOPEN THEN
          CLOSE l_ecc_csr;
        END IF;
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             'SQLCODE'
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             'SQLERRM'
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_crit_cat_def_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------

  FUNCTION validate_attributes(p_eco_rec  IN  okl_eco_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN

    -- call each column-level validation

    /*******************/

    -- object_class_id

    /*******************/

    l_return_status := validate_object_class_id(p_eco_rec.object_class_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    /***********************/

    -- object_version_number

    /***********************/

    l_return_status := validate_object_version_number(p_eco_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    /*******************/

    -- crit_cat_def_id

    /*******************/

    l_return_status := validate_crit_cat_def_id(p_eco_rec.crit_cat_def_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    /*******************/

    -- object_class_code

    /*******************/

    l_return_status := validate_object_class_code(p_eco_rec.object_class_code);

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
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             'SQLCODE'
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             'SQLERRM'
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_attributes;

  --------------------------------------------
  -- Validate_Record for:OKL_FE_CRIT_CAT_OBJECTS --
  --------------------------------------------

  FUNCTION validate_record(p_eco_rec  IN  okl_eco_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_record';

  BEGIN
    RETURN(l_return_status);
  END validate_record;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_CRIT_CAT_OBJECTS
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_eco_rec        IN             okl_eco_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_eco_rec IS

    CURSOR eco_pk_csr(p_id  IN  number) IS
      SELECT object_class_id
            ,object_version_number
            ,crit_cat_def_id
            ,object_class_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_crit_cat_objects
      WHERE  okl_fe_crit_cat_objects.object_class_id = p_id;
    l_eco_pk  eco_pk_csr%ROWTYPE;
    l_eco_rec okl_eco_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN eco_pk_csr(p_eco_rec.object_class_id);
    FETCH eco_pk_csr INTO l_eco_rec.object_class_id
                         ,l_eco_rec.object_version_number
                         ,l_eco_rec.crit_cat_def_id
                         ,l_eco_rec.object_class_code
                         ,l_eco_rec.created_by
                         ,l_eco_rec.creation_date
                         ,l_eco_rec.last_updated_by
                         ,l_eco_rec.last_update_date
                         ,l_eco_rec.last_update_login ;
    x_no_data_found := eco_pk_csr%NOTFOUND;
    CLOSE eco_pk_csr;
    RETURN(l_eco_rec);
  END get_rec;

  FUNCTION get_rec(p_eco_rec  IN  okl_eco_rec) RETURN okl_eco_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_eco_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_eco_rec  IN  okl_eco_rec) RETURN okl_eco_rec IS
    l_eco_rec okl_eco_rec := p_eco_rec;

  BEGIN

    IF (l_eco_rec.object_class_id = okl_api.g_miss_num) THEN
      l_eco_rec.object_class_id := NULL;
    END IF;

    IF (l_eco_rec.object_version_number = g_miss_num) THEN
      l_eco_rec.object_version_number := NULL;
    END IF;

    IF (l_eco_rec.crit_cat_def_id = okl_api.g_miss_num) THEN
      l_eco_rec.crit_cat_def_id := NULL;
    END IF;

    IF (l_eco_rec.object_class_code = okl_api.g_miss_char) THEN
      l_eco_rec.object_class_code := NULL;
    END IF;

    IF (l_eco_rec.created_by = okl_api.g_miss_num) THEN
      l_eco_rec.created_by := NULL;
    END IF;

    IF (l_eco_rec.creation_date = okl_api.g_miss_date) THEN
      l_eco_rec.creation_date := NULL;
    END IF;

    IF (l_eco_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_eco_rec.last_updated_by := NULL;
    END IF;

    IF (l_eco_rec.last_update_date = okl_api.g_miss_date) THEN
      l_eco_rec.last_update_date := NULL;
    END IF;

    IF (l_eco_rec.last_update_login = okl_api.g_miss_num) THEN
      l_eco_rec.last_update_login := NULL;
    END IF;
    RETURN(l_eco_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN number IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  --------------------------------------------------------------------------------
  -- Procedure insert_row
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_rec        IN             okl_eco_rec
                      ,x_eco_rec           OUT NOCOPY  okl_eco_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eco_rec                okl_eco_rec;
    l_def_eco_rec            okl_eco_rec;

    FUNCTION fill_who_columns(p_eco_rec  IN  okl_eco_rec) RETURN okl_eco_rec IS
      l_eco_rec okl_eco_rec := p_eco_rec;

    BEGIN
      l_eco_rec.creation_date := sysdate;
      l_eco_rec.created_by := fnd_global.user_id;
      l_eco_rec.last_update_date := sysdate;
      l_eco_rec.last_updated_by := fnd_global.user_id;
      l_eco_rec.last_update_login := fnd_global.login_id;
      RETURN(l_eco_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_eco_rec  IN             okl_eco_rec
                           ,x_eco_rec     OUT NOCOPY  okl_eco_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eco_rec := p_eco_rec;
      x_eco_rec.object_version_number := 1;

      -- Set Primary key value

      x_eco_rec.object_class_id := get_seq_id;
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

    l_eco_rec := null_out_defaults(p_eco_rec);

    --Setting Item Attributes

    l_return_status := set_attributes(l_eco_rec, l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --fill who columns

    l_def_eco_rec := fill_who_columns(l_def_eco_rec);

    --validate attributes

    l_return_status := validate_attributes(l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record

    l_return_status := validate_record(l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --insert into table

    INSERT INTO okl_fe_crit_cat_objects
               (object_class_id
               ,object_version_number
               ,crit_cat_def_id
               ,object_class_code
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login)
    VALUES     (l_def_eco_rec.object_class_id
               ,l_def_eco_rec.object_version_number
               ,l_def_eco_rec.crit_cat_def_id
               ,l_def_eco_rec.object_class_code
               ,l_def_eco_rec.created_by
               ,l_def_eco_rec.creation_date
               ,l_def_eco_rec.last_updated_by
               ,l_def_eco_rec.last_update_date
               ,l_def_eco_rec.last_update_login);

    --Set OUT Values

    x_eco_rec := l_def_eco_rec;
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
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'insert_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eco_tbl.COUNT > 0) THEN
      i := p_eco_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eco_rec       =>            p_eco_tbl(i)
                  ,x_eco_rec       =>            x_eco_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eco_tbl.LAST);
        i := p_eco_tbl.next(i);
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
                      ,p_eco_rec        IN             okl_eco_rec
                      ,x_eco_rec           OUT NOCOPY  okl_eco_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eco_rec                okl_eco_rec := p_eco_rec;
    l_def_eco_rec            okl_eco_rec;
    l_row_notfound           boolean := true;

    FUNCTION fill_who_columns(p_eco_rec  IN  okl_eco_rec) RETURN okl_eco_rec IS
      l_eco_rec okl_eco_rec := p_eco_rec;

    BEGIN
      l_eco_rec.last_update_date := sysdate;
      l_eco_rec.last_updated_by := fnd_global.user_id;
      l_eco_rec.last_update_login := fnd_global.login_id;
      RETURN(l_eco_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_eco_rec  IN             okl_eco_rec
                                ,x_eco_rec     OUT NOCOPY  okl_eco_rec) RETURN varchar2 IS
      l_eco_rec       okl_eco_rec;
      l_row_notfound  boolean := true;
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eco_rec := p_eco_rec;

      --Get current database values

      l_eco_rec := get_rec(p_eco_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      --dont default object_version_number, last_updated_by, last_updat_date  and last_update_login

      IF (x_eco_rec.object_class_id IS NULL) THEN
        x_eco_rec.object_class_id := l_eco_rec.object_class_id;
      END IF;

      IF (x_eco_rec.crit_cat_def_id IS NULL) THEN
        x_eco_rec.crit_cat_def_id := l_eco_rec.crit_cat_def_id;
      END IF;

      IF (x_eco_rec.object_class_code IS NULL) THEN
        x_eco_rec.object_class_code := l_eco_rec.object_class_code;
      END IF;

      IF (x_eco_rec.created_by IS NULL) THEN
        x_eco_rec.created_by := l_eco_rec.created_by;
      END IF;

      IF (x_eco_rec.creation_date IS NULL) THEN
        x_eco_rec.creation_date := l_eco_rec.creation_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_eco_rec  IN             okl_eco_rec
                           ,x_eco_rec     OUT NOCOPY  okl_eco_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eco_rec := p_eco_rec;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN

    --start activity

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

    l_return_status := set_attributes(p_eco_rec, l_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --populate new record

    l_return_status := populate_new_record(l_eco_rec, l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out G Miss values

    l_def_eco_rec := null_out_defaults(l_def_eco_rec);

    --fill who columns

    l_def_eco_rec := fill_who_columns(l_def_eco_rec);

    --validate attributes

    l_return_status := validate_attributes(l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record

    l_return_status := validate_record(l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --lock the row

    lock_row(p_init_msg_list =>            okl_api.g_false
            ,x_return_status =>            l_return_status
            ,x_msg_count     =>            x_msg_count
            ,x_msg_data      =>            x_msg_data
            ,p_eco_rec       =>            l_def_eco_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --update the record

    UPDATE okl_fe_crit_cat_objects
    SET    object_class_id = l_def_eco_rec.object_class_id
          ,object_version_number = l_def_eco_rec.object_version_number + 1
          ,crit_cat_def_id = l_def_eco_rec.crit_cat_def_id
          ,object_class_code = l_def_eco_rec.object_class_code
          ,created_by = l_def_eco_rec.created_by
          ,creation_date = l_def_eco_rec.creation_date
          ,last_updated_by = l_def_eco_rec.last_updated_by
          ,last_update_date = l_def_eco_rec.last_update_date
          ,last_update_login = l_def_eco_rec.last_update_login
    WHERE  object_class_id = l_def_eco_rec.object_class_id;

    --Set OUT Values

    x_eco_rec := l_def_eco_rec;
    x_return_status := l_return_status;

    --end activity

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
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'update_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eco_tbl.COUNT > 0) THEN
      i := p_eco_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eco_rec       =>            p_eco_tbl(i)
                  ,x_eco_rec       =>            x_eco_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eco_tbl.LAST);
        i := p_eco_tbl.next(i);
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
                      ,p_eco_rec        IN             okl_eco_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eco_rec                okl_eco_rec := p_eco_rec;
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

    DELETE FROM okl_fe_crit_cat_objects
    WHERE       object_class_id = l_eco_rec.object_class_id;

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
                      ,p_eco_tbl        IN             okl_eco_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'delete_row_tbl';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eco_tbl.COUNT > 0) THEN
      i := p_eco_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eco_rec       =>            p_eco_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eco_tbl.LAST);
        i := p_eco_tbl.next(i);
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
 ----------------------------------------
 -- Procedure LOAD_SEED_ROW
 ----------------------------------------
  PROCEDURE LOAD_SEED_ROW(p_object_class_id        IN VARCHAR2,
	                  p_object_version_number  IN VARCHAR2,
	                  p_crit_cat_def_id        IN VARCHAR2,
	                  p_object_class_code      IN VARCHAR2,
                          p_owner                  IN VARCHAR2,
                          p_last_update_date       IN VARCHAR2) IS

    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_init_msg_list          VARCHAR2(1):= 'T';

  BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);
    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN

       SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
       into id, db_luby, db_ludate
       from OKL_FE_CRIT_CAT_OBJECTS
       where OBJECT_CLASS_ID  = p_object_class_id;

       IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
         UPDATE OKL_FE_CRIT_CAT_OBJECTS
         SET
          OBJECT_VERSION_NUMBER = p_object_version_number,
          CRIT_CAT_DEF_ID       = to_number(p_crit_cat_def_id),
          OBJECT_CLASS_CODE     = p_object_class_code,
          LAST_UPDATE_DATE      = f_ludate,
          LAST_UPDATED_BY       = f_luby,
          LAST_UPDATE_LOGIN     = 0
         WHERE OBJECT_CLASS_ID = to_number(p_object_class_id);
       END IF;
     exception
      when no_data_found then
          INSERT INTO OKL_FE_CRIT_CAT_OBJECTS
          (OBJECT_CLASS_ID,
           OBJECT_VERSION_NUMBER,
           CRIT_CAT_DEF_ID,
           OBJECT_CLASS_CODE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
           )
          VALUES(
           TO_NUMBER(p_object_class_id),
           p_OBJECT_VERSION_NUMBER,
           TO_NUMBER(p_crit_cat_def_id),
           p_object_class_code,
           f_luby,
           f_ludate,
           f_luby,
           f_ludate,
           0);
    END;
 END LOAD_SEED_ROW;

END okl_eco_pvt;

/
