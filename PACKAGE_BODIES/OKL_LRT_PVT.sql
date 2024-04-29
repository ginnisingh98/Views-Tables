--------------------------------------------------------
--  DDL for Package Body OKL_LRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRT_PVT" AS
/* $Header: OKLSLRTB.pls 120.14 2007/08/08 12:47:59 arajagop noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------

  PROCEDURE add_language IS

  BEGIN

    DELETE FROM okl_ls_rt_fctr_sets_tl t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_LS_RT_FTR_SETS_ALL_B  b
                           WHERE  b.id = t.id);

    UPDATE okl_ls_rt_fctr_sets_tl t
    SET(description) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.description
                              FROM   okl_ls_rt_fctr_sets_tl b
                              WHERE  b.id = t.id
                                 AND b.language = t.source_lang)
    WHERE  (t.id, t.language) IN(SELECT subt.id ,subt.language
           FROM   okl_ls_rt_fctr_sets_tl subb ,okl_ls_rt_fctr_sets_tl subt
           WHERE  subb.id = subt.id AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.description <> subt.description OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.description IS NULL AND subt.description IS NOT NULL)));

    INSERT INTO okl_ls_rt_fctr_sets_tl
               (id
               ,language
               ,source_lang
               ,sfwt_flag
               ,description)
                SELECT b.id
                      ,l.language_code
                      ,b.source_lang
                      ,b.sfwt_flag
                      ,b.description
                FROM   okl_ls_rt_fctr_sets_tl b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   okl_ls_rt_fctr_sets_tl t
                                      WHERE  t.id = b.id AND t.language = l.language_code);

  END add_language;

  ----------
  -- get_rec
  ----------

  FUNCTION get_rec(p_id             IN             number
                  ,x_return_status     OUT NOCOPY  varchar2) RETURN lrtv_rec_type IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'get_rec';
    l_lrtv_rec          lrtv_rec_type;

  BEGIN

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
          ,orig_rate_set_id
    INTO   l_lrtv_rec.id
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
          ,l_lrtv_rec.end_of_term_id
          ,l_lrtv_rec.orig_rate_set_id
    FROM   okl_ls_rt_fctr_sets_v lrtv
    WHERE  lrtv.id = p_id;
    x_return_status := g_ret_sts_success;
    RETURN l_lrtv_rec;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END get_rec;

  --------------------
  -- null_out_defaults
  --------------------

  FUNCTION null_out_defaults(p_lrtv_rec  IN  lrtv_rec_type) RETURN lrtv_rec_type IS
    l_lrtv_rec lrtv_rec_type := p_lrtv_rec;

  BEGIN

    IF (l_lrtv_rec.id = g_miss_num) THEN
      l_lrtv_rec.id := NULL;
    END IF;

    IF (l_lrtv_rec.object_version_number = g_miss_num) THEN
      l_lrtv_rec.object_version_number := NULL;
    END IF;

    IF (l_lrtv_rec.sfwt_flag = g_miss_char) THEN
      l_lrtv_rec.sfwt_flag := NULL;
    END IF;

    IF (l_lrtv_rec.try_id = g_miss_num) THEN
      l_lrtv_rec.try_id := NULL;
    END IF;

    IF (l_lrtv_rec.pdt_id = g_miss_num) THEN
      l_lrtv_rec.pdt_id := NULL;
    END IF;

    IF (l_lrtv_rec.rate = g_miss_num) THEN
      l_lrtv_rec.rate := NULL;
    END IF;

    IF (l_lrtv_rec.frq_code = g_miss_char) THEN
      l_lrtv_rec.frq_code := NULL;
    END IF;

    IF (l_lrtv_rec.arrears_yn = g_miss_char) THEN
      l_lrtv_rec.arrears_yn := NULL;
    END IF;

    IF (l_lrtv_rec.start_date = g_miss_date) THEN
      l_lrtv_rec.start_date := NULL;
    END IF;

    IF (l_lrtv_rec.end_date = g_miss_date) THEN
      l_lrtv_rec.end_date := NULL;
    END IF;

    IF (l_lrtv_rec.name = g_miss_char) THEN
      l_lrtv_rec.name := NULL;
    END IF;

    IF (l_lrtv_rec.description = g_miss_char) THEN
      l_lrtv_rec.description := NULL;
    END IF;

    IF (l_lrtv_rec.created_by = g_miss_num) THEN
      l_lrtv_rec.created_by := NULL;
    END IF;

    IF (l_lrtv_rec.creation_date = g_miss_date) THEN
      l_lrtv_rec.creation_date := NULL;
    END IF;

    IF (l_lrtv_rec.last_updated_by = g_miss_num) THEN
      l_lrtv_rec.last_updated_by := NULL;
    END IF;

    IF (l_lrtv_rec.last_update_date = g_miss_date) THEN
      l_lrtv_rec.last_update_date := NULL;
    END IF;

    IF (l_lrtv_rec.last_update_login = g_miss_num) THEN
      l_lrtv_rec.last_update_login := NULL;
    END IF;

    IF (l_lrtv_rec.attribute_category = g_miss_char) THEN
      l_lrtv_rec.attribute_category := NULL;
    END IF;

    IF (l_lrtv_rec.attribute1 = g_miss_char) THEN
      l_lrtv_rec.attribute1 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute2 = g_miss_char) THEN
      l_lrtv_rec.attribute2 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute3 = g_miss_char) THEN
      l_lrtv_rec.attribute3 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute4 = g_miss_char) THEN
      l_lrtv_rec.attribute4 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute5 = g_miss_char) THEN
      l_lrtv_rec.attribute5 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute6 = g_miss_char) THEN
      l_lrtv_rec.attribute6 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute7 = g_miss_char) THEN
      l_lrtv_rec.attribute7 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute8 = g_miss_char) THEN
      l_lrtv_rec.attribute8 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute9 = g_miss_char) THEN
      l_lrtv_rec.attribute9 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute10 = g_miss_char) THEN
      l_lrtv_rec.attribute10 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute11 = g_miss_char) THEN
      l_lrtv_rec.attribute11 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute12 = g_miss_char) THEN
      l_lrtv_rec.attribute12 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute13 = g_miss_char) THEN
      l_lrtv_rec.attribute13 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute14 = g_miss_char) THEN
      l_lrtv_rec.attribute14 := NULL;
    END IF;

    IF (l_lrtv_rec.attribute15 = g_miss_char) THEN
      l_lrtv_rec.attribute15 := NULL;
    END IF;

    IF (l_lrtv_rec.sts_code = g_miss_char) THEN
      l_lrtv_rec.sts_code := NULL;
    END IF;

    IF (l_lrtv_rec.org_id = g_miss_num) THEN
      l_lrtv_rec.org_id := NULL;
    END IF;

    IF (l_lrtv_rec.currency_code = g_miss_char) THEN
      l_lrtv_rec.currency_code := NULL;
    END IF;

    IF (l_lrtv_rec.lrs_type_code = g_miss_char) THEN
      l_lrtv_rec.lrs_type_code := NULL;
    END IF;

    IF (l_lrtv_rec.end_of_term_id = g_miss_num) THEN
      l_lrtv_rec.end_of_term_id := NULL;
    END IF;

    IF (l_lrtv_rec.orig_rate_set_id = g_miss_num) THEN
      l_lrtv_rec.orig_rate_set_id := NULL;
    END IF;

    RETURN(l_lrtv_rec);
  END null_out_defaults;

  ---------------------------------
  -- PROCEDURE validate_id
  ---------------------------------

  PROCEDURE validate_id(x_return_status     OUT NOCOPY  varchar2
                       ,p_id             IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_id';

  BEGIN

    IF p_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'id');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_id;

  PROCEDURE validate_object_version_number(x_return_status             OUT NOCOPY  varchar2
                                          ,p_object_version_number  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_version_number';

  BEGIN

    IF (p_object_version_number IS NULL) OR (p_object_version_number = g_miss_num) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'object_version_number');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_object_version_number;

  ---------------------------------
  -- PROCEDURE validate_rate
  ---------------------------------

  PROCEDURE validate_rate(x_return_status     OUT NOCOPY  varchar2
                         ,p_rate           IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_rate';

  BEGIN

    IF p_rate IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'rate');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_rate;

  ---------------------------------
  -- PROCEDURE validate_arrears_yn
  ---------------------------------

  PROCEDURE validate_arrears_yn(x_return_status     OUT NOCOPY  varchar2
                               ,p_arrears_yn     IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_arrears_yn';

    CURSOR c_yes_no IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKL_YES_NO' AND lookup_code = p_arrears_yn;
    l_dummy varchar2(1);

  BEGIN

    IF p_arrears_yn IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'arrears_yn');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_yes_no;
    FETCH c_yes_no INTO l_dummy ;
    CLOSE c_yes_no;

    IF l_dummy IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'arrears_yn');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_arrears_yn;

  ---------------------------------
  -- PROCEDURE validate_frq_code
  ---------------------------------

  PROCEDURE validate_frq_code(x_return_status     OUT NOCOPY  varchar2
                             ,p_frq_code       IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_frq_code';

    CURSOR c_frq_code IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKL_FREQUENCY' AND lookup_code = p_frq_code;
    l_dummy varchar2(1);

  BEGIN

    IF p_frq_code IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'frq_code');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_frq_code;
    FETCH c_frq_code INTO l_dummy ;
    CLOSE c_frq_code;

    IF l_dummy IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'frq_code');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_frq_code;

  ---------------------------------
  -- PROCEDURE validate_name
  ---------------------------------

  PROCEDURE validate_name(x_return_status     OUT NOCOPY  varchar2
                         ,p_name           IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_name';

  BEGIN

    IF p_name IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'name');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_name;

  -------------------------------------
  -- PROCEDURE validate_lrs_type_code
  -------------------------------------

  PROCEDURE validate_lrs_type_code(x_return_status     OUT NOCOPY  varchar2
                                  ,p_type_code      IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_lrs_type_code';

    CURSOR c_type_code IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKL_LRS_TYPES' AND lookup_code = p_type_code;
    l_dummy varchar2(1) := '?';

  BEGIN

    IF p_type_code IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'LRS_TYPE_CODE');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_type_code;
    FETCH c_type_code INTO l_dummy ;
    CLOSE c_type_code;

    IF l_dummy = '?' THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'LRS_TYPE_CODE');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_lrs_type_code;

  --------------------------------------
  -- PROCEDURE validate_STS_CODE
  --------------------------------------

  PROCEDURE validate_sts_code(x_return_status     OUT NOCOPY  varchar2
                             ,p_sts_code       IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_STS_CODE';

    CURSOR c_sts_code IS
      SELECT 'x'
      FROM   fnd_lookups
      WHERE  lookup_type = 'OKL_PRC_STATUS' AND lookup_code = p_sts_code;
    l_dummy varchar2(1);

  BEGIN

    IF p_sts_code IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'STS_CODE');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_sts_code;
    FETCH c_sts_code INTO l_dummy ;
    CLOSE c_sts_code;

    IF l_dummy IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'STS_CODE');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_sts_code;

  ---------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------

  PROCEDURE validate_org_id(x_return_status     OUT NOCOPY  varchar2
                           ,p_org_id         IN             number) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_org_id';
    l_return_status          varchar2(3);

  BEGIN
    l_return_status := okl_util.check_org_id(p_org_id, 'N');

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'org_id');
      RAISE okl_api.g_exception_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN

      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_org_id;

  ---------------------------------
  -- PROCEDURE validate_END_OF_TERM_ID
  ---------------------------------

  PROCEDURE validate_end_of_term_id(x_return_status      OUT NOCOPY  varchar2
                                   ,p_end_of_term_id  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_END_OF_TERM_ID';

    CURSOR c_end_of_term_id IS
      SELECT 'X'
      FROM   okl_fe_eo_terms_v
      WHERE  end_of_term_id = p_end_of_term_id;
    l_dummy varchar2(1) := '?';

  BEGIN

    IF p_end_of_term_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'END_OF_TERM_ID');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_end_of_term_id;
    FETCH c_end_of_term_id INTO l_dummy ;
    CLOSE c_end_of_term_id;

    IF l_dummy = '?' THEN
      okl_api.set_message(p_app_name     =>  okl_api.g_app_name
                         ,p_msg_name     =>  'OKC_NO_PARENT_RECORD'
                         ,p_token1       =>  okl_api.g_col_name_token
                         ,p_token1_value =>  'END_OF_TERM_ID'
                         ,p_token2       =>  okl_api.g_child_table_token
                         ,p_token2_value =>  'OKL_LS_RT_FCTR_SETS_B'
                         ,p_token3       =>  okl_api.g_parent_table_token
                         ,p_token3_value =>  'OKL_FE_EO_TERMS_V');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_end_of_term_id;

  ---------------------------------
  -- PROCEDURE validate_currency_code
  ---------------------------------

  PROCEDURE validate_currency_code(x_return_status     OUT NOCOPY  varchar2
                                  ,p_currency_code  IN             varchar2) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_currency_code';

  BEGIN

    IF p_currency_code IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'currency_code');
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_currency_code;

  --------------------------------
  -- PROCEDURE validate_attributes
  --------------------------------

  FUNCTION validate_attributes(p_lrtv_rec  IN  lrtv_rec_type) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';
    x_return_status          varchar2(1);

  BEGIN

    --

    validate_id(x_return_status, p_lrtv_rec.id);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    --

    validate_object_version_number(x_return_status
                                  ,p_lrtv_rec.object_version_number);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    validate_frq_code(x_return_status, p_lrtv_rec.frq_code);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    validate_name(x_return_status, p_lrtv_rec.name);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    validate_sts_code(x_return_status, p_lrtv_rec.sts_code);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    validate_lrs_type_code(x_return_status, p_lrtv_rec.lrs_type_code);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    validate_org_id(x_return_status, p_lrtv_rec.org_id);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    validate_end_of_term_id(x_return_status, p_lrtv_rec.end_of_term_id);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;

    validate_currency_code(x_return_status, p_lrtv_rec.currency_code);

    IF x_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF x_return_status = g_ret_sts_unexp_error THEN
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
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_attributes;

  ------------------
  -- validate_record
  ------------------

  FUNCTION validate_record(p_lrtv_rec  IN  lrtv_rec_type) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_record';

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
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_record;

  ----------------
  -- migrate (V-B)
  ----------------

  PROCEDURE migrate(p_from  IN             lrtv_rec_type
                   ,p_to    IN OUT NOCOPY  lrt_rec_type) IS

  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.arrears_yn := p_from.arrears_yn;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.pdt_id := p_from.pdt_id;
    p_to.rate := p_from.rate;
    p_to.try_id := p_from.try_id;
    p_to.frq_code := p_from.frq_code;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.sts_code := p_from.sts_code;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.lrs_type_code := p_from.lrs_type_code;
    p_to.end_of_term_id := p_from.end_of_term_id;
    p_to.orig_rate_set_id := p_from.orig_rate_set_id;

  END migrate;

  ----------------
  -- migrate (V-TL)
  ----------------

  PROCEDURE migrate(p_from  IN             lrtv_rec_type
                   ,p_to    IN OUT NOCOPY  lrttl_rec_type) IS

  BEGIN
    p_to.id := p_from.id;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------
  -- validate_row (REC)
  ---------------------

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrtv_rec       IN             lrtv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_row (REC)';
    l_return_status          varchar2(1);

  BEGIN
    l_return_status := validate_attributes(p_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(p_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_row;

  ---------------------
  -- validate_row (TBL)
  ---------------------

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrtv_tbl       IN             lrtv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrtv_tbl.COUNT > 0) THEN
      i := p_lrtv_tbl.FIRST;

      LOOP
        IF p_lrtv_tbl.EXISTS(i) THEN
          validate_row(p_api_version   =>  g_api_version
                      ,p_init_msg_list =>  g_false
                      ,x_return_status =>  l_return_status
                      ,x_msg_count     =>  x_msg_count
                      ,x_msg_data      =>  x_msg_data
                      ,p_lrtv_rec      =>  p_lrtv_tbl(i));
          IF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          ELSIF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          END IF;
          EXIT WHEN i = p_lrtv_tbl.LAST;
          i := p_lrtv_tbl.next(i);
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
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END validate_row;

  -----------------
  -- insert_row (B)
  -----------------

  PROCEDURE insert_row(x_return_status     OUT NOCOPY  varchar2
                      ,p_lrt_rec        IN             lrt_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (B)';
    l_lrt_rec           lrt_rec_type := p_lrt_rec;

  BEGIN

    INSERT INTO okl_ls_rt_fctr_sets_b
               (id
               ,object_version_number
               ,name
               ,arrears_yn
               ,start_date
               ,end_date
               ,pdt_id
               ,rate
               ,try_id
               ,frq_code
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
               ,orig_rate_set_id)
    VALUES     (l_lrt_rec.id
               ,l_lrt_rec.object_version_number
               ,l_lrt_rec.name
               ,l_lrt_rec.arrears_yn
               ,l_lrt_rec.start_date
               ,l_lrt_rec.end_date
               ,l_lrt_rec.pdt_id
               ,l_lrt_rec.rate
               ,l_lrt_rec.try_id
               ,l_lrt_rec.frq_code
               ,l_lrt_rec.created_by
               ,l_lrt_rec.creation_date
               ,l_lrt_rec.last_updated_by
               ,l_lrt_rec.last_update_date
               ,l_lrt_rec.last_update_login
               ,l_lrt_rec.attribute_category
               ,l_lrt_rec.attribute1
               ,l_lrt_rec.attribute2
               ,l_lrt_rec.attribute3
               ,l_lrt_rec.attribute4
               ,l_lrt_rec.attribute5
               ,l_lrt_rec.attribute6
               ,l_lrt_rec.attribute7
               ,l_lrt_rec.attribute8
               ,l_lrt_rec.attribute9
               ,l_lrt_rec.attribute10
               ,l_lrt_rec.attribute11
               ,l_lrt_rec.attribute12
               ,l_lrt_rec.attribute13
               ,l_lrt_rec.attribute14
               ,l_lrt_rec.attribute15
               ,l_lrt_rec.sts_code
               ,l_lrt_rec.org_id
               ,l_lrt_rec.currency_code
               ,l_lrt_rec.lrs_type_code
               ,l_lrt_rec.end_of_term_id
               ,l_lrt_rec.orig_rate_set_id);
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END insert_row;

  ------------------
  -- insert_row (TL)
  ------------------

  PROCEDURE insert_row(x_return_status     OUT NOCOPY  varchar2
                      ,p_lrttl_rec      IN             lrttl_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (TL)';

    CURSOR get_languages IS
      SELECT language_code
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B');
    l_sfwt_flag varchar2(1);
    l_miss_flag varchar2(1) := 'Y';

  BEGIN

    FOR l_lang_rec IN get_languages LOOP

      IF l_lang_rec.language_code = userenv('LANG') THEN
        l_sfwt_flag := 'N';
      ELSE
        l_sfwt_flag := 'Y';
      END IF;

      IF l_lang_rec.language_code = userenv('LANG') THEN
        l_miss_flag := 'N';
      END IF;

      INSERT INTO okl_ls_rt_fctr_sets_tl
                 (id
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,description
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (p_lrttl_rec.id
                 ,l_lang_rec.language_code
                 ,userenv('LANG')
                 ,l_sfwt_flag
                 ,p_lrttl_rec.description
                 ,p_lrttl_rec.created_by
                 ,p_lrttl_rec.creation_date
                 ,p_lrttl_rec.last_updated_by
                 ,p_lrttl_rec.last_update_date
                 ,p_lrttl_rec.last_update_login);

    END LOOP;

    IF l_miss_flag = 'Y' THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_LANG_NOT_INSTALLED'
                         ,p_token1       =>  'LANG_CODE'
                         ,p_token1_value =>  userenv('LANG'));
    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END insert_row;

  -------------------
  -- insert_row (REC)
  -------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type
                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (REC)';
    l_return_status          varchar2(1);
    l_lrtv_rec               lrtv_rec_type;
    l_lrt_rec                lrt_rec_type;
    l_lrttl_rec              lrttl_rec_type;

  BEGIN
    l_lrtv_rec := null_out_defaults(p_lrtv_rec);
    l_lrtv_rec.id := okc_p_util.raw_to_number(sys_guid());
    l_lrtv_rec.object_version_number := 1;
    l_lrtv_rec.sfwt_flag := 'N';
    l_lrtv_rec.creation_date := sysdate;
    l_lrtv_rec.created_by := fnd_global.user_id;
    l_lrtv_rec.last_update_date := sysdate;
    l_lrtv_rec.last_updated_by := fnd_global.user_id;
    l_lrtv_rec.last_update_login := fnd_global.login_id;
    l_lrtv_rec.org_id := mo_global.get_current_org_id();

    --default depricated columns

    l_lrtv_rec.pdt_id := - 1;
    l_lrtv_rec.try_id := - 1;
    l_lrtv_rec.arrears_yn := 'NA';
    l_return_status := validate_attributes(l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    l_return_status := validate_record(l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_lrtv_rec, l_lrt_rec);
    migrate(l_lrtv_rec, l_lrttl_rec);
    insert_row(x_return_status =>  l_return_status
              ,p_lrt_rec       =>  l_lrt_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    insert_row(x_return_status =>  l_return_status
              ,p_lrttl_rec     =>  l_lrttl_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    x_lrtv_rec := l_lrtv_rec;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END insert_row;

  -------------------
  -- insert_row (TBL)
  -------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type
                      ,x_lrtv_tbl          OUT NOCOPY  lrtv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrtv_tbl.COUNT > 0) THEN
      i := p_lrtv_tbl.FIRST;

      LOOP
        IF p_lrtv_tbl.EXISTS(i) THEN
          insert_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrtv_rec      =>  p_lrtv_tbl(i)
                    ,x_lrtv_rec      =>  x_lrtv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrtv_tbl.LAST);
          i := p_lrtv_tbl.next(i);
        END IF;
      END LOOP;

    END IF;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END insert_row;

  ---------------
  -- lock_row (B)
  ---------------

  PROCEDURE lock_row(x_return_status     OUT NOCOPY  varchar2
                    ,p_lrt_rec        IN             lrt_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (TL)';
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_lrt_rec  IN  lrt_rec_type) IS
      SELECT        object_version_number
      FROM          okl_ls_rt_fctr_sets_b
      WHERE         id = p_lrt_rec.id
                AND object_version_number = p_lrt_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_lrt_rec  IN  lrt_rec_type) IS
      SELECT object_version_number
      FROM   okl_ls_rt_fctr_sets_b
      WHERE  id = p_lrt_rec.id;
    l_return_status          varchar2(1) := g_ret_sts_success;
    l_object_version_number  okl_ls_rt_fctr_sets_b.object_version_number%TYPE;
    lc_object_version_number okl_ls_rt_fctr_sets_b.object_version_number%TYPE;
    l_row_notfound           boolean := false;
    lc_row_notfound          boolean := false;

  BEGIN

    BEGIN
      OPEN lock_csr(p_lrt_rec);
      FETCH lock_csr INTO l_object_version_number ;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
      EXCEPTION
        WHEN e_resource_busy THEN

          IF (lock_csr%ISOPEN) THEN
            CLOSE lock_csr;
          END IF;
          okc_api.set_message(g_fnd_app, g_form_unable_to_reserve_rec);
          RAISE app_exceptions.record_lock_exception;
    END;

    IF (l_row_notfound) THEN
      OPEN lchk_csr(p_lrt_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okc_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_lrt_rec.object_version_number THEN
      okc_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_lrt_rec.object_version_number THEN
      okc_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okc_api.set_message(g_app_name, g_record_logically_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  ---------------
  -- lock_row (TL)
  ---------------

  PROCEDURE lock_row(x_return_status     OUT NOCOPY  varchar2
                    ,p_lrttl_rec      IN             lrttl_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (TL)';
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_lrttl_rec  IN  lrttl_rec_type) IS
      SELECT     *
      FROM       okl_ls_rt_fctr_sets_tl
      WHERE      id = p_lrttl_rec.id
      FOR UPDATE NOWAIT;
    l_return_status varchar2(1) := g_ret_sts_success;
    l_lock_var      lock_csr%ROWTYPE;
    l_row_notfound  boolean := false;
    lc_row_notfound boolean := false;

  BEGIN

    BEGIN
      OPEN lock_csr(p_lrttl_rec);
      FETCH lock_csr INTO l_lock_var ;
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

    IF l_row_notfound THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  -----------------
  -- lock_row (REC)
  -----------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrtv_rec       IN             lrtv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (REC)';
    l_return_status          varchar2(1);
    l_lrt_rec                lrt_rec_type;
    l_lrttl_rec              lrttl_rec_type;

  BEGIN
    migrate(p_lrtv_rec, l_lrt_rec);
    migrate(p_lrtv_rec, l_lrttl_rec);
    lock_row(x_return_status =>  l_return_status
            ,p_lrt_rec       =>  l_lrt_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lock_row(x_return_status =>  l_return_status
            ,p_lrttl_rec     =>  l_lrttl_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  -----------------
  -- lock_row (TBL)
  -----------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrtv_tbl       IN             lrtv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrtv_tbl.COUNT > 0) THEN
      i := p_lrtv_tbl.FIRST;

      LOOP
        IF p_lrtv_tbl.EXISTS(i) THEN
          lock_row(p_api_version   =>  g_api_version
                  ,p_init_msg_list =>  g_false
                  ,x_return_status =>  l_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_lrtv_rec      =>  p_lrtv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrtv_tbl.LAST);
          i := p_lrtv_tbl.next(i);
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
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END lock_row;

  -----------------
  -- update_row (B)
  -----------------

  PROCEDURE update_row(x_return_status     OUT NOCOPY  varchar2
                      ,p_lrt_rec        IN             lrt_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (B)';

  BEGIN

    UPDATE okl_ls_rt_fctr_sets_b
    SET    object_version_number = p_lrt_rec.object_version_number + 1
          ,name = p_lrt_rec.name
          ,arrears_yn = p_lrt_rec.arrears_yn
          ,start_date = p_lrt_rec.start_date
          ,end_date = p_lrt_rec.end_date
          ,pdt_id = p_lrt_rec.pdt_id
          ,rate = p_lrt_rec.rate
          ,try_id = p_lrt_rec.try_id
          ,frq_code = p_lrt_rec.frq_code
          ,created_by = p_lrt_rec.created_by
          ,creation_date = p_lrt_rec.creation_date
          ,last_updated_by = p_lrt_rec.last_updated_by
          ,last_update_date = p_lrt_rec.last_update_date
          ,last_update_login = p_lrt_rec.last_update_login
          ,attribute_category = p_lrt_rec.attribute_category
          ,attribute1 = p_lrt_rec.attribute1
          ,attribute2 = p_lrt_rec.attribute2
          ,attribute3 = p_lrt_rec.attribute3
          ,attribute4 = p_lrt_rec.attribute4
          ,attribute5 = p_lrt_rec.attribute5
          ,attribute6 = p_lrt_rec.attribute6
          ,attribute7 = p_lrt_rec.attribute7
          ,attribute8 = p_lrt_rec.attribute8
          ,attribute9 = p_lrt_rec.attribute9
          ,attribute10 = p_lrt_rec.attribute10
          ,attribute11 = p_lrt_rec.attribute11
          ,attribute12 = p_lrt_rec.attribute12
          ,attribute13 = p_lrt_rec.attribute13
          ,attribute14 = p_lrt_rec.attribute14
          ,attribute15 = p_lrt_rec.attribute15
          ,sts_code = p_lrt_rec.sts_code
          ,org_id = p_lrt_rec.org_id
          ,currency_code = p_lrt_rec.currency_code
          ,lrs_type_code = p_lrt_rec.lrs_type_code
          ,end_of_term_id = p_lrt_rec.end_of_term_id
          ,orig_rate_set_id = p_lrt_rec.orig_rate_set_id
    WHERE  id = p_lrt_rec.id;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END update_row;

  ------------------
  -- update_row (TL)
  ------------------

  PROCEDURE update_row(x_return_status     OUT NOCOPY  varchar2
                      ,p_lrttl_rec      IN             lrttl_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (TL)';

    CURSOR c_lang_setup IS
      SELECT 'Y'
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B') AND language_code = userenv('LANG');

    CURSOR c_lang_found IS
      SELECT 'Y'
      FROM   okl_ls_rt_fctr_sets_tl
      WHERE  id = p_lrttl_rec.id AND language = userenv('LANG');
    l_lang_setup varchar2(1) := 'N';
    l_lang_found varchar2(1) := 'N';

  BEGIN
    OPEN c_lang_setup;
    FETCH c_lang_setup INTO l_lang_setup ;
    CLOSE c_lang_setup;

    IF l_lang_setup = 'N' THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_LANG_NOT_INSTALLED'
                         ,p_token1       =>  'LANG_CODE'
                         ,p_token1_value =>  userenv('LANG'));
    END IF;
    OPEN c_lang_found;
    FETCH c_lang_found INTO l_lang_found ;
    CLOSE c_lang_found;

    IF l_lang_found = 'N' THEN

      INSERT INTO okl_ls_rt_fctr_sets_tl
                 (id
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,description
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (p_lrttl_rec.id
                 ,userenv('LANG')
                 ,userenv('LANG')
                 ,'N'
                 ,p_lrttl_rec.description
                 ,p_lrttl_rec.created_by
                 ,p_lrttl_rec.creation_date
                 ,p_lrttl_rec.last_updated_by
                 ,p_lrttl_rec.last_update_date
                 ,p_lrttl_rec.last_update_login);

    END IF;

    UPDATE okl_ls_rt_fctr_sets_tl
    SET    description = p_lrttl_rec.description
          ,source_lang = userenv('LANG')
          ,created_by = p_lrttl_rec.created_by
          ,creation_date = p_lrttl_rec.creation_date
          ,last_updated_by = p_lrttl_rec.last_updated_by
          ,last_update_date = p_lrttl_rec.last_update_date
          ,last_update_login = p_lrttl_rec.last_update_login
    WHERE  id = p_lrttl_rec.id;

    UPDATE okl_ls_rt_fctr_sets_tl
    SET    sfwt_flag = 'Y'
    WHERE  id = p_lrttl_rec.id AND source_lang <> language;

    UPDATE okl_ls_rt_fctr_sets_tl
    SET    sfwt_flag = 'N'
    WHERE  id = p_lrttl_rec.id AND source_lang = language;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END update_row;

  -------------------
  -- update_row (REC)
  -------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type
                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (REC)';
    l_return_status          varchar2(1);
    l_lrtv_rec               lrtv_rec_type;
    l_lrt_rec                lrt_rec_type;
    l_lrttl_rec              lrttl_rec_type;
    l_lrfv_tbl               okl_lrf_pvt.lrfv_tbl_type;
    lx_lrfv_tbl              okl_lrf_pvt.lrfv_tbl_type;
    i                        binary_integer := 0;
    l_old_rate               number;

    CURSOR c_lrf_rec(p_lrt_id   number) IS
      SELECT id
      FROM   okl_ls_rt_fctr_ents
      WHERE  lrt_id = p_lrt_id;

    ----------------------
    -- populate_new_record
    ----------------------

    FUNCTION populate_new_record(p_lrtv_rec  IN             lrtv_rec_type
                                ,x_lrtv_rec     OUT NOCOPY  lrtv_rec_type) RETURN varchar2 IS
      l_return_status varchar2(1);
      l_db_lrtv_rec   lrtv_rec_type;

    BEGIN
      x_lrtv_rec := p_lrtv_rec;
      l_db_lrtv_rec := get_rec(p_lrtv_rec.id, l_return_status);

      IF l_return_status = g_ret_sts_unexp_error THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF l_return_status = g_ret_sts_error THEN
        RAISE okl_api.g_exception_error;
      END IF;

      -- Do NOT default the following 4 standard attributes from the DB
      -- object_version_number
      -- last_update_date
      -- last_update_by
      -- last_update_login

      IF (x_lrtv_rec.id IS NULL) THEN
        x_lrtv_rec.id := l_db_lrtv_rec.id;
      END IF;

      IF (x_lrtv_rec.try_id IS NULL) THEN
        x_lrtv_rec.try_id := l_db_lrtv_rec.try_id;
      END IF;

      IF (x_lrtv_rec.pdt_id IS NULL) THEN
        x_lrtv_rec.pdt_id := l_db_lrtv_rec.pdt_id;
      END IF;

      IF (x_lrtv_rec.rate IS NULL) THEN
        x_lrtv_rec.rate := l_db_lrtv_rec.rate;
      END IF;

      IF (x_lrtv_rec.frq_code IS NULL) THEN
        x_lrtv_rec.frq_code := l_db_lrtv_rec.frq_code;
      END IF;

      IF (x_lrtv_rec.arrears_yn IS NULL) THEN
        x_lrtv_rec.arrears_yn := l_db_lrtv_rec.arrears_yn;
      END IF;

      IF (x_lrtv_rec.start_date IS NULL) THEN
        x_lrtv_rec.start_date := l_db_lrtv_rec.start_date;
      END IF;

      IF (x_lrtv_rec.end_date IS NULL) THEN
        x_lrtv_rec.end_date := l_db_lrtv_rec.end_date;
      END IF;

      IF (x_lrtv_rec.name IS NULL) THEN
        x_lrtv_rec.name := l_db_lrtv_rec.name;
      END IF;

      IF (x_lrtv_rec.description IS NULL) THEN
        x_lrtv_rec.description := l_db_lrtv_rec.description;
      END IF;

      IF (x_lrtv_rec.created_by IS NULL) THEN
        x_lrtv_rec.created_by := l_db_lrtv_rec.created_by;
      END IF;

      IF (x_lrtv_rec.creation_date IS NULL) THEN
        x_lrtv_rec.creation_date := l_db_lrtv_rec.creation_date;
      END IF;

      IF (x_lrtv_rec.attribute_category IS NULL) THEN
        x_lrtv_rec.attribute_category := l_db_lrtv_rec.attribute_category;
      END IF;

      IF (x_lrtv_rec.attribute1 IS NULL) THEN
        x_lrtv_rec.attribute1 := l_db_lrtv_rec.attribute1;
      END IF;

      IF (x_lrtv_rec.attribute2 IS NULL) THEN
        x_lrtv_rec.attribute2 := l_db_lrtv_rec.attribute2;
      END IF;

      IF (x_lrtv_rec.attribute3 IS NULL) THEN
        x_lrtv_rec.attribute3 := l_db_lrtv_rec.attribute3;
      END IF;

      IF (x_lrtv_rec.attribute4 IS NULL) THEN
        x_lrtv_rec.attribute4 := l_db_lrtv_rec.attribute4;
      END IF;

      IF (x_lrtv_rec.attribute5 IS NULL) THEN
        x_lrtv_rec.attribute5 := l_db_lrtv_rec.attribute5;
      END IF;

      IF (x_lrtv_rec.attribute6 IS NULL) THEN
        x_lrtv_rec.attribute6 := l_db_lrtv_rec.attribute6;
      END IF;

      IF (x_lrtv_rec.attribute7 IS NULL) THEN
        x_lrtv_rec.attribute7 := l_db_lrtv_rec.attribute7;
      END IF;

      IF (x_lrtv_rec.attribute8 IS NULL) THEN
        x_lrtv_rec.attribute8 := l_db_lrtv_rec.attribute8;
      END IF;

      IF (x_lrtv_rec.attribute9 IS NULL) THEN
        x_lrtv_rec.attribute9 := l_db_lrtv_rec.attribute9;
      END IF;

      IF (x_lrtv_rec.attribute10 IS NULL) THEN
        x_lrtv_rec.attribute10 := l_db_lrtv_rec.attribute10;
      END IF;

      IF (x_lrtv_rec.attribute11 IS NULL) THEN
        x_lrtv_rec.attribute11 := l_db_lrtv_rec.attribute11;
      END IF;

      IF (x_lrtv_rec.attribute12 IS NULL) THEN
        x_lrtv_rec.attribute12 := l_db_lrtv_rec.attribute12;
      END IF;

      IF (x_lrtv_rec.attribute13 IS NULL) THEN
        x_lrtv_rec.attribute13 := l_db_lrtv_rec.attribute13;
      END IF;

      IF (x_lrtv_rec.attribute14 IS NULL) THEN
        x_lrtv_rec.attribute14 := l_db_lrtv_rec.attribute14;
      END IF;

      IF (x_lrtv_rec.attribute15 IS NULL) THEN
        x_lrtv_rec.attribute15 := l_db_lrtv_rec.attribute15;
      END IF;

      IF (x_lrtv_rec.sts_code IS NULL) THEN
        x_lrtv_rec.sts_code := l_db_lrtv_rec.sts_code;
      END IF;

      IF (x_lrtv_rec.org_id IS NULL) THEN
        x_lrtv_rec.org_id := l_db_lrtv_rec.org_id;
      END IF;

      IF (x_lrtv_rec.currency_code IS NULL) THEN
        x_lrtv_rec.currency_code := l_db_lrtv_rec.currency_code;
      END IF;

      IF (x_lrtv_rec.lrs_type_code IS NULL) THEN
        x_lrtv_rec.lrs_type_code := l_db_lrtv_rec.lrs_type_code;
      END IF;

      IF (x_lrtv_rec.end_of_term_id IS NULL) THEN
        x_lrtv_rec.end_of_term_id := l_db_lrtv_rec.end_of_term_id;
      END IF;

      IF (x_lrtv_rec.orig_rate_set_id IS NULL) THEN
        x_lrtv_rec.orig_rate_set_id := l_db_lrtv_rec.orig_rate_set_id;
      END IF;


      RETURN l_return_status;
      EXCEPTION
        WHEN okl_api.g_exception_error THEN
          x_return_status := g_ret_sts_error;
        WHEN okl_api.g_exception_unexpected_error THEN
          x_return_status := g_ret_sts_unexp_error;
        WHEN OTHERS THEN
          okl_api.set_message(p_app_name     =>  g_app_name
                             ,p_msg_name     =>  g_db_error
                             ,p_token1       =>  g_prog_name_token
                             ,p_token1_value =>  l_api_name
                             ,p_token2       =>  g_sqlcode_token
                             ,p_token2_value =>  sqlcode
                             ,p_token3       =>  g_sqlerrm_token
                             ,p_token3_value =>  sqlerrm);
          x_return_status := g_ret_sts_unexp_error;
    END populate_new_record;

  BEGIN
    l_return_status := populate_new_record(p_lrtv_rec, l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out g miss values

    l_lrtv_rec := null_out_defaults(l_lrtv_rec);

    l_lrtv_rec.sfwt_flag := 'N';
    l_lrtv_rec.last_update_date := sysdate;
    l_lrtv_rec.last_updated_by := fnd_global.user_id;
    l_lrtv_rec.last_update_login := fnd_global.login_id;
    l_return_status := validate_attributes(l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    lock_row(p_api_version   =>  g_api_version
            ,p_init_msg_list =>  g_false
            ,x_return_status =>  l_return_status
            ,x_msg_count     =>  x_msg_count
            ,x_msg_data      =>  x_msg_data
            ,p_lrtv_rec      =>  l_lrtv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_lrtv_rec, l_lrt_rec);
    migrate(l_lrtv_rec, l_lrttl_rec);
    update_row(x_return_status =>  l_return_status
              ,p_lrt_rec       =>  l_lrt_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    update_row(x_return_status =>  l_return_status
              ,p_lrttl_rec     =>  l_lrttl_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    x_lrtv_rec := l_lrtv_rec;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END update_row;

  -------------------
  -- update_row (TBL)
  -------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type
                      ,x_lrtv_tbl          OUT NOCOPY  lrtv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrtv_tbl.COUNT > 0) THEN
      i := p_lrtv_tbl.FIRST;

      LOOP
        IF p_lrtv_tbl.EXISTS(i) THEN
          update_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrtv_rec      =>  p_lrtv_tbl(i)
                    ,x_lrtv_rec      =>  x_lrtv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrtv_tbl.LAST);
          i := p_lrtv_tbl.next(i);
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
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END update_row;

  -----------------
  -- delete_row (B)
  -----------------

  PROCEDURE delete_row(p_init_msg_list  IN             varchar2     DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrt_rec        IN             lrt_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (B)';

  BEGIN

    DELETE FROM okl_ls_rt_fctr_ents
    WHERE       lrt_id = p_lrt_rec.id;

    DELETE FROM okl_ls_rt_fctr_sets_b
    WHERE       id = p_lrt_rec.id;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END delete_row;

  ------------------
  -- delete_row (TL)
  ------------------

  PROCEDURE delete_row(p_init_msg_list  IN             varchar2       DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrttl_rec      IN             lrttl_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (TL)';

  BEGIN

    DELETE FROM okl_ls_rt_fctr_sets_tl
    WHERE       id = p_lrttl_rec.id;
    x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END delete_row;

  -------------------
  -- delete_row (REC)
  -------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (REC)';
    l_return_status          varchar2(1);
    l_lrtv_rec               lrtv_rec_type := p_lrtv_rec;
    l_lrttl_rec              lrttl_rec_type;
    l_lrt_rec                lrt_rec_type;

  BEGIN
    migrate(l_lrtv_rec, l_lrttl_rec);
    migrate(l_lrtv_rec, l_lrt_rec);
    delete_row(p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_lrttl_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    delete_row(p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_lrt_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END delete_row;

  -------------------
  -- delete_row (TBL)
  -------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrtv_tbl.COUNT > 0) THEN
      i := p_lrtv_tbl.FIRST;

      LOOP
        IF p_lrtv_tbl.EXISTS(i) THEN
          delete_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrtv_rec      =>  p_lrtv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrtv_tbl.LAST);
          i := p_lrtv_tbl.next(i);
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
        okl_api.set_message(p_app_name     =>  g_app_name
                           ,p_msg_name     =>  g_db_error
                           ,p_token1       =>  g_prog_name_token
                           ,p_token1_value =>  l_api_name
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        x_return_status := g_ret_sts_unexp_error;
  END delete_row;

END okl_lrt_pvt;

/
