--------------------------------------------------------
--  DDL for Package Body OKL_PAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAM_PVT" AS
/* $Header: OKLSPAMB.pls 120.5 2006/07/13 12:59:32 adagur noship $ */

  -- The lock_row and the validate_row procedures are not available.

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

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------

  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_FE_ADJ_MAT_ALL_TL t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_FE_ADJ_MAT_ALL_B b
                           WHERE  b.adj_mat_id = t.adj_mat_id);

    UPDATE OKL_FE_ADJ_MAT_ALL_TL t
    SET(adj_mat_desc) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.adj_mat_desc
                              FROM   OKL_FE_ADJ_MAT_ALL_TL b
                              WHERE  b.adj_mat_id = t.adj_mat_id
                                 AND b.language = t.source_lang)
    WHERE  (t.adj_mat_id, t.language) IN(SELECT subt.adj_mat_id ,subt.language
           FROM   OKL_FE_ADJ_MAT_ALL_TL subb ,OKL_FE_ADJ_MAT_ALL_TL subt
           WHERE  subb.adj_mat_id = subt.adj_mat_id AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.adj_mat_desc <> subt.adj_mat_desc OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.adj_mat_desc IS NULL AND subt.adj_mat_desc IS NOT NULL)));

    INSERT INTO OKL_FE_ADJ_MAT_ALL_TL
               (adj_mat_id
               ,language
               ,source_lang
               ,sfwt_flag
               ,adj_mat_desc)
                SELECT b.adj_mat_id
                      ,l.language_code
                      ,b.source_lang
                      ,b.sfwt_flag
                      ,b.adj_mat_desc
                FROM   OKL_FE_ADJ_MAT_ALL_TL b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   OKL_FE_ADJ_MAT_ALL_TL t
                                      WHERE  t.adj_mat_id = b.adj_mat_id AND t.language = l.language_code);

  END add_language;


  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_ADJ_MAT_ALL_B
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_pamb_rec      IN            okl_pamb_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_pamb_rec IS

    CURSOR pamb_pk_csr(p_id IN NUMBER) IS
      SELECT adj_mat_id
            ,adj_mat_name
            ,object_version_number
            ,org_id
            ,currency_code
            ,adj_mat_type_code
            ,orig_adj_mat_id
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
      FROM   okl_fe_adj_mat_all_b
      WHERE  okl_fe_adj_mat_all_b.adj_mat_id = p_id;
    l_pamb_pk                    pamb_pk_csr%ROWTYPE;
    l_pamb_rec                   okl_pamb_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN pamb_pk_csr(p_pamb_rec.adj_mat_id);
    FETCH pamb_pk_csr INTO l_pamb_rec.adj_mat_id
                          ,l_pamb_rec.adj_mat_name
                          ,l_pamb_rec.object_version_number
                          ,l_pamb_rec.org_id
                          ,l_pamb_rec.currency_code
                          ,l_pamb_rec.adj_mat_type_code
                          ,l_pamb_rec.orig_adj_mat_id
                          ,l_pamb_rec.sts_code
                          ,l_pamb_rec.effective_from_date
                          ,l_pamb_rec.effective_to_date
                          ,l_pamb_rec.attribute_category
                          ,l_pamb_rec.attribute1
                          ,l_pamb_rec.attribute2
                          ,l_pamb_rec.attribute3
                          ,l_pamb_rec.attribute4
                          ,l_pamb_rec.attribute5
                          ,l_pamb_rec.attribute6
                          ,l_pamb_rec.attribute7
                          ,l_pamb_rec.attribute8
                          ,l_pamb_rec.attribute9
                          ,l_pamb_rec.attribute10
                          ,l_pamb_rec.attribute11
                          ,l_pamb_rec.attribute12
                          ,l_pamb_rec.attribute13
                          ,l_pamb_rec.attribute14
                          ,l_pamb_rec.attribute15
                          ,l_pamb_rec.created_by
                          ,l_pamb_rec.creation_date
                          ,l_pamb_rec.last_updated_by
                          ,l_pamb_rec.last_update_date
                          ,l_pamb_rec.last_update_login ;
    x_no_data_found := pamb_pk_csr%NOTFOUND;
    CLOSE pamb_pk_csr;
    RETURN(l_pamb_rec);
  END get_rec;

  FUNCTION get_rec(p_pamb_rec IN okl_pamb_rec) RETURN okl_pamb_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_pamb_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec forOKL_FE_ADJ_MAT_ALL_TL
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_pamtl_rec     IN            okl_pamtl_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_pamtl_rec IS

    CURSOR pamtl_pk_csr(p_id       IN NUMBER
                       ,p_language IN VARCHAR2) IS
      SELECT adj_mat_id
            ,adj_mat_desc
            ,language
            ,source_lang
            ,sfwt_flag
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_adj_mat_all_tl
      WHERE  okl_fe_adj_mat_all_tl.adj_mat_id = p_id
         AND okl_fe_adj_mat_all_tl.language = p_language;
    l_pamtl_pk                   pamtl_pk_csr%ROWTYPE;
    l_pamtl_rec                  okl_pamtl_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN pamtl_pk_csr(p_pamtl_rec.adj_mat_id
                     ,p_pamtl_rec.language);
    FETCH pamtl_pk_csr INTO l_pamtl_rec.adj_mat_id
                           ,l_pamtl_rec.adj_mat_desc
                           ,l_pamtl_rec.language
                           ,l_pamtl_rec.source_lang
                           ,l_pamtl_rec.sfwt_flag
                           ,l_pamtl_rec.created_by
                           ,l_pamtl_rec.creation_date
                           ,l_pamtl_rec.last_updated_by
                           ,l_pamtl_rec.last_update_date
                           ,l_pamtl_rec.last_update_login ;
    x_no_data_found := pamtl_pk_csr%NOTFOUND;
    CLOSE pamtl_pk_csr;
    RETURN(l_pamtl_rec);
  END get_rec;

  FUNCTION get_rec(p_pamtl_rec IN okl_pamtl_rec) RETURN okl_pamtl_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_pamtl_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_ADJ_MAT_V
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_pamv_rec      IN            okl_pamv_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_pamv_rec IS

    CURSOR pamv_pk_csr(p_id IN NUMBER) IS
      SELECT adj_mat_id
            ,object_version_number
            ,org_id
            ,currency_code
            ,adj_mat_type_code
            ,orig_adj_mat_id
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
            ,adj_mat_name
            ,adj_mat_desc
      FROM   okl_fe_adj_mat_v
      WHERE  okl_fe_adj_mat_v.adj_mat_id = p_id;
    l_pamv_pk                    pamv_pk_csr%ROWTYPE;
    l_pamv_rec                   okl_pamv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN pamv_pk_csr(p_pamv_rec.adj_mat_id);
    FETCH pamv_pk_csr INTO l_pamv_rec.adj_mat_id
                          ,l_pamv_rec.object_version_number
                          ,l_pamv_rec.org_id
                          ,l_pamv_rec.currency_code
                          ,l_pamv_rec.adj_mat_type_code
                          ,l_pamv_rec.orig_adj_mat_id
                          ,l_pamv_rec.sts_code
                          ,l_pamv_rec.effective_from_date
                          ,l_pamv_rec.effective_to_date
                          ,l_pamv_rec.attribute_category
                          ,l_pamv_rec.attribute1
                          ,l_pamv_rec.attribute2
                          ,l_pamv_rec.attribute3
                          ,l_pamv_rec.attribute4
                          ,l_pamv_rec.attribute5
                          ,l_pamv_rec.attribute6
                          ,l_pamv_rec.attribute7
                          ,l_pamv_rec.attribute8
                          ,l_pamv_rec.attribute9
                          ,l_pamv_rec.attribute10
                          ,l_pamv_rec.attribute11
                          ,l_pamv_rec.attribute12
                          ,l_pamv_rec.attribute13
                          ,l_pamv_rec.attribute14
                          ,l_pamv_rec.attribute15
                          ,l_pamv_rec.created_by
                          ,l_pamv_rec.creation_date
                          ,l_pamv_rec.last_updated_by
                          ,l_pamv_rec.last_update_date
                          ,l_pamv_rec.last_update_login
                          ,l_pamv_rec.adj_mat_name
                          ,l_pamv_rec.adj_mat_desc ;
    x_no_data_found := pamv_pk_csr%NOTFOUND;
    CLOSE pamv_pk_csr;
    RETURN(l_pamv_rec);
  END get_rec;

  FUNCTION get_rec(p_pamv_rec IN okl_pamv_rec) RETURN okl_pamv_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_pamv_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure migrate
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from IN            okl_pamv_rec
                   ,p_to   IN OUT NOCOPY okl_pamb_rec) IS

  BEGIN
    p_to.adj_mat_id := p_from.adj_mat_id;
    p_to.adj_mat_name := p_from.adj_mat_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.adj_mat_type_code := p_from.adj_mat_type_code;
    p_to.orig_adj_mat_id := p_from.orig_adj_mat_id;
    p_to.sts_code := p_from.sts_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate(p_from IN            okl_pamb_rec
                   ,p_to   IN OUT NOCOPY okl_pamv_rec) IS

  BEGIN
    p_to.adj_mat_id := p_from.adj_mat_id;
    p_to.adj_mat_name := p_from.adj_mat_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.adj_mat_type_code := p_from.adj_mat_type_code;
    p_to.orig_adj_mat_id := p_from.orig_adj_mat_id;
    p_to.sts_code := p_from.sts_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate(p_from IN            okl_pamv_rec
                   ,p_to   IN OUT NOCOPY okl_pamtl_rec) IS

  BEGIN
    p_to.adj_mat_id := p_from.adj_mat_id;
    p_to.adj_mat_desc := p_from.adj_mat_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate(p_from IN            okl_pamtl_rec
                   ,p_to   IN OUT NOCOPY okl_pamv_rec) IS

  BEGIN
    p_to.adj_mat_id := p_from.adj_mat_id;
    p_to.adj_mat_desc := p_from.adj_mat_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  FUNCTION null_out_defaults(p_pamv_rec IN okl_pamv_rec) RETURN okl_pamv_rec IS
    l_pamv_rec                   okl_pamv_rec := p_pamv_rec;

  BEGIN

    IF (l_pamv_rec.adj_mat_id = okl_api.g_miss_num) THEN
      l_pamv_rec.adj_mat_id := NULL;
    END IF;

    IF (l_pamv_rec.adj_mat_name = okl_api.g_miss_char) THEN
      l_pamv_rec.adj_mat_name := NULL;
    END IF;

    IF (l_pamv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_pamv_rec.object_version_number := NULL;
    END IF;

    IF (l_pamv_rec.org_id = okl_api.g_miss_num) THEN
      l_pamv_rec.org_id := NULL;
    END IF;

    IF (l_pamv_rec.currency_code = okl_api.g_miss_char) THEN
      l_pamv_rec.currency_code := NULL;
    END IF;

    IF (l_pamv_rec.adj_mat_type_code = okl_api.g_miss_char) THEN
      l_pamv_rec.adj_mat_type_code := NULL;
    END IF;

    IF (l_pamv_rec.orig_adj_mat_id = okl_api.g_miss_num) THEN
      l_pamv_rec.orig_adj_mat_id := NULL;
    END IF;

    IF (l_pamv_rec.sts_code = okl_api.g_miss_char) THEN
      l_pamv_rec.sts_code := NULL;
    END IF;

    IF (l_pamv_rec.effective_from_date = okl_api.g_miss_date) THEN
      l_pamv_rec.effective_from_date := NULL;
    END IF;

    IF (l_pamv_rec.effective_to_date = okl_api.g_miss_date) THEN
      l_pamv_rec.effective_to_date := NULL;
    END IF;

    IF (l_pamv_rec.attribute_category = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute_category := NULL;
    END IF;

    IF (l_pamv_rec.attribute1 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute1 := NULL;
    END IF;

    IF (l_pamv_rec.attribute2 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute2 := NULL;
    END IF;

    IF (l_pamv_rec.attribute3 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute3 := NULL;
    END IF;

    IF (l_pamv_rec.attribute4 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute4 := NULL;
    END IF;

    IF (l_pamv_rec.attribute5 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute5 := NULL;
    END IF;

    IF (l_pamv_rec.attribute6 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute6 := NULL;
    END IF;

    IF (l_pamv_rec.attribute7 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute7 := NULL;
    END IF;

    IF (l_pamv_rec.attribute8 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute8 := NULL;
    END IF;

    IF (l_pamv_rec.attribute9 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute9 := NULL;
    END IF;

    IF (l_pamv_rec.attribute10 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute10 := NULL;
    END IF;

    IF (l_pamv_rec.attribute11 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute11 := NULL;
    END IF;

    IF (l_pamv_rec.attribute12 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute12 := NULL;
    END IF;

    IF (l_pamv_rec.attribute13 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute13 := NULL;
    END IF;

    IF (l_pamv_rec.attribute14 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute14 := NULL;
    END IF;

    IF (l_pamv_rec.attribute15 = okl_api.g_miss_char) THEN
      l_pamv_rec.attribute15 := NULL;
    END IF;

    IF (l_pamv_rec.created_by = okl_api.g_miss_num) THEN
      l_pamv_rec.created_by := NULL;
    END IF;

    IF (l_pamv_rec.creation_date = okl_api.g_miss_date) THEN
      l_pamv_rec.creation_date := NULL;
    END IF;

    IF (l_pamv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_pamv_rec.last_updated_by := NULL;
    END IF;

    IF (l_pamv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_pamv_rec.last_update_date := NULL;
    END IF;

    IF (l_pamv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_pamv_rec.last_update_login := NULL;
    END IF;

    IF (l_pamv_rec.adj_mat_name = okl_api.g_miss_char) THEN
      l_pamv_rec.adj_mat_name := NULL;
    END IF;

    IF (l_pamv_rec.adj_mat_desc = okl_api.g_miss_char) THEN
      l_pamv_rec.adj_mat_desc := NULL;
    END IF;
    RETURN(l_pamv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- lock_row_b --
  ---------------------------------------

  PROCEDURE lock_row(p_init_msg_list IN            VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_pamb_rec      IN            okl_pamb_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_pamb_rec IN okl_pamb_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_adj_mat_all_b
      WHERE         adj_mat_id = p_pamb_rec.adj_mat_id
                AND object_version_number = p_pamb_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_pamb_rec IN okl_pamb_rec) IS
      SELECT object_version_number
      FROM   okl_fe_adj_mat_all_b
      WHERE  adj_mat_id = p_pamb_rec.adj_mat_id;
    l_api_version            CONSTANT NUMBER                                           := 1;
    l_api_name               CONSTANT VARCHAR2(30)                                     := 'B_lock_row';
    l_return_status                   VARCHAR2(1)                                      := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_resi_cat_all_b.object_version_number%TYPE;
    lc_object_version_number          okl_fe_resi_cat_all_b.object_version_number%TYPE;
    l_row_notfound                    BOOLEAN                                          := false;
    lc_row_notfound                   BOOLEAN                                          := false;

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
      OPEN lock_csr(p_pamb_rec);
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
      OPEN lchk_csr(p_pamb_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_pamb_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_pamb_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okl_api.set_message(g_app_name
                         ,g_record_logically_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
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

  ----------------------------------------
  -- lock_row_tl --
  ----------------------------------------

  PROCEDURE lock_row(p_init_msg_list IN            VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_pamtl_rec     IN            okl_pamtl_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_pamtl_rec IN okl_pamtl_rec) IS
      SELECT     *
      FROM       okl_fe_adj_mat_all_tl
      WHERE      adj_mat_id = p_pamtl_rec.adj_mat_id
      FOR UPDATE NOWAIT;
    l_api_version        CONSTANT NUMBER           := 1;
    l_api_name           CONSTANT VARCHAR2(30)     := 'TL_lock_row';
    l_return_status               VARCHAR2(1)      := okl_api.g_ret_sts_success;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN          := false;
    lc_row_notfound               BOOLEAN          := false;

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
      OPEN lock_csr(p_pamtl_rec);
      FETCH lock_csr INTO l_lock_var ;
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
      okl_api.set_message(g_fnd_app
                         ,g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
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

  ---------------------------------------
  -- lock_row_v --
  ---------------------------------------

  PROCEDURE lock_row(p_api_version   IN            NUMBER
                    ,p_init_msg_list IN            VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_pamv_rec      IN            okl_pamv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'V_lock_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamb_rec                    okl_pamb_rec;
    l_pamtl_rec                   okl_pamtl_rec;

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

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------

    migrate(p_pamv_rec
           ,l_pamb_rec);
    migrate(p_pamv_rec
           ,l_pamtl_rec);

    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------

    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_pamb_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_pamtl_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
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

  --------------------------------------
  -- PL/SQL TBL lock_row_tbl --
  --------------------------------------

  PROCEDURE lock_row(p_api_version   IN            NUMBER
                    ,p_init_msg_list IN            VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_pamv_tbl      IN            okl_pamv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;

    -- Begin Post-Generation Change
    -- overall error status

    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

    -- End Post-Generation Change

    i                             NUMBER       := 0;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pamv_tbl.COUNT > 0) THEN
      i := p_pamv_tbl.FIRST;

      LOOP
        lock_row(p_api_version   =>            p_api_version
                ,p_init_msg_list =>            okl_api.g_false
                ,x_return_status =>            x_return_status
                ,x_msg_count     =>            x_msg_count
                ,x_msg_data      =>            x_msg_data
                ,p_pamv_rec      =>            p_pamv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_pamv_tbl.LAST);
        i := p_pamv_tbl.next(i);
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

  -- get the sequence id

  FUNCTION get_seq_id RETURN NUMBER IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

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

        NULL;
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

  -- Validation of the org Id

  FUNCTION validate_org_id(p_org_id IN NUMBER) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- data is required

    IF (p_org_id IS NULL) OR (p_org_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'org_id');
      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- check org id validity using the generic function okl_util.check_org_id()

    x_return_status := okl_util.check_org_id(TO_CHAR(p_org_id));

    IF (x_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'org_id');

      -- notify caller of an error

      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      RAISE g_exception_halt_validation;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        RETURN(x_return_status);
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
        RETURN(x_return_status);
  END validate_org_id;

  -- Validation of the currency code

  FUNCTION validate_currency_code(p_currency_code IN VARCHAR2) RETURN VARCHAR2 IS

    -- initialize the return status

    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- data is required

    IF (p_currency_code IS NULL) OR (p_currency_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'currency_code');

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- check from currency values using the generic okl_util.validate_currency_code

    x_return_status := okl_accounting_util.validate_currency_code(p_currency_code);

    IF (x_return_status <> okl_api.g_true) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'currency_code');

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN g_exception_halt_validation THEN
        x_return_status := okl_api.g_ret_sts_error;
        RETURN(x_return_status);
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
        RETURN(x_return_status);
  END validate_currency_code;

  FUNCTION validate_adj_mat_type_code(p_adj_mat_type_code IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_adj_mat_type_code IS NULL) OR (p_adj_mat_type_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ADJ_MAT_TYPE_CODE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- Lookup Code Validation

    x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_ADJ_MAT_TYPES'
                                                 ,p_lookup_code =>              p_adj_mat_type_code);

    IF (x_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ADJ_MAT_TYPE_CODE');  -- notify caller of an error
      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_unexp_error;
      RAISE g_exception_halt_validation;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        RETURN(x_return_status);
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
        RETURN(x_return_status);
  END validate_adj_mat_type_code;

  FUNCTION validate_orig_adj_mat_id(p_orig_adj_mat_id IN NUMBER) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    CURSOR adj_matrix_exists_csr IS
      SELECT 'x'
      FROM   okl_fe_adj_mat_all_b
      WHERE  adj_mat_id = p_orig_adj_mat_id;
    l_dummy_var                  VARCHAR2(1) := '?';

  BEGIN

    IF (p_orig_adj_mat_id IS NOT NULL AND p_orig_adj_mat_id <> okl_api.g_miss_num) THEN
      OPEN adj_matrix_exists_csr;
      FETCH adj_matrix_exists_csr INTO l_dummy_var ;
      CLOSE adj_matrix_exists_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'ORIG_ADJ_MAT_ID');

        -- notify caller of an error

        x_return_status := okl_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;
      END IF;
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

        -- verify that cursor was closed

        IF adj_matrix_exists_csr%ISOPEN THEN
          CLOSE adj_matrix_exists_csr;
        END IF;
        RETURN x_return_status;
  END validate_orig_adj_mat_id;

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

  FUNCTION validate_attributes(p_pamv_rec IN okl_pamv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- validate the adjustment matrix id

    l_return_status := validate_adj_mat_id(p_pamv_rec.adj_mat_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the org_id

    l_return_status := validate_org_id(p_pamv_rec.org_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the currency code

    l_return_status := validate_currency_code(p_pamv_rec.currency_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Adjustment matrix type

    l_return_status := validate_adj_mat_type_code(p_pamv_rec.adj_mat_type_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Adjusment matrix Id used for duplicate

    l_return_status := validate_orig_adj_mat_id(p_pamv_rec.orig_adj_mat_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the status of the header

    l_return_status := validate_sts_code(p_pamv_rec.sts_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the effective from date

    l_return_status := validate_effective_from_date(p_pamv_rec.effective_from_date);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    RETURN(x_return_status);
  END validate_attributes;

  FUNCTION validate_record(p_pamv_rec IN okl_pamv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_pamv_rec.effective_to_date IS NOT NULL) THEN
      IF (p_pamv_rec.effective_from_date > p_pamv_rec.effective_to_date) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             'OKL_INVALID_EFFECTIVE_TO');
        x_return_status := okl_api.g_ret_sts_error;
      END IF;
    END IF;
    RETURN x_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation THEN
        NULL;
        x_return_status := okl_api.g_ret_sts_error;
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

  --------------------------------------------------------------------------------
  -- Procedure insert_row_b
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamb_rec      IN            okl_pamb_rec
                      ,x_pamb_rec         OUT NOCOPY okl_pamb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pamb_rec                    okl_pamb_rec := p_pamb_rec;

    FUNCTION set_attributes(p_pamb_rec IN            okl_pamb_rec
                           ,x_pamb_rec    OUT NOCOPY okl_pamb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamb_rec := p_pamb_rec;
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

    l_return_status := set_attributes(p_pamb_rec
                                     ,l_pamb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    INSERT INTO okl_fe_adj_mat_all_b
               (adj_mat_id
               ,adj_mat_name
               ,object_version_number
               ,org_id
               ,currency_code
               ,adj_mat_type_code
               ,orig_adj_mat_id
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
    VALUES     (l_pamb_rec.adj_mat_id
               ,l_pamb_rec.adj_mat_name
               ,l_pamb_rec.object_version_number
               ,l_pamb_rec.org_id
               ,l_pamb_rec.currency_code
               ,l_pamb_rec.adj_mat_type_code
               ,l_pamb_rec.orig_adj_mat_id
               ,l_pamb_rec.sts_code
               ,l_pamb_rec.effective_from_date
               ,l_pamb_rec.effective_to_date
               ,l_pamb_rec.attribute_category
               ,l_pamb_rec.attribute1
               ,l_pamb_rec.attribute2
               ,l_pamb_rec.attribute3
               ,l_pamb_rec.attribute4
               ,l_pamb_rec.attribute5
               ,l_pamb_rec.attribute6
               ,l_pamb_rec.attribute7
               ,l_pamb_rec.attribute8
               ,l_pamb_rec.attribute9
               ,l_pamb_rec.attribute10
               ,l_pamb_rec.attribute11
               ,l_pamb_rec.attribute12
               ,l_pamb_rec.attribute13
               ,l_pamb_rec.attribute14
               ,l_pamb_rec.attribute15
               ,l_pamb_rec.created_by
               ,l_pamb_rec.creation_date
               ,l_pamb_rec.last_updated_by
               ,l_pamb_rec.last_update_date
               ,l_pamb_rec.last_update_login);

    --Set OUT Values

    x_pamb_rec := l_pamb_rec;
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
  -- Procedure insert_row_tl
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamtl_rec     IN            okl_pamtl_rec
                      ,x_pamtl_rec        OUT NOCOPY okl_pamtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamtl_rec                   okl_pamtl_rec := p_pamtl_rec;

    CURSOR get_languages IS
      SELECT *
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B');

    FUNCTION set_attributes(p_pamtl_rec IN            okl_pamtl_rec
                           ,x_pamtl_rec    OUT NOCOPY okl_pamtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamtl_rec := p_pamtl_rec;
      x_pamtl_rec.language := USERENV('LANG');
      x_pamtl_rec.source_lang := USERENV('LANG');
      x_pamtl_rec.sfwt_flag := 'N';
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

    l_return_status := set_attributes(p_pamtl_rec
                                     ,l_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    FOR l_lang_rec IN get_languages LOOP
      l_pamtl_rec.language := l_lang_rec.language_code;

      INSERT INTO okl_fe_adj_mat_all_tl
                 (adj_mat_id
                 ,adj_mat_desc
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (l_pamtl_rec.adj_mat_id
                 ,l_pamtl_rec.adj_mat_desc
                 ,l_pamtl_rec.language
                 ,l_pamtl_rec.source_lang
                 ,l_pamtl_rec.sfwt_flag
                 ,l_pamtl_rec.created_by
                 ,l_pamtl_rec.creation_date
                 ,l_pamtl_rec.last_updated_by
                 ,l_pamtl_rec.last_update_date
                 ,l_pamtl_rec.last_update_login);

    END LOOP;

    --Set OUT Values

    x_pamtl_rec := l_pamtl_rec;
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
  -- Procedure insert_row_v
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec
                      ,x_pamv_rec         OUT NOCOPY okl_pamv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamv_rec                    okl_pamv_rec;
    l_def_pamv_rec                okl_pamv_rec;
    l_pamb_rec                    okl_pamb_rec;
    lx_pamb_rec                   okl_pamb_rec;
    l_pamtl_rec                   okl_pamtl_rec;
    lx_pamtl_rec                  okl_pamtl_rec;

    FUNCTION fill_who_columns(p_pamv_rec IN okl_pamv_rec) RETURN okl_pamv_rec IS
      l_pamv_rec                   okl_pamv_rec := p_pamv_rec;

    BEGIN
      l_pamv_rec.creation_date := SYSDATE;
      l_pamv_rec.created_by := fnd_global.user_id;
      l_pamv_rec.last_update_date := SYSDATE;
      l_pamv_rec.last_updated_by := fnd_global.user_id;
      l_pamv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_pamv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_pamv_rec IN            okl_pamv_rec
                           ,x_pamv_rec    OUT NOCOPY okl_pamv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamv_rec := p_pamv_rec;
      x_pamv_rec.object_version_number := 1;
	x_pamv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
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
    l_pamv_rec := null_out_defaults(p_pamv_rec);

    -- Set Primary key value

    l_pamv_rec.adj_mat_id := get_seq_id;

    --Setting Item Attributes

    l_return_status := set_attributes(l_pamv_rec
                                     ,l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pamv_rec := fill_who_columns(l_def_pamv_rec);
    l_return_status := validate_attributes(l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_def_pamv_rec
           ,l_pamb_rec);
    migrate(l_def_pamv_rec
           ,l_pamtl_rec);
    insert_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamb_rec
              ,lx_pamb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_pamb_rec
           ,l_def_pamv_rec);
    insert_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamtl_rec
              ,lx_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_pamtl_rec
           ,l_def_pamv_rec);

    --Set OUT Values

    x_pamv_rec := l_def_pamv_rec;
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl
                      ,x_pamv_tbl         OUT NOCOPY okl_pamv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pamv_tbl.COUNT > 0) THEN
      i := p_pamv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pamv_rec      =>            p_pamv_tbl(i)
                  ,x_pamv_rec      =>            x_pamv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pamv_tbl.LAST);
        i := p_pamv_tbl.next(i);
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
  -- Procedure update_row_b
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamb_rec      IN            okl_pamb_rec
                      ,x_pamb_rec         OUT NOCOPY okl_pamb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pamb_rec                    okl_pamb_rec := p_pamb_rec;
    l_def_pamb_rec                okl_pamb_rec;
    l_row_notfound                BOOLEAN      := true;

    FUNCTION set_attributes(p_pamb_rec IN            okl_pamb_rec
                           ,x_pamb_rec    OUT NOCOPY okl_pamb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamb_rec := p_pamb_rec;
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

    l_return_status := set_attributes(p_pamb_rec
                                     ,l_def_pamb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_adj_mat_all_b
    SET    adj_mat_id = l_def_pamb_rec.adj_mat_id
          ,adj_mat_name = l_def_pamb_rec.adj_mat_name
          ,object_version_number = l_def_pamb_rec.object_version_number + 1
          ,org_id = l_def_pamb_rec.org_id
          ,currency_code = l_def_pamb_rec.currency_code
          ,adj_mat_type_code = l_def_pamb_rec.adj_mat_type_code
          ,orig_adj_mat_id = l_def_pamb_rec.orig_adj_mat_id
          ,sts_code = l_def_pamb_rec.sts_code
          ,effective_from_date = l_def_pamb_rec.effective_from_date
          ,effective_to_date = l_def_pamb_rec.effective_to_date
          ,attribute_category = l_def_pamb_rec.attribute_category
          ,attribute1 = l_def_pamb_rec.attribute1
          ,attribute2 = l_def_pamb_rec.attribute2
          ,attribute3 = l_def_pamb_rec.attribute3
          ,attribute4 = l_def_pamb_rec.attribute4
          ,attribute5 = l_def_pamb_rec.attribute5
          ,attribute6 = l_def_pamb_rec.attribute6
          ,attribute7 = l_def_pamb_rec.attribute7
          ,attribute8 = l_def_pamb_rec.attribute8
          ,attribute9 = l_def_pamb_rec.attribute9
          ,attribute10 = l_def_pamb_rec.attribute10
          ,attribute11 = l_def_pamb_rec.attribute11
          ,attribute12 = l_def_pamb_rec.attribute12
          ,attribute13 = l_def_pamb_rec.attribute13
          ,attribute14 = l_def_pamb_rec.attribute14
          ,attribute15 = l_def_pamb_rec.attribute15
          ,created_by = l_def_pamb_rec.created_by
          ,creation_date = l_def_pamb_rec.creation_date
          ,last_updated_by = l_def_pamb_rec.last_updated_by
          ,last_update_date = l_def_pamb_rec.last_update_date
          ,last_update_login = l_def_pamb_rec.last_update_login
    WHERE  adj_mat_id = l_def_pamb_rec.adj_mat_id;

    --Set OUT Values

    x_pamb_rec := l_pamb_rec;
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
  -- Procedure update_row_tl
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamtl_rec     IN            okl_pamtl_rec
                      ,x_pamtl_rec        OUT NOCOPY okl_pamtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'update_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamtl_rec                   okl_pamtl_rec := p_pamtl_rec;
    l_def_pamtl_rec               okl_pamtl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_pamtl_rec IN            okl_pamtl_rec
                           ,x_pamtl_rec    OUT NOCOPY okl_pamtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamtl_rec := p_pamtl_rec;
      x_pamtl_rec.language := USERENV('LANG');
      x_pamtl_rec.source_lang := USERENV('LANG');
      x_pamtl_rec.sfwt_flag := 'N';
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

    l_return_status := set_attributes(p_pamtl_rec
                                     ,l_def_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_adj_mat_all_tl
    SET    adj_mat_id = l_def_pamtl_rec.adj_mat_id
          ,adj_mat_desc = l_def_pamtl_rec.adj_mat_desc
          ,language = l_def_pamtl_rec.language
          ,source_lang = l_def_pamtl_rec.source_lang
          ,sfwt_flag = l_def_pamtl_rec.sfwt_flag
          ,created_by = l_def_pamtl_rec.created_by
          ,creation_date = l_def_pamtl_rec.creation_date
          ,last_updated_by = l_def_pamtl_rec.last_updated_by
          ,last_update_date = l_def_pamtl_rec.last_update_date
          ,last_update_login = l_def_pamtl_rec.last_update_login
    WHERE  adj_mat_id = l_def_pamtl_rec.adj_mat_id
       AND language = l_def_pamtl_rec.language;

    UPDATE okl_fe_adj_mat_all_tl
    SET    sfwt_flag = 'Y'
    WHERE  adj_mat_id = l_def_pamtl_rec.adj_mat_id
       AND source_lang <> USERENV('LANG');

    --Set OUT Values

    x_pamtl_rec := l_pamtl_rec;
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
  -- Procedure insert_row_v
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec
                      ,x_pamv_rec         OUT NOCOPY okl_pamv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamv_rec                    okl_pamv_rec  := p_pamv_rec;
    l_def_pamv_rec                okl_pamv_rec;
    lx_pamv_rec                   okl_pamv_rec;
    l_pamb_rec                    okl_pamb_rec;
    lx_pamb_rec                   okl_pamb_rec;
    l_pamtl_rec                   okl_pamtl_rec;
    lx_pamtl_rec                  okl_pamtl_rec;

    FUNCTION fill_who_columns(p_pamv_rec IN okl_pamv_rec) RETURN okl_pamv_rec IS
      l_pamv_rec                   okl_pamv_rec := p_pamv_rec;

    BEGIN
      l_pamv_rec.last_update_date := SYSDATE;
      l_pamv_rec.last_updated_by := fnd_global.user_id;
      l_pamv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_pamv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_pamv_rec IN            okl_pamv_rec
                                ,x_pamv_rec    OUT NOCOPY okl_pamv_rec) RETURN VARCHAR2 IS
      l_pamv_rec                   okl_pamv_rec;
      l_row_notfound               BOOLEAN      := true;
      l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

    BEGIN
      x_pamv_rec := p_pamv_rec;

      --Get current database values

      l_pamv_rec := get_rec(p_pamv_rec
                           ,l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_pamv_rec.adj_mat_id IS NULL) THEN
        x_pamv_rec.adj_mat_id := l_pamv_rec.adj_mat_id;
      END IF;

      IF (x_pamv_rec.object_version_number IS NULL) THEN
        x_pamv_rec.object_version_number := l_pamv_rec.object_version_number;
      END IF;

      IF (x_pamv_rec.org_id IS NULL) THEN
        x_pamv_rec.org_id := l_pamv_rec.org_id;
      END IF;

      IF (x_pamv_rec.currency_code IS NULL) THEN
        x_pamv_rec.currency_code := l_pamv_rec.currency_code;
      END IF;

      IF (x_pamv_rec.adj_mat_type_code IS NULL) THEN
        x_pamv_rec.adj_mat_type_code := l_pamv_rec.adj_mat_type_code;
      END IF;

      IF (x_pamv_rec.orig_adj_mat_id IS NULL) THEN
        x_pamv_rec.orig_adj_mat_id := l_pamv_rec.orig_adj_mat_id;
      END IF;

      IF (x_pamv_rec.sts_code IS NULL) THEN
        x_pamv_rec.sts_code := l_pamv_rec.sts_code;
      END IF;

      IF (x_pamv_rec.effective_from_date IS NULL) THEN
        x_pamv_rec.effective_from_date := l_pamv_rec.effective_from_date;
      END IF;

      IF (x_pamv_rec.effective_to_date IS NULL) THEN
        x_pamv_rec.effective_to_date := l_pamv_rec.effective_to_date;
      END IF;

      IF (x_pamv_rec.attribute_category IS NULL) THEN
        x_pamv_rec.attribute_category := l_pamv_rec.attribute_category;
      END IF;

      IF (x_pamv_rec.attribute1 IS NULL) THEN
        x_pamv_rec.attribute1 := l_pamv_rec.attribute1;
      END IF;

      IF (x_pamv_rec.attribute2 IS NULL) THEN
        x_pamv_rec.attribute2 := l_pamv_rec.attribute2;
      END IF;

      IF (x_pamv_rec.attribute3 IS NULL) THEN
        x_pamv_rec.attribute3 := l_pamv_rec.attribute3;
      END IF;

      IF (x_pamv_rec.attribute4 IS NULL) THEN
        x_pamv_rec.attribute4 := l_pamv_rec.attribute4;
      END IF;

      IF (x_pamv_rec.attribute5 IS NULL) THEN
        x_pamv_rec.attribute5 := l_pamv_rec.attribute5;
      END IF;

      IF (x_pamv_rec.attribute6 IS NULL) THEN
        x_pamv_rec.attribute6 := l_pamv_rec.attribute6;
      END IF;

      IF (x_pamv_rec.attribute7 IS NULL) THEN
        x_pamv_rec.attribute7 := l_pamv_rec.attribute7;
      END IF;

      IF (x_pamv_rec.attribute8 IS NULL) THEN
        x_pamv_rec.attribute8 := l_pamv_rec.attribute8;
      END IF;

      IF (x_pamv_rec.attribute9 IS NULL) THEN
        x_pamv_rec.attribute9 := l_pamv_rec.attribute9;
      END IF;

      IF (x_pamv_rec.attribute10 IS NULL) THEN
        x_pamv_rec.attribute10 := l_pamv_rec.attribute10;
      END IF;

      IF (x_pamv_rec.attribute11 IS NULL) THEN
        x_pamv_rec.attribute11 := l_pamv_rec.attribute11;
      END IF;

      IF (x_pamv_rec.attribute12 IS NULL) THEN
        x_pamv_rec.attribute12 := l_pamv_rec.attribute12;
      END IF;

      IF (x_pamv_rec.attribute13 IS NULL) THEN
        x_pamv_rec.attribute13 := l_pamv_rec.attribute13;
      END IF;

      IF (x_pamv_rec.attribute14 IS NULL) THEN
        x_pamv_rec.attribute14 := l_pamv_rec.attribute14;
      END IF;

      IF (x_pamv_rec.attribute15 IS NULL) THEN
        x_pamv_rec.attribute15 := l_pamv_rec.attribute15;
      END IF;

      IF (x_pamv_rec.created_by IS NULL) THEN
        x_pamv_rec.created_by := l_pamv_rec.created_by;
      END IF;

      IF (x_pamv_rec.creation_date IS NULL) THEN
        x_pamv_rec.creation_date := l_pamv_rec.creation_date;
      END IF;

      IF (x_pamv_rec.last_updated_by IS NULL) THEN
        x_pamv_rec.last_updated_by := l_pamv_rec.last_updated_by;
      END IF;

      IF (x_pamv_rec.last_update_date IS NULL) THEN
        x_pamv_rec.last_update_date := l_pamv_rec.last_update_date;
      END IF;

      IF (x_pamv_rec.last_update_login IS NULL) THEN
        x_pamv_rec.last_update_login := l_pamv_rec.last_update_login;
      END IF;

      IF (x_pamv_rec.adj_mat_name IS NULL) THEN
        x_pamv_rec.adj_mat_name := l_pamv_rec.adj_mat_name;
      END IF;

      IF (x_pamv_rec.adj_mat_desc IS NULL) THEN
        x_pamv_rec.adj_mat_desc := l_pamv_rec.adj_mat_desc;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_pamv_rec IN            okl_pamv_rec
                           ,x_pamv_rec    OUT NOCOPY okl_pamv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamv_rec := p_pamv_rec;
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

    l_return_status := set_attributes(l_pamv_rec
                                     ,lx_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := populate_new_record(lx_pamv_rec
                                          ,l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pamv_rec := null_out_defaults(l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_pamv_rec := fill_who_columns(l_def_pamv_rec);
    l_return_status := validate_attributes(l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --lock the row

    lock_row(p_api_version   =>            l_api_version
            ,p_init_msg_list =>            okl_api.g_false
            ,x_return_status =>            l_return_status
            ,x_msg_count     =>            x_msg_count
            ,x_msg_data      =>            x_msg_data
            ,p_pamv_rec      =>            l_def_pamv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_def_pamv_rec
           ,l_pamb_rec);
    migrate(l_def_pamv_rec
           ,l_pamtl_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamb_rec
              ,lx_pamb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_pamb_rec
           ,l_def_pamv_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamtl_rec
              ,lx_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_pamtl_rec
           ,l_def_pamv_rec);

    --Set OUT Values

    x_pamv_rec := l_def_pamv_rec;
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl
                      ,x_pamv_tbl         OUT NOCOPY okl_pamv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pamv_tbl.COUNT > 0) THEN
      i := p_pamv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pamv_rec      =>            p_pamv_tbl(i)
                  ,x_pamv_rec      =>            x_pamv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pamv_tbl.LAST);
        i := p_pamv_tbl.next(i);
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
  -- Procedure delete_row_b
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamb_rec      IN            okl_pamb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_pamb_rec                    okl_pamb_rec := p_pamb_rec;
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

    DELETE FROM okl_fe_adj_mat_all_b
    WHERE       adj_mat_id = l_pamb_rec.adj_mat_id;

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
  -- Procedure delete_row_tl
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamtl_rec     IN            okl_pamtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamtl_rec                   okl_pamtl_rec := p_pamtl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_pamtl_rec IN            okl_pamtl_rec
                           ,x_pamtl_rec    OUT NOCOPY okl_pamtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_pamtl_rec := p_pamtl_rec;
      x_pamtl_rec.language := USERENV('LANG');
      x_pamtl_rec.source_lang := USERENV('LANG');
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

    l_return_status := set_attributes(p_pamtl_rec
                                     ,l_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_adj_mat_all_tl
    WHERE       adj_mat_id = l_pamtl_rec.adj_mat_id;

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
  -- Procedure delete_row_v
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_pamv_rec                    okl_pamv_rec  := p_pamv_rec;
    l_pamb_rec                    okl_pamb_rec;
    l_pamtl_rec                   okl_pamtl_rec;

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
    migrate(l_pamv_rec
           ,l_pamb_rec);
    migrate(l_pamv_rec
           ,l_pamtl_rec);
    delete_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    delete_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_pamtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
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
  END delete_row;

  --------------------------------------------------------------------------------
  -- Procedure delete_row_tbl
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_pamv_tbl.COUNT > 0) THEN
      i := p_pamv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_pamv_rec      =>            p_pamv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_pamv_tbl.LAST);
        i := p_pamv_tbl.next(i);
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

END okl_pam_pvt;

/
