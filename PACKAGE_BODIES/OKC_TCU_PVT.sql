--------------------------------------------------------
--  DDL for Package Body OKC_TCU_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TCU_PVT" AS
/* $Header: OKCSTCUB.pls 120.0 2005/05/25 19:22:15 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
    DELETE FROM OKC_TIME_CODE_UNITS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_TIME_CODE_UNITS_B B
         WHERE B.uom_code = T.uom_code
           AND B.TCE_CODE = T.TCE_CODE
        );

    UPDATE OKC_TIME_CODE_UNITS_TL T SET (
        SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.SHORT_DESCRIPTION,
                                  B.DESCRIPTION,
                                  B.COMMENTS
                                FROM OKC_TIME_CODE_UNITS_TL B
                               WHERE B.uom_code = T.uom_code
                                 AND B.TCE_CODE = T.TCE_CODE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.uom_code,
              T.TCE_CODE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.uom_code,
                  SUBT.TCE_CODE,
                  SUBT.LANGUAGE
                FROM OKC_TIME_CODE_UNITS_TL SUBB, OKC_TIME_CODE_UNITS_TL SUBT
               WHERE SUBB.uom_code = SUBT.uom_code
                 AND SUBB.TCE_CODE = SUBT.TCE_CODE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKC_TIME_CODE_UNITS_TL (
        uom_code,
        TCE_CODE,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.uom_code,
            B.TCE_CODE,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.SHORT_DESCRIPTION,
            B.DESCRIPTION,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_TIME_CODE_UNITS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_TIME_CODE_UNITS_TL T
                     WHERE T.uom_code = B.uom_code
                       AND T.TCE_CODE = B.TCE_CODE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_TIME_CODE_UNITS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tcu_rec                      IN tcu_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tcu_rec_type IS
    CURSOR tcu_pk_csr (p_uom_code    IN VARCHAR2,
                       p_tce_code           IN VARCHAR2) IS
    SELECT
            TCE_CODE,
            uom_code,
            QUANTITY,
            ACTIVE_FLAG,
            OBJECT_VERSION_NUMBER,
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
      FROM Okc_Time_Code_Units_B
     WHERE okc_time_code_units_b.uom_code = p_uom_code
       AND okc_time_code_units_b.tce_code = p_tce_code;
    l_tcu_pk                       tcu_pk_csr%ROWTYPE;
    l_tcu_rec                      tcu_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tcu_pk_csr (p_tcu_rec.uom_code,
                     p_tcu_rec.tce_code);
    FETCH tcu_pk_csr INTO
              l_tcu_rec.TCE_CODE,
              l_tcu_rec.uom_code,
              l_tcu_rec.QUANTITY,
              l_tcu_rec.ACTIVE_FLAG,
              l_tcu_rec.OBJECT_VERSION_NUMBER,
              l_tcu_rec.CREATED_BY,
              l_tcu_rec.CREATION_DATE,
              l_tcu_rec.LAST_UPDATED_BY,
              l_tcu_rec.LAST_UPDATE_DATE,
              l_tcu_rec.LAST_UPDATE_LOGIN,
              l_tcu_rec.ATTRIBUTE_CATEGORY,
              l_tcu_rec.ATTRIBUTE1,
              l_tcu_rec.ATTRIBUTE2,
              l_tcu_rec.ATTRIBUTE3,
              l_tcu_rec.ATTRIBUTE4,
              l_tcu_rec.ATTRIBUTE5,
              l_tcu_rec.ATTRIBUTE6,
              l_tcu_rec.ATTRIBUTE7,
              l_tcu_rec.ATTRIBUTE8,
              l_tcu_rec.ATTRIBUTE9,
              l_tcu_rec.ATTRIBUTE10,
              l_tcu_rec.ATTRIBUTE11,
              l_tcu_rec.ATTRIBUTE12,
              l_tcu_rec.ATTRIBUTE13,
              l_tcu_rec.ATTRIBUTE14,
              l_tcu_rec.ATTRIBUTE15;
    x_no_data_found := tcu_pk_csr%NOTFOUND;
    CLOSE tcu_pk_csr;
    RETURN(l_tcu_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tcu_rec                      IN tcu_rec_type
  ) RETURN tcu_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tcu_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_TIME_CODE_UNITS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcTimeCodeUnitsTlRecType IS
    CURSOR tcu_pktl_csr (p_uom_code    IN VARCHAR2,
                         p_tce_code           IN VARCHAR2,
                         p_language           IN VARCHAR2) IS
    SELECT
            uom_code,
            TCE_CODE,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            SHORT_DESCRIPTION,
            DESCRIPTION,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Time_Code_Units_Tl
     WHERE okc_time_code_units_tl.uom_code = p_uom_code
       AND okc_time_code_units_tl.tce_code = p_tce_code
       AND okc_time_code_units_tl.language = p_language;
    l_tcu_pktl                     tcu_pktl_csr%ROWTYPE;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tcu_pktl_csr (p_okc_time_code_units_tl_rec.uom_code,
                       p_okc_time_code_units_tl_rec.tce_code,
                       p_okc_time_code_units_tl_rec.language);
    FETCH tcu_pktl_csr INTO
              l_okc_time_code_units_tl_rec.uom_code,
              l_okc_time_code_units_tl_rec.TCE_CODE,
              l_okc_time_code_units_tl_rec.LANGUAGE,
              l_okc_time_code_units_tl_rec.SOURCE_LANG,
              l_okc_time_code_units_tl_rec.SFWT_FLAG,
              l_okc_time_code_units_tl_rec.SHORT_DESCRIPTION,
              l_okc_time_code_units_tl_rec.DESCRIPTION,
              l_okc_time_code_units_tl_rec.COMMENTS,
              l_okc_time_code_units_tl_rec.CREATED_BY,
              l_okc_time_code_units_tl_rec.CREATION_DATE,
              l_okc_time_code_units_tl_rec.LAST_UPDATED_BY,
              l_okc_time_code_units_tl_rec.LAST_UPDATE_DATE,
              l_okc_time_code_units_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := tcu_pktl_csr%NOTFOUND;
    CLOSE tcu_pktl_csr;
    RETURN(l_okc_time_code_units_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType
  ) RETURN OkcTimeCodeUnitsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_time_code_units_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_TIME_CODE_UNITS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tcuv_rec                     IN tcuv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tcuv_rec_type IS
    CURSOR okc_tcuv_pk_csr (p_tce_code           IN VARCHAR2,
                            p_uom_code    IN VARCHAR2) IS
    SELECT
            uom_code,
            TCE_CODE,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            QUANTITY,
            ACTIVE_FLAG,
            SHORT_DESCRIPTION,
            DESCRIPTION,
            COMMENTS,
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
            LAST_UPDATE_LOGIN
      FROM Okc_Time_Code_Units_V
     WHERE okc_time_code_units_v.tce_code = p_tce_code
       AND okc_time_code_units_v.uom_code = p_uom_code;
    l_okc_tcuv_pk                  okc_tcuv_pk_csr%ROWTYPE;
    l_tcuv_rec                     tcuv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_tcuv_pk_csr (p_tcuv_rec.tce_code,
                          p_tcuv_rec.uom_code);
    FETCH okc_tcuv_pk_csr INTO
              l_tcuv_rec.uom_code,
              l_tcuv_rec.TCE_CODE,
              l_tcuv_rec.OBJECT_VERSION_NUMBER,
              l_tcuv_rec.SFWT_FLAG,
              l_tcuv_rec.QUANTITY,
              l_tcuv_rec.ACTIVE_FLAG,
              l_tcuv_rec.SHORT_DESCRIPTION,
              l_tcuv_rec.DESCRIPTION,
              l_tcuv_rec.COMMENTS,
              l_tcuv_rec.ATTRIBUTE_CATEGORY,
              l_tcuv_rec.ATTRIBUTE1,
              l_tcuv_rec.ATTRIBUTE2,
              l_tcuv_rec.ATTRIBUTE3,
              l_tcuv_rec.ATTRIBUTE4,
              l_tcuv_rec.ATTRIBUTE5,
              l_tcuv_rec.ATTRIBUTE6,
              l_tcuv_rec.ATTRIBUTE7,
              l_tcuv_rec.ATTRIBUTE8,
              l_tcuv_rec.ATTRIBUTE9,
              l_tcuv_rec.ATTRIBUTE10,
              l_tcuv_rec.ATTRIBUTE11,
              l_tcuv_rec.ATTRIBUTE12,
              l_tcuv_rec.ATTRIBUTE13,
              l_tcuv_rec.ATTRIBUTE14,
              l_tcuv_rec.ATTRIBUTE15,
              l_tcuv_rec.CREATED_BY,
              l_tcuv_rec.CREATION_DATE,
              l_tcuv_rec.LAST_UPDATED_BY,
              l_tcuv_rec.LAST_UPDATE_DATE,
              l_tcuv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_tcuv_pk_csr%NOTFOUND;
    CLOSE okc_tcuv_pk_csr;
    G_QUANTITY := l_tcuv_rec.quantity;
    RETURN(l_tcuv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tcuv_rec                     IN tcuv_rec_type
  ) RETURN tcuv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tcuv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_TIME_CODE_UNITS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tcuv_rec	IN tcuv_rec_type
  ) RETURN tcuv_rec_type IS
    l_tcuv_rec	tcuv_rec_type := p_tcuv_rec;
  BEGIN
    IF (l_tcuv_rec.uom_code = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.uom_code := NULL;
    END IF;
    IF (l_tcuv_rec.tce_code = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.tce_code := NULL;
    END IF;
    IF (l_tcuv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_tcuv_rec.object_version_number := NULL;
    END IF;
    IF (l_tcuv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tcuv_rec.quantity = OKC_API.G_MISS_NUM) THEN
      l_tcuv_rec.quantity := NULL;
    END IF;
    IF (l_tcuv_rec.active_flag = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.active_flag := NULL;
    END IF;
    IF (l_tcuv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.short_description := NULL;
    END IF;
    IF (l_tcuv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.description := NULL;
    END IF;
    IF (l_tcuv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.comments := NULL;
    END IF;
    IF (l_tcuv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute_category := NULL;
    END IF;
    IF (l_tcuv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute1 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute2 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute3 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute4 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute5 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute6 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute7 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute8 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute9 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute10 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute11 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute12 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute13 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute14 := NULL;
    END IF;
    IF (l_tcuv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_tcuv_rec.attribute15 := NULL;
    END IF;
    IF (l_tcuv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_tcuv_rec.created_by := NULL;
    END IF;
    IF (l_tcuv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_tcuv_rec.creation_date := NULL;
    END IF;
    IF (l_tcuv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_tcuv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tcuv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_tcuv_rec.last_update_date := NULL;
    END IF;
    IF (l_tcuv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_tcuv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_tcuv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -- Validate_Attributes for:OKC_TIME_CODE_UNITS_V --
  --------------------------------------------------
  --**** Change from TAPI Code---follow till end of change---------------

  PROCEDURE Validate_uom_code (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_tcuv_rec                     IN tcuv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
/*  Commented this cursor for bug 1787982
      CURSOR uom_pk_csr (p_uom_code IN okx_units_of_measure_v.uom_code%type) IS
      SELECT  '1'
        FROM OKX_Units_Of_Measure_v
       WHERE uom_code        = p_uom_code;
*/
/*
  --Commented this cursor as this cursor should be based on MTL_UNITS_OF_MEASURE

      CURSOR uom_pk_csr (p_uom_code IN okc_timeunit_v.uom_code%type) IS
      SELECT  '1'
        FROM okc_timeunit_v
       WHERE uom_code        = p_uom_code
         AND active_flag = 'Y';
*/
      CURSOR uom_pk_csr (p_uom_code IN okc_timeunit_v.uom_code%type) IS
      SELECT  '1'
        FROM OKX_Units_Of_Measure_v
       WHERE uom_code        = p_uom_code
         AND (trunc(disable_date) > trunc(sysdate) or
              disable_date is NULL);
      l_uom_pk                  uom_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_tcuv_rec.uom_code IS NOT NULL AND
          p_tcuv_rec.uom_code <> OKC_API.G_MISS_CHAR)
      THEN
        OPEN uom_pk_csr(p_tcuv_rec.uom_code);
        FETCH uom_pk_csr INTO l_uom_pk;
        l_row_notfound := uom_pk_csr%NOTFOUND;
        CLOSE uom_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
          RAISE item_not_found_error;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'uom_code');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_uom_code ;

  PROCEDURE Validate_Tce_Code (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_tcuv_rec.TCE_CODE IS NOT NULL AND
          p_tcuv_rec.TCE_CODE <> OKC_API.G_MISS_CHAR)
      THEN
	   x_return_status := OKC_UTIL.CHECK_LOOKUP_CODE('OKC_TIME',p_tcuv_rec.TCE_CODE);
        if x_return_status = OKC_API.G_RET_STS_ERROR
	   Then
		OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TCE_CODE');
	   end if;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tce_code');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TCE_CODE',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Tce_Code ;

  PROCEDURE Validate_SFWT_Flag (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS
  BEGIN
    IF upper(p_tcuv_rec.sfwt_flag) = 'Y' OR
       upper(p_tcuv_rec.sfwt_flag) = 'N'
    THEN
       IF p_tcuv_rec.sfwt_flag = 'Y' OR
          p_tcuv_rec.sfwt_flag = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'SFWT_FLAG');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SFWT_FLAG');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_SFWT_Flag;

  PROCEDURE Validate_Active_Flag (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS
  BEGIN
    IF upper(p_tcuv_rec.active_flag) = 'Y' OR
       upper(p_tcuv_rec.active_flag) = 'N'
    THEN
       IF p_tcuv_rec.active_flag = 'Y' OR
          p_tcuv_rec.active_flag = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'ACTIVE_FLAG');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
   -- ELSE
    --   OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACTIVE_FLAG');
     --  x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_col_name_token,
                          p_token2_value => 'Active_Flag',
                          p_token3       => g_sqlerrm_token,
                          p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Active_Flag;

  ---------------------------------------------------
  -- Validate_Attributes for:OKC_TIME_CODE_UNITS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tcuv_rec IN  tcuv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_tcuv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_tcuv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF p_tcuv_rec.quantity = OKC_API.G_MISS_NUM OR
       p_tcuv_rec.quantity IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'quantity');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    Validate_uom_code (l_return_status,
                           p_tcuv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Tce_Code (l_return_status,
                     p_tcuv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Active_Flag (l_return_status,
                     p_tcuv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_TIME_CODE_UNITS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_tcuv_rec IN tcuv_rec_type
  ) RETURN VARCHAR2 IS
    --l_col_tbl	                    okc_util.unq_tbl_type;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy                        VARCHAR2(1);
    l_row_found                    Boolean := False;
    Cursor c1(p_tce_code okc_time_code_units_v.tce_code%TYPE,
		    p_uom_code okc_time_code_units_v.uom_code%TYPE) is
    SELECT 1
    FROM okc_time_code_units_b
    WHERE tce_code = p_tce_code
    AND   uom_code = p_uom_code;

    Cursor c2(p_uom_code okc_time_code_units_v.uom_code%TYPE,
		    p_quantity okc_time_code_units_v.quantity%TYPE) is
    SELECT 1
    FROM okc_time_code_units_b
    WHERE uom_code = p_uom_code
    AND   quantity = p_quantity;

  BEGIN
    IF G_RECORD_STATUS = 'I' THEN
   /* Bug 1636056:The following code commented out nocopy since it was not using bind
		 varibles and parsing was taking place. Replaced with explicit cursor
		 as defined above
	--Check for unique value
      l_col_tbl(1).p_col_name := 'TCE_CODE';
      l_col_tbl(1).p_col_val := p_tcuv_rec.tce_code;
      l_col_tbl(2).p_col_name := 'UOM_CODE';
      l_col_tbl(2).p_col_val := p_tcuv_rec.uom_code;
      OKC_UTIL.check_comp_unique('OKC_TIME_CODE_UNITS_V',
                                 l_col_tbl,
                                 l_return_status);
	 if l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	   return (l_return_status);
	 end if;*/
	 OPEN c1(p_tcuv_rec.tce_code,
		    p_tcuv_rec.uom_code);
      FETCH c1 into l_dummy;
	 l_row_found := c1%FOUND;
	 CLOSE c1;
	 IF l_row_found THEN
		 --OKC_API.set_message(G_APP_NAME, G_UNQS, G_COL_NAME_TOKEN1, 'uom_code', G_COL_NAME_TOKEN2, 'tce_code');
		 OKC_API.set_message(G_APP_NAME, G_UNQS1);
		 l_return_status := OKC_API.G_RET_STS_ERROR;
    RETURN (l_return_status);
      END IF;
    END IF;
    IF (G_QUANTITY <> p_tcuv_rec.quantity) OR
	 (G_RECORD_STATUS = 'I') THEN
   /* Bug 1636056:The following code commented out nocopy since it was not using bind
		 varibles and parsing was taking place. Replaced with explicit cursor
		 as defined above
      l_col_tbl(1).p_col_name := 'UOM_CODE';
      l_col_tbl(1).p_col_val := p_tcuv_rec.uom_code;
      l_col_tbl(2).p_col_name := 'QUANTITY';
      l_col_tbl(2).p_col_val := p_tcuv_rec.quantity;
      OKC_UTIL.check_comp_unique('OKC_TIME_CODE_UNITS_V',
                                l_col_tbl,
                                l_return_status); */
	 OPEN c2(p_tcuv_rec.uom_code,
		    p_tcuv_rec.quantity);
      FETCH c2 into l_dummy;
	 l_row_found := c2%FOUND;
	 CLOSE c2;
	 IF l_row_found THEN
		 --OKC_API.set_message(G_APP_NAME, G_UNQS, 'COL_NAME1', p_tcuv_rec.uom_code, 'COL_NAME2',p_tcuv_rec.quantity);
		 OKC_API.set_message(G_APP_NAME, G_UNQS2);
		 l_return_status := OKC_API.G_RET_STS_ERROR;
    RETURN (l_return_status);
      END IF;

    END IF;
    RETURN (l_return_status);
  END Validate_Record;

  --**** end of change-------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tcuv_rec_type,
    p_to	IN OUT NOCOPY tcu_rec_type
  ) IS
  BEGIN
    p_to.tce_code := p_from.tce_code;
    p_to.uom_code := p_from.uom_code;
    p_to.quantity := p_from.quantity;
    p_to.active_flag := p_from.active_flag;
    p_to.object_version_number := p_from.object_version_number;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN tcu_rec_type,
    p_to	IN OUT NOCOPY tcuv_rec_type
  ) IS
  BEGIN
    p_to.tce_code := p_from.tce_code;
    p_to.uom_code := p_from.uom_code;
    p_to.quantity := p_from.quantity;
    p_to.active_flag := p_from.active_flag;
    p_to.object_version_number := p_from.object_version_number;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN tcuv_rec_type,
    p_to	IN OUT NOCOPY OkcTimeCodeUnitsTlRecType
  ) IS
  BEGIN
    p_to.uom_code := p_from.uom_code;
    p_to.tce_code := p_from.tce_code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OkcTimeCodeUnitsTlRecType,
    p_to	IN OUT NOCOPY tcuv_rec_type
  ) IS
  BEGIN
    p_to.uom_code := p_from.uom_code;
    p_to.tce_code := p_from.tce_code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKC_TIME_CODE_UNITS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcuv_rec                     tcuv_rec_type := p_tcuv_rec;
    l_tcu_rec                      tcu_rec_type;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
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
    l_return_status := Validate_Attributes(l_tcuv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tcuv_rec);
    G_QUANTITY := OKC_API.G_MISS_NUM;
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
  -- PL/SQL TBL validate_row for:TCUV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcuv_tbl.COUNT > 0) THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcuv_rec                     => p_tcuv_tbl(i));
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- insert_row for:OKC_TIME_CODE_UNITS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcu_rec                      IN tcu_rec_type,
    x_tcu_rec                      OUT NOCOPY tcu_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcu_rec                      tcu_rec_type := p_tcu_rec;
    l_def_tcu_rec                  tcu_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tcu_rec IN  tcu_rec_type,
      x_tcu_rec OUT NOCOPY tcu_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcu_rec := p_tcu_rec;
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
      p_tcu_rec,                         -- IN
      l_tcu_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_TIME_CODE_UNITS_B(
        tce_code,
        uom_code,
        quantity,
        active_flag,
        object_version_number,
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
        l_tcu_rec.tce_code,
        l_tcu_rec.uom_code,
        l_tcu_rec.quantity,
        l_tcu_rec.active_flag,
        l_tcu_rec.object_version_number,
        l_tcu_rec.created_by,
        l_tcu_rec.creation_date,
        l_tcu_rec.last_updated_by,
        l_tcu_rec.last_update_date,
        l_tcu_rec.last_update_login,
        l_tcu_rec.attribute_category,
        l_tcu_rec.attribute1,
        l_tcu_rec.attribute2,
        l_tcu_rec.attribute3,
        l_tcu_rec.attribute4,
        l_tcu_rec.attribute5,
        l_tcu_rec.attribute6,
        l_tcu_rec.attribute7,
        l_tcu_rec.attribute8,
        l_tcu_rec.attribute9,
        l_tcu_rec.attribute10,
        l_tcu_rec.attribute11,
        l_tcu_rec.attribute12,
        l_tcu_rec.attribute13,
        l_tcu_rec.attribute14,
        l_tcu_rec.attribute15);
    -- Set OUT values
    x_tcu_rec := l_tcu_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_TIME_CODE_UNITS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType,
    x_okc_time_code_units_tl_rec   OUT NOCOPY OkcTimeCodeUnitsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType := p_okc_time_code_units_tl_rec;
    ldefokctimecodeunitstlrec      OkcTimeCodeUnitsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_time_code_units_tl_rec IN  OkcTimeCodeUnitsTlRecType,
      x_okc_time_code_units_tl_rec OUT NOCOPY OkcTimeCodeUnitsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_time_code_units_tl_rec := p_okc_time_code_units_tl_rec;
      x_okc_time_code_units_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_time_code_units_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_time_code_units_tl_rec,      -- IN
      l_okc_time_code_units_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_time_code_units_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_TIME_CODE_UNITS_TL(
          uom_code,
          tce_code,
          language,
          source_lang,
          sfwt_flag,
          short_description,
          description,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_time_code_units_tl_rec.uom_code,
          l_okc_time_code_units_tl_rec.tce_code,
          l_okc_time_code_units_tl_rec.language,
          l_okc_time_code_units_tl_rec.source_lang,
          l_okc_time_code_units_tl_rec.sfwt_flag,
          l_okc_time_code_units_tl_rec.short_description,
          l_okc_time_code_units_tl_rec.description,
          l_okc_time_code_units_tl_rec.comments,
          l_okc_time_code_units_tl_rec.created_by,
          l_okc_time_code_units_tl_rec.creation_date,
          l_okc_time_code_units_tl_rec.last_updated_by,
          l_okc_time_code_units_tl_rec.last_update_date,
          l_okc_time_code_units_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_time_code_units_tl_rec := l_okc_time_code_units_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKC_TIME_CODE_UNITS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type,
    x_tcuv_rec                     OUT NOCOPY tcuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcuv_rec                     tcuv_rec_type;
    l_def_tcuv_rec                 tcuv_rec_type;
    l_tcu_rec                      tcu_rec_type;
    lx_tcu_rec                     tcu_rec_type;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
    lx_okc_time_code_units_tl_rec  OkcTimeCodeUnitsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tcuv_rec	IN tcuv_rec_type
    ) RETURN tcuv_rec_type IS
      l_tcuv_rec	tcuv_rec_type := p_tcuv_rec;
    BEGIN
      l_tcuv_rec.CREATION_DATE := SYSDATE;
      l_tcuv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tcuv_rec.LAST_UPDATE_DATE := l_tcuv_rec.CREATION_DATE;
      l_tcuv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tcuv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tcuv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tcuv_rec IN  tcuv_rec_type,
      x_tcuv_rec OUT NOCOPY tcuv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcuv_rec := p_tcuv_rec;
      x_tcuv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tcuv_rec.SFWT_FLAG := 'N';
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
    l_tcuv_rec := null_out_defaults(p_tcuv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tcuv_rec,                        -- IN
      l_def_tcuv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tcuv_rec := fill_who_columns(l_def_tcuv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tcuv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  --**** uniqueness is checked only in insert cases--------------------
    G_RECORD_STATUS := 'I';
    l_return_status := Validate_Record(l_def_tcuv_rec);
    G_RECORD_STATUS := OKC_API.G_MISS_CHAR;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tcuv_rec, l_tcu_rec);
    migrate(l_def_tcuv_rec, l_okc_time_code_units_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcu_rec,
      lx_tcu_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcu_rec, l_def_tcuv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_time_code_units_tl_rec,
      lx_okc_time_code_units_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_time_code_units_tl_rec, l_def_tcuv_rec);
    -- Set OUT values
    x_tcuv_rec := l_def_tcuv_rec;
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
  -- PL/SQL TBL insert_row for:TCUV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcuv_tbl.COUNT > 0) THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcuv_rec                     => p_tcuv_tbl(i),
          x_tcuv_rec                     => x_tcuv_tbl(i));
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
      END LOOP;
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
  ----------------------------------------
  -- lock_row for:OKC_TIME_CODE_UNITS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcu_rec                      IN tcu_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tcu_rec IN tcu_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_TIME_CODE_UNITS_B
     WHERE uom_code = p_tcu_rec.uom_code
       AND TCE_CODE = p_tcu_rec.tce_code
       AND OBJECT_VERSION_NUMBER = p_tcu_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tcu_rec IN tcu_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_TIME_CODE_UNITS_B
    WHERE uom_code = p_tcu_rec.uom_code
       AND TCE_CODE = p_tcu_rec.tce_code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_TIME_CODE_UNITS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_TIME_CODE_UNITS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tcu_rec);
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
      OPEN lchk_csr(p_tcu_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tcu_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tcu_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
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
  -----------------------------------------
  -- lock_row for:OKC_TIME_CODE_UNITS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_time_code_units_tl_rec IN OkcTimeCodeUnitsTlRecType) IS
    SELECT uom_code
      FROM OKC_TIME_CODE_UNITS_TL
     WHERE uom_code = p_okc_time_code_units_tl_rec.uom_code
       AND TCE_CODE = p_okc_time_code_units_tl_rec.tce_code
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
      OPEN lock_csr(p_okc_time_code_units_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKC_TIME_CODE_UNITS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcu_rec                      tcu_rec_type;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
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
    migrate(p_tcuv_rec, l_tcu_rec);
    migrate(p_tcuv_rec, l_okc_time_code_units_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcu_rec
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
      l_okc_time_code_units_tl_rec
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
  -- PL/SQL TBL lock_row for:TCUV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcuv_tbl.COUNT > 0) THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcuv_rec                     => p_tcuv_tbl(i));
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- update_row for:OKC_TIME_CODE_UNITS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcu_rec                      IN tcu_rec_type,
    x_tcu_rec                      OUT NOCOPY tcu_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcu_rec                      tcu_rec_type := p_tcu_rec;
    l_def_tcu_rec                  tcu_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tcu_rec	IN tcu_rec_type,
      x_tcu_rec	OUT NOCOPY tcu_rec_type
    ) RETURN VARCHAR2 IS
      l_tcu_rec                      tcu_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcu_rec := p_tcu_rec;
      -- Get current database values
      l_tcu_rec := get_rec(p_tcu_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tcu_rec.tce_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.tce_code := l_tcu_rec.tce_code;
      END IF;
      IF (x_tcu_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.uom_code := l_tcu_rec.uom_code;
      END IF;
      IF (x_tcu_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tcu_rec.quantity := l_tcu_rec.quantity;
      END IF;
      IF (x_tcu_rec.active_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.active_flag := l_tcu_rec.active_flag;
      END IF;
      IF (x_tcu_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tcu_rec.object_version_number := l_tcu_rec.object_version_number;
      END IF;
      IF (x_tcu_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcu_rec.created_by := l_tcu_rec.created_by;
      END IF;
      IF (x_tcu_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcu_rec.creation_date := l_tcu_rec.creation_date;
      END IF;
      IF (x_tcu_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcu_rec.last_updated_by := l_tcu_rec.last_updated_by;
      END IF;
      IF (x_tcu_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcu_rec.last_update_date := l_tcu_rec.last_update_date;
      END IF;
      IF (x_tcu_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tcu_rec.last_update_login := l_tcu_rec.last_update_login;
      END IF;
      IF (x_tcu_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute_category := l_tcu_rec.attribute_category;
      END IF;
      IF (x_tcu_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute1 := l_tcu_rec.attribute1;
      END IF;
      IF (x_tcu_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute2 := l_tcu_rec.attribute2;
      END IF;
      IF (x_tcu_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute3 := l_tcu_rec.attribute3;
      END IF;
      IF (x_tcu_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute4 := l_tcu_rec.attribute4;
      END IF;
      IF (x_tcu_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute5 := l_tcu_rec.attribute5;
      END IF;
      IF (x_tcu_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute6 := l_tcu_rec.attribute6;
      END IF;
      IF (x_tcu_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute7 := l_tcu_rec.attribute7;
      END IF;
      IF (x_tcu_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute8 := l_tcu_rec.attribute8;
      END IF;
      IF (x_tcu_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute9 := l_tcu_rec.attribute9;
      END IF;
      IF (x_tcu_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute10 := l_tcu_rec.attribute10;
      END IF;
      IF (x_tcu_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute11 := l_tcu_rec.attribute11;
      END IF;
      IF (x_tcu_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute12 := l_tcu_rec.attribute12;
      END IF;
      IF (x_tcu_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute13 := l_tcu_rec.attribute13;
      END IF;
      IF (x_tcu_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute14 := l_tcu_rec.attribute14;
      END IF;
      IF (x_tcu_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcu_rec.attribute15 := l_tcu_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tcu_rec IN  tcu_rec_type,
      x_tcu_rec OUT NOCOPY tcu_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcu_rec := p_tcu_rec;
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
      p_tcu_rec,                         -- IN
      l_tcu_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tcu_rec, l_def_tcu_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_TIME_CODE_UNITS_B
    SET QUANTITY = l_def_tcu_rec.quantity,
        ACTIVE_FLAG = l_def_tcu_rec.active_flag,
        OBJECT_VERSION_NUMBER = l_def_tcu_rec.object_version_number,
        CREATED_BY = l_def_tcu_rec.created_by,
        CREATION_DATE = l_def_tcu_rec.creation_date,
        LAST_UPDATED_BY = l_def_tcu_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tcu_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tcu_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_tcu_rec.attribute_category,
        ATTRIBUTE1 = l_def_tcu_rec.attribute1,
        ATTRIBUTE2 = l_def_tcu_rec.attribute2,
        ATTRIBUTE3 = l_def_tcu_rec.attribute3,
        ATTRIBUTE4 = l_def_tcu_rec.attribute4,
        ATTRIBUTE5 = l_def_tcu_rec.attribute5,
        ATTRIBUTE6 = l_def_tcu_rec.attribute6,
        ATTRIBUTE7 = l_def_tcu_rec.attribute7,
        ATTRIBUTE8 = l_def_tcu_rec.attribute8,
        ATTRIBUTE9 = l_def_tcu_rec.attribute9,
        ATTRIBUTE10 = l_def_tcu_rec.attribute10,
        ATTRIBUTE11 = l_def_tcu_rec.attribute11,
        ATTRIBUTE12 = l_def_tcu_rec.attribute12,
        ATTRIBUTE13 = l_def_tcu_rec.attribute13,
        ATTRIBUTE14 = l_def_tcu_rec.attribute14,
        ATTRIBUTE15 = l_def_tcu_rec.attribute15
    WHERE uom_code = l_def_tcu_rec.uom_code
      AND TCE_CODE = l_def_tcu_rec.tce_code;

    x_tcu_rec := l_def_tcu_rec;
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
  -------------------------------------------
  -- update_row for:OKC_TIME_CODE_UNITS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType,
    x_okc_time_code_units_tl_rec   OUT NOCOPY OkcTimeCodeUnitsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType := p_okc_time_code_units_tl_rec;
    ldefokctimecodeunitstlrec      OkcTimeCodeUnitsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_time_code_units_tl_rec	IN OkcTimeCodeUnitsTlRecType,
      x_okc_time_code_units_tl_rec	OUT NOCOPY OkcTimeCodeUnitsTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_time_code_units_tl_rec := p_okc_time_code_units_tl_rec;
      -- Get current database values
      l_okc_time_code_units_tl_rec := get_rec(p_okc_time_code_units_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_time_code_units_tl_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.uom_code := l_okc_time_code_units_tl_rec.uom_code;
      END IF;
      IF (x_okc_time_code_units_tl_rec.tce_code = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.tce_code := l_okc_time_code_units_tl_rec.tce_code;
      END IF;
      IF (x_okc_time_code_units_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.language := l_okc_time_code_units_tl_rec.language;
      END IF;
      IF (x_okc_time_code_units_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.source_lang := l_okc_time_code_units_tl_rec.source_lang;
      END IF;
      IF (x_okc_time_code_units_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.sfwt_flag := l_okc_time_code_units_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_time_code_units_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.short_description := l_okc_time_code_units_tl_rec.short_description;
      END IF;
      IF (x_okc_time_code_units_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.description := l_okc_time_code_units_tl_rec.description;
      END IF;
      IF (x_okc_time_code_units_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_time_code_units_tl_rec.comments := l_okc_time_code_units_tl_rec.comments;
      END IF;
      IF (x_okc_time_code_units_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_time_code_units_tl_rec.created_by := l_okc_time_code_units_tl_rec.created_by;
      END IF;
      IF (x_okc_time_code_units_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_time_code_units_tl_rec.creation_date := l_okc_time_code_units_tl_rec.creation_date;
      END IF;
      IF (x_okc_time_code_units_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_time_code_units_tl_rec.last_updated_by := l_okc_time_code_units_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_time_code_units_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_time_code_units_tl_rec.last_update_date := l_okc_time_code_units_tl_rec.last_update_date;
      END IF;
      IF (x_okc_time_code_units_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_time_code_units_tl_rec.last_update_login := l_okc_time_code_units_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_time_code_units_tl_rec IN  OkcTimeCodeUnitsTlRecType,
      x_okc_time_code_units_tl_rec OUT NOCOPY OkcTimeCodeUnitsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_time_code_units_tl_rec := p_okc_time_code_units_tl_rec;
      x_okc_time_code_units_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_time_code_units_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_time_code_units_tl_rec,      -- IN
      l_okc_time_code_units_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_time_code_units_tl_rec, ldefokctimecodeunitstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_TIME_CODE_UNITS_TL
    SET SHORT_DESCRIPTION = ldefokctimecodeunitstlrec.short_description,
        DESCRIPTION = ldefokctimecodeunitstlrec.description,
        COMMENTS = ldefokctimecodeunitstlrec.comments,
        CREATED_BY = ldefokctimecodeunitstlrec.created_by,
        CREATION_DATE = ldefokctimecodeunitstlrec.creation_date,
        LAST_UPDATED_BY = ldefokctimecodeunitstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokctimecodeunitstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokctimecodeunitstlrec.last_update_login
    WHERE uom_code = ldefokctimecodeunitstlrec.uom_code
      AND TCE_CODE = ldefokctimecodeunitstlrec.tce_code
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_TIME_CODE_UNITS_TL
    SET SFWT_FLAG = 'Y'
    WHERE uom_code = ldefokctimecodeunitstlrec.uom_code
      AND TCE_CODE = ldefokctimecodeunitstlrec.tce_code
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_time_code_units_tl_rec := ldefokctimecodeunitstlrec;
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
  ------------------------------------------
  -- update_row for:OKC_TIME_CODE_UNITS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type,
    x_tcuv_rec                     OUT NOCOPY tcuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcuv_rec                     tcuv_rec_type := p_tcuv_rec;
    l_def_tcuv_rec                 tcuv_rec_type;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
    lx_okc_time_code_units_tl_rec  OkcTimeCodeUnitsTlRecType;
    l_tcu_rec                      tcu_rec_type;
    lx_tcu_rec                     tcu_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tcuv_rec	IN tcuv_rec_type
    ) RETURN tcuv_rec_type IS
      l_tcuv_rec	tcuv_rec_type := p_tcuv_rec;
    BEGIN
      l_tcuv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tcuv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tcuv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tcuv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tcuv_rec	IN tcuv_rec_type,
      x_tcuv_rec	OUT NOCOPY tcuv_rec_type
    ) RETURN VARCHAR2 IS
      l_tcuv_rec                     tcuv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcuv_rec := p_tcuv_rec;
      -- Get current database values
      l_tcuv_rec := get_rec(p_tcuv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tcuv_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.uom_code := l_tcuv_rec.uom_code;
      END IF;
      IF (x_tcuv_rec.tce_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.tce_code := l_tcuv_rec.tce_code;
      END IF;
      IF (x_tcuv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tcuv_rec.object_version_number := l_tcuv_rec.object_version_number;
      END IF;
      IF (x_tcuv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.sfwt_flag := l_tcuv_rec.sfwt_flag;
      END IF;
      IF (x_tcuv_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_tcuv_rec.quantity := l_tcuv_rec.quantity;
      END IF;
      IF (x_tcuv_rec.active_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.active_flag := l_tcuv_rec.active_flag;
      END IF;
      IF (x_tcuv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.short_description := l_tcuv_rec.short_description;
      END IF;
      IF (x_tcuv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.description := l_tcuv_rec.description;
      END IF;
      IF (x_tcuv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.comments := l_tcuv_rec.comments;
      END IF;
      IF (x_tcuv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute_category := l_tcuv_rec.attribute_category;
      END IF;
      IF (x_tcuv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute1 := l_tcuv_rec.attribute1;
      END IF;
      IF (x_tcuv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute2 := l_tcuv_rec.attribute2;
      END IF;
      IF (x_tcuv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute3 := l_tcuv_rec.attribute3;
      END IF;
      IF (x_tcuv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute4 := l_tcuv_rec.attribute4;
      END IF;
      IF (x_tcuv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute5 := l_tcuv_rec.attribute5;
      END IF;
      IF (x_tcuv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute6 := l_tcuv_rec.attribute6;
      END IF;
      IF (x_tcuv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute7 := l_tcuv_rec.attribute7;
      END IF;
      IF (x_tcuv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute8 := l_tcuv_rec.attribute8;
      END IF;
      IF (x_tcuv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute9 := l_tcuv_rec.attribute9;
      END IF;
      IF (x_tcuv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute10 := l_tcuv_rec.attribute10;
      END IF;
      IF (x_tcuv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute11 := l_tcuv_rec.attribute11;
      END IF;
      IF (x_tcuv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute12 := l_tcuv_rec.attribute12;
      END IF;
      IF (x_tcuv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute13 := l_tcuv_rec.attribute13;
      END IF;
      IF (x_tcuv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute14 := l_tcuv_rec.attribute14;
      END IF;
      IF (x_tcuv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcuv_rec.attribute15 := l_tcuv_rec.attribute15;
      END IF;
      IF (x_tcuv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcuv_rec.created_by := l_tcuv_rec.created_by;
      END IF;
      IF (x_tcuv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcuv_rec.creation_date := l_tcuv_rec.creation_date;
      END IF;
      IF (x_tcuv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcuv_rec.last_updated_by := l_tcuv_rec.last_updated_by;
      END IF;
      IF (x_tcuv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcuv_rec.last_update_date := l_tcuv_rec.last_update_date;
      END IF;
      IF (x_tcuv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tcuv_rec.last_update_login := l_tcuv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tcuv_rec IN  tcuv_rec_type,
      x_tcuv_rec OUT NOCOPY tcuv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcuv_rec := p_tcuv_rec;
-- **** Added the following two lines for uppercasing *********
      x_tcuv_rec.SFWT_FLAG := upper(p_tcuv_rec.SFWT_FLAG);
      x_tcuv_rec.OBJECT_VERSION_NUMBER := NVL(x_tcuv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_tcuv_rec,                        -- IN
      l_tcuv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tcuv_rec, l_def_tcuv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tcuv_rec := fill_who_columns(l_def_tcuv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tcuv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tcuv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tcuv_rec, l_okc_time_code_units_tl_rec);
    migrate(l_def_tcuv_rec, l_tcu_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_time_code_units_tl_rec,
      lx_okc_time_code_units_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_time_code_units_tl_rec, l_def_tcuv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcu_rec,
      lx_tcu_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcu_rec, l_def_tcuv_rec);
    x_tcuv_rec := l_def_tcuv_rec;
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
  -- PL/SQL TBL update_row for:TCUV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type,
    x_tcuv_tbl                     OUT NOCOPY tcuv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcuv_tbl.COUNT > 0) THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcuv_rec                     => p_tcuv_tbl(i),
          x_tcuv_rec                     => x_tcuv_tbl(i));
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
      END LOOP;
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
  ------------------------------------------
  -- delete_row for:OKC_TIME_CODE_UNITS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcu_rec                      IN tcu_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcu_rec                      tcu_rec_type:= p_tcu_rec;
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
    DELETE FROM OKC_TIME_CODE_UNITS_B
     WHERE uom_code = l_tcu_rec.uom_code AND
TCE_CODE = l_tcu_rec.tce_code;

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
  -------------------------------------------
  -- delete_row for:OKC_TIME_CODE_UNITS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_time_code_units_tl_rec   IN OkcTimeCodeUnitsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType:= p_okc_time_code_units_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKC_TIME_CODE_UNITS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_time_code_units_tl_rec IN  OkcTimeCodeUnitsTlRecType,
      x_okc_time_code_units_tl_rec OUT NOCOPY OkcTimeCodeUnitsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_time_code_units_tl_rec := p_okc_time_code_units_tl_rec;
      x_okc_time_code_units_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_time_code_units_tl_rec,      -- IN
      l_okc_time_code_units_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_TIME_CODE_UNITS_TL
     WHERE uom_code = l_okc_time_code_units_tl_rec.uom_code AND
     TCE_CODE = l_okc_time_code_units_tl_rec.tce_code;

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
  ------------------------------------------
  -- delete_row for:OKC_TIME_CODE_UNITS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_rec                     IN tcuv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcuv_rec                     tcuv_rec_type := p_tcuv_rec;
    l_okc_time_code_units_tl_rec   OkcTimeCodeUnitsTlRecType;
    l_tcu_rec                      tcu_rec_type;
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
    migrate(l_tcuv_rec, l_okc_time_code_units_tl_rec);
    migrate(l_tcuv_rec, l_tcu_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_time_code_units_tl_rec
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
      l_tcu_rec
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
  -- PL/SQL TBL delete_row for:TCUV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcuv_tbl                     IN tcuv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcuv_tbl.COUNT > 0) THEN
      i := p_tcuv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcuv_rec                     => p_tcuv_tbl(i));
        EXIT WHEN (i = p_tcuv_tbl.LAST);
        i := p_tcuv_tbl.NEXT(i);
      END LOOP;
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

END OKC_TCU_PVT;

/
