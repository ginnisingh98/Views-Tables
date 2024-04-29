--------------------------------------------------------
--  DDL for Package Body OKL_LPO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LPO_PVT" AS
/* $Header: OKLSLPOB.pls 120.6 2007/08/08 12:47:38 arajagop noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ----------------------------------------
  -- is_unique to check uniqueness of NAME
  ----------------------------------------
  PROCEDURE is_unique (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lpov_rec                      IN lpov_rec_type) IS


    -- Cursor to get khr_id if a contract exists (create mode)
    CURSOR okl_name_csr ( p_lpov_rec IN lpov_rec_type) IS
    SELECT name
    FROM   OKL_LATE_POLICIES_V
    WHERE  name = p_lpov_rec.name
    AND    id <> p_lpov_rec.id;


    l_name OKL_LATE_POLICIES_V.NAME%TYPE;
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Check if value passed for id
    IF (p_lpov_rec.id IS NOT NULL AND p_lpov_rec.id <> OKC_API.G_MISS_NUM) THEN

      OPEN okl_name_csr(p_lpov_rec);
      FETCH okl_name_csr INTO l_name;

      -- id already exists, so update mode
      IF okl_name_csr%FOUND THEN
    	       OKL_API.SET_MESSAGE(  p_app_name  		=> 'OKL'
				      	  	              ,p_msg_name		  => 'OKL_LLA_NOT_UNIQUE'
					    	                  ,p_token1		    => 'COL_NAME'
					   	  	                ,p_token1_value	=> 'Late Policy Name');

      	     -- notify caller of an error
	           l_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;

        END IF;
        CLOSE okl_name_csr;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      IF okl_name_csr%ISOPEN THEN
         CLOSE okl_name_csr;
      END IF;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END is_unique;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_LATE_POLICIES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_LATE_POLICIES_ALL_B B
         WHERE B.ID =T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_LATE_POLICIES_TL T SET(
        --LANGUAGE,
        NAME,
        DESCRIPTION) = (SELECT
                                  --B.LANGUAGE,
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_LATE_POLICIES_TL B
                               WHERE B.ID = T.ID
                               and b.language = t.source_lang)
      WHERE ( T.ID, t.language)
          IN (SELECT
                  SUBT.ID
                  ,subt.language
                FROM OKL_LATE_POLICIES_TL SUBB, OKL_LATE_POLICIES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
               and subb.language = subt.language
                 AND (--SUBB.LANGUAGE <> SUBT.LANGUAGE OR
                       SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.LANGUAGE IS NOT NULL AND SUBT.LANGUAGE IS NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_LATE_POLICIES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        NAME,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.NAME,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_LATE_POLICIES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_LATE_POLICIES_TL T
                     WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_LATE_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lpov_rec                     IN lpov_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lpov_rec_type IS
    CURSOR okl_late_policies_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            NAME,
            DESCRIPTION,
            ISE_ID,
            TDF_ID,
            IDX_ID,
            LATE_POLICY_TYPE_CODE,
            OBJECT_VERSION_NUMBER,
            LATE_CHRG_ALLOWED_YN,
            LATE_CHRG_FIXED_YN,
            LATE_CHRG_AMOUNT,
            LATE_CHRG_RATE,
            LATE_CHRG_GRACE_PERIOD,
            LATE_CHRG_MINIMUM_BALANCE,
            MINIMUM_LATE_CHARGE,
            MAXIMUM_LATE_CHARGE,
            LATE_INT_ALLOWED_YN,
            LATE_INT_FIXED_YN,
            LATE_INT_RATE,
            ADDER_RATE,
            LATE_INT_GRACE_PERIOD,
            LATE_INT_MINIMUM_BALANCE,
            MINIMUM_LATE_INTEREST,
            MAXIMUM_LATE_INTEREST,
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
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            DAYS_IN_YEAR
      FROM Okl_Late_Policies_V
     WHERE okl_late_policies_v.id = p_id;
    l_okl_late_policies_v_pk       okl_late_policies_v_pk_csr%ROWTYPE;
    l_lpov_rec                     lpov_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_late_policies_v_pk_csr (p_lpov_rec.id);
    FETCH okl_late_policies_v_pk_csr INTO
              l_lpov_rec.id,
              l_lpov_rec.org_id,
              l_lpov_rec.name,
              l_lpov_rec.description,
              l_lpov_rec.ise_id,
              l_lpov_rec.tdf_id,
              l_lpov_rec.idx_id,
              l_lpov_rec.late_policy_type_code,
              l_lpov_rec.object_version_number,
              l_lpov_rec.late_chrg_allowed_yn,
              l_lpov_rec.late_chrg_fixed_yn,
              l_lpov_rec.late_chrg_amount,
              l_lpov_rec.late_chrg_rate,
              l_lpov_rec.late_chrg_grace_period,
              l_lpov_rec.late_chrg_minimum_balance,
              l_lpov_rec.minimum_late_charge,
              l_lpov_rec.maximum_late_charge,
              l_lpov_rec.late_int_allowed_yn,
              l_lpov_rec.late_int_fixed_yn,
              l_lpov_rec.late_int_rate,
              l_lpov_rec.adder_rate,
              l_lpov_rec.late_int_grace_period,
              l_lpov_rec.late_int_minimum_balance,
              l_lpov_rec.minimum_late_interest,
              l_lpov_rec.maximum_late_interest,
              l_lpov_rec.attribute_category,
              l_lpov_rec.attribute1,
              l_lpov_rec.attribute2,
              l_lpov_rec.attribute3,
              l_lpov_rec.attribute4,
              l_lpov_rec.attribute5,
              l_lpov_rec.attribute6,
              l_lpov_rec.attribute7,
              l_lpov_rec.attribute8,
              l_lpov_rec.attribute9,
              l_lpov_rec.attribute10,
              l_lpov_rec.attribute11,
              l_lpov_rec.attribute12,
              l_lpov_rec.attribute13,
              l_lpov_rec.attribute14,
              l_lpov_rec.attribute15,
              l_lpov_rec.created_by,
              l_lpov_rec.creation_date,
              l_lpov_rec.last_updated_by,
              l_lpov_rec.last_update_date,
              l_lpov_rec.last_update_login,
              l_lpov_rec.DAYS_IN_YEAR;
    x_no_data_found := okl_late_policies_v_pk_csr%NOTFOUND;
    CLOSE okl_late_policies_v_pk_csr;
    RETURN(l_lpov_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_lpov_rec                     IN lpov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN lpov_rec_type IS
    l_lpov_rec                     lpov_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_lpov_rec := get_rec(p_lpov_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_lpov_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_lpov_rec                     IN lpov_rec_type
  ) RETURN lpov_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lpov_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_LATE_POLICIES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lpo_rec                      IN lpo_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lpo_rec_type IS
    CURSOR okl_late_policies_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            ISE_ID,
            TDF_ID,
            IDX_ID,
            LATE_POLICY_TYPE_CODE,
            OBJECT_VERSION_NUMBER,
            LATE_CHRG_ALLOWED_YN,
            LATE_CHRG_FIXED_YN,
            LATE_CHRG_AMOUNT,
            LATE_CHRG_RATE,
            LATE_CHRG_GRACE_PERIOD,
            LATE_CHRG_MINIMUM_BALANCE,
            MINIMUM_LATE_CHARGE,
            MAXIMUM_LATE_CHARGE,
            LATE_INT_ALLOWED_YN,
            LATE_INT_FIXED_YN,
            LATE_INT_RATE,
            ADDER_RATE,
            LATE_INT_GRACE_PERIOD,
            LATE_INT_MINIMUM_BALANCE,
            MINIMUM_LATE_INTEREST,
            MAXIMUM_LATE_INTEREST,
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
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            days_in_year
      FROM Okl_Late_Policies_B
     WHERE okl_late_policies_b.id = p_id;
    l_okl_late_policies_b_pk       okl_late_policies_b_pk_csr%ROWTYPE;
    l_lpo_rec                      lpo_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_late_policies_b_pk_csr (p_lpo_rec.id);
    FETCH okl_late_policies_b_pk_csr INTO
              l_lpo_rec.id,
              l_lpo_rec.org_id,
              l_lpo_rec.ise_id,
              l_lpo_rec.tdf_id,
              l_lpo_rec.idx_id,
              l_lpo_rec.late_policy_type_code,
              l_lpo_rec.object_version_number,
              l_lpo_rec.late_chrg_allowed_yn,
              l_lpo_rec.late_chrg_fixed_yn,
              l_lpo_rec.late_chrg_amount,
              l_lpo_rec.late_chrg_rate,
              l_lpo_rec.late_chrg_grace_period,
              l_lpo_rec.late_chrg_minimum_balance,
              l_lpo_rec.minimum_late_charge,
              l_lpo_rec.maximum_late_charge,
              l_lpo_rec.late_int_allowed_yn,
              l_lpo_rec.late_int_fixed_yn,
              l_lpo_rec.late_int_rate,
              l_lpo_rec.adder_rate,
              l_lpo_rec.late_int_grace_period,
              l_lpo_rec.late_int_minimum_balance,
              l_lpo_rec.minimum_late_interest,
              l_lpo_rec.maximum_late_interest,
              l_lpo_rec.attribute_category,
              l_lpo_rec.attribute1,
              l_lpo_rec.attribute2,
              l_lpo_rec.attribute3,
              l_lpo_rec.attribute4,
              l_lpo_rec.attribute5,
              l_lpo_rec.attribute6,
              l_lpo_rec.attribute7,
              l_lpo_rec.attribute8,
              l_lpo_rec.attribute9,
              l_lpo_rec.attribute10,
              l_lpo_rec.attribute11,
              l_lpo_rec.attribute12,
              l_lpo_rec.attribute13,
              l_lpo_rec.attribute14,
              l_lpo_rec.attribute15,
              l_lpo_rec.created_by,
              l_lpo_rec.creation_date,
              l_lpo_rec.last_updated_by,
              l_lpo_rec.last_update_date,
              l_lpo_rec.last_update_login,
              l_lpo_rec.days_in_year;
    x_no_data_found := okl_late_policies_b_pk_csr%NOTFOUND;
    CLOSE okl_late_policies_b_pk_csr;
    RETURN(l_lpo_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_lpo_rec                      IN lpo_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN lpo_rec_type IS
    l_lpo_rec                      lpo_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_lpo_rec := get_rec(p_lpo_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_lpo_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_lpo_rec                      IN lpo_rec_type
  ) RETURN lpo_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lpo_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_LATE_POLICIES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_late_policies_tl_rec_type IS
    CURSOR okl_late_policies_tl_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Late_Policies_Tl
     WHERE okl_late_policies_tl.id = p_id;
    l_okl_late_policies_tl_pk      okl_late_policies_tl_pk_csr%ROWTYPE;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_late_policies_tl_pk_csr (p_okl_late_policies_tl_rec.id);
    FETCH okl_late_policies_tl_pk_csr INTO
              l_okl_late_policies_tl_rec.id,
              l_okl_late_policies_tl_rec.LANGUAGE,
              l_okl_late_policies_tl_rec.source_lang,
              l_okl_late_policies_tl_rec.name,
              l_okl_late_policies_tl_rec.description,
              l_okl_late_policies_tl_rec.created_by,
              l_okl_late_policies_tl_rec.creation_date,
              l_okl_late_policies_tl_rec.last_updated_by,
              l_okl_late_policies_tl_rec.last_update_date,
              l_okl_late_policies_tl_rec.last_update_login;
    x_no_data_found := okl_late_policies_tl_pk_csr%NOTFOUND;
    CLOSE okl_late_policies_tl_pk_csr;
    RETURN(l_okl_late_policies_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_late_policies_tl_rec_type IS
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_late_policies_tl_rec := get_rec(p_okl_late_policies_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_late_policies_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type
  ) RETURN okl_late_policies_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_late_policies_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_LATE_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_lpov_rec   IN lpov_rec_type
  ) RETURN lpov_rec_type IS
    l_lpov_rec                     lpov_rec_type := p_lpov_rec;
  BEGIN
    IF (l_lpov_rec.id = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.id := NULL;
    END IF;
    IF (l_lpov_rec.org_id = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.org_id := NULL;
    END IF;
    IF (l_lpov_rec.name = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.name := NULL;
    END IF;
    IF (l_lpov_rec.description = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.description := NULL;
    END IF;
    IF (l_lpov_rec.ise_id = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.ise_id := NULL;
    END IF;
    IF (l_lpov_rec.tdf_id = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.tdf_id := NULL;
    END IF;
    IF (l_lpov_rec.idx_id = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.idx_id := NULL;
    END IF;
    IF (l_lpov_rec.late_policy_type_code = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.late_policy_type_code := NULL;
    END IF;
    IF (l_lpov_rec.object_version_number = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.object_version_number := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_allowed_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.late_chrg_allowed_yn := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_fixed_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.late_chrg_fixed_yn := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_amount = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_chrg_amount := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_rate = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_chrg_rate := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_grace_period = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_chrg_grace_period := NULL;
    END IF;
    IF (l_lpov_rec.late_chrg_minimum_balance = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_chrg_minimum_balance := NULL;
    END IF;
    IF (l_lpov_rec.minimum_late_charge = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.minimum_late_charge := NULL;
    END IF;
    IF (l_lpov_rec.maximum_late_charge = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.maximum_late_charge := NULL;
    END IF;
    IF (l_lpov_rec.late_int_allowed_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.late_int_allowed_yn := NULL;
    END IF;
    IF (l_lpov_rec.late_int_fixed_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.late_int_fixed_yn := NULL;
    END IF;
    IF (l_lpov_rec.late_int_rate = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_int_rate := NULL;
    END IF;
    IF (l_lpov_rec.adder_rate = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.adder_rate := NULL;
    END IF;
    IF (l_lpov_rec.late_int_grace_period = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_int_grace_period := NULL;
    END IF;
    IF (l_lpov_rec.late_int_minimum_balance = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.late_int_minimum_balance := NULL;
    END IF;
    IF (l_lpov_rec.minimum_late_interest = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.minimum_late_interest := NULL;
    END IF;
    IF (l_lpov_rec.maximum_late_interest = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.maximum_late_interest := NULL;
    END IF;
    IF (l_lpov_rec.attribute_category = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute_category := NULL;
    END IF;
    IF (l_lpov_rec.attribute1 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute1 := NULL;
    END IF;
    IF (l_lpov_rec.attribute2 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute2 := NULL;
    END IF;
    IF (l_lpov_rec.attribute3 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute3 := NULL;
    END IF;
    IF (l_lpov_rec.attribute4 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute4 := NULL;
    END IF;
    IF (l_lpov_rec.attribute5 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute5 := NULL;
    END IF;
    IF (l_lpov_rec.attribute6 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute6 := NULL;
    END IF;
    IF (l_lpov_rec.attribute7 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute7 := NULL;
    END IF;
    IF (l_lpov_rec.attribute8 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute8 := NULL;
    END IF;
    IF (l_lpov_rec.attribute9 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute9 := NULL;
    END IF;
    IF (l_lpov_rec.attribute10 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute10 := NULL;
    END IF;
    IF (l_lpov_rec.attribute11 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute11 := NULL;
    END IF;
    IF (l_lpov_rec.attribute12 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute12 := NULL;
    END IF;
    IF (l_lpov_rec.attribute13 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute13 := NULL;
    END IF;
    IF (l_lpov_rec.attribute14 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute14 := NULL;
    END IF;
    IF (l_lpov_rec.attribute15 = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.attribute15 := NULL;
    END IF;
    IF (l_lpov_rec.created_by = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.created_by := NULL;
    END IF;
    IF (l_lpov_rec.creation_date = Okc_Api.G_MISS_DATE ) THEN
      l_lpov_rec.creation_date := NULL;
    END IF;
    IF (l_lpov_rec.last_updated_by = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.last_updated_by := NULL;
    END IF;
    IF (l_lpov_rec.last_update_date = Okc_Api.G_MISS_DATE ) THEN
      l_lpov_rec.last_update_date := NULL;
    END IF;
    IF (l_lpov_rec.last_update_login = Okc_Api.G_MISS_NUM ) THEN
      l_lpov_rec.last_update_login := NULL;
    END IF;
    IF (l_lpov_rec.days_in_year = Okc_Api.G_MISS_CHAR ) THEN
      l_lpov_rec.days_in_year := NULL;
    END IF;
    RETURN(l_lpov_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_LATE_POLICIES_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_lpov_rec                     IN lpov_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    Okc_Util.ADD_VIEW('OKL_LATE_POLICIES_V', x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ** Hand Coded*
    IF p_lpov_rec.id = Okl_Api.G_MISS_NUM OR
       p_lpov_rec.id IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    -- ***
    -- name
    -- ***
    ELSIF p_lpov_rec.name = Okl_Api.G_MISS_CHAR OR
       p_lpov_rec.name IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;

    -- ***
    -- ise_id
    -- ***
    ELSIF p_lpov_rec.ise_id = Okl_Api.G_MISS_NUM OR
       p_lpov_rec.ise_id IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ise_id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    -- ***
    -- late_policy_type_code
    -- ***
    ELSIF p_lpov_rec.late_policy_type_code = Okl_Api.G_MISS_CHAR OR
       p_lpov_rec.late_policy_type_code IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'late_policy_type_code');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    -- ***
    -- object_version_number
    -- ***
    ELSIF p_lpov_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_lpov_rec.object_version_number IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
   END IF;
    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate Record for:OKL_LATE_POLICIES_V --
  ---------------------------------------------
  FUNCTION Validate_Record (p_lpov_rec IN lpov_rec_type)
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- check uniqueness
    is_unique(l_return_status, p_lpov_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN lpov_rec_type,
    p_to   IN OUT NOCOPY lpo_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.ise_id := p_from.ise_id;
    p_to.tdf_id := p_from.tdf_id;
    p_to.idx_id := p_from.idx_id;
    p_to.late_policy_type_code := p_from.late_policy_type_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_chrg_allowed_yn := p_from.late_chrg_allowed_yn;
    p_to.late_chrg_fixed_yn := p_from.late_chrg_fixed_yn;
    p_to.late_chrg_amount := p_from.late_chrg_amount;
    p_to.late_chrg_rate := p_from.late_chrg_rate;
    p_to.late_chrg_grace_period := p_from.late_chrg_grace_period;
    p_to.late_chrg_minimum_balance := p_from.late_chrg_minimum_balance;
    p_to.minimum_late_charge := p_from.minimum_late_charge;
    p_to.maximum_late_charge := p_from.maximum_late_charge;
    p_to.late_int_allowed_yn := p_from.late_int_allowed_yn;
    p_to.late_int_fixed_yn := p_from.late_int_fixed_yn;
    p_to.late_int_rate := p_from.late_int_rate;
    p_to.adder_rate := p_from.adder_rate;
    p_to.late_int_grace_period := p_from.late_int_grace_period;
    p_to.late_int_minimum_balance := p_from.late_int_minimum_balance;
    p_to.minimum_late_interest := p_from.minimum_late_interest;
    p_to.maximum_late_interest := p_from.maximum_late_interest;
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
    p_to.days_in_year := p_from.days_in_year;
  END migrate;
  PROCEDURE migrate (
    p_from IN lpo_rec_type,
    p_to   IN OUT NOCOPY lpov_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.ise_id := p_from.ise_id;
    p_to.tdf_id := p_from.tdf_id;
    p_to.idx_id := p_from.idx_id;
    p_to.late_policy_type_code := p_from.late_policy_type_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_chrg_allowed_yn := p_from.late_chrg_allowed_yn;
    p_to.late_chrg_fixed_yn := p_from.late_chrg_fixed_yn;
    p_to.late_chrg_amount := p_from.late_chrg_amount;
    p_to.late_chrg_rate := p_from.late_chrg_rate;
    p_to.late_chrg_grace_period := p_from.late_chrg_grace_period;
    p_to.late_chrg_minimum_balance := p_from.late_chrg_minimum_balance;
    p_to.minimum_late_charge := p_from.minimum_late_charge;
    p_to.maximum_late_charge := p_from.maximum_late_charge;
    p_to.late_int_allowed_yn := p_from.late_int_allowed_yn;
    p_to.late_int_fixed_yn := p_from.late_int_fixed_yn;
    p_to.late_int_rate := p_from.late_int_rate;
    p_to.adder_rate := p_from.adder_rate;
    p_to.late_int_grace_period := p_from.late_int_grace_period;
    p_to.late_int_minimum_balance := p_from.late_int_minimum_balance;
    p_to.minimum_late_interest := p_from.minimum_late_interest;
    p_to.maximum_late_interest := p_from.maximum_late_interest;
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
    p_to.days_in_year := p_from.days_in_year;
  END migrate;
  PROCEDURE migrate (
    p_from IN lpov_rec_type,
    p_to   IN OUT NOCOPY okl_late_policies_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okl_late_policies_tl_rec_type,
    p_to   IN OUT NOCOPY lpov_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_LATE_POLICIES_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpov_rec                     lpov_rec_type := p_lpov_rec;
    l_lpo_rec                      lpo_rec_type;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_lpov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_lpov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_LATE_POLICIES_V --
  -----------------------------------------------------

  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_LATE_POLICIES_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lpov_tbl.COUNT > 0) THEN
      i := p_lpov_tbl.FIRST;
      LOOP
        validate_row (p_api_version    => p_api_version,
                      p_init_msg_list  => Okc_Api.G_FALSE,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_lpov_rec       => p_lpov_tbl(i));
        EXIT WHEN (i = p_lpov_tbl.LAST);
        i := p_lpov_tbl.NEXT(i);
      END LOOP;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKL_LATE_POLICIES_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpo_rec                      IN lpo_rec_type,
    x_lpo_rec                      OUT NOCOPY lpo_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpo_rec                      lpo_rec_type := p_lpo_rec;
    l_def_lpo_rec                  lpo_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_lpo_rec IN lpo_rec_type,
      x_lpo_rec OUT NOCOPY lpo_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpo_rec := p_lpo_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_lpo_rec,                         -- IN
      l_lpo_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_LATE_POLICIES_B(
      id,
      org_id,
      ise_id,
      tdf_id,
      idx_id,
      late_policy_type_code,
      object_version_number,
      late_chrg_allowed_yn,
      late_chrg_fixed_yn,
      late_chrg_amount,
      late_chrg_rate,
      late_chrg_grace_period,
      late_chrg_minimum_balance,
      minimum_late_charge,
      maximum_late_charge,
      late_int_allowed_yn,
      late_int_fixed_yn,
      late_int_rate,
      adder_rate,
      late_int_grace_period,
      late_int_minimum_balance,
      minimum_late_interest,
      maximum_late_interest,
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
      attribute15,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      days_in_year)
    VALUES (
      l_lpo_rec.id,
      NVL(l_lpo_rec.org_id,MO_GLOBAL.GET_CURRENT_ORG_ID()),
      l_lpo_rec.ise_id,
      l_lpo_rec.tdf_id,
      l_lpo_rec.idx_id,
      l_lpo_rec.late_policy_type_code,
      l_lpo_rec.object_version_number,
      l_lpo_rec.late_chrg_allowed_yn,
      l_lpo_rec.late_chrg_fixed_yn,
      l_lpo_rec.late_chrg_amount,
      l_lpo_rec.late_chrg_rate,
      l_lpo_rec.late_chrg_grace_period,
      l_lpo_rec.late_chrg_minimum_balance,
      l_lpo_rec.minimum_late_charge,
      l_lpo_rec.maximum_late_charge,
      l_lpo_rec.late_int_allowed_yn,
      l_lpo_rec.late_int_fixed_yn,
      l_lpo_rec.late_int_rate,
      l_lpo_rec.adder_rate,
      l_lpo_rec.late_int_grace_period,
      l_lpo_rec.late_int_minimum_balance,
      l_lpo_rec.minimum_late_interest,
      l_lpo_rec.maximum_late_interest,
      l_lpo_rec.attribute_category,
      l_lpo_rec.attribute1,
      l_lpo_rec.attribute2,
      l_lpo_rec.attribute3,
      l_lpo_rec.attribute4,
      l_lpo_rec.attribute5,
      l_lpo_rec.attribute6,
      l_lpo_rec.attribute7,
      l_lpo_rec.attribute8,
      l_lpo_rec.attribute9,
      l_lpo_rec.attribute10,
      l_lpo_rec.attribute11,
      l_lpo_rec.attribute12,
      l_lpo_rec.attribute13,
      l_lpo_rec.attribute14,
      l_lpo_rec.attribute15,
      l_lpo_rec.created_by,
      l_lpo_rec.creation_date,
      l_lpo_rec.last_updated_by,
      l_lpo_rec.last_update_date,
      l_lpo_rec.last_update_login,
      l_lpo_rec.days_in_year);
    -- Set OUT values
    x_lpo_rec := l_lpo_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------
  -- insert_row for:OKL_LATE_POLICIES_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type,
    x_okl_late_policies_tl_rec     OUT NOCOPY okl_late_policies_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type := p_okl_late_policies_tl_rec;
    l_def_okl_late_policies_tl_rec okl_late_policies_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_late_policies_tl_rec IN okl_late_policies_tl_rec_type,
      x_okl_late_policies_tl_rec OUT NOCOPY okl_late_policies_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_late_policies_tl_rec := p_okl_late_policies_tl_rec;
      x_okl_late_policies_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_late_policies_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_late_policies_tl_rec,        -- IN
      l_okl_late_policies_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_late_policies_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_LATE_POLICIES_TL(
        id,
        LANGUAGE,
        source_lang,
        name,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_late_policies_tl_rec.id,
        l_okl_late_policies_tl_rec.LANGUAGE,
        l_okl_late_policies_tl_rec.source_lang,
        l_okl_late_policies_tl_rec.name,
        l_okl_late_policies_tl_rec.description,
        l_okl_late_policies_tl_rec.created_by,
        l_okl_late_policies_tl_rec.creation_date,
        l_okl_late_policies_tl_rec.last_updated_by,
        l_okl_late_policies_tl_rec.last_update_date,
        l_okl_late_policies_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_late_policies_tl_rec := l_okl_late_policies_tl_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------
  -- insert_row for :OKL_LATE_POLICIES_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type,
    x_lpov_rec                     OUT NOCOPY lpov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpov_rec                     lpov_rec_type := p_lpov_rec;
    l_def_lpov_rec                 lpov_rec_type;
    l_lpo_rec                      lpo_rec_type;
    lx_lpo_rec                     lpo_rec_type;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
    lx_okl_late_policies_tl_rec    okl_late_policies_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lpov_rec IN lpov_rec_type
    ) RETURN lpov_rec_type IS
      l_lpov_rec lpov_rec_type := p_lpov_rec;
    BEGIN
      l_lpov_rec.CREATION_DATE := SYSDATE;
      l_lpov_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_lpov_rec.LAST_UPDATE_DATE := l_lpov_rec.CREATION_DATE;
      l_lpov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_lpov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_lpov_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_lpov_rec IN lpov_rec_type,
      x_lpov_rec OUT NOCOPY lpov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpov_rec := p_lpov_rec;
      x_lpov_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_lpov_rec := null_out_defaults(p_lpov_rec);
    -- Set primary key value
    l_lpov_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_lpov_rec,                        -- IN
      l_def_lpov_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_lpov_rec := fill_who_columns(l_def_lpov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lpov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lpov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_lpov_rec, l_lpo_rec);
    migrate(l_def_lpov_rec, l_okl_late_policies_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_lpo_rec,
      lx_lpo_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lpo_rec, l_def_lpov_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_late_policies_tl_rec,
      lx_okl_late_policies_tl_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_late_policies_tl_rec, l_def_lpov_rec);
    -- Set OUT values
    x_lpov_rec := l_def_lpov_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:LPOV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type,
    x_lpov_tbl                     OUT NOCOPY lpov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     i                              NUMBER := 0;
 BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lpov_tbl.COUNT > 0) THEN
      i := p_lpov_tbl.FIRST;
      LOOP
        insert_row (
           p_api_version                  => p_api_version,
           p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_lpov_rec                     => p_lpov_tbl(i),
           x_lpov_rec                     => x_lpov_tbl(i));
        EXIT WHEN (i = p_lpov_tbl.LAST);
        i := p_lpov_tbl.NEXT(i);
      END LOOP;
   END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for:OKL_LATE_POLICIES_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpo_rec                      IN lpo_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_lpo_rec IN lpo_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LATE_POLICIES_B
     WHERE ID = p_lpo_rec.id
       AND OBJECT_VERSION_NUMBER = p_lpo_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_lpo_rec IN lpo_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LATE_POLICIES_B
     WHERE ID = p_lpo_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_LATE_POLICIES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_LATE_POLICIES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_lpo_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_lpo_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_lpo_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_lpo_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- lock_row for:OKL_LATE_POLICIES_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_late_policies_tl_rec IN okl_late_policies_tl_rec_type) IS
    SELECT *
      FROM OKL_LATE_POLICIES_TL
     WHERE ID = p_okl_late_policies_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_late_policies_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- lock_row for: OKL_LATE_POLICIES_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpo_rec                      lpo_rec_type;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_lpov_rec, l_lpo_rec);
    migrate(p_lpov_rec, l_okl_late_policies_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_lpo_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_late_policies_tl_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:LPOV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_lpov_tbl.COUNT > 0) THEN
      i := p_lpov_tbl.FIRST;
      LOOP
         lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lpov_rec                     => p_lpov_tbl(i));
        EXIT WHEN (i = p_lpov_tbl.LAST);
        i := p_lpov_tbl.NEXT(i);
      END LOOP;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- update_row for:OKL_LATE_POLICIES_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpo_rec                      IN lpo_rec_type,
    x_lpo_rec                      OUT NOCOPY lpo_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpo_rec                      lpo_rec_type := p_lpo_rec;
    l_def_lpo_rec                  lpo_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lpo_rec IN lpo_rec_type,
      x_lpo_rec OUT NOCOPY lpo_rec_type
    ) RETURN VARCHAR2 IS
      l_lpo_rec                      lpo_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpo_rec := p_lpo_rec;
      -- Get current database values
      l_lpo_rec := get_rec(p_lpo_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_lpo_rec.id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.id := l_lpo_rec.id;
        END IF;
        IF (x_lpo_rec.org_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.org_id := l_lpo_rec.org_id;
        END IF;
        IF (x_lpo_rec.ise_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.ise_id := l_lpo_rec.ise_id;
        END IF;
        IF (x_lpo_rec.tdf_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.tdf_id := l_lpo_rec.tdf_id;
        END IF;
        IF (x_lpo_rec.idx_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.idx_id := l_lpo_rec.idx_id;
        END IF;
        IF (x_lpo_rec.late_policy_type_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.late_policy_type_code := l_lpo_rec.late_policy_type_code;
        END IF;
        IF (x_lpo_rec.object_version_number = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.object_version_number := l_lpo_rec.object_version_number;
        END IF;
        IF (x_lpo_rec.late_chrg_allowed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.late_chrg_allowed_yn := l_lpo_rec.late_chrg_allowed_yn;
        END IF;
        IF (x_lpo_rec.late_chrg_fixed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.late_chrg_fixed_yn := l_lpo_rec.late_chrg_fixed_yn;
        END IF;
        IF (x_lpo_rec.late_chrg_amount = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_chrg_amount := l_lpo_rec.late_chrg_amount;
        END IF;
        IF (x_lpo_rec.late_chrg_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_chrg_rate := l_lpo_rec.late_chrg_rate;
        END IF;
        IF (x_lpo_rec.late_chrg_grace_period = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_chrg_grace_period := l_lpo_rec.late_chrg_grace_period;
        END IF;
        IF (x_lpo_rec.late_chrg_minimum_balance = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_chrg_minimum_balance := l_lpo_rec.late_chrg_minimum_balance;
        END IF;
        IF (x_lpo_rec.minimum_late_charge = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.minimum_late_charge := l_lpo_rec.minimum_late_charge;
        END IF;
        IF (x_lpo_rec.maximum_late_charge = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.maximum_late_charge := l_lpo_rec.maximum_late_charge;
        END IF;
        IF (x_lpo_rec.late_int_allowed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.late_int_allowed_yn := l_lpo_rec.late_int_allowed_yn;
        END IF;
        IF (x_lpo_rec.late_int_fixed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.late_int_fixed_yn := l_lpo_rec.late_int_fixed_yn;
        END IF;
        IF (x_lpo_rec.late_int_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_int_rate := l_lpo_rec.late_int_rate;
        END IF;
        IF (x_lpo_rec.adder_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.adder_rate := l_lpo_rec.adder_rate;
        END IF;
        IF (x_lpo_rec.late_int_grace_period = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_int_grace_period := l_lpo_rec.late_int_grace_period;
        END IF;
        IF (x_lpo_rec.late_int_minimum_balance = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.late_int_minimum_balance := l_lpo_rec.late_int_minimum_balance;
        END IF;
        IF (x_lpo_rec.minimum_late_interest = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.minimum_late_interest := l_lpo_rec.minimum_late_interest;
        END IF;
        IF (x_lpo_rec.maximum_late_interest = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.maximum_late_interest := l_lpo_rec.maximum_late_interest;
        END IF;
        IF (x_lpo_rec.attribute_category = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute_category := l_lpo_rec.attribute_category;
        END IF;
        IF (x_lpo_rec.attribute1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute1 := l_lpo_rec.attribute1;
        END IF;
        IF (x_lpo_rec.attribute2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute2 := l_lpo_rec.attribute2;
        END IF;
        IF (x_lpo_rec.attribute3 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute3 := l_lpo_rec.attribute3;
        END IF;
        IF (x_lpo_rec.attribute4 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute4 := l_lpo_rec.attribute4;
        END IF;
        IF (x_lpo_rec.attribute5 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute5 := l_lpo_rec.attribute5;
        END IF;
        IF (x_lpo_rec.attribute6 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute6 := l_lpo_rec.attribute6;
        END IF;
        IF (x_lpo_rec.attribute7 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute7 := l_lpo_rec.attribute7;
        END IF;
        IF (x_lpo_rec.attribute8 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute8 := l_lpo_rec.attribute8;
        END IF;
        IF (x_lpo_rec.attribute9 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute9 := l_lpo_rec.attribute9;
        END IF;
        IF (x_lpo_rec.attribute10 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute10 := l_lpo_rec.attribute10;
        END IF;
        IF (x_lpo_rec.attribute11 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute11 := l_lpo_rec.attribute11;
        END IF;
        IF (x_lpo_rec.attribute12 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute12 := l_lpo_rec.attribute12;
        END IF;
        IF (x_lpo_rec.attribute13 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute13 := l_lpo_rec.attribute13;
        END IF;
        IF (x_lpo_rec.attribute14 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute14 := l_lpo_rec.attribute14;
        END IF;
        IF (x_lpo_rec.attribute15 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.attribute15 := l_lpo_rec.attribute15;
        END IF;
        IF (x_lpo_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.created_by := l_lpo_rec.created_by;
        END IF;
        IF (x_lpo_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_lpo_rec.creation_date := l_lpo_rec.creation_date;
        END IF;
        IF (x_lpo_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.last_updated_by := l_lpo_rec.last_updated_by;
        END IF;
        IF (x_lpo_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_lpo_rec.last_update_date := l_lpo_rec.last_update_date;
        END IF;
        IF (x_lpo_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_lpo_rec.last_update_login := l_lpo_rec.last_update_login;
        END IF;
        IF (x_lpo_rec.days_in_year = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpo_rec.days_in_year := l_lpo_rec.days_in_year;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_lpo_rec IN lpo_rec_type,
      x_lpo_rec OUT NOCOPY lpo_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpo_rec := p_lpo_rec;
      x_lpo_rec.OBJECT_VERSION_NUMBER := p_lpo_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_lpo_rec,                         -- IN
      l_lpo_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lpo_rec, l_def_lpo_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_LATE_POLICIES_B
    SET ORG_ID = NVL(l_def_lpo_rec.org_id, MO_GLOBAL.GET_CURRENT_ORG_ID()),
        ISE_ID = l_def_lpo_rec.ise_id,
        TDF_ID = l_def_lpo_rec.tdf_id,
        IDX_ID = l_def_lpo_rec.idx_id,
        LATE_POLICY_TYPE_CODE = l_def_lpo_rec.late_policy_type_code,
        OBJECT_VERSION_NUMBER = l_def_lpo_rec.object_version_number,
        LATE_CHRG_ALLOWED_YN = l_def_lpo_rec.late_chrg_allowed_yn,
        LATE_CHRG_FIXED_YN = l_def_lpo_rec.late_chrg_fixed_yn,
        LATE_CHRG_AMOUNT = l_def_lpo_rec.late_chrg_amount,
        LATE_CHRG_RATE = l_def_lpo_rec.late_chrg_rate,
        LATE_CHRG_GRACE_PERIOD = l_def_lpo_rec.late_chrg_grace_period,
        LATE_CHRG_MINIMUM_BALANCE = l_def_lpo_rec.late_chrg_minimum_balance,
        MINIMUM_LATE_CHARGE = l_def_lpo_rec.minimum_late_charge,
        MAXIMUM_LATE_CHARGE = l_def_lpo_rec.maximum_late_charge,
        LATE_INT_ALLOWED_YN = l_def_lpo_rec.late_int_allowed_yn,
        LATE_INT_FIXED_YN = l_def_lpo_rec.late_int_fixed_yn,
        LATE_INT_RATE = l_def_lpo_rec.late_int_rate,
        ADDER_RATE = l_def_lpo_rec.adder_rate,
        LATE_INT_GRACE_PERIOD = l_def_lpo_rec.late_int_grace_period,
        LATE_INT_MINIMUM_BALANCE = l_def_lpo_rec.late_int_minimum_balance,
        MINIMUM_LATE_INTEREST = l_def_lpo_rec.minimum_late_interest,
        MAXIMUM_LATE_INTEREST = l_def_lpo_rec.maximum_late_interest,
        ATTRIBUTE_CATEGORY = l_def_lpo_rec.attribute_category,
        ATTRIBUTE1 = l_def_lpo_rec.attribute1,
        ATTRIBUTE2 = l_def_lpo_rec.attribute2,
        ATTRIBUTE3 = l_def_lpo_rec.attribute3,
        ATTRIBUTE4 = l_def_lpo_rec.attribute4,
        ATTRIBUTE5 = l_def_lpo_rec.attribute5,
        ATTRIBUTE6 = l_def_lpo_rec.attribute6,
        ATTRIBUTE7 = l_def_lpo_rec.attribute7,
        ATTRIBUTE8 = l_def_lpo_rec.attribute8,
        ATTRIBUTE9 = l_def_lpo_rec.attribute9,
        ATTRIBUTE10 = l_def_lpo_rec.attribute10,
        ATTRIBUTE11 = l_def_lpo_rec.attribute11,
        ATTRIBUTE12 = l_def_lpo_rec.attribute12,
        ATTRIBUTE13 = l_def_lpo_rec.attribute13,
        ATTRIBUTE14 = l_def_lpo_rec.attribute14,
        ATTRIBUTE15 = l_def_lpo_rec.attribute15,
        CREATED_BY = l_def_lpo_rec.created_by,
        CREATION_DATE = l_def_lpo_rec.creation_date,
        LAST_UPDATED_BY = l_def_lpo_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_lpo_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_lpo_rec.last_update_login,
        days_in_year = l_def_lpo_rec.days_in_year
    WHERE ID = l_def_lpo_rec.id;

    x_lpo_rec := l_lpo_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------
  -- update_row for:OKL_LATE_POLICIES_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type,
    x_okl_late_policies_tl_rec     OUT NOCOPY okl_late_policies_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type := p_okl_late_policies_tl_rec;
    l_def_okl_late_policies_tl_rec okl_late_policies_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_late_policies_tl_rec IN okl_late_policies_tl_rec_type,
      x_okl_late_policies_tl_rec OUT NOCOPY okl_late_policies_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_late_policies_tl_rec := p_okl_late_policies_tl_rec;
      -- Get current database values
      l_okl_late_policies_tl_rec := get_rec(p_okl_late_policies_tl_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_okl_late_policies_tl_rec.id = Okc_Api.G_MISS_NUM)
        THEN
          x_okl_late_policies_tl_rec.id := l_okl_late_policies_tl_rec.id;
        END IF;
        IF (x_okl_late_policies_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
        THEN
          x_okl_late_policies_tl_rec.LANGUAGE := l_okl_late_policies_tl_rec.LANGUAGE;
        END IF;
        IF (x_okl_late_policies_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
        THEN
          x_okl_late_policies_tl_rec.source_lang := l_okl_late_policies_tl_rec.source_lang;
        END IF;
        IF (x_okl_late_policies_tl_rec.name = Okc_Api.G_MISS_CHAR)
        THEN
          x_okl_late_policies_tl_rec.name := l_okl_late_policies_tl_rec.name;
        END IF;
        IF (x_okl_late_policies_tl_rec.description = Okc_Api.G_MISS_CHAR)
        THEN
          x_okl_late_policies_tl_rec.description := l_okl_late_policies_tl_rec.description;
        END IF;
        IF (x_okl_late_policies_tl_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_okl_late_policies_tl_rec.created_by := l_okl_late_policies_tl_rec.created_by;
        END IF;
        IF (x_okl_late_policies_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_okl_late_policies_tl_rec.creation_date := l_okl_late_policies_tl_rec.creation_date;
        END IF;
        IF (x_okl_late_policies_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_okl_late_policies_tl_rec.last_updated_by := l_okl_late_policies_tl_rec.last_updated_by;
        END IF;
        IF (x_okl_late_policies_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_okl_late_policies_tl_rec.last_update_date := l_okl_late_policies_tl_rec.last_update_date;
        END IF;
        IF (x_okl_late_policies_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_okl_late_policies_tl_rec.last_update_login := l_okl_late_policies_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_late_policies_tl_rec IN okl_late_policies_tl_rec_type,
      x_okl_late_policies_tl_rec OUT NOCOPY okl_late_policies_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_late_policies_tl_rec := p_okl_late_policies_tl_rec;
      x_okl_late_policies_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_late_policies_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_late_policies_tl_rec,        -- IN
      l_okl_late_policies_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_late_policies_tl_rec, l_def_okl_late_policies_tl_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_LATE_POLICIES_TL
    SET NAME = l_def_okl_late_policies_tl_rec.name,
        DESCRIPTION = l_def_okl_late_policies_tl_rec.description,
        CREATED_BY = l_def_okl_late_policies_tl_rec.created_by,
        CREATION_DATE = l_def_okl_late_policies_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_late_policies_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_late_policies_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_late_policies_tl_rec.last_update_login
    WHERE ID = l_def_okl_late_policies_tl_rec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

/*    UPDATE OKL_LATE_POLICIES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_late_policies_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');
*/
    x_okl_late_policies_tl_rec := l_okl_late_policies_tl_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- update_row for:OKL_LATE_POLICIES_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type,
    x_lpov_rec                     OUT NOCOPY lpov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpov_rec                     lpov_rec_type := p_lpov_rec;
    l_def_lpov_rec                 lpov_rec_type;
    l_db_lpov_rec                  lpov_rec_type;
    l_lpo_rec                      lpo_rec_type;
    lx_lpo_rec                     lpo_rec_type;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
    lx_okl_late_policies_tl_rec    okl_late_policies_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lpov_rec IN lpov_rec_type
    ) RETURN lpov_rec_type IS
      l_lpov_rec lpov_rec_type := p_lpov_rec;
    BEGIN
      l_lpov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lpov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_lpov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_lpov_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lpov_rec IN lpov_rec_type,
      x_lpov_rec OUT NOCOPY lpov_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpov_rec := p_lpov_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_lpov_rec := get_rec(p_lpov_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_lpov_rec.id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.id := l_db_lpov_rec.id;
        END IF;
        IF (x_lpov_rec.org_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.org_id := l_db_lpov_rec.org_id;
        END IF;
        IF (x_lpov_rec.object_version_number = Okl_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.object_version_number := l_db_lpov_rec.object_version_number;
        END IF;
        IF (x_lpov_rec.name = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.name := l_db_lpov_rec.name;
        END IF;
        IF (x_lpov_rec.description = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.description := l_db_lpov_rec.description;
        END IF;
        IF (x_lpov_rec.ise_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.ise_id := l_db_lpov_rec.ise_id;
        END IF;
        IF (x_lpov_rec.tdf_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.tdf_id := l_db_lpov_rec.tdf_id;
        END IF;
        IF (x_lpov_rec.idx_id = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.idx_id := l_db_lpov_rec.idx_id;
        END IF;
        IF (x_lpov_rec.late_policy_type_code = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.late_policy_type_code := l_db_lpov_rec.late_policy_type_code;
        END IF;
        IF (x_lpov_rec.late_chrg_allowed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.late_chrg_allowed_yn := l_db_lpov_rec.late_chrg_allowed_yn;
        END IF;
        IF (x_lpov_rec.late_chrg_fixed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.late_chrg_fixed_yn := l_db_lpov_rec.late_chrg_fixed_yn;
        END IF;
        IF (x_lpov_rec.late_chrg_amount = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_chrg_amount := l_db_lpov_rec.late_chrg_amount;
        END IF;
        IF (x_lpov_rec.late_chrg_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_chrg_rate := l_db_lpov_rec.late_chrg_rate;
        END IF;
        IF (x_lpov_rec.late_chrg_grace_period = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_chrg_grace_period := l_db_lpov_rec.late_chrg_grace_period;
        END IF;
        IF (x_lpov_rec.late_chrg_minimum_balance = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_chrg_minimum_balance := l_db_lpov_rec.late_chrg_minimum_balance;
        END IF;
        IF (x_lpov_rec.minimum_late_charge = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.minimum_late_charge := l_db_lpov_rec.minimum_late_charge;
        END IF;
        IF (x_lpov_rec.maximum_late_charge = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.maximum_late_charge := l_db_lpov_rec.maximum_late_charge;
        END IF;
        IF (x_lpov_rec.late_int_allowed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.late_int_allowed_yn := l_db_lpov_rec.late_int_allowed_yn;
        END IF;
        IF (x_lpov_rec.late_int_fixed_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.late_int_fixed_yn := l_db_lpov_rec.late_int_fixed_yn;
        END IF;
        IF (x_lpov_rec.late_int_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_int_rate := l_db_lpov_rec.late_int_rate;
        END IF;
        IF (x_lpov_rec.adder_rate = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.adder_rate := l_db_lpov_rec.adder_rate;
        END IF;
        IF (x_lpov_rec.late_int_grace_period = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_int_grace_period := l_db_lpov_rec.late_int_grace_period;
        END IF;
        IF (x_lpov_rec.late_int_minimum_balance = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.late_int_minimum_balance := l_db_lpov_rec.late_int_minimum_balance;
        END IF;
        IF (x_lpov_rec.minimum_late_interest = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.minimum_late_interest := l_db_lpov_rec.minimum_late_interest;
        END IF;
        IF (x_lpov_rec.maximum_late_interest = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.maximum_late_interest := l_db_lpov_rec.maximum_late_interest;
        END IF;
        IF (x_lpov_rec.attribute_category = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute_category := l_db_lpov_rec.attribute_category;
        END IF;
        IF (x_lpov_rec.attribute1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute1 := l_db_lpov_rec.attribute1;
        END IF;
        IF (x_lpov_rec.attribute2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute2 := l_db_lpov_rec.attribute2;
        END IF;
        IF (x_lpov_rec.attribute3 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute3 := l_db_lpov_rec.attribute3;
        END IF;
        IF (x_lpov_rec.attribute4 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute4 := l_db_lpov_rec.attribute4;
        END IF;
        IF (x_lpov_rec.attribute5 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute5 := l_db_lpov_rec.attribute5;
        END IF;
        IF (x_lpov_rec.attribute6 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute6 := l_db_lpov_rec.attribute6;
        END IF;
        IF (x_lpov_rec.attribute7 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute7 := l_db_lpov_rec.attribute7;
        END IF;
        IF (x_lpov_rec.attribute8 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute8 := l_db_lpov_rec.attribute8;
        END IF;
        IF (x_lpov_rec.attribute9 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute9 := l_db_lpov_rec.attribute9;
        END IF;
        IF (x_lpov_rec.attribute10 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute10 := l_db_lpov_rec.attribute10;
        END IF;
        IF (x_lpov_rec.attribute11 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute11 := l_db_lpov_rec.attribute11;
        END IF;
        IF (x_lpov_rec.attribute12 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute12 := l_db_lpov_rec.attribute12;
        END IF;
        IF (x_lpov_rec.attribute13 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute13 := l_db_lpov_rec.attribute13;
        END IF;
        IF (x_lpov_rec.attribute14 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute14 := l_db_lpov_rec.attribute14;
        END IF;
        IF (x_lpov_rec.attribute15 = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.attribute15 := l_db_lpov_rec.attribute15;
        END IF;
        IF (x_lpov_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.created_by := l_db_lpov_rec.created_by;
        END IF;
        IF (x_lpov_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_lpov_rec.creation_date := l_db_lpov_rec.creation_date;
        END IF;
        IF (x_lpov_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.last_updated_by := l_db_lpov_rec.last_updated_by;
        END IF;
        IF (x_lpov_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_lpov_rec.last_update_date := l_db_lpov_rec.last_update_date;
        END IF;
        IF (x_lpov_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_lpov_rec.last_update_login := l_db_lpov_rec.last_update_login;
        END IF;
        IF (x_lpov_rec.days_in_year = Okc_Api.G_MISS_CHAR)
        THEN
          x_lpov_rec.days_in_year := l_db_lpov_rec.days_in_year;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_LATE_POLICIES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_lpov_rec IN lpov_rec_type,
      x_lpov_rec OUT NOCOPY lpov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_lpov_rec := p_lpov_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_lpov_rec,                        -- IN
      x_lpov_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lpov_rec, l_def_lpov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_lpov_rec := fill_who_columns(l_def_lpov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lpov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lpov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_lpov_rec, l_lpo_rec);
    migrate(l_def_lpov_rec, l_okl_late_policies_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_lpo_rec,
      lx_lpo_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lpo_rec, l_def_lpov_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_late_policies_tl_rec,
      lx_okl_late_policies_tl_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_late_policies_tl_rec, l_def_lpov_rec);
    x_lpov_rec := l_def_lpov_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------
  -- PL/SQL TBL update_row for:LPOV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type,
    x_lpov_tbl                     OUT NOCOPY lpov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lpov_tbl.COUNT > 0) THEN
      i := p_lpov_tbl.FIRST;
      LOOP
         update_row (
           p_api_version                  => p_api_version,
           p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_lpov_rec                     => p_lpov_tbl(i),
           x_lpov_rec                     => x_lpov_tbl(i));
        EXIT WHEN (i = p_lpov_tbl.LAST);
        i := p_lpov_tbl.NEXT(i);
      END LOOP;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- delete_row for:OKL_LATE_POLICIES_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpo_rec                      IN lpo_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpo_rec                      lpo_rec_type := p_lpo_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_LATE_POLICIES_B
     WHERE ID = p_lpo_rec.id;

    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------
  -- delete_row for:OKL_LATE_POLICIES_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_late_policies_tl_rec     IN okl_late_policies_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type := p_okl_late_policies_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_LATE_POLICIES_TL
     WHERE ID = p_okl_late_policies_tl_rec.id;

    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- delete_row for:OKL_LATE_POLICIES_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_rec                     IN lpov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lpov_rec                     lpov_rec_type := p_lpov_rec;
    l_okl_late_policies_tl_rec     okl_late_policies_tl_rec_type;
    l_lpo_rec                      lpo_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_lpov_rec, l_okl_late_policies_tl_rec);
    migrate(l_lpov_rec, l_lpo_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_late_policies_tl_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_lpo_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_LATE_POLICIES_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lpov_tbl                     IN lpov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lpov_tbl.COUNT > 0) THEN
      i := p_lpov_tbl.FIRST;
      LOOP
         delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => Okc_Api.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_lpov_rec                     => p_lpov_tbl(i));

        EXIT WHEN (i = p_lpov_tbl.LAST);
        i := p_lpov_tbl.NEXT(i);
      END LOOP;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END Okl_Lpo_Pvt;


/
