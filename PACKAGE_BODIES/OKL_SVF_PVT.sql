--------------------------------------------------------
--  DDL for Package Body OKL_SVF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SVF_PVT" AS
/* $Header: OKLSSVFB.pls 120.5 2007/08/08 12:52:58 arajagop noship $ */
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

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_SERVICE_FEES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_SERVICE_FEES_ALL_B B --changed _TL to _B by rvaduri for MLS compliance.
         WHERE B.ID = T.ID
        );

    UPDATE OKL_SERVICE_FEES_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_SERVICE_FEES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_SERVICE_FEES_TL SUBB, OKL_SERVICE_FEES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_SERVICE_FEES_TL (
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
        LAST_UPDATE_LOGIN)
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
            B.LAST_UPDATE_LOGIN
        FROM OKL_SERVICE_FEES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_SERVICE_FEES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SERVICE_FEES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_svf_rec                      IN svf_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN svf_rec_type IS
    CURSOR okl_service_fees_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            SRV_CODE,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
            START_DATE,
            END_DATE,
            ORGANIZATION_ID,
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
            ORG_ID
      FROM Okl_Service_Fees_B
     WHERE okl_service_fees_b.id = p_id;
    l_okl_service_fees_b_pk        okl_service_fees_b_pk_csr%ROWTYPE;
    l_svf_rec                      svf_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_service_fees_b_pk_csr (p_svf_rec.id);
    FETCH okl_service_fees_b_pk_csr INTO
              l_svf_rec.ID,
              l_svf_rec.SRV_CODE,
              l_svf_rec.OBJECT_VERSION_NUMBER,
              l_svf_rec.AMOUNT,
              l_svf_rec.START_DATE,
              l_svf_rec.END_DATE,
              l_svf_rec.ORGANIZATION_ID,
              l_svf_rec.ATTRIBUTE_CATEGORY,
              l_svf_rec.ATTRIBUTE1,
              l_svf_rec.ATTRIBUTE2,
              l_svf_rec.ATTRIBUTE3,
              l_svf_rec.ATTRIBUTE4,
              l_svf_rec.ATTRIBUTE5,
              l_svf_rec.ATTRIBUTE6,
              l_svf_rec.ATTRIBUTE7,
              l_svf_rec.ATTRIBUTE8,
              l_svf_rec.ATTRIBUTE9,
              l_svf_rec.ATTRIBUTE10,
              l_svf_rec.ATTRIBUTE11,
              l_svf_rec.ATTRIBUTE12,
              l_svf_rec.ATTRIBUTE13,
              l_svf_rec.ATTRIBUTE14,
              l_svf_rec.ATTRIBUTE15,
              l_svf_rec.CREATED_BY,
              l_svf_rec.CREATION_DATE,
              l_svf_rec.LAST_UPDATED_BY,
              l_svf_rec.LAST_UPDATE_DATE,
              l_svf_rec.LAST_UPDATE_LOGIN,
              l_svf_rec.ORG_ID;
    x_no_data_found := okl_service_fees_b_pk_csr%NOTFOUND;
    CLOSE okl_service_fees_b_pk_csr;
    RETURN(l_svf_rec);
  END get_rec;

  FUNCTION get_rec (
    p_svf_rec                      IN svf_rec_type
  ) RETURN svf_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_svf_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SERVICE_FEES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_service_fees_tl_rec_type IS
    CURSOR okl_service_fees_tl_pk_csr (p_id                 IN NUMBER,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Service_Fees_Tl
     WHERE okl_service_fees_tl.id = p_id
       AND okl_service_fees_tl.LANGUAGE = p_language;
    l_okl_service_fees_tl_pk       okl_service_fees_tl_pk_csr%ROWTYPE;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_service_fees_tl_pk_csr (p_okl_service_fees_tl_rec.id,
                                     p_okl_service_fees_tl_rec.LANGUAGE);
    FETCH okl_service_fees_tl_pk_csr INTO
              l_okl_service_fees_tl_rec.ID,
              l_okl_service_fees_tl_rec.LANGUAGE,
              l_okl_service_fees_tl_rec.SOURCE_LANG,
              l_okl_service_fees_tl_rec.SFWT_FLAG,
              l_okl_service_fees_tl_rec.NAME,
              l_okl_service_fees_tl_rec.DESCRIPTION,
              l_okl_service_fees_tl_rec.CREATED_BY,
              l_okl_service_fees_tl_rec.CREATION_DATE,
              l_okl_service_fees_tl_rec.LAST_UPDATED_BY,
              l_okl_service_fees_tl_rec.LAST_UPDATE_DATE,
              l_okl_service_fees_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_service_fees_tl_pk_csr%NOTFOUND;
    CLOSE okl_service_fees_tl_pk_csr;
    RETURN(l_okl_service_fees_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type
  ) RETURN okl_service_fees_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_service_fees_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SERVICE_FEES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_svfv_rec                     IN svfv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN svfv_rec_type IS
    CURSOR okl_svfv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            SRV_CODE,
            NAME,
            DESCRIPTION,
            AMOUNT,
            START_DATE,
            END_DATE,
            ORGANIZATION_ID,
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
      FROM Okl_Service_Fees_V
     WHERE okl_service_fees_v.id = p_id;
    l_okl_svfv_pk                  okl_svfv_pk_csr%ROWTYPE;
    l_svfv_rec                     svfv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_svfv_pk_csr (p_svfv_rec.id);
    FETCH okl_svfv_pk_csr INTO
              l_svfv_rec.ID,
              l_svfv_rec.OBJECT_VERSION_NUMBER,
              l_svfv_rec.SFWT_FLAG,
              l_svfv_rec.SRV_CODE,
              l_svfv_rec.NAME,
              l_svfv_rec.DESCRIPTION,
              l_svfv_rec.AMOUNT,
              l_svfv_rec.START_DATE,
              l_svfv_rec.END_DATE,
	      l_svfv_rec.ORGANIZATION_ID,
              l_svfv_rec.ATTRIBUTE_CATEGORY,
              l_svfv_rec.ATTRIBUTE1,
              l_svfv_rec.ATTRIBUTE2,
              l_svfv_rec.ATTRIBUTE3,
              l_svfv_rec.ATTRIBUTE4,
              l_svfv_rec.ATTRIBUTE5,
              l_svfv_rec.ATTRIBUTE6,
              l_svfv_rec.ATTRIBUTE7,
              l_svfv_rec.ATTRIBUTE8,
              l_svfv_rec.ATTRIBUTE9,
              l_svfv_rec.ATTRIBUTE10,
              l_svfv_rec.ATTRIBUTE11,
              l_svfv_rec.ATTRIBUTE12,
              l_svfv_rec.ATTRIBUTE13,
              l_svfv_rec.ATTRIBUTE14,
              l_svfv_rec.ATTRIBUTE15,
              l_svfv_rec.CREATED_BY,
              l_svfv_rec.CREATION_DATE,
              l_svfv_rec.LAST_UPDATED_BY,
              l_svfv_rec.LAST_UPDATE_DATE,
              l_svfv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_svfv_pk_csr%NOTFOUND;
    CLOSE okl_svfv_pk_csr;
    RETURN(l_svfv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_svfv_rec                     IN svfv_rec_type
  ) RETURN svfv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_svfv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SERVICE_FEES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_svfv_rec	IN svfv_rec_type
  ) RETURN svfv_rec_type IS
    l_svfv_rec	svfv_rec_type := p_svfv_rec;
  BEGIN
    IF (l_svfv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.object_version_number := NULL;
    END IF;
    IF (l_svfv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_svfv_rec.srv_code = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.srv_code := NULL;
    END IF;
    IF (l_svfv_rec.name = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.name := NULL;
    END IF;
    IF (l_svfv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.description := NULL;
    END IF;
    IF (l_svfv_rec.amount = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.amount := NULL;
    END IF;
    IF (l_svfv_rec.start_date = OKL_API.G_MISS_DATE) THEN
      l_svfv_rec.start_date := NULL;
    END IF;
    IF (l_svfv_rec.end_date = OKL_API.G_MISS_DATE) THEN
      l_svfv_rec.end_date := NULL;
    END IF;
    IF (l_svfv_rec.organization_id = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.organization_id := NULL;
    END IF;
    IF (l_svfv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute_category := NULL;
    END IF;
    IF (l_svfv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute1 := NULL;
    END IF;
    IF (l_svfv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute2 := NULL;
    END IF;
    IF (l_svfv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute3 := NULL;
    END IF;
    IF (l_svfv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute4 := NULL;
    END IF;
    IF (l_svfv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute5 := NULL;
    END IF;
    IF (l_svfv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute6 := NULL;
    END IF;
    IF (l_svfv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute7 := NULL;
    END IF;
    IF (l_svfv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute8 := NULL;
    END IF;
    IF (l_svfv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute9 := NULL;
    END IF;
    IF (l_svfv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute10 := NULL;
    END IF;
    IF (l_svfv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute11 := NULL;
    END IF;
    IF (l_svfv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute12 := NULL;
    END IF;
    IF (l_svfv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute13 := NULL;
    END IF;
    IF (l_svfv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute14 := NULL;
    END IF;
    IF (l_svfv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_svfv_rec.attribute15 := NULL;
    END IF;
    IF (l_svfv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.created_by := NULL;
    END IF;
    IF (l_svfv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_svfv_rec.creation_date := NULL;
    END IF;
    IF (l_svfv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.last_updated_by := NULL;
    END IF;
    IF (l_svfv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_svfv_rec.last_update_date := NULL;
    END IF;
    IF (l_svfv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_svfv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_svfv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_svfv_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_svfv_id(
    p_svfv_rec          IN svfv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_svfv_rec.id = OKL_API.G_MISS_NUM OR
       p_svfv_rec.id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_svfv_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_svfv_rec          IN svfv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_svfv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_svfv_rec.object_version_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;


  --------------------------------------------------------------------------
  -- PROCEDURE Validate_srv_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_srv_code(p_svfv_rec IN svfv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_svfv_rec.srv_code = OKL_API.G_MISS_CHAR OR p_svfv_rec.srv_code IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'srv_code');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    x_return_status := OKL_UTIL.check_lookup_code('OKL_SERVICE_FEES', p_svfv_rec.srv_code);

    IF NOT (x_return_status = OKL_API.G_RET_STS_SUCCESS ) THEN
           OKL_API.set_message(p_app_name 	        => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'SRV_CODE',
                               p_token2             => g_child_table_token,
                               p_token2_value       => 'OKL_SERVICE_FEES_B',
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'FND_LOOKUPS');

    x_return_status := OKL_API.G_RET_STS_ERROR;
    RETURN;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_srv_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_amount
  ---------------------------------------------------------------------------
  PROCEDURE validate_amount(
    p_svfv_rec          IN svfv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF p_svfv_rec.amount = OKL_API.G_MISS_NUM OR p_svfv_rec.amount IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_OKL_AMOUNT_GREATER_THAN_ZERO);
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    IF p_svfv_rec.amount < 0
    THEN
      OKL_API.set_message(G_APP_NAME, G_OKL_AMOUNT_GREATER_THAN_ZERO);
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_amount;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_sfwt_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_sfwt_flag(
    p_svfv_rec          IN svfv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_svfv_rec.sfwt_flag = OKL_API.G_MISS_CHAR OR p_svfv_rec.sfwt_flag IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SFWT_FLAG');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(
    p_svfv_rec          IN svfv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_svfv_rec.start_date = OKL_API.G_MISS_DATE OR p_svfv_rec.start_date IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'EFFECTIVE_FROM');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;




  ------------------------------------------------
  -- Validate_Attributes for:OKL_SERVICE_FEES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_svfv_rec IN  svfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_svfv_id(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_srv_code(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_amount(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sfwt_flag(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_start_date(p_svfv_rec, l_return_status);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;


  RETURN(x_return_status);

   EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_SERVICE_FEES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_svfv_rec IN svfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

     CURSOR c_relevant_records IS
            SELECT id, srv_code, organization_id, end_date, start_date
            FROM   okl_service_fees_b
            WHERE  id = p_svfv_rec.id
            OR     organization_id = p_svfv_rec.organization_id AND id <> p_svfv_rec.id;

  BEGIN

    IF p_svfv_rec.end_date < p_svfv_rec.start_date THEN
        OKL_API.set_message(G_APP_NAME, G_OKL_INVALID_END_DATE);
        l_return_status := OKL_API.G_RET_STS_ERROR;
	RETURN l_return_status;
    END IF;

    FOR v_rec IN c_relevant_records LOOP

    IF v_rec.id <> p_svfv_rec.id AND
       v_rec.organization_id = p_svfv_rec.organization_id AND
       v_rec.srv_code = p_svfv_rec.srv_code AND
       TRUNC(v_rec.start_date)<= TRUNC(p_svfv_rec.start_date) AND
      (TRUNC(v_rec.end_date) >= TRUNC(p_svfv_rec.start_date) OR v_rec.end_date IS NULL) THEN

         OKL_API.set_message(G_APP_NAME, G_OKL_DUPLICATE_SERVICE_FEE);
         l_return_status := OKL_API.G_RET_STS_ERROR;
  	     RETURN l_return_status;
    END IF;

    IF v_rec.id <> p_svfv_rec.id AND
       v_rec.organization_id = p_svfv_rec.organization_id AND
       v_rec.srv_code = p_svfv_rec.srv_code AND
       TRUNC(v_rec.start_date)>= TRUNC(p_svfv_rec.start_date) AND
      (TRUNC(p_svfv_rec.end_date) >= TRUNC(v_rec.start_date) OR p_svfv_rec.end_date IS NULL) THEN

         OKL_API.set_message(G_APP_NAME, G_OKL_DUPLICATE_SERVICE_FEE);
         l_return_status := OKL_API.G_RET_STS_ERROR;
  	     RETURN l_return_status;
    END IF;

    END LOOP;

    RETURN (l_return_status);


 EXCEPTION

   WHEN OTHERS THEN

        OKL_API.set_message(p_app_name    => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        RETURN(l_return_status);

  ----------------------------------------------------------------------------
  -- End Post Tapi Generation validation Code
  ----------------------------------------------------------------------------

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN svfv_rec_type,
    p_to	IN OUT NOCOPY svf_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.srv_code := p_from.srv_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.organization_id := p_from.organization_id;
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
  PROCEDURE migrate (
    p_from	IN svf_rec_type,
    p_to	OUT NOCOPY svfv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.srv_code := p_from.srv_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.organization_id := p_from.organization_id;
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
  PROCEDURE migrate (
    p_from	IN svfv_rec_type,
    p_to	OUT NOCOPY okl_service_fees_tl_rec_type
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_service_fees_tl_rec_type,
    p_to	OUT NOCOPY svfv_rec_type
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_SERVICE_FEES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svfv_rec                     svfv_rec_type := p_svfv_rec;
    l_svf_rec                      svf_rec_type;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_svfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_svfv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:SVFV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_svfv_tbl.COUNT > 0) THEN
      i := p_svfv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_svfv_rec                     => p_svfv_tbl(i));
        EXIT WHEN (i = p_svfv_tbl.LAST);
        i := p_svfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- insert_row for:OKL_SERVICE_FEES_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svf_rec                      IN svf_rec_type,
    x_svf_rec                      OUT NOCOPY svf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svf_rec                      svf_rec_type := p_svf_rec;
    l_def_svf_rec                  svf_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_svf_rec IN  svf_rec_type,
      x_svf_rec OUT NOCOPY svf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_svf_rec := p_svf_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_svf_rec,                         -- IN
      l_svf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SERVICE_FEES_B(
        id,
        srv_code,
        object_version_number,
        amount,
        start_date,
        end_date,
        organization_id,
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
        org_id)
      VALUES (
        l_svf_rec.id,
        l_svf_rec.srv_code,
        l_svf_rec.object_version_number,
        l_svf_rec.amount,
        l_svf_rec.start_date,
        l_svf_rec.end_date,
        l_svf_rec.organization_id,
        l_svf_rec.attribute_category,
        l_svf_rec.attribute1,
        l_svf_rec.attribute2,
        l_svf_rec.attribute3,
        l_svf_rec.attribute4,
        l_svf_rec.attribute5,
        l_svf_rec.attribute6,
        l_svf_rec.attribute7,
        l_svf_rec.attribute8,
        l_svf_rec.attribute9,
        l_svf_rec.attribute10,
        l_svf_rec.attribute11,
        l_svf_rec.attribute12,
        l_svf_rec.attribute13,
        l_svf_rec.attribute14,
        l_svf_rec.attribute15,
        l_svf_rec.created_by,
        l_svf_rec.creation_date,
        l_svf_rec.last_updated_by,
        l_svf_rec.last_update_date,
        l_svf_rec.last_update_login,
        l_svf_rec.organization_id);
    -- Set OUT values
    x_svf_rec := l_svf_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_SERVICE_FEES_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type,
    x_okl_service_fees_tl_rec      OUT NOCOPY okl_service_fees_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type := p_okl_service_fees_tl_rec;
    ldefoklservicefeestlrec        okl_service_fees_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_service_fees_tl_rec IN  okl_service_fees_tl_rec_type,
      x_okl_service_fees_tl_rec OUT NOCOPY okl_service_fees_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_service_fees_tl_rec := p_okl_service_fees_tl_rec;
      x_okl_service_fees_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_service_fees_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_service_fees_tl_rec,         -- IN
      l_okl_service_fees_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_service_fees_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_SERVICE_FEES_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          name,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_service_fees_tl_rec.id,
          l_okl_service_fees_tl_rec.LANGUAGE,
          l_okl_service_fees_tl_rec.source_lang,
          l_okl_service_fees_tl_rec.sfwt_flag,
          l_okl_service_fees_tl_rec.name,
          l_okl_service_fees_tl_rec.description,
          l_okl_service_fees_tl_rec.created_by,
          l_okl_service_fees_tl_rec.creation_date,
          l_okl_service_fees_tl_rec.last_updated_by,
          l_okl_service_fees_tl_rec.last_update_date,
          l_okl_service_fees_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_service_fees_tl_rec := l_okl_service_fees_tl_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------
  -- insert_row for:OKL_SERVICE_FEES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type,
    x_svfv_rec                     OUT NOCOPY svfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svfv_rec                     svfv_rec_type;
    l_def_svfv_rec                 svfv_rec_type;
    l_svf_rec                      svf_rec_type;
    lx_svf_rec                     svf_rec_type;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
    lx_okl_service_fees_tl_rec     okl_service_fees_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_svfv_rec	IN svfv_rec_type
    ) RETURN svfv_rec_type IS
      l_svfv_rec	svfv_rec_type := p_svfv_rec;
    BEGIN
      l_svfv_rec.CREATION_DATE := SYSDATE;
      l_svfv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_svfv_rec.LAST_UPDATE_DATE := l_svfv_rec.CREATION_DATE;
      l_svfv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_svfv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_svfv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_svfv_rec IN  svfv_rec_type,
      x_svfv_rec OUT NOCOPY svfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_org_id                       hr_operating_units.organization_id%TYPE;

    BEGIN

      --fnd_profile.get('ORG_ID', l_org_id);

      l_org_id:= mo_global.get_current_org_id();

      x_svfv_rec := p_svfv_rec;
      x_svfv_rec.OBJECT_VERSION_NUMBER := 1;
      x_svfv_rec.SFWT_FLAG := 'N';
      x_svfv_rec.organization_id := l_org_id;
      RETURN(l_return_status);
    END Set_Attributes;
    ------------------------------------------------------------------------
    -- New function to validate start date when inserting                 --
    -- Start date must be > todays date when inserting                    --
    ------------------------------------------------------------------------



    FUNCTION Validate_Create_Start_Date (
      p_svfv_rec IN  svfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      IF TRUNC(p_svfv_rec.start_date) < TRUNC(SYSDATE)
      THEN
         OKL_API.set_message(G_APP_NAME, G_OKL_START_DATE);
         l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;

      RETURN(l_return_status);

    END Validate_Create_Start_Date;


  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_svfv_rec := null_out_defaults(p_svfv_rec);
    -- Set primary key value
    l_svfv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_svfv_rec,                        -- IN
      l_def_svfv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_svfv_rec := fill_who_columns(l_def_svfv_rec);

    --------------------------------------------------------
    -- Added Validation to Check start_date > todays date
    -- during an insert_row
    --------------------------------------------------------

    l_return_status := Validate_Create_Start_Date(l_def_svfv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_svfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_svfv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_svfv_rec, l_svf_rec);
    migrate(l_def_svfv_rec, l_okl_service_fees_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_svf_rec,
      lx_svf_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_svf_rec, l_def_svfv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_service_fees_tl_rec,
      lx_okl_service_fees_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_service_fees_tl_rec, l_def_svfv_rec);
    -- Set OUT values
    x_svfv_rec := l_def_svfv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:SVFV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type,
    x_svfv_tbl                     OUT NOCOPY svfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_svfv_tbl.COUNT > 0) THEN
      i := p_svfv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_svfv_rec                     => p_svfv_tbl(i),
          x_svfv_rec                     => x_svfv_tbl(i));
        EXIT WHEN (i = p_svfv_tbl.LAST);
        i := p_svfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- lock_row for:OKL_SERVICE_FEES_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svf_rec                      IN svf_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_svf_rec IN svf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SERVICE_FEES_B
     WHERE ID = p_svf_rec.id
       AND OBJECT_VERSION_NUMBER = p_svf_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_svf_rec IN svf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SERVICE_FEES_B
    WHERE ID = p_svf_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SERVICE_FEES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SERVICE_FEES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_svf_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_svf_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_svf_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_svf_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_SERVICE_FEES_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_service_fees_tl_rec IN okl_service_fees_tl_rec_type) IS
    SELECT *
      FROM OKL_SERVICE_FEES_TL
     WHERE ID = p_okl_service_fees_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_service_fees_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------
  -- lock_row for:OKL_SERVICE_FEES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svf_rec                      svf_rec_type;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_svfv_rec, l_svf_rec);
    migrate(p_svfv_rec, l_okl_service_fees_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_svf_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_service_fees_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SVFV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_svfv_tbl.COUNT > 0) THEN
      i := p_svfv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_svfv_rec                     => p_svfv_tbl(i));
        EXIT WHEN (i = p_svfv_tbl.LAST);
        i := p_svfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- update_row for:OKL_SERVICE_FEES_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svf_rec                      IN svf_rec_type,
    x_svf_rec                      OUT NOCOPY svf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svf_rec                      svf_rec_type := p_svf_rec;
    l_def_svf_rec                  svf_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_svf_rec	IN svf_rec_type,
      x_svf_rec	OUT NOCOPY svf_rec_type
    ) RETURN VARCHAR2 IS
      l_svf_rec                      svf_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_svf_rec := p_svf_rec;
      -- Get current database values
      l_svf_rec := get_rec(p_svf_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_svf_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.id := l_svf_rec.id;
      END IF;
      IF (x_svf_rec.srv_code = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.srv_code := l_svf_rec.srv_code;
      END IF;
      IF (x_svf_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.object_version_number := l_svf_rec.object_version_number;
      END IF;
      IF (x_svf_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.amount := l_svf_rec.amount;
      END IF;
      IF (x_svf_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_svf_rec.start_date := l_svf_rec.start_date;
      END IF;
      IF (x_svf_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_svf_rec.end_date := l_svf_rec.end_date;
      END IF;
      IF (x_svf_rec.organization_id = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.organization_id := l_svf_rec.organization_id;
      END IF;
      IF (x_svf_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute_category := l_svf_rec.attribute_category;
      END IF;
      IF (x_svf_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute1 := l_svf_rec.attribute1;
      END IF;
      IF (x_svf_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute2 := l_svf_rec.attribute2;
      END IF;
      IF (x_svf_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute3 := l_svf_rec.attribute3;
      END IF;
      IF (x_svf_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute4 := l_svf_rec.attribute4;
      END IF;
      IF (x_svf_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute5 := l_svf_rec.attribute5;
      END IF;
      IF (x_svf_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute6 := l_svf_rec.attribute6;
      END IF;
      IF (x_svf_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute7 := l_svf_rec.attribute7;
      END IF;
      IF (x_svf_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute8 := l_svf_rec.attribute8;
      END IF;
      IF (x_svf_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute9 := l_svf_rec.attribute9;
      END IF;
      IF (x_svf_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute10 := l_svf_rec.attribute10;
      END IF;
      IF (x_svf_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute11 := l_svf_rec.attribute11;
      END IF;
      IF (x_svf_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute12 := l_svf_rec.attribute12;
      END IF;
      IF (x_svf_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute13 := l_svf_rec.attribute13;
      END IF;
      IF (x_svf_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute14 := l_svf_rec.attribute14;
      END IF;
      IF (x_svf_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_svf_rec.attribute15 := l_svf_rec.attribute15;
      END IF;
      IF (x_svf_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.created_by := l_svf_rec.created_by;
      END IF;
      IF (x_svf_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_svf_rec.creation_date := l_svf_rec.creation_date;
      END IF;
      IF (x_svf_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.last_updated_by := l_svf_rec.last_updated_by;
      END IF;
      IF (x_svf_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_svf_rec.last_update_date := l_svf_rec.last_update_date;
      END IF;
      IF (x_svf_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.last_update_login := l_svf_rec.last_update_login;
      END IF;
      IF (x_svf_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_svf_rec.org_id := l_svf_rec.organization_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_svf_rec IN  svf_rec_type,
      x_svf_rec OUT NOCOPY svf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_svf_rec := p_svf_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_svf_rec,                         -- IN
      l_svf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_svf_rec, l_def_svf_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SERVICE_FEES_B
    SET SRV_CODE = l_def_svf_rec.srv_code,
        OBJECT_VERSION_NUMBER = l_def_svf_rec.object_version_number,
        AMOUNT = l_def_svf_rec.amount,
        START_DATE = l_def_svf_rec.start_date,
        END_DATE = l_def_svf_rec.end_date,
        ORGANIZATION_ID = l_def_svf_rec.organization_id,
        ATTRIBUTE_CATEGORY = l_def_svf_rec.attribute_category,
        ATTRIBUTE1 = l_def_svf_rec.attribute1,
        ATTRIBUTE2 = l_def_svf_rec.attribute2,
        ATTRIBUTE3 = l_def_svf_rec.attribute3,
        ATTRIBUTE4 = l_def_svf_rec.attribute4,
        ATTRIBUTE5 = l_def_svf_rec.attribute5,
        ATTRIBUTE6 = l_def_svf_rec.attribute6,
        ATTRIBUTE7 = l_def_svf_rec.attribute7,
        ATTRIBUTE8 = l_def_svf_rec.attribute8,
        ATTRIBUTE9 = l_def_svf_rec.attribute9,
        ATTRIBUTE10 = l_def_svf_rec.attribute10,
        ATTRIBUTE11 = l_def_svf_rec.attribute11,
        ATTRIBUTE12 = l_def_svf_rec.attribute12,
        ATTRIBUTE13 = l_def_svf_rec.attribute13,
        ATTRIBUTE14 = l_def_svf_rec.attribute14,
        ATTRIBUTE15 = l_def_svf_rec.attribute15,
        CREATED_BY = l_def_svf_rec.created_by,
        CREATION_DATE = l_def_svf_rec.creation_date,
        LAST_UPDATED_BY = l_def_svf_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_svf_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_svf_rec.last_update_login,
        ORG_ID=l_def_svf_rec.organization_id

    WHERE ID = l_def_svf_rec.id;

    x_svf_rec := l_def_svf_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_SERVICE_FEES_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type,
    x_okl_service_fees_tl_rec      OUT NOCOPY okl_service_fees_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type := p_okl_service_fees_tl_rec;
    ldefoklservicefeestlrec        okl_service_fees_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_service_fees_tl_rec	IN okl_service_fees_tl_rec_type,
      x_okl_service_fees_tl_rec	OUT NOCOPY okl_service_fees_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_service_fees_tl_rec := p_okl_service_fees_tl_rec;
      -- Get current database values
      l_okl_service_fees_tl_rec := get_rec(p_okl_service_fees_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_service_fees_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_service_fees_tl_rec.id := l_okl_service_fees_tl_rec.id;
      END IF;
      IF (x_okl_service_fees_tl_rec.LANGUAGE = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_service_fees_tl_rec.LANGUAGE := l_okl_service_fees_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_service_fees_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_service_fees_tl_rec.source_lang := l_okl_service_fees_tl_rec.source_lang;
      END IF;
      IF (x_okl_service_fees_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_service_fees_tl_rec.sfwt_flag := l_okl_service_fees_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_service_fees_tl_rec.name = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_service_fees_tl_rec.name := l_okl_service_fees_tl_rec.name;
      END IF;
      IF (x_okl_service_fees_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_service_fees_tl_rec.description := l_okl_service_fees_tl_rec.description;
      END IF;
      IF (x_okl_service_fees_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_service_fees_tl_rec.created_by := l_okl_service_fees_tl_rec.created_by;
      END IF;
      IF (x_okl_service_fees_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_service_fees_tl_rec.creation_date := l_okl_service_fees_tl_rec.creation_date;
      END IF;
      IF (x_okl_service_fees_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_service_fees_tl_rec.last_updated_by := l_okl_service_fees_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_service_fees_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_service_fees_tl_rec.last_update_date := l_okl_service_fees_tl_rec.last_update_date;
      END IF;
      IF (x_okl_service_fees_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_service_fees_tl_rec.last_update_login := l_okl_service_fees_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_service_fees_tl_rec IN  okl_service_fees_tl_rec_type,
      x_okl_service_fees_tl_rec OUT NOCOPY okl_service_fees_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_service_fees_tl_rec := p_okl_service_fees_tl_rec;
      x_okl_service_fees_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_service_fees_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_service_fees_tl_rec,         -- IN
      l_okl_service_fees_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_service_fees_tl_rec, ldefoklservicefeestlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SERVICE_FEES_TL
    SET NAME = ldefoklservicefeestlrec.name,
        DESCRIPTION = ldefoklservicefeestlrec.description,
        SOURCE_LANG = ldefoklservicefeestlrec.source_lang,--Fix for 3637102
        CREATED_BY = ldefoklservicefeestlrec.created_by,
        CREATION_DATE = ldefoklservicefeestlrec.creation_date,
        LAST_UPDATED_BY = ldefoklservicefeestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklservicefeestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklservicefeestlrec.last_update_login
    WHERE ID = ldefoklservicefeestlrec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_SERVICE_FEES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklservicefeestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_service_fees_tl_rec := ldefoklservicefeestlrec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ---------------------------------------
  -- update_row for:OKL_SERVICE_FEES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type,
    x_svfv_rec                     OUT NOCOPY svfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svfv_rec                     svfv_rec_type := p_svfv_rec;
    l_def_svfv_rec                 svfv_rec_type;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
    lx_okl_service_fees_tl_rec     okl_service_fees_tl_rec_type;
    l_svf_rec                      svf_rec_type;
    lx_svf_rec                     svf_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_svfv_rec	IN svfv_rec_type
    ) RETURN svfv_rec_type IS
      l_svfv_rec	svfv_rec_type := p_svfv_rec;
    BEGIN
      l_svfv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_svfv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_svfv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_svfv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_svfv_rec	IN svfv_rec_type,
      x_svfv_rec	OUT NOCOPY svfv_rec_type
    ) RETURN VARCHAR2 IS
      l_svfv_rec                     svfv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_svfv_rec := p_svfv_rec;
      -- Get current database values
      l_svfv_rec := get_rec(p_svfv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_svfv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.id := l_svfv_rec.id;
      END IF;
      IF (x_svfv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.object_version_number := l_svfv_rec.object_version_number;
      END IF;
      IF (x_svfv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.sfwt_flag := l_svfv_rec.sfwt_flag;
      END IF;
      IF (x_svfv_rec.srv_code = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.srv_code := l_svfv_rec.srv_code;
      END IF;
      IF (x_svfv_rec.name = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.name := l_svfv_rec.name;
      END IF;
      IF (x_svfv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.description := l_svfv_rec.description;
      END IF;
      IF (x_svfv_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.amount := l_svfv_rec.amount;
      END IF;
      IF (x_svfv_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_svfv_rec.start_date := l_svfv_rec.start_date;
      END IF;
      IF (x_svfv_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_svfv_rec.end_date := l_svfv_rec.end_date;
      END IF;
      IF (x_svfv_rec.organization_id = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.organization_id := l_svfv_rec.organization_id;
      END IF;
      IF (x_svfv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute_category := l_svfv_rec.attribute_category;
      END IF;
      IF (x_svfv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute1 := l_svfv_rec.attribute1;
      END IF;
      IF (x_svfv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute2 := l_svfv_rec.attribute2;
      END IF;
      IF (x_svfv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute3 := l_svfv_rec.attribute3;
      END IF;
      IF (x_svfv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute4 := l_svfv_rec.attribute4;
      END IF;
      IF (x_svfv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute5 := l_svfv_rec.attribute5;
      END IF;
      IF (x_svfv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute6 := l_svfv_rec.attribute6;
      END IF;
      IF (x_svfv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute7 := l_svfv_rec.attribute7;
      END IF;
      IF (x_svfv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute8 := l_svfv_rec.attribute8;
      END IF;
      IF (x_svfv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute9 := l_svfv_rec.attribute9;
      END IF;
      IF (x_svfv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute10 := l_svfv_rec.attribute10;
      END IF;
      IF (x_svfv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute11 := l_svfv_rec.attribute11;
      END IF;
      IF (x_svfv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute12 := l_svfv_rec.attribute12;
      END IF;
      IF (x_svfv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute13 := l_svfv_rec.attribute13;
      END IF;
      IF (x_svfv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute14 := l_svfv_rec.attribute14;
      END IF;
      IF (x_svfv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_svfv_rec.attribute15 := l_svfv_rec.attribute15;
      END IF;
      IF (x_svfv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.created_by := l_svfv_rec.created_by;
      END IF;
      IF (x_svfv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_svfv_rec.creation_date := l_svfv_rec.creation_date;
      END IF;
      IF (x_svfv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.last_updated_by := l_svfv_rec.last_updated_by;
      END IF;
      IF (x_svfv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_svfv_rec.last_update_date := l_svfv_rec.last_update_date;
      END IF;
      IF (x_svfv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_svfv_rec.last_update_login := l_svfv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_svfv_rec IN  svfv_rec_type,
      x_svfv_rec OUT NOCOPY svfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_svfv_rec := p_svfv_rec;
      x_svfv_rec.OBJECT_VERSION_NUMBER := NVL(x_svfv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      x_svfv_rec.SFWT_FLAG := 'N';

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_svfv_rec,                        -- IN
      l_svfv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_svfv_rec, l_def_svfv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_svfv_rec := fill_who_columns(l_def_svfv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_svfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_svfv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_svfv_rec, l_okl_service_fees_tl_rec);
    migrate(l_def_svfv_rec, l_svf_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_service_fees_tl_rec,
      lx_okl_service_fees_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_service_fees_tl_rec, l_def_svfv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_svf_rec,
      lx_svf_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_svf_rec, l_def_svfv_rec);
    x_svfv_rec := l_def_svfv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:SVFV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type,
    x_svfv_tbl                     OUT NOCOPY svfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_svfv_tbl.COUNT > 0) THEN
      i := p_svfv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_svfv_rec                     => p_svfv_tbl(i),
          x_svfv_rec                     => x_svfv_tbl(i));
        EXIT WHEN (i = p_svfv_tbl.LAST);
        i := p_svfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- delete_row for:OKL_SERVICE_FEES_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svf_rec                      IN svf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svf_rec                      svf_rec_type:= p_svf_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_SERVICE_FEES_B
     WHERE ID = l_svf_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_SERVICE_FEES_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_service_fees_tl_rec      IN okl_service_fees_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type:= p_okl_service_fees_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKL_SERVICE_FEES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_service_fees_tl_rec IN  okl_service_fees_tl_rec_type,
      x_okl_service_fees_tl_rec OUT NOCOPY okl_service_fees_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_service_fees_tl_rec := p_okl_service_fees_tl_rec;
      x_okl_service_fees_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_service_fees_tl_rec,         -- IN
      l_okl_service_fees_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_SERVICE_FEES_TL
     WHERE ID = l_okl_service_fees_tl_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------
  -- delete_row for:OKL_SERVICE_FEES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_rec                     IN svfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_svfv_rec                     svfv_rec_type := p_svfv_rec;
    l_okl_service_fees_tl_rec      okl_service_fees_tl_rec_type;
    l_svf_rec                      svf_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_svfv_rec, l_okl_service_fees_tl_rec);
    migrate(l_svfv_rec, l_svf_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_service_fees_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_svf_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:SVFV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_svfv_tbl                     IN svfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_svfv_tbl.COUNT > 0) THEN
      i := p_svfv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_svfv_rec                     => p_svfv_tbl(i));
        EXIT WHEN (i = p_svfv_tbl.LAST);
        i := p_svfv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Svf_Pvt;

/
