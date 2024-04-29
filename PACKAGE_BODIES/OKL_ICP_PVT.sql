--------------------------------------------------------
--  DDL for Package Body OKL_ICP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ICP_PVT" AS
/* $Header: OKLSICPB.pls 120.3 2005/07/08 07:06:45 smadhava noship $ */

  ----------
  -- get_rec
  ----------
  FUNCTION get_rec (p_id IN         NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2) RETURN icpv_rec_type IS

    l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_rec';

    l_icpv_rec  icpv_rec_type;

  BEGIN

   /* smadhava - Pricing Enhancements - Modified - Start */
    SELECT
      ID,
      OBJECT_VERSION_NUMBER,
      CAT_ID1,
      CAT_ID2,
      TERM_IN_MONTHS,
      RESIDUAL_VALUE_PERCENT,
      ITEM_RESIDUAL_ID,
      STS_CODE,
      VERSION_NUMBER,
      START_DATE,
      END_DATE,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    INTO
      l_icpv_rec.id,
      l_icpv_rec.object_version_number,
      l_icpv_rec.cat_id1,
      l_icpv_rec.cat_id2,
      l_icpv_rec.term_in_months,
      l_icpv_rec.residual_value_percent,
      l_icpv_rec.item_residual_id,
      l_icpv_rec.sts_code,
      l_icpv_rec.version_number,
      l_icpv_rec.start_date,
      l_icpv_rec.end_date,
      l_icpv_rec.created_by,
      l_icpv_rec.creation_date,
      l_icpv_rec.last_updated_by,
      l_icpv_rec.last_update_date,
      l_icpv_rec.last_update_login,
      l_icpv_rec.attribute_category,
      l_icpv_rec.attribute1,
      l_icpv_rec.attribute2,
      l_icpv_rec.attribute3,
      l_icpv_rec.attribute4,
      l_icpv_rec.attribute5,
      l_icpv_rec.attribute6,
      l_icpv_rec.attribute7,
      l_icpv_rec.attribute8,
      l_icpv_rec.attribute9,
      l_icpv_rec.attribute10,
      l_icpv_rec.attribute11,
      l_icpv_rec.attribute12,
      l_icpv_rec.attribute13,
      l_icpv_rec.attribute14,
      l_icpv_rec.attribute15
    FROM okl_itm_cat_rv_prcs_v icpv
    WHERE icpv.id = p_id;
   /* smadhava - Pricing Enhancements - Modified - Start */
    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_icpv_rec;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_LS_RT_FCTR_ENTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (p_icpv_rec   IN icpv_rec_type) RETURN icpv_rec_type IS
    l_icpv_rec                     icpv_rec_type := p_icpv_rec;
  BEGIN
    IF (l_icpv_rec.id = G_MISS_NUM ) THEN
      l_icpv_rec.id := NULL;
    END IF;
    IF (l_icpv_rec.object_version_number = G_MISS_NUM ) THEN
      l_icpv_rec.object_version_number := NULL;
    END IF;
    IF (l_icpv_rec.cat_id1 = G_MISS_NUM ) THEN
      l_icpv_rec.cat_id1 := NULL;
    END IF;
   /* smadhava - Pricing Enhancements - Modified - Start */
    IF (l_icpv_rec.cat_id2 = G_MISS_NUM ) THEN
      l_icpv_rec.cat_id2 := NULL;
    END IF;
   /* smadhava - Pricing Enhancements - Modified - End */
    IF (l_icpv_rec.term_in_months = G_MISS_NUM ) THEN
      l_icpv_rec.term_in_months := NULL;
    END IF;
    IF (l_icpv_rec.residual_value_percent = G_MISS_NUM ) THEN
      l_icpv_rec.residual_value_percent := NULL;
    END IF;
   /* smadhava - Pricing Enhancements - Added - Start */
    IF (l_icpv_rec.item_residual_id = G_MISS_NUM ) THEN
      l_icpv_rec.item_residual_id := NULL;
    END IF;
    IF (l_icpv_rec.sts_code = G_MISS_CHAR ) THEN
      l_icpv_rec.sts_code := NULL;
    END IF;
    IF (l_icpv_rec.version_number = G_MISS_CHAR ) THEN
      l_icpv_rec.version_number := NULL;
    END IF;
   /* smadhava - Pricing Enhancements - Added - End */
    IF (l_icpv_rec.start_date = G_MISS_DATE ) THEN
      l_icpv_rec.start_date := NULL;
    END IF;
    IF (l_icpv_rec.end_date = G_MISS_DATE ) THEN
      l_icpv_rec.end_date := NULL;
    END IF;
    IF (l_icpv_rec.created_by = G_MISS_NUM ) THEN
      l_icpv_rec.created_by := NULL;
    END IF;
    IF (l_icpv_rec.creation_date = G_MISS_DATE ) THEN
      l_icpv_rec.creation_date := NULL;
    END IF;
    IF (l_icpv_rec.last_updated_by = G_MISS_NUM ) THEN
      l_icpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_icpv_rec.last_update_date = G_MISS_DATE ) THEN
      l_icpv_rec.last_update_date := NULL;
    END IF;
    IF (l_icpv_rec.last_update_login = G_MISS_NUM ) THEN
      l_icpv_rec.last_update_login := NULL;
    END IF;
    IF (l_icpv_rec.attribute_category = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute_category := NULL;
    END IF;
    IF (l_icpv_rec.attribute1 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute1 := NULL;
    END IF;
    IF (l_icpv_rec.attribute2 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute2 := NULL;
    END IF;
    IF (l_icpv_rec.attribute3 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute3 := NULL;
    END IF;
    IF (l_icpv_rec.attribute4 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute4 := NULL;
    END IF;
    IF (l_icpv_rec.attribute5 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute5 := NULL;
    END IF;
    IF (l_icpv_rec.attribute6 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute6 := NULL;
    END IF;
    IF (l_icpv_rec.attribute7 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute7 := NULL;
    END IF;
    IF (l_icpv_rec.attribute8 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute8 := NULL;
    END IF;
    IF (l_icpv_rec.attribute9 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute9 := NULL;
    END IF;
    IF (l_icpv_rec.attribute10 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute10 := NULL;
    END IF;
    IF (l_icpv_rec.attribute11 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute11 := NULL;
    END IF;
    IF (l_icpv_rec.attribute12 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute12 := NULL;
    END IF;
    IF (l_icpv_rec.attribute13 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute13 := NULL;
    END IF;
    IF (l_icpv_rec.attribute14 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute14 := NULL;
    END IF;
    IF (l_icpv_rec.attribute15 = G_MISS_CHAR ) THEN
      l_icpv_rec.attribute15 := NULL;
    END IF;
    RETURN(l_icpv_rec);
  END null_out_defaults;


  ---------------------------------
  -- PROCEDURE validate_id
  ---------------------------------
  PROCEDURE validate_id (x_return_status OUT NOCOPY VARCHAR2,
                         p_id            IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_id';

  BEGIN

    IF p_id IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'id');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_id;


  PROCEDURE validate_object_version_number (x_return_status OUT NOCOPY VARCHAR2,
                                            p_object_version_number           IN NUMBER) IS

    l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_object_version_number';

  BEGIN

    IF (p_object_version_number IS NULL) OR (p_object_version_number = G_MISS_NUM) THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'object_version_number');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_object_version_number;


  ---------------------------------
  -- PROCEDURE validate_cat_id1
  ---------------------------------
  PROCEDURE validate_cat_id1 (x_return_status OUT NOCOPY VARCHAR2,
                              p_cat_id1 IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_cat_id1';

  BEGIN

    IF p_cat_id1 IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'cat_id1');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_cat_id1;


  ---------------------------------
  -- PROCEDURE validate_cat_id2
  ---------------------------------
  PROCEDURE validate_cat_id2 (x_return_status OUT NOCOPY VARCHAR2,
                              p_cat_id2 IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_cat_id2';

  BEGIN

    IF p_cat_id2 IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'cat_id2');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_cat_id2;


  ---------------------------------
  -- PROCEDURE validate_term_in_months
  ---------------------------------
  PROCEDURE validate_term_in_months (x_return_status OUT NOCOPY VARCHAR2,
                                     p_term_in_months            IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_term_in_months';

  BEGIN

    IF p_term_in_months IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'term_in_months');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    IF p_term_in_months <= 0 THEN

      OKL_API.set_message(OKL_API.G_APP_NAME, 'OKL_INVALID_TERM');
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    IF TRUNC(p_term_in_months) <> p_term_in_months THEN

      OKL_API.set_message(OKL_API.G_APP_NAME, 'OKL_INVALID_TERM2');
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_term_in_months;


  ---------------------------------
  -- PROCEDURE validate_rv_percent
  ---------------------------------
  PROCEDURE validate_rv_percent (x_return_status          OUT NOCOPY VARCHAR2,
                                             p_residual_value_percent IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_rv_percent';

  BEGIN

    IF p_residual_value_percent IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'residual_value_percent');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    IF p_residual_value_percent < 0 OR p_residual_value_percent >= 100 THEN

      OKL_API.set_message(OKL_API.G_APP_NAME, 'OKL_INVALID_RV');
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_rv_percent;
   /* smadhava - Pricing Enhancements - Added - Start */
 ---------------------------------
  -- PROCEDURE validate_item_residual_id
  ---------------------------------
  PROCEDURE validate_item_residual_id (x_return_status          OUT NOCOPY VARCHAR2,
                             p_item_residual_id                  IN NUMBER) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_item_residual_id';

  BEGIN

    IF p_item_residual_id  IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'item_residual_id');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_item_residual_id;

   ---------------------------------
  -- PROCEDURE validate_sts_code
  ---------------------------------
  PROCEDURE validate_sts_code (x_return_status          OUT NOCOPY VARCHAR2,
                             p_sts_code                IN VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_sts_code';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF p_sts_code  IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'sts_code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     l_return_status := OKL_UTIL.check_lookup_code(
                             p_lookup_type  =>  'OKL_PRC_STATUS',
                             p_lookup_code  =>  p_sts_code);
    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'sts_code');
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_sts_code;

   ---------------------------------
  -- PROCEDURE validate_version_number
  ---------------------------------
  PROCEDURE validate_version_number (x_return_status          OUT NOCOPY VARCHAR2,
                             p_version_number                IN VARCHAR2) IS

    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_version_number';

  BEGIN

    IF p_version_number  IS NULL THEN

      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'version_number');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_version_number;
   /* smadhava - Pricing Enhancements - Added - End */
  ----------------------
  -- validate_attributes
  ----------------------
  FUNCTION Validate_Attributes (p_icpv_rec IN icpv_rec_type) RETURN VARCHAR2 IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_attributes';
    l_return_status                VARCHAR2(1);

  BEGIN

    -- ***
    -- id
    -- ***

    validate_id(l_return_status, p_icpv_rec.id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- object_version_number
    -- ***

    validate_object_version_number (l_return_status, p_icpv_rec.object_version_number);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   /* smadhava - Pricing Enhancements - Modified - Start */
   /*
   Commenting the validations for cat_id1, cat_id2, term_in_months and residual_value_percent
   as these are henceforth deprecated
   */


    -- ***
    -- cat_id1
    -- ***
/*
    validate_cat_id1(l_return_status, p_icpv_rec.cat_id1);
    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
*/
    -- ***
    -- cat_id2
    -- ***
/*
    validate_cat_id2(l_return_status, p_icpv_rec.cat_id2);
    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
*/
    -- ***
    -- term_in_months
    -- ***
/*
    validate_term_in_months(l_return_status, p_icpv_rec.term_in_months);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- ***
    -- residual_value_percent
    -- ***
/*
    validate_rv_percent (l_return_status, p_icpv_rec.residual_value_percent);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
   /* smadhava - Pricing Enhancements - Modified - End */

   /* smadhava - Pricing Enhancements - Added - Start */
    -- ***
    -- item_residual_id
    -- ***

    validate_item_residual_id(l_return_status, p_icpv_rec.item_residual_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- sts_code
    -- ***

    validate_sts_code(l_return_status, p_icpv_rec.sts_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- version_number
    -- ***
    validate_version_number(l_return_status, p_icpv_rec.version_number);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   /* smadhava - Pricing Enhancements - Added - End */

    RETURN G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      RETURN G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR;

  END validate_attributes;


  ------------------
  -- validate_record
  ------------------
  FUNCTION validate_record (p_icpv_rec IN icpv_rec_type) RETURN VARCHAR2 IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_record';

   /* smadhava - Pricing Enhancements - Modified - Start */
    /*
       Commenting to remove the existing validations. The existing validations
       check for overlap of effective from and effective to dates for a particular
       term which is not relevant for this release. This is because the term and
       values are stored in a separate table.
     */
    /*
    CURSOR c_uk_recs IS
      SELECT start_date,
             end_date
      FROM   okl_itm_cat_rv_prcs
      WHERE  cat_id1 = p_icpv_rec.cat_id1
      AND    cat_id2 = p_icpv_rec.cat_id2
      AND    term_in_months = p_icpv_rec.term_in_months
      AND    id <> p_icpv_rec.id
      AND    start_date IS NOT NULL
      ORDER BY start_date;

    l_item_desc                    VARCHAR2(240);
     */
   /* smadhava - Pricing Enhancements - Modified - End */
  BEGIN
   /* smadhava - Pricing Enhancements - Added - Start */

    /* The if condition is modified to check only the effective from date */
--    IF p_icpv_rec.end_date IS NOT NULL AND p_icpv_rec.start_date IS NULL THEN
    IF p_icpv_rec.start_date IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_EFFECTIVE_FROM');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    IF p_icpv_rec.end_date IS NOT NULL AND p_icpv_rec.end_date <> G_MISS_DATE AND p_icpv_rec.end_date < p_icpv_rec.start_date THEN

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_EFFECTIVE_TO');

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;
   /* smadhava - Pricing Enhancements - Added - End */

   /* smadhava - Pricing Enhancements - Modified - Start */
  /*
    --------------------------
    -- check for date overlaps
    --------------------------
    IF p_icpv_rec.start_date IS NOT NULL THEN

      SELECT description
      INTO   l_item_desc
      FROM   mtl_system_items_tl
      WHERE  inventory_item_id = p_icpv_rec.cat_id1
      AND    organization_id = p_icpv_rec.cat_id2
      AND    language = USERENV('LANG');

      FOR l_uk_rec IN c_uk_recs LOOP


        -- Open ended record
        IF l_uk_rec.end_date IS NULL THEN

          IF (p_icpv_rec.end_date >= l_uk_rec.start_date) OR (p_icpv_rec.end_date IS NULL) THEN

            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_ITMRV_EXISTS',
                                p_token1       => 'ITEM_DESC',
                                p_token1_value => l_item_desc,
                                p_token2       => 'TERM',
                                p_token2_value => p_icpv_rec.term_in_months);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;

        -- Finite record
        IF l_uk_rec.end_date IS NOT NULL THEN

          IF p_icpv_rec.end_date BETWEEN l_uk_rec.start_date AND l_uk_rec.end_date THEN

            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_ITMRV_EXISTS',
                                p_token1       => 'ITEM_DESC',
                                p_token1_value => l_item_desc,
                                p_token2       => 'TERM',
                                p_token2_value => p_icpv_rec.term_in_months);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          IF p_icpv_rec.start_date <= l_uk_rec.end_date AND p_icpv_rec.end_date IS NULL THEN

            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_ITMRV_EXISTS',
                                p_token1       => 'ITEM_DESC',
                                p_token1_value => l_item_desc,
                                p_token2       => 'TERM',
                                p_token2_value => p_icpv_rec.term_in_months);

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

        END IF;

      END LOOP;

    END IF;
    */
   /* smadhava - Pricing Enhancements - Modified - End */

    RETURN G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      RETURN G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR;

  END validate_record;


  ---------------------
  -- validate_row (REC)
  ---------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_row (REC)';

    l_return_status                VARCHAR2(1);

  BEGIN

    l_return_status := validate_attributes(p_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(p_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_row;

  ---------------------
  -- validate_row (TBL)
  ---------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_row (TBL)';

    l_return_status                VARCHAR2(1)  :=  G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (p_icpv_tbl.COUNT > 0) THEN

      i := p_icpv_tbl.FIRST;

      LOOP

        IF p_icpv_tbl.EXISTS(i) THEN

          validate_row (p_api_version   => G_API_VERSION,
                        p_init_msg_list => G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_icpv_rec      => p_icpv_tbl(i));

          IF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;

          EXIT WHEN i = p_icpv_tbl.LAST;
          i := p_icpv_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_row;


  -------------------
  -- insert_row (REC)
  -------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type,
    x_icpv_rec                     OUT NOCOPY icpv_rec_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'insert_row (REC)';

    l_return_status                VARCHAR2(1);
    l_icpv_rec                     icpv_rec_type;

  BEGIN

    l_icpv_rec                       := null_out_defaults(p_icpv_rec);

    l_icpv_rec.ID                    := okc_p_util.raw_to_number(sys_guid());
    l_icpv_rec.OBJECT_VERSION_NUMBER := 1;
    l_icpv_rec.CREATION_DATE         := SYSDATE;
    l_icpv_rec.CREATED_BY            := FND_GLOBAL.USER_ID;
    l_icpv_rec.LAST_UPDATE_DATE      := SYSDATE;
    l_icpv_rec.LAST_UPDATED_BY       := FND_GLOBAL.USER_ID;
    l_icpv_rec.LAST_UPDATE_LOGIN     := FND_GLOBAL.LOGIN_ID;

    l_return_status := validate_attributes(l_icpv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := validate_record(l_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   /* smadhava - Pricing Enhancements - Modified- Start */
    INSERT INTO OKL_ITM_CAT_RV_PRCS(
      id,
      object_version_number,
      cat_id1,
      cat_id2,
      term_in_months,
      residual_value_percent,
      item_residual_id,
      sts_code,
      version_number,
      start_date,
      end_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15)
    VALUES (
      l_icpv_rec.id,
      l_icpv_rec.object_version_number,
      l_icpv_rec.cat_id1,
      l_icpv_rec.cat_id2,
      l_icpv_rec.term_in_months,
      l_icpv_rec.residual_value_percent,
      l_icpv_rec.item_residual_id,
      l_icpv_rec.sts_code,
      l_icpv_rec.version_number,
      l_icpv_rec.start_date,
      l_icpv_rec.end_date,
      l_icpv_rec.created_by,
      l_icpv_rec.creation_date,
      l_icpv_rec.last_updated_by,
      l_icpv_rec.last_update_date,
      l_icpv_rec.last_update_login,
      l_icpv_rec.attribute_category,
      l_icpv_rec.attribute1,
      l_icpv_rec.attribute2,
      l_icpv_rec.attribute3,
      l_icpv_rec.attribute4,
      l_icpv_rec.attribute5,
      l_icpv_rec.attribute6,
      l_icpv_rec.attribute7,
      l_icpv_rec.attribute8,
      l_icpv_rec.attribute9,
      l_icpv_rec.attribute10,
      l_icpv_rec.attribute11,
      l_icpv_rec.attribute12,
      l_icpv_rec.attribute13,
      l_icpv_rec.attribute14,
      l_icpv_rec.attribute15);
   /* smadhava - Pricing Enhancements - Added - End */
    x_icpv_rec      := l_icpv_rec;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -------------------
  -- insert_row (TBL)
  -------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type,
    x_icpv_tbl                     OUT NOCOPY icpv_tbl_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'insert_row (TBL)';
    l_return_status                VARCHAR2(1) := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (p_icpv_tbl.COUNT > 0) THEN
      i := p_icpv_tbl.FIRST;
      LOOP
        IF p_icpv_tbl.EXISTS(i) THEN

          insert_row (p_api_version                  => G_API_VERSION,
                      p_init_msg_list                => G_FALSE,
                      x_return_status                => l_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data,
                      p_icpv_rec                     => p_icpv_tbl(i),
                      x_icpv_rec                     => x_icpv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_icpv_tbl.LAST);
          i := p_icpv_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------
  -- lock_row (REC)
  -----------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (REC)';

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_icpv_rec IN icpv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ITM_CAT_RV_PRCS
     WHERE ID = p_icpv_rec.id
       AND OBJECT_VERSION_NUMBER = p_icpv_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_icpv_rec IN icpv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ITM_CAT_RV_PRCS
     WHERE ID = p_icpv_rec.id;

    l_return_status                VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_ITM_CAT_RV_PRCS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_ITM_CAT_RV_PRCS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;

  BEGIN

    BEGIN
      OPEN lock_csr(p_icpv_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_icpv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_icpv_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_icpv_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  -----------------
  -- lock_row (TBL)
  -----------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (p_icpv_tbl.COUNT > 0) THEN

      i := p_icpv_tbl.FIRST;

      LOOP

        IF p_icpv_tbl.EXISTS(i) THEN

          lock_row (p_api_version                  => G_API_VERSION,
                    p_init_msg_list                => G_FALSE,
                    x_return_status                => l_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_icpv_rec                     => p_icpv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_icpv_tbl.LAST);
          i := p_icpv_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  ------------------------------------------
  -- update_row for:OKL_ITM_CAT_RV_PRCS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type,
    x_icpv_rec                     OUT NOCOPY icpv_rec_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_row (_V)';
    l_return_status                VARCHAR2(1);
    l_icpv_rec                     icpv_rec_type := p_icpv_rec;

   /* smadhava - Pricing Enhancements - Modified - Start */
   -- Modifications for G_MISS changes
    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_icpv_rec IN icpv_rec_type,
                                  x_icpv_rec OUT NOCOPY icpv_rec_type) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1);
      l_db_icpv_rec                  icpv_rec_type;

    BEGIN

      x_icpv_rec    := p_icpv_rec;

      l_db_icpv_rec := get_rec(p_icpv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Do NOT default the following 4 standard attributes from the DB
      -- object_version_number
      -- last_update_date
      -- last_update_by
      -- last_update_login
      IF (x_icpv_rec.id IS NULL) THEN
        x_icpv_rec.id := l_db_icpv_rec.id;
      END IF;
      IF (x_icpv_rec.cat_id1 IS NULL) THEN
        x_icpv_rec.cat_id1 := l_db_icpv_rec.cat_id1;
      END IF;
      IF (x_icpv_rec.cat_id2 IS NULL) THEN
        x_icpv_rec.cat_id2 := l_db_icpv_rec.cat_id2;
      END IF;
      IF (x_icpv_rec.term_in_months IS NULL) THEN
        x_icpv_rec.term_in_months := l_db_icpv_rec.term_in_months;
      END IF;
      IF (x_icpv_rec.residual_value_percent IS NULL) THEN
        x_icpv_rec.residual_value_percent := l_db_icpv_rec.residual_value_percent;
      END IF;
      IF (x_icpv_rec.item_residual_id IS NULL) THEN
        x_icpv_rec.item_residual_id := l_db_icpv_rec.item_residual_id;
      END IF;
      IF (x_icpv_rec.sts_code IS NULL) THEN
        x_icpv_rec.sts_code := l_db_icpv_rec.sts_code;
      END IF;
      IF (x_icpv_rec.version_number IS NULL) THEN
        x_icpv_rec.version_number := l_db_icpv_rec.version_number;
      END IF;
      IF (x_icpv_rec.start_date IS NULL) THEN
        x_icpv_rec.start_date := l_db_icpv_rec.start_date;
      END IF;
      IF (x_icpv_rec.end_date IS NULL) THEN
        x_icpv_rec.end_date := l_db_icpv_rec.end_date;
      END IF;
      IF (x_icpv_rec.created_by IS NULL) THEN
        x_icpv_rec.created_by := l_db_icpv_rec.created_by;
      END IF;
      IF (x_icpv_rec.creation_date IS NULL) THEN
        x_icpv_rec.creation_date := l_db_icpv_rec.creation_date;
      END IF;
      IF (x_icpv_rec.attribute_category IS NULL) THEN
        x_icpv_rec.attribute_category := l_db_icpv_rec.attribute_category;
      END IF;
      IF (x_icpv_rec.attribute1 IS NULL) THEN
        x_icpv_rec.attribute1 := l_db_icpv_rec.attribute1;
      END IF;
      IF (x_icpv_rec.attribute2 IS NULL) THEN
        x_icpv_rec.attribute2 := l_db_icpv_rec.attribute2;
      END IF;
      IF (x_icpv_rec.attribute3 IS NULL) THEN
        x_icpv_rec.attribute3 := l_db_icpv_rec.attribute3;
      END IF;
      IF (x_icpv_rec.attribute4 IS NULL) THEN
        x_icpv_rec.attribute4 := l_db_icpv_rec.attribute4;
      END IF;
      IF (x_icpv_rec.attribute5 IS NULL) THEN
        x_icpv_rec.attribute5 := l_db_icpv_rec.attribute5;
      END IF;
      IF (x_icpv_rec.attribute6 IS NULL) THEN
        x_icpv_rec.attribute6 := l_db_icpv_rec.attribute6;
      END IF;
      IF (x_icpv_rec.attribute7 IS NULL) THEN
        x_icpv_rec.attribute7 := l_db_icpv_rec.attribute7;
      END IF;
      IF (x_icpv_rec.attribute8 IS NULL) THEN
        x_icpv_rec.attribute8 := l_db_icpv_rec.attribute8;
      END IF;
      IF (x_icpv_rec.attribute9 IS NULL) THEN
        x_icpv_rec.attribute9 := l_db_icpv_rec.attribute9;
      END IF;
      IF (x_icpv_rec.attribute10 IS NULL) THEN
        x_icpv_rec.attribute10 := l_db_icpv_rec.attribute10;
      END IF;
      IF (x_icpv_rec.attribute11 IS NULL) THEN
        x_icpv_rec.attribute11 := l_db_icpv_rec.attribute11;
      END IF;
      IF (x_icpv_rec.attribute12 IS NULL) THEN
        x_icpv_rec.attribute12 := l_db_icpv_rec.attribute12;
      END IF;
      IF (x_icpv_rec.attribute13 IS NULL) THEN
        x_icpv_rec.attribute13 := l_db_icpv_rec.attribute13;
      END IF;
      IF (x_icpv_rec.attribute14 IS NULL) THEN
        x_icpv_rec.attribute14 := l_db_icpv_rec.attribute14;
      END IF;
      IF (x_icpv_rec.attribute15 IS NULL) THEN
        x_icpv_rec.attribute15 := l_db_icpv_rec.attribute15;
      END IF;

      RETURN l_return_status;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := G_RET_STS_ERROR;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_api_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

    END populate_new_record;
   /* smadhava - Pricing Enhancements - Modified - End */
  BEGIN
    l_return_status := populate_new_record(p_icpv_rec, l_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_icpv_rec := null_out_defaults(l_icpv_rec);

    l_icpv_rec.LAST_UPDATE_DATE  := SYSDATE;
    l_icpv_rec.LAST_UPDATED_BY   := FND_GLOBAL.USER_ID;
    l_icpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

    l_return_status := validate_attributes(l_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lock_row(p_api_version    => G_API_VERSION,
             p_init_msg_list  => G_FALSE,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_icpv_rec       => l_icpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   /* smadhava - Pricing Enhancements - Modified - Start */
    UPDATE OKL_ITM_CAT_RV_PRCS
    SET OBJECT_VERSION_NUMBER = l_icpv_rec.object_version_number+1,
        CAT_ID1 = l_icpv_rec.cat_id1,
        CAT_ID2 = l_icpv_rec.cat_id2,
        TERM_IN_MONTHS = l_icpv_rec.term_in_months,
        RESIDUAL_VALUE_PERCENT = l_icpv_rec.residual_value_percent,
        ITEM_RESIDUAL_ID = l_icpv_rec.item_residual_id,
        STS_CODE = l_icpv_rec.sts_code,
        VERSION_NUMBER = l_icpv_rec.version_number,
        START_DATE = l_icpv_rec.start_date,
        END_DATE = l_icpv_rec.end_date,
        CREATED_BY = l_icpv_rec.created_by,
        CREATION_DATE = l_icpv_rec.creation_date,
        LAST_UPDATED_BY = l_icpv_rec.last_updated_by,
        LAST_UPDATE_DATE = l_icpv_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_icpv_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_icpv_rec.attribute_category,
        ATTRIBUTE1 = l_icpv_rec.attribute1,
        ATTRIBUTE2 = l_icpv_rec.attribute2,
        ATTRIBUTE3 = l_icpv_rec.attribute3,
        ATTRIBUTE4 = l_icpv_rec.attribute4,
        ATTRIBUTE5 = l_icpv_rec.attribute5,
        ATTRIBUTE6 = l_icpv_rec.attribute6,
        ATTRIBUTE7 = l_icpv_rec.attribute7,
        ATTRIBUTE8 = l_icpv_rec.attribute8,
        ATTRIBUTE9 = l_icpv_rec.attribute9,
        ATTRIBUTE10 = l_icpv_rec.attribute10,
        ATTRIBUTE11 = l_icpv_rec.attribute11,
        ATTRIBUTE12 = l_icpv_rec.attribute12,
        ATTRIBUTE13 = l_icpv_rec.attribute13,
        ATTRIBUTE14 = l_icpv_rec.attribute14,
        ATTRIBUTE15 = l_icpv_rec.attribute15
    WHERE ID = l_icpv_rec.id;
   /* smadhava - Pricing Enhancements - Modified - End */
    x_icpv_rec      := l_icpv_rec;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -------------------
  -- update_row (TBL)
  -------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type,
    x_icpv_tbl                     OUT NOCOPY icpv_tbl_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (p_icpv_tbl.COUNT > 0) THEN

      i := p_icpv_tbl.FIRST;

      LOOP

        IF p_icpv_tbl.EXISTS(i) THEN
          update_row (p_api_version                  => G_API_VERSION,
                      p_init_msg_list                => G_FALSE,
                      x_return_status                => l_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data,
                      p_icpv_rec                     => p_icpv_tbl(i),
                      x_icpv_rec                     => x_icpv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_icpv_tbl.LAST);
          i := p_icpv_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -------------------
  -- delete_row (REC)
  -------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_rec                     IN icpv_rec_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'delete_row (REC)';

  BEGIN

    DELETE FROM OKL_ITM_CAT_RV_PRCS WHERE id = p_icpv_rec.id;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;

  -------------------
  -- delete_row (TBL)
  -------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icpv_tbl                     IN icpv_tbl_type) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'delete_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (p_icpv_tbl.COUNT > 0) THEN

      i := p_icpv_tbl.FIRST;

      LOOP

        IF p_icpv_tbl.EXISTS(i) THEN

          delete_row (p_api_version                  => G_API_VERSION,
                      p_init_msg_list                => G_FALSE,
                      x_return_status                => l_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data,
                      p_icpv_rec                     => p_icpv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_icpv_tbl.LAST);
          i := p_icpv_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;

END OKL_icp_PVT;

/
