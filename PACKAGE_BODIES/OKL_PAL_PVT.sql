--------------------------------------------------------
--  DDL for Package Body OKL_PAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAL_PVT" AS
/* $Header: OKLSPALB.pls 120.1 2005/10/18 14:03:51 viselvar noship $ */

  g_no_parent_record   CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLerrm';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLcode';
  g_exception_halt_validation EXCEPTION;

  PROCEDURE api_copy IS

  BEGIN
    NULL;
  END api_copy;

  PROCEDURE change_version IS

  BEGIN
    NULL;
  END change_version;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_ADJ_MAT_VERSIONS
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_pal_rec       IN            okl_pal_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_pal_rec IS

    CURSOR pal_pk_csr(p_id IN NUMBER) IS
      SELECT adj_mat_version_id
            ,object_version_number
            ,version_number
            ,adj_mat_id
            ,sts_code
            ,effective_from_date
            ,effective_to_date
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
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_adj_mat_versions
      WHERE  okl_fe_adj_mat_versions.adj_mat_version_id = p_id;
    l_pal_pk                     pal_pk_csr%ROWTYPE;
    l_pal_rec                    okl_pal_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN pal_pk_csr(p_pal_rec.adj_mat_version_id);
    FETCH pal_pk_csr INTO l_pal_rec.adj_mat_version_id
                         ,l_pal_rec.object_version_number
                         ,l_pal_rec.version_number
                         ,l_pal_rec.adj_mat_id
                         ,l_pal_rec.sts_code
                         ,l_pal_rec.effective_from_date
                         ,l_pal_rec.effective_to_date
                         ,l_pal_rec.attribute_category
                         ,l_pal_rec.attribute1
                         ,l_pal_rec.attribute2
                         ,l_pal_rec.attribute3
                         ,l_pal_rec.attribute4
                         ,l_pal_rec.attribute5
                         ,l_pal_rec.attribute6
                         ,l_pal_rec.attribute7
                         ,l_pal_rec.attribute8
                         ,l_pal_rec.attribute9
                         ,l_pal_rec.attribute10
                         ,l_pal_rec.attribute11
                         ,l_pal_rec.attribute12
                         ,l_pal_rec.attribute13
                         ,l_pal_rec.attribute14
                         ,l_pal_rec.attribute15
                         ,l_pal_rec.created_by
                         ,l_pal_rec.creation_date
                         ,l_pal_rec.last_updated_by
                         ,l_pal_rec.last_update_date
                         ,l_pal_rec.last_update_login ;
    x_no_data_found := pal_pk_csr%NOTFOUND;
    CLOSE pal_pk_csr;
    RETURN(l_pal_rec);
  END get_rec;

  FUNCTION get_rec(p_pal_rec IN okl_pal_rec) RETURN okl_pal_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_pal_rec
                  ,l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_pal_rec IN okl_pal_rec) RETURN okl_pal_rec IS
    l_pal_rec                    okl_pal_rec := p_pal_rec;

  BEGIN

    IF (l_pal_rec.adj_mat_version_id = okl_api.g_miss_num) THEN
      l_pal_rec.adj_mat_version_id := NULL;
    END IF;

    IF (l_pal_rec.object_version_number = okl_api.g_miss_num) THEN
      l_pal_rec.object_version_number := NULL;
    END IF;

    IF (l_pal_rec.version_number = okl_api.g_miss_char) THEN
      l_pal_rec.version_number := NULL;
    END IF;

    IF (l_pal_rec.adj_mat_id = okl_api.g_miss_num) THEN
      l_pal_rec.adj_mat_id := NULL;
    END IF;

    IF (l_pal_rec.sts_code = okl_api.g_miss_char) THEN
      l_pal_rec.sts_code := NULL;
    END IF;

    IF (l_pal_rec.effective_from_date = okl_api.g_miss_date) THEN
      l_pal_rec.effective_from_date := NULL;
    END IF;

    IF (l_pal_rec.effective_to_date = okl_api.g_miss_date) THEN
      l_pal_rec.effective_to_date := NULL;
    END IF;

    IF (l_pal_rec.attribute_category = okl_api.g_miss_char) THEN
      l_pal_rec.attribute_category := NULL;
    END IF;

    IF (l_pal_rec.attribute1 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute1 := NULL;
    END IF;

    IF (l_pal_rec.attribute2 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute2 := NULL;
    END IF;

    IF (l_pal_rec.attribute3 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute3 := NULL;
    END IF;

    IF (l_pal_rec.attribute4 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute4 := NULL;
    END IF;

    IF (l_pal_rec.attribute5 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute5 := NULL;
    END IF;

    IF (l_pal_rec.attribute6 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute6 := NULL;
    END IF;

    IF (l_pal_rec.attribute7 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute7 := NULL;
    END IF;

    IF (l_pal_rec.attribute8 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute8 := NULL;
    END IF;

    IF (l_pal_rec.attribute9 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute9 := NULL;
    END IF;

    IF (l_pal_rec.attribute10 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute10 := NULL;
    END IF;

    IF (l_pal_rec.attribute11 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute11 := NULL;
    END IF;

    IF (l_pal_rec.attribute12 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute12 := NULL;
    END IF;

    IF (l_pal_rec.attribute13 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute13 := NULL;
    END IF;

    IF (l_pal_rec.attribute14 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute14 := NULL;
    END IF;

    IF (l_pal_rec.attribute15 = okl_api.g_miss_char) THEN
      l_pal_rec.attribute15 := NULL;
    END IF;

    IF (l_pal_rec.created_by = okl_api.g_miss_num) THEN
      l_pal_rec.created_by := NULL;
    END IF;

    IF (l_pal_rec.creation_date = okl_api.g_miss_date) THEN
      l_pal_rec.creation_date := NULL;
    END IF;

    IF (l_pal_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_pal_rec.last_updated_by := NULL;
    END IF;

    IF (l_pal_rec.last_update_date = okl_api.g_miss_date) THEN
      l_pal_rec.last_update_date := NULL;
    END IF;

    IF (l_pal_rec.last_update_login = okl_api.g_miss_num) THEN
      l_pal_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pal_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN NUMBER IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_adj_mat_version_id(p_adj_mat_version_id IN NUMBER) RETURN VARCHAR2 IS

    -- initialize the return status

    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- Version Id is a required field

    IF (p_adj_mat_version_id IS NULL OR p_adj_mat_version_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ADJ_MAT_VERSION_ID');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no proccessing required. Validation can continue with the next column

        RETURN x_return_status;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RETURN x_return_status;
  END validate_adj_mat_version_id;

  FUNCTION validate_version_number(p_version_number IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- Version Number is a required field

    IF (p_version_number IS NULL OR p_version_number = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'VERSION_NUMBER');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no proccessing required. Validation can continue with the next column

        RETURN x_return_status;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RETURN x_return_status;
  END validate_version_number;

  -- validation of Adjusment Matrix Id

  FUNCTION validate_adj_mat_id(p_adj_mat_id IN NUMBER) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- ADJ_MAT_ID is a required field

    IF (p_adj_mat_id IS NULL OR p_adj_mat_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ADJ_MAT_ID');

      -- notify caller of an error

      l_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;
    RETURN(l_return_status);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no proccessing required. Validation can continue with the next column

        RETURN okl_api.g_ret_sts_error;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        l_return_status := okl_api.g_ret_sts_unexp_error;
        RETURN(l_return_status);
  END validate_adj_mat_id;

  -- validation of the status code

  FUNCTION validate_sts_code(p_sts_code IN VARCHAR2) RETURN VARCHAR2 IS

    --initialize the Return Status

    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- Column is mandatory

    IF (p_sts_code IS NULL OR p_sts_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'sts_code');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;
      RAISE g_exception_halt_validation;
    END IF;

    -- Lookup Code Validation

    x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_PRC_STATUS'
                                                 ,p_lookup_code =>              p_sts_code);

    IF (x_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'sts_code');  -- notify caller of an error
      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_unexp_error;
      RAISE g_exception_halt_validation;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        RETURN x_return_status;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RETURN x_return_status;
  END validate_sts_code;

  -- validation of the effective from

  FUNCTION validate_effective_from_date(p_effective_from_date IN DATE) RETURN VARCHAR2 IS

    -- initialize the return status

    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_effective_from_date IS NULL OR p_effective_from_date = okl_api.g_miss_date) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'EFFECTIVE_FROM_DATE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;
      RAISE g_exception_halt_validation;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        RETURN x_return_status;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RETURN x_return_status;
  END validate_effective_from_date;

  FUNCTION validate_attributes(p_pal_rec IN okl_pal_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- validate the adjustment matrix version id

    l_return_status := validate_adj_mat_version_id(p_pal_rec.adj_mat_version_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the adjustment matrix id

    l_return_status := validate_adj_mat_id(p_pal_rec.adj_mat_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the status of the header

    l_return_status := validate_sts_code(p_pal_rec.sts_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the effective from date

    l_return_status := validate_effective_from_date(p_pal_rec.effective_from_date);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    RETURN(x_return_status);
  END validate_attributes;

  FUNCTION validate_record(p_pal_rec IN okl_pal_rec) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_pal_rec.effective_to_date IS NOT NULL) THEN
      IF (p_pal_rec.effective_from_date > p_pal_rec.effective_to_date) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             'OKL_INVALID_EFFECTIVE_TO');
        x_return_status := okl_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;
      END IF;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN
        RETURN x_return_status;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_error;
        RETURN(x_return_status);
  END validate_record;

  -----------------
  -- lock_row (REC)
  -----------------

  PROCEDURE lock_row(p_api_version   IN            NUMBER
                    ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_def_pal_rec   IN            okl_pal_rec) IS
    l_api_name           CONSTANT VARCHAR2(61) := g_pkg_name || '.' || 'lock_row (REC)';
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_def_pal_rec IN okl_pal_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_adj_mat_versions
      WHERE         adj_mat_version_id = p_def_pal_rec.adj_mat_version_id
                AND object_version_number = p_def_pal_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_def_pal_rec IN okl_pal_rec) IS
      SELECT object_version_number
      FROM   okl_fe_adj_mat_versions
      WHERE  adj_mat_version_id = p_def_pal_rec.adj_mat_version_id;
    l_return_status              VARCHAR2(1)                                         := okl_api.g_ret_sts_success;
    l_object_version_number      okl_fe_item_residual_all.object_version_number%TYPE;
    lc_object_version_number     okl_fe_item_residual_all.object_version_number%TYPE;
    l_row_notfound               BOOLEAN                                             := false;
    lc_row_notfound              BOOLEAN                                             := false;

  BEGIN

    BEGIN
      OPEN lock_csr(p_def_pal_rec);
      FETCH lock_csr INTO l_object_version_number ;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
      EXCEPTION
        WHEN e_resource_busy THEN

          IF (lock_csr%ISOPEN) THEN
            CLOSE lock_csr;
          END IF;
          okl_api.set_message(g_fnd_app
                             ,g_form_unable_to_reserve_rec);
          RAISE app_exceptions.record_lock_exception;
    END;

    IF (l_row_notfound) THEN
      OPEN lchk_csr(p_def_pal_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_def_pal_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_def_pal_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okl_api.set_message(g_app_name
                         ,g_record_logically_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             g_sqlcode_token
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             g_sqlerrm_token
                           ,p_token3_value =>             sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  -----------------
  -- lock_row (TBL)
  -----------------

  PROCEDURE lock_row(p_api_version   IN            NUMBER
                    ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,okl_pal_tbl     IN            okl_pal_tbl) IS
    l_api_name           CONSTANT VARCHAR2(61)   := g_pkg_name || '.' || 'lock_row (TBL)';
    l_return_status               VARCHAR2(1)    := g_ret_sts_success;
    i                             BINARY_INTEGER;

  BEGIN

    IF (okl_pal_tbl.COUNT > 0) THEN
      i := okl_pal_tbl.FIRST;

      LOOP
        IF okl_pal_tbl.EXISTS(i) THEN
          lock_row(p_api_version   =>            g_api_version
                  ,p_init_msg_list =>            g_false
                  ,x_return_status =>            l_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_def_pal_rec   =>            okl_pal_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = okl_pal_tbl.LAST);
          i := okl_pal_tbl.next(i);
        END IF;
      END LOOP;

    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_db_error
                           ,p_token1       =>             g_prog_name_token
                           ,p_token1_value =>             l_api_name
                           ,p_token2       =>             g_sqlcode_token
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             g_sqlerrm_token
                           ,p_token3_value =>             sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  --------------------------------------------------------------------------------
  -- Procedure insert_row
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_rec       IN            okl_pal_rec
                      ,x_pal_rec          OUT NOCOPY okl_pal_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pal_rec                     okl_pal_rec;
    lx_pal_rec                    okl_pal_rec;
    l_def_pal_rec                 okl_pal_rec;

    FUNCTION fill_who_columns(p_pal_rec IN okl_pal_rec) RETURN okl_pal_rec IS
      l_pal_rec                    okl_pal_rec := p_pal_rec;

    BEGIN
      l_pal_rec.creation_date := SYSDATE;
      l_pal_rec.created_by := fnd_global.user_id;
      l_pal_rec.last_update_date := SYSDATE;
      l_pal_rec.last_updated_by := fnd_global.user_id;
      l_pal_rec.last_update_login := fnd_global.login_id;
      RETURN(l_pal_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_pal_rec IN            okl_pal_rec
                           ,x_pal_rec    OUT NOCOPY okl_pal_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pal_rec := p_pal_rec;
      x_pal_rec.object_version_number := 1;
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
    l_pal_rec := null_out_defaults(p_pal_rec);

    -- Set Primary key value

    l_pal_rec.adj_mat_version_id := get_seq_id;

    --Setting Item Attributes

    l_return_status := set_attributes(l_pal_rec
                                     ,l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pal_rec := fill_who_columns(l_def_pal_rec);
    l_return_status := validate_attributes(l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    INSERT INTO okl_fe_adj_mat_versions
               (adj_mat_version_id
               ,object_version_number
               ,version_number
               ,adj_mat_id
               ,sts_code
               ,effective_from_date
               ,effective_to_date
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
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login)
    VALUES     (l_def_pal_rec.adj_mat_version_id
               ,l_def_pal_rec.object_version_number
               ,l_def_pal_rec.version_number
               ,l_def_pal_rec.adj_mat_id
               ,l_def_pal_rec.sts_code
               ,l_def_pal_rec.effective_from_date
               ,l_def_pal_rec.effective_to_date
               ,l_def_pal_rec.attribute_category
               ,l_def_pal_rec.attribute1
               ,l_def_pal_rec.attribute2
               ,l_def_pal_rec.attribute3
               ,l_def_pal_rec.attribute4
               ,l_def_pal_rec.attribute5
               ,l_def_pal_rec.attribute6
               ,l_def_pal_rec.attribute7
               ,l_def_pal_rec.attribute8
               ,l_def_pal_rec.attribute9
               ,l_def_pal_rec.attribute10
               ,l_def_pal_rec.attribute11
               ,l_def_pal_rec.attribute12
               ,l_def_pal_rec.attribute13
               ,l_def_pal_rec.attribute14
               ,l_def_pal_rec.attribute15
               ,l_def_pal_rec.created_by
               ,l_def_pal_rec.creation_date
               ,l_def_pal_rec.last_updated_by
               ,l_def_pal_rec.last_update_date
               ,l_def_pal_rec.last_update_login);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Set OUT Values

    x_pal_rec := l_def_pal_rec;
    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
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

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_tbl       IN            okl_pal_tbl
                      ,x_pal_tbl          OUT NOCOPY okl_pal_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'insert_row_tbl';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pal_tbl.COUNT > 0) THEN
      i := p_pal_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pal_rec       =>            p_pal_tbl(i)
                  ,x_pal_rec       =>            x_pal_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pal_tbl.LAST);
        i := p_pal_tbl.next(i);
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
  --------------------------------------------------------------------------------
  -- Procedure update_row
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_rec       IN            okl_pal_rec
                      ,x_pal_rec          OUT NOCOPY okl_pal_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pal_rec                     okl_pal_rec  := p_pal_rec;
    l_def_pal_rec                 okl_pal_rec;
    lx_pal_rec                    okl_pal_rec;

    FUNCTION fill_who_columns(p_pal_rec IN okl_pal_rec) RETURN okl_pal_rec IS
      l_pal_rec                    okl_pal_rec := p_pal_rec;

    BEGIN
      l_pal_rec.last_update_date := SYSDATE;
      l_pal_rec.last_updated_by := fnd_global.user_id;
      l_pal_rec.last_update_login := fnd_global.login_id;
      RETURN(l_pal_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_pal_rec IN            okl_pal_rec
                                ,x_pal_rec    OUT NOCOPY okl_pal_rec) RETURN VARCHAR2 IS
      l_pal_rec                    okl_pal_rec;
      l_row_notfound               BOOLEAN     := true;
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pal_rec := p_pal_rec;

      --Get current database values

      l_pal_rec := get_rec(p_pal_rec
                          ,l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_pal_rec.adj_mat_version_id IS NULL) THEN
        x_pal_rec.adj_mat_version_id := l_pal_rec.adj_mat_version_id;
      END IF;

      IF (x_pal_rec.object_version_number IS NULL) THEN
        x_pal_rec.object_version_number := l_pal_rec.object_version_number;
      END IF;

      IF (x_pal_rec.version_number IS NULL) THEN
        x_pal_rec.version_number := l_pal_rec.version_number;
      END IF;

      IF (x_pal_rec.adj_mat_id IS NULL) THEN
        x_pal_rec.adj_mat_id := l_pal_rec.adj_mat_id;
      END IF;

      IF (x_pal_rec.sts_code IS NULL) THEN
        x_pal_rec.sts_code := l_pal_rec.sts_code;
      END IF;

      IF (x_pal_rec.effective_from_date IS NULL) THEN
        x_pal_rec.effective_from_date := l_pal_rec.effective_from_date;
      END IF;

      IF (x_pal_rec.effective_to_date IS NULL) THEN
        x_pal_rec.effective_to_date := l_pal_rec.effective_to_date;
      END IF;

      IF (x_pal_rec.attribute_category IS NULL) THEN
        x_pal_rec.attribute_category := l_pal_rec.attribute_category;
      END IF;

      IF (x_pal_rec.attribute1 IS NULL) THEN
        x_pal_rec.attribute1 := l_pal_rec.attribute1;
      END IF;

      IF (x_pal_rec.attribute2 IS NULL) THEN
        x_pal_rec.attribute2 := l_pal_rec.attribute2;
      END IF;

      IF (x_pal_rec.attribute3 IS NULL) THEN
        x_pal_rec.attribute3 := l_pal_rec.attribute3;
      END IF;

      IF (x_pal_rec.attribute4 IS NULL) THEN
        x_pal_rec.attribute4 := l_pal_rec.attribute4;
      END IF;

      IF (x_pal_rec.attribute5 IS NULL) THEN
        x_pal_rec.attribute5 := l_pal_rec.attribute5;
      END IF;

      IF (x_pal_rec.attribute6 IS NULL) THEN
        x_pal_rec.attribute6 := l_pal_rec.attribute6;
      END IF;

      IF (x_pal_rec.attribute7 IS NULL) THEN
        x_pal_rec.attribute7 := l_pal_rec.attribute7;
      END IF;

      IF (x_pal_rec.attribute8 IS NULL) THEN
        x_pal_rec.attribute8 := l_pal_rec.attribute8;
      END IF;

      IF (x_pal_rec.attribute9 IS NULL) THEN
        x_pal_rec.attribute9 := l_pal_rec.attribute9;
      END IF;

      IF (x_pal_rec.attribute10 IS NULL) THEN
        x_pal_rec.attribute10 := l_pal_rec.attribute10;
      END IF;

      IF (x_pal_rec.attribute11 IS NULL) THEN
        x_pal_rec.attribute11 := l_pal_rec.attribute11;
      END IF;

      IF (x_pal_rec.attribute12 IS NULL) THEN
        x_pal_rec.attribute12 := l_pal_rec.attribute12;
      END IF;

      IF (x_pal_rec.attribute13 IS NULL) THEN
        x_pal_rec.attribute13 := l_pal_rec.attribute13;
      END IF;

      IF (x_pal_rec.attribute14 IS NULL) THEN
        x_pal_rec.attribute14 := l_pal_rec.attribute14;
      END IF;

      IF (x_pal_rec.attribute15 IS NULL) THEN
        x_pal_rec.attribute15 := l_pal_rec.attribute15;
      END IF;

      IF (x_pal_rec.created_by IS NULL) THEN
        x_pal_rec.created_by := l_pal_rec.created_by;
      END IF;

      IF (x_pal_rec.creation_date IS NULL) THEN
        x_pal_rec.creation_date := l_pal_rec.creation_date;
      END IF;

      IF (x_pal_rec.last_updated_by IS NULL) THEN
        x_pal_rec.last_updated_by := l_pal_rec.last_updated_by;
      END IF;

      IF (x_pal_rec.last_update_date IS NULL) THEN
        x_pal_rec.last_update_date := l_pal_rec.last_update_date;
      END IF;

      IF (x_pal_rec.last_update_login IS NULL) THEN
        x_pal_rec.last_update_login := l_pal_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_pal_rec IN            okl_pal_rec
                           ,x_pal_rec    OUT NOCOPY okl_pal_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pal_rec := p_pal_rec;
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

    l_return_status := set_attributes(l_pal_rec
                                     ,lx_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := populate_new_record(lx_pal_rec
                                          ,l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pal_rec := null_out_defaults(l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pal_rec := fill_who_columns(l_def_pal_rec);
    l_return_status := validate_attributes(l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_pal_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Lock the row before updating

    lock_row(p_api_version   =>            g_api_version
            ,p_init_msg_list =>            g_false
            ,x_return_status =>            l_return_status
            ,x_msg_count     =>            x_msg_count
            ,x_msg_data      =>            x_msg_data
            ,p_def_pal_rec   =>            l_def_pal_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_adj_mat_versions
    SET    adj_mat_version_id = l_def_pal_rec.adj_mat_version_id
          ,object_version_number = l_def_pal_rec.object_version_number + 1
          ,version_number = l_def_pal_rec.version_number
          ,adj_mat_id = l_def_pal_rec.adj_mat_id
          ,sts_code = l_def_pal_rec.sts_code
          ,effective_from_date = l_def_pal_rec.effective_from_date
          ,effective_to_date = l_def_pal_rec.effective_to_date
          ,attribute_category = l_def_pal_rec.attribute_category
          ,attribute1 = l_def_pal_rec.attribute1
          ,attribute2 = l_def_pal_rec.attribute2
          ,attribute3 = l_def_pal_rec.attribute3
          ,attribute4 = l_def_pal_rec.attribute4
          ,attribute5 = l_def_pal_rec.attribute5
          ,attribute6 = l_def_pal_rec.attribute6
          ,attribute7 = l_def_pal_rec.attribute7
          ,attribute8 = l_def_pal_rec.attribute8
          ,attribute9 = l_def_pal_rec.attribute9
          ,attribute10 = l_def_pal_rec.attribute10
          ,attribute11 = l_def_pal_rec.attribute11
          ,attribute12 = l_def_pal_rec.attribute12
          ,attribute13 = l_def_pal_rec.attribute13
          ,attribute14 = l_def_pal_rec.attribute14
          ,attribute15 = l_def_pal_rec.attribute15
          ,created_by = l_def_pal_rec.created_by
          ,creation_date = l_def_pal_rec.creation_date
          ,last_updated_by = l_def_pal_rec.last_updated_by
          ,last_update_date = l_def_pal_rec.last_update_date
          ,last_update_login = l_def_pal_rec.last_update_login
    WHERE  adj_mat_version_id = l_def_pal_rec.adj_mat_version_id;

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Set OUT Values

    x_pal_rec := l_def_pal_rec;
    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
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

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_tbl       IN            okl_pal_tbl
                      ,x_pal_tbl          OUT NOCOPY okl_pal_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'update_row_tbl';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pal_tbl.COUNT > 0) THEN
      i := p_pal_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pal_rec       =>            p_pal_tbl(i)
                  ,x_pal_rec       =>            x_pal_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pal_tbl.LAST);
        i := p_pal_tbl.next(i);
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

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_rec       IN            okl_pal_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pal_rec                     okl_pal_rec  := p_pal_rec;
    l_row_notfound                BOOLEAN      := true;

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

    DELETE FROM okl_fe_adj_mat_versions
    WHERE       adj_mat_version_id = l_pal_rec.adj_mat_version_id;

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

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pal_tbl       IN            okl_pal_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'delete_row_tbl';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pal_tbl.COUNT > 0) THEN
      i := p_pal_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pal_rec       =>            p_pal_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pal_tbl.LAST);
        i := p_pal_tbl.next(i);
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

END okl_pal_pvt;

/
