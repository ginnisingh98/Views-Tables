--------------------------------------------------------
--  DDL for Package Body OKL_ECC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_PVT" AS
/* $Header: OKLSECCB.pls 120.7 2007/01/09 08:41:56 abhsaxen noship $ */

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

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------

  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_FE_CRIT_CAT_DEF_TL t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_FE_CRIT_CAT_DEF_B b
                           WHERE  b.crit_cat_def_id = t.crit_cat_def_id);

    UPDATE OKL_FE_CRIT_CAT_DEF_TL t
    SET(crit_cat_desc) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.crit_cat_desc
                              FROM   OKL_FE_CRIT_CAT_DEF_TL b
                              WHERE  b.crit_cat_def_id = t.crit_cat_def_id
                                 AND b.language = t.source_lang)
    WHERE  (t.crit_cat_def_id, t.language) IN(SELECT subt.crit_cat_def_id ,subt.language
           FROM   OKL_FE_CRIT_CAT_DEF_TL subb ,OKL_FE_CRIT_CAT_DEF_TL subt
           WHERE  subb.crit_cat_def_id = subt.crit_cat_def_id AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.crit_cat_desc <> subt.crit_cat_desc OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.crit_cat_desc IS NULL AND subt.crit_cat_desc IS NOT NULL)));

    INSERT INTO OKL_FE_CRIT_CAT_DEF_TL
               (crit_cat_def_id,
                language,
                source_lang,
                sfwt_flag,
                crit_cat_desc,
	        CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN)
                SELECT b.crit_cat_def_id,
                       l.language_code,
                       b.source_lang,
                       b.sfwt_flag,
                       b.crit_cat_desc,
		       b.CREATED_BY,
		       b.CREATION_DATE,
		       b.LAST_UPDATED_BY,
		       b.LAST_UPDATE_DATE,
		       b.LAST_UPDATE_LOGIN
                FROM   OKL_FE_CRIT_CAT_DEF_TL b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   OKL_FE_CRIT_CAT_DEF_TL t
                                      WHERE  t.crit_cat_def_id = b.crit_cat_def_id AND t.language = l.language_code);

  END add_language;


  --------------------------------------------------------------------------------
  -- Procedure migrate  v to b
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from  IN             okl_eccv_rec
                   ,p_to    IN OUT NOCOPY  okl_eccb_rec) IS

  BEGIN
    p_to.crit_cat_def_id := p_from.crit_cat_def_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.crit_cat_name := p_from.crit_cat_name;
    p_to.ecc_ac_flag := p_from.ecc_ac_flag;
    p_to.orig_crit_cat_def_id := p_from.orig_crit_cat_def_id;
    p_to.value_type_code := p_from.value_type_code;
    p_to.data_type_code := p_from.data_type_code;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.seeded_yn := p_from.seeded_yn;
    p_to.function_id := p_from.function_id;
    p_to.source_yn := p_from.source_yn;
    p_to.sql_statement := p_from.sql_statement;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  --------------------------------------------------------------------------------
  -- Procedure migrate  b to v
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from  IN             okl_eccb_rec
                   ,p_to    IN OUT NOCOPY  okl_eccv_rec) IS

  BEGIN
    p_to.crit_cat_def_id := p_from.crit_cat_def_id;
    p_to.ecc_ac_flag := p_from.ecc_ac_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.crit_cat_name := p_from.crit_cat_name;
    p_to.orig_crit_cat_def_id := p_from.orig_crit_cat_def_id;
    p_to.value_type_code := p_from.value_type_code;
    p_to.data_type_code := p_from.data_type_code;
    p_to.enabled_yn := p_from.enabled_yn;
    p_to.seeded_yn := p_from.seeded_yn;
    p_to.function_id := p_from.function_id;
    p_to.source_yn := p_from.source_yn;
    p_to.sql_statement := p_from.sql_statement;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  --------------------------------------------------------------------------------
  -- Procedure migrate  v to tl
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from  IN             okl_eccv_rec
                   ,p_to    IN OUT NOCOPY  okl_ecctl_rec) IS

  BEGIN
    p_to.crit_cat_def_id := p_from.crit_cat_def_id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.crit_cat_desc := p_from.crit_cat_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  --------------------------------------------------------------------------------
  -- Procedure migrate  tl to v
  --------------------------------------------------------------------------------

  PROCEDURE migrate(p_from  IN             okl_ecctl_rec
                   ,p_to    IN OUT NOCOPY  okl_eccv_rec) IS

  BEGIN
    p_to.crit_cat_def_id := p_from.crit_cat_def_id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.crit_cat_desc := p_from.crit_cat_desc;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ------------------------------------
  -- FUNCTION validate_crit_cat_def_id
  ------------------------------------

  FUNCTION validate_crit_cat_def_id(p_crit_cat_def_id  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_crit_cat_def_id';

  BEGIN

    --crit_cat_def_id is required

    IF ((p_crit_cat_def_id IS NULL) OR (p_crit_cat_def_id = g_miss_num)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'crit_cat_def_id');
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
  END validate_crit_cat_def_id;

  -------------------------------------------
  -- Function validate_object_version_number
  -------------------------------------------

  FUNCTION validate_object_version_number(p_object_version_number  IN  number) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_object_version_number';

  BEGIN

    --object_version_number is required

    IF (p_object_version_number IS NULL) OR (p_object_version_number = g_miss_num) THEN
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

  ---------------------------------
  -- FUNCTION validate_name
  ---------------------------------

  FUNCTION validate_name(p_name  IN  varchar2) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_name';

  BEGIN

    --name is required

    IF ((p_name IS NULL) OR (p_name = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'Name');
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
  END validate_name;

  -------------------------------------
  -- FUNCTION validate_value_type_code
  -------------------------------------

  FUNCTION validate_value_type_code(p_value_type_code  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_value_type_code';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    --value_type_code is required

    IF ((p_value_type_code IS NULL) OR (p_value_type_code = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'VALUE_TYPE_CODE');
      RAISE okl_api.g_exception_error;
    END IF;

    --value_type_code should belong to lookup type OKL_ECC_VALUE_TYPE

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_ECC_VALUE_TYPE'
                                                 ,p_lookup_code =>              p_value_type_code);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'VALUE_TYPE_CODE');
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
  END validate_value_type_code;

  ---------------------------------
  -- Function validate_ECC_AC_FLAG
  ---------------------------------

  FUNCTION validate_ecc_ac_flag(p_ecc_ac_flag  IN  varchar2) RETURN varchar2 IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_ecc_ac_flag';

  BEGIN

    --ecc_ac_flag is required

    IF ((p_ecc_ac_flag IS NULL) OR (p_ecc_ac_flag = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ECC_AC_FLAG');
      RAISE okl_api.g_exception_error;
    END IF;

    -- ecc_ac_flag should either be ECC or AC

    IF ( NOT ((p_ecc_ac_flag = 'ECC') OR (p_ecc_ac_flag = 'AC'))) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'ECC_AC_FLAG');
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
  END validate_ecc_ac_flag;

  ------------------------------------
  -- FUNCTION validate_data_type_code
  ------------------------------------

  FUNCTION validate_data_type_code(p_data_type_code  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_data_type_code';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    --data_type_code is required

    IF ((p_data_type_code IS NULL) OR (p_data_type_code = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'DATA_TYPE_CODE');
      RAISE okl_api.g_exception_error;
    END IF;

    --data_type_code should belong to lookup type OKL_ECC_DATA_TYPE

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_ECC_DATA_TYPE'
                                                 ,p_lookup_code =>              p_data_type_code);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'DATA_TYPE_CODE');
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
  END validate_data_type_code;

  ---------------------------------
  -- FUNCTION validate_seeded_yn
  ---------------------------------

  FUNCTION validate_seeded_yn(p_seeded_yn  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_seeded_yn';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    --seeded_yn is required

    IF ((p_seeded_yn IS NULL) OR (p_seeded_yn = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'seeded_yn');
      RAISE okl_api.g_exception_error;
    END IF;

    --seeded_yn should belong to lookup type OKL_YES_NO

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_YES_NO'
                                                 ,p_lookup_code =>              p_seeded_yn);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'seeded_yn');
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
  END validate_seeded_yn;

  ---------------------------------
  -- FUNCTION validate_enabled_yn
  ---------------------------------

  FUNCTION validate_enabled_yn(p_enabled_yn  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_enabled_yn';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    --enabled_yn is required

    IF ((p_enabled_yn IS NULL) OR (p_enabled_yn = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'enabled_yn');
      RAISE okl_api.g_exception_error;
    END IF;

    --enabled_yn should belong to lookup type OKL_YES_NO

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_YES_NO'
                                                 ,p_lookup_code =>              p_enabled_yn);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'enabled_yn');
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
  END validate_enabled_yn;

  ---------------------------------
  -- FUNCTION validate_source_yn
  ---------------------------------

  FUNCTION validate_source_yn(p_source_yn  IN  varchar2) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_source_yn';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN

    --source_yn is required

    IF ((p_source_yn IS NULL) OR (p_source_yn = g_miss_char)) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_required_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'source_yn');
      RAISE okl_api.g_exception_error;
    END IF;

    --source_yn should belong to lookup type OKL_YES_NO

    l_return_status := okl_util.check_lookup_code(p_lookup_type =>              'OKL_YES_NO'
                                                 ,p_lookup_code =>              p_source_yn);

    IF (l_return_status = okl_api.g_ret_sts_error) THEN
      okl_api.set_message(p_app_name     =>             g_app_name
                         ,p_msg_name     =>             g_invalid_value
                         ,p_token1       =>             g_col_name_token
                         ,p_token1_value =>             'source_yn');
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
  END validate_source_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- lock_row for:OKL_FE_CRIT_CAT_DEF_B --
  ---------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_eccb_rec       IN             okl_eccb_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_eccb_rec  IN  okl_eccb_rec) IS
      SELECT        object_version_number
      FROM          okl_fe_crit_cat_def_b
      WHERE         crit_cat_def_id = p_eccb_rec.crit_cat_def_id
                AND object_version_number = p_eccb_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_eccb_rec  IN  okl_eccb_rec) IS
      SELECT object_version_number
      FROM   okl_fe_crit_cat_def_b
      WHERE  crit_cat_def_id = p_eccb_rec.crit_cat_def_id;
    l_api_version            CONSTANT number := 1;
    l_api_name               CONSTANT varchar2(30) := 'B_lock_row';
    l_return_status                   varchar2(1) := okl_api.g_ret_sts_success;
    l_object_version_number           okl_fe_crit_cat_def_b.object_version_number%TYPE;
    lc_object_version_number          okl_fe_crit_cat_def_b.object_version_number%TYPE;
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
      OPEN lock_csr(p_eccb_rec);
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
      OPEN lchk_csr(p_eccb_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number > p_eccb_rec.object_version_number THEN
      okl_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okl_api.g_exception_error;
    ELSIF lc_object_version_number <> p_eccb_rec.object_version_number THEN
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

  ----------------------------------------
  -- lock_row for:OKL_FE_CRIT_CAT_DEF_TL --
  ----------------------------------------

  PROCEDURE lock_row(p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_ecctl_rec      IN             okl_ecctl_rec) IS
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_ecctl_rec  IN  okl_ecctl_rec) IS
      SELECT     *
      FROM       okl_fe_crit_cat_def_tl
      WHERE      crit_cat_def_id = p_ecctl_rec.crit_cat_def_id
      FOR UPDATE NOWAIT;
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'TL_lock_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_lock_var               lock_csr%ROWTYPE;
    l_row_notfound           boolean := false;
    lc_row_notfound          boolean := false;

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
      OPEN lock_csr(p_ecctl_rec);
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

    IF (l_row_notfound) THEN
      okl_api.set_message(g_fnd_app, g_form_record_deleted);
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

  ---------------------------------------
  -- lock_row for:OKL_TXL_AR_INV_LNS_V --
  ---------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_eccv_rec       IN             okl_eccv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'V_lock_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccb_rec               okl_eccb_rec;
    l_ecctl_rec              okl_ecctl_rec;

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

    migrate(p_eccv_rec, l_eccb_rec);
    migrate(p_eccv_rec, l_ecctl_rec);

    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------

    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_eccb_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    lock_row(p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,l_ecctl_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
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

  --------------------------------------
  -- PL/SQL TBL lock_row for:TILV_TBL --
  --------------------------------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_eccv_tbl       IN             okl_eccv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'V_tbl_lock_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;

    -- Begin Post-Generation Change
    -- overall error status

    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

    -- End Post-Generation Change

    i                         number := 0;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eccv_tbl.COUNT > 0) THEN
      i := p_eccv_tbl.FIRST;

      LOOP
        lock_row(p_api_version   =>            p_api_version
                ,p_init_msg_list =>            okl_api.g_false
                ,x_return_status =>            x_return_status
                ,x_msg_count     =>            x_msg_count
                ,x_msg_data      =>            x_msg_data
                ,p_eccv_rec      =>            p_eccv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error

        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;

        -- End Post-Generation Change

        EXIT WHEN(i = p_eccv_tbl.LAST);
        i := p_eccv_tbl.next(i);
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
  -- Procedure get_rec for OKL_FE_CRIT_CAT_DEF_B
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_eccb_rec       IN             okl_eccb_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_eccb_rec IS

    CURSOR eccb_pk_csr(p_id  IN  number) IS
      SELECT crit_cat_def_id
            ,object_version_number
            ,crit_cat_name
            ,ecc_ac_flag
            ,orig_crit_cat_def_id
            ,value_type_code
            ,data_type_code
            ,enabled_yn
            ,seeded_yn
            ,function_id
            ,source_yn
            ,sql_statement
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_crit_cat_def_b
      WHERE  okl_fe_crit_cat_def_b.crit_cat_def_id = p_id;
    l_eccb_pk  eccb_pk_csr%ROWTYPE;
    l_eccb_rec okl_eccb_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN eccb_pk_csr(p_eccb_rec.crit_cat_def_id);
    FETCH eccb_pk_csr INTO l_eccb_rec.crit_cat_def_id
                          ,l_eccb_rec.object_version_number
                          ,l_eccb_rec.crit_cat_name
                          ,l_eccb_rec.ecc_ac_flag
                          ,l_eccb_rec.orig_crit_cat_def_id
                          ,l_eccb_rec.value_type_code
                          ,l_eccb_rec.data_type_code
                          ,l_eccb_rec.enabled_yn
                          ,l_eccb_rec.seeded_yn
                          ,l_eccb_rec.function_id
                          ,l_eccb_rec.source_yn
                          ,l_eccb_rec.sql_statement
                          ,l_eccb_rec.created_by
                          ,l_eccb_rec.creation_date
                          ,l_eccb_rec.last_updated_by
                          ,l_eccb_rec.last_update_date
                          ,l_eccb_rec.last_update_login ;
    x_no_data_found := eccb_pk_csr%NOTFOUND;
    CLOSE eccb_pk_csr;
    RETURN(l_eccb_rec);
  END get_rec;

  FUNCTION get_rec(p_eccb_rec  IN  okl_eccb_rec) RETURN okl_eccb_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_eccb_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_CRIT_CAT_DEF_TL
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_ecctl_rec      IN             okl_ecctl_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_ecctl_rec IS

    CURSOR ecctl_pk_csr(p_id        IN  number
                       ,p_language  IN  varchar2) IS
      SELECT crit_cat_def_id
            ,language
            ,source_lang
            ,sfwt_flag
            ,crit_cat_desc
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_crit_cat_def_tl
      WHERE  okl_fe_crit_cat_def_tl.crit_cat_def_id = p_id
         AND okl_fe_crit_cat_def_tl.language = p_language;
    l_ecctl_pk  ecctl_pk_csr%ROWTYPE;
    l_ecctl_rec okl_ecctl_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN ecctl_pk_csr(p_ecctl_rec.crit_cat_def_id, p_ecctl_rec.language);
    FETCH ecctl_pk_csr INTO l_ecctl_rec.crit_cat_def_id
                           ,l_ecctl_rec.language
                           ,l_ecctl_rec.source_lang
                           ,l_ecctl_rec.sfwt_flag
                           ,l_ecctl_rec.crit_cat_desc
                           ,l_ecctl_rec.created_by
                           ,l_ecctl_rec.creation_date
                           ,l_ecctl_rec.last_updated_by
                           ,l_ecctl_rec.last_update_date
                           ,l_ecctl_rec.last_update_login ;
    x_no_data_found := ecctl_pk_csr%NOTFOUND;
    CLOSE ecctl_pk_csr;
    RETURN(l_ecctl_rec);
  END get_rec;

  FUNCTION get_rec(p_ecctl_rec  IN  okl_ecctl_rec) RETURN okl_ecctl_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_ecctl_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------------------------------
  -- Procedure get_rec for OKL_FE_CRIT_CAT_DEF_V
  --------------------------------------------------------------------------------

  FUNCTION get_rec(p_eccv_rec       IN             okl_eccv_rec
                  ,x_no_data_found     OUT NOCOPY  boolean) RETURN okl_eccv_rec IS

    CURSOR eccv_pk_csr(p_id  IN  number) IS
      SELECT crit_cat_def_id
            ,object_version_number
            ,ecc_ac_flag
            ,orig_crit_cat_def_id
            ,crit_cat_name
            ,crit_cat_desc
            ,sfwt_flag
            ,value_type_code
            ,data_type_code
            ,enabled_yn
            ,seeded_yn
            ,function_id
            ,source_yn
            ,sql_statement
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_crit_cat_def_v
      WHERE  okl_fe_crit_cat_def_v.crit_cat_def_id = p_id;
    l_eccv_pk  eccv_pk_csr%ROWTYPE;
    l_eccv_rec okl_eccv_rec;

  BEGIN
    x_no_data_found := true;

    --Get current data base values

    OPEN eccv_pk_csr(p_eccv_rec.crit_cat_def_id);
    FETCH eccv_pk_csr INTO l_eccv_rec.crit_cat_def_id
                          ,l_eccv_rec.object_version_number
                          ,l_eccv_rec.ecc_ac_flag
                          ,l_eccv_rec.orig_crit_cat_def_id
                          ,l_eccv_rec.crit_cat_name
                          ,l_eccv_rec.crit_cat_desc
                          ,l_eccv_rec.sfwt_flag
                          ,l_eccv_rec.value_type_code
                          ,l_eccv_rec.data_type_code
                          ,l_eccv_rec.enabled_yn
                          ,l_eccv_rec.seeded_yn
                          ,l_eccv_rec.function_id
                          ,l_eccv_rec.source_yn
                          ,l_eccv_rec.sql_statement
                          ,l_eccv_rec.created_by
                          ,l_eccv_rec.creation_date
                          ,l_eccv_rec.last_updated_by
                          ,l_eccv_rec.last_update_date
                          ,l_eccv_rec.last_update_login ;
    x_no_data_found := eccv_pk_csr%NOTFOUND;
    CLOSE eccv_pk_csr;
    RETURN(l_eccv_rec);
  END get_rec;

  FUNCTION get_rec(p_eccv_rec  IN  okl_eccv_rec) RETURN okl_eccv_rec IS
    l_row_notfound boolean := true;

  BEGIN
    RETURN(get_rec(p_eccv_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(p_eccv_rec  IN  okl_eccv_rec) RETURN okl_eccv_rec IS
    l_eccv_rec okl_eccv_rec := p_eccv_rec;

  BEGIN

    IF (l_eccv_rec.crit_cat_def_id = okl_api.g_miss_num) THEN
      l_eccv_rec.crit_cat_def_id := NULL;
    END IF;

    IF (l_eccv_rec.object_version_number = okl_api.g_miss_num) THEN
      l_eccv_rec.object_version_number := NULL;
    END IF;

    IF (l_eccv_rec.ecc_ac_flag = okl_api.g_miss_char) THEN
      l_eccv_rec.ecc_ac_flag := NULL;
    END IF;

    IF (l_eccv_rec.orig_crit_cat_def_id = okl_api.g_miss_num) THEN
      l_eccv_rec.orig_crit_cat_def_id := NULL;
    END IF;

    IF (l_eccv_rec.crit_cat_name = okl_api.g_miss_char) THEN
      l_eccv_rec.crit_cat_name := NULL;
    END IF;

    IF (l_eccv_rec.crit_cat_desc = okl_api.g_miss_char) THEN
      l_eccv_rec.crit_cat_desc := NULL;
    END IF;

    IF (l_eccv_rec.sfwt_flag = okl_api.g_miss_char) THEN
      l_eccv_rec.sfwt_flag := NULL;
    END IF;

    IF (l_eccv_rec.value_type_code = okl_api.g_miss_char) THEN
      l_eccv_rec.value_type_code := NULL;
    END IF;

    IF (l_eccv_rec.data_type_code = okl_api.g_miss_char) THEN
      l_eccv_rec.data_type_code := NULL;
    END IF;

    IF (l_eccv_rec.enabled_yn = okl_api.g_miss_char) THEN
      l_eccv_rec.enabled_yn := NULL;
    END IF;

    IF (l_eccv_rec.seeded_yn = okl_api.g_miss_char) THEN
      l_eccv_rec.seeded_yn := NULL;
    END IF;

    IF (l_eccv_rec.function_id = okl_api.g_miss_num) THEN
      l_eccv_rec.function_id := NULL;
    END IF;

    IF (l_eccv_rec.source_yn = okl_api.g_miss_char) THEN
      l_eccv_rec.source_yn := NULL;
    END IF;

    IF (l_eccv_rec.sql_statement = okl_api.g_miss_char) THEN
      l_eccv_rec.sql_statement := NULL;
    END IF;

    IF (l_eccv_rec.created_by = okl_api.g_miss_num) THEN
      l_eccv_rec.created_by := NULL;
    END IF;

    IF (l_eccv_rec.creation_date = okl_api.g_miss_date) THEN
      l_eccv_rec.creation_date := NULL;
    END IF;

    IF (l_eccv_rec.last_updated_by = okl_api.g_miss_num) THEN
      l_eccv_rec.last_updated_by := NULL;
    END IF;

    IF (l_eccv_rec.last_update_date = okl_api.g_miss_date) THEN
      l_eccv_rec.last_update_date := NULL;
    END IF;

    IF (l_eccv_rec.last_update_login = okl_api.g_miss_num) THEN
      l_eccv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_eccv_rec);
  END null_out_defaults;

  FUNCTION get_seq_id RETURN number IS

  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  -------------------------------------------------------------------------------
  -----validate_attributes
  -------------------------------------------------------------------------------

  FUNCTION validate_attributes(p_eccv_rec  IN  okl_eccv_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN

    -- ***
    -- id
    -- ***

    l_return_status := validate_crit_cat_def_id(p_eccv_rec.crit_cat_def_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- object_version_number
    -- ***

    l_return_status := validate_object_version_number(p_eccv_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- name
    -- ***

    l_return_status := validate_name(p_eccv_rec.crit_cat_name);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- ECC_AC_FLAG
    -- ***

    l_return_status := validate_ecc_ac_flag(p_eccv_rec.ecc_ac_flag);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- VALUE_TYPE_CODE
    -- ***

    l_return_status := validate_value_type_code(p_eccv_rec.value_type_code);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- DATA_TYPE_CODE
    -- ***

    l_return_status := validate_data_type_code(p_eccv_rec.data_type_code);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- seeded_yn
    -- ***

    l_return_status := validate_seeded_yn(p_eccv_rec.seeded_yn);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- enabled_yn
    -- ***

    l_return_status := validate_enabled_yn(p_eccv_rec.enabled_yn);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- source_yn
    -- ***

    l_return_status := validate_source_yn(p_eccv_rec.source_yn);

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

  FUNCTION validate_record(p_eccv_rec  IN  okl_eccv_rec) RETURN varchar2 IS
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    x_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';

  BEGIN
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
                           ,p_token2       =>             g_sqlcode_token
                           ,p_token2_value =>             sqlcode
                           ,p_token3       =>             g_sqlerrm_token
                           ,p_token3_value =>             sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_record;

  --------------------------------------------------------------------------------
  -- Procedure insert_row_b
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccb_rec       IN             okl_eccb_rec
                      ,x_eccb_rec          OUT NOCOPY  okl_eccb_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row_b';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccb_rec               okl_eccb_rec := p_eccb_rec;
    temp                     number;

    FUNCTION set_attributes(p_eccb_rec  IN             okl_eccb_rec
                           ,x_eccb_rec     OUT NOCOPY  okl_eccb_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eccb_rec := p_eccb_rec;
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

    l_return_status := set_attributes(p_eccb_rec, l_eccb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    INSERT INTO okl_fe_crit_cat_def_b
               (crit_cat_def_id
               ,object_version_number
               ,crit_cat_name
               ,ecc_ac_flag
               ,orig_crit_cat_def_id
               ,value_type_code
               ,data_type_code
               ,enabled_yn
               ,seeded_yn
               ,function_id
               ,source_yn
               ,sql_statement
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login)
    VALUES     (l_eccb_rec.crit_cat_def_id
               ,l_eccb_rec.object_version_number
               ,l_eccb_rec.crit_cat_name
               ,l_eccb_rec.ecc_ac_flag
               ,l_eccb_rec.orig_crit_cat_def_id
               ,l_eccb_rec.value_type_code
               ,l_eccb_rec.data_type_code
               ,l_eccb_rec.enabled_yn
               ,l_eccb_rec.seeded_yn
               ,l_eccb_rec.function_id
               ,l_eccb_rec.source_yn
               ,l_eccb_rec.sql_statement
               ,l_eccb_rec.created_by
               ,l_eccb_rec.creation_date
               ,l_eccb_rec.last_updated_by
               ,l_eccb_rec.last_update_date
               ,l_eccb_rec.last_update_login);

    --Set OUT Values

    x_eccb_rec := l_eccb_rec;
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
  -- Procedure insert_row_tl
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecctl_rec      IN             okl_ecctl_rec
                      ,x_ecctl_rec         OUT NOCOPY  okl_ecctl_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'insert_row_tl';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecctl_rec              okl_ecctl_rec := p_ecctl_rec;

    CURSOR get_languages IS
      SELECT *
      FROM   fnd_languages
      WHERE  installed_flag IN('I', 'B');

    FUNCTION set_attributes(p_ecctl_rec  IN             okl_ecctl_rec
                           ,x_ecctl_rec     OUT NOCOPY  okl_ecctl_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecctl_rec := p_ecctl_rec;
      x_ecctl_rec.language := userenv('LANG');
      x_ecctl_rec.source_lang := userenv('LANG');
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

    l_return_status := set_attributes(p_ecctl_rec, l_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    FOR l_lang_rec IN get_languages LOOP
      l_ecctl_rec.language := l_lang_rec.language_code;

      IF l_lang_rec.language_code = userenv('LANG') THEN
        l_ecctl_rec.sfwt_flag := 'N';
      ELSE
        l_ecctl_rec.sfwt_flag := 'Y';
      END IF;

      INSERT INTO okl_fe_crit_cat_def_tl
                 (crit_cat_def_id
                 ,language
                 ,source_lang
                 ,sfwt_flag
                 ,crit_cat_desc
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login)
      VALUES     (l_ecctl_rec.crit_cat_def_id
                 ,l_ecctl_rec.language
                 ,l_ecctl_rec.source_lang
                 ,l_ecctl_rec.sfwt_flag
                 ,l_ecctl_rec.crit_cat_desc
                 ,l_ecctl_rec.created_by
                 ,l_ecctl_rec.creation_date
                 ,l_ecctl_rec.last_updated_by
                 ,l_ecctl_rec.last_update_date
                 ,l_ecctl_rec.last_update_login);

    END LOOP;

    --Set OUT Values

    x_ecctl_rec := l_ecctl_rec;
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
  -- Procedure insert_row_v
  --------------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'v_insert_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccv_rec               okl_eccv_rec;
    l_def_eccv_rec           okl_eccv_rec;
    l_eccb_rec               okl_eccb_rec;
    lx_eccb_rec              okl_eccb_rec;
    l_ecctl_rec              okl_ecctl_rec;
    lx_ecctl_rec             okl_ecctl_rec;

    FUNCTION fill_who_columns(p_eccv_rec  IN  okl_eccv_rec) RETURN okl_eccv_rec IS
      l_eccv_rec okl_eccv_rec := p_eccv_rec;

    BEGIN
      l_eccv_rec.creation_date := sysdate;
      l_eccv_rec.created_by := fnd_global.user_id;
      l_eccv_rec.last_update_date := sysdate;
      l_eccv_rec.last_updated_by := fnd_global.user_id;
      l_eccv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_eccv_rec);
    END fill_who_columns;

    FUNCTION set_attributes(p_eccv_rec  IN             okl_eccv_rec
                           ,x_eccv_rec     OUT NOCOPY  okl_eccv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eccv_rec := p_eccv_rec;
      x_eccv_rec.crit_cat_name := upper(p_eccv_rec.crit_cat_name);
      x_eccv_rec.object_version_number := 1;
      x_eccv_rec.sfwt_flag := 'N';
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

    l_eccv_rec := null_out_defaults(p_eccv_rec);

    -- Set Primary key value

    l_eccv_rec.crit_cat_def_id := get_seq_id;  --Setting Item Attributes
    l_return_status := set_attributes(l_eccv_rec, l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- fill who columns

    l_def_eccv_rec := fill_who_columns(l_def_eccv_rec);

    --validate attributes

    l_return_status := validate_attributes(l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record

    l_return_status := validate_record(l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --migrate v to b

    migrate(l_def_eccv_rec, l_eccb_rec);

    --migrate v to tl

    migrate(l_def_eccv_rec, l_ecctl_rec);

    --call b insert_row

    insert_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_eccb_rec
              ,lx_eccb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --migrate back b to v

    migrate(lx_eccb_rec, l_def_eccv_rec);

    --call tl insert row

    insert_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ecctl_rec
              ,lx_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --migrate back tl to v

    migrate(lx_ecctl_rec, l_def_eccv_rec);

    --Set OUT Values

    x_eccv_rec := l_def_eccv_rec;
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
                      ,p_eccv_tbl       IN             okl_eccv_tbl
                      ,x_eccv_tbl          OUT NOCOPY  okl_eccv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'tbl_insert_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eccv_tbl.COUNT > 0) THEN
      i := p_eccv_tbl.FIRST;

      LOOP
        insert_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eccv_rec      =>            p_eccv_tbl(i)
                  ,x_eccv_rec      =>            x_eccv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eccv_tbl.LAST);
        i := p_eccv_tbl.next(i);
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

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccb_rec       IN             okl_eccb_rec
                      ,x_eccb_rec          OUT NOCOPY  okl_eccb_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row_b';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccb_rec               okl_eccb_rec := p_eccb_rec;
    l_def_eccb_rec           okl_eccb_rec;
    l_row_notfound           boolean := true;

    FUNCTION set_attributes(p_eccb_rec  IN             okl_eccb_rec
                           ,x_eccb_rec     OUT NOCOPY  okl_eccb_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eccb_rec := p_eccb_rec;
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

    l_return_status := set_attributes(p_eccb_rec, l_eccb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_crit_cat_def_b
    SET    crit_cat_def_id = l_eccb_rec.crit_cat_def_id
          ,object_version_number = l_eccb_rec.object_version_number + 1
          ,crit_cat_name = l_eccb_rec.crit_cat_name
          ,ecc_ac_flag = l_eccb_rec.ecc_ac_flag
          ,orig_crit_cat_def_id = l_eccb_rec.orig_crit_cat_def_id
          ,value_type_code = l_eccb_rec.value_type_code
          ,data_type_code = l_eccb_rec.data_type_code
          ,enabled_yn = l_eccb_rec.enabled_yn
          ,seeded_yn = l_eccb_rec.seeded_yn
          ,function_id = l_eccb_rec.function_id
          ,source_yn = l_eccb_rec.source_yn
          ,sql_statement = l_eccb_rec.sql_statement
          ,created_by = l_eccb_rec.created_by
          ,creation_date = l_eccb_rec.creation_date
          ,last_updated_by = l_eccb_rec.last_updated_by
          ,last_update_date = l_eccb_rec.last_update_date
          ,last_update_login = l_eccb_rec.last_update_login
    WHERE  crit_cat_def_id = l_eccb_rec.crit_cat_def_id;

    --Set OUT Values

    x_eccb_rec := l_eccb_rec;
    okl_api.end_activity(x_msg_count, x_msg_data);
    x_return_status := l_return_status;
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

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecctl_rec      IN             okl_ecctl_rec
                      ,x_ecctl_rec         OUT NOCOPY  okl_ecctl_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'update_row_tl';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecctl_rec              okl_ecctl_rec := p_ecctl_rec;
    l_def_ecctl_rec          okl_ecctl_rec;
    l_row_notfound           boolean := true;

    FUNCTION set_attributes(p_ecctl_rec  IN             okl_ecctl_rec
                           ,x_ecctl_rec     OUT NOCOPY  okl_ecctl_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecctl_rec := p_ecctl_rec;
      x_ecctl_rec.language := userenv('LANG');
      x_ecctl_rec.source_lang := userenv('LANG');
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

    l_return_status := set_attributes(p_ecctl_rec, l_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_fe_crit_cat_def_tl
    SET    crit_cat_def_id = l_ecctl_rec.crit_cat_def_id
          ,source_lang = l_ecctl_rec.source_lang
          ,crit_cat_desc = l_ecctl_rec.crit_cat_desc
          ,created_by = l_ecctl_rec.created_by
          ,creation_date = l_ecctl_rec.creation_date
          ,last_updated_by = l_ecctl_rec.last_updated_by
          ,last_update_date = l_ecctl_rec.last_update_date
          ,last_update_login = l_ecctl_rec.last_update_login
    WHERE  crit_cat_def_id = l_ecctl_rec.crit_cat_def_id;

    UPDATE okl_fe_crit_cat_def_tl
    SET    sfwt_flag = 'Y'
    WHERE  crit_cat_def_id = l_ecctl_rec.crit_cat_def_id
       AND source_lang <> userenv('LANG');

    --Set OUT Values

    x_ecctl_rec := l_ecctl_rec;
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
  -- Procedure update_row_v
  --------------------------------------------------------------------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'v_update_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccv_rec               okl_eccv_rec := p_eccv_rec;
    l_def_eccv_rec           okl_eccv_rec;
    lx_def_eccv_rec          okl_eccv_rec;
    l_eccb_rec               okl_eccb_rec;
    lx_eccb_rec              okl_eccb_rec;
    l_ecctl_rec              okl_ecctl_rec;
    lx_ecctl_rec             okl_ecctl_rec;

    FUNCTION fill_who_columns(p_eccv_rec  IN  okl_eccv_rec) RETURN okl_eccv_rec IS
      l_eccv_rec okl_eccv_rec := p_eccv_rec;

    BEGIN
      l_eccv_rec.last_update_date := sysdate;
      l_eccv_rec.last_updated_by := fnd_global.user_id;
      l_eccv_rec.last_update_login := fnd_global.login_id;
      RETURN(l_eccv_rec);
    END fill_who_columns;

    FUNCTION populate_new_record(p_eccv_rec  IN             okl_eccv_rec
                                ,x_eccv_rec     OUT NOCOPY  okl_eccv_rec) RETURN varchar2 IS
      l_eccv_rec      okl_eccv_rec;
      l_row_notfound  boolean := true;
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eccv_rec := p_eccv_rec;

      --Get current database values

      l_eccv_rec := get_rec(p_eccv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := okl_api.g_ret_sts_unexp_error;
      END IF;

      --dont default object_version_number, last_updated_by, last_updat_date  and last_update_login

      IF (x_eccv_rec.crit_cat_def_id IS NULL) THEN
        x_eccv_rec.crit_cat_def_id := l_eccv_rec.crit_cat_def_id;
      END IF;

      IF (x_eccv_rec.ecc_ac_flag IS NULL) THEN
        x_eccv_rec.ecc_ac_flag := l_eccv_rec.ecc_ac_flag;
      END IF;

      IF (x_eccv_rec.orig_crit_cat_def_id IS NULL) THEN
        x_eccv_rec.orig_crit_cat_def_id := l_eccv_rec.orig_crit_cat_def_id;
      END IF;

      IF (x_eccv_rec.crit_cat_name IS NULL) THEN
        x_eccv_rec.crit_cat_name := l_eccv_rec.crit_cat_name;
      END IF;

      IF (x_eccv_rec.crit_cat_desc IS NULL) THEN
        x_eccv_rec.crit_cat_desc := l_eccv_rec.crit_cat_desc;
      END IF;

      IF (x_eccv_rec.sfwt_flag IS NULL) THEN
        x_eccv_rec.sfwt_flag := l_eccv_rec.sfwt_flag;
      END IF;

      IF (x_eccv_rec.value_type_code IS NULL) THEN
        x_eccv_rec.value_type_code := l_eccv_rec.value_type_code;
      END IF;

      IF (x_eccv_rec.data_type_code IS NULL) THEN
        x_eccv_rec.data_type_code := l_eccv_rec.data_type_code;
      END IF;

      IF (x_eccv_rec.enabled_yn IS NULL) THEN
        x_eccv_rec.enabled_yn := l_eccv_rec.enabled_yn;
      END IF;

      IF (x_eccv_rec.seeded_yn IS NULL) THEN
        x_eccv_rec.seeded_yn := l_eccv_rec.seeded_yn;
      END IF;

      IF (x_eccv_rec.function_id IS NULL) THEN
        x_eccv_rec.function_id := l_eccv_rec.function_id;
      END IF;

      IF (x_eccv_rec.source_yn IS NULL) THEN
        x_eccv_rec.source_yn := l_eccv_rec.source_yn;
      END IF;

      IF (x_eccv_rec.sql_statement IS NULL) THEN
        x_eccv_rec.sql_statement := l_eccv_rec.sql_statement;
      END IF;

      IF (x_eccv_rec.created_by IS NULL) THEN
        x_eccv_rec.created_by := l_eccv_rec.created_by;
      END IF;

      IF (x_eccv_rec.creation_date IS NULL) THEN
        x_eccv_rec.creation_date := l_eccv_rec.creation_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;

    FUNCTION set_attributes(p_eccv_rec  IN             okl_eccv_rec
                           ,x_eccv_rec     OUT NOCOPY  okl_eccv_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_eccv_rec := p_eccv_rec;
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

    l_return_status := set_attributes(l_eccv_rec, lx_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --default the unmodified values from the database

    l_return_status := populate_new_record(lx_def_eccv_rec, l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out the G Miss values

    l_def_eccv_rec := null_out_defaults(l_def_eccv_rec);

    --fill who columns

    l_def_eccv_rec := fill_who_columns(l_def_eccv_rec);

    --validate attributes

    l_return_status := validate_attributes(l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --validate record

    l_return_status := validate_record(l_def_eccv_rec);

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
            ,p_eccv_rec      =>            l_def_eccv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --migrate v to b

    migrate(l_def_eccv_rec, l_eccb_rec);

    --migrate v to tl

    migrate(l_def_eccv_rec, l_ecctl_rec);

    --call b update_row

    update_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_eccb_rec
              ,lx_eccb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;  --migrate back b to v
    migrate(lx_eccb_rec, l_def_eccv_rec);

    --call tl update row

    update_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ecctl_rec
              ,lx_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    migrate(lx_ecctl_rec, l_def_eccv_rec);

    --Set OUT Values

    x_eccv_rec := l_def_eccv_rec;
    okl_api.end_activity(x_msg_count, x_msg_data);
    x_return_status := l_return_status;
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
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_tbl       IN             okl_eccv_tbl
                      ,x_eccv_tbl          OUT NOCOPY  okl_eccv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'tbl_update_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eccv_tbl.COUNT > 0) THEN
      i := p_eccv_tbl.FIRST;

      LOOP
        update_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eccv_rec      =>            p_eccv_tbl(i)
                  ,x_eccv_rec      =>            x_eccv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eccv_tbl.LAST);
        i := p_eccv_tbl.next(i);
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

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccb_rec       IN             okl_eccb_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row_b';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccb_rec               okl_eccb_rec := p_eccb_rec;
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

    DELETE FROM okl_fe_crit_cat_def_b
    WHERE       crit_cat_def_id = l_eccb_rec.crit_cat_def_id;
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
  -- Procedure delete_row_tl
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecctl_rec      IN             okl_ecctl_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'delete_row_tl';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_ecctl_rec              okl_ecctl_rec := p_ecctl_rec;
    l_row_notfound           boolean := true;

    FUNCTION set_attributes(p_ecctl_rec  IN             okl_ecctl_rec
                           ,x_ecctl_rec     OUT NOCOPY  okl_ecctl_rec) RETURN varchar2 IS
      l_return_status varchar2(1) := okl_api.g_ret_sts_success;

    BEGIN
      x_ecctl_rec := p_ecctl_rec;
      x_ecctl_rec.language := userenv('LANG');
      x_ecctl_rec.source_lang := userenv('LANG');
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

    l_return_status := set_attributes(p_ecctl_rec, l_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    DELETE FROM okl_fe_crit_cat_def_tl
    WHERE       crit_cat_def_id = l_ecctl_rec.crit_cat_def_id;
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
  -- Procedure delete_row_v
  --------------------------------------------------------------------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec) IS
    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'v_delete_row';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_eccv_rec               okl_eccv_rec := p_eccv_rec;
    l_eccb_rec               okl_eccb_rec;
    l_ecctl_rec              okl_ecctl_rec;

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
    migrate(l_eccv_rec, l_eccb_rec);
    migrate(l_eccv_rec, l_ecctl_rec);
    delete_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_eccb_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    delete_row(p_api_version
              ,p_init_msg_list
              ,l_return_status
              ,x_msg_count
              ,x_msg_data
              ,l_ecctl_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
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
                      ,p_eccv_tbl       IN             okl_eccv_tbl) IS
    l_api_version    CONSTANT number := 1;
    l_api_name       CONSTANT varchar2(30) := 'tbl_delete_row';
    l_return_status           varchar2(1) := okl_api.g_ret_sts_success;
    i                         number := 0;
    l_overall_status          varchar2(1) := okl_api.g_ret_sts_success;

  BEGIN
    okl_api.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_eccv_tbl.COUNT > 0) THEN
      i := p_eccv_tbl.FIRST;

      LOOP
        delete_row(p_api_version   =>            p_api_version
                  ,p_init_msg_list =>            okl_api.g_false
                  ,x_return_status =>            x_return_status
                  ,x_msg_count     =>            x_msg_count
                  ,x_msg_data      =>            x_msg_data
                  ,p_eccv_rec      =>            p_eccv_tbl(i));
        IF x_return_status <> okl_api.g_ret_sts_success THEN
          IF l_overall_status <> okl_api.g_ret_sts_unexp_error THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN(i = p_eccv_tbl.LAST);
        i := p_eccv_tbl.next(i);
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

 -------------------------------------------------------------------------------
  -- Procedure TRANSLATE_ROW
 -------------------------------------------------------------------------------

  PROCEDURE TRANSLATE_ROW(p_eccv_rec IN okl_eccv_rec,
                          p_owner IN VARCHAR2,
                          p_last_update_date IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2) IS
   f_luby    NUMBER;  -- entity owner in file
   f_ludate  DATE;    -- entity update date in file
   db_luby     NUMBER;  -- entity owner in db
   db_ludate   DATE;    -- entity update date in db

   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

     SELECT  LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO  db_luby, db_ludate
      FROM  OKL_FE_CRIT_CAT_DEF_TL
      where crit_cat_def_id  = p_eccv_rec.crit_cat_def_id
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
    	UPDATE OKL_FE_CRIT_CAT_DEF_TL
    	SET
       		CRIT_CAT_DESC     = p_eccv_rec.crit_cat_desc,
       		LAST_UPDATE_DATE  = f_ludate,
       		LAST_UPDATED_BY   = f_luby,
       		LAST_UPDATE_LOGIN = 0,
       		SOURCE_LANG       = USERENV('LANG')
       	WHERE CRIT_CAT_DEF_ID = to_number(p_eccv_rec.crit_cat_def_id)
       	AND USERENV('LANG') IN (language,source_lang);
     END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_eccv_rec IN okl_eccv_rec,
                     p_owner    IN VARCHAR2,
                     p_last_update_date IN VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2) IS
    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db
   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO id, db_luby, db_ludate
      FROM OKL_FE_CRIT_CAT_DEF_B
      where crit_cat_def_id  = p_eccv_rec.crit_cat_def_id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
        UPDATE okl_fe_crit_cat_def_b
        SET crit_cat_def_id = p_eccv_rec.crit_cat_def_id
          ,object_version_number = p_eccv_rec.object_version_number + 1
          ,crit_cat_name = p_eccv_rec.crit_cat_name
          ,ecc_ac_flag = p_eccv_rec.ecc_ac_flag
          ,orig_crit_cat_def_id = p_eccv_rec.orig_crit_cat_def_id
          ,value_type_code = p_eccv_rec.value_type_code
          ,data_type_code = p_eccv_rec.data_type_code
          ,enabled_yn = p_eccv_rec.enabled_yn
          ,seeded_yn = p_eccv_rec.seeded_yn
          ,function_id = p_eccv_rec.function_id
          ,source_yn = p_eccv_rec.source_yn
          ,sql_statement = p_eccv_rec.sql_statement
          ,last_updated_by = f_luby
          ,last_update_date = f_ludate
          ,last_update_login = 0
        WHERE  crit_cat_def_id = p_eccv_rec.crit_cat_def_id;
        --Update _TL
        UPDATE OKL_FE_CRIT_CAT_DEF_TL
        SET
          CRIT_CAT_DESC     = p_eccv_rec.crit_cat_desc,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = USERENV('LANG')
        WHERE CRIT_CAT_DEF_ID = TO_NUMBER(p_eccv_rec.crit_cat_def_id)
          AND USERENV('LANG') IN (language,source_lang);

        if (sql%notfound) then

          INSERT INTO OKL_FE_CRIT_CAT_DEF_TL
           (CRIT_CAT_DEF_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CRIT_CAT_DESC,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
           )
           SELECT
             TO_NUMBER(p_eccv_rec.crit_cat_def_id),
             L.LANGUAGE_CODE,
             USERENV('LANG'),
             decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
             p_eccv_rec.crit_cat_desc,
             f_luby,
             f_ludate,
			 f_luby,
             f_ludate,
			 0
           FROM FND_LANGUAGES L
             WHERE L.INSTALLED_FLAG IN ('I','B')
             AND NOT EXISTS
               (SELECT NULL
                FROM OKL_FE_CRIT_CAT_DEF_TL TL
                WHERE TL.CRIT_CAT_DEF_ID = TO_NUMBER(p_eccv_rec.crit_cat_def_id)
                AND   TL.LANGUAGE = L.LANGUAGE_CODE );
       end if;

     END IF;

    END;
    EXCEPTION
     when no_data_found then
       INSERT INTO okl_fe_crit_cat_def_b
               (crit_cat_def_id
               ,object_version_number
               ,crit_cat_name
               ,ecc_ac_flag
               ,orig_crit_cat_def_id
               ,value_type_code
               ,data_type_code
               ,enabled_yn
               ,seeded_yn
               ,function_id
               ,source_yn
               ,sql_statement
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login)
       VALUES  (p_eccv_rec.crit_cat_def_id
               ,p_eccv_rec.object_version_number
               ,p_eccv_rec.crit_cat_name
               ,p_eccv_rec.ecc_ac_flag
               ,p_eccv_rec.orig_crit_cat_def_id
               ,p_eccv_rec.value_type_code
               ,p_eccv_rec.data_type_code
               ,p_eccv_rec.enabled_yn
               ,p_eccv_rec.seeded_yn
               ,p_eccv_rec.function_id
               ,p_eccv_rec.source_yn
               ,p_eccv_rec.sql_statement
               ,f_luby
               ,f_ludate
               ,f_luby
               ,f_ludate
               ,0);
        --Insert Into TL
        INSERT INTO OKL_FE_CRIT_CAT_DEF_TL
           (CRIT_CAT_DEF_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CRIT_CAT_DESC,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
        )
        SELECT
	    p_eccv_rec.crit_cat_def_id,
        L.LANGUAGE_CODE,
        userenv('LANG'),
        decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
        p_eccv_rec.crit_cat_desc,
        f_luby,
        f_ludate,
        f_luby,
        f_ludate,
        0
        FROM FND_LANGUAGES L
        WHERE L.INSTALLED_FLAG IN ('I','B')
        AND NOT EXISTS
             (SELECT 1
              FROM OKL_FE_CRIT_CAT_DEF_TL TL
              WHERE TL.CRIT_CAT_DEF_ID = TO_NUMBER(p_eccv_rec.crit_cat_def_id)
                AND  TL.LANGUAGE = L.LANGUAGE_CODE);

  END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(p_upload_mode  IN VARCHAR2,
                          p_crit_cat_def_id IN VARCHAR2,
                		  p_object_version_number IN VARCHAR2,
                		  p_ecc_ac_flag IN VARCHAR2,
                		  p_crit_cat_name IN VARCHAR2,
                		  p_orig_crit_cat_def_id IN VARCHAR2,
                		  p_value_type_code IN VARCHAR2,
                		  p_data_type_code IN VARCHAR2,
                		  p_enabled_yn IN VARCHAR2,
                		  p_seeded_yn IN VARCHAR2,
                		  p_function_id IN VARCHAR2,
                		  p_source_yn IN VARCHAR2,
                		  p_sql_statement IN VARCHAR2,
                		  p_trans_crit_cat_desc IN VARCHAR2,
                		  p_owner IN VARCHAR2,
                          p_last_update_date IN VARCHAR2) IS
  l_api_version   CONSTANT number := 1;
  l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
  l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
  l_msg_count              number;
  l_msg_data               varchar2(4000);
  l_init_msg_list          VARCHAR2(1):= 'T';
  l_eccv_rec               okl_eccv_rec;
  BEGIN
  --Prepare Record Structure for Insert/Update
    l_eccv_rec.crit_cat_def_id       := TO_NUMBER(p_crit_cat_def_id);
    l_eccv_rec.object_version_number := TO_NUMBER(p_object_version_number);
    l_eccv_rec.ecc_ac_flag           := p_ecc_ac_flag;
    l_eccv_rec.orig_crit_cat_def_id  := TO_NUMBER(p_orig_crit_cat_def_id);
    l_eccv_rec.crit_cat_name         := p_crit_cat_name;
    l_eccv_rec.crit_cat_desc         := p_trans_crit_cat_desc;
    l_eccv_rec.value_type_code       := p_value_type_code;
    l_eccv_rec.data_type_code        := p_data_type_code;
    l_eccv_rec.enabled_yn            := p_enabled_yn;
    l_eccv_rec.seeded_yn             := p_seeded_yn;
    l_eccv_rec.function_id           := p_function_id;
    l_eccv_rec.source_yn             := p_source_yn;
    l_eccv_rec.sql_statement         := p_sql_statement;
   IF(p_upload_mode = 'NLS') then
	 OKL_ECC_PVT.TRANSLATE_ROW(p_eccv_rec => l_eccv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);
   ELSE
	 OKL_ECC_PVT.LOAD_ROW(p_eccv_rec => l_eccv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);
   END IF;
  END LOAD_SEED_ROW;

END okl_ecc_pvt;


/
