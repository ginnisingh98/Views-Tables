--------------------------------------------------------
--  DDL for Package Body OKL_ETH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ETH_PVT" AS
/* $Header: OKLSETHB.pls 120.6 2006/07/13 12:55:30 adagur noship $ */

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

    DELETE FROM OKL_FE_EO_TERMS_ALL_TL t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_FE_EO_TERMS_ALL_B b
                           WHERE  b.end_of_term_id = t.end_of_term_id);

    UPDATE OKL_FE_EO_TERMS_ALL_TL t
    SET(end_of_term_desc) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.end_of_term_desc
                              FROM   OKL_FE_EO_TERMS_ALL_TL b
                              WHERE  b.end_of_term_id = t.end_of_term_id
                                 AND b.language = t.source_lang)
    WHERE  (t.end_of_term_id, t.language) IN(SELECT subt.end_of_term_id ,subt.language
           FROM   OKL_FE_EO_TERMS_ALL_TL subb ,OKL_FE_EO_TERMS_ALL_TL subt
           WHERE  subb.end_of_term_id = subt.end_of_term_id AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.end_of_term_desc <> subt.end_of_term_desc OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.end_of_term_desc IS NULL AND subt.end_of_term_desc IS NOT NULL)));

    INSERT INTO OKL_FE_EO_TERMS_ALL_TL
               (end_of_term_id
               ,language
               ,source_lang
               ,sfwt_flag
               ,end_of_term_desc)
                SELECT b.end_of_term_id
                      ,l.language_code
                      ,b.source_lang
                      ,b.sfwt_flag
                      ,b.end_of_term_desc
                FROM   OKL_FE_EO_TERMS_ALL_TL b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   OKL_FE_EO_TERMS_ALL_TL t
                                      WHERE  t.end_of_term_id = b.end_of_term_id AND t.language = l.language_code);

  END add_language;


  PROCEDURE validate_end_of_term_id(x_return_status    OUT NOCOPY VARCHAR2
                                   ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize the return status

    x_return_status := okl_api.g_ret_sts_success;

    -- END_OF_TERM_ID is a required field

    IF (p_ethv_rec.end_of_term_id IS NULL OR p_ethv_rec.end_of_term_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'END_OF_TERM_ID');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no proccessing required. Validation can continue with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_end_of_term_id;

  PROCEDURE validate_object_version_number(x_return_status    OUT NOCOPY VARCHAR2
                                          ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize the return status

    x_return_status := okl_api.g_ret_sts_success;

    -- object_version_number is a required field

    IF (p_ethv_rec.object_version_number IS NULL OR p_ethv_rec.object_version_number = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'object_version_number');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no proccessing required. Validation can continue with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_object_version_number;

  PROCEDURE validate_org_id(x_return_status    OUT NOCOPY VARCHAR2
                           ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize return status

    x_return_status := okc_api.g_ret_sts_success;

    -- check org id validity using the generic function okl_util.check_org_id()

    x_return_status := okl_util.check_org_id(p_ethv_rec.org_id);

    IF (x_return_status = okc_api.g_ret_sts_error) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'org_id');

      -- notify caller of an error

      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

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

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_org_id;

  PROCEDURE validate_currency_code(x_return_status    OUT NOCOPY VARCHAR2
                                  ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize return status

    x_return_status := okc_api.g_ret_sts_success;

    -- data is required

    IF (p_ethv_rec.currency_code IS NOT NULL) AND (p_ethv_rec.currency_code <> okc_api.g_miss_char) THEN

    x_return_status := okl_accounting_util.validate_currency_code(p_ethv_rec.currency_code);

    IF (x_return_status <> okl_api.g_true) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'currency_code');

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN
        x_return_status := okc_api.g_ret_sts_error;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_currency_code;

  PROCEDURE validate_eot_type_code(x_return_status    OUT NOCOPY VARCHAR2
                                  ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize return status

    x_return_status := okc_api.g_ret_sts_success;

    -- data is required

    IF (p_ethv_rec.eot_type_code IS NULL) OR (p_ethv_rec.eot_type_code = okc_api.g_miss_char) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'EOT_TYPE_CODE');

      -- notify caller of an error

      x_return_status := okc_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- Lookup Code Validation

    x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_RESIDUAL_TYPES'
                                                 ,p_lookup_code =>              p_ethv_rec.eot_type_code);

    IF (x_return_status = okc_api.g_ret_sts_error) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'EOT_TYPE_CODE');  -- notify caller of an error
      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      x_return_status := okc_api.g_ret_sts_unexp_error;
      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okl_api.g_ret_sts_unexp_error;
  END validate_eot_type_code;

  PROCEDURE validate_product_id(x_return_status    OUT NOCOPY VARCHAR2
                               ,p_ethv_rec      IN            okl_ethv_rec) IS

    CURSOR product_id_exists_csr IS
      SELECT 'x'
      FROM   okl_products_v
      WHERE  id = p_ethv_rec.product_id;
    l_dummy_var                  VARCHAR2(1) := '?';

  BEGIN

    -- initialize return status

    x_return_status := okc_api.g_ret_sts_success;

    -- data is required

    IF (p_ethv_rec.product_id IS NULL) OR (p_ethv_rec.product_id = okc_api.g_miss_num) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'product_id');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- enforce foreign key

    OPEN product_id_exists_csr;
    FETCH product_id_exists_csr INTO l_dummy_var ;
    CLOSE product_id_exists_csr;

    -- if l_dummy_var is still set to default, data was not found

    IF (l_dummy_var = '?') THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'product_id');

      -- notify caller of an error

      x_return_status := okc_api.g_ret_sts_error;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;

        -- verify that cursor was closed

        IF product_id_exists_csr%ISOPEN THEN
          CLOSE product_id_exists_csr;
        END IF;

  END validate_product_id;

  PROCEDURE validate_category_type_code(x_return_status    OUT NOCOPY VARCHAR2
                                       ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- initialize return status

    x_return_status := okc_api.g_ret_sts_success;

    -- data is required

    IF (p_ethv_rec.category_type_code IS NULL) OR (p_ethv_rec.category_type_code = okc_api.g_miss_char) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'CATEGORY_TYPE_CODE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    END IF;

    -- Lookup Code Validation

    x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_SOURCE_TYPES'
                                                 ,p_lookup_code =>              p_ethv_rec.category_type_code);

    IF (x_return_status = okc_api.g_ret_sts_error) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'CATEGORY_TYPE_CODE');  -- notify caller of an error
      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      x_return_status := okc_api.g_ret_sts_unexp_error;
      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_category_type_code;

  PROCEDURE validate_orig_end_of_term_id(x_return_status    OUT NOCOPY VARCHAR2
                                        ,p_ethv_rec      IN            okl_ethv_rec) IS

    CURSOR pos_exists_csr IS
      SELECT 'x'
      FROM   okl_fe_eo_terms_all_b
      WHERE  end_of_term_id = p_ethv_rec.orig_end_of_term_id;
    l_dummy_var                  VARCHAR2(1) := '?';

  BEGIN

    -- Initialize the return status to success

    x_return_status := okl_api.g_ret_sts_success;

    IF (p_ethv_rec.orig_end_of_term_id IS NOT NULL AND p_ethv_rec.orig_end_of_term_id <> okl_api.g_miss_num) THEN
      OPEN pos_exists_csr;
      FETCH pos_exists_csr INTO l_dummy_var ;
      CLOSE pos_exists_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'ORIG_END_OF_TERM_ID');

        -- notify caller of an error

        x_return_status := okc_api.g_ret_sts_error;
        RAISE g_exception_halt_validation;
      END IF;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;

        -- verify that cursor was closed

        IF pos_exists_csr%ISOPEN THEN
          CLOSE pos_exists_csr;
        END IF;

  END validate_orig_end_of_term_id;

  PROCEDURE validate_effective_from_date(x_return_status    OUT NOCOPY VARCHAR2
                                        ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- Initialize the return status to success

    x_return_status := okl_api.g_ret_sts_success;

    IF (p_ethv_rec.effective_from_date IS NULL OR p_ethv_rec.effective_from_date = okl_api.g_miss_date) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'EFFECTIVE_FROM_DATE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;
      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_effective_from_date;

  PROCEDURE validate_sts_code(x_return_status    OUT NOCOPY VARCHAR2
                             ,p_ethv_rec      IN            okl_ethv_rec) IS

  BEGIN

    -- Initialize the return status to success

    x_return_status := okl_api.g_ret_sts_success;

    -- Column is mandatory

    IF (p_ethv_rec.sts_code IS NULL OR p_ethv_rec.sts_code = okl_api.g_miss_char) THEN
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
                                                 ,p_lookup_code =>              p_ethv_rec.sts_code);

    IF (x_return_status = okc_api.g_ret_sts_error) THEN
      okc_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'sts_code');  -- notify caller of an error
      RAISE g_exception_halt_validation;
    ELSIF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN

      -- notify caller of an error

      x_return_status := okc_api.g_ret_sts_unexp_error;
      RAISE g_exception_halt_validation;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- no processing necessary;  validation can continue
        -- with the next column

        NULL;
      WHEN OTHERS THEN

        -- store SQL error message on message stack for caller

        okc_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_unexpected_error
                           ,p_token1       =>             g_sqlcode_token
                           ,p_token1_value =>             sqlcode
                           ,p_token2       =>             g_sqlerrm_token
                           ,p_token2_value =>             sqlerrm);

        -- notify caller of an UNEXPECTED error

        x_return_status := okc_api.g_ret_sts_unexp_error;
  END validate_sts_code;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_EO_TERMS_ALL_B
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ethb_rec      IN            okl_ethb_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_ethb_rec IS

    CURSOR posb_pk_csr(p_id IN NUMBER) IS
      SELECT end_of_term_id
            ,end_of_term_name
            ,object_version_number
            ,org_id
            ,currency_code
            ,eot_type_code
            ,product_id
            ,category_type_code
            ,orig_end_of_term_id
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
      FROM   okl_fe_eo_terms_all_b
      WHERE  okl_fe_eo_terms_all_b.end_of_term_id = p_id;
    l_ethb_pk                    posb_pk_csr%ROWTYPE;
    l_ethb_rec                   okl_ethb_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN posb_pk_csr(p_ethb_rec.end_of_term_id);
    FETCH posb_pk_csr INTO l_ethb_rec.end_of_term_id
                          ,l_ethb_rec.end_of_term_name
                          ,l_ethb_rec.object_version_number
                          ,l_ethb_rec.org_id
                          ,l_ethb_rec.currency_code
                          ,l_ethb_rec.eot_type_code
                          ,l_ethb_rec.product_id
                          ,l_ethb_rec.category_type_code
                          ,l_ethb_rec.orig_end_of_term_id
                          ,l_ethb_rec.sts_code
                          ,l_ethb_rec.effective_from_date
                          ,l_ethb_rec.effective_to_date
                          ,l_ethb_rec.attribute_category
                          ,l_ethb_rec.attribute1
                          ,l_ethb_rec.attribute2
                          ,l_ethb_rec.attribute3
                          ,l_ethb_rec.attribute4
                          ,l_ethb_rec.attribute5
                          ,l_ethb_rec.attribute6
                          ,l_ethb_rec.attribute7
                          ,l_ethb_rec.attribute8
                          ,l_ethb_rec.attribute9
                          ,l_ethb_rec.attribute10
                          ,l_ethb_rec.attribute11
                          ,l_ethb_rec.attribute12
                          ,l_ethb_rec.attribute13
                          ,l_ethb_rec.attribute14
                          ,l_ethb_rec.attribute15
                          ,l_ethb_rec.created_by
                          ,l_ethb_rec.creation_date
                          ,l_ethb_rec.last_updated_by
                          ,l_ethb_rec.last_update_date
                          ,l_ethb_rec.last_update_login ;
    x_no_data_found := posb_pk_csr%NOTFOUND;

    CLOSE posb_pk_csr;
    RETURN(l_ethb_rec);
  END get_rec;

  FUNCTION get_rec(p_ethb_rec IN okl_ethb_rec) RETURN okl_ethb_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_ethb_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec forOKL_FE_EO_TERMS_ALL_TL
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ethtl_rec     IN            okl_ethtl_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_ethtl_rec IS

    CURSOR postl_pk_csr(p_id       IN NUMBER
                       ,p_language IN VARCHAR2) IS
      SELECT end_of_term_id
            ,end_of_term_desc
            ,language
            ,source_lang
            ,sfwt_flag
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_eo_terms_all_tl
      WHERE  okl_fe_eo_terms_all_tl.end_of_term_id = p_id
         AND okl_fe_eo_terms_all_tl.language = p_language;
    l_ethtl_pk                   postl_pk_csr%ROWTYPE;
    l_ethtl_rec                  okl_ethtl_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN postl_pk_csr(p_ethtl_rec.end_of_term_id
                     ,p_ethtl_rec.language);
    FETCH postl_pk_csr INTO l_ethtl_rec.end_of_term_id
                           ,l_ethtl_rec.end_of_term_desc
                           ,l_ethtl_rec.language
                           ,l_ethtl_rec.source_lang
                           ,l_ethtl_rec.sfwt_flag
                           ,l_ethtl_rec.created_by
                           ,l_ethtl_rec.creation_date
                           ,l_ethtl_rec.last_updated_by
                           ,l_ethtl_rec.last_update_date
                           ,l_ethtl_rec.last_update_login ;
    x_no_data_found := postl_pk_csr%NOTFOUND;
    CLOSE postl_pk_csr;
    RETURN(l_ethtl_rec);
  END get_rec;

  FUNCTION get_rec(p_ethtl_rec IN okl_ethtl_rec) RETURN okl_ethtl_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_ethtl_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_EO_TERMS_V
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ethv_rec      IN            okl_ethv_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_ethv_rec IS

    CURSOR posv_pk_csr(p_id IN NUMBER) IS
      SELECT end_of_term_id
            ,object_version_number
            ,end_of_term_name
            ,end_of_term_desc
            ,org_id
            ,currency_code
            ,eot_type_code
            ,product_id
            ,category_type_code
            ,orig_end_of_term_id
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
      FROM   okl_fe_eo_terms_v
      WHERE  okl_fe_eo_terms_v.end_of_term_id = p_id;
    l_ethv_pk                    posv_pk_csr%ROWTYPE;
    l_ethv_rec                   okl_ethv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN posv_pk_csr(p_ethv_rec.end_of_term_id);
    FETCH posv_pk_csr INTO l_ethv_rec.end_of_term_id
                          ,l_ethv_rec.object_version_number
                          ,l_ethv_rec.end_of_term_name
                          ,l_ethv_rec.end_of_term_desc
                          ,l_ethv_rec.org_id
                          ,l_ethv_rec.currency_code
                          ,l_ethv_rec.eot_type_code
                          ,l_ethv_rec.product_id
                          ,l_ethv_rec.category_type_code
                          ,l_ethv_rec.orig_end_of_term_id
                          ,l_ethv_rec.sts_code
                          ,l_ethv_rec.effective_from_date
                          ,l_ethv_rec.effective_to_date
                          ,l_ethv_rec.attribute_category
                          ,l_ethv_rec.attribute1
                          ,l_ethv_rec.attribute2
                          ,l_ethv_rec.attribute3
                          ,l_ethv_rec.attribute4
                          ,l_ethv_rec.attribute5
                          ,l_ethv_rec.attribute6
                          ,l_ethv_rec.attribute7
                          ,l_ethv_rec.attribute8
                          ,l_ethv_rec.attribute9
                          ,l_ethv_rec.attribute10
                          ,l_ethv_rec.attribute11
                          ,l_ethv_rec.attribute12
                          ,l_ethv_rec.attribute13
                          ,l_ethv_rec.attribute14
                          ,l_ethv_rec.attribute15
                          ,l_ethv_rec.created_by
                          ,l_ethv_rec.creation_date
                          ,l_ethv_rec.last_updated_by
                          ,l_ethv_rec.last_update_date
                          ,l_ethv_rec.last_update_login ;
    x_no_data_found := posv_pk_csr%NOTFOUND;
    CLOSE posv_pk_csr;
    RETURN(l_ethv_rec);
  END get_rec;

  FUNCTION get_rec(p_ethv_rec IN okl_ethv_rec) RETURN okl_ethv_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_ethv_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure migrate
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from IN            okl_ethv_rec
                   ,p_to   IN OUT NOCOPY okl_ethb_rec) IS

  BEGIN
    p_to.end_of_term_id := p_from.end_of_term_id;
    p_to.end_of_term_name := p_from.end_of_term_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.eot_type_code := p_from.eot_type_code;
    p_to.product_id := p_from.product_id;
    p_to.category_type_code := p_from.category_type_code;
    p_to.orig_end_of_term_id := p_from.orig_end_of_term_id;
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

  PROCEDURE migrate(p_from IN            okl_ethb_rec
                   ,p_to   IN OUT NOCOPY okl_ethv_rec) IS

  BEGIN
    p_to.end_of_term_id := p_from.end_of_term_id;
    p_to.end_of_term_name := p_from.end_of_term_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.eot_type_code := p_from.eot_type_code;
    p_to.product_id := p_from.product_id;
    p_to.category_type_code := p_from.category_type_code;
    p_to.orig_end_of_term_id := p_from.orig_end_of_term_id;
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

  PROCEDURE migrate(p_from IN            okl_ethv_rec
                   ,p_to   IN OUT NOCOPY okl_ethtl_rec) IS

  BEGIN
    p_to.end_of_term_id := p_from.end_of_term_id;
    p_to.end_of_term_desc := p_from.end_of_term_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate(p_from IN            okl_ethtl_rec
                   ,p_to   IN OUT NOCOPY okl_ethv_rec) IS

  BEGIN
    p_to.end_of_term_id := p_from.end_of_term_id;
    p_to.end_of_term_desc := p_from.end_of_term_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  FUNCTION null_out_defaults(p_ethv_rec IN okl_ethv_rec) RETURN okl_ethv_rec IS
    l_ethv_rec                   okl_ethv_rec := p_ethv_rec;

  BEGIN

    IF (l_ethv_rec.end_of_term_id = okl_api.g_miss_num) THEN
      l_ethv_rec.end_of_term_id := NULL;
    END IF;

    IF (l_ethv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_ethv_rec.object_version_number := NULL;
    END IF;

    IF (l_ethv_rec.end_of_term_name = okl_api.g_miss_char) THEN
      l_ethv_rec.end_of_term_name := NULL;
    END IF;

    IF (l_ethv_rec.end_of_term_desc = okl_api.g_miss_char) THEN
      l_ethv_rec.end_of_term_desc := NULL;
    END IF;

    IF (l_ethv_rec.org_id = okl_api.g_miss_num) THEN
      l_ethv_rec.org_id := NULL;
    END IF;

    IF (l_ethv_rec.currency_code = okl_api.g_miss_char) THEN
      l_ethv_rec.currency_code := NULL;
    END IF;

    IF (l_ethv_rec.eot_type_code = okl_api.g_miss_char) THEN
      l_ethv_rec.eot_type_code := NULL;
    END IF;

    IF (l_ethv_rec.product_id = okl_api.g_miss_num) THEN
      l_ethv_rec.product_id := NULL;
    END IF;

    IF (l_ethv_rec.category_type_code = okl_api.g_miss_char) THEN
      l_ethv_rec.category_type_code := NULL;
    END IF;

    IF (l_ethv_rec.orig_end_of_term_id = okl_api.g_miss_num) THEN
      l_ethv_rec.orig_end_of_term_id := NULL;
    END IF;

    IF (l_ethv_rec.sts_code = okl_api.g_miss_char) THEN
      l_ethv_rec.sts_code := NULL;
    END IF;

    IF (l_ethv_rec.effective_from_date = okl_api.g_miss_date) THEN
      l_ethv_rec.effective_from_date := NULL;
    END IF;

    IF (l_ethv_rec.effective_to_date = okl_api.g_miss_date) THEN
      l_ethv_rec.effective_to_date := NULL;
    END IF;

    IF (l_ethv_rec.attribute_category = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute_category := NULL;
    END IF;

    IF (l_ethv_rec.attribute1 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute1 := NULL;
    END IF;

    IF (l_ethv_rec.attribute2 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute2 := NULL;
    END IF;

    IF (l_ethv_rec.attribute3 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute3 := NULL;
    END IF;

    IF (l_ethv_rec.attribute4 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute4 := NULL;
    END IF;

    IF (l_ethv_rec.attribute5 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute5 := NULL;
    END IF;

    IF (l_ethv_rec.attribute6 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute6 := NULL;
    END IF;

    IF (l_ethv_rec.attribute7 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute7 := NULL;
    END IF;

    IF (l_ethv_rec.attribute8 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute8 := NULL;
    END IF;

    IF (l_ethv_rec.attribute9 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute9 := NULL;
    END IF;

    IF (l_ethv_rec.attribute10 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute10 := NULL;
    END IF;

    IF (l_ethv_rec.attribute11 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute11 := NULL;
    END IF;

    IF (l_ethv_rec.attribute12 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute12 := NULL;
    END IF;

    IF (l_ethv_rec.attribute13 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute13 := NULL;
    END IF;

    IF (l_ethv_rec.attribute14 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute14 := NULL;
    END IF;

    IF (l_ethv_rec.attribute15 = okl_api.g_miss_char) THEN
      l_ethv_rec.attribute15 := NULL;
    END IF;

    IF (l_ethv_rec.created_by = okl_api.g_miss_num) THEN
      l_ethv_rec.created_by := NULL;
    END IF;

    IF (l_ethv_rec.creation_date = okl_api.g_miss_date) THEN
      l_ethv_rec.creation_date := NULL;
    END IF;

    IF (l_ethv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_ethv_rec.last_updated_by := NULL;
    END IF;

    IF (l_ethv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_ethv_rec.last_update_date := NULL;
    END IF;

    IF (l_ethv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_ethv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ethv_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN NUMBER IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_attributes(p_ethv_rec IN okl_ethv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- validate the id

    validate_end_of_term_id(x_return_status =>            l_return_status
                           ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_object_version_number(x_return_status =>            l_return_status
                                  ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_org_id(x_return_status =>            l_return_status
                   ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_currency_code(x_return_status =>            l_return_status
                          ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_eot_type_code(x_return_status =>            l_return_status
                          ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_product_id(x_return_status =>            l_return_status
                       ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_category_type_code(x_return_status =>            l_return_status
                               ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_orig_end_of_term_id(x_return_status =>            l_return_status
                                ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_sts_code(x_return_status =>            l_return_status
                     ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    validate_effective_from_date(x_return_status =>            l_return_status
                                ,p_ethv_rec      =>            p_ethv_rec);

    -- store the highest degree of error

    IF (l_return_status <> okc_api.g_ret_sts_success) THEN
      IF (x_return_status <> okc_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    RETURN(x_return_status);
  END validate_attributes;

  FUNCTION validate_record(p_ethv_rec IN okl_ethv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN
    IF (p_ethv_rec.effective_to_date IS NOT NULL) THEN
      IF (p_ethv_rec.effective_from_date > p_ethv_rec.effective_to_date) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             'OKL_INVALID_EFFECTIVE_TO');
        x_return_status := okl_api.g_ret_sts_error;
       END IF;
      END IF;
    RETURN(x_return_status);
  END validate_record;

  PROCEDURE lock_row(p_init_msg_list IN            VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2
                    ,p_ethb_rec      IN            okl_ethb_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_ethb_rec IN okl_ethb_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_eo_terms_all_b
      WHERE         end_of_term_id = p_ethb_rec.end_of_term_id
                AND object_version_number = p_ethb_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_ethb_rec IN okl_ethb_rec) IS
      SELECT object_version_number
      FROM   okl_fe_eo_terms_all_b
      WHERE  end_of_term_id = p_ethb_rec.end_of_term_id;
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
      OPEN lock_csr(p_ethb_rec);
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
      OPEN lchk_csr(p_ethb_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_ethb_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_ethb_rec.object_version_number THEN
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
                    ,p_ethtl_rec     IN            okl_ethtl_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_ethtl_rec IN okl_ethtl_rec) IS
      SELECT     *
      FROM       okl_fe_eo_terms_all_tl
      WHERE      end_of_term_id = p_ethtl_rec.end_of_term_id
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
      OPEN lock_csr(p_ethtl_rec);
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
                    ,p_ethv_rec      IN            okl_ethv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'V_lock_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethb_rec                    okl_ethb_rec;
    l_ethtl_rec                   okl_ethtl_rec;

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

    migrate(p_ethv_rec
           ,l_ethb_rec);
    migrate(p_ethv_rec
           ,l_ethtl_rec);

    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------

    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_ethb_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_ethtl_rec);

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
                    ,p_ethv_tbl      IN            okl_ethv_tbl) IS
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

    IF (p_ethv_tbl.COUNT > 0) THEN
      i := p_ethv_tbl.FIRST;

      LOOP
        lock_row(p_api_version   =>            p_api_version
                ,p_init_msg_list =>            okl_api.g_false
                ,x_return_status =>            x_return_status
                ,x_msg_count     =>            x_msg_count
                ,x_msg_data      =>            x_msg_data
                ,p_ethv_rec      =>            p_ethv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_ethv_tbl.LAST);
        i := p_ethv_tbl.next(i);
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

  --------------------------------------------------------------------------------
  -- Procedure insert_row_b
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethb_rec      IN            okl_ethb_rec
                      ,x_ethb_rec         OUT NOCOPY okl_ethb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_ethb_rec                    okl_ethb_rec := p_ethb_rec;

    FUNCTION set_attributes(p_ethb_rec IN            okl_ethb_rec
                           ,x_ethb_rec    OUT NOCOPY okl_ethb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethb_rec := p_ethb_rec;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_ethb_rec
                                     ,l_ethb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    INSERT INTO okl_fe_eo_terms_all_b
               (end_of_term_id
               ,end_of_term_name
               ,object_version_number
               ,org_id
               ,currency_code
               ,eot_type_code
               ,product_id
               ,category_type_code
               ,orig_end_of_term_id
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
    VALUES     (l_ethb_rec.end_of_term_id
               ,l_ethb_rec.end_of_term_name
               ,l_ethb_rec.object_version_number
               ,l_ethb_rec.org_id
               ,l_ethb_rec.currency_code
               ,l_ethb_rec.eot_type_code
               ,l_ethb_rec.product_id
               ,l_ethb_rec.category_type_code
               ,l_ethb_rec.orig_end_of_term_id
               ,l_ethb_rec.sts_code
               ,l_ethb_rec.effective_from_date
               ,l_ethb_rec.effective_to_date
               ,l_ethb_rec.attribute_category
               ,l_ethb_rec.attribute1
               ,l_ethb_rec.attribute2
               ,l_ethb_rec.attribute3
               ,l_ethb_rec.attribute4
               ,l_ethb_rec.attribute5
               ,l_ethb_rec.attribute6
               ,l_ethb_rec.attribute7
               ,l_ethb_rec.attribute8
               ,l_ethb_rec.attribute9
               ,l_ethb_rec.attribute10
               ,l_ethb_rec.attribute11
               ,l_ethb_rec.attribute12
               ,l_ethb_rec.attribute13
               ,l_ethb_rec.attribute14
               ,l_ethb_rec.attribute15
               ,l_ethb_rec.created_by
               ,l_ethb_rec.creation_date
               ,l_ethb_rec.last_updated_by
               ,l_ethb_rec.last_update_date
               ,l_ethb_rec.last_update_login);

    --Set OUT Values

    x_ethb_rec := l_ethb_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethtl_rec     IN            okl_ethtl_rec
                      ,x_ethtl_rec        OUT NOCOPY okl_ethtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethtl_rec                   okl_ethtl_rec := p_ethtl_rec;

    CURSOR get_languages IS
      SELECT *
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B');

    FUNCTION set_attributes(p_ethtl_rec IN            okl_ethtl_rec
                           ,x_ethtl_rec    OUT NOCOPY okl_ethtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethtl_rec := p_ethtl_rec;
      x_ethtl_rec.sfwt_flag := 'N';
      x_ethtl_rec.language := USERENV('LANG');
      x_ethtl_rec.source_lang := USERENV('LANG');
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_ethtl_rec
                                     ,l_ethtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    FOR l_lang_rec IN get_languages LOOP
      l_ethtl_rec.language := l_lang_rec.language_code;

      INSERT INTO okl_fe_eo_terms_all_tl
                 (end_of_term_id
                 ,end_of_term_desc
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (l_ethtl_rec.end_of_term_id
                 ,l_ethtl_rec.end_of_term_desc
                 ,l_ethtl_rec.language
                 ,l_ethtl_rec.source_lang
                 ,l_ethtl_rec.sfwt_flag
                 ,l_ethtl_rec.created_by
                 ,l_ethtl_rec.creation_date
                 ,l_ethtl_rec.last_updated_by
                 ,l_ethtl_rec.last_update_date
                 ,l_ethtl_rec.last_update_login);

    END LOOP;

    --Set OUT Values

    x_ethtl_rec := l_ethtl_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec
                      ,x_ethv_rec         OUT NOCOPY okl_ethv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethv_rec                    okl_ethv_rec;
    l_def_ethv_rec                okl_ethv_rec;
    l_ethb_rec                    okl_ethb_rec;
    lx_ethb_rec                   okl_ethb_rec;
    l_ethtl_rec                   okl_ethtl_rec;
    lx_ethtl_rec                  okl_ethtl_rec;

    FUNCTION fill_who_columns(p_ethv_rec IN okl_ethv_rec) RETURN okl_ethv_rec IS
      l_ethv_rec                   okl_ethv_rec := p_ethv_rec;

    BEGIN
      l_ethv_rec.creation_date := SYSDATE;
      l_ethv_rec.created_by := fnd_global.user_id;
      l_ethv_rec.last_update_date := SYSDATE;
      l_ethv_rec.last_updated_by := fnd_global.user_id;
      l_ethv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ethv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_ethv_rec IN            okl_ethv_rec
                           ,x_ethv_rec    OUT NOCOPY okl_ethv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethv_rec := p_ethv_rec;
      x_ethv_rec.object_version_number := 1;
      x_ethv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_ethv_rec := null_out_defaults(p_ethv_rec);

    -- Set Primary key value

    l_ethv_rec.end_of_term_id := get_seq_id;

    --Setting Item Attributes

    l_return_status := set_attributes(l_ethv_rec
                                     ,l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_def_ethv_rec := fill_who_columns(l_def_ethv_rec);
    l_return_status := validate_attributes(l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(l_def_ethv_rec
           ,l_ethb_rec);
    migrate(l_def_ethv_rec
           ,l_ethtl_rec);
    insert_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethb_rec
              ,lx_ethb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(lx_ethb_rec
           ,l_def_ethv_rec);
    insert_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethtl_rec
              ,lx_ethtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(lx_ethtl_rec
           ,l_def_ethv_rec);

    --Set OUT Values

    x_ethv_rec := l_def_ethv_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl
                      ,x_ethv_tbl         OUT NOCOPY okl_ethv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okc_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ethv_tbl.COUNT > 0) THEN
      i := p_ethv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okc_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_ethv_rec      =>            p_ethv_tbl(i)
                  ,x_ethv_rec      =>            x_ethv_tbl(i));
        IF x_return_status <> okc_api.g_ret_sts_success THEN
          IF l_overall_status <> okc_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ethv_tbl.LAST);
        i := p_ethv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethb_rec      IN            okl_ethb_rec
                      ,x_ethb_rec         OUT NOCOPY okl_ethb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_ethb_rec                    okl_ethb_rec := p_ethb_rec;
    l_def_ethb_rec                okl_ethb_rec;
    l_row_notfound                BOOLEAN      := true;

    FUNCTION set_attributes(p_ethb_rec IN            okl_ethb_rec
                           ,x_ethb_rec    OUT NOCOPY okl_ethb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethb_rec := p_ethb_rec;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_ethb_rec
                                     ,l_def_ethb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    UPDATE okl_fe_eo_terms_all_b
    SET    end_of_term_id = l_def_ethb_rec.end_of_term_id
          ,end_of_term_name = l_def_ethb_rec.end_of_term_name
          ,object_version_number = l_def_ethb_rec.object_version_number + 1
          ,org_id = l_def_ethb_rec.org_id
          ,currency_code = l_def_ethb_rec.currency_code
          ,eot_type_code = l_def_ethb_rec.eot_type_code
          ,product_id = l_def_ethb_rec.product_id
          ,category_type_code = l_def_ethb_rec.category_type_code
          ,orig_end_of_term_id = l_def_ethb_rec.orig_end_of_term_id
          ,sts_code = l_def_ethb_rec.sts_code
          ,effective_from_date = l_def_ethb_rec.effective_from_date
          ,effective_to_date = l_def_ethb_rec.effective_to_date
          ,attribute_category = l_def_ethb_rec.attribute_category
          ,attribute1 = l_def_ethb_rec.attribute1
          ,attribute2 = l_def_ethb_rec.attribute2
          ,attribute3 = l_def_ethb_rec.attribute3
          ,attribute4 = l_def_ethb_rec.attribute4
          ,attribute5 = l_def_ethb_rec.attribute5
          ,attribute6 = l_def_ethb_rec.attribute6
          ,attribute7 = l_def_ethb_rec.attribute7
          ,attribute8 = l_def_ethb_rec.attribute8
          ,attribute9 = l_def_ethb_rec.attribute9
          ,attribute10 = l_def_ethb_rec.attribute10
          ,attribute11 = l_def_ethb_rec.attribute11
          ,attribute12 = l_def_ethb_rec.attribute12
          ,attribute13 = l_def_ethb_rec.attribute13
          ,attribute14 = l_def_ethb_rec.attribute14
          ,attribute15 = l_def_ethb_rec.attribute15
          ,created_by = l_def_ethb_rec.created_by
          ,creation_date = l_def_ethb_rec.creation_date
          ,last_updated_by = l_def_ethb_rec.last_updated_by
          ,last_update_date = l_def_ethb_rec.last_update_date
          ,last_update_login = l_def_ethb_rec.last_update_login
    WHERE  end_of_term_id = l_def_ethb_rec.end_of_term_id;

    --Set OUT Values

    x_ethb_rec := l_ethb_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethtl_rec     IN            okl_ethtl_rec
                      ,x_ethtl_rec        OUT NOCOPY okl_ethtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'update_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethtl_rec                   okl_ethtl_rec := p_ethtl_rec;
    l_def_ethtl_rec               okl_ethtl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_ethtl_rec IN            okl_ethtl_rec
                           ,x_ethtl_rec    OUT NOCOPY okl_ethtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethtl_rec := p_ethtl_rec;
      x_ethtl_rec.language := USERENV('LANG');
      x_ethtl_rec.source_lang := USERENV('LANG');
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_ethtl_rec
                                     ,l_def_ethtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    UPDATE okl_fe_eo_terms_all_tl
    SET    end_of_term_id = l_def_ethtl_rec.end_of_term_id
          ,end_of_term_desc = l_def_ethtl_rec.end_of_term_desc
          ,language = l_def_ethtl_rec.language
          ,source_lang = l_def_ethtl_rec.source_lang
          ,sfwt_flag = l_def_ethtl_rec.sfwt_flag
          ,created_by = l_def_ethtl_rec.created_by
          ,creation_date = l_def_ethtl_rec.creation_date
          ,last_updated_by = l_def_ethtl_rec.last_updated_by
          ,last_update_date = l_def_ethtl_rec.last_update_date
          ,last_update_login = l_def_ethtl_rec.last_update_login
    WHERE  end_of_term_id = l_def_ethtl_rec.end_of_term_id
       AND language = l_def_ethtl_rec.language;

    UPDATE okl_fe_eo_terms_all_tl
    SET    sfwt_flag = 'Y'
    WHERE  end_of_term_id = l_def_ethtl_rec.end_of_term_id
       AND source_lang <> USERENV('LANG');

    --Set OUT Values

    x_ethtl_rec := l_ethtl_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec
                      ,x_ethv_rec         OUT NOCOPY okl_ethv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethv_rec                    okl_ethv_rec  := p_ethv_rec;
    l_def_ethv_rec                okl_ethv_rec;
    lx_ethv_rec                   okl_ethv_rec;
    l_ethb_rec                    okl_ethb_rec;
    lx_ethb_rec                   okl_ethb_rec;
    l_ethtl_rec                   okl_ethtl_rec;
    lx_ethtl_rec                  okl_ethtl_rec;

    FUNCTION fill_who_columns(p_ethv_rec IN okl_ethv_rec) RETURN okl_ethv_rec IS
      l_ethv_rec                   okl_ethv_rec := p_ethv_rec;

    BEGIN
      l_ethv_rec.last_update_date := SYSDATE;
      l_ethv_rec.last_updated_by := fnd_global.user_id;
      l_ethv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_ethv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_ethv_rec IN            okl_ethv_rec
                                ,x_ethv_rec    OUT NOCOPY okl_ethv_rec) RETURN VARCHAR2 IS
      l_ethv_rec                   okl_ethv_rec;
      l_row_notfound               BOOLEAN      := true;
      l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

    BEGIN
      x_ethv_rec := p_ethv_rec;

      --Get current database values

      l_ethv_rec := get_rec(p_ethv_rec
                           ,l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_ethv_rec.end_of_term_id IS NULL) THEN
        x_ethv_rec.end_of_term_id := l_ethv_rec.end_of_term_id;
      END IF;

      IF (x_ethv_rec.object_version_number IS NULL) THEN
        x_ethv_rec.object_version_number := l_ethv_rec.object_version_number;
      END IF;

      IF (x_ethv_rec.end_of_term_name IS NULL) THEN
        x_ethv_rec.end_of_term_name := l_ethv_rec.end_of_term_name;
      END IF;

      IF (x_ethv_rec.end_of_term_desc IS NULL) THEN
        x_ethv_rec.end_of_term_desc := l_ethv_rec.end_of_term_desc;
      END IF;

      IF (x_ethv_rec.org_id IS NULL) THEN
        x_ethv_rec.org_id := l_ethv_rec.org_id;
      END IF;

      IF (x_ethv_rec.currency_code IS NULL) THEN
        x_ethv_rec.currency_code := l_ethv_rec.currency_code;
      END IF;

      IF (x_ethv_rec.eot_type_code IS NULL) THEN
        x_ethv_rec.eot_type_code := l_ethv_rec.eot_type_code;
      END IF;

      IF (x_ethv_rec.product_id IS NULL) THEN
        x_ethv_rec.product_id := l_ethv_rec.product_id;
      END IF;

      IF (x_ethv_rec.category_type_code IS NULL) THEN
        x_ethv_rec.category_type_code := l_ethv_rec.category_type_code;
      END IF;

      IF (x_ethv_rec.orig_end_of_term_id IS NULL) THEN
        x_ethv_rec.orig_end_of_term_id := l_ethv_rec.orig_end_of_term_id;
      END IF;

      IF (x_ethv_rec.sts_code IS NULL) THEN
        x_ethv_rec.sts_code := l_ethv_rec.sts_code;
      END IF;

      IF (x_ethv_rec.effective_from_date IS NULL) THEN
        x_ethv_rec.effective_from_date := l_ethv_rec.effective_from_date;
      END IF;

      IF (x_ethv_rec.effective_to_date IS NULL) THEN
        x_ethv_rec.effective_to_date := l_ethv_rec.effective_to_date;
      END IF;

      IF (x_ethv_rec.attribute_category IS NULL) THEN
        x_ethv_rec.attribute_category := l_ethv_rec.attribute_category;
      END IF;

      IF (x_ethv_rec.attribute1 IS NULL) THEN
        x_ethv_rec.attribute1 := l_ethv_rec.attribute1;
      END IF;

      IF (x_ethv_rec.attribute2 IS NULL) THEN
        x_ethv_rec.attribute2 := l_ethv_rec.attribute2;
      END IF;

      IF (x_ethv_rec.attribute3 IS NULL) THEN
        x_ethv_rec.attribute3 := l_ethv_rec.attribute3;
      END IF;

      IF (x_ethv_rec.attribute4 IS NULL) THEN
        x_ethv_rec.attribute4 := l_ethv_rec.attribute4;
      END IF;

      IF (x_ethv_rec.attribute5 IS NULL) THEN
        x_ethv_rec.attribute5 := l_ethv_rec.attribute5;
      END IF;

      IF (x_ethv_rec.attribute6 IS NULL) THEN
        x_ethv_rec.attribute6 := l_ethv_rec.attribute6;
      END IF;

      IF (x_ethv_rec.attribute7 IS NULL) THEN
        x_ethv_rec.attribute7 := l_ethv_rec.attribute7;
      END IF;

      IF (x_ethv_rec.attribute8 IS NULL) THEN
        x_ethv_rec.attribute8 := l_ethv_rec.attribute8;
      END IF;

      IF (x_ethv_rec.attribute9 IS NULL) THEN
        x_ethv_rec.attribute9 := l_ethv_rec.attribute9;
      END IF;

      IF (x_ethv_rec.attribute10 IS NULL) THEN
        x_ethv_rec.attribute10 := l_ethv_rec.attribute10;
      END IF;

      IF (x_ethv_rec.attribute11 IS NULL) THEN
        x_ethv_rec.attribute11 := l_ethv_rec.attribute11;
      END IF;

      IF (x_ethv_rec.attribute12 IS NULL) THEN
        x_ethv_rec.attribute12 := l_ethv_rec.attribute12;
      END IF;

      IF (x_ethv_rec.attribute13 IS NULL) THEN
        x_ethv_rec.attribute13 := l_ethv_rec.attribute13;
      END IF;

      IF (x_ethv_rec.attribute14 IS NULL) THEN
        x_ethv_rec.attribute14 := l_ethv_rec.attribute14;
      END IF;

      IF (x_ethv_rec.attribute15 IS NULL) THEN
        x_ethv_rec.attribute15 := l_ethv_rec.attribute15;
      END IF;

      IF (x_ethv_rec.created_by IS NULL) THEN
        x_ethv_rec.created_by := l_ethv_rec.created_by;
      END IF;

      IF (x_ethv_rec.creation_date IS NULL) THEN
        x_ethv_rec.creation_date := l_ethv_rec.creation_date;
      END IF;

      IF (x_ethv_rec.last_updated_by IS NULL) THEN
        x_ethv_rec.last_updated_by := l_ethv_rec.last_updated_by;
      END IF;

      IF (x_ethv_rec.last_update_date IS NULL) THEN
        x_ethv_rec.last_update_date := l_ethv_rec.last_update_date;
      END IF;

      IF (x_ethv_rec.last_update_login IS NULL) THEN
        x_ethv_rec.last_update_login := l_ethv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_ethv_rec IN            okl_ethv_rec
                           ,x_ethv_rec    OUT NOCOPY okl_ethv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethv_rec := p_ethv_rec;
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(l_ethv_rec
                                     ,lx_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_return_status := populate_new_record(lx_ethv_rec
                                          ,l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_def_ethv_rec := null_out_defaults(l_def_ethv_rec);
    l_def_ethv_rec := fill_who_columns(l_def_ethv_rec);
    l_return_status := validate_attributes(l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --lock the row

    lock_row(p_api_version   =>            l_api_version
            ,p_init_msg_list =>            okl_api.g_false
            ,x_return_status =>            l_return_status
            ,x_msg_count     =>            x_msg_count
            ,x_msg_data      =>            x_msg_data
            ,p_ethv_rec      =>            l_def_ethv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_def_ethv_rec
           ,l_ethb_rec);
    migrate(l_def_ethv_rec
           ,l_ethtl_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethb_rec
              ,lx_ethb_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(lx_ethb_rec
           ,l_def_ethv_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethtl_rec
              ,lx_ethtl_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(lx_ethtl_rec
           ,l_def_ethv_rec);

    --Set OUT Values

    x_ethv_rec := l_def_ethv_rec;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl
                      ,x_ethv_tbl         OUT NOCOPY okl_ethv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okc_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ethv_tbl.COUNT > 0) THEN
      i := p_ethv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okc_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_ethv_rec      =>            p_ethv_tbl(i)
                  ,x_ethv_rec      =>            x_ethv_tbl(i));
        IF x_return_status <> okc_api.g_ret_sts_success THEN
          IF l_overall_status <> okc_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ethv_tbl.LAST);
        i := p_ethv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethb_rec      IN            okl_ethb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_ethb_rec                    okl_ethb_rec := p_ethb_rec;
    l_row_notfound                BOOLEAN      := true;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_eo_terms_all_b
    WHERE       end_of_term_id = l_ethb_rec.end_of_term_id;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2      DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethtl_rec     IN            okl_ethtl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethtl_rec                   okl_ethtl_rec := p_ethtl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_ethtl_rec IN            okl_ethtl_rec
                           ,x_ethtl_rec    OUT NOCOPY okl_ethtl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okc_api.g_ret_sts_success;

    BEGIN
      x_ethtl_rec := p_ethtl_rec;
      x_ethtl_rec.language := USERENV('LANG');
      x_ethtl_rec.source_lang := USERENV('LANG');
      RETURN(l_return_status);
    END set_attributes;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    --Setting Item Attributes

    l_return_status := set_attributes(p_ethtl_rec
                                     ,l_ethtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_eo_terms_all_tl
    WHERE       end_of_term_id = l_ethtl_rec.end_of_term_id;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_ethv_rec                    okl_ethv_rec  := p_ethv_rec;
    l_ethb_rec                    okl_ethb_rec;
    l_ethtl_rec                   okl_ethtl_rec;

  BEGIN
    l_return_status := okc_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    migrate(l_ethv_rec
           ,l_ethb_rec);
    migrate(l_ethv_rec
           ,l_ethtl_rec);
    delete_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    delete_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ethtl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okc_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okc_api.g_exception_error;
    END IF;
    okc_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okc_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_ethv_tbl.COUNT > 0) THEN
      i := p_ethv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okc_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_ethv_rec      =>            p_ethv_tbl(i));
        IF x_return_status <> okc_api.g_ret_sts_success THEN
          IF l_overall_status <> okc_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_ethv_tbl.LAST);
        i := p_ethv_tbl.next(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

    EXCEPTION
      WHEN g_exception_halt_validation THEN

        -- No action necessary. Validation can continue to next attribute/column

        NULL;
      WHEN okc_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okc_api.g_exception_unexpected_error THEN
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

END okl_eth_pvt;

/
