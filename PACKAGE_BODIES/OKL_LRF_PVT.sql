--------------------------------------------------------
--  DDL for Package Body OKL_LRF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRF_PVT" AS
/* $Header: OKLSLRFB.pls 120.6 2005/07/05 12:34:42 asawanka noship $ */

  ----------
  -- get_rec
  ----------

  FUNCTION get_rec(p_id             IN             number
                  ,x_return_status     OUT NOCOPY  varchar2) RETURN lrfv_rec_type IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'get_rec';
    l_lrfv_rec          lrfv_rec_type;

  BEGIN

    SELECT id
          ,object_version_number
          ,lrt_id
          ,term_in_months
          ,residual_value_percent
          ,interest_rate
          ,lease_rate_factor
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
          ,rate_set_version_id
    INTO   l_lrfv_rec.id
          ,l_lrfv_rec.object_version_number
          ,l_lrfv_rec.lrt_id
          ,l_lrfv_rec.term_in_months
          ,l_lrfv_rec.residual_value_percent
          ,l_lrfv_rec.interest_rate
          ,l_lrfv_rec.lease_rate_factor
          ,l_lrfv_rec.created_by
          ,l_lrfv_rec.creation_date
          ,l_lrfv_rec.last_updated_by
          ,l_lrfv_rec.last_update_date
          ,l_lrfv_rec.last_update_login
          ,l_lrfv_rec.attribute_category
          ,l_lrfv_rec.attribute1
          ,l_lrfv_rec.attribute2
          ,l_lrfv_rec.attribute3
          ,l_lrfv_rec.attribute4
          ,l_lrfv_rec.attribute5
          ,l_lrfv_rec.attribute6
          ,l_lrfv_rec.attribute7
          ,l_lrfv_rec.attribute8
          ,l_lrfv_rec.attribute9
          ,l_lrfv_rec.attribute10
          ,l_lrfv_rec.attribute11
          ,l_lrfv_rec.attribute12
          ,l_lrfv_rec.attribute13
          ,l_lrfv_rec.attribute14
          ,l_lrfv_rec.attribute15
          ,l_lrfv_rec.rate_set_version_id
    FROM   okl_ls_rt_fctr_ents_v lrfv
    WHERE  lrfv.id = p_id;
    x_return_status := g_ret_sts_success;
    RETURN l_lrfv_rec;
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

  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_LS_RT_FCTR_ENTS_V
  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults(p_lrfv_rec  IN  lrfv_rec_type) RETURN lrfv_rec_type IS
    l_lrfv_rec lrfv_rec_type := p_lrfv_rec;

  BEGIN

    IF (l_lrfv_rec.id = g_miss_num) THEN
      l_lrfv_rec.id := NULL;
    END IF;

    IF (l_lrfv_rec.object_version_number = g_miss_num) THEN
      l_lrfv_rec.object_version_number := NULL;
    END IF;

    IF (l_lrfv_rec.lrt_id = g_miss_num) THEN
      l_lrfv_rec.lrt_id := NULL;
    END IF;

    IF (l_lrfv_rec.term_in_months = g_miss_num) THEN
      l_lrfv_rec.term_in_months := NULL;
    END IF;

    IF (l_lrfv_rec.residual_value_percent = g_miss_num) THEN
      l_lrfv_rec.residual_value_percent := NULL;
    END IF;

    IF (l_lrfv_rec.interest_rate = g_miss_num) THEN
      l_lrfv_rec.interest_rate := NULL;
    END IF;

    IF (l_lrfv_rec.lease_rate_factor = g_miss_num) THEN
      l_lrfv_rec.lease_rate_factor := NULL;
    END IF;

    IF (l_lrfv_rec.created_by = g_miss_num) THEN
      l_lrfv_rec.created_by := NULL;
    END IF;

    IF (l_lrfv_rec.creation_date = g_miss_date) THEN
      l_lrfv_rec.creation_date := NULL;
    END IF;

    IF (l_lrfv_rec.last_updated_by = g_miss_num) THEN
      l_lrfv_rec.last_updated_by := NULL;
    END IF;

    IF (l_lrfv_rec.last_update_date = g_miss_date) THEN
      l_lrfv_rec.last_update_date := NULL;
    END IF;

    IF (l_lrfv_rec.last_update_login = g_miss_num) THEN
      l_lrfv_rec.last_update_login := NULL;
    END IF;

    IF (l_lrfv_rec.attribute_category = g_miss_char) THEN
      l_lrfv_rec.attribute_category := NULL;
    END IF;

    IF (l_lrfv_rec.attribute1 = g_miss_char) THEN
      l_lrfv_rec.attribute1 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute2 = g_miss_char) THEN
      l_lrfv_rec.attribute2 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute3 = g_miss_char) THEN
      l_lrfv_rec.attribute3 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute4 = g_miss_char) THEN
      l_lrfv_rec.attribute4 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute5 = g_miss_char) THEN
      l_lrfv_rec.attribute5 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute6 = g_miss_char) THEN
      l_lrfv_rec.attribute6 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute7 = g_miss_char) THEN
      l_lrfv_rec.attribute7 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute8 = g_miss_char) THEN
      l_lrfv_rec.attribute8 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute9 = g_miss_char) THEN
      l_lrfv_rec.attribute9 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute10 = g_miss_char) THEN
      l_lrfv_rec.attribute10 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute11 = g_miss_char) THEN
      l_lrfv_rec.attribute11 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute12 = g_miss_char) THEN
      l_lrfv_rec.attribute12 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute13 = g_miss_char) THEN
      l_lrfv_rec.attribute13 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute14 = g_miss_char) THEN
      l_lrfv_rec.attribute14 := NULL;
    END IF;

    IF (l_lrfv_rec.attribute15 = g_miss_char) THEN
      l_lrfv_rec.attribute15 := NULL;
    END IF;

    IF (l_lrfv_rec.rate_set_version_id = g_miss_num) THEN
      l_lrfv_rec.rate_set_version_id := NULL;
    END IF;

    RETURN(l_lrfv_rec);
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
  -- PROCEDURE validate_lrt_id
  ---------------------------------

  PROCEDURE validate_lrt_id(x_return_status     OUT NOCOPY  varchar2
                           ,p_lrt_id         IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_lrt_id';

    CURSOR c_lrt_id IS
      SELECT 'x'
      FROM   okl_ls_rt_fctr_sets_b
      WHERE  id = p_lrt_id;
    l_dummy varchar2(1);

  BEGIN

    IF p_lrt_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'lrt_id');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_lrt_id;
    FETCH c_lrt_id INTO l_dummy ;
    CLOSE c_lrt_id;

    IF l_dummy IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'lrt_id');
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
  END validate_lrt_id;

  ---------------------------------
  -- PROCEDURE validate_term_in_months
  ---------------------------------

  PROCEDURE validate_term_in_months(x_return_status      OUT NOCOPY  varchar2
                                   ,p_term_in_months  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_term_in_months';

  BEGIN

    IF p_term_in_months IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'term_in_months');
      RAISE okl_api.g_exception_error;
    END IF;

    IF p_term_in_months <= 0 THEN
      okl_api.set_message(okl_api.g_app_name, 'OKL_INVALID_TERM');
      RAISE okl_api.g_exception_error;
    END IF;

    IF trunc(p_term_in_months) <> p_term_in_months THEN
      okl_api.set_message(okl_api.g_app_name, 'OKL_INVALID_TERM2');
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
  END validate_term_in_months;

  ---------------------------------
  -- PROCEDURE validate_rv_percent
  ---------------------------------

  PROCEDURE validate_rv_percent(x_return_status              OUT NOCOPY  varchar2
                               ,p_residual_value_percent  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_rv_percent';

  BEGIN


    IF p_residual_value_percent IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'residual_value_percent');
      RAISE okl_api.g_exception_error;
    END IF;

    IF p_residual_value_percent < 0 OR p_residual_value_percent >= 100 THEN
      okl_api.set_message(okl_api.g_app_name, 'OKL_INVALID_RV');
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
  END validate_rv_percent;

  ---------------------------------
  -- PROCEDURE validate_interest_rate
  ---------------------------------

  PROCEDURE validate_interest_rate(x_return_status     OUT NOCOPY  varchar2
                                  ,p_interest_rate  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_interest_rate';

  BEGIN

    IF p_interest_rate IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'interest_rate');
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
  END validate_interest_rate;

  ---------------------------------
  -- PROCEDURE validate_lease_rate_factor
  ---------------------------------

  PROCEDURE validate_lease_rate_factor (x_return_status         OUT NOCOPY  varchar2
                                       ,p_lease_rate_factor  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_lease_rate_factor';

  BEGIN

    IF p_lease_rate_factor IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'lease_rate_factor');
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
  END validate_lease_rate_factor;

  ------------------------------------------
  -- PROCEDURE validate_rate_set_version_id
  ------------------------------------------

  PROCEDURE validate_rate_set_version_id(x_return_status           OUT NOCOPY  varchar2
                                        ,p_rate_set_version_id  IN             number) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_lrt_id';

    CURSOR c_rate_set_version_id IS
      SELECT 'x'
      FROM   okl_fe_rate_set_versions
      WHERE  rate_set_version_id = p_rate_set_version_id;
    l_dummy varchar2(1);

  BEGIN

    IF p_rate_set_version_id IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_required_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'RATE_SET_VERSION_ID');
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN c_rate_set_version_id;
    FETCH c_rate_set_version_id INTO l_dummy ;
    CLOSE c_rate_set_version_id;

    IF l_dummy IS NULL THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  g_invalid_value
                         ,p_token1       =>  g_col_name_token
                         ,p_token1_value =>  'RATE_SET_VERSION_ID');
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
  END validate_rate_set_version_id;

  ----------------------
  -- validate_attributes
  ----------------------

  FUNCTION validate_attributes(p_lrfv_rec  IN  lrfv_rec_type) RETURN varchar2 IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_attributes';
    l_return_status          varchar2(1);

  BEGIN

    -- ***
    -- id
    -- ***

    validate_id(l_return_status, p_lrfv_rec.id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- object_version_number
    -- ***

    validate_object_version_number(l_return_status
                                  ,p_lrfv_rec.object_version_number);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- lrt_id
    -- ***

    validate_lrt_id(l_return_status, p_lrfv_rec.lrt_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- term_in_months
    -- ***

    validate_term_in_months(l_return_status, p_lrfv_rec.term_in_months);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- residual_value_percent
    -- ***

    validate_rv_percent(l_return_status, p_lrfv_rec.residual_value_percent);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- interest_rate
    -- ***

    validate_interest_rate(l_return_status, p_lrfv_rec.interest_rate);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- lease_rate_factor
    -- ***

    validate_lease_rate_factor (l_return_status
                               ,p_lrfv_rec.lease_rate_factor);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- ***
    -- RATE_SET_VERSION_ID
    -- ***

    validate_rate_set_version_id(l_return_status
                                ,p_lrfv_rec.rate_set_version_id);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
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
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_attributes;

  ------------------
  -- validate_record
  ------------------

  FUNCTION validate_record(p_lrfv_rec  IN  lrfv_rec_type) RETURN varchar2 IS
    l_dummy             varchar2(1);
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_record';

    --asawanka start changed  'lrt_id = p_lrfv_rec.lrt_id' to 'rate_set_version_id=p_lrfv_rec.rate_set_version_id'

    CURSOR c_enforce_uk IS
      SELECT 'x'
      FROM   okl_ls_rt_fctr_ents
      WHERE  rate_set_version_id = p_lrfv_rec.rate_set_version_id  --lrt_id =  p_lrfv_rec.lrt_id
         AND term_in_months = p_lrfv_rec.term_in_months
         AND residual_value_percent = p_lrfv_rec.residual_value_percent
         AND interest_rate = p_lrfv_rec.interest_rate
         AND id <> p_lrfv_rec.id;

  BEGIN
    OPEN c_enforce_uk;
    FETCH c_enforce_uk INTO l_dummy ;
    CLOSE c_enforce_uk;

    IF l_dummy IS NOT NULL THEN
      okl_api.set_message(p_app_name =>  g_app_name
                         ,p_msg_name =>  'OKL_LRF_EXISTS');
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
                           ,p_token2       =>  g_sqlcode_token
                           ,p_token2_value =>  sqlcode
                           ,p_token3       =>  g_sqlerrm_token
                           ,p_token3_value =>  sqlerrm);
        RETURN g_ret_sts_unexp_error;
  END validate_record;

  ---------------------
  -- validate_row (REC)
  ---------------------

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrfv_rec       IN             lrfv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_row (REC)';
    l_return_status          varchar2(1);

  BEGIN
    l_return_status := validate_attributes(p_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(p_lrfv_rec);

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
                        ,p_lrfv_tbl       IN             lrfv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'validate_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrfv_tbl.COUNT > 0) THEN
      i := p_lrfv_tbl.FIRST;

      LOOP
        IF p_lrfv_tbl.EXISTS(i) THEN
          validate_row(p_api_version   =>  g_api_version
                      ,p_init_msg_list =>  g_false
                      ,x_return_status =>  l_return_status
                      ,x_msg_count     =>  x_msg_count
                      ,x_msg_data      =>  x_msg_data
                      ,p_lrfv_rec      =>  p_lrfv_tbl(i));
          IF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          ELSIF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          END IF;
          EXIT WHEN i = p_lrfv_tbl.LAST;
          i := p_lrfv_tbl.next(i);
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

  -------------------
  -- insert_row (REC)
  -------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type
                      ,x_lrfv_rec          OUT NOCOPY  lrfv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (REC)';
    l_return_status          varchar2(1);
    l_lrfv_rec               lrfv_rec_type;

  BEGIN
    l_lrfv_rec := null_out_defaults(p_lrfv_rec);
    l_lrfv_rec.id := okc_p_util.raw_to_number(sys_guid());
    l_lrfv_rec.object_version_number := 1;
    l_lrfv_rec.creation_date := sysdate;
    l_lrfv_rec.created_by := fnd_global.user_id;
    l_lrfv_rec.last_update_date := sysdate;
    l_lrfv_rec.last_updated_by := fnd_global.user_id;
    l_lrfv_rec.last_update_login := fnd_global.login_id;

    l_return_status := validate_attributes(l_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    INSERT INTO okl_ls_rt_fctr_ents
               (id
               ,object_version_number
               ,lrt_id
               ,term_in_months
               ,residual_value_percent
               ,interest_rate
               ,lease_rate_factor
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
               ,rate_set_version_id)
    VALUES     (l_lrfv_rec.id
               ,l_lrfv_rec.object_version_number
               ,l_lrfv_rec.lrt_id
               ,l_lrfv_rec.term_in_months
               ,l_lrfv_rec.residual_value_percent
               ,l_lrfv_rec.interest_rate
               ,l_lrfv_rec.lease_rate_factor
               ,l_lrfv_rec.created_by
               ,l_lrfv_rec.creation_date
               ,l_lrfv_rec.last_updated_by
               ,l_lrfv_rec.last_update_date
               ,l_lrfv_rec.last_update_login
               ,l_lrfv_rec.attribute_category
               ,l_lrfv_rec.attribute1
               ,l_lrfv_rec.attribute2
               ,l_lrfv_rec.attribute3
               ,l_lrfv_rec.attribute4
               ,l_lrfv_rec.attribute5
               ,l_lrfv_rec.attribute6
               ,l_lrfv_rec.attribute7
               ,l_lrfv_rec.attribute8
               ,l_lrfv_rec.attribute9
               ,l_lrfv_rec.attribute10
               ,l_lrfv_rec.attribute11
               ,l_lrfv_rec.attribute12
               ,l_lrfv_rec.attribute13
               ,l_lrfv_rec.attribute14
               ,l_lrfv_rec.attribute15
               ,l_lrfv_rec.rate_set_version_id);

    x_lrfv_rec := l_lrfv_rec;
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
                      ,p_lrfv_tbl       IN             lrfv_tbl_type
                      ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'insert_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrfv_tbl.COUNT > 0) THEN
      i := p_lrfv_tbl.FIRST;

      LOOP
        IF p_lrfv_tbl.EXISTS(i) THEN
          insert_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrfv_rec      =>  p_lrfv_tbl(i)
                    ,x_lrfv_rec      =>  x_lrfv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrfv_tbl.LAST);
          i := p_lrfv_tbl.next(i);
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

  -----------------
  -- lock_row (REC)
  -----------------

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrfv_rec       IN             lrfv_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (REC)';
    e_resource_busy EXCEPTION;

    PRAGMA exception_init(e_resource_busy, - 00054);

    CURSOR lock_csr(p_lrfv_rec  IN  lrfv_rec_type) IS
      SELECT        object_version_number
      FROM          okl_ls_rt_fctr_ents
      WHERE         id = p_lrfv_rec.id
                AND object_version_number = p_lrfv_rec.object_version_number
      FOR UPDATE OF object_version_number NOWAIT;

    CURSOR lchk_csr(p_lrfv_rec  IN  lrfv_rec_type) IS
      SELECT object_version_number
      FROM   okl_ls_rt_fctr_ents
      WHERE  id = p_lrfv_rec.id;
    l_return_status          varchar2(1);
    l_object_version_number  okl_ls_rt_fctr_ents.object_version_number%TYPE;
    lc_object_version_number okl_ls_rt_fctr_ents.object_version_number%TYPE;
    l_row_notfound           boolean := false;
    lc_row_notfound          boolean := false;

  BEGIN

    BEGIN
      OPEN lock_csr(p_lrfv_rec);
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
      OPEN lchk_csr(p_lrfv_rec);
      FETCH lchk_csr INTO lc_object_version_number ;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;

    IF (lc_row_notfound) THEN
      okc_api.set_message(g_fnd_app, g_form_record_deleted);
      RAISE okc_api.g_exception_error;
    ELSIF lc_object_version_number > p_lrfv_rec.object_version_number THEN
      okc_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okc_api.g_exception_error;
    ELSIF lc_object_version_number <> p_lrfv_rec.object_version_number THEN
      okc_api.set_message(g_fnd_app, g_form_record_changed);
      RAISE okc_api.g_exception_error;
    ELSIF lc_object_version_number = - 1 THEN
      okc_api.set_message(g_app_name, g_record_logically_deleted);
      RAISE okc_api.g_exception_error;
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
                    ,p_lrfv_tbl       IN             lrfv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'lock_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrfv_tbl.COUNT > 0) THEN
      i := p_lrfv_tbl.FIRST;

      LOOP
        IF p_lrfv_tbl.EXISTS(i) THEN
          lock_row(p_api_version   =>  g_api_version
                  ,p_init_msg_list =>  g_false
                  ,x_return_status =>  l_return_status
                  ,x_msg_count     =>  x_msg_count
                  ,x_msg_data      =>  x_msg_data
                  ,p_lrfv_rec      =>  p_lrfv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrfv_tbl.LAST);
          i := p_lrfv_tbl.next(i);
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

  ------------------------------------------
  -- update_row for:OKL_LS_RT_FCTR_ENTS_V --
  ------------------------------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type
                      ,x_lrfv_rec          OUT NOCOPY  lrfv_rec_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (_V)';
    l_return_status          varchar2(1);
    l_lrfv_rec               lrfv_rec_type := p_lrfv_rec;

    ----------------------
    -- populate_new_record
    ----------------------

    FUNCTION populate_new_record(p_lrfv_rec  IN             lrfv_rec_type
                                ,x_lrfv_rec     OUT NOCOPY  lrfv_rec_type) RETURN varchar2 IS
      l_return_status varchar2(1);
      l_db_lrfv_rec   lrfv_rec_type;

    BEGIN
      x_lrfv_rec := p_lrfv_rec;
      l_db_lrfv_rec := get_rec(p_lrfv_rec.id, l_return_status);

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

      IF (x_lrfv_rec.id IS NULL) THEN
        x_lrfv_rec.id := l_db_lrfv_rec.id;
      END IF;

      IF (x_lrfv_rec.lrt_id IS NULL) THEN
        x_lrfv_rec.lrt_id := l_db_lrfv_rec.lrt_id;
      END IF;

      IF (x_lrfv_rec.term_in_months IS NULL) THEN
        x_lrfv_rec.term_in_months := l_db_lrfv_rec.term_in_months;
      END IF;

      IF (x_lrfv_rec.residual_value_percent IS NULL) THEN
        x_lrfv_rec.residual_value_percent := l_db_lrfv_rec.residual_value_percent;
      END IF;

      IF (x_lrfv_rec.interest_rate IS NULL) THEN
        x_lrfv_rec.interest_rate := l_db_lrfv_rec.interest_rate;
      END IF;

      IF (x_lrfv_rec.lease_rate_factor IS NULL) THEN
        x_lrfv_rec.lease_rate_factor := l_db_lrfv_rec.lease_rate_factor;
      END IF;

      IF (x_lrfv_rec.created_by IS NULL) THEN
        x_lrfv_rec.created_by := l_db_lrfv_rec.created_by;
      END IF;

      IF (x_lrfv_rec.creation_date IS NULL) THEN
        x_lrfv_rec.creation_date := l_db_lrfv_rec.creation_date;
      END IF;

      IF (x_lrfv_rec.attribute_category IS NULL) THEN
        x_lrfv_rec.attribute_category := l_db_lrfv_rec.attribute_category;
      END IF;

      IF (x_lrfv_rec.attribute1 IS NULL) THEN
        x_lrfv_rec.attribute1 := l_db_lrfv_rec.attribute1;
      END IF;

      IF (x_lrfv_rec.attribute2 IS NULL) THEN
        x_lrfv_rec.attribute2 := l_db_lrfv_rec.attribute2;
      END IF;

      IF (x_lrfv_rec.attribute3 IS NULL) THEN
        x_lrfv_rec.attribute3 := l_db_lrfv_rec.attribute3;
      END IF;

      IF (x_lrfv_rec.attribute4 IS NULL) THEN
        x_lrfv_rec.attribute4 := l_db_lrfv_rec.attribute4;
      END IF;

      IF (x_lrfv_rec.attribute5 IS NULL) THEN
        x_lrfv_rec.attribute5 := l_db_lrfv_rec.attribute5;
      END IF;

      IF (x_lrfv_rec.attribute6 IS NULL) THEN
        x_lrfv_rec.attribute6 := l_db_lrfv_rec.attribute6;
      END IF;

      IF (x_lrfv_rec.attribute7 IS NULL) THEN
        x_lrfv_rec.attribute7 := l_db_lrfv_rec.attribute7;
      END IF;

      IF (x_lrfv_rec.attribute8 IS NULL) THEN
        x_lrfv_rec.attribute8 := l_db_lrfv_rec.attribute8;
      END IF;

      IF (x_lrfv_rec.attribute9 IS NULL) THEN
        x_lrfv_rec.attribute9 := l_db_lrfv_rec.attribute9;
      END IF;

      IF (x_lrfv_rec.attribute10 IS NULL) THEN
        x_lrfv_rec.attribute10 := l_db_lrfv_rec.attribute10;
      END IF;

      IF (x_lrfv_rec.attribute11 IS NULL) THEN
        x_lrfv_rec.attribute11 := l_db_lrfv_rec.attribute11;
      END IF;

      IF (x_lrfv_rec.attribute12 IS NULL) THEN
        x_lrfv_rec.attribute12 := l_db_lrfv_rec.attribute12;
      END IF;

      IF (x_lrfv_rec.attribute13 IS NULL) THEN
        x_lrfv_rec.attribute13 := l_db_lrfv_rec.attribute13;
      END IF;

      IF (x_lrfv_rec.attribute14 IS NULL) THEN
        x_lrfv_rec.attribute14 := l_db_lrfv_rec.attribute14;
      END IF;

      IF (x_lrfv_rec.attribute15 IS NULL) THEN
        x_lrfv_rec.attribute15 := l_db_lrfv_rec.attribute15;
      END IF;

      IF (x_lrfv_rec.rate_set_version_id IS NULL) THEN
        x_lrfv_rec.rate_set_version_id := l_db_lrfv_rec.rate_set_version_id;
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
    l_return_status := populate_new_record(p_lrfv_rec, l_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --null out g miss values

    l_lrfv_rec := null_out_defaults(l_lrfv_rec);
    l_lrfv_rec.last_update_date := sysdate;
    l_lrfv_rec.last_updated_by := fnd_global.user_id;
    l_lrfv_rec.last_update_login := fnd_global.login_id;
    l_return_status := validate_attributes(l_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_return_status := validate_record(l_lrfv_rec);

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
            ,p_lrfv_rec      =>  l_lrfv_rec);

    IF (l_return_status = g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    UPDATE okl_ls_rt_fctr_ents
    SET    object_version_number = l_lrfv_rec.object_version_number + 1
          ,lrt_id = l_lrfv_rec.lrt_id
          ,term_in_months = l_lrfv_rec.term_in_months
          ,residual_value_percent = l_lrfv_rec.residual_value_percent
          ,interest_rate = l_lrfv_rec.interest_rate
          ,lease_rate_factor = l_lrfv_rec.lease_rate_factor
          ,created_by = l_lrfv_rec.created_by
          ,creation_date = l_lrfv_rec.creation_date
          ,last_updated_by = l_lrfv_rec.last_updated_by
          ,last_update_date = l_lrfv_rec.last_update_date
          ,last_update_login = l_lrfv_rec.last_update_login
          ,attribute_category = l_lrfv_rec.attribute_category
          ,attribute1 = l_lrfv_rec.attribute1
          ,attribute2 = l_lrfv_rec.attribute2
          ,attribute3 = l_lrfv_rec.attribute3
          ,attribute4 = l_lrfv_rec.attribute4
          ,attribute5 = l_lrfv_rec.attribute5
          ,attribute6 = l_lrfv_rec.attribute6
          ,attribute7 = l_lrfv_rec.attribute7
          ,attribute8 = l_lrfv_rec.attribute8
          ,attribute9 = l_lrfv_rec.attribute9
          ,attribute10 = l_lrfv_rec.attribute10
          ,attribute11 = l_lrfv_rec.attribute11
          ,attribute12 = l_lrfv_rec.attribute12
          ,attribute13 = l_lrfv_rec.attribute13
          ,attribute14 = l_lrfv_rec.attribute14
          ,attribute15 = l_lrfv_rec.attribute15
          ,rate_set_version_id = l_lrfv_rec.rate_set_version_id
    WHERE  id = l_lrfv_rec.id;
    x_lrfv_rec := l_lrfv_rec;
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

  -------------------
  -- update_row (TBL)
  -------------------

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_tbl       IN             lrfv_tbl_type
                      ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'update_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrfv_tbl.COUNT > 0) THEN
      i := p_lrfv_tbl.FIRST;

      LOOP
        IF p_lrfv_tbl.EXISTS(i) THEN
          update_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrfv_rec      =>  p_lrfv_tbl(i)
                    ,x_lrfv_rec      =>  x_lrfv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrfv_tbl.LAST);
          i := p_lrfv_tbl.next(i);
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

  -------------------
  -- delete_row (REC)
  -------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type) IS
    l_api_name CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (REC)';

  BEGIN

    DELETE FROM okl_ls_rt_fctr_ents
    WHERE       id = p_lrfv_rec.id;
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
  -- delete_row (TBL)
  -------------------

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_tbl       IN             lrfv_tbl_type) IS
    l_api_name      CONSTANT varchar2(61) := g_pkg_name || '.' || 'delete_row (TBL)';
    l_return_status          varchar2(1) := g_ret_sts_success;
    i                        binary_integer;

  BEGIN

    IF (p_lrfv_tbl.COUNT > 0) THEN
      i := p_lrfv_tbl.FIRST;

      LOOP
        IF p_lrfv_tbl.EXISTS(i) THEN
          delete_row(p_api_version   =>  g_api_version
                    ,p_init_msg_list =>  g_false
                    ,x_return_status =>  l_return_status
                    ,x_msg_count     =>  x_msg_count
                    ,x_msg_data      =>  x_msg_data
                    ,p_lrfv_rec      =>  p_lrfv_tbl(i));
          IF l_return_status = g_ret_sts_unexp_error THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF l_return_status = g_ret_sts_error THEN
            RAISE okl_api.g_exception_error;
          END IF;
          EXIT WHEN(i = p_lrfv_tbl.LAST);
          i := p_lrfv_tbl.next(i);
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

END okl_lrf_pvt;

/
