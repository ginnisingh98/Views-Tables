--------------------------------------------------------
--  DDL for Package Body OKL_SRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SRT_PVT" AS
/* $Header: OKLSSRTB.pls 120.5 2006/07/13 13:03:40 adagur noship $ */

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

    DELETE FROM OKL_FE_STD_RT_TMP_ALL_TL t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_FE_STD_RT_TMP_ALL_B b
                           WHERE  b.std_rate_tmpl_id = t.std_rate_tmpl_id);

    UPDATE OKL_FE_STD_RT_TMP_ALL_TL t
    SET(template_desc) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.template_desc
                              FROM   OKL_FE_STD_RT_TMP_ALL_TL b
                              WHERE  b.std_rate_tmpl_id = t.std_rate_tmpl_id
                                 AND b.language = t.source_lang)
    WHERE  (t.std_rate_tmpl_id, t.language) IN(SELECT subt.std_rate_tmpl_id ,subt.language
           FROM   OKL_FE_STD_RT_TMP_ALL_TL subb ,OKL_FE_STD_RT_TMP_ALL_TL subt
           WHERE  subb.std_rate_tmpl_id = subt.std_rate_tmpl_id AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.template_desc <> subt.template_desc OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.template_desc IS NULL AND subt.template_desc IS NOT NULL)));

    INSERT INTO OKL_FE_STD_RT_TMP_ALL_TL
               (std_rate_tmpl_id
               ,language
               ,source_lang
               ,sfwt_flag
               ,template_desc)
                SELECT b.std_rate_tmpl_id
                      ,l.language_code
                      ,b.source_lang
                      ,b.sfwt_flag
                      ,b.template_desc
                FROM   OKL_FE_STD_RT_TMP_ALL_TL b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   OKL_FE_STD_RT_TMP_ALL_TL t
                                      WHERE  t.std_rate_tmpl_id = b.std_rate_tmpl_id AND t.language = l.language_code);

  END add_language;

  -- validation of Standard Rate Template Id

  FUNCTION validate_std_rate_tmpl_id(p_srt_id IN NUMBER) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- STD_RATE_TMPL_ID is a required field

    IF (p_srt_id IS NULL OR p_srt_id = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'STD_RATE_TMPL_ID');

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
  END validate_std_rate_tmpl_id;

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

  FUNCTION validate_orig_std_rate_tmpl_id(p_orig_srt_id IN NUMBER) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    CURSOR srt_exists_csr IS
      SELECT 'x'
      FROM   okl_fe_std_rt_tmp_all_b
      WHERE  std_rate_tmpl_id = p_orig_srt_id;
    l_dummy_var                  VARCHAR2(1) := '?';

  BEGIN

    IF (p_orig_srt_id IS NOT NULL AND p_orig_srt_id <> okl_api.g_miss_num) THEN
      OPEN srt_exists_csr;
      FETCH srt_exists_csr INTO l_dummy_var ;
      CLOSE srt_exists_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'ORIG_STD_RATE_TMPL_ID');

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

        IF srt_exists_csr%ISOPEN THEN
          CLOSE srt_exists_csr;
        END IF;
        RETURN x_return_status;
  END validate_orig_std_rate_tmpl_id;

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

  FUNCTION validate_srt_rate(p_srt_rate IN NUMBER) RETURN VARCHAR2 IS

    -- initialize the return status

    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_srt_rate IS NULL OR p_srt_rate = okl_api.g_miss_num) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'SRT_RATE');

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
  END validate_srt_rate;

  FUNCTION validate_rate_card_yn(p_rate_card_yn IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_rate_card_yn IS NULL) OR (p_rate_card_yn = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'RATE_CARD_YN');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    ELSE

      -- Lookup Code Validation

      x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_YES_NO'
                                                   ,p_lookup_code =>              p_rate_card_yn);
      IF (x_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'RATE_CARD_YN');  -- notify caller of an error
        RAISE g_exception_halt_validation;
      ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

        -- notify caller of an error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RAISE g_exception_halt_validation;
      END IF;
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
  END validate_rate_card_yn;

  FUNCTION validate_pricing_engine_code(p_pricing_engine_code IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_pricing_engine_code IS NULL) OR (p_pricing_engine_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'PRICING_ENGINE_CODE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    ELSE

      -- Lookup Code Validation

      x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_PRICING_ENGINE'
                                                   ,p_lookup_code =>              p_pricing_engine_code);
      IF (x_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'PRICING_ENGINE_CODE');  -- notify caller of an error
        RAISE g_exception_halt_validation;
      ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

        -- notify caller of an error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RAISE g_exception_halt_validation;
      END IF;
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
  END validate_pricing_engine_code;

  -- function to validate the frequency code

  FUNCTION validate_frequency_code(p_frequency_code IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_frequency_code IS NULL) OR (p_frequency_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'FREQUENCY_CODE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    ELSE

      -- Lookup Code Validation

      x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_FREQUENCY'
                                                   ,p_lookup_code =>              p_frequency_code);
      IF (x_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'FREQUENCY_CODE');  -- notify caller of an error
        RAISE g_exception_halt_validation;
      ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

        -- notify caller of an error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RAISE g_exception_halt_validation;
      END IF;
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
  END validate_frequency_code;

  -- validate the rate type code

  FUNCTION validate_rate_type_code(p_rate_type_code IN VARCHAR2) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    IF (p_rate_type_code IS NULL) OR (p_rate_type_code = okl_api.g_miss_char) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'RATE_TYPE_CODE');

      -- notify caller of an error

      x_return_status := okl_api.g_ret_sts_error;

      -- halt further validation of this column

      RAISE g_exception_halt_validation;
    ELSE

      -- Lookup Code Validation

      x_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_SRT_RATE_TYPES'
                                                   ,p_lookup_code =>              p_rate_type_code);
      IF (x_return_status = okl_api.g_ret_sts_error) THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'RATE_TYPE_CODE');  -- notify caller of an error
        RAISE g_exception_halt_validation;
      ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN

        -- notify caller of an error

        x_return_status := okl_api.g_ret_sts_unexp_error;
        RAISE g_exception_halt_validation;
      END IF;
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
  END validate_rate_type_code;

  FUNCTION validate_index_id(p_index_id IN NUMBER) RETURN VARCHAR2 IS
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    CURSOR index_exists_csr IS
      SELECT 'x'
      FROM   okl_indices
      WHERE  id = p_index_id;
    l_dummy_var                  VARCHAR2(1) := '?';

  BEGIN

    IF (p_index_id IS NOT NULL AND p_index_id <> okl_api.g_miss_num) THEN
      OPEN index_exists_csr;
      FETCH index_exists_csr INTO l_dummy_var ;
      CLOSE index_exists_csr;

      -- if l_dummy_var is still set to default, data was not found

      IF (l_dummy_var = '?') THEN
        okl_api.set_message(p_app_name     =>             g_app_name
                           ,p_msg_name     =>             g_invalid_value
                           ,p_token1       =>             g_col_name_token
                           ,p_token1_value =>             'INDEX_ID');

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

        IF index_exists_csr%ISOPEN THEN
          CLOSE index_exists_csr;
        END IF;
        RETURN x_return_status;
  END validate_index_id;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_STD_RT_TMP_ALL_B
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_srtb_rec      IN            okl_srtb_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_srtb_rec IS

    CURSOR srtb_pk_csr(p_id IN NUMBER) IS
      SELECT std_rate_tmpl_id
            ,template_name
            ,object_version_number
            ,org_id
            ,currency_code
            ,rate_card_yn
            ,pricing_engine_code
            ,orig_std_rate_tmpl_id
            ,rate_type_code
            ,frequency_code
            ,index_id
            ,default_yn
            ,sts_code
            ,effective_from_date
            ,effective_to_date
            ,srt_rate
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
      FROM   okl_fe_std_rt_tmp_all_b
      WHERE  okl_fe_std_rt_tmp_all_b.std_rate_tmpl_id = p_id;
    l_srtb_pk                    srtb_pk_csr%ROWTYPE;
    l_srtb_rec                   okl_srtb_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN srtb_pk_csr(p_srtb_rec.std_rate_tmpl_id);
    FETCH srtb_pk_csr INTO l_srtb_rec.std_rate_tmpl_id
                          ,l_srtb_rec.template_name
                          ,l_srtb_rec.object_version_number
                          ,l_srtb_rec.org_id
                          ,l_srtb_rec.currency_code
                          ,l_srtb_rec.rate_card_yn
                          ,l_srtb_rec.pricing_engine_code
                          ,l_srtb_rec.orig_std_rate_tmpl_id
                          ,l_srtb_rec.rate_type_code
                          ,l_srtb_rec.frequency_code
                          ,l_srtb_rec.index_id
                          ,l_srtb_rec.default_yn
                          ,l_srtb_rec.sts_code
                          ,l_srtb_rec.effective_from_date
                          ,l_srtb_rec.effective_to_date
                          ,l_srtb_rec.srt_rate
                          ,l_srtb_rec.attribute_category
                          ,l_srtb_rec.attribute1
                          ,l_srtb_rec.attribute2
                          ,l_srtb_rec.attribute3
                          ,l_srtb_rec.attribute4
                          ,l_srtb_rec.attribute5
                          ,l_srtb_rec.attribute6
                          ,l_srtb_rec.attribute7
                          ,l_srtb_rec.attribute8
                          ,l_srtb_rec.attribute9
                          ,l_srtb_rec.attribute10
                          ,l_srtb_rec.attribute11
                          ,l_srtb_rec.attribute12
                          ,l_srtb_rec.attribute13
                          ,l_srtb_rec.attribute14
                          ,l_srtb_rec.attribute15
                          ,l_srtb_rec.created_by
                          ,l_srtb_rec.creation_date
                          ,l_srtb_rec.last_updated_by
                          ,l_srtb_rec.last_update_date
                          ,l_srtb_rec.last_update_login ;
    x_no_data_found := srtb_pk_csr%NOTFOUND;
    CLOSE srtb_pk_csr;
    RETURN(l_srtb_rec);
  END get_rec;

  FUNCTION get_rec(p_srtb_rec IN okl_srtb_rec) RETURN okl_srtb_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_srtb_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec forOKL_FE_STD_RT_TMP_ALL_TL
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_srttl_rec     IN            okl_srttl_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_srttl_rec IS

    CURSOR srttl_pk_csr(p_id       IN NUMBER
                       ,p_language IN VARCHAR2) IS
      SELECT std_rate_tmpl_id
            ,template_desc
            ,language
            ,source_lang
            ,sfwt_flag
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_std_rt_tmp_all_tl
      WHERE  okl_fe_std_rt_tmp_all_tl.std_rate_tmpl_id = p_id
         AND okl_fe_std_rt_tmp_all_tl.language = p_language;
    l_srttl_pk                   srttl_pk_csr%ROWTYPE;
    l_srttl_rec                  okl_srttl_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN srttl_pk_csr(p_srttl_rec.std_rate_tmpl_id
                     ,p_srttl_rec.language);
    FETCH srttl_pk_csr INTO l_srttl_rec.std_rate_tmpl_id
                           ,l_srttl_rec.template_desc
                           ,l_srttl_rec.language
                           ,l_srttl_rec.source_lang
                           ,l_srttl_rec.sfwt_flag
                           ,l_srttl_rec.created_by
                           ,l_srttl_rec.creation_date
                           ,l_srttl_rec.last_updated_by
                           ,l_srttl_rec.last_update_date
                           ,l_srttl_rec.last_update_login ;
    x_no_data_found := srttl_pk_csr%NOTFOUND;
    CLOSE srttl_pk_csr;
    RETURN(l_srttl_rec);
  END get_rec;

  FUNCTION get_rec(p_srttl_rec IN okl_srttl_rec) RETURN okl_srttl_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_srttl_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_STD_RT_TMP_V
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_srtv_rec      IN            okl_srtv_rec
                  ,x_no_data_found    OUT NOCOPY BOOLEAN) RETURN okl_srtv_rec IS

    CURSOR srtv_pk_csr(p_id IN NUMBER) IS
      SELECT std_rate_tmpl_id
            ,template_name
            ,template_desc
            ,object_version_number
            ,org_id
            ,currency_code
            ,rate_card_yn
            ,pricing_engine_code
            ,orig_std_rate_tmpl_id
            ,rate_type_code
            ,frequency_code
            ,index_id
            ,default_yn
            ,sts_code
            ,effective_from_date
            ,effective_to_date
            ,srt_rate
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
      FROM   okl_fe_std_rt_tmp_v
      WHERE  okl_fe_std_rt_tmp_v.std_rate_tmpl_id = p_id;
    l_srtv_pk                    srtv_pk_csr%ROWTYPE;
    l_srtv_rec                   okl_srtv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN srtv_pk_csr(p_srtv_rec.std_rate_tmpl_id);
    FETCH srtv_pk_csr INTO l_srtv_rec.std_rate_tmpl_id
                          ,l_srtv_rec.template_name
                          ,l_srtv_rec.template_desc
                          ,l_srtv_rec.object_version_number
                          ,l_srtv_rec.org_id
                          ,l_srtv_rec.currency_code
                          ,l_srtv_rec.rate_card_yn
                          ,l_srtv_rec.pricing_engine_code
                          ,l_srtv_rec.orig_std_rate_tmpl_id
                          ,l_srtv_rec.rate_type_code
                          ,l_srtv_rec.frequency_code
                          ,l_srtv_rec.index_id
                          ,l_srtv_rec.default_yn
                          ,l_srtv_rec.sts_code
                          ,l_srtv_rec.effective_from_date
                          ,l_srtv_rec.effective_to_date
                          ,l_srtv_rec.srt_rate
                          ,l_srtv_rec.attribute_category
                          ,l_srtv_rec.attribute1
                          ,l_srtv_rec.attribute2
                          ,l_srtv_rec.attribute3
                          ,l_srtv_rec.attribute4
                          ,l_srtv_rec.attribute5
                          ,l_srtv_rec.attribute6
                          ,l_srtv_rec.attribute7
                          ,l_srtv_rec.attribute8
                          ,l_srtv_rec.attribute9
                          ,l_srtv_rec.attribute10
                          ,l_srtv_rec.attribute11
                          ,l_srtv_rec.attribute12
                          ,l_srtv_rec.attribute13
                          ,l_srtv_rec.attribute14
                          ,l_srtv_rec.attribute15
                          ,l_srtv_rec.created_by
                          ,l_srtv_rec.creation_date
                          ,l_srtv_rec.last_updated_by
                          ,l_srtv_rec.last_update_date
                          ,l_srtv_rec.last_update_login ;
    x_no_data_found := srtv_pk_csr%NOTFOUND;
    CLOSE srtv_pk_csr;
    RETURN(l_srtv_rec);
  END get_rec;

  FUNCTION get_rec(p_srtv_rec IN okl_srtv_rec) RETURN okl_srtv_rec IS
    l_row_notfound               BOOLEAN := true;

  BEGIN
    RETURN(get_rec(p_srtv_rec
                  ,l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure migrate
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from IN            okl_srtv_rec
                   ,p_to   IN OUT NOCOPY okl_srtb_rec) IS

  BEGIN
    p_to.std_rate_tmpl_id := p_from.std_rate_tmpl_id;
    p_to.template_name := p_from.template_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.rate_card_yn := p_from.rate_card_yn;
    p_to.pricing_engine_code := p_from.pricing_engine_code;
    p_to.orig_std_rate_tmpl_id := p_from.orig_std_rate_tmpl_id;
    p_to.rate_type_code := p_from.rate_type_code;
    p_to.frequency_code := p_from.frequency_code;
    p_to.index_id := p_from.index_id;
    p_to.default_yn := p_from.default_yn;
    p_to.sts_code := p_from.sts_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.srt_rate := p_from.srt_rate;
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

  PROCEDURE migrate(p_from IN            okl_srtb_rec
                   ,p_to   IN OUT NOCOPY okl_srtv_rec) IS

  BEGIN
    p_to.std_rate_tmpl_id := p_from.std_rate_tmpl_id;
    p_to.template_name := p_from.template_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.currency_code := p_from.currency_code;
    p_to.rate_card_yn := p_from.rate_card_yn;
    p_to.pricing_engine_code := p_from.pricing_engine_code;
    p_to.orig_std_rate_tmpl_id := p_from.orig_std_rate_tmpl_id;
    p_to.rate_type_code := p_from.rate_type_code;
    p_to.frequency_code := p_from.frequency_code;
    p_to.index_id := p_from.index_id;
    p_to.sts_code := p_from.sts_code;
    p_to.default_yn := p_from.default_yn;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.srt_rate := p_from.srt_rate;
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

  PROCEDURE migrate(p_from IN            okl_srtv_rec
                   ,p_to   IN OUT NOCOPY okl_srttl_rec) IS

  BEGIN
    p_to.std_rate_tmpl_id := p_from.std_rate_tmpl_id;
    p_to.template_desc := p_from.template_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate(p_from IN            okl_srttl_rec
                   ,p_to   IN OUT NOCOPY okl_srtv_rec) IS

  BEGIN
    p_to.std_rate_tmpl_id := p_from.std_rate_tmpl_id;
    p_to.template_desc := p_from.template_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  FUNCTION null_out_defaults(p_srtv_rec IN okl_srtv_rec) RETURN okl_srtv_rec IS
    l_srtv_rec                   okl_srtv_rec := p_srtv_rec;

  BEGIN

    IF (l_srtv_rec.std_rate_tmpl_id = okl_api.g_miss_num) THEN
      l_srtv_rec.std_rate_tmpl_id := NULL;
    END IF;

    IF (l_srtv_rec.template_name = okl_api.g_miss_char) THEN
      l_srtv_rec.template_name := NULL;
    END IF;

    IF (l_srtv_rec.template_desc = okl_api.g_miss_char) THEN
      l_srtv_rec.template_desc := NULL;
    END IF;

    IF (l_srtv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_srtv_rec.object_version_number := NULL;
    END IF;

    IF (l_srtv_rec.org_id = okl_api.g_miss_num) THEN
      l_srtv_rec.org_id := NULL;
    END IF;

    IF (l_srtv_rec.currency_code = okl_api.g_miss_char) THEN
      l_srtv_rec.currency_code := NULL;
    END IF;

    IF (l_srtv_rec.rate_card_yn = okl_api.g_miss_char) THEN
      l_srtv_rec.rate_card_yn := NULL;
    END IF;

    IF (l_srtv_rec.pricing_engine_code = okl_api.g_miss_char) THEN
      l_srtv_rec.pricing_engine_code := NULL;
    END IF;

    IF (l_srtv_rec.orig_std_rate_tmpl_id = okl_api.g_miss_num) THEN
      l_srtv_rec.orig_std_rate_tmpl_id := NULL;
    END IF;

    IF (l_srtv_rec.rate_type_code = okl_api.g_miss_char) THEN
      l_srtv_rec.rate_type_code := NULL;
    END IF;

    IF (l_srtv_rec.frequency_code = okl_api.g_miss_char) THEN
      l_srtv_rec.frequency_code := NULL;
    END IF;

    IF (l_srtv_rec.index_id = okl_api.g_miss_num) THEN
      l_srtv_rec.index_id := NULL;
    END IF;

    IF (l_srtv_rec.default_yn = okl_api.g_miss_char) THEN
      l_srtv_rec.default_yn := NULL;
    END IF;

    IF (l_srtv_rec.sts_code = okl_api.g_miss_char) THEN
      l_srtv_rec.sts_code := NULL;
    END IF;

    IF (l_srtv_rec.effective_from_date = okl_api.g_miss_date) THEN
      l_srtv_rec.effective_from_date := NULL;
    END IF;

    IF (l_srtv_rec.effective_to_date = okl_api.g_miss_date) THEN
      l_srtv_rec.effective_to_date := NULL;
    END IF;

    IF (l_srtv_rec.srt_rate = okl_api.g_miss_num) THEN
      l_srtv_rec.srt_rate := NULL;
    END IF;

    IF (l_srtv_rec.attribute_category = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute_category := NULL;
    END IF;

    IF (l_srtv_rec.attribute1 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute1 := NULL;
    END IF;

    IF (l_srtv_rec.attribute2 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute2 := NULL;
    END IF;

    IF (l_srtv_rec.attribute3 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute3 := NULL;
    END IF;

    IF (l_srtv_rec.attribute4 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute4 := NULL;
    END IF;

    IF (l_srtv_rec.attribute5 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute5 := NULL;
    END IF;

    IF (l_srtv_rec.attribute6 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute6 := NULL;
    END IF;

    IF (l_srtv_rec.attribute7 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute7 := NULL;
    END IF;

    IF (l_srtv_rec.attribute8 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute8 := NULL;
    END IF;

    IF (l_srtv_rec.attribute9 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute9 := NULL;
    END IF;

    IF (l_srtv_rec.attribute10 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute10 := NULL;
    END IF;

    IF (l_srtv_rec.attribute11 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute11 := NULL;
    END IF;

    IF (l_srtv_rec.attribute12 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute12 := NULL;
    END IF;

    IF (l_srtv_rec.attribute13 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute13 := NULL;
    END IF;

    IF (l_srtv_rec.attribute14 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute14 := NULL;
    END IF;

    IF (l_srtv_rec.attribute15 = okl_api.g_miss_char) THEN
      l_srtv_rec.attribute15 := NULL;
    END IF;

    IF (l_srtv_rec.created_by = okl_api.g_miss_num) THEN
      l_srtv_rec.created_by := NULL;
    END IF;

    IF (l_srtv_rec.creation_date = okl_api.g_miss_date) THEN
      l_srtv_rec.creation_date := NULL;
    END IF;

    IF (l_srtv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_srtv_rec.last_updated_by := NULL;
    END IF;

    IF (l_srtv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_srtv_rec.last_update_date := NULL;
    END IF;

    IF (l_srtv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_srtv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_srtv_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN NUMBER IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  FUNCTION validate_attributes(p_srtv_rec IN okl_srtv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

  BEGIN

    -- validate the Standard Rate Template id

    l_return_status := validate_std_rate_tmpl_id(p_srtv_rec.std_rate_tmpl_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the org_id

    l_return_status := validate_org_id(p_srtv_rec.org_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the currency code

    l_return_status := validate_currency_code(p_srtv_rec.currency_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the orig_std_rate_id

    l_return_status := validate_orig_std_rate_tmpl_id(p_srtv_rec.orig_std_rate_tmpl_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the pricing engine code

    l_return_status := validate_pricing_engine_code(p_srtv_rec.pricing_engine_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the frequency code

    l_return_status := validate_frequency_code(p_srtv_rec.frequency_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the index id

    l_return_status := validate_index_id(p_srtv_rec.index_id);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Status code

    l_return_status := validate_sts_code(p_srtv_rec.sts_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the rate card flag

    l_return_status := validate_rate_card_yn(p_srtv_rec.rate_card_yn);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Rate Type

    l_return_status := validate_rate_type_code(p_srtv_rec.rate_type_code);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Rate

    l_return_status := validate_srt_rate(p_srtv_rec.srt_rate);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- validate the Effective from date

    l_return_status := validate_effective_from_date(p_srtv_rec.effective_from_date);

    -- store the highest degree of error

    IF (l_return_status <> okl_api.g_ret_sts_success) THEN
      IF (x_return_status <> okl_api.g_ret_sts_unexp_error) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    RETURN(x_return_status);
  END validate_attributes;

  FUNCTION validate_record(p_srtv_rec IN okl_srtv_rec) RETURN VARCHAR2 IS
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    x_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_srtv_rec                   okl_srtv_rec := p_srtv_rec;

  BEGIN

    IF (l_srtv_rec.rate_type_code = 'INDEX RATE' AND (l_srtv_rec.index_id IS NULL
                                                      OR l_srtv_rec.index_id = okl_api.g_miss_num)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'index_rate');


      l_return_status := okl_api.g_ret_sts_error;
    END IF;
    if (p_srtv_rec.effective_to_date is not null) then
        if (p_srtv_rec.effective_from_date > p_srtv_rec.effective_to_date) then
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_INVALID_EFFECTIVE_TO');
            x_return_status := okl_api.g_ret_sts_error;

        end if;
    end if;
    RETURN(x_return_status);
  END validate_record;

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
                    ,p_srtb_rec      IN            okl_srtb_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_srtb_rec IN okl_srtb_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_std_rt_tmp_all_b
      WHERE         std_rate_tmpl_id = p_srtb_rec.std_rate_tmpl_id
                AND object_version_number = p_srtb_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_srtb_rec IN okl_srtb_rec) IS
      SELECT object_version_number
      FROM   okl_fe_std_rt_tmp_all_b
      WHERE  std_rate_tmpl_id = p_srtb_rec.std_rate_tmpl_id;
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
      OPEN lock_csr(p_srtb_rec);
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
      OPEN lchk_csr(p_srtb_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_srtb_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app
                         ,g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_srtb_rec.object_version_number THEN
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
                    ,p_srttl_rec     IN            okl_srttl_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, - 00054);

    CURSOR lock_csr(p_srttl_rec IN okl_srttl_rec) IS
      SELECT     *
      FROM       okl_fe_std_rt_tmp_all_tl
      WHERE      std_rate_tmpl_id = p_srttl_rec.std_rate_tmpl_id
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
      OPEN lock_csr(p_srttl_rec);
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
                    ,p_srtv_rec      IN            okl_srtv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'V_lock_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srtb_rec                    okl_srtb_rec;
    l_srttl_rec                   okl_srttl_rec;

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

    migrate(p_srtv_rec
           ,l_srtb_rec);
    migrate(p_srtv_rec
           ,l_srttl_rec);

    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------

    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_srtb_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_srttl_rec);

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
                    ,p_srtv_tbl      IN            okl_srtv_tbl) IS
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

    IF (p_srtv_tbl.COUNT > 0) THEN
      i := p_srtv_tbl.FIRST;

      LOOP
        lock_row(p_api_version   =>            p_api_version
                ,p_init_msg_list =>            okl_api.g_false
                ,x_return_status =>            x_return_status
                ,x_msg_count     =>            x_msg_count
                ,x_msg_data      =>            x_msg_data
                ,p_srtv_rec      =>            p_srtv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_srtv_tbl.LAST);
        i := p_srtv_tbl.next(i);
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
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srtb_rec      IN            okl_srtb_rec
                      ,x_srtb_rec         OUT NOCOPY okl_srtb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_srtb_rec                    okl_srtb_rec := p_srtb_rec;

    FUNCTION set_attributes(p_srtb_rec IN            okl_srtb_rec
                           ,x_srtb_rec    OUT NOCOPY okl_srtb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srtb_rec := p_srtb_rec;
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

    l_return_status := set_attributes(p_srtb_rec
                                     ,l_srtb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    INSERT INTO okl_fe_std_rt_tmp_all_b
               (std_rate_tmpl_id
               ,template_name
               ,object_version_number
               ,org_id
               ,currency_code
               ,rate_card_yn
               ,pricing_engine_code
               ,orig_std_rate_tmpl_id
               ,rate_type_code
               ,frequency_code
               ,index_id
               ,default_yn
               ,sts_code
               ,effective_from_date
               ,effective_to_date
               ,srt_rate
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
    VALUES     (l_srtb_rec.std_rate_tmpl_id
               ,l_srtb_rec.template_name
               ,l_srtb_rec.object_version_number
               ,l_srtb_rec.org_id
               ,l_srtb_rec.currency_code
               ,l_srtb_rec.rate_card_yn
               ,l_srtb_rec.pricing_engine_code
               ,l_srtb_rec.orig_std_rate_tmpl_id
               ,l_srtb_rec.rate_type_code
               ,l_srtb_rec.frequency_code
               ,l_srtb_rec.index_id
               ,l_srtb_rec.default_yn
               ,l_srtb_rec.sts_code
               ,l_srtb_rec.effective_from_date
               ,l_srtb_rec.effective_to_date
               ,l_srtb_rec.srt_rate
               ,l_srtb_rec.attribute_category
               ,l_srtb_rec.attribute1
               ,l_srtb_rec.attribute2
               ,l_srtb_rec.attribute3
               ,l_srtb_rec.attribute4
               ,l_srtb_rec.attribute5
               ,l_srtb_rec.attribute6
               ,l_srtb_rec.attribute7
               ,l_srtb_rec.attribute8
               ,l_srtb_rec.attribute9
               ,l_srtb_rec.attribute10
               ,l_srtb_rec.attribute11
               ,l_srtb_rec.attribute12
               ,l_srtb_rec.attribute13
               ,l_srtb_rec.attribute14
               ,l_srtb_rec.attribute15
               ,l_srtb_rec.created_by
               ,l_srtb_rec.creation_date
               ,l_srtb_rec.last_updated_by
               ,l_srtb_rec.last_update_date
               ,l_srtb_rec.last_update_login);

    --Set OUT Values

    x_srtb_rec := l_srtb_rec;
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
                      ,p_srttl_rec     IN            okl_srttl_rec
                      ,x_srttl_rec        OUT NOCOPY okl_srttl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srttl_rec                   okl_srttl_rec := p_srttl_rec;

    CURSOR get_languages IS
      SELECT *
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B');

    FUNCTION set_attributes(p_srttl_rec IN            okl_srttl_rec
                           ,x_srttl_rec    OUT NOCOPY okl_srttl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srttl_rec := p_srttl_rec;
      x_srttl_rec.language := USERENV('LANG');
      x_srttl_rec.source_lang := USERENV('LANG');
      x_srttl_rec.sfwt_flag := 'N';
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

    l_return_status := set_attributes(p_srttl_rec
                                     ,l_srttl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    FOR l_lang_rec IN get_languages LOOP
      l_srttl_rec.language := l_lang_rec.language_code;

      INSERT INTO okl_fe_std_rt_tmp_all_tl
                 (std_rate_tmpl_id
                 ,template_desc
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (l_srttl_rec.std_rate_tmpl_id
                 ,l_srttl_rec.template_desc
                 ,l_srttl_rec.language
                 ,l_srttl_rec.source_lang
                 ,l_srttl_rec.sfwt_flag
                 ,l_srttl_rec.created_by
                 ,l_srttl_rec.creation_date
                 ,l_srttl_rec.last_updated_by
                 ,l_srttl_rec.last_update_date
                 ,l_srttl_rec.last_update_login);

    END LOOP;

    --Set OUT Values

    x_srttl_rec := l_srttl_rec;
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
                      ,p_srtv_rec      IN            okl_srtv_rec
                      ,x_srtv_rec         OUT NOCOPY okl_srtv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srtv_rec                    okl_srtv_rec;
    l_def_srtv_rec                okl_srtv_rec;
    l_srtb_rec                    okl_srtb_rec;
    lx_srtb_rec                   okl_srtb_rec;
    l_srttl_rec                   okl_srttl_rec;
    lx_srttl_rec                  okl_srttl_rec;

    FUNCTION fill_who_columns(p_srtv_rec IN okl_srtv_rec) RETURN okl_srtv_rec IS
      l_srtv_rec                   okl_srtv_rec := p_srtv_rec;

    BEGIN
      l_srtv_rec.creation_date := SYSDATE;
      l_srtv_rec.created_by := fnd_global.user_id;
      l_srtv_rec.last_update_date := SYSDATE;
      l_srtv_rec.last_updated_by := fnd_global.user_id;
      l_srtv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_srtv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_srtv_rec IN            okl_srtv_rec
                           ,x_srtv_rec    OUT NOCOPY okl_srtv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srtv_rec := p_srtv_rec;
      x_srtv_rec.object_version_number := 1;
      x_srtv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
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
    l_srtv_rec := null_out_defaults(p_srtv_rec);

    -- Set Primary key value

    l_srtv_rec.std_rate_tmpl_id := get_seq_id;

    --Setting Item Attributes

    l_return_status := set_attributes(l_srtv_rec
                                     ,l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_srtv_rec := fill_who_columns(l_def_srtv_rec);
    l_return_status := validate_attributes(l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_def_srtv_rec
           ,l_srtb_rec);
    migrate(l_def_srtv_rec
           ,l_srttl_rec);

    -- insert into the b table

    insert_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_srtb_rec
              ,lx_srtb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_srtb_rec
           ,l_def_srtv_rec);

    --insert into the tl table

    insert_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_srttl_rec
              ,lx_srttl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_srttl_rec
           ,l_def_srtv_rec);

    --Set OUT Values

    x_srtv_rec := l_def_srtv_rec;
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
                      ,p_srtv_tbl      IN            okl_srtv_tbl
                      ,x_srtv_tbl         OUT NOCOPY okl_srtv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_insert_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_srtv_tbl.COUNT > 0) THEN
      i := p_srtv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_srtv_rec      =>            p_srtv_tbl(i)
                  ,x_srtv_rec      =>            x_srtv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_srtv_tbl.LAST);
        i := p_srtv_tbl.next(i);
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
                      ,p_srtb_rec      IN            okl_srtb_rec
                      ,x_srtb_rec         OUT NOCOPY okl_srtb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_srtb_rec                    okl_srtb_rec := p_srtb_rec;
    l_def_srtb_rec                okl_srtb_rec;
    l_row_notfound                BOOLEAN      := true;

    FUNCTION set_attributes(p_srtb_rec IN            okl_srtb_rec
                           ,x_srtb_rec    OUT NOCOPY okl_srtb_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srtb_rec := p_srtb_rec;
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

    l_return_status := set_attributes(p_srtb_rec
                                     ,l_def_srtb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_std_rt_tmp_all_b
    SET    std_rate_tmpl_id = l_def_srtb_rec.std_rate_tmpl_id
          ,template_name = l_def_srtb_rec.template_name
          ,object_version_number = l_def_srtb_rec.object_version_number + 1
          ,org_id = l_def_srtb_rec.org_id
          ,currency_code = l_def_srtb_rec.currency_code
          ,rate_card_yn = l_def_srtb_rec.rate_card_yn
          ,pricing_engine_code = l_def_srtb_rec.pricing_engine_code
          ,orig_std_rate_tmpl_id = l_def_srtb_rec.orig_std_rate_tmpl_id
          ,rate_type_code = l_def_srtb_rec.rate_type_code
          ,frequency_code = l_def_srtb_rec.frequency_code
          ,index_id = l_def_srtb_rec.index_id
          ,default_yn = l_def_srtb_rec.default_yn
          ,sts_code = l_def_srtb_rec.sts_code
          ,effective_from_date = l_def_srtb_rec.effective_from_date
          ,effective_to_date = l_def_srtb_rec.effective_to_date
          ,srt_rate = l_def_srtb_rec.srt_rate
          ,attribute_category = l_def_srtb_rec.attribute_category
          ,attribute1 = l_def_srtb_rec.attribute1
          ,attribute2 = l_def_srtb_rec.attribute2
          ,attribute3 = l_def_srtb_rec.attribute3
          ,attribute4 = l_def_srtb_rec.attribute4
          ,attribute5 = l_def_srtb_rec.attribute5
          ,attribute6 = l_def_srtb_rec.attribute6
          ,attribute7 = l_def_srtb_rec.attribute7
          ,attribute8 = l_def_srtb_rec.attribute8
          ,attribute9 = l_def_srtb_rec.attribute9
          ,attribute10 = l_def_srtb_rec.attribute10
          ,attribute11 = l_def_srtb_rec.attribute11
          ,attribute12 = l_def_srtb_rec.attribute12
          ,attribute13 = l_def_srtb_rec.attribute13
          ,attribute14 = l_def_srtb_rec.attribute14
          ,attribute15 = l_def_srtb_rec.attribute15
          ,created_by = l_def_srtb_rec.created_by
          ,creation_date = l_def_srtb_rec.creation_date
          ,last_updated_by = l_def_srtb_rec.last_updated_by
          ,last_update_date = l_def_srtb_rec.last_update_date
          ,last_update_login = l_def_srtb_rec.last_update_login
    WHERE  std_rate_tmpl_id = l_def_srtb_rec.std_rate_tmpl_id;

    --Set OUT Values

    x_srtb_rec := l_srtb_rec;
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
                      ,p_srttl_rec     IN            okl_srttl_rec
                      ,x_srttl_rec        OUT NOCOPY okl_srttl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'update_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srttl_rec                   okl_srttl_rec := p_srttl_rec;
    l_def_srttl_rec               okl_srttl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_srttl_rec IN            okl_srttl_rec
                           ,x_srttl_rec    OUT NOCOPY okl_srttl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srttl_rec := p_srttl_rec;
      x_srttl_rec.language := USERENV('LANG');
      x_srttl_rec.source_lang := USERENV('LANG');
      x_srttl_rec.sfwt_flag := 'N';
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

    l_return_status := set_attributes(p_srttl_rec
                                     ,l_def_srttl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_std_rt_tmp_all_tl
    SET    std_rate_tmpl_id = l_def_srttl_rec.std_rate_tmpl_id
          ,template_desc = l_def_srttl_rec.template_desc
          ,language = l_def_srttl_rec.language
          ,source_lang = l_def_srttl_rec.source_lang
          ,sfwt_flag = l_def_srttl_rec.sfwt_flag
          ,created_by = l_def_srttl_rec.created_by
          ,creation_date = l_def_srttl_rec.creation_date
          ,last_updated_by = l_def_srttl_rec.last_updated_by
          ,last_update_date = l_def_srttl_rec.last_update_date
          ,last_update_login = l_def_srttl_rec.last_update_login
    WHERE  std_rate_tmpl_id = l_def_srttl_rec.std_rate_tmpl_id
       AND language = l_def_srttl_rec.language;

    UPDATE okl_fe_std_rt_tmp_all_tl
    SET    sfwt_flag = 'Y'
    WHERE  std_rate_tmpl_id = l_def_srttl_rec.std_rate_tmpl_id
       AND source_lang <> USERENV('LANG');

    --Set OUT Values

    x_srttl_rec := l_srttl_rec;
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
                      ,p_srtv_rec      IN            okl_srtv_rec
                      ,x_srtv_rec         OUT NOCOPY okl_srtv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_insert_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srtv_rec                    okl_srtv_rec  := p_srtv_rec;
    l_def_srtv_rec                okl_srtv_rec;
    lx_srtv_rec                   okl_srtv_rec;
    l_srtb_rec                    okl_srtb_rec;
    lx_srtb_rec                   okl_srtb_rec;
    l_srttl_rec                   okl_srttl_rec;
    lx_srttl_rec                  okl_srttl_rec;

    FUNCTION fill_who_columns(p_srtv_rec IN okl_srtv_rec) RETURN okl_srtv_rec IS
      l_srtv_rec                   okl_srtv_rec := p_srtv_rec;

    BEGIN
      l_srtv_rec.last_update_date := SYSDATE;
      l_srtv_rec.last_updated_by := fnd_global.user_id;
      l_srtv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_srtv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_srtv_rec IN            okl_srtv_rec
                                ,x_srtv_rec    OUT NOCOPY okl_srtv_rec) RETURN VARCHAR2 IS
      l_srtv_rec                   okl_srtv_rec;
      l_row_notfound               BOOLEAN      := true;
      l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

    BEGIN
      x_srtv_rec := p_srtv_rec;

      --Get current database values

      l_srtv_rec := get_rec(p_srtv_rec
                           ,l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      IF (x_srtv_rec.std_rate_tmpl_id IS NULL) THEN
        x_srtv_rec.std_rate_tmpl_id := l_srtv_rec.std_rate_tmpl_id;
      END IF;

      IF (x_srtv_rec.template_name IS NULL) THEN
        x_srtv_rec.template_name := l_srtv_rec.template_name;
      END IF;

      IF (x_srtv_rec.template_desc IS NULL) THEN
        x_srtv_rec.template_desc := l_srtv_rec.template_desc;
      END IF;

      IF (x_srtv_rec.object_version_number IS NULL) THEN
        x_srtv_rec.object_version_number := l_srtv_rec.object_version_number;
      END IF;

      IF (x_srtv_rec.org_id IS NULL) THEN
        x_srtv_rec.org_id := l_srtv_rec.org_id;
      END IF;

      IF (x_srtv_rec.currency_code IS NULL) THEN
        x_srtv_rec.currency_code := l_srtv_rec.currency_code;
      END IF;

      IF (x_srtv_rec.rate_card_yn IS NULL) THEN
        x_srtv_rec.rate_card_yn := l_srtv_rec.rate_card_yn;
      END IF;

      IF (x_srtv_rec.pricing_engine_code IS NULL) THEN
        x_srtv_rec.pricing_engine_code := l_srtv_rec.pricing_engine_code;
      END IF;

      IF (x_srtv_rec.orig_std_rate_tmpl_id IS NULL) THEN
        x_srtv_rec.orig_std_rate_tmpl_id := l_srtv_rec.orig_std_rate_tmpl_id;
      END IF;

      IF (x_srtv_rec.rate_type_code IS NULL) THEN
        x_srtv_rec.rate_type_code := l_srtv_rec.rate_type_code;
      END IF;

      IF (x_srtv_rec.frequency_code IS NULL) THEN
        x_srtv_rec.frequency_code := l_srtv_rec.frequency_code;
      END IF;

      IF (x_srtv_rec.index_id IS NULL) THEN
        x_srtv_rec.index_id := l_srtv_rec.index_id;
      END IF;

      IF (x_srtv_rec.default_yn IS NULL) THEN
        x_srtv_rec.default_yn := l_srtv_rec.default_yn;
      END IF;

      IF (x_srtv_rec.sts_code IS NULL) THEN
        x_srtv_rec.sts_code := l_srtv_rec.sts_code;
      END IF;

      IF (x_srtv_rec.effective_from_date IS NULL) THEN
        x_srtv_rec.effective_from_date := l_srtv_rec.effective_from_date;
      END IF;

      IF (x_srtv_rec.effective_to_date IS NULL) THEN
        x_srtv_rec.effective_to_date := l_srtv_rec.effective_to_date;
      END IF;

      IF (x_srtv_rec.srt_rate IS NULL) THEN
        x_srtv_rec.srt_rate := l_srtv_rec.srt_rate;
      END IF;

      IF (x_srtv_rec.attribute_category IS NULL) THEN
        x_srtv_rec.attribute_category := l_srtv_rec.attribute_category;
      END IF;

      IF (x_srtv_rec.attribute1 IS NULL) THEN
        x_srtv_rec.attribute1 := l_srtv_rec.attribute1;
      END IF;

      IF (x_srtv_rec.attribute2 IS NULL) THEN
        x_srtv_rec.attribute2 := l_srtv_rec.attribute2;
      END IF;

      IF (x_srtv_rec.attribute3 IS NULL) THEN
        x_srtv_rec.attribute3 := l_srtv_rec.attribute3;
      END IF;

      IF (x_srtv_rec.attribute4 IS NULL) THEN
        x_srtv_rec.attribute4 := l_srtv_rec.attribute4;
      END IF;

      IF (x_srtv_rec.attribute5 IS NULL) THEN
        x_srtv_rec.attribute5 := l_srtv_rec.attribute5;
      END IF;

      IF (x_srtv_rec.attribute6 IS NULL) THEN
        x_srtv_rec.attribute6 := l_srtv_rec.attribute6;
      END IF;

      IF (x_srtv_rec.attribute7 IS NULL) THEN
        x_srtv_rec.attribute7 := l_srtv_rec.attribute7;
      END IF;

      IF (x_srtv_rec.attribute8 IS NULL) THEN
        x_srtv_rec.attribute8 := l_srtv_rec.attribute8;
      END IF;

      IF (x_srtv_rec.attribute9 IS NULL) THEN
        x_srtv_rec.attribute9 := l_srtv_rec.attribute9;
      END IF;

      IF (x_srtv_rec.attribute10 IS NULL) THEN
        x_srtv_rec.attribute10 := l_srtv_rec.attribute10;
      END IF;

      IF (x_srtv_rec.attribute11 IS NULL) THEN
        x_srtv_rec.attribute11 := l_srtv_rec.attribute11;
      END IF;

      IF (x_srtv_rec.attribute12 IS NULL) THEN
        x_srtv_rec.attribute12 := l_srtv_rec.attribute12;
      END IF;

      IF (x_srtv_rec.attribute13 IS NULL) THEN
        x_srtv_rec.attribute13 := l_srtv_rec.attribute13;
      END IF;

      IF (x_srtv_rec.attribute14 IS NULL) THEN
        x_srtv_rec.attribute14 := l_srtv_rec.attribute14;
      END IF;

      IF (x_srtv_rec.attribute15 IS NULL) THEN
        x_srtv_rec.attribute15 := l_srtv_rec.attribute15;
      END IF;

      IF (x_srtv_rec.created_by IS NULL) THEN
        x_srtv_rec.created_by := l_srtv_rec.created_by;
      END IF;

      IF (x_srtv_rec.creation_date IS NULL) THEN
        x_srtv_rec.creation_date := l_srtv_rec.creation_date;
      END IF;

      IF (x_srtv_rec.last_updated_by IS NULL) THEN
        x_srtv_rec.last_updated_by := l_srtv_rec.last_updated_by;
      END IF;

      IF (x_srtv_rec.last_update_date IS NULL) THEN
        x_srtv_rec.last_update_date := l_srtv_rec.last_update_date;
      END IF;

      IF (x_srtv_rec.last_update_login IS NULL) THEN
        x_srtv_rec.last_update_login := l_srtv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_srtv_rec IN            okl_srtv_rec
                           ,x_srtv_rec    OUT NOCOPY okl_srtv_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srtv_rec := p_srtv_rec;
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

    l_return_status := set_attributes(l_srtv_rec
                                     ,lx_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := populate_new_record(lx_srtv_rec
                                          ,l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_srtv_rec := null_out_defaults(l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_def_srtv_rec := fill_who_columns(l_def_srtv_rec);
    l_return_status := validate_attributes(l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_def_srtv_rec);

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
            ,p_srtv_rec      =>            l_def_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(l_def_srtv_rec
           ,l_srtb_rec);
    migrate(l_def_srtv_rec
           ,l_srttl_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_srtb_rec
              ,lx_srtb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_srtb_rec
           ,l_def_srtv_rec);
    update_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_srttl_rec
              ,lx_srttl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_srttl_rec
           ,l_def_srtv_rec);

    --Set OUT Values

    x_srtv_rec := l_def_srtv_rec;
    x_return_status := l_return_status;
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
                      ,p_srtv_tbl      IN            okl_srtv_tbl
                      ,x_srtv_tbl         OUT NOCOPY okl_srtv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_update_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_srtv_tbl.COUNT > 0) THEN
      i := p_srtv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_srtv_rec      =>            p_srtv_tbl(i)
                  ,x_srtv_rec      =>            x_srtv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_srtv_tbl.LAST);
        i := p_srtv_tbl.next(i);
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
                      ,p_srtb_rec      IN            okl_srtb_rec) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_srtb_rec                    okl_srtb_rec := p_srtb_rec;
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

    DELETE FROM okl_fe_std_rt_tmp_all_b
    WHERE       std_rate_tmpl_id = l_srtb_rec.std_rate_tmpl_id;

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
                      ,p_srttl_rec     IN            okl_srttl_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srttl_rec                   okl_srttl_rec := p_srttl_rec;
    l_row_notfound                BOOLEAN       := true;

    FUNCTION set_attributes(p_srttl_rec IN            okl_srttl_rec
                           ,x_srttl_rec    OUT NOCOPY okl_srttl_rec) RETURN VARCHAR2 IS
      l_return_status              VARCHAR2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_srttl_rec := p_srttl_rec;
      x_srttl_rec.language := USERENV('LANG');
      x_srttl_rec.source_lang := USERENV('LANG');
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

    l_return_status := set_attributes(p_srttl_rec
                                     ,l_srttl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_std_rt_tmp_all_tl
    WHERE       std_rate_tmpl_id = l_srttl_rec.std_rate_tmpl_id;

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
                      ,p_srtv_rec      IN            okl_srtv_rec) IS
    l_api_version        CONSTANT NUMBER        := 1;
    l_api_name           CONSTANT VARCHAR2(30)  := 'v_delete_row';
    l_return_status               VARCHAR2(1)   := okl_api.g_ret_sts_success;
    l_srtv_rec                    okl_srtv_rec  := p_srtv_rec;
    l_srtb_rec                    okl_srtb_rec;
    l_srttl_rec                   okl_srttl_rec;

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
    migrate(l_srtv_rec
           ,l_srtb_rec);
    migrate(l_srtv_rec
           ,l_srttl_rec);
    delete_row(p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_srtb_rec);

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
              ,l_srttl_rec);

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
                      ,p_srtv_tbl      IN            okl_srtv_tbl) IS
    l_api_version        CONSTANT NUMBER       := 1;
    l_api_name           CONSTANT VARCHAR2(30) := 'v_delete_row';
    l_return_status               VARCHAR2(1)  := okl_api.g_ret_sts_success;
    i                             NUMBER       := 0;
    l_overall_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_srtv_tbl.COUNT > 0) THEN
      i := p_srtv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_srtv_rec      =>            p_srtv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_srtv_tbl.LAST);
        i := p_srtv_tbl.next(i);
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

END okl_srt_pvt;

/
