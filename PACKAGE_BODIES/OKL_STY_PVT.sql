--------------------------------------------------------
--  DDL for Package Body OKL_STY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STY_PVT" AS
/* $Header: OKLSSTYB.pls 120.28 2008/01/30 00:39:37 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
	l_temp	NUMBER 	:= 0;
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
    DELETE FROM OKL_STRM_TYPE_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_STRM_TYPE_B B    --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_STRM_TYPE_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_STRM_TYPE_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_STRM_TYPE_TL SUBB, OKL_STRM_TYPE_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_STRM_TYPE_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
	SHORT_DESCRIPTION
-- Added by RGOOTY for ER 3935682: End
	)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.NAME,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
	    B.SHORT_DESCRIPTION
-- Added by RGOOTY for ER 3935682: End
        FROM OKL_STRM_TYPE_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_STRM_TYPE_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYPE_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sty_rec                      IN sty_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sty_rec_type IS
    CURSOR okl_strm_type_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
			VERSION,
			CODE,
			CUSTOMIZATION_LEVEL,
			STREAM_TYPE_SCOPE,
			OBJECT_VERSION_NUMBER,
			ACCRUAL_YN,
			TAXABLE_DEFAULT_YN,
			STREAM_TYPE_CLASS,
			-- hkpatel 04/15/2003
			STREAM_TYPE_SUBCLASS,
			--
			START_DATE,
			END_DATE,
			BILLABLE_YN,
			CAPITALIZE_YN,
			PERIODIC_YN,
			FUNDABLE_YN,
			-- mvasudev , 05/13/2002
			ALLOCATION_FACTOR,
			--
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
			STREAM_TYPE_PURPOSE,
			CONTINGENCY,
                         -- Added by SNANDIKO for Bug 6744584 Start
                        CONTINGENCY_ID
                         -- Added by SNANDIKO for Bug 6744584 End
      FROM OKL_STRM_TYPE_B
     WHERE OKL_STRM_TYPE_B.id   = p_id;
    l_okl_strm_type_b_pk           okl_strm_type_b_pk_csr%ROWTYPE;
    l_sty_rec                      sty_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_strm_type_b_pk_csr (p_sty_rec.id);
    FETCH okl_strm_type_b_pk_csr INTO
			l_sty_rec.VERSION,
			l_sty_rec.CODE,
			l_sty_rec.CUSTOMIZATION_LEVEL,
			l_sty_rec.STREAM_TYPE_SCOPE,
			l_sty_rec.OBJECT_VERSION_NUMBER,
			l_sty_rec.ACCRUAL_YN,
			l_sty_rec.TAXABLE_DEFAULT_YN,
			l_sty_rec.STREAM_TYPE_CLASS,
			-- hkpatel  04/15/2003
			l_sty_rec.STREAM_TYPE_SUBCLASS,
			--
			l_sty_rec.START_DATE,
			l_sty_rec.END_DATE,
			l_sty_rec.BILLABLE_YN,
			l_sty_rec.CAPITALIZE_YN,
			l_sty_rec.PERIODIC_YN,
			l_sty_rec.FUNDABLE_YN,
			-- mvasudev , 05/13/2002
			l_sty_rec.ALLOCATION_FACTOR,
			--
			l_sty_rec.ATTRIBUTE_CATEGORY,
			l_sty_rec.ATTRIBUTE1,
			l_sty_rec.ATTRIBUTE2,
			l_sty_rec.ATTRIBUTE3,
			l_sty_rec.ATTRIBUTE4,
			l_sty_rec.ATTRIBUTE5,
			l_sty_rec.ATTRIBUTE6,
			l_sty_rec.ATTRIBUTE7,
			l_sty_rec.ATTRIBUTE8,
			l_sty_rec.ATTRIBUTE9,
			l_sty_rec.ATTRIBUTE10,
			l_sty_rec.ATTRIBUTE11,
			l_sty_rec.ATTRIBUTE12,
			l_sty_rec.ATTRIBUTE13,
			l_sty_rec.ATTRIBUTE14,
			l_sty_rec.ATTRIBUTE15,
			l_sty_rec.CREATED_BY,
			l_sty_rec.CREATION_DATE,
			l_sty_rec.LAST_UPDATED_BY,
			l_sty_rec.LAST_UPDATE_DATE,
			l_sty_rec.LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
			l_sty_rec.STREAM_TYPE_PURPOSE,
			l_sty_rec.CONTINGENCY,
-- Added by RGOOTY for ER 3935682: End

 -- Added by SNANDIKO for Bug 6744584 Start
                        l_sty_rec.CONTINGENCY_ID;
 -- Added by SNANDIKO for Bug 6744584 End
    x_no_data_found := okl_strm_type_b_pk_csr%NOTFOUND;
    CLOSE okl_strm_type_b_pk_csr;
    RETURN(l_sty_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sty_rec                      IN sty_rec_type
  ) RETURN sty_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sty_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYPE_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_strm_type_tl_rec_type IS
    CURSOR okl_strm_type_tl_pk_csr (p_id                 IN NUMBER,
                                    p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
	    SHORT_DESCRIPTION
-- Added by RGOOTY for ER 3935682: Start
      FROM Okl_Strm_Type_Tl
     WHERE okl_strm_type_tl.id  = p_id
       AND okl_strm_type_tl.language = p_language;
    l_okl_strm_type_tl_pk          okl_strm_type_tl_pk_csr%ROWTYPE;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_strm_type_tl_pk_csr (p_okl_strm_type_tl_rec.id,
                                  p_okl_strm_type_tl_rec.language);
    FETCH okl_strm_type_tl_pk_csr INTO
              l_okl_strm_type_tl_rec.ID,
              l_okl_strm_type_tl_rec.LANGUAGE,
              l_okl_strm_type_tl_rec.SOURCE_LANG,
              l_okl_strm_type_tl_rec.SFWT_FLAG,
              l_okl_strm_type_tl_rec.NAME,
              l_okl_strm_type_tl_rec.DESCRIPTION,
              l_okl_strm_type_tl_rec.CREATED_BY,
              l_okl_strm_type_tl_rec.CREATION_DATE,
              l_okl_strm_type_tl_rec.LAST_UPDATED_BY,
              l_okl_strm_type_tl_rec.LAST_UPDATE_DATE,
              l_okl_strm_type_tl_rec.LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
	      l_okl_strm_type_tl_rec.SHORT_DESCRIPTION;
-- Added by RGOOTY for ER 3935682: End
    x_no_data_found := okl_strm_type_tl_pk_csr%NOTFOUND;
    CLOSE okl_strm_type_tl_pk_csr;
    RETURN(l_okl_strm_type_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type
  ) RETURN okl_strm_type_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_strm_type_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYPE_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_styv_rec                     IN styv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN styv_rec_type IS
    CURSOR okl_styv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
			ID,
			NAME,
			VERSION,
			OBJECT_VERSION_NUMBER,
			CODE,
			SFWT_FLAG,
			STREAM_TYPE_SCOPE,
			DESCRIPTION,
			START_DATE,
			END_DATE,
			BILLABLE_YN,
			CAPITALIZE_YN,
			PERIODIC_YN,
			FUNDABLE_YN,
			-- mvasudev , 05/13/2002
			ALLOCATION_FACTOR,
			--
			TAXABLE_DEFAULT_YN,
			CUSTOMIZATION_LEVEL,
			STREAM_TYPE_CLASS,
			-- hkpatel    04/15/2003
			STREAM_TYPE_SUBCLASS,
			--
			ACCRUAL_YN,
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
-- Added by RGOOTY for ER 3935682: Start
			STREAM_TYPE_PURPOSE,
			CONTINGENCY,
			SHORT_DESCRIPTION,
-- Added by RGOOTY for ER 3935682: End

 -- Added by SNANDIKO for Bug 6744584 Start
                        CONTINGENCY_ID
 -- Added by SNANDIKO for Bug 6744584 End
      FROM OKL_STRM_TYPE_V
     WHERE OKL_STRM_TYPE_V.id   = p_id;
    l_okl_styv_pk                  okl_styv_pk_csr%ROWTYPE;
    l_styv_rec                     styv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_styv_pk_csr (p_styv_rec.id);
    FETCH okl_styv_pk_csr INTO
			l_styv_rec.ID,
			l_styv_rec.NAME,
			l_styv_rec.VERSION,
			l_styv_rec.OBJECT_VERSION_NUMBER,
			l_styv_rec.CODE,
			l_styv_rec.SFWT_FLAG,
			l_styv_rec.STREAM_TYPE_SCOPE,
			l_styv_rec.DESCRIPTION,
			l_styv_rec.START_DATE,
			l_styv_rec.END_DATE,
			l_styv_rec.BILLABLE_YN,
			l_styv_rec.CAPITALIZE_YN,
			l_styv_rec.PERIODIC_YN,
			l_styv_rec.FUNDABLE_YN,
			-- mvasudev , 05/13/2002
			l_styv_rec.ALLOCATION_FACTOR,
			--
			l_styv_rec.TAXABLE_DEFAULT_YN,
			l_styv_rec.CUSTOMIZATION_LEVEL,
			l_styv_rec.STREAM_TYPE_CLASS,
			-- hkpatel    04/15/2003
			l_styv_rec.STREAM_TYPE_SUBCLASS,
			--
			l_styv_rec.ACCRUAL_YN,
			l_styv_rec.ATTRIBUTE_CATEGORY,
			l_styv_rec.ATTRIBUTE1,
			l_styv_rec.ATTRIBUTE2,
			l_styv_rec.ATTRIBUTE3,
			l_styv_rec.ATTRIBUTE4,
			l_styv_rec.ATTRIBUTE5,
			l_styv_rec.ATTRIBUTE6,
   			l_styv_rec.ATTRIBUTE7,
			l_styv_rec.ATTRIBUTE8,
			l_styv_rec.ATTRIBUTE9,
			l_styv_rec.ATTRIBUTE10,
			l_styv_rec.ATTRIBUTE11,
			l_styv_rec.ATTRIBUTE12,
			l_styv_rec.ATTRIBUTE13,
			l_styv_rec.ATTRIBUTE14,
			l_styv_rec.ATTRIBUTE15,
			l_styv_rec.CREATED_BY,
			l_styv_rec.CREATION_DATE,
   			l_styv_rec.LAST_UPDATED_BY,
   			l_styv_rec.LAST_UPDATE_DATE,
			l_styv_rec.LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
			l_styv_rec.STREAM_TYPE_PURPOSE,
			l_styv_rec.CONTINGENCY,
			l_styv_rec.SHORT_DESCRIPTION,
-- Added by RGOOTY for ER 3935682: End

 -- Added by SNANDIKO for Bug 6744584 Start
                        l_styv_rec.CONTINGENCY_ID;
 -- Added by SNANDIKO for Bug 6744584 End

    x_no_data_found := okl_styv_pk_csr%NOTFOUND;
    CLOSE okl_styv_pk_csr;
    RETURN(l_styv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_styv_rec                     IN styv_rec_type
  ) RETURN styv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_styv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STRM_TYPE_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_styv_rec	IN styv_rec_type
  ) RETURN styv_rec_type IS
    l_styv_rec	styv_rec_type := p_styv_rec;
  BEGIN
    IF (l_styv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.name := NULL;
    END IF;
    IF (l_styv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.version := NULL;
    END IF;
    IF (l_styv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_styv_rec.object_version_number := NULL;
    END IF;
    IF (l_styv_rec.code = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.code := NULL;
    END IF;
    IF (l_styv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_styv_rec.stream_type_scope = OKC_API.G_MISS_CHAR) THEN
--      l_styv_rec.stream_type_scope := NULL;
	l_styv_rec.stream_type_scope := 'BOTH'; -- Modified by RGOOTY for bug 4036080
    END IF;
    IF (l_styv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.description := NULL;
    END IF;
    IF (l_styv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_styv_rec.start_date := NULL;
    END IF;
    IF (l_styv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_styv_rec.end_date := NULL;
    END IF;
    IF (l_styv_rec.billable_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.billable_yn := NULL;
    END IF;
    IF (l_styv_rec.capitalize_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.capitalize_yn := NULL;
    END IF;
    IF (l_styv_rec.periodic_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.periodic_yn := NULL;
    END IF;
    -- mvasudev , 05/13/2002
    IF (l_styv_rec.fundable_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.fundable_yn := NULL;
    END IF;
    IF (l_styv_rec.ALLOCATION_FACTOR = OKC_API.G_MISS_CHAR) THEN
          l_styv_rec.ALLOCATION_FACTOR := NULL;
    END IF;
    --
    IF (l_styv_rec.taxable_default_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.taxable_default_yn := NULL;
    END IF;
    IF (l_styv_rec.customization_level = OKC_API.G_MISS_CHAR) THEN
--      l_styv_rec.customization_level := NULL;
	l_styv_rec.customization_level := 'S';  -- Modified by RGOOTY for ER 3935682
    END IF;
    IF (l_styv_rec.stream_type_class = OKC_API.G_MISS_CHAR) THEN
--     l_styv_rec.stream_type_class := NULL;
	l_styv_rec.stream_type_class := 'GENERAL'; -- Modified by RGOOTY for ER 3935682
    END IF;
    -- hkpatel   04/15/2003
    IF (l_styv_rec.stream_type_subclass = OKC_API.G_MISS_CHAR) THEN
          l_styv_rec.stream_type_subclass := NULL;
    END IF;
    --
    IF (l_styv_rec.accrual_yn = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.accrual_yn := NULL;
    END IF;
    IF (l_styv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute_category := NULL;
    END IF;
    IF (l_styv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute1 := NULL;
    END IF;
    IF (l_styv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute2 := NULL;
    END IF;
    IF (l_styv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute3 := NULL;
    END IF;
    IF (l_styv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute4 := NULL;
    END IF;
    IF (l_styv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute5 := NULL;
    END IF;
    IF (l_styv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute6 := NULL;
    END IF;
    IF (l_styv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute7 := NULL;
    END IF;
    IF (l_styv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute8 := NULL;
    END IF;
    IF (l_styv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute9 := NULL;
    END IF;
    IF (l_styv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute10 := NULL;
    END IF;
    IF (l_styv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute11 := NULL;
    END IF;
    IF (l_styv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute12 := NULL;
    END IF;
    IF (l_styv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute13 := NULL;
    END IF;
    IF (l_styv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute14 := NULL;
    END IF;
    IF (l_styv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.attribute15 := NULL;
    END IF;
    IF (l_styv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_styv_rec.created_by := NULL;
    END IF;
    IF (l_styv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_styv_rec.creation_date := NULL;
    END IF;
    IF (l_styv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_styv_rec.last_updated_by := NULL;
    END IF;
    IF (l_styv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_styv_rec.last_update_date := NULL;
    END IF;
    IF (l_styv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_styv_rec.last_update_login := NULL;
    END IF;
-- Added by RGOOTY for ER 3935682: Start
    IF (l_styv_rec.stream_type_purpose = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.stream_type_purpose := NULL;
    END IF;
    IF (l_styv_rec.contingency = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.contingency := NULL;
    END IF;
    IF (l_styv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_styv_rec.short_description := NULL;
    END IF;
-- Added by RGOOTY for ER 3935682: End

 -- Added by SNANDIKO for Bug 6744584 Start
    IF (l_styv_rec.contingency_id = OKC_API.G_MISS_NUM) THEN
      l_styv_rec.contingency_id := NULL;
    END IF;
 -- Added by SNANDIKO for Bug 6744584 End
    RETURN(l_styv_rec);
  END null_out_defaults;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Id
    ---------------------------------------------------------------------------
          -- Start of comments
          -- Author          : mvasudev
          -- Procedure Name  : Validate_Id
          -- Description     :
          -- Business Rules  :
          -- Parameters      :
          -- Version         : 1.0
          -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Id(p_styv_rec IN  styv_rec_type,
                          x_return_status OUT NOCOPY  VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      BEGIN
        -- initialize return status
        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
        -- check for data before processing
        IF (p_styv_rec.id = OKC_API.G_MISS_NUM) OR
	           (p_styv_rec.id IS NULL)      THEN

            Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
                              ,p_msg_name       => g_required_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'id');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary; validation can continue
        -- with the next column
        NULL;

        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Id;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Name
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Name
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Name( p_styv_rec IN  styv_rec_type,
                             x_return_status OUT NOCOPY  VARCHAR2)
 	IS
	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
	   	IF (p_styv_rec.name IS NULL) OR
	    	        (p_styv_rec.name  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'name');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Name;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Version
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Version
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Version( p_styv_rec IN  styv_rec_type,
                             x_return_status OUT NOCOPY  VARCHAR2)
 	IS
	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
	   	IF (p_styv_rec.Version IS NULL) OR
	    	        (p_styv_rec.Version  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'Version');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Version;


    ---------------------------------------------------------------------------
      -- PROCEDURE Validate_Object_Version_Number
      ---------------------------------------------------------------------------
          -- Start of comments
          -- Author          :Ajay
          -- Procedure Name  : Validate_Object_Version_Number
          -- Description     :
          -- Business Rules  :
          -- Parameters      :
          -- Version         : 1.0
          -- End of comments
     -----------------------------------------------------------------------------
    Procedure Validate_Object_Version_Number( p_styv_rec IN  styv_rec_type,
                                             x_return_status OUT NOCOPY  VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      BEGIN
        -- initialize return status
        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
        -- check for data before processing
        IF (p_styv_rec.object_version_number IS NULL) OR
           (p_styv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
           Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
                              ,p_msg_name       => g_required_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => 'Object_Version_Number');
           x_return_status    := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary; validation can continue
        -- with the next column
        NULL;

        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Object_Version_Number;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Code
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Code
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Code( p_styv_rec IN  styv_rec_type,
                             x_return_status OUT NOCOPY  VARCHAR2)
 	IS
	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
	   	IF (p_styv_rec.Code IS NULL) OR
	    	        (p_styv_rec.Code  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'Code');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Code;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Stream_Type_Scope
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : mvasudev
    -- Procedure Name  : Validate_Stream_Type_Scope
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_Stream_Type_Scope(
      p_styv_rec IN  styv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    )  IS

    l_found VARCHAR2(1);

    BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	IF (p_styv_rec.stream_type_scope IS NULL) OR
		(p_styv_rec.stream_type_scope  = Okc_Api.G_MISS_CHAR) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
			     ,p_msg_name       => g_required_value
			     ,p_token1         => g_col_name_token
			     ,p_token1_value   => 'Stream_Type_Scope');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

   	ELSE
		--Check if Stream_Type_Scope exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_TYPE_SCOPE',
															p_lookup_code => p_styv_rec.stream_type_scope);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_Scope');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	END IF;

    EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
	    	 -- with the next column
	    	 NULL;

	     	WHEN OTHERS THEN
	    	 -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Stream_Type_Scope;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Start_Date
  --------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Validate_Start_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   Procedure Validate_Start_Date(p_styv_rec IN  styv_rec_type,
                                x_return_status OUT NOCOPY  VARCHAR2) IS

	  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

	 BEGIN
	     -- initialize return status
	     x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	     -- check for data before processing

	   IF p_styv_rec.start_date = OKC_API.G_MISS_DATE   OR
	                         (p_styv_rec.start_date) IS NULL  THEN

	             Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	                                ,p_msg_name       => g_required_value
	                                ,p_token1         => g_col_name_token
	                                ,p_token1_value   => 'Start_Date');

	           x_return_status    := Okc_Api.G_RET_STS_ERROR;
	           RAISE G_EXCEPTION_HALT_VALIDATION;
	   END IF;

	  EXCEPTION
	        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	        -- no processing necessary; validation can continue
	        -- with the next column
	        NULL;

	        WHEN OTHERS THEN
	          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);


	          -- notify caller of an UNEXPECTED error
	          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Start_Date;

---------------------------------------------------------------------------
  -- PROCEDURE Validate_Enddate
  --------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Validate_Enddate
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


   PROCEDURE Validate_End_Date(p_styv_rec IN  styv_rec_type,
                              x_return_status OUT NOCOPY  VARCHAR2)
     IS
       l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
       l_start_date            DATE         := Okc_Api.G_MISS_DATE;
      BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       l_start_date := p_styv_rec.start_date;
       -- check for data before processing
	IF   p_styv_rec.end_date <> OKC_API.G_MISS_DATE
	OR p_styv_rec.end_date IS NOT NULL
	THEN
	    IF 	p_styv_rec.end_date  < l_start_date
	    THEN
	      Okc_Api.SET_MESSAGE( p_app_name   => G_OKC_APP,
                           p_msg_name       => g_invalid_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'end_date' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
	END IF;

    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error

      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_End_Date;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Billable_Yn
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Billable_Yn
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Billable_Yn( p_styv_rec IN  styv_rec_type,
                                           x_return_status OUT NOCOPY  VARCHAR2)

    IS
	  l_found VARCHAR2(1);

	  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check for data before processing
	   	IF (p_styv_rec.billable_yn IS NULL) OR
	    	        (p_styv_rec.billable_yn  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'Billable_YN');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
			--Check if billable_yn exists in the fnd_common_lookups or not
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
   								    p_lookup_code => p_styv_rec.billable_yn,
								    p_app_id 		=> 0,
								    p_view_app_id => 0);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Billable_YN');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
				 RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;

        --VTHIRUVA Bug 4273953..21-Apr-05..removed purpose based validations
        --on billable,taxable and capitalize fields..

	  END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Billable_Yn;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Taxable_Default_Yn
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Taxable_Default_Yn
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Taxable_Default_Yn( p_styv_rec IN  styv_rec_type,
                                           x_return_status OUT NOCOPY  VARCHAR2)

    IS

	l_found VARCHAR2(1);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
	   	IF (p_styv_rec.taxable_default_yn IS NULL) OR
	    	        (p_styv_rec.taxable_default_yn  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'Taxable_Default_YN');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
			--Check if Taxable_Default_YN exists in the fnd_common_lookups or not
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
   															  p_lookup_code => p_styv_rec.taxable_default_yn,
															  p_app_id 		=> 0,
															  p_view_app_id => 0);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Taxable_Default_YN');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
				 RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;
	  END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Taxable_Default_YN;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Customization Level
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : mvasudev
    -- Procedure Name  : Validate_Customization_Level
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_Customization_Level(
      p_styv_rec IN  styv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    )  IS
    l_found  VARCHAR2(1);

    --mvasudev, 01/31/2002
    -- This constant to alleviate differences between DB Column Name and Display Name
    l_display_col_name CONSTANT VARCHAR2(30) := 'Access Level';

    BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	IF (p_styv_rec.customization_level IS NULL) OR
		(p_styv_rec.customization_level  = Okc_Api.G_MISS_CHAR) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
			     ,p_msg_name       => g_required_value
			     ,p_token1         => g_col_name_token
			     ,p_token1_value   => l_display_col_name);
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

   	ELSE
		--Check if customization_level exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STY_CUSTOMIZATION_LEVEL',
														  p_lookup_code => p_styv_rec.customization_level);


		IF (l_found <> OKL_API.G_TRUE ) THEN
	       OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_display_col_name);
		   x_return_status := Okc_Api.G_RET_STS_ERROR;
		   -- raise the exception as there's no matching foreign key value
	   		 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	END IF;

    EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
	    	 -- with the next column
	    	 NULL;

	     	WHEN OTHERS THEN
	    	 -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Customization_Level;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Stream_Type_class
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : akjain
    -- Procedure Name  : Validate_Stream_Type_Class
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    PROCEDURE Validate_Stream_Type_Class(
      p_styv_rec IN  styv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    )  IS

    l_found  VARCHAR2(1);

    BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	IF (p_styv_rec.stream_type_class IS NULL) OR
		(p_styv_rec.stream_type_class  = Okc_Api.G_MISS_CHAR) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
			     ,p_msg_name       => g_required_value
			     ,p_token1         => g_col_name_token
			     ,p_token1_value   => 'Stream_Type_Class');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

   	ELSE
		--Check if stream_type_class exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_TYPE_CLASS',
														  p_lookup_code => p_styv_rec.stream_type_class);

		IF (l_found <> OKL_API.G_TRUE ) THEN
	       OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_Class');
		   x_return_status := Okc_Api.G_RET_STS_ERROR;
		   -- raise the exception as there's no matching foreign key value
	   		 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;
	END IF;

    EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
	    	 -- with the next column
	    	 NULL;

	     	WHEN OTHERS THEN
	    	 -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Stream_Type_Class;

    ---------------------------------------------------------------------------
        -- PROCEDURE Validate_Stream_Type_SubClass
        --------------------------------------------------------------------------
        -- Start of comments
        -- Author          : hkpatel
        -- Procedure Name  : Validate_Stream_Type_SubClass
        -- Description     :
        -- Business Rules  :
        -- Parameters      :
        -- Version         : 1.0
        -- End of comments
        ---------------------------------------------------------------------------

        PROCEDURE Validate_Stream_Type_SubClass(
          p_styv_rec IN  styv_rec_type,
          x_return_status OUT NOCOPY  VARCHAR2
        )  IS

        l_found  VARCHAR2(1);

        BEGIN
    	-- initialize return status
    	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    	     -- check for data before processing

    	IF (p_styv_rec.stream_type_subclass IS NOT NULL) AND
    		(p_styv_rec.stream_type_subclass  <> Okc_Api.G_MISS_CHAR) THEN
    	/*  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
    			     ,p_msg_name       => g_required_value
    			     ,p_token1         => g_col_name_token
    			     ,p_token1_value   => 'Stream_Type_Class');
    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	  RAISE G_EXCEPTION_HALT_VALIDATION;

       	ELSE
       	*/
    		--Check if stream_type_subclass exists in the fnd_common_lookups or not
            l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_TYPE_SUBCLASS',
    							        p_lookup_code => p_styv_rec.stream_type_subclass);

    		IF (l_found <> OKL_API.G_TRUE ) THEN
    	       OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
    		   x_return_status := Okc_Api.G_RET_STS_ERROR;
    		   -- raise the exception as there's no matching foreign key value
    	   		 RAISE G_EXCEPTION_HALT_VALIDATION;
    		END IF;

    	END IF;

        IF ((p_styv_rec.stream_type_purpose = 'ADVANCE_RENT' OR
             p_styv_rec.stream_type_purpose = 'RENT' OR
             p_styv_rec.stream_type_purpose = 'RENEWAL_RENT') AND
			(p_styv_rec.stream_type_subclass IS NULL OR
             p_styv_rec.stream_type_subclass <> 'RENT')) THEN
               OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               -- raise the exception as there's no matching foreign key value
               RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        --Bug # 6740000 ssdeshpa Changed Start
        IF (((p_styv_rec.stream_type_purpose = 'INVESTOR_CNTRCT_OBLIGATION_PAY' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_RESIDUAL_PAY' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_LATE_FEE_PAYABLE' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_RENT_BUYBACK' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_RESIDUAL_BUYBACK' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_DISB_ADJUSTMENT' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_EVERGREEN_RENT_PAY' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_LATE_INTEREST_PAY' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_PRINCIPAL_BUYBACK' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_INTEREST_BUYBACK' OR
             p_styv_rec.stream_type_purpose = 'INVESTOR_PAYDOWN_BUYBACK') AND
            (p_styv_rec.stream_type_subclass IS NULL OR
			 p_styv_rec.stream_type_subclass <> 'INVESTOR_DISBURSEMENT')) OR
             ((p_styv_rec.stream_type_purpose = 'INVESTOR_PRINCIPAL_DISB_BASIS' OR
               p_styv_rec.stream_type_purpose = 'INVESTOR_INTEREST_DISB_BASIS' OR
               p_styv_rec.stream_type_purpose = 'INVESTOR_PPD_DISB_BASIS') AND

            (p_styv_rec.stream_type_subclass IS NULL OR
			 p_styv_rec.stream_type_subclass <> 'LOAN_PAYMENT'))) THEN
               OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               -- raise the exception as there's no matching foreign key value
               RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        IF (p_styv_rec.stream_type_purpose = 'RESIDUAL_VALUE' AND
			(p_styv_rec.stream_type_subclass IS NULL OR
             p_styv_rec.stream_type_subclass <> 'RESIDUAL')) THEN
               OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               -- raise the exception as there's no matching foreign key value
               RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
         --Bug # 6740000 ssdeshpa Changed Start

        IF (p_styv_rec.stream_type_purpose <> 'ADVANCE_RENT' AND
            p_styv_rec.stream_type_purpose <> 'RENT' AND
            p_styv_rec.stream_type_purpose <> 'RESIDUAL_VALUE' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_CNTRCT_OBLIGATION_PAY' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_RESIDUAL_PAY' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_LATE_FEE_PAYABLE' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_RENT_BUYBACK' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_RESIDUAL_BUYBACK' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_DISB_ADJUSTMENT' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_EVERGREEN_RENT_PAY' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_LATE_INTEREST_PAY' AND
            p_styv_rec.stream_type_purpose <> 'RENEWAL_RENT' AND
             p_styv_rec.stream_type_purpose <> 'INVESTOR_PRINCIPAL_BUYBACK' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_INTEREST_BUYBACK' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_PAYDOWN_BUYBACK' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_PRINCIPAL_DISB_BASIS' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_INTEREST_DISB_BASIS' AND
            p_styv_rec.stream_type_purpose <> 'INVESTOR_PPD_DISB_BASIS' AND
            p_styv_rec.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT' AND
            p_styv_rec.stream_type_purpose = 'PRINCIPAL_PAYMENT' AND
            p_styv_rec.stream_type_purpose = 'INTEREST_PAYMENT' AND

	        p_styv_rec.stream_type_subclass IS NOT NULL) THEN
                IF ((p_styv_rec.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT' OR
                p_styv_rec.stream_type_purpose = 'PRINCIPAL_PAYMENT' OR
                p_styv_rec.stream_type_purpose = 'INTEREST_PAYMENT') AND
	           (p_styv_rec.stream_type_subclass IS NOT NULL AND
                p_styv_rec.stream_type_subclass <>'LOAN_PAYMENT')) THEN

               OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
               x_return_status := Okc_Api.G_RET_STS_ERROR;
               -- raise the exception as there's no matching foreign key value
               RAISE G_EXCEPTION_HALT_VALIDATION;
               ELSIF (p_styv_rec.stream_type_purpose <> 'ADVANCE_RENT' AND
                  p_styv_rec.stream_type_purpose <> 'RENT' AND
                  p_styv_rec.stream_type_purpose <> 'RESIDUAL_VALUE' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_CNTRCT_OBLIGATION_PAY' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_RESIDUAL_PAY' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_LATE_FEE_PAYABLE' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_RENT_BUYBACK' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_RESIDUAL_BUYBACK' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_DISB_ADJUSTMENT' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_EVERGREEN_RENT_PAY' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_LATE_INTEREST_PAY' AND
                  p_styv_rec.stream_type_purpose <> 'RENEWAL_RENT' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_PRINCIPAL_BUYBACK' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_INTEREST_BUYBACK' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_PAYDOWN_BUYBACK' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_PRINCIPAL_DISB_BASIS' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_INTEREST_DISB_BASIS' AND
                  p_styv_rec.stream_type_purpose <> 'INVESTOR_PPD_DISB_BASIS' AND
                  p_styv_rec.stream_type_subclass IS NOT NULL)  THEN

                    OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream_Type_SubClass');
                    x_return_status := Okc_Api.G_RET_STS_ERROR;

               END IF;

        END IF;

        EXCEPTION
    	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
    	    	 -- no processing necessary;  validation can continue
    	    	 -- with the next column
    	    	 NULL;

    	     	WHEN OTHERS THEN
    	    	 -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                                  p_token1       => G_OKL_SQLCODE_TOKEN,
                                  p_token1_value => SQLCODE,
                                  p_token2       => G_OKL_SQLERRM_TOKEN,
                                  p_token2_value => SQLERRM);
    	    	 -- notify caller of an UNEXPECTED error
    	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Stream_Type_SubClass;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Accrual_Yn
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Accrual_Yn
    -- Description     :
    -- Business Rules  :

    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    Procedure Validate_Accrual_Yn( p_styv_rec IN  styv_rec_type,
                                  x_return_status OUT NOCOPY  VARCHAR2)
  	IS
	   l_found VARCHAR2(1);
       l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

	 -- prasjain - Bug#5762913 - Commented - Start
	 /*
	 CURSOR prev_strm_type_csr( p_sty_id OKL_STRM_TYPE_V.ID%TYPE) IS
         SELECT ACCRUAL_YN
         FROM   OKL_STRM_TYPE_V
         WHERE  ID = p_sty_id;
	 */
	 -- prasjain - Bug#5762913 - Commented - End

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- check for data before processing
	   	IF  (p_styv_rec.accrual_yn IS NULL) OR
            (p_styv_rec .accrual_yn  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'accrual_yn');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type =>
                                'OKL_STREAM_TYPE_CASH_BASIS',
                                p_lookup_code => p_styv_rec.accrual_yn);
    		IF (l_found <> OKL_API.G_TRUE ) THEN
                -- Modified by RGOOTY
                OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVENUE_RECOGNITION_BASIS');
                x_return_status := Okc_Api.G_RET_STS_ERROR;
                -- raise the exception as there's no matching foreign key value
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	    -- prasjain - Bug#5762913 - Commented - Start
            -- Cash Basis related fields on a stream type to be updatable always
            -- Decision taken to ensure that customers migrated to OKL.H can enable
            -- cash basis on their stream types if they had not used it in earlier
            -- codelines
            /*
	    --Modified by RGOOTY
            --Bug 4075113: Start
            FOR prev_strm_type_rec in prev_strm_type_csr( p_styv_rec.id )
            LOOP
                -- Stream Types with Accrual_Yn as 'ACRL_WITH_RULE' or 'ACRL_WITHOUT_RULE'
                -- cannot be changed to 'CASH_RECEIPT' and vice-versa
                IF  ( (
                        (   prev_strm_type_rec.accrual_yn = 'ACRL_WITH_RULE' OR
                            prev_strm_type_rec.accrual_yn = 'ACRL_WITHOUT_RULE' ) AND
                            p_styv_rec.accrual_yn = 'CASH_RECEIPT'
                        )
                        OR (
                        (   p_styv_rec.accrual_yn = 'ACRL_WITH_RULE' OR
                            p_styv_rec.accrual_yn = 'ACRL_WITHOUT_RULE' ) AND
                            prev_strm_type_rec.accrual_yn = 'CASH_RECEIPT'
                        )
                    )
                THEN
                    OKC_API.set_message(    G_OKC_APP,
                                            G_INVALID_VALUE,
                                            G_COL_NAME_TOKEN,
                                            'REVENUE_RECOGNITION_BASIS');
                    x_return_status := Okc_Api.G_RET_STS_ERROR;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
            END LOOP;
            --Bug 4075113: End
	    */
            -- prasjain - Bug#5762913 - Commented - End


            -- Modified by RGOOTY
            -- Bug 4137988: Start

            IF(  p_styv_rec.accrual_yn = 'CASH_RECEIPT' AND
            -- Added by SNANDIKO for Bug 6744584 Start
                ( p_styv_rec.contingency_id IS NULL OR
                   p_styv_rec.contingency_id = Okc_Api.G_MISS_NUM ) )
                    -- Added by SNANDIKO for Bug 6744584 End
            THEN
                OKC_API.set_message(    G_OKC_APP,
                                        G_REQUIRED_VALUE,
                                        G_COL_NAME_TOKEN,
                                        'CONTINGENCY');
                x_return_status := Okc_Api.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF ( ( p_styv_rec.accrual_yn = 'ACRL_WITH_RULE' OR
                        p_styv_rec.accrual_yn = 'ACRL_WITHOUT_RULE' ) AND
                        -- Added by SNANDIKO for Bug 6744584 Start
                      ( p_styv_rec.contingency_id IS NOT NULL OR
                        p_styv_rec.contingency_id = Okc_Api.G_MISS_NUM ) )
                        -- Added by SNANDIKO for Bug 6744584 End
            THEN
                OKC_API.set_message(    G_OKC_APP,
                                        G_INVALID_VALUE,
                                        G_COL_NAME_TOKEN,
                                        'CONTINGENCY');
                x_return_status := Okc_Api.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            -- Bug 4137988: End
        END IF;
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	        -- no processing necessary; validation can continue
	        -- with the next column
	        NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack for caller
            Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Accrual_YN;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Allocation_Factor
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : mvasudev
    -- Procedure Name  : Validate_Allocation_Factor
    -- Description     :
    -- Business Rules  :

    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_Allocation_Factor( p_styv_rec IN  styv_rec_type,
                                  x_return_status OUT NOCOPY  VARCHAR2)

  	IS

	l_found VARCHAR2(1);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

     -- check for data before processing
	IF (p_styv_rec.Allocation_Factor IS NOT NULL) AND
		(p_styv_rec .Allocation_Factor  <> Okc_Api.G_MISS_CHAR) THEN
	l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STY_ALLOCATION_BASIS',
							    p_lookup_code => p_styv_rec.Allocation_Factor);

		IF (l_found <> OKL_API.G_TRUE ) THEN
	     OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Allocation_Factor');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

     END IF;


     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Allocation_Factor;

 ---------------------------------------------------------------------------
    -- PROCEDURE validate_stream_type_purpose
    --------------------------------------------------------------------------
    --Author           : RGOOTY
    -- Procedure Name  : validate_stream_type_purpose
    -- Description     : Adding this one so as to purpose fetches only from the
    --                   OKL_STREAM_TYPE_PURPOSE values
    -- Business Rules  :

    -- Parameters      :
    -- Version         : 1.0
    ---------------------------------------------------------------------------

    Procedure validate_stream_type_purpose( p_styv_rec IN  styv_rec_type,
                                  x_return_status OUT NOCOPY  VARCHAR2)

  	IS

	l_found VARCHAR2(1);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

     -- check for data before processing
	IF (p_styv_rec.stream_type_purpose IS NOT NULL) AND
		(p_styv_rec.stream_type_purpose  <> Okc_Api.G_MISS_CHAR) THEN
	l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STREAM_TYPE_PURPOSE',
							    p_lookup_code => p_styv_rec.stream_type_purpose);

		IF (l_found <> OKL_API.G_TRUE ) THEN
             -- Modified by RGOOTY
	     OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PURPOSE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

     END IF;

-- Added by kthiruva for Bug 3935682

	   	IF (p_styv_rec.stream_type_purpose IS NULL) OR
	    	        (p_styv_rec.stream_type_purpose  = Okc_Api.G_MISS_CHAR) THEN
	    	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
	    	                     ,p_msg_name       => g_required_value
	    	                     ,p_token1         => g_col_name_token
	    	                     ,p_token1_value   => 'stream_type_purpose');
	    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	  RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_stream_type_purpose;
    ---------------------------------------------------------------------------
      -- FUNCTION Validate_Attributes
    ---------------------------------------------------------------------------
      -- Start of comments
      -- Procedure Name  : Validate_Attributes
      -- Description     :
      -- Business Rules  :
      -- Parameters      :
      -- Version         : 1.0
      -- End of comments
    ---------------------------------------------------------------------------
    Function Validate_Attributes (
    	    p_styv_rec IN  styv_rec_type
    	  ) RETURN VARCHAR2 IS

    	    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	  BEGIN

    	     -- call each column-level validation

    	    -- Validate_Id
    	    Validate_Id(p_styv_rec , x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

    	    -- Validate_Name
    	    Validate_Name(p_styv_rec , x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;

    	          -- Validate_Code only if Name_Validation went throgh fine
    	          -- as we always auto-update CODE := NAME
    	       ELSE
		    -- Validate_Code
		       Validate_Code(p_styv_rec, x_return_status);
					    -- store the highest degree of error
		       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
			  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
			  -- need to leave
			  l_return_status := x_return_status;
			  RAISE G_EXCEPTION_HALT_VALIDATION;
			  ELSE
			  -- record that there was an error
			  l_return_status := x_return_status;
			  END IF;
		       END IF;
    	       END IF;

    	    -- Validate_Version
    	    Validate_Version(p_styv_rec , x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

    	    -- Validate_Object_Version_Number
    	    Validate_Object_Version_Number(p_styv_rec , x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;
-- Commented by RGOOTY for ER 3935682: Start
/*

    	    -- Validate_Stream_Type_Scope
    	       Validate_Stream_Type_Scope(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;
*/

    	    -- Validate_Start_Date
    	       Validate_Start_Date(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

    	    -- Validate_End_Date
    	       Validate_End_Date(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

    	    -- Validate_Billable_Yn
    	       Validate_Billable_Yn(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

    	    -- Validate_Taxable_Default_Yn
    	       Validate_Taxable_Default_Yn(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

-- Commented by RGOOTY for ER 3935682: Start
/*
             -- Validate_Customization_Level
    	      Validate_Customization_Level(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

	    -- Validate_Stream_Type_Class
    	       Validate_Stream_Type_Class(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;
*/
-- Commented by RGOOTY for ER 3935682: End

    	       -- Validate_Stream_Type_SubClass
	          Validate_Stream_Type_SubClass(p_styv_rec, x_return_status);
	       -- store the highest degree of error
	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	           -- need to leave
	           l_return_status := x_return_status;
	           RAISE G_EXCEPTION_HALT_VALIDATION;
	           ELSE
	           -- record that there was an error
	           l_return_status := x_return_status;
	           END IF;
    	       END IF;

    	    -- Validate_Accrual_Yn
    	       Validate_Accrual_Yn(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;

-- Commented by RGOOTY for ER 3935682: Start
/*
             -- Validate_Allocation_Factor
    	       Validate_Allocation_Factor(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;
*/
-- Commented by RGOOTY for ER 3935682: End
	 -- validate_stream_type_purpose
    	       validate_stream_type_purpose(p_styv_rec, x_return_status);
    	    -- store the highest degree of error
    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	          -- need to leave
    	          l_return_status := x_return_status;
    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	          ELSE
    	          -- record that there was an error
    	          l_return_status := x_return_status;
    	          END IF;
    	       END IF;


    	    RETURN(l_return_status);
    	  EXCEPTION
    	    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    	       -- just come out with return status
               null;
    	       RETURN (l_return_status);

    	    WHEN OTHERS THEN
    	       -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
    	       -- notify caller of an UNEXPECTED error
    	       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    	       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Sty_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Sty_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Sty_Record(p_styv_rec      IN      styv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for sty Unique Key
  CURSOR okl_sty_uk_csr(p_rec styv_rec_type) IS
  SELECT '1'
  FROM OKL_STRM_TYPE_V
  WHERE  code =  p_rec.code
    AND  version =  p_rec.version
    AND  stream_type_purpose =  p_rec.stream_type_purpose
    AND  id     <> NVL(p_rec.id,-9999);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_sty_uk_csr(p_styv_rec);
    FETCH okl_sty_uk_csr INTO l_dummy;
    l_row_found := okl_sty_uk_csr%FOUND;
    CLOSE okl_sty_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_sty_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_styv_rec IN styv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_sty_Record
    Validate_Unique_sty_Record(p_styv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN styv_rec_type,
    p_to	IN OUT NOCOPY sty_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.version := p_from.version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.code := p_from.code;
    p_to.stream_type_scope := p_from.stream_type_scope;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.billable_yn := p_from.billable_yn;
    p_to.capitalize_yn := p_from.capitalize_yn;
    p_to.periodic_yn := p_from.periodic_yn;
    p_to.fundable_yn := p_from.fundable_yn;
    -- mvasudev , 05/13/2002
    p_to.allocation_factor := p_from.allocation_factor;
    --
    p_to.taxable_default_yn := p_from.taxable_default_yn;
    p_to.customization_level := p_from.customization_level;
    p_to.stream_type_class := p_from.stream_type_class;
    -- hkpatel   04/15/2002
    p_to.stream_type_subclass := p_from.stream_type_subclass;
    --
    p_to.accrual_yn := p_from.accrual_yn;
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
-- Added by RGOOTY for ER 3935682: Start
    p_to.stream_type_purpose := p_from.stream_type_purpose;
    p_to.contingency := p_from.contingency;
-- Added by RGOOTY for ER 3935682: End

-- Added by SNANDIKO for Bug 6744584 Start
    p_to.contingency_id := p_from.contingency_id;
-- Added by SNANDIKO for Bug 6744584 End

  END migrate;
  PROCEDURE migrate (
    p_from	IN sty_rec_type,
    p_to	IN OUT NOCOPY styv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.version := p_from.version;
    p_to.code := p_from.code;
    p_to.customization_level := p_from.customization_level;
    p_to.stream_type_scope := p_from.stream_type_scope;
    p_to.object_version_number := p_from.object_version_number;
    p_to.accrual_yn := p_from.accrual_yn;
    p_to.taxable_default_yn := p_from.taxable_default_yn;
    p_to.stream_type_class := p_from.stream_type_class;
    -- hkpatel   04/15/2003
    p_to.stream_type_subclass := p_from.stream_type_subclass;
    --
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.billable_yn := p_from.billable_yn;
    p_to.capitalize_yn := p_from.capitalize_yn;
    p_to.periodic_yn := p_from.periodic_yn;
    p_to.fundable_yn := p_from.fundable_yn;
    -- mvasudev , 05/13/2002
    p_to.allocation_factor := p_from.allocation_factor;
    --
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
-- Added by RGOOTY for ER 3935682: Start
    p_to.stream_type_purpose := p_from.stream_type_purpose;
    p_to.contingency := p_from.contingency;
-- Added by RGOOTY for ER 3935682: End

-- Added by SNANDIKO for Bug 6744584 Start
     p_to.contingency_id := p_from.contingency_id;
-- Added by SNANDIKO for Bug 6744584 End

  END migrate;
  PROCEDURE migrate (
    p_from	IN styv_rec_type,
    p_to	IN OUT NOCOPY okl_strm_type_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- Added by RGOOTY for ER 3935682: Start
    p_to.short_description := p_from.short_description;
-- Added by RGOOTY for ER 3935682: End
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_strm_type_tl_rec_type,
    p_to	IN OUT NOCOPY styv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- Added by RGOOTY for ER 3935682: Start
    p_to.short_description := p_from.short_description;
-- Added by RGOOTY for ER 3935682: End
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_STRM_TYPE_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_styv_rec                     styv_rec_type := p_styv_rec;
    l_sty_rec                      sty_rec_type;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_styv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_styv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:STYV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_styv_tbl.COUNT > 0) THEN
      i := p_styv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_styv_rec                     => p_styv_tbl(i));

        /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_styv_tbl.LAST);
        i := p_styv_tbl.NEXT(i);
      END LOOP;

    -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- insert_row for:OKL_STRM_TYPE_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sty_rec                      IN sty_rec_type,
    x_sty_rec                      OUT NOCOPY sty_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sty_rec                      sty_rec_type := p_sty_rec;
    l_def_sty_rec                  sty_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_sty_rec IN  sty_rec_type,
      x_sty_rec OUT NOCOPY sty_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sty_rec := p_sty_rec;
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
      p_sty_rec,                         -- IN
      l_sty_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_STRM_TYPE_B(
			id,
			version,
			code,
			customization_level,
			stream_type_scope,
			object_version_number,
			accrual_yn,
			taxable_default_yn,
			stream_type_class,
			-- hkpatel   04/15/2003
			stream_type_subclass,
			--
			start_date,
			end_date,
			billable_yn,
    		        capitalize_yn,
			periodic_yn,
			fundable_yn,
			-- mvasudev , 05/13/2002
			allocation_factor,
			--
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
-- Added by RGOOTY for ER 3935682: Start
			stream_type_purpose,
			contingency,
-- Added by RGOOTY for ER 3935682: End

-- Added by SNANDIKO for Bug 6744584 Start
                        contingency_id
-- Added by SNANDIKO for Bug 6744584 End
                        )
      VALUES (
			l_sty_rec.id,
			l_sty_rec.version,
			l_sty_rec.code,
			l_sty_rec.customization_level,
			l_sty_rec.stream_type_scope,
			l_sty_rec.object_version_number,
			l_sty_rec.accrual_yn,
			l_sty_rec.taxable_default_yn,
			l_sty_rec.stream_type_class,
			-- hkpatel    04/15/2003
			l_sty_rec.stream_type_subclass,
			--
			l_sty_rec.start_date,
			l_sty_rec.end_date,
			l_sty_rec.billable_yn,
    		l_sty_rec.capitalize_yn,
			l_sty_rec.periodic_yn,
			l_sty_rec.fundable_yn,
			-- mvasudev , 05/13/2002
			l_sty_rec.allocation_factor,
			--
			l_sty_rec.attribute_category,
			l_sty_rec.attribute1,
			l_sty_rec.attribute2,
			l_sty_rec.attribute3,
			l_sty_rec.attribute4,
			l_sty_rec.attribute5,
			l_sty_rec.attribute6,
			l_sty_rec.attribute7,
			l_sty_rec.attribute8,
			l_sty_rec.attribute9,
			l_sty_rec.attribute10,
			l_sty_rec.attribute11,
			l_sty_rec.attribute12,
			l_sty_rec.attribute13,
			l_sty_rec.attribute14,
			l_sty_rec.attribute15,
			l_sty_rec.created_by,
			l_sty_rec.creation_date,
			l_sty_rec.last_updated_by,
			l_sty_rec.last_update_date,
			l_sty_rec.last_update_login,
-- Added by RGOOTY for ER 3935682: Start
			l_sty_rec.stream_type_purpose,
			l_sty_rec.contingency,
-- Added by RGOOTY for ER 3935682: End
-- Added by SNANDIKO for Bug 6744584 Start
                        l_sty_rec.contingency_id
-- Added by SNANDIKO for Bug 6744584 End

			);
    -- Set OUT values
    x_sty_rec := l_sty_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------
  -- insert_row for:OKL_STRM_TYPE_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type,
    x_okl_strm_type_tl_rec         OUT NOCOPY okl_strm_type_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type := p_okl_strm_type_tl_rec;
    l_def_okl_strm_type_tl_rec     okl_strm_type_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_strm_type_tl_rec IN  okl_strm_type_tl_rec_type,
      x_okl_strm_type_tl_rec OUT NOCOPY okl_strm_type_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_strm_type_tl_rec := p_okl_strm_type_tl_rec;
      x_okl_strm_type_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_strm_type_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_strm_type_tl_rec,            -- IN
      l_okl_strm_type_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_strm_type_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_STRM_TYPE_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
-- Added by RGOOTY for ER 3935682: Start
	  short_description
-- Added by RGOOTY for ER 3935682: End
	 )
        VALUES (
          l_okl_strm_type_tl_rec.id,
          l_okl_strm_type_tl_rec.language,
          l_okl_strm_type_tl_rec.source_lang,
          l_okl_strm_type_tl_rec.sfwt_flag,
          l_okl_strm_type_tl_rec.name,
          l_okl_strm_type_tl_rec.description,
          l_okl_strm_type_tl_rec.created_by,
          l_okl_strm_type_tl_rec.creation_date,
          l_okl_strm_type_tl_rec.last_updated_by,
          l_okl_strm_type_tl_rec.last_update_date,
          l_okl_strm_type_tl_rec.last_update_login,
-- Added by RGOOTY for ER 3935682: Start
	  l_okl_strm_type_tl_rec.short_description
-- Added by RGOOTY for ER 3935682: End
	  );
    END LOOP;
    -- Set OUT values
    x_okl_strm_type_tl_rec := l_okl_strm_type_tl_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------
  -- insert_row for:OKL_STRM_TYPE_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type,
    x_styv_rec                     OUT NOCOPY styv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_styv_rec                     styv_rec_type;
    l_def_styv_rec                 styv_rec_type;
    l_sty_rec                      sty_rec_type;
    lx_sty_rec                     sty_rec_type;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
    lx_okl_strm_type_tl_rec        okl_strm_type_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_styv_rec	IN styv_rec_type
    ) RETURN styv_rec_type IS
      l_styv_rec	styv_rec_type := p_styv_rec;
    BEGIN
      l_styv_rec.CREATION_DATE := SYSDATE;
      l_styv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_styv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_styv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_styv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_styv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_styv_rec IN  styv_rec_type,
      x_styv_rec OUT NOCOPY styv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_styv_rec := p_styv_rec;
      x_styv_rec.OBJECT_VERSION_NUMBER := 1;
      x_styv_rec.SFWT_FLAG := 'N';
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
    l_styv_rec := null_out_defaults(p_styv_rec);
    -- Set primary key value
    l_styv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_styv_rec,                        -- IN
      l_def_styv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_styv_rec := fill_who_columns(l_def_styv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_styv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_styv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_styv_rec, l_sty_rec);
    migrate(l_def_styv_rec, l_okl_strm_type_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sty_rec,
      lx_sty_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sty_rec, l_def_styv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_type_tl_rec,
      lx_okl_strm_type_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_strm_type_tl_rec, l_def_styv_rec);
    -- Set OUT values
    x_styv_rec := l_def_styv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:STYV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type,
    x_styv_tbl                     OUT NOCOPY styv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_styv_tbl.COUNT > 0) THEN
      i := p_styv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_styv_rec                     => p_styv_tbl(i),
          x_styv_rec                     => x_styv_tbl(i));

      /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_styv_tbl.LAST);
        i := p_styv_tbl.NEXT(i);
      END LOOP;
     -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- lock_row for:OKL_STRM_TYPE_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sty_rec                      IN sty_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sty_rec IN sty_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYPE_B
     WHERE ID = p_sty_rec.id
       AND OBJECT_VERSION_NUMBER = p_sty_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sty_rec IN sty_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYPE_B
    WHERE ID = p_sty_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_STRM_TYPE_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_STRM_TYPE_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_sty_rec);
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
      OPEN lchk_csr(p_sty_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sty_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sty_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------
  -- lock_row for:OKL_STRM_TYPE_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_strm_type_tl_rec IN okl_strm_type_tl_rec_type) IS
    SELECT *
      FROM OKL_STRM_TYPE_TL
     WHERE ID = p_okl_strm_type_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_okl_strm_type_tl_rec);
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------
  -- lock_row for:OKL_STRM_TYPE_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sty_rec                      sty_rec_type;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_styv_rec, l_sty_rec);
    migrate(p_styv_rec, l_okl_strm_type_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sty_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_type_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:STYV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_styv_tbl.COUNT > 0) THEN
      i := p_styv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_styv_rec                     => p_styv_tbl(i));
          /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_styv_tbl.LAST);
        i := p_styv_tbl.NEXT(i);
      END LOOP;

    -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- update_row for:OKL_STRM_TYPE_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sty_rec                      IN sty_rec_type,
    x_sty_rec                      OUT NOCOPY sty_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sty_rec                      sty_rec_type := p_sty_rec;
    l_def_sty_rec                  sty_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sty_rec	IN sty_rec_type,
      x_sty_rec	OUT NOCOPY sty_rec_type
    ) RETURN VARCHAR2 IS
      l_sty_rec                      sty_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sty_rec := p_sty_rec;
      -- Get current database values
      l_sty_rec := get_rec(p_sty_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sty_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.id := l_sty_rec.id;
      END IF;
      IF (x_sty_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.version := l_sty_rec.version;
      END IF;
      IF (x_sty_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.code := l_sty_rec.code;
      END IF;
      IF (x_sty_rec.customization_level = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.customization_level := l_sty_rec.customization_level;
      END IF;
      IF (x_sty_rec.stream_type_scope = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.stream_type_scope := l_sty_rec.stream_type_scope;
      END IF;
      IF (x_sty_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.object_version_number := l_sty_rec.object_version_number;
      END IF;
      IF (x_sty_rec.accrual_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.accrual_yn := l_sty_rec.accrual_yn;
      END IF;
      IF (x_sty_rec.taxable_default_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.taxable_default_yn := l_sty_rec.taxable_default_yn;
      END IF;
      IF (x_sty_rec.stream_type_class = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.stream_type_class := l_sty_rec.stream_type_class;
      END IF;
      -- hkpatel    04/15/2003
      IF (x_sty_rec.stream_type_subclass = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.stream_type_subclass := l_sty_rec.stream_type_subclass;
      END IF;
      --
      IF (x_sty_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_sty_rec.start_date := l_sty_rec.start_date;
      END IF;
      IF (x_sty_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_sty_rec.end_date := l_sty_rec.end_date;
      END IF;
      IF (x_sty_rec.billable_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.billable_yn := l_sty_rec.billable_yn;
      END IF;
      IF (x_sty_rec.capitalize_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.capitalize_yn := l_sty_rec.capitalize_yn;
      END IF;
      IF (x_sty_rec.periodic_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.periodic_yn := l_sty_rec.periodic_yn;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_sty_rec.fundable_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.fundable_yn := l_sty_rec.fundable_yn;
      END IF;
      IF (x_sty_rec.allocation_factor = OKC_API.G_MISS_CHAR)
            THEN
              x_sty_rec.allocation_factor := l_sty_rec.allocation_factor;
      END IF;
      --
      IF (x_sty_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute_category := l_sty_rec.attribute_category;
      END IF;
      IF (x_sty_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute1 := l_sty_rec.attribute1;
      END IF;
      IF (x_sty_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute2 := l_sty_rec.attribute2;
      END IF;
      IF (x_sty_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute3 := l_sty_rec.attribute3;
      END IF;
      IF (x_sty_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute4 := l_sty_rec.attribute4;
      END IF;
      IF (x_sty_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute5 := l_sty_rec.attribute5;
      END IF;
      IF (x_sty_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute6 := l_sty_rec.attribute6;
      END IF;
      IF (x_sty_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute7 := l_sty_rec.attribute7;
      END IF;
      IF (x_sty_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute8 := l_sty_rec.attribute8;
      END IF;
      IF (x_sty_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute9 := l_sty_rec.attribute9;
      END IF;
      IF (x_sty_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute10 := l_sty_rec.attribute10;
      END IF;
      IF (x_sty_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute11 := l_sty_rec.attribute11;
      END IF;
      IF (x_sty_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute12 := l_sty_rec.attribute12;
      END IF;
      IF (x_sty_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute13 := l_sty_rec.attribute13;
      END IF;
      IF (x_sty_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute14 := l_sty_rec.attribute14;
      END IF;
      IF (x_sty_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.attribute15 := l_sty_rec.attribute15;
      END IF;
      IF (x_sty_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.created_by := l_sty_rec.created_by;
      END IF;
      IF (x_sty_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sty_rec.creation_date := l_sty_rec.creation_date;
      END IF;
      IF (x_sty_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.last_updated_by := l_sty_rec.last_updated_by;
      END IF;
      IF (x_sty_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sty_rec.last_update_date := l_sty_rec.last_update_date;
      END IF;
      IF (x_sty_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.last_update_login := l_sty_rec.last_update_login;
      END IF;
-- Added by RGOOTY for ER 3935682: Start
      IF (x_sty_rec.stream_type_purpose = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.stream_type_purpose := l_sty_rec.stream_type_purpose;
      END IF;
      IF (x_sty_rec.contingency = OKC_API.G_MISS_CHAR)
      THEN
        x_sty_rec.contingency := l_sty_rec.contingency;
      END IF;
-- Added by RGOOTY for ER 3935682: End
-- Added by SNANDIKO for Bug 6744584 Start
      IF (x_sty_rec.contingency_id = OKC_API.G_MISS_NUM)
      THEN
        x_sty_rec.contingency_id := l_sty_rec.contingency_id;
      END IF;
-- Added by SNANDIKO for Bug 6744584 End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_sty_rec IN  sty_rec_type,
      x_sty_rec OUT NOCOPY sty_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sty_rec := p_sty_rec;
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
      p_sty_rec,                         -- IN
      l_sty_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sty_rec, l_def_sty_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STRM_TYPE_B
    SET
	VERSION	= l_def_sty_rec.version,
	CODE	= l_def_sty_rec.code,
	CUSTOMIZATION_LEVEL = l_def_sty_rec.customization_level,
	STREAM_TYPE_SCOPE	= l_def_sty_rec.stream_type_scope,
        OBJECT_VERSION_NUMBER = l_def_sty_rec.object_version_number,
        ACCRUAL_YN = l_def_sty_rec.accrual_yn,
        TAXABLE_DEFAULT_YN = l_def_sty_rec.taxable_default_yn,
        STREAM_TYPE_CLASS = l_def_sty_rec.stream_type_class,
        -- hkpatel    04/15/2003
        STREAM_TYPE_SUBCLASS = l_def_sty_rec.stream_type_subclass,
        --
        START_DATE = l_def_sty_rec.start_date,
        END_DATE = l_def_sty_rec.end_date,
        BILLABLE_YN = l_def_sty_rec.billable_yn,
        CAPITALIZE_YN = l_def_sty_rec.capitalize_yn,
        PERIODIC_YN = l_def_sty_rec.periodic_yn,
        -- mvasudev , 05/13/2002
        FUNDABLE_YN = l_def_sty_rec.fundable_yn,
        ALLOCATION_FACTOR = l_def_sty_rec.allocation_factor,
        --
        ATTRIBUTE_CATEGORY = l_def_sty_rec.attribute_category,
        ATTRIBUTE1 = l_def_sty_rec.attribute1,
        ATTRIBUTE2 = l_def_sty_rec.attribute2,
        ATTRIBUTE3 = l_def_sty_rec.attribute3,
        ATTRIBUTE4 = l_def_sty_rec.attribute4,
        ATTRIBUTE5 = l_def_sty_rec.attribute5,
        ATTRIBUTE6 = l_def_sty_rec.attribute6,
        ATTRIBUTE7 = l_def_sty_rec.attribute7,
        ATTRIBUTE8 = l_def_sty_rec.attribute8,
        ATTRIBUTE9 = l_def_sty_rec.attribute9,
        ATTRIBUTE10 = l_def_sty_rec.attribute10,
        ATTRIBUTE11 = l_def_sty_rec.attribute11,
        ATTRIBUTE12 = l_def_sty_rec.attribute12,
        ATTRIBUTE13 = l_def_sty_rec.attribute13,
        ATTRIBUTE14 = l_def_sty_rec.attribute14,
        ATTRIBUTE15 = l_def_sty_rec.attribute15,
        CREATED_BY = l_def_sty_rec.created_by,
        CREATION_DATE = l_def_sty_rec.creation_date,
        LAST_UPDATED_BY = l_def_sty_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sty_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sty_rec.last_update_login,
-- Added by RGOOTY for ER 3935682: Start
	STREAM_TYPE_PURPOSE = l_def_sty_rec.stream_type_purpose,
	CONTINGENCY         = l_def_sty_rec.contingency,
-- Added by RGOOTY for ER 3935682: End
-- Added by SNANDIKO for Bug 6744584 Start
        CONTINGENCY_ID         = l_def_sty_rec.contingency_id
-- Added by SNANDIKO for Bug 6744584 End
    WHERE ID = l_def_sty_rec.id;

    x_sty_rec := l_def_sty_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------
  -- update_row for:OKL_STRM_TYPE_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type,
    x_okl_strm_type_tl_rec         OUT NOCOPY okl_strm_type_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type := p_okl_strm_type_tl_rec;
    l_def_okl_strm_type_tl_rec     okl_strm_type_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_strm_type_tl_rec	IN okl_strm_type_tl_rec_type,
      x_okl_strm_type_tl_rec	OUT NOCOPY okl_strm_type_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_strm_type_tl_rec := p_okl_strm_type_tl_rec;
      -- Get current database values
      l_okl_strm_type_tl_rec := get_rec(p_okl_strm_type_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_strm_type_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_strm_type_tl_rec.id := l_okl_strm_type_tl_rec.id;
      END IF;
      IF (x_okl_strm_type_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.language := l_okl_strm_type_tl_rec.language;
      END IF;
      IF (x_okl_strm_type_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.source_lang := l_okl_strm_type_tl_rec.source_lang;
      END IF;
      IF (x_okl_strm_type_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.sfwt_flag := l_okl_strm_type_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_strm_type_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.name := l_okl_strm_type_tl_rec.name;
      END IF;
      IF (x_okl_strm_type_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.description := l_okl_strm_type_tl_rec.description;
      END IF;
      IF (x_okl_strm_type_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_strm_type_tl_rec.created_by := l_okl_strm_type_tl_rec.created_by;
      END IF;
      IF (x_okl_strm_type_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_strm_type_tl_rec.creation_date := l_okl_strm_type_tl_rec.creation_date;
      END IF;
      IF (x_okl_strm_type_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_strm_type_tl_rec.last_updated_by := l_okl_strm_type_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_strm_type_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_strm_type_tl_rec.last_update_date := l_okl_strm_type_tl_rec.last_update_date;
      END IF;
      IF (x_okl_strm_type_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_strm_type_tl_rec.last_update_login := l_okl_strm_type_tl_rec.last_update_login;
      END IF;
-- Added by RGOOTY for ER 3935682: Start
      IF (x_okl_strm_type_tl_rec.short_description= OKC_API.G_MISS_CHAR)
      THEN
        x_okl_strm_type_tl_rec.short_description := l_okl_strm_type_tl_rec.short_description;
      END IF;
-- Added by RGOOTY for ER 3935682: End
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_strm_type_tl_rec IN  okl_strm_type_tl_rec_type,
      x_okl_strm_type_tl_rec OUT NOCOPY okl_strm_type_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_strm_type_tl_rec := p_okl_strm_type_tl_rec;
      x_okl_strm_type_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_strm_type_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_strm_type_tl_rec,            -- IN
      l_okl_strm_type_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_strm_type_tl_rec, l_def_okl_strm_type_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STRM_TYPE_TL
    SET NAME = l_def_okl_strm_type_tl_rec.name,
        DESCRIPTION = l_def_okl_strm_type_tl_rec.description,
        CREATED_BY = l_def_okl_strm_type_tl_rec.created_by,
        SOURCE_LANG = l_def_okl_strm_type_tl_rec.source_lang,
        CREATION_DATE = l_def_okl_strm_type_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_strm_type_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_strm_type_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_strm_type_tl_rec.last_update_login,
-- Added by RGOOTY for ER 3935682: Start
	SHORT_DESCRIPTION = l_def_okl_strm_type_tl_rec.short_description
-- Added by RGOOTY for ER 3935682: End
    WHERE ID = l_def_okl_strm_type_tl_rec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
    --  AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_STRM_TYPE_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_strm_type_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_strm_type_tl_rec := l_def_okl_strm_type_tl_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------
  -- update_row for:OKL_STRM_TYPE_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type,
    x_styv_rec                     OUT NOCOPY styv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_styv_rec                     styv_rec_type := p_styv_rec;
    l_def_styv_rec                 styv_rec_type;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
    lx_okl_strm_type_tl_rec        okl_strm_type_tl_rec_type;
    l_sty_rec                      sty_rec_type;
    lx_sty_rec                     sty_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_styv_rec	IN styv_rec_type
    ) RETURN styv_rec_type IS
      l_styv_rec	styv_rec_type := p_styv_rec;
    BEGIN
      l_styv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_styv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_styv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_styv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_styv_rec	IN styv_rec_type,
      x_styv_rec	OUT NOCOPY styv_rec_type
    ) RETURN VARCHAR2 IS
      l_styv_rec                     styv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_styv_rec := p_styv_rec;
      -- Get current database values
      l_styv_rec := get_rec(p_styv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_styv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.id := l_styv_rec.id;
      END IF;
      IF (x_styv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.name := l_styv_rec.name;
      END IF;
      IF (x_styv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.version := l_styv_rec.version;
      END IF;
      IF (x_styv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.object_version_number := l_styv_rec.object_version_number;
      END IF;
      IF (x_styv_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.code := l_styv_rec.code;
      END IF;
      IF (x_styv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.sfwt_flag := l_styv_rec.sfwt_flag;
      END IF;
      IF (x_styv_rec.stream_type_scope = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.stream_type_scope := l_styv_rec.stream_type_scope;
      END IF;
      IF (x_styv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.description := l_styv_rec.description;
      END IF;
      IF (x_styv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_styv_rec.start_date := l_styv_rec.start_date;
      END IF;
      IF (x_styv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_styv_rec.end_date := l_styv_rec.end_date;
      END IF;
      IF (x_styv_rec.billable_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.billable_yn := l_styv_rec.billable_yn;
      END IF;
      IF (x_styv_rec.capitalize_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.capitalize_yn := l_styv_rec.capitalize_yn;
      END IF;
      IF (x_styv_rec.periodic_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.periodic_yn := l_styv_rec.periodic_yn;
      END IF;
      -- mvasudev , 05/13/2002
      IF (x_styv_rec.fundable_yn = OKC_API.G_MISS_CHAR)
      THEN
          x_styv_rec.fundable_yn := l_styv_rec.fundable_yn;
      END IF;
      IF (x_styv_rec.allocation_factor = OKC_API.G_MISS_CHAR)
      THEN
         x_styv_rec.allocation_factor := l_styv_rec.allocation_factor;
      END IF;
      --
      IF (x_styv_rec.taxable_default_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.taxable_default_yn := l_styv_rec.taxable_default_yn;
      END IF;
      IF (x_styv_rec.customization_level = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.customization_level := l_styv_rec.customization_level;
      END IF;
      IF (x_styv_rec.stream_type_class = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.stream_type_class := l_styv_rec.stream_type_class;
      END IF;
      -- hkpatel    04/15/2003
      IF (x_styv_rec.stream_type_subclass = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.stream_type_subclass := l_styv_rec.stream_type_subclass;
      END IF;
      --
      IF (x_styv_rec.accrual_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.accrual_yn := l_styv_rec.accrual_yn;
      END IF;
      IF (x_styv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute_category := l_styv_rec.attribute_category;
      END IF;
      IF (x_styv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute1 := l_styv_rec.attribute1;
      END IF;
      IF (x_styv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute2 := l_styv_rec.attribute2;
      END IF;
      IF (x_styv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute3 := l_styv_rec.attribute3;
      END IF;
      IF (x_styv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute4 := l_styv_rec.attribute4;
      END IF;
      IF (x_styv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute5 := l_styv_rec.attribute5;
      END IF;
      IF (x_styv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute6 := l_styv_rec.attribute6;
      END IF;
      IF (x_styv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute7 := l_styv_rec.attribute7;
      END IF;
      IF (x_styv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute8 := l_styv_rec.attribute8;
      END IF;
      IF (x_styv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute9 := l_styv_rec.attribute9;
      END IF;
      IF (x_styv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute10 := l_styv_rec.attribute10;
      END IF;
      IF (x_styv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute11 := l_styv_rec.attribute11;
      END IF;
      IF (x_styv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute12 := l_styv_rec.attribute12;
      END IF;
      IF (x_styv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute13 := l_styv_rec.attribute13;
      END IF;
      IF (x_styv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute14 := l_styv_rec.attribute14;
      END IF;
      IF (x_styv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.attribute15 := l_styv_rec.attribute15;
      END IF;
      IF (x_styv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.created_by := l_styv_rec.created_by;
      END IF;
      IF (x_styv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_styv_rec.creation_date := l_styv_rec.creation_date;
      END IF;
      IF (x_styv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.last_updated_by := l_styv_rec.last_updated_by;
      END IF;
      IF (x_styv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_styv_rec.last_update_date := l_styv_rec.last_update_date;
      END IF;
      IF (x_styv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.last_update_login := l_styv_rec.last_update_login;
      END IF;
-- Added by RGOOTY for ER 3935682: Start
      IF (x_styv_rec.stream_type_purpose = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.stream_type_purpose := l_styv_rec.stream_type_purpose;
      END IF;
      IF (x_styv_rec.contingency = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.contingency := l_styv_rec.contingency;
      END IF;
      IF (x_styv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_styv_rec.short_description := l_styv_rec.short_description;
      END IF;
-- Added by RGOOTY for ER 3935682: End
-- Added by SNANDIKO for Bug 6744584 Start
      IF (x_styv_rec.contingency_id = OKC_API.G_MISS_NUM)
      THEN
        x_styv_rec.contingency_id := l_styv_rec.contingency_id;
      END IF;
-- Added by SNANDIKO for Bug 6744584 End
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_styv_rec IN  styv_rec_type,
      x_styv_rec OUT NOCOPY styv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_styv_rec := p_styv_rec;
      x_styv_rec.OBJECT_VERSION_NUMBER := NVL(x_styv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_styv_rec,                        -- IN
      l_styv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_styv_rec, l_def_styv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_styv_rec := fill_who_columns(l_def_styv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_styv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_styv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_styv_rec, l_okl_strm_type_tl_rec);
    migrate(l_def_styv_rec, l_sty_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_type_tl_rec,
      lx_okl_strm_type_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_strm_type_tl_rec, l_def_styv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sty_rec,
      lx_sty_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sty_rec, l_def_styv_rec);
    x_styv_rec := l_def_styv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:STYV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type,
    x_styv_tbl                     OUT NOCOPY styv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_styv_tbl.COUNT > 0) THEN
      i := p_styv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_styv_rec                     => p_styv_tbl(i),
          x_styv_rec                     => x_styv_tbl(i));
        /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_styv_tbl.LAST);
        i := p_styv_tbl.NEXT(i);
      END LOOP;

     -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- delete_row for:OKL_STRM_TYPE_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sty_rec                      IN sty_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sty_rec                      sty_rec_type:= p_sty_rec;
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
    DELETE FROM OKL_STRM_TYPE_B
     WHERE ID = l_sty_rec.id;

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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------
  -- delete_row for:OKL_STRM_TYPE_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_strm_type_tl_rec         IN okl_strm_type_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type:= p_okl_strm_type_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_strm_type_tl_rec IN  okl_strm_type_tl_rec_type,
      x_okl_strm_type_tl_rec OUT NOCOPY okl_strm_type_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_strm_type_tl_rec := p_okl_strm_type_tl_rec;
      x_okl_strm_type_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_strm_type_tl_rec,            -- IN
      l_okl_strm_type_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_STRM_TYPE_TL
     WHERE ID = l_okl_strm_type_tl_rec.id;

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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------
  -- delete_row for:OKL_STRM_TYPE_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_styv_rec                     styv_rec_type := p_styv_rec;
    l_okl_strm_type_tl_rec         okl_strm_type_tl_rec_type;
    l_sty_rec                      sty_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_styv_rec, l_okl_strm_type_tl_rec);
    migrate(l_styv_rec, l_sty_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_type_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sty_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:STYV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_styv_tbl.COUNT > 0) THEN
      i := p_styv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_styv_rec                     => p_styv_tbl(i));

         /* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_styv_tbl.LAST);
        i := p_styv_tbl.NEXT(i);
      END LOOP;

    -- return the overall status
  x_return_status :=l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


 -------------------------------------------------------------------------------
  -- Procedure TRANSLATE_ROW
 -------------------------------------------------------------------------------
  PROCEDURE TRANSLATE_ROW(p_styv_rec IN styv_rec_type,
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
      FROM OKL_STRM_TYPE_TL
      where ID = to_number(p_styv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
	UPDATE OKL_STRM_TYPE_TL
	SET
	   ID                = TO_NUMBER(p_styv_rec.id),
	   DESCRIPTION       = p_styv_rec.description,
	   NAME              = p_styv_rec.name,
	   LAST_UPDATE_DATE  = f_ludate,
	   LAST_UPDATED_BY   = f_luby,
	   LAST_UPDATE_LOGIN = 0,
	   SOURCE_LANG       = USERENV('LANG')
	WHERE ID = to_number(p_styv_rec.id)
	AND USERENV('LANG') IN (language,source_lang);
     END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_styv_rec IN styv_rec_type,
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
      FROM OKL_STRM_TYPE_B
      where ID = p_styv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
         UPDATE OKL_STRM_TYPE_B
		 SET
		   OBJECT_VERSION_NUMBER = p_styv_rec.object_version_number,
		   START_DATE            = p_styv_rec.start_date,
		   END_DATE              = p_styv_rec.end_date,
		   CUSTOMIZATION_LEVEL   = p_styv_rec.customization_level,
		   STREAM_TYPE_SCOPE     = p_styv_rec.stream_type_scope,
		   ACCRUAL_YN            = p_styv_rec.accrual_yn,
		   TAXABLE_DEFAULT_YN    = p_styv_rec.taxable_default_yn,
		   STREAM_TYPE_CLASS     = p_styv_rec.stream_type_class,
		   STREAM_TYPE_SUBCLASS  = p_styv_rec.stream_type_subclass,
		   BILLABLE_YN           = p_styv_rec.billable_yn,
		   CAPITALIZE_YN         = p_styv_rec.capitalize_yn,
		   PERIODIC_YN           = p_styv_rec.periodic_yn,
		   FUNDABLE_YN           = p_styv_rec.fundable_yn,
		   ALLOCATION_FACTOR     = p_styv_rec.allocation_factor,
		   LAST_UPDATE_DATE      = f_ludate,
		   LAST_UPDATED_BY       = f_luby,
		   LAST_UPDATE_LOGIN     = 0,
		   VERSION               = p_styv_rec.version,
		   CODE                  = p_styv_rec.code,
		   ATTRIBUTE_CATEGORY    = p_styv_rec.attribute_category ,
		   ATTRIBUTE1            = p_styv_rec.attribute1,
		   ATTRIBUTE2            = p_styv_rec.attribute2,
		   ATTRIBUTE3            = p_styv_rec.attribute3,
		   ATTRIBUTE4            = p_styv_rec.attribute4,
		   ATTRIBUTE5            = p_styv_rec.attribute5,
		   ATTRIBUTE6            = p_styv_rec.attribute6,
		   ATTRIBUTE7            = p_styv_rec.attribute7,
		   ATTRIBUTE8            = p_styv_rec.attribute8,
		   ATTRIBUTE9            = p_styv_rec.attribute9,
		   ATTRIBUTE10           = p_styv_rec.attribute10,
		   ATTRIBUTE11           = p_styv_rec.attribute11,
		   ATTRIBUTE12           = p_styv_rec.attribute12,
		   ATTRIBUTE13           = p_styv_rec.attribute13,
		   ATTRIBUTE14           = p_styv_rec.attribute14,
		   ATTRIBUTE15           = p_styv_rec.attribute15 ,
		   STREAM_TYPE_PURPOSE   = p_styv_rec.stream_type_purpose,
		   CONTINGENCY	         = p_styv_rec.contingency,
-- Added by SNANDIKO for Bug 6744584 Start
                   CONTINGENCY_ID	         = p_styv_rec.contingency_id
-- Added by SNANDIKO for Bug 6744584 End
	      WHERE ID = to_number(p_styv_rec.ID);
		  --Update TL
         UPDATE OKL_STRM_TYPE_TL
	     SET
		   ID                = p_styv_rec.ID,
		   NAME              = p_styv_rec.NAME,
		   DESCRIPTION       = p_styv_rec.DESCRIPTION,
		   LAST_UPDATE_DATE  = f_ludate,
		   LAST_UPDATED_BY   = f_luby,
		   LAST_UPDATE_LOGIN = 0,
		   SOURCE_LANG       = USERENV('LANG')
	     WHERE ID = TO_NUMBER(p_styv_rec.ID)
		  AND USERENV('LANG') IN (language,source_lang);

      IF(sql%notfound) THEN
    	 INSERT INTO OKL_STRM_TYPE_TL
		( ID,
		  NAME,
		  LANGUAGE,
		  SOURCE_LANG,
		  SFWT_FLAG,
		  DESCRIPTION,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN
		) select
		  p_styv_rec.ID,
		  p_styv_rec.NAME,
		  L.LANGUAGE_CODE,
		  USERENV('LANG'),
		  decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
		  p_styv_rec.DESCRIPTION,
		  f_luby,
		  f_ludate,
		  f_luby,
		  f_ludate,
		  0
		from FND_LANGUAGES L
		where L.INSTALLED_FLAG IN ('I','B')
		and not exists
		      ( select NULL
			from okl_strm_type_tl TL
			where TL.ID = TO_NUMBER(p_styv_rec.ID)
			and   TL.LANGUAGE = L.LANGUAGE_CODE );

	 end if;

    END IF;
   END;
   EXCEPTION
     when no_data_found then
       INSERT INTO OKL_STRM_TYPE_B
		(ID,
		VERSION,
		CODE,
		CUSTOMIZATION_LEVEL,
		STREAM_TYPE_SCOPE,
		OBJECT_VERSION_NUMBER,
		ACCRUAL_YN,
		TAXABLE_DEFAULT_YN,
		STREAM_TYPE_CLASS,
		STREAM_TYPE_SUBCLASS,
		START_DATE,
		END_DATE,
		BILLABLE_YN,
		CAPITALIZE_YN,
		PERIODIC_YN,
		FUNDABLE_YN,
		ALLOCATION_FACTOR,
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
		STREAM_TYPE_PURPOSE,
		CONTINGENCY,
                -- Added by SNANDIKO for Bug 6744584 Start
                CONTINGENCY_ID )
                -- Added by SNANDIKO for Bug 6744584 End
	  Select
	    p_styv_rec.ID,
	    p_styv_rec.VERSION,
	    p_styv_rec.CODE,
	    p_styv_rec.CUSTOMIZATION_LEVEL,
	    p_styv_rec.STREAM_TYPE_SCOPE,
	    p_styv_rec.OBJECT_VERSION_NUMBER,
	    p_styv_rec.ACCRUAL_YN,
	    p_styv_rec.TAXABLE_DEFAULT_YN,
	    p_styv_rec.STREAM_TYPE_CLASS,
	    p_styv_rec.STREAM_TYPE_SUBCLASS,
	    p_styv_rec.START_DATE,
	    p_styv_rec.END_DATE,
	    p_styv_rec.BILLABLE_YN,
	    p_styv_rec.CAPITALIZE_YN,
	    p_styv_rec.PERIODIC_YN,
	    p_styv_rec.FUNDABLE_YN,
	    p_styv_rec.ALLOCATION_FACTOR,
	    p_styv_rec.ATTRIBUTE_CATEGORY,
	    p_styv_rec.ATTRIBUTE1,
	    p_styv_rec.ATTRIBUTE2,
	    p_styv_rec.ATTRIBUTE3,
	    p_styv_rec.ATTRIBUTE4,
	    p_styv_rec.ATTRIBUTE5,
	    p_styv_rec.ATTRIBUTE6,
	    p_styv_rec.ATTRIBUTE7,
	    p_styv_rec.ATTRIBUTE8,
	    p_styv_rec.ATTRIBUTE9,
	    p_styv_rec.ATTRIBUTE10,
	    p_styv_rec.ATTRIBUTE11,
	    p_styv_rec.ATTRIBUTE12,
	    p_styv_rec.ATTRIBUTE13,
	    p_styv_rec.ATTRIBUTE14,
	    p_styv_rec.ATTRIBUTE15,
	    f_luby,
	    f_ludate,
	    f_luby,
	    f_ludate,
	    0,
	    p_styv_rec.STREAM_TYPE_PURPOSE,
	    p_styv_rec.CONTINGENCY,
            -- Added by SNANDIKO for Bug 6744584 Start
            p_styv_rec.CONTINGENCY_ID
            -- Added by SNANDIKO for Bug 6744584 End
       from dual
	   where not exists (select 1
			  from okl_strm_type_b
			  where ID = TO_NUMBER(p_styv_rec.ID));

	   INSERT INTO OKL_STRM_TYPE_TL
		(
		ID,
		LANGUAGE,
		SOURCE_LANG,
		SFWT_FLAG,
		NAME,
		DESCRIPTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
		)
		SELECT
			p_styv_rec.id,
			L.LANGUAGE_CODE,
			userenv('LANG'),
			decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
			p_styv_rec.NAME,
			p_styv_rec.DESCRIPTION,
			f_luby,
			f_ludate,
			f_luby,
			f_ludate,
			0
		  FROM FND_LANGUAGES L
		  WHERE L.INSTALLED_FLAG IN ('I','B')
		   AND NOT EXISTS
		    (SELECT NULL
		      FROM OKL_STRM_TYPE_TL TL
		      WHERE TL.ID = TO_NUMBER(p_styv_rec.ID)
		      AND  TL.LANGUAGE = L.LANGUAGE_CODE);
   END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode IN VARCHAR2,
    p_id IN VARCHAR2,
    p_version IN VARCHAR2,
    p_code IN VARCHAR2,
    p_customization_level IN VARCHAR2,
    p_stream_type_scope IN VARCHAR2,
    p_object_version_number IN VARCHAR2,
    p_accrual_yn IN VARCHAR2,
    p_taxable_default_yn IN VARCHAR2,
    p_stream_type_class IN VARCHAR2,
    p_stream_type_subclass IN VARCHAR2,
    p_start_date IN VARCHAR2,
    p_end_date IN VARCHAR2,
    p_billable_yn IN VARCHAR2,
    p_capitalize_yn IN VARCHAR2,
    p_periodic_yn IN VARCHAR2,
    p_fundable_yn IN VARCHAR2,
    p_allocation_factor IN VARCHAR2,
    p_attribute_category IN VARCHAR2,
    p_attribute1  IN VARCHAR2,
    p_attribute2  IN VARCHAR2,
    p_attribute3  IN VARCHAR2,
    p_attribute4  IN VARCHAR2,
    p_attribute5  IN VARCHAR2,
    p_attribute6  IN VARCHAR2,
    p_attribute7  IN VARCHAR2,
    p_attribute8  IN VARCHAR2,
    p_attribute9  IN VARCHAR2,
    p_attribute10 IN VARCHAR2,
    p_attribute11 IN VARCHAR2,
    p_attribute12 IN VARCHAR2,
    p_attribute13 IN VARCHAR2,
    p_attribute14 IN VARCHAR2,
    p_attribute15 IN VARCHAR2,
    p_stream_type_purpose IN VARCHAR2,
    p_contingency IN VARCHAR2,
    p_name IN VARCHAR2,
    p_description IN VARCHAR2,
    p_owner IN VARCHAR2,
    p_last_update_date IN VARCHAR2,
    -- Added by SNANDIKO for Bug 6744584 Start
    p_contingency_id IN VARCHAR2) IS
    -- Added by SNANDIKO for Bug 6744584 End

  l_api_version   CONSTANT number := 1;
  l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
  l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
  l_msg_count              number;
  l_msg_data               varchar2(4000);
  l_init_msg_list          VARCHAR2(1):= 'T';
  l_styv_rec               styv_rec_type;
  BEGIN

   --Prepare Record Structure for Insert/Update
    l_styv_rec.id :=  TO_NUMBER(p_id);
    l_styv_rec.name  := p_name;
    l_styv_rec.version  := p_version;
    l_styv_rec.object_version_number  := p_object_version_number;
    l_styv_rec.code	 := p_code;
    l_styv_rec.stream_type_scope  := p_stream_type_scope;
    l_styv_rec.description  := p_description;
    l_styv_rec.start_date  :=  TO_DATE(p_start_date,'YYYY/MM/DD');
    l_styv_rec.end_date    :=  TO_DATE(p_end_date,'YYYY/MM/DD');
    l_styv_rec.billable_yn  := p_billable_yn;
    l_styv_rec.taxable_default_yn  := p_taxable_default_yn;
    l_styv_rec.customization_level := p_customization_level;
    l_styv_rec.stream_type_class   := p_stream_type_class;
    l_styv_rec.stream_type_subclass  := p_stream_type_subclass;
    l_styv_rec.accrual_yn   := p_accrual_yn;
    l_styv_rec.capitalize_yn  := p_capitalize_yn;
    l_styv_rec.periodic_yn  := p_periodic_yn;
    l_styv_rec.fundable_yn  := p_fundable_yn;
    l_styv_rec.allocation_factor  := p_allocation_factor;
    l_styv_rec.attribute_category := p_attribute_category;
    l_styv_rec.attribute1	 :=	p_attribute1;
    l_styv_rec.attribute2	 :=	p_attribute2;
    l_styv_rec.attribute3	 :=	p_attribute3;
    l_styv_rec.attribute4	 :=	p_attribute4;
    l_styv_rec.attribute5	 :=	p_attribute5;
    l_styv_rec.attribute6	 :=	p_attribute6;
    l_styv_rec.attribute7	 :=	p_attribute7;
    l_styv_rec.attribute8	 :=	p_attribute8;
    l_styv_rec.attribute9	 :=	p_attribute9;
    l_styv_rec.attribute10	 :=	p_attribute10;
    l_styv_rec.attribute11	 :=	p_attribute11;
    l_styv_rec.attribute12	 :=	p_attribute12;
    l_styv_rec.attribute13	 :=	p_attribute13;
    l_styv_rec.attribute14	 :=	p_attribute14;
    l_styv_rec.attribute15	 :=	p_attribute15;
    l_styv_rec.contingency	 := p_contingency;
    l_styv_rec.stream_type_purpose	:= p_stream_type_purpose;

    -- Added by SNANDIKO for Bug 6744584 Start
    l_styv_rec.contingency_id	 := p_contingency_id;
-- Added by SNANDIKO for Bug 6744584 End
   IF(p_upload_mode = 'NLS') then
     OKL_STY_PVT.TRANSLATE_ROW(p_styv_rec => l_styv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);
   ELSE
    OKL_STY_PVT.LOAD_ROW(p_styv_rec => l_styv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);
   END IF;
 END LOAD_SEED_ROW;

END OKL_STY_PVT;

/
