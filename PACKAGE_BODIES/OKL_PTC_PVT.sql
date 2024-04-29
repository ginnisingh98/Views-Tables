--------------------------------------------------------
--  DDL for Package Body OKL_PTC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PTC_PVT" AS
/* $Header: OKLSPTCB.pls 120.4 2007/08/08 12:48:24 arajagop ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_PROPERTY_TAX_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_PROPERTY_TAX_ALL_B B --Changed _TL to _B by rvaduri for MLS compliance
         WHERE B.ID =T.ID
        );

    UPDATE OKL_PROPERTY_TAX_TL T SET(
        ASSET_DESCRIPTION) = (SELECT
                                  B.ASSET_DESCRIPTION
                                FROM OKL_PROPERTY_TAX_TL B
                               WHERE B.ID = T.ID
				AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID, T.LANGUAGE)
          IN (SELECT
                  SUBT.ID
		 ,SUBT.LANGUAGE
                FROM OKL_PROPERTY_TAX_TL SUBB, OKL_PROPERTY_TAX_TL SUBT
               WHERE SUBB.ID = SUBT.ID
	         AND SUBB.LANGUAGE = SUBT.LANGUAGE
                 AND ( SUBB.ASSET_DESCRIPTION <> SUBT.ASSET_DESCRIPTION
                      OR (SUBB.LANGUAGE IS NOT NULL AND SUBT.LANGUAGE IS NULL)
                      OR (SUBB.ASSET_DESCRIPTION IS NULL AND SUBT.ASSET_DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_PROPERTY_TAX_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        ASSET_DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.ASSET_DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_PROPERTY_TAX_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_PROPERTY_TAX_TL T
                     WHERE T.ID = B.ID
		-- Added as per Bug 2876076 by rvaduri
		     AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PROPERTY_TAX_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptcv_rec                     IN ptcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ptcv_rec_type IS
    CURSOR okl_ptcv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SEQUENCE_NUMBER,
            ASSET_ID,
            ASSET_NUMBER,
            ASSET_DESCRIPTION,
            KHR_ID,
            KLE_ID,
            ASSET_UNITS,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            ASSET_ADDRESS_1,
            ASSET_ADDRESS_2,
            ASSET_ADDRESS_3,
            ASSET_ADDRESS_4,
            ASSET_CITY,
            ASSET_STATE,
            ASSET_COUNTRY,
            TAX_ASSESSMENT_AMOUNT,
            TAX_JURISDICTION_CITY,
            TAX_JURISDICTION_CITY_RATE,
            TAX_JURISDICTION_COUNTY,
            TAX_JURISDICTION_COUNTY_RATE,
            TAX_JURISDICTION_STATE,
            TAX_JURISDICTION_STATE_RATE,
            TAX_JURISDICTION_SCHOOL,
            TAX_JURISDICTION_SCHOOL_RATE,
            TAX_JURISDICTION_COUNTRY,
            TAX_JURISDICTION_COUNTRY_RATE,
            TAX_ASSESSMENT_DATE,
            MILRATE,
            PROPERTY_TAX_AMOUNT,
            OEC,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
            ,contract_number
	    ,sty_name
	    ,sty_id
	    ,invoice_date
	    ,amount
        ,org_id
        ,JURSDCTN_TYPE
        ,JURSDCTN_NAME
        ,MLRT_TAX
        ,TAX_VENDOR_ID
        ,TAX_VENDOR_NAME
        ,TAX_VENDOR_SITE_ID
        ,TAX_VENDOR_SITE_NAME
      FROM OKL_PROPERTY_TAX_V
     WHERE OKL_PROPERTY_TAX_V.id = p_id;
    l_okl_ptcv_pk                  okl_ptcv_pk_csr%ROWTYPE;
    l_ptcv_rec                     ptcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ptcv_pk_csr (p_ptcv_rec.id);
    FETCH okl_ptcv_pk_csr INTO
              l_ptcv_rec.id,
              l_ptcv_rec.sequence_number,
              l_ptcv_rec.asset_id,
              l_ptcv_rec.asset_number,
              l_ptcv_rec.asset_description,
              l_ptcv_rec.khr_id,
              l_ptcv_rec.kle_id,
              l_ptcv_rec.asset_units,
              l_ptcv_rec.language,
              l_ptcv_rec.source_lang,
              l_ptcv_rec.sfwt_flag,
              l_ptcv_rec.asset_address_1,
              l_ptcv_rec.asset_address_2,
              l_ptcv_rec.asset_address_3,
              l_ptcv_rec.asset_address_4,
              l_ptcv_rec.asset_city,
              l_ptcv_rec.asset_state,
              l_ptcv_rec.asset_country,
              l_ptcv_rec.tax_assessment_amount,
              l_ptcv_rec.tax_jurisdiction_city,
              l_ptcv_rec.tax_jurisdiction_city_rate,
              l_ptcv_rec.tax_jurisdiction_county,
              l_ptcv_rec.tax_jurisdiction_county_rate,
              l_ptcv_rec.tax_jurisdiction_state,
              l_ptcv_rec.tax_jurisdiction_state_rate,
              l_ptcv_rec.tax_jurisdiction_school,
              l_ptcv_rec.tax_jurisdiction_school_rate,
              l_ptcv_rec.tax_jurisdiction_country,
              l_ptcv_rec.tax_jurisdiction_country_rate,
              l_ptcv_rec.tax_assessment_date,
              l_ptcv_rec.milrate,
              l_ptcv_rec.property_tax_amount,
              l_ptcv_rec.oec,
              l_ptcv_rec.created_by,
              l_ptcv_rec.creation_date,
              l_ptcv_rec.last_updated_by,
              l_ptcv_rec.last_update_date,
              l_ptcv_rec.last_update_login
              ,l_ptcv_rec.contract_number
	      ,l_ptcv_rec.sty_name
	      ,l_ptcv_rec.sty_id
	      ,l_ptcv_rec.invoice_date
	      ,l_ptcv_rec.amount
 	      ,l_ptcv_rec.org_id
          ,l_ptcv_rec.JURSDCTN_TYPE
          ,l_ptcv_rec.JURSDCTN_NAME
          ,l_ptcv_rec.MLRT_TAX
          ,l_ptcv_rec.TAX_VENDOR_ID
          ,l_ptcv_rec.TAX_VENDOR_NAME
          ,l_ptcv_rec.TAX_VENDOR_SITE_ID
          ,l_ptcv_rec.TAX_VENDOR_SITE_NAME;
    x_no_data_found := okl_ptcv_pk_csr%NOTFOUND;
    CLOSE okl_ptcv_pk_csr;
    RETURN(l_ptcv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptcv_rec                     IN ptcv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ptcv_rec_type IS
    l_ptcv_rec                     ptcv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ptcv_rec := get_rec(p_ptcv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ptcv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ptcv_rec                     IN ptcv_rec_type
  ) RETURN ptcv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ptcv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PROPERTY_TAX_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptc_rec                      IN ptc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ptc_rec_type IS
    CURSOR okl_ptc_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SEQUENCE_NUMBER,
            ASSET_ID,
            ASSET_NUMBER,
            KHR_ID,
            KLE_ID,
            ASSET_UNITS,
            ASSET_ADDRESS_1,
            ASSET_ADDRESS_2,
            ASSET_ADDRESS_3,
            ASSET_ADDRESS_4,
            ASSET_CITY,
            ASSET_STATE,
            ASSET_COUNTRY,
            TAX_ASSESSMENT_AMOUNT,
            TAX_JURISDICTION_CITY,
            TAX_JURISDICTION_CITY_RATE,
            TAX_JURISDICTION_COUNTY,
            TAX_JURISDICTION_COUNTY_RATE,
            TAX_JURISDICTION_STATE,
            TAX_JURISDICTION_STATE_RATE,
            TAX_JURISDICTION_SCHOOL,
            TAX_JURISDICTION_SCHOOL_RATE,
            TAX_JURISDICTION_COUNTRY,
            TAX_JURISDICTION_COUNTRY_RATE,
            TAX_ASSESSMENT_DATE,
            MILRATE,
            PROPERTY_TAX_AMOUNT,
            OEC,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
            ,contract_number
	    ,sty_name
	    ,sty_id
	    ,invoice_date
	    ,amount
	    ,org_id
        ,JURSDCTN_TYPE
        ,JURSDCTN_NAME
        ,MLRT_TAX
        ,TAX_VENDOR_ID
        ,TAX_VENDOR_NAME
        ,TAX_VENDOR_SITE_ID
        ,TAX_VENDOR_SITE_NAME
      FROM OKL_PROPERTY_TAX_B
     WHERE okl_property_tax_b.id = p_id;
    l_okl_ptc_pk                   okl_ptc_pk_csr%ROWTYPE;
    l_ptc_rec                      ptc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ptc_pk_csr (p_ptc_rec.id);
    FETCH okl_ptc_pk_csr INTO
              l_ptc_rec.id,
              l_ptc_rec.sequence_number,
              l_ptc_rec.asset_id,
              l_ptc_rec.asset_number,
              l_ptc_rec.khr_id,
              l_ptc_rec.kle_id,
              l_ptc_rec.asset_units,
              l_ptc_rec.asset_address_1,
              l_ptc_rec.asset_address_2,
              l_ptc_rec.asset_address_3,
              l_ptc_rec.asset_address_4,
              l_ptc_rec.asset_city,
              l_ptc_rec.asset_state,
              l_ptc_rec.asset_country,
              l_ptc_rec.tax_assessment_amount,
              l_ptc_rec.tax_jurisdiction_city,
              l_ptc_rec.tax_jurisdiction_city_rate,
              l_ptc_rec.tax_jurisdiction_county,
              l_ptc_rec.tax_jurisdiction_county_rate,
              l_ptc_rec.tax_jurisdiction_state,
              l_ptc_rec.tax_jurisdiction_state_rate,
              l_ptc_rec.tax_jurisdiction_school,
              l_ptc_rec.tax_jurisdiction_school_rate,
              l_ptc_rec.tax_jurisdiction_country,
              l_ptc_rec.tax_jurisdiction_country_rate,
              l_ptc_rec.tax_assessment_date,
              l_ptc_rec.milrate,
              l_ptc_rec.property_tax_amount,
              l_ptc_rec.oec,
              l_ptc_rec.created_by,
              l_ptc_rec.creation_date,
              l_ptc_rec.last_updated_by,
              l_ptc_rec.last_update_date,
              l_ptc_rec.last_update_login
             ,l_ptc_rec.contract_number
	     ,l_ptc_rec.sty_name
	     ,l_ptc_rec.sty_id
	     ,l_ptc_rec.invoice_date
	     ,l_ptc_rec.amount
	     ,l_ptc_rec.org_id
         ,l_ptc_rec.JURSDCTN_TYPE
         ,l_ptc_rec.JURSDCTN_NAME
         ,l_ptc_rec.MLRT_TAX
         ,l_ptc_rec.TAX_VENDOR_ID
         ,l_ptc_rec.TAX_VENDOR_NAME
         ,l_ptc_rec.TAX_VENDOR_SITE_ID
         ,l_ptc_rec.TAX_VENDOR_SITE_NAME;
    x_no_data_found := okl_ptc_pk_csr%NOTFOUND;
    CLOSE okl_ptc_pk_csr;
    RETURN(l_ptc_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptc_rec                      IN ptc_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ptc_rec_type IS
    l_ptc_rec                      ptc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ptc_rec := get_rec(p_ptc_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ptc_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ptc_rec                      IN ptc_rec_type
  ) RETURN ptc_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ptc_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PROPERTY_TAX_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptct_rec                     IN ptct_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ptct_rec_type IS
    CURSOR okl_ptct_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            ASSET_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Property_Tax_Tl
     WHERE Okl_Property_Tax_Tl.id = p_id;
    l_okl_ptct_pk                  okl_ptct_pk_csr%ROWTYPE;
    l_ptct_rec                     ptct_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ptct_pk_csr (p_ptct_rec.id);
    FETCH okl_ptct_pk_csr INTO
              l_ptct_rec.id,
              l_ptct_rec.language,
              l_ptct_rec.source_lang,
              l_ptct_rec.sfwt_flag,
              l_ptct_rec.asset_description,
              l_ptct_rec.created_by,
              l_ptct_rec.creation_date,
              l_ptct_rec.last_updated_by,
              l_ptct_rec.last_update_date,
              l_ptct_rec.last_update_login;
    x_no_data_found := okl_ptct_pk_csr%NOTFOUND;
    CLOSE okl_ptct_pk_csr;
    RETURN(l_ptct_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ptct_rec                     IN ptct_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ptct_rec_type IS
    l_ptct_rec                     ptct_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ptct_rec := get_rec(p_ptct_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ptct_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ptct_rec                     IN ptct_rec_type
  ) RETURN ptct_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ptct_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PROPERTY_TAX_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ptcv_rec   IN ptcv_rec_type
  ) RETURN ptcv_rec_type IS
    l_ptcv_rec                     ptcv_rec_type := p_ptcv_rec;
  BEGIN
    IF (l_ptcv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.id := NULL;
    END IF;
    IF (l_ptcv_rec.sequence_number = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.sequence_number := NULL;
    END IF;
    IF (l_ptcv_rec.asset_id = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.asset_id := NULL;
    END IF;
    IF (l_ptcv_rec.asset_number = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_number := NULL;
    END IF;
    IF (l_ptcv_rec.asset_description = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_description := NULL;
    END IF;
    IF (l_ptcv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.khr_id := NULL;
    END IF;
    IF (l_ptcv_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.kle_id := NULL;
    END IF;
    IF (l_ptcv_rec.asset_units = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.asset_units := NULL;
    END IF;
    IF (l_ptcv_rec.language = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.language := NULL;
    END IF;
    IF (l_ptcv_rec.source_lang = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.source_lang := NULL;
    END IF;
    IF (l_ptcv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ptcv_rec.asset_address_1 = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_address_1 := NULL;
    END IF;
    IF (l_ptcv_rec.asset_address_2 = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_address_2 := NULL;
    END IF;
    IF (l_ptcv_rec.asset_address_3 = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_address_3 := NULL;
    END IF;
    IF (l_ptcv_rec.asset_address_4 = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_address_4 := NULL;
    END IF;
    IF (l_ptcv_rec.asset_city = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_city := NULL;
    END IF;
    IF (l_ptcv_rec.asset_state = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_state := NULL;
    END IF;
    IF (l_ptcv_rec.asset_country = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.asset_country := NULL;
    END IF;
    IF (l_ptcv_rec.tax_assessment_amount = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_assessment_amount := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_city = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.tax_jurisdiction_city := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_city_rate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_jurisdiction_city_rate := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_county = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.tax_jurisdiction_county := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_county_rate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_jurisdiction_county_rate := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_state = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.tax_jurisdiction_state := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_state_rate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_jurisdiction_state_rate := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_school = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.tax_jurisdiction_school := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_school_rate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_jurisdiction_school_rate := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_country = OKC_API.G_MISS_CHAR ) THEN
      l_ptcv_rec.tax_jurisdiction_country := NULL;
    END IF;
    IF (l_ptcv_rec.tax_jurisdiction_country_rate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.tax_jurisdiction_country_rate := NULL;
    END IF;
    IF (l_ptcv_rec.tax_assessment_date = OKC_API.G_MISS_DATE ) THEN
      l_ptcv_rec.tax_assessment_date := NULL;
    END IF;
    IF (l_ptcv_rec.milrate = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.milrate := NULL;
    END IF;
    IF (l_ptcv_rec.property_tax_amount = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.property_tax_amount := NULL;
    END IF;
    IF (l_ptcv_rec.oec = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.oec := NULL;
    END IF;
    IF (l_ptcv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.created_by := NULL;
    END IF;
    IF (l_ptcv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_ptcv_rec.creation_date := NULL;
    END IF;
    IF (l_ptcv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ptcv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_ptcv_rec.last_update_date := NULL;
    END IF;
    IF (l_ptcv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_ptcv_rec.last_update_login := NULL;
    END IF;
    IF (l_ptcv_rec.contract_number = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.contract_number := NULL;
    END IF;
    IF (l_ptcv_rec.sty_name = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.sty_name := NULL;
    END IF;
    IF (l_ptcv_rec.sty_id = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.sty_id := NULL;
    END IF;
    IF (l_ptcv_rec.invoice_date = OKC_API.G_MISS_DATE ) THEN
        l_ptcv_rec.invoice_date := NULL;
    END IF;
    IF (l_ptcv_rec.amount = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.amount := NULL;
    END IF;
    IF (l_ptcv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.org_id := NULL;
    END IF;

    -- Addition for Est Property Tax
    IF (l_ptcv_rec.JURSDCTN_TYPE = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.JURSDCTN_TYPE := NULL;
    END IF;
    IF (l_ptcv_rec.JURSDCTN_NAME = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.JURSDCTN_NAME := NULL;
    END IF;
    IF (l_ptcv_rec.MLRT_TAX = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.MLRT_TAX := NULL;
    END IF;
    IF (l_ptcv_rec.TAX_VENDOR_ID = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.TAX_VENDOR_ID := NULL;
    END IF;
    IF (l_ptcv_rec.TAX_VENDOR_NAME = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.TAX_VENDOR_NAME := NULL;
    END IF;
    IF (l_ptcv_rec.TAX_VENDOR_SITE_ID = OKC_API.G_MISS_NUM ) THEN
        l_ptcv_rec.TAX_VENDOR_SITE_ID := NULL;
    END IF;
    IF (l_ptcv_rec.TAX_VENDOR_SITE_NAME = OKC_API.G_MISS_CHAR ) THEN
        l_ptcv_rec.TAX_VENDOR_SITE_NAME := NULL;
    END IF;
    -- End Addition for Est Property Tax

    RETURN(l_ptcv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ptcv_rec.id = OKC_API.G_MISS_NUM OR
        p_ptcv_rec.id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;

  ----------------------------------------------
  -- Validate_Attributes for: SEQUENCE_NUMBER --
  ----------------------------------------------
 /* PROCEDURE validate_sequence_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sequence_number              IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_sequence_number.sequence_number = OKC_API.G_MISS_NUM OR
        p_sequence_number.sequence_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sequence_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- verify that length is within allowed limits
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sequence_number;
 */
   -------------------------------------
   -- Validate_Attributes for: STY_ID --
   -------------------------------------

   PROCEDURE validate_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ptcv_rec.sty_id = OKC_API.G_MISS_NUM OR
        p_ptcv_rec.sty_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sty_id;
   -------------------------------------
   -- Validate_Attributes for: INVOICE_DATE --
   -------------------------------------

   PROCEDURE validate_invoice_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ptcv_rec.invoice_date = OKC_API.G_MISS_DATE OR
        p_ptcv_rec.invoice_date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Invoice Date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_invoice_date;
  ---------------------------------------
  -- Validate_Attributes for: LANGUAGE --
  ---------------------------------------
  PROCEDURE validate_language(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_language                     IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_language.language = OKC_API.G_MISS_CHAR OR
        p_language.language IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'language');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- verify that length is within allowed limits
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_language;
  ------------------------------------------
  -- Validate_Attributes for: SOURCE_LANG --
  ------------------------------------------
  PROCEDURE validate_source_lang(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_lang                  IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_source_lang.source_lang = OKC_API.G_MISS_CHAR OR
        p_source_lang.source_lang IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_lang');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- verify that length is within allowed limits
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_source_lang;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN ptcv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_sfwt_flag.sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_sfwt_flag.sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- verify that length is within allowed limits
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_PROPERTY_TAX_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ptcv_rec                     IN ptcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- sequence_number
    -- ***
   /* validate_sequence_number(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
*/
    -- ***
    -- sty_id
    -- ***
    validate_sty_id(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- invoice_date
    -- ***
    validate_invoice_date(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- language
    -- ***
    validate_language(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- source_lang
    -- ***
    validate_source_lang(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(l_return_status, p_ptcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate Record for:OKL_PROPERTY_TAX_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_ptcv_rec IN ptcv_rec_type,
    p_db_ptcv_rec IN ptcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_ptcv_rec IN ptcv_rec_type,
      p_db_ptcv_rec IN ptcv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_khrv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_K_Headers_V
       WHERE okl_k_headers_v.id   = p_id;
      l_okl_khrv_pk                  okl_khrv_pk_csr%ROWTYPE;

      CURSOR okl_klev_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_K_Lines_V
       WHERE okl_k_lines_v.id     = p_id;
      l_okl_klev_pk                  okl_klev_pk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_ptcv_rec.KHR_ID IS NOT NULL)
       AND
          (p_ptcv_rec.KHR_ID <> p_db_ptcv_rec.KHR_ID))
      THEN
        OPEN okl_khrv_pk_csr (p_ptcv_rec.KHR_ID);
        FETCH okl_khrv_pk_csr INTO l_okl_khrv_pk;
        l_row_notfound := okl_khrv_pk_csr%NOTFOUND;
        CLOSE okl_khrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_ptcv_rec.KLE_ID IS NOT NULL)
       AND
          (p_ptcv_rec.KLE_ID <> p_db_ptcv_rec.KLE_ID))
      THEN
        OPEN okl_klev_pk_csr (p_ptcv_rec.KLE_ID);
        FETCH okl_klev_pk_csr INTO l_okl_klev_pk;
        l_row_notfound := okl_klev_pk_csr%NOTFOUND;
        CLOSE okl_klev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_ptcv_rec, p_db_ptcv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_ptcv_rec IN ptcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_ptcv_rec                  ptcv_rec_type := get_rec(p_ptcv_rec);
  BEGIN
    l_return_status := Validate_Record(p_ptcv_rec => p_ptcv_rec,
                                       p_db_ptcv_rec => l_db_ptcv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ptcv_rec_type,
    p_to   IN OUT NOCOPY ptc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_units := p_from.asset_units;
    p_to.asset_address_1 := p_from.asset_address_1;
    p_to.asset_address_2 := p_from.asset_address_2;
    p_to.asset_address_3 := p_from.asset_address_3;
    p_to.asset_address_4 := p_from.asset_address_4;
    p_to.asset_city := p_from.asset_city;
    p_to.asset_state := p_from.asset_state;
    p_to.asset_country := p_from.asset_country;
    p_to.tax_assessment_amount := p_from.tax_assessment_amount;
    p_to.tax_jurisdiction_city := p_from.tax_jurisdiction_city;
    p_to.tax_jurisdiction_city_rate := p_from.tax_jurisdiction_city_rate;
    p_to.tax_jurisdiction_county := p_from.tax_jurisdiction_county;
    p_to.tax_jurisdiction_county_rate := p_from.tax_jurisdiction_county_rate;
    p_to.tax_jurisdiction_state := p_from.tax_jurisdiction_state;
    p_to.tax_jurisdiction_state_rate := p_from.tax_jurisdiction_state_rate;
    p_to.tax_jurisdiction_school := p_from.tax_jurisdiction_school;
    p_to.tax_jurisdiction_school_rate := p_from.tax_jurisdiction_school_rate;
    p_to.tax_jurisdiction_country := p_from.tax_jurisdiction_country;
    p_to.tax_jurisdiction_country_rate := p_from.tax_jurisdiction_country_rate;
    p_to.tax_assessment_date := p_from.tax_assessment_date;
    p_to.milrate := p_from.milrate;
    p_to.property_tax_amount := p_from.property_tax_amount;
    p_to.oec := p_from.oec;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.contract_number := p_from.contract_number;
    p_to.sty_name := p_from.sty_name;
    p_to.sty_id := p_from.sty_id;
    p_to.invoice_date := p_from.invoice_date;
    p_to.amount := p_from.amount;
    p_to.org_id := p_from.org_id;
    -- Addition for Est Property Tax
    p_to.JURSDCTN_TYPE := p_from.JURSDCTN_TYPE;
    p_to.JURSDCTN_NAME := p_from.JURSDCTN_NAME;
    p_to.MLRT_TAX      := p_from.MLRT_TAX;
    p_to.TAX_VENDOR_ID := p_from.TAX_VENDOR_ID;
    p_to.TAX_VENDOR_NAME := p_from.TAX_VENDOR_NAME;
    p_to.TAX_VENDOR_SITE_ID := p_from.TAX_VENDOR_SITE_ID;
    p_to.TAX_VENDOR_SITE_NAME := p_from.TAX_VENDOR_SITE_NAME;
    -- End Addition for Est Property Tax
  END migrate;
  PROCEDURE migrate (
    p_from IN ptc_rec_type,
    p_to   IN OUT NOCOPY ptcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_units := p_from.asset_units;
    p_to.asset_address_1 := p_from.asset_address_1;
    p_to.asset_address_2 := p_from.asset_address_2;
    p_to.asset_address_3 := p_from.asset_address_3;
    p_to.asset_address_4 := p_from.asset_address_4;
    p_to.asset_city := p_from.asset_city;
    p_to.asset_state := p_from.asset_state;
    p_to.asset_country := p_from.asset_country;
    p_to.tax_assessment_amount := p_from.tax_assessment_amount;
    p_to.tax_jurisdiction_city := p_from.tax_jurisdiction_city;
    p_to.tax_jurisdiction_city_rate := p_from.tax_jurisdiction_city_rate;
    p_to.tax_jurisdiction_county := p_from.tax_jurisdiction_county;
    p_to.tax_jurisdiction_county_rate := p_from.tax_jurisdiction_county_rate;
    p_to.tax_jurisdiction_state := p_from.tax_jurisdiction_state;
    p_to.tax_jurisdiction_state_rate := p_from.tax_jurisdiction_state_rate;
    p_to.tax_jurisdiction_school := p_from.tax_jurisdiction_school;
    p_to.tax_jurisdiction_school_rate := p_from.tax_jurisdiction_school_rate;
    p_to.tax_jurisdiction_country := p_from.tax_jurisdiction_country;
    p_to.tax_jurisdiction_country_rate := p_from.tax_jurisdiction_country_rate;
    p_to.tax_assessment_date := p_from.tax_assessment_date;
    p_to.milrate := p_from.milrate;
    p_to.property_tax_amount := p_from.property_tax_amount;
    p_to.oec := p_from.oec;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.contract_number := p_from.contract_number;
    p_to.sty_name := p_from.sty_name;
    p_to.sty_id := p_from.sty_id;
    p_to.invoice_date := p_from.invoice_date;
    p_to.amount := p_from.amount;
    p_to.org_id := p_from.org_id;

    -- Addition for Est Property tax
    p_to.JURSDCTN_TYPE := p_from.JURSDCTN_TYPE;
    p_to.JURSDCTN_NAME := p_from.JURSDCTN_NAME;
    p_to.MLRT_TAX := p_from.MLRT_TAX;
    p_to.TAX_VENDOR_ID := p_from.TAX_VENDOR_ID;
    p_to.TAX_VENDOR_NAME := p_from.TAX_VENDOR_NAME;
    p_to.TAX_VENDOR_SITE_ID := p_from.TAX_VENDOR_SITE_ID;
    p_to.TAX_VENDOR_SITE_NAME := p_from.TAX_VENDOR_SITE_NAME;
    -- End addition for Est Property tax
  END migrate;
  PROCEDURE migrate (
    p_from IN ptcv_rec_type,
    p_to   IN OUT NOCOPY ptct_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.asset_description := p_from.asset_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN ptct_rec_type,
    p_to   IN OUT NOCOPY ptcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.asset_description := p_from.asset_description;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:OKL_PROPERTY_TAX_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptcv_rec                     ptcv_rec_type := p_ptcv_rec;
    l_ptc_rec                      ptc_rec_type;
    l_ptct_rec                     ptct_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ptcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ptcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PROPERTY_TAX_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      i := p_ptcv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ptcv_rec                     => p_ptcv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ptcv_tbl.LAST);
        i := p_ptcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_PROPERTY_TAX_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ptcv_tbl                     => p_ptcv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- insert_row for:OKL_PROPERTY_TAX_B --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptc_rec                      IN ptc_rec_type,
    x_ptc_rec                      OUT NOCOPY ptc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptc_rec                      ptc_rec_type := p_ptc_rec;
    l_def_ptc_rec                  ptc_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptc_rec IN ptc_rec_type,
      x_ptc_rec OUT NOCOPY ptc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptc_rec := p_ptc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_ptc_rec,                         -- IN
      l_ptc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PROPERTY_TAX_B(
      id,
      sequence_number,
      asset_id,
      asset_number,
      khr_id,
      kle_id,
      asset_units,
      asset_address_1,
      asset_address_2,
      asset_address_3,
      asset_address_4,
      asset_city,
      asset_state,
      asset_country,
      tax_assessment_amount,
      tax_jurisdiction_city,
      tax_jurisdiction_city_rate,
      tax_jurisdiction_county,
      tax_jurisdiction_county_rate,
      tax_jurisdiction_state,
      tax_jurisdiction_state_rate,
      tax_jurisdiction_school,
      tax_jurisdiction_school_rate,
      tax_jurisdiction_country,
      tax_jurisdiction_country_rate,
      tax_assessment_date,
      milrate,
      property_tax_amount,
      oec,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      ,contract_number
      ,sty_name
      ,sty_id
      ,invoice_date
      ,amount
      ,org_id
      ,JURSDCTN_TYPE
      ,JURSDCTN_NAME
      ,MLRT_TAX
      ,TAX_VENDOR_ID
      ,TAX_VENDOR_NAME
      ,TAX_VENDOR_SITE_ID
      ,TAX_VENDOR_SITE_NAME
)
    VALUES (
      l_ptc_rec.id,
      l_ptc_rec.sequence_number,
      l_ptc_rec.asset_id,
      l_ptc_rec.asset_number,
      l_ptc_rec.khr_id,
      l_ptc_rec.kle_id,
      l_ptc_rec.asset_units,
      l_ptc_rec.asset_address_1,
      l_ptc_rec.asset_address_2,
      l_ptc_rec.asset_address_3,
      l_ptc_rec.asset_address_4,
      l_ptc_rec.asset_city,
      l_ptc_rec.asset_state,
      l_ptc_rec.asset_country,
      l_ptc_rec.tax_assessment_amount,
      l_ptc_rec.tax_jurisdiction_city,
      l_ptc_rec.tax_jurisdiction_city_rate,
      l_ptc_rec.tax_jurisdiction_county,
      l_ptc_rec.tax_jurisdiction_county_rate,
      l_ptc_rec.tax_jurisdiction_state,
      l_ptc_rec.tax_jurisdiction_state_rate,
      l_ptc_rec.tax_jurisdiction_school,
      l_ptc_rec.tax_jurisdiction_school_rate,
      l_ptc_rec.tax_jurisdiction_country,
      l_ptc_rec.tax_jurisdiction_country_rate,
      l_ptc_rec.tax_assessment_date,
      l_ptc_rec.milrate,
      l_ptc_rec.property_tax_amount,
      l_ptc_rec.oec,
      l_ptc_rec.created_by,
      l_ptc_rec.creation_date,
      l_ptc_rec.last_updated_by,
      l_ptc_rec.last_update_date,
      l_ptc_rec.last_update_login
      ,l_ptc_rec.contract_number
      ,l_ptc_rec.sty_name
      ,l_ptc_rec.sty_id
      ,l_ptc_rec.invoice_date
      ,l_ptc_rec.amount
      ,l_ptc_rec.org_id
      -- Addition for Est Property Tax
      ,l_ptc_rec.JURSDCTN_TYPE
      ,l_ptc_rec.JURSDCTN_NAME
      ,l_ptc_rec.MLRT_TAX
      ,l_ptc_rec.TAX_VENDOR_ID
      ,l_ptc_rec.TAX_VENDOR_NAME
      ,l_ptc_rec.TAX_VENDOR_SITE_ID
      ,l_ptc_rec.TAX_VENDOR_SITE_NAME
      -- End Addition for Est Property Tax
      );
    -- Set OUT values
    x_ptc_rec := l_ptc_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------------
  -- insert_row for:OKL_PROPERTY_TAX_TL --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptct_rec                     IN ptct_rec_type,
    x_ptct_rec                     OUT NOCOPY ptct_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptct_rec                     ptct_rec_type := p_ptct_rec;
    l_def_ptct_rec                 ptct_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptct_rec IN ptct_rec_type,
      x_ptct_rec OUT NOCOPY ptct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptct_rec := p_ptct_rec;
      x_ptct_rec.LANGUAGE := USERENV('LANG');
      x_ptct_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ptct_rec,                        -- IN
      l_ptct_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_ptct_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_PROPERTY_TAX_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        asset_description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ptct_rec.id,
        l_ptct_rec.language,
        l_ptct_rec.source_lang,
        l_ptct_rec.sfwt_flag,
        l_ptct_rec.asset_description,
        l_ptct_rec.created_by,
        l_ptct_rec.creation_date,
        l_ptct_rec.last_updated_by,
        l_ptct_rec.last_update_date,
        l_ptct_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_ptct_rec := l_ptct_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------------
  -- insert_row for :OKL_PROPERTY_TAX_V --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type,
    x_ptcv_rec                     OUT NOCOPY ptcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptcv_rec                     ptcv_rec_type := p_ptcv_rec;
    l_def_ptcv_rec                 ptcv_rec_type;
    l_ptc_rec                      ptc_rec_type;
    lx_ptc_rec                     ptc_rec_type;
    l_ptct_rec                     ptct_rec_type;
    lx_ptct_rec                    ptct_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ptcv_rec IN ptcv_rec_type
    ) RETURN ptcv_rec_type IS
      l_ptcv_rec ptcv_rec_type := p_ptcv_rec;
    BEGIN
      l_ptcv_rec.CREATION_DATE := SYSDATE;
      l_ptcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ptcv_rec.LAST_UPDATE_DATE := l_ptcv_rec.CREATION_DATE;
      l_ptcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ptcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ptcv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptcv_rec IN ptcv_rec_type,
      x_ptcv_rec OUT NOCOPY ptcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptcv_rec := p_ptcv_rec;
      x_ptcv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ptcv_rec := null_out_defaults(p_ptcv_rec);
    -- Set primary key value
    l_ptcv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_ptcv_rec,                        -- IN
      l_def_ptcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ptcv_rec := fill_who_columns(l_def_ptcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ptcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ptcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ptcv_rec, l_ptc_rec);
    migrate(l_def_ptcv_rec, l_ptct_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptc_rec,
      lx_ptc_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ptc_rec, l_def_ptcv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptct_rec,
      lx_ptct_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ptct_rec, l_def_ptcv_rec);
    -- Set OUT values
    x_ptcv_rec := l_def_ptcv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:PTCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      i := p_ptcv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ptcv_rec                     => p_ptcv_tbl(i),
            x_ptcv_rec                     => x_ptcv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ptcv_tbl.LAST);
        i := p_ptcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:PTCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ptcv_tbl                     => p_ptcv_tbl,
        x_ptcv_tbl                     => x_ptcv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  --------------------------------------------
  -- lock_row for:OKL_PROPERTY_TAX_B --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptc_rec                      IN ptc_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ptc_rec IN ptc_rec_type) IS
    SELECT *
      FROM OKL_PROPERTY_TAX_B
     WHERE ID = p_ptc_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ptc_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
	--Commented by rvaduri
	-- This is not correct, we should go by object version number
	-- but this is not present in the table for now.
/*
    ELSE
      IF (l_lock_var.id <> p_ptc_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sequence_number <> p_ptc_rec.sequence_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_id <> p_ptc_rec.asset_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_number <> p_ptc_rec.asset_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.khr_id <> p_ptc_rec.khr_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.kle_id <> p_ptc_rec.kle_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_units <> p_ptc_rec.asset_units) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_address_1 <> p_ptc_rec.asset_address_1) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_address_2 <> p_ptc_rec.asset_address_2) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_address_3 <> p_ptc_rec.asset_address_3) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_address_4 <> p_ptc_rec.asset_address_4) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_city <> p_ptc_rec.asset_city) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_state <> p_ptc_rec.asset_state) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_country <> p_ptc_rec.asset_country) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_assessment_amount <> p_ptc_rec.tax_assessment_amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_city <> p_ptc_rec.tax_jurisdiction_city) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_city_rate <> p_ptc_rec.tax_jurisdiction_city_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_county <> p_ptc_rec.tax_jurisdiction_county) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_county_rate <> p_ptc_rec.tax_jurisdiction_county_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_state <> p_ptc_rec.tax_jurisdiction_state) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_state_rate <> p_ptc_rec.tax_jurisdiction_state_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_school <> p_ptc_rec.tax_jurisdiction_school) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_school_rate <> p_ptc_rec.tax_jurisdiction_school_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_country <> p_ptc_rec.tax_jurisdiction_country) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_jurisdiction_country_rate <> p_ptc_rec.tax_jurisdiction_country_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_assessment_date <> p_ptc_rec.tax_assessment_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.milrate <> p_ptc_rec.milrate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.property_tax_amount <> p_ptc_rec.property_tax_amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.oec <> p_ptc_rec.oec) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_ptc_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_ptc_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_ptc_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_ptc_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_ptc_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.contract_number <> p_ptc_rec.contract_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sty_name <> p_ptc_rec.sty_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sty_id <> p_ptc_rec.sty_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.invoice_date <> p_ptc_rec.invoice_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.amount <> p_ptc_rec.amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.org_id <> p_ptc_rec.org_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
*/ --end comment by rvaduri
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------
  -- lock_row for:OKL_PROPERTY_TAX_TL --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptct_rec                     IN ptct_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ptct_rec IN ptct_rec_type) IS
    SELECT *
      FROM OKL_PROPERTY_TAX_TL
     WHERE ID = p_ptct_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ptct_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------
  -- lock_row for: OKL_PROPERTY_TAX_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptc_rec                      ptc_rec_type;
    l_ptct_rec                     ptct_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_ptcv_rec, l_ptc_rec);
    migrate(p_ptcv_rec, l_ptct_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptc_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptct_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:PTCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      i := p_ptcv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ptcv_rec                     => p_ptcv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ptcv_tbl.LAST);
        i := p_ptcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:PTCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ptcv_tbl                     => p_ptcv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- update_row for:OKL_PROPERTY_TAX_B --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptc_rec                      IN ptc_rec_type,
    x_ptc_rec                      OUT NOCOPY ptc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptc_rec                      ptc_rec_type := p_ptc_rec;
    l_def_ptc_rec                  ptc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ptc_rec IN ptc_rec_type,
      x_ptc_rec OUT NOCOPY ptc_rec_type
    ) RETURN VARCHAR2 IS
      l_ptc_rec                      ptc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptc_rec := p_ptc_rec;
      -- Get current database values
      l_ptc_rec := get_rec(p_ptc_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ptc_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.id := l_ptc_rec.id;
        END IF;
        IF (x_ptc_rec.sequence_number = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.sequence_number := l_ptc_rec.sequence_number;
        END IF;
        IF (x_ptc_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.asset_id := l_ptc_rec.asset_id;
        END IF;
        IF (x_ptc_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_number := l_ptc_rec.asset_number;
        END IF;
        IF (x_ptc_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.khr_id := l_ptc_rec.khr_id;
        END IF;
        IF (x_ptc_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.kle_id := l_ptc_rec.kle_id;
        END IF;
        IF (x_ptc_rec.asset_units = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.asset_units := l_ptc_rec.asset_units;
        END IF;
        IF (x_ptc_rec.asset_address_1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_address_1 := l_ptc_rec.asset_address_1;
        END IF;
        IF (x_ptc_rec.asset_address_2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_address_2 := l_ptc_rec.asset_address_2;
        END IF;
        IF (x_ptc_rec.asset_address_3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_address_3 := l_ptc_rec.asset_address_3;
        END IF;
        IF (x_ptc_rec.asset_address_4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_address_4 := l_ptc_rec.asset_address_4;
        END IF;
        IF (x_ptc_rec.asset_city = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_city := l_ptc_rec.asset_city;
        END IF;
        IF (x_ptc_rec.asset_state = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_state := l_ptc_rec.asset_state;
        END IF;
        IF (x_ptc_rec.asset_country = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.asset_country := l_ptc_rec.asset_country;
        END IF;
        IF (x_ptc_rec.tax_assessment_amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_assessment_amount := l_ptc_rec.tax_assessment_amount;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_city = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.tax_jurisdiction_city := l_ptc_rec.tax_jurisdiction_city;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_city_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_jurisdiction_city_rate := l_ptc_rec.tax_jurisdiction_city_rate;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_county = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.tax_jurisdiction_county := l_ptc_rec.tax_jurisdiction_county;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_county_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_jurisdiction_county_rate := l_ptc_rec.tax_jurisdiction_county_rate;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_state = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.tax_jurisdiction_state := l_ptc_rec.tax_jurisdiction_state;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_state_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_jurisdiction_state_rate := l_ptc_rec.tax_jurisdiction_state_rate;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_school = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.tax_jurisdiction_school := l_ptc_rec.tax_jurisdiction_school;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_school_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_jurisdiction_school_rate := l_ptc_rec.tax_jurisdiction_school_rate;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_country = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.tax_jurisdiction_country := l_ptc_rec.tax_jurisdiction_country;
        END IF;
        IF (x_ptc_rec.tax_jurisdiction_country_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.tax_jurisdiction_country_rate := l_ptc_rec.tax_jurisdiction_country_rate;
        END IF;
        IF (x_ptc_rec.tax_assessment_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptc_rec.tax_assessment_date := l_ptc_rec.tax_assessment_date;
        END IF;
        IF (x_ptc_rec.milrate = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.milrate := l_ptc_rec.milrate;
        END IF;
        IF (x_ptc_rec.property_tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.property_tax_amount := l_ptc_rec.property_tax_amount;
        END IF;
        IF (x_ptc_rec.oec = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.oec := l_ptc_rec.oec;
        END IF;
        IF (x_ptc_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.created_by := l_ptc_rec.created_by;
        END IF;
        IF (x_ptc_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptc_rec.creation_date := l_ptc_rec.creation_date;
        END IF;
        IF (x_ptc_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.last_updated_by := l_ptc_rec.last_updated_by;
        END IF;
        IF (x_ptc_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptc_rec.last_update_date := l_ptc_rec.last_update_date;
        END IF;
        IF (x_ptc_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.last_update_login := l_ptc_rec.last_update_login;
        END IF;
        IF (x_ptc_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.contract_number := l_ptc_rec.contract_number;
        END IF;
        IF (x_ptc_rec.sty_name = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.sty_name := l_ptc_rec.sty_name;
        END IF;
        IF (x_ptc_rec.sty_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.sty_id := l_ptc_rec.sty_id;
        END IF;
        IF (x_ptc_rec.invoice_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptc_rec.invoice_date := l_ptc_rec.invoice_date;
        END IF;
        IF (x_ptc_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.amount := l_ptc_rec.amount;
        END IF;
        IF (x_ptc_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.org_id := l_ptc_rec.org_id;
        END IF;

        -- Addition for Est Property Tax
        IF (x_ptc_rec.JURSDCTN_TYPE = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.JURSDCTN_TYPE := l_ptc_rec.JURSDCTN_TYPE;
        END IF;

        IF (x_ptc_rec.JURSDCTN_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.JURSDCTN_NAME := l_ptc_rec.JURSDCTN_NAME;
        END IF;

        IF (x_ptc_rec.MLRT_TAX = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.MLRT_TAX := l_ptc_rec.MLRT_TAX;
        END IF;

        IF (x_ptc_rec.TAX_VENDOR_ID   = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.TAX_VENDOR_ID := l_ptc_rec.TAX_VENDOR_ID;
        END IF;

        IF (x_ptc_rec.TAX_VENDOR_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.TAX_VENDOR_NAME := l_ptc_rec.TAX_VENDOR_NAME;
        END IF;

        IF (x_ptc_rec.TAX_VENDOR_SITE_ID = OKC_API.G_MISS_NUM)
        THEN
          x_ptc_rec.TAX_VENDOR_SITE_ID := l_ptc_rec.TAX_VENDOR_SITE_ID;
        END IF;

        IF (x_ptc_rec.TAX_VENDOR_SITE_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptc_rec.TAX_VENDOR_SITE_NAME := l_ptc_rec.TAX_VENDOR_SITE_NAME;
        END IF;
        -- End Addition for Est Property Tax

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptc_rec IN ptc_rec_type,
      x_ptc_rec OUT NOCOPY ptc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptc_rec := p_ptc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ptc_rec,                         -- IN
      l_ptc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ptc_rec, l_def_ptc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PROPERTY_TAX_B
    SET SEQUENCE_NUMBER = l_def_ptc_rec.sequence_number,
        ASSET_ID = l_def_ptc_rec.asset_id,
        ASSET_NUMBER = l_def_ptc_rec.asset_number,
        KHR_ID = l_def_ptc_rec.khr_id,
        KLE_ID = l_def_ptc_rec.kle_id,
        ASSET_UNITS = l_def_ptc_rec.asset_units,
        ASSET_ADDRESS_1 = l_def_ptc_rec.asset_address_1,
        ASSET_ADDRESS_2 = l_def_ptc_rec.asset_address_2,
        ASSET_ADDRESS_3 = l_def_ptc_rec.asset_address_3,
        ASSET_ADDRESS_4 = l_def_ptc_rec.asset_address_4,
        ASSET_CITY = l_def_ptc_rec.asset_city,
        ASSET_STATE = l_def_ptc_rec.asset_state,
        ASSET_COUNTRY = l_def_ptc_rec.asset_country,
        TAX_ASSESSMENT_AMOUNT = l_def_ptc_rec.tax_assessment_amount,
        TAX_JURISDICTION_CITY = l_def_ptc_rec.tax_jurisdiction_city,
        TAX_JURISDICTION_CITY_RATE = l_def_ptc_rec.tax_jurisdiction_city_rate,
        TAX_JURISDICTION_COUNTY = l_def_ptc_rec.tax_jurisdiction_county,
        TAX_JURISDICTION_COUNTY_RATE = l_def_ptc_rec.tax_jurisdiction_county_rate,
        TAX_JURISDICTION_STATE = l_def_ptc_rec.tax_jurisdiction_state,
        TAX_JURISDICTION_STATE_RATE = l_def_ptc_rec.tax_jurisdiction_state_rate,
        TAX_JURISDICTION_SCHOOL = l_def_ptc_rec.tax_jurisdiction_school,
        TAX_JURISDICTION_SCHOOL_RATE = l_def_ptc_rec.tax_jurisdiction_school_rate,
        TAX_JURISDICTION_COUNTRY = l_def_ptc_rec.tax_jurisdiction_country,
        TAX_JURISDICTION_COUNTRY_RATE = l_def_ptc_rec.tax_jurisdiction_country_rate,
        TAX_ASSESSMENT_DATE = l_def_ptc_rec.tax_assessment_date,
        MILRATE = l_def_ptc_rec.milrate,
        PROPERTY_TAX_AMOUNT = l_def_ptc_rec.property_tax_amount,
        OEC = l_def_ptc_rec.oec,
        CREATED_BY = l_def_ptc_rec.created_by,
        CREATION_DATE = l_def_ptc_rec.creation_date,
        LAST_UPDATED_BY = l_def_ptc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ptc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ptc_rec.last_update_login,
        contract_number = l_def_ptc_rec.contract_number,
        sty_name = l_def_ptc_rec.sty_name,
        sty_id = l_def_ptc_rec.sty_id,
        invoice_date = l_def_ptc_rec.invoice_date,
        amount = l_def_ptc_rec.amount,
        org_id = l_def_ptc_rec.org_id,
        -- Addition for Est Property Tax
        JURSDCTN_TYPE = l_def_ptc_rec.JURSDCTN_TYPE,
        JURSDCTN_NAME = l_def_ptc_rec.JURSDCTN_NAME,
        MLRT_TAX = l_def_ptc_rec.MLRT_TAX,
        TAX_VENDOR_ID = l_def_ptc_rec.TAX_VENDOR_ID,
        TAX_VENDOR_NAME = l_def_ptc_rec.TAX_VENDOR_NAME,
        TAX_VENDOR_SITE_ID = l_def_ptc_rec.TAX_VENDOR_SITE_ID,
        TAX_VENDOR_SITE_NAME = l_def_ptc_rec.TAX_VENDOR_SITE_NAME
        -- End Addition for Est Property Tax
    WHERE ID = l_def_ptc_rec.id;

    x_ptc_rec := l_ptc_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------------
  -- update_row for:OKL_PROPERTY_TAX_TL --
  -----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptct_rec                     IN ptct_rec_type,
    x_ptct_rec                     OUT NOCOPY ptct_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptct_rec                     ptct_rec_type := p_ptct_rec;
    l_def_ptct_rec                 ptct_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ptct_rec IN ptct_rec_type,
      x_ptct_rec OUT NOCOPY ptct_rec_type
    ) RETURN VARCHAR2 IS
      l_ptct_rec                     ptct_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptct_rec := p_ptct_rec;
      -- Get current database values
      l_ptct_rec := get_rec(p_ptct_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ptct_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ptct_rec.id := l_ptct_rec.id;
        END IF;
        IF (x_ptct_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_ptct_rec.language := l_ptct_rec.language;
        END IF;
        IF (x_ptct_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_ptct_rec.source_lang := l_ptct_rec.source_lang;
        END IF;
        IF (x_ptct_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ptct_rec.sfwt_flag := l_ptct_rec.sfwt_flag;
        END IF;
        IF (x_ptct_rec.asset_description = OKC_API.G_MISS_CHAR)
        THEN
          x_ptct_rec.asset_description := l_ptct_rec.asset_description;
        END IF;
        IF (x_ptct_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptct_rec.created_by := l_ptct_rec.created_by;
        END IF;
        IF (x_ptct_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptct_rec.creation_date := l_ptct_rec.creation_date;
        END IF;
        IF (x_ptct_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptct_rec.last_updated_by := l_ptct_rec.last_updated_by;
        END IF;
        IF (x_ptct_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptct_rec.last_update_date := l_ptct_rec.last_update_date;
        END IF;
        IF (x_ptct_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ptct_rec.last_update_login := l_ptct_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptct_rec IN ptct_rec_type,
      x_ptct_rec OUT NOCOPY ptct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptct_rec := p_ptct_rec;
      x_ptct_rec.LANGUAGE := USERENV('LANG');
      x_ptct_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ptct_rec,                        -- IN
      l_ptct_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ptct_rec, l_def_ptct_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_PROPERTY_TAX_TL
    SET ASSET_DESCRIPTION = l_def_ptct_rec.asset_description,
        SOURCE_LANG = l_def_ptct_rec.source_lang,-- Fix for bug 3637102
        CREATED_BY = l_def_ptct_rec.created_by,
        CREATION_DATE = l_def_ptct_rec.creation_date,
        LAST_UPDATED_BY = l_def_ptct_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ptct_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ptct_rec.last_update_login
    WHERE ID = l_def_ptct_rec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_PROPERTY_TAX_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_ptct_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_ptct_rec := l_ptct_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------------
  -- update_row for:OKL_PROPERTY_TAX_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type,
    x_ptcv_rec                     OUT NOCOPY ptcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptcv_rec                     ptcv_rec_type := p_ptcv_rec;
    l_def_ptcv_rec                 ptcv_rec_type;
    l_db_ptcv_rec                  ptcv_rec_type;
    l_ptc_rec                      ptc_rec_type;
    lx_ptc_rec                     ptc_rec_type;
    l_ptct_rec                     ptct_rec_type;
    lx_ptct_rec                    ptct_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ptcv_rec IN ptcv_rec_type
    ) RETURN ptcv_rec_type IS
      l_ptcv_rec ptcv_rec_type := p_ptcv_rec;
    BEGIN
      l_ptcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ptcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ptcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ptcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ptcv_rec IN ptcv_rec_type,
      x_ptcv_rec OUT NOCOPY ptcv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptcv_rec := p_ptcv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_ptcv_rec := get_rec(p_ptcv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ptcv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.id := l_db_ptcv_rec.id;
        END IF;
        IF (x_ptcv_rec.sequence_number = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.sequence_number := l_db_ptcv_rec.sequence_number;
        END IF;
        IF (x_ptcv_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.asset_id := l_db_ptcv_rec.asset_id;
        END IF;
        IF (x_ptcv_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_number := l_db_ptcv_rec.asset_number;
        END IF;
        IF (x_ptcv_rec.asset_description = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_description := l_db_ptcv_rec.asset_description;
        END IF;
        IF (x_ptcv_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.khr_id := l_db_ptcv_rec.khr_id;
        END IF;
        IF (x_ptcv_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.kle_id := l_db_ptcv_rec.kle_id;
        END IF;
        IF (x_ptcv_rec.asset_units = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.asset_units := l_db_ptcv_rec.asset_units;
        END IF;
        IF (x_ptcv_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.language := l_db_ptcv_rec.language;
        END IF;
        IF (x_ptcv_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.source_lang := l_db_ptcv_rec.source_lang;
        END IF;
        IF (x_ptcv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.sfwt_flag := l_db_ptcv_rec.sfwt_flag;
        END IF;
        IF (x_ptcv_rec.asset_address_1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_address_1 := l_db_ptcv_rec.asset_address_1;
        END IF;
        IF (x_ptcv_rec.asset_address_2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_address_2 := l_db_ptcv_rec.asset_address_2;
        END IF;
        IF (x_ptcv_rec.asset_address_3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_address_3 := l_db_ptcv_rec.asset_address_3;
        END IF;
        IF (x_ptcv_rec.asset_address_4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_address_4 := l_db_ptcv_rec.asset_address_4;
        END IF;
        IF (x_ptcv_rec.asset_city = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_city := l_db_ptcv_rec.asset_city;
        END IF;
        IF (x_ptcv_rec.asset_state = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_state := l_db_ptcv_rec.asset_state;
        END IF;
        IF (x_ptcv_rec.asset_country = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.asset_country := l_db_ptcv_rec.asset_country;
        END IF;
        IF (x_ptcv_rec.tax_assessment_amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_assessment_amount := l_db_ptcv_rec.tax_assessment_amount;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_city = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.tax_jurisdiction_city := l_db_ptcv_rec.tax_jurisdiction_city;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_city_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_jurisdiction_city_rate := l_db_ptcv_rec.tax_jurisdiction_city_rate;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_county = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.tax_jurisdiction_county := l_db_ptcv_rec.tax_jurisdiction_county;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_county_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_jurisdiction_county_rate := l_db_ptcv_rec.tax_jurisdiction_county_rate;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_state = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.tax_jurisdiction_state := l_db_ptcv_rec.tax_jurisdiction_state;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_state_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_jurisdiction_state_rate := l_db_ptcv_rec.tax_jurisdiction_state_rate;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_school = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.tax_jurisdiction_school := l_db_ptcv_rec.tax_jurisdiction_school;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_school_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_jurisdiction_school_rate := l_db_ptcv_rec.tax_jurisdiction_school_rate;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_country = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.tax_jurisdiction_country := l_db_ptcv_rec.tax_jurisdiction_country;
        END IF;
        IF (x_ptcv_rec.tax_jurisdiction_country_rate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.tax_jurisdiction_country_rate := l_db_ptcv_rec.tax_jurisdiction_country_rate;
        END IF;
        IF (x_ptcv_rec.tax_assessment_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptcv_rec.tax_assessment_date := l_db_ptcv_rec.tax_assessment_date;
        END IF;
        IF (x_ptcv_rec.milrate = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.milrate := l_db_ptcv_rec.milrate;
        END IF;
        IF (x_ptcv_rec.property_tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.property_tax_amount := l_db_ptcv_rec.property_tax_amount;
        END IF;
        IF (x_ptcv_rec.oec = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.oec := l_db_ptcv_rec.oec;
        END IF;
        IF (x_ptcv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.created_by := l_db_ptcv_rec.created_by;
        END IF;
        IF (x_ptcv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptcv_rec.creation_date := l_db_ptcv_rec.creation_date;
        END IF;
        IF (x_ptcv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.last_updated_by := l_db_ptcv_rec.last_updated_by;
        END IF;
        IF (x_ptcv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptcv_rec.last_update_date := l_db_ptcv_rec.last_update_date;
        END IF;
        IF (x_ptcv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.last_update_login := l_db_ptcv_rec.last_update_login;
        END IF;
        IF (x_ptcv_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.contract_number := l_db_ptcv_rec.contract_number;
        END IF;
        IF (x_ptcv_rec.sty_name = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.sty_name := l_db_ptcv_rec.sty_name;
        END IF;
        IF (x_ptcv_rec.sty_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.sty_id := l_db_ptcv_rec.sty_id;
        END IF;
        IF (x_ptcv_rec.invoice_date = OKC_API.G_MISS_DATE)
        THEN
          x_ptcv_rec.invoice_date := l_db_ptcv_rec.invoice_date;
        END IF;
        IF (x_ptcv_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.amount := l_db_ptcv_rec.amount;
        END IF;
        IF (x_ptcv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.org_id := l_db_ptcv_rec.org_id;
        END IF;

        -- Addition for Est property Tax
        IF (x_ptcv_rec.JURSDCTN_TYPE = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.JURSDCTN_TYPE := l_db_ptcv_rec.JURSDCTN_TYPE;
        END IF;

        IF (x_ptcv_rec.JURSDCTN_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.JURSDCTN_NAME := l_db_ptcv_rec.JURSDCTN_NAME;
        END IF;

        IF (x_ptcv_rec.MLRT_TAX = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.MLRT_TAX := l_db_ptcv_rec.MLRT_TAX;
        END IF;

        IF (x_ptcv_rec.TAX_VENDOR_ID = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.TAX_VENDOR_ID := l_db_ptcv_rec.TAX_VENDOR_ID;
        END IF;

        IF (x_ptcv_rec.TAX_VENDOR_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.TAX_VENDOR_NAME := l_db_ptcv_rec.TAX_VENDOR_NAME;
        END IF;

        IF (x_ptcv_rec.TAX_VENDOR_SITE_ID = OKC_API.G_MISS_NUM)
        THEN
          x_ptcv_rec.TAX_VENDOR_SITE_ID := l_db_ptcv_rec.TAX_VENDOR_SITE_ID;
        END IF;

        IF (x_ptcv_rec.TAX_VENDOR_SITE_NAME = OKC_API.G_MISS_CHAR)
        THEN
          x_ptcv_rec.TAX_VENDOR_SITE_NAME := l_db_ptcv_rec.TAX_VENDOR_SITE_NAME;
        END IF;
        -- End addition for Est Property Tax

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_PROPERTY_TAX_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_ptcv_rec IN ptcv_rec_type,
      x_ptcv_rec OUT NOCOPY ptcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptcv_rec := p_ptcv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ptcv_rec,                        -- IN
      x_ptcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ptcv_rec, l_def_ptcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ptcv_rec := fill_who_columns(l_def_ptcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ptcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ptcv_rec, l_db_ptcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_ptcv_rec                     => p_ptcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ptcv_rec, l_ptc_rec);
    migrate(l_def_ptcv_rec, l_ptct_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptc_rec,
      lx_ptc_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ptc_rec, l_def_ptcv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptct_rec,
      lx_ptct_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ptct_rec, l_def_ptcv_rec);
    x_ptcv_rec := l_def_ptcv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:ptcv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      i := p_ptcv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ptcv_rec                     => p_ptcv_tbl(i),
            x_ptcv_rec                     => x_ptcv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ptcv_tbl.LAST);
        i := p_ptcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:PTCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ptcv_tbl                     => p_ptcv_tbl,
        x_ptcv_tbl                     => x_ptcv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- delete_row for:OKL_PROPERTY_TAX_B --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptc_rec                      IN ptc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptc_rec                      ptc_rec_type := p_ptc_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_PROPERTY_TAX_B
     WHERE ID = p_ptc_rec.id;

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------
  -- delete_row for:OKL_PROPERTY_TAX_TL --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptct_rec                     IN ptct_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptct_rec                     ptct_rec_type := p_ptct_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_PROPERTY_TAX_TL
     WHERE ID = p_ptct_rec.id;

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------
  -- delete_row for:OKL_PROPERTY_TAX_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptcv_rec                     ptcv_rec_type := p_ptcv_rec;
    l_ptct_rec                     ptct_rec_type;
    l_ptc_rec                      ptc_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_ptcv_rec, l_ptct_rec);
    migrate(l_ptcv_rec, l_ptc_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptct_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ptc_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PROPERTY_TAX_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      i := p_ptcv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ptcv_rec                     => p_ptcv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ptcv_tbl.LAST);
        i := p_ptcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_PROPERTY_TAX_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptcv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ptcv_tbl                     => p_ptcv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_PTC_PVT;

/
