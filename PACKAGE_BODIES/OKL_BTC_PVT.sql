--------------------------------------------------------
--  DDL for Package Body OKL_BTC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTC_PVT" AS
/* $Header: OKLSBTCB.pls 120.7 2008/04/30 20:42:39 racheruv ship $ */
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
    DELETE FROM OKL_TRX_CSH_BATCH_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_CSH_BATCH_ALL_B B         --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TRX_CSH_BATCH_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_TRX_CSH_BATCH_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_CSH_BATCH_TL SUBB, OKL_TRX_CSH_BATCH_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TRX_CSH_BATCH_TL (
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
        FROM OKL_TRX_CSH_BATCH_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_CSH_BATCH_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_BATCH_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_btc_rec                      IN btc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN btc_rec_type IS
    CURSOR btc_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            DATE_ENTERED,
            DATE_GL_REQUESTED,
            DATE_DEPOSIT,
            BATCH_QTY,
            BATCH_TOTAL,
            BATCH_CURRENCY,
            IRM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
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
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            REMIT_BANK_ID
      FROM Okl_Trx_Csh_Batch_B
     WHERE okl_trx_csh_batch_b.id = p_id;
    l_btc_pk                       btc_pk_csr%ROWTYPE;
    l_btc_rec                      btc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN btc_pk_csr (p_btc_rec.id);
    FETCH btc_pk_csr INTO
              l_btc_rec.ID,
              l_btc_rec.OBJECT_VERSION_NUMBER,
              l_btc_rec.DATE_ENTERED,
              l_btc_rec.DATE_GL_REQUESTED,
              l_btc_rec.DATE_DEPOSIT,
              l_btc_rec.BATCH_QTY,
              l_btc_rec.BATCH_TOTAL,
              l_btc_rec.BATCH_CURRENCY,
              l_btc_rec.IRM_ID,
              l_btc_rec.REQUEST_ID,
              l_btc_rec.PROGRAM_APPLICATION_ID,
              l_btc_rec.PROGRAM_ID,
              l_btc_rec.PROGRAM_UPDATE_DATE,
              l_btc_rec.ORG_ID,
              l_btc_rec.ATTRIBUTE_CATEGORY,
              l_btc_rec.ATTRIBUTE1,
              l_btc_rec.ATTRIBUTE2,
              l_btc_rec.ATTRIBUTE3,
              l_btc_rec.ATTRIBUTE4,
              l_btc_rec.ATTRIBUTE5,
              l_btc_rec.ATTRIBUTE6,
              l_btc_rec.ATTRIBUTE7,
              l_btc_rec.ATTRIBUTE8,
              l_btc_rec.ATTRIBUTE9,
              l_btc_rec.ATTRIBUTE10,
              l_btc_rec.ATTRIBUTE11,
              l_btc_rec.ATTRIBUTE12,
              l_btc_rec.ATTRIBUTE13,
              l_btc_rec.ATTRIBUTE14,
              l_btc_rec.ATTRIBUTE15,
              l_btc_rec.CREATED_BY,
              l_btc_rec.CREATION_DATE,
              l_btc_rec.LAST_UPDATED_BY,
              l_btc_rec.LAST_UPDATE_DATE,
              l_btc_rec.LAST_UPDATE_LOGIN,
              l_btc_rec.CURRENCY_CONVERSION_TYPE,
              l_btc_rec.CURRENCY_CONVERSION_RATE,
              l_btc_rec.CURRENCY_CONVERSION_DATE,
              l_btc_rec.REMIT_BANK_ID;
    x_no_data_found := btc_pk_csr%NOTFOUND;
    CLOSE btc_pk_csr;
    RETURN(l_btc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_btc_rec                      IN btc_rec_type
  ) RETURN btc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_btc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_BATCH_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_trx_csh_batch_tl_rec_type IS
    CURSOR okl_trx_csh_batch_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Trx_Csh_Batch_Tl
     WHERE okl_trx_csh_batch_tl.id = p_id
       AND okl_trx_csh_batch_tl.LANGUAGE = p_language;
    l_okl_trx_csh_batch_tl_pk      okl_trx_csh_batch_tl_pk_csr%ROWTYPE;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_csh_batch_tl_pk_csr (p_okl_trx_csh_batch_tl_rec.id,
                                      p_okl_trx_csh_batch_tl_rec.LANGUAGE);
    FETCH okl_trx_csh_batch_tl_pk_csr INTO
              l_okl_trx_csh_batch_tl_rec.ID,
              l_okl_trx_csh_batch_tl_rec.LANGUAGE,
              l_okl_trx_csh_batch_tl_rec.SOURCE_LANG,
              l_okl_trx_csh_batch_tl_rec.SFWT_FLAG,
              l_okl_trx_csh_batch_tl_rec.NAME,
              l_okl_trx_csh_batch_tl_rec.DESCRIPTION,
              l_okl_trx_csh_batch_tl_rec.CREATED_BY,
              l_okl_trx_csh_batch_tl_rec.CREATION_DATE,
              l_okl_trx_csh_batch_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_csh_batch_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_csh_batch_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_csh_batch_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_csh_batch_tl_pk_csr;
    RETURN(l_okl_trx_csh_batch_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type
  ) RETURN okl_trx_csh_batch_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_csh_batch_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_BATCH_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_btcv_rec                     IN btcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN btcv_rec_type IS
    CURSOR okl_btcv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            DATE_ENTERED,
            TRX_STATUS_CODE,
            DATE_GL_REQUESTED,
            DATE_DEPOSIT,
            BATCH_QTY,
            BATCH_TOTAL,
            BATCH_CURRENCY,
            IRM_ID,
            DESCRIPTION,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            REMIT_BANK_ID
      FROM Okl_Trx_Csh_Batch_V
     WHERE okl_trx_csh_batch_v.id = p_id;
    l_okl_btcv_pk                  okl_btcv_pk_csr%ROWTYPE;
    l_btcv_rec                     btcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_btcv_pk_csr (p_btcv_rec.id);
    FETCH okl_btcv_pk_csr INTO
              l_btcv_rec.ID,
              l_btcv_rec.OBJECT_VERSION_NUMBER,
              l_btcv_rec.SFWT_FLAG,
              l_btcv_rec.NAME,
              l_btcv_rec.DATE_ENTERED,
              l_btcv_rec.TRX_STATUS_CODE,
              l_btcv_rec.DATE_GL_REQUESTED,
              l_btcv_rec.DATE_DEPOSIT,
              l_btcv_rec.BATCH_QTY,
              l_btcv_rec.BATCH_TOTAL,
              l_btcv_rec.BATCH_CURRENCY,
              l_btcv_rec.IRM_ID,
              l_btcv_rec.DESCRIPTION,
              l_btcv_rec.ATTRIBUTE_CATEGORY,
              l_btcv_rec.ATTRIBUTE1,
              l_btcv_rec.ATTRIBUTE2,
              l_btcv_rec.ATTRIBUTE3,
              l_btcv_rec.ATTRIBUTE4,
              l_btcv_rec.ATTRIBUTE5,
              l_btcv_rec.ATTRIBUTE6,
              l_btcv_rec.ATTRIBUTE7,
              l_btcv_rec.ATTRIBUTE8,
              l_btcv_rec.ATTRIBUTE9,
              l_btcv_rec.ATTRIBUTE10,
              l_btcv_rec.ATTRIBUTE11,
              l_btcv_rec.ATTRIBUTE12,
              l_btcv_rec.ATTRIBUTE13,
              l_btcv_rec.ATTRIBUTE14,
              l_btcv_rec.ATTRIBUTE15,
              l_btcv_rec.REQUEST_ID,
              l_btcv_rec.PROGRAM_APPLICATION_ID,
              l_btcv_rec.PROGRAM_ID,
              l_btcv_rec.PROGRAM_UPDATE_DATE,
              l_btcv_rec.ORG_ID,
              l_btcv_rec.CREATED_BY,
              l_btcv_rec.CREATION_DATE,
              l_btcv_rec.LAST_UPDATED_BY,
              l_btcv_rec.LAST_UPDATE_DATE,
              l_btcv_rec.LAST_UPDATE_LOGIN,
              l_btcv_rec.CURRENCY_CONVERSION_TYPE,
              l_btcv_rec.CURRENCY_CONVERSION_RATE,
              l_btcv_rec.CURRENCY_CONVERSION_DATE,
              l_btcv_rec.REMIT_BANK_ID;
    x_no_data_found := okl_btcv_pk_csr%NOTFOUND;
    CLOSE okl_btcv_pk_csr;
    RETURN(l_btcv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_btcv_rec                     IN btcv_rec_type
  ) RETURN btcv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_btcv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_CSH_BATCH_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_btcv_rec	IN btcv_rec_type
  ) RETURN btcv_rec_type IS
    l_btcv_rec	btcv_rec_type := p_btcv_rec;
  BEGIN
    IF (l_btcv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.object_version_number := NULL;
    END IF;
    IF (l_btcv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_btcv_rec.name = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.name := NULL;
    END IF;
    IF (l_btcv_rec.date_entered = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.date_entered := SYSDATE;
    END IF;
    IF (l_btcv_rec.date_gl_requested = Okl_Api.G_MISS_DATE) OR
       (l_btcv_rec.date_gl_requested = NULL) THEN
      l_btcv_rec.date_gl_requested := SYSDATE;
    END IF;
    IF (l_btcv_rec.date_deposit = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.date_deposit := SYSDATE;
    END IF;
    IF (l_btcv_rec.batch_qty = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.batch_qty := NULL;
    END IF;
    IF (l_btcv_rec.batch_total = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.batch_total := NULL;
    END IF;
    IF (l_btcv_rec.batch_currency = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.batch_currency := NULL;
    END IF;
    IF (l_btcv_rec.irm_id = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.irm_id := NULL;
    END IF;
    IF (l_btcv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.description := NULL;
    END IF;
    IF (l_btcv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute_category := NULL;
    END IF;
    IF (l_btcv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute1 := NULL;
    END IF;
    IF (l_btcv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute2 := NULL;
    END IF;
    IF (l_btcv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute3 := NULL;
    END IF;
    IF (l_btcv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute4 := NULL;
    END IF;
    IF (l_btcv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute5 := NULL;
    END IF;
    IF (l_btcv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute6 := NULL;
    END IF;
    IF (l_btcv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute7 := NULL;
    END IF;
    IF (l_btcv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute8 := NULL;
    END IF;
    IF (l_btcv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute9 := NULL;
    END IF;
    IF (l_btcv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute10 := NULL;
    END IF;
    IF (l_btcv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute11 := NULL;
    END IF;
    IF (l_btcv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute12 := NULL;
    END IF;
    IF (l_btcv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute13 := NULL;
    END IF;
    IF (l_btcv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute14 := NULL;
    END IF;
    IF (l_btcv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.attribute15 := NULL;
    END IF;
    IF (l_btcv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.request_id := NULL;
    END IF;
    IF (l_btcv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.program_application_id := NULL;
    END IF;
    IF (l_btcv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.program_id := NULL;
    END IF;
    IF (l_btcv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.program_update_date := NULL;
    END IF;
    IF (l_btcv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.org_id := NULL;
    END IF;
    IF (l_btcv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.created_by := NULL;
    END IF;
    IF (l_btcv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.creation_date := NULL;
    END IF;
    IF (l_btcv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_btcv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.last_update_date := NULL;
    END IF;
    IF (l_btcv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.last_update_login := NULL;
    END IF;

    IF (l_btcv_rec.CURRENCY_CONVERSION_TYPE = Okl_Api.G_MISS_CHAR) THEN
      l_btcv_rec.CURRENCY_CONVERSION_TYPE := NULL;
    END IF;

    IF (l_btcv_rec.CURRENCY_CONVERSION_RATE = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.CURRENCY_CONVERSION_RATE := NULL;
    END IF;

    IF (l_btcv_rec.CURRENCY_CONVERSION_DATE = Okl_Api.G_MISS_DATE) THEN
      l_btcv_rec.CURRENCY_CONVERSION_DATE := NULL;
    END IF;

    IF (l_btcv_rec.REMIT_BANK_ID = Okl_Api.G_MISS_NUM) THEN
      l_btcv_rec.REMIT_BANK_ID := NULL;
    END IF;

    RETURN(l_btcv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/17/2001
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By BVAGHELA on 05-JUN-2001
  ---------------------------------------------------------------------------

  FUNCTION Is_Unique (
    p_btcv_rec IN btcv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_btcv_csr IS
		  SELECT 'x'
		  FROM   okl_trx_csh_batch_v
		  WHERE  name = p_btcv_rec.name
		  AND    id   <> NVL (p_btcv_rec.id, -99999);

    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique NAME
    OPEN     l_btcv_csr;
    FETCH    l_btcv_csr INTO l_dummy;
	  l_found  := l_btcv_csr%FOUND;
	  CLOSE    l_btcv_csr;

    IF (l_found) THEN

     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                        ,p_msg_name       => 'OKL_BPD_BTCH_EXISTS');
     x_return_status := okl_api.G_RET_STS_ERROR;

    END IF;

    -- return status to the caller
    RETURN x_return_status;

  END Is_Unique;

-- Start of comments
-- Procedure Name  : validate_org_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_org_id (p_btcv_rec IN btcv_rec_type,

  			                 x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      x_return_status := Okl_Util.check_org_id(p_btcv_rec.org_id);

  END validate_org_id;

-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_id(p_btcv_rec 		IN 	btcv_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_btcv_rec.id IS NULL) OR (p_btcv_rec.id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_id;

-- Start of comments
-- Procedure Name  : validate_trx_status_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_trx_status_code (p_btcv_rec 		IN 	btcv_rec_type,
                      			    x_return_status OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_btcv_rec.trx_status_code IS NULL) OR (p_btcv_rec.trx_status_code = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'trx_status_code');
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

--   x_return_status := Okl_Util.CHECK_FND_LOOKUP_CODE('TRX_STATUS_CODE',p_btcv_rec.trx_status_code);

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_trx_status_code;

  -- Start of comments
  -- Procedure Name  : validate_batch_total
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

PROCEDURE validate_batch_total (p_btcv_rec 	 IN  btcv_rec_type,
                      		    x_return_status OUT NOCOPY VARCHAR2) IS

 BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_btcv_rec.batch_total IS NULL) OR (p_btcv_rec.batch_total <= 0) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                        ,p_msg_name       => 'OKL_BPD_BTCH_ZERO');
     x_return_status := okl_api.G_RET_STS_ERROR;

   END IF;

  END validate_batch_total;

  -- Start of comments
  -- Procedure Name  : validate_madatory_flds
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_madatory_flds (p_btcv_rec 	    IN  btcv_rec_type,
                       		        x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_btcv_rec.batch_currency IS NULL OR
       p_btcv_rec.batch_total IS NULL OR

       p_btcv_rec.date_gl_requested = Okl_Api.G_MISS_DATE OR
       p_btcv_rec.date_deposit = Okl_Api.G_MISS_DATE OR
       p_btcv_rec.date_gl_requested IS NULL OR
       p_btcv_rec.date_deposit IS NULL OR

       p_btcv_rec.irm_id IS NULL OR
       p_btcv_rec.name IS NULL THEN

       -- Message Text: Please enter all mandatory fields
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_MISSING_FIELDS');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
  END validate_madatory_flds;

-- Start of comments
-- Procedure Name  : validate_currency_code
-- Description     : added for bug 6957755. racheruv
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_currency_code(p_btcv_rec IN btcv_rec_type,
  			                       x_return_status OUT NOCOPY VARCHAR2) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_CURRENCIES;
  CURSOR okl_fnd_curr_csr (p_code IN okl_k_headers_full_v.currency_code%type) IS
  SELECT '1'
    FROM FND_CURRENCIES_VL
   WHERE FND_CURRENCIES_VL.currency_code = p_code;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN okl_fnd_curr_csr(p_btcv_rec.batch_currency);
    FETCH okl_fnd_curr_csr INTO l_dummy;
    l_row_not_found := okl_fnd_curr_csr%NOTFOUND;
    CLOSE okl_fnd_curr_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'currency_code');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF okl_fnd_curr_csr%ISOPEN THEN
        CLOSE okl_fnd_curr_csr;
      END IF;
  END validate_currency_code;

-- Start of comments
-- Procedure Name  : validate_curr_conv
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_curr_conv (p_btcv_rec IN btcv_rec_type,
  			                 x_return_status OUT NOCOPY VARCHAR2) IS
    l_functional_currency    okl_k_headers_full_v.currency_code%type := okl_accounting_util.get_func_curr_code;
    l_currency_conv_type  okl_k_headers_full_v.currency_conversion_type%type := p_btcv_rec.currency_conversion_type;
    l_currency_conv_rate  okl_k_headers_full_v.currency_conversion_rate%type := p_btcv_rec.currency_conversion_rate;
    l_functional_conversion_rate okl_k_headers_full_v.currency_conversion_rate%type := p_btcv_rec.currency_conversion_rate;
    l_currency_conv_date  okl_k_headers_full_v.currency_conversion_date%type := p_btcv_rec.currency_conversion_date;
    l_batch_currency okl_k_headers_full_v.currency_code%type := p_btcv_rec.batch_currency;
  BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   IF l_functional_currency = l_batch_currency THEN
        IF Upper(l_currency_conv_type) IN ('CORPORATE', 'SPOT', 'USER') OR
           NVL(l_currency_conv_rate, okl_api.g_miss_num) <> okl_api.g_miss_num OR
           NVL(l_currency_conv_date, okl_api.g_miss_date) <> okl_api.g_miss_date THEN

            -- Message Text: Currency conversion values are not required when the receipt and invoice currency's are the same.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_SAME_CURRENCY_BATCH');
        END IF;

   END IF;


   IF ((l_functional_currency <> l_batch_currency) AND
       Upper(nvl(l_currency_conv_type,'NONE')) = 'NONE' AND
       x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN

       -- Message Text: Please enter a currency type.
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');
   END IF;

   IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
     IF (UPPER(p_btcv_rec.currency_conversion_type) = 'USER') THEN
       IF ((NVL(p_btcv_rec.currency_conversion_rate, okl_api.g_miss_num) = okl_api.g_miss_num) OR
         (NVL(p_btcv_rec.currency_conversion_date, okl_api.g_miss_date) = okl_api.g_miss_date)) THEN
         --set error message in message stack
         Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                        ,p_msg_name       => 'OKL_BPD_BATCH_MULTI_CURR');
         x_return_status := okl_api.G_RET_STS_ERROR;
       END IF;
     ELSIF (UPPER(p_btcv_rec.currency_conversion_type) IN ('SPOT', 'CORPORATE')) THEN
       IF (NVL(p_btcv_rec.currency_conversion_date, okl_api.g_miss_date) = okl_api.g_miss_date) THEN
         --set error message in message stack
         Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                        ,p_msg_name       => 'OKL_BPD_BATCH_MULTI_CURR');
         x_return_status := okl_api.G_RET_STS_ERROR;
       END IF;
     END IF;
   END IF;

    IF l_functional_currency <> l_batch_currency AND
       upper(l_currency_conv_type) NOT IN ('USER') AND
       x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN

        l_functional_conversion_rate := okl_accounting_util.get_curr_con_rate( l_batch_currency
                                                                              ,l_functional_currency
                                                                              ,l_currency_conv_date
                                                                              ,l_currency_conv_type
                                                                              );


        IF l_functional_conversion_rate IN (0,-1) THEN

            -- Message Text: No exchange rate defined
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
        END IF;
    END IF;

  END validate_curr_conv;
  ---------------------------------------------------------------------------
  -- END OF POST TAPI CODE  04/17/2001
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_CSH_BATCH_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_btcv_rec IN  btcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	   -- Added 04/16/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

    validate_org_id(p_btcv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_madatory_flds(p_btcv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_id(p_btcv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_batch_total(x_return_status => x_return_status,
	   	 	             p_btcv_rec      => p_btcv_rec);

    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            -- there was an error
            l_return_status := x_return_status;
        END IF;
    END IF;


    -- adding below currency validation for bug 6957755.. racheruv
    validate_currency_code(p_btcv_rec,x_return_status);

    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            -- there was an error
            l_return_status := x_return_status;
        END IF;
    END IF;
    -- end currency validation .. bug 6957755. racheruv

    validate_curr_conv(x_return_status => x_return_status,
	   	 	             p_btcv_rec      => p_btcv_rec);

    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            -- there was an error
            l_return_status := x_return_status;
        END IF;
    END IF;

/*
	validate_trx_status_code(p_btcv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
	IF p_btcv_rec.id = Okl_Api.G_MISS_NUM OR
       p_btcv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_btcv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_btcv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_btcv_rec.name = Okl_Api.G_MISS_CHAR OR
          p_btcv_rec.name IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_TRX_CSH_BATCH_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_btcv_rec IN btcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	x_return_status				   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

	 -- call each record-level validation
    l_return_status := is_unique (p_btcv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN (x_return_status);

	EXCEPTION

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN btcv_rec_type,
    p_to	IN OUT NOCOPY btc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_entered := p_from.date_entered;
	p_to.trx_status_code := p_from.trx_status_code;
    p_to.date_gl_requested := p_from.date_gl_requested;
    p_to.date_deposit := p_from.date_deposit;
    p_to.batch_qty := p_from.batch_qty;
    p_to.batch_total := p_from.batch_total;
    p_to.batch_currency := p_from.batch_currency;
    p_to.irm_id := p_from.irm_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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

    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
    p_to.REMIT_BANK_ID := p_from.REMIT_BANK_ID;
  END migrate;
  PROCEDURE migrate (
    p_from	IN btc_rec_type,
    p_to	IN OUT NOCOPY btcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_entered := p_from.date_entered;
	p_to.trx_status_code := p_from.trx_status_code;
    p_to.date_gl_requested := p_from.date_gl_requested;
    p_to.date_deposit := p_from.date_deposit;
    p_to.batch_qty := p_from.batch_qty;
    p_to.batch_total := p_from.batch_total;
    p_to.batch_currency := p_from.batch_currency;
    p_to.irm_id := p_from.irm_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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

    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
    p_to.REMIT_BANK_ID := p_from.REMIT_BANK_ID;
  END migrate;
  PROCEDURE migrate (
    p_from	IN btcv_rec_type,
    p_to	IN OUT NOCOPY okl_trx_csh_batch_tl_rec_type
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
    p_from	IN okl_trx_csh_batch_tl_rec_type,
    p_to	IN OUT NOCOPY btcv_rec_type
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
  ------------------------------------------
  -- validate_row for:OKL_TRX_CSH_BATCH_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btcv_rec                     btcv_rec_type := p_btcv_rec;
    l_btc_rec                      btc_rec_type;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_btcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_btcv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:BTCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btcv_tbl.COUNT > 0) THEN
      i := p_btcv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btcv_rec                     => p_btcv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_btcv_tbl.LAST);
        i := p_btcv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_CSH_BATCH_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btc_rec                      IN btc_rec_type,
    x_btc_rec                      OUT NOCOPY btc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btc_rec                      btc_rec_type := p_btc_rec;
    l_def_btc_rec                  btc_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_btc_rec IN  btc_rec_type,
      x_btc_rec OUT NOCOPY btc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btc_rec := p_btc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_btc_rec,                         -- IN
      l_btc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_TRX_CSH_BATCH_B(
        id,
        object_version_number,
        date_entered,
        date_gl_requested,
        date_deposit,
        batch_qty,
        batch_total,
        batch_currency,
        irm_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
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
         trx_status_code,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        REMIT_BANK_ID)
      VALUES (
        l_btc_rec.id,
        l_btc_rec.object_version_number,
        l_btc_rec.date_entered,
        l_btc_rec.date_gl_requested,
        l_btc_rec.date_deposit,
        l_btc_rec.batch_qty,
        l_btc_rec.batch_total,
        l_btc_rec.batch_currency,
        l_btc_rec.irm_id,
        l_btc_rec.request_id,
        l_btc_rec.program_application_id,
        l_btc_rec.program_id,
        l_btc_rec.program_update_date,
        l_btc_rec.org_id,
        l_btc_rec.attribute_category,
        l_btc_rec.attribute1,
        l_btc_rec.attribute2,
        l_btc_rec.attribute3,
        l_btc_rec.attribute4,
        l_btc_rec.attribute5,
        l_btc_rec.attribute6,
        l_btc_rec.attribute7,
        l_btc_rec.attribute8,
        l_btc_rec.attribute9,
        l_btc_rec.attribute10,
        l_btc_rec.attribute11,
        l_btc_rec.attribute12,
        l_btc_rec.attribute13,
        l_btc_rec.attribute14,
        l_btc_rec.attribute15,
        l_btc_rec.created_by,
        l_btc_rec.creation_date,
        l_btc_rec.last_updated_by,
        l_btc_rec.last_update_date,
        l_btc_rec.last_update_login,
       l_btc_rec.trx_status_code,
        l_btc_rec.CURRENCY_CONVERSION_TYPE,
        l_btc_rec.CURRENCY_CONVERSION_RATE,
        l_btc_rec.CURRENCY_CONVERSION_DATE,
        l_btc_rec.REMIT_BANK_ID);
    -- Set OUT values
    x_btc_rec := l_btc_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_CSH_BATCH_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type,
    x_okl_trx_csh_batch_tl_rec     OUT NOCOPY okl_trx_csh_batch_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type := p_okl_trx_csh_batch_tl_rec;
    ldefokltrxcshbatchtlrec        okl_trx_csh_batch_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_batch_tl_rec IN  okl_trx_csh_batch_tl_rec_type,
      x_okl_trx_csh_batch_tl_rec OUT NOCOPY okl_trx_csh_batch_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_batch_tl_rec := p_okl_trx_csh_batch_tl_rec;
      x_okl_trx_csh_batch_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_csh_batch_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_csh_batch_tl_rec,        -- IN
      l_okl_trx_csh_batch_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_csh_batch_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_CSH_BATCH_TL(
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
          l_okl_trx_csh_batch_tl_rec.id,
          l_okl_trx_csh_batch_tl_rec.LANGUAGE,
          l_okl_trx_csh_batch_tl_rec.source_lang,
          l_okl_trx_csh_batch_tl_rec.sfwt_flag,
          l_okl_trx_csh_batch_tl_rec.name,
          l_okl_trx_csh_batch_tl_rec.description,
          l_okl_trx_csh_batch_tl_rec.created_by,
          l_okl_trx_csh_batch_tl_rec.creation_date,
          l_okl_trx_csh_batch_tl_rec.last_updated_by,
          l_okl_trx_csh_batch_tl_rec.last_update_date,
          l_okl_trx_csh_batch_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_csh_batch_tl_rec := l_okl_trx_csh_batch_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_CSH_BATCH_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type,
    x_btcv_rec                     OUT NOCOPY btcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btcv_rec                     btcv_rec_type;
    l_def_btcv_rec                 btcv_rec_type;
    l_btc_rec                      btc_rec_type;
    lx_btc_rec                     btc_rec_type;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
    lx_okl_trx_csh_batch_tl_rec    okl_trx_csh_batch_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_btcv_rec	IN btcv_rec_type
    ) RETURN btcv_rec_type IS
      l_btcv_rec	btcv_rec_type := p_btcv_rec;
    BEGIN
      IF l_btcv_rec.DATE_GL_REQUESTED IS NULL THEN
        l_btcv_rec.DATE_GL_REQUESTED := SYSDATE;
      END IF;
      IF l_btcv_rec.DATE_ENTERED IS NULL THEN
        l_btcv_rec.DATE_ENTERED := SYSDATE;
      END IF;
      IF l_btcv_rec.DATE_DEPOSIT IS NULL THEN
        l_btcv_rec.DATE_DEPOSIT := SYSDATE;
      END IF;
      l_btcv_rec.CURRENCY_CONVERSION_TYPE := INITCAP(l_btcv_rec.CURRENCY_CONVERSION_TYPE);
      IF (UPPER(l_btcv_rec.CURRENCY_CONVERSION_TYPE) = 'NONE') THEN
        l_btcv_rec.CURRENCY_CONVERSION_TYPE := NULL;
      ELSIF (UPPER(l_btcv_rec.CURRENCY_CONVERSION_TYPE) IN ('CORPORATE', 'SPOT')) THEN
        l_btcv_rec.CURRENCY_CONVERSION_RATE :=  okl_accounting_util.get_curr_con_rate( l_btcv_rec.BATCH_CURRENCY
                                                                              ,okl_accounting_util.get_func_curr_code
                                                                              ,l_btcv_rec.currency_conversion_date
                                                                              ,l_btcv_rec.currency_conversion_type);
      END IF;
      l_btcv_rec.CREATION_DATE := SYSDATE;
      l_btcv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_btcv_rec.LAST_UPDATE_DATE := l_btcv_rec.CREATION_DATE;
      l_btcv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_btcv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_btcv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_btcv_rec IN  btcv_rec_type,
      x_btcv_rec OUT NOCOPY btcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btcv_rec := p_btcv_rec;
      x_btcv_rec.OBJECT_VERSION_NUMBER := 1;
      x_btcv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_btcv_rec := null_out_defaults(p_btcv_rec);
    -- Set primary key value
    l_btcv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_btcv_rec,                        -- IN
      l_def_btcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_btcv_rec := fill_who_columns(l_def_btcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_btcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_btcv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_btcv_rec, l_btc_rec);
    migrate(l_def_btcv_rec, l_okl_trx_csh_batch_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btc_rec,
      lx_btc_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_btc_rec, l_def_btcv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_batch_tl_rec,
      lx_okl_trx_csh_batch_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_csh_batch_tl_rec, l_def_btcv_rec);
    -- Set OUT values
    x_btcv_rec := l_def_btcv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E'; -- Okl_Api.HANDLE_EXCEPTIONS
      /*
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :='U'; -- Okl_Api.HANDLE_EXCEPTIONS
      /*
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status :='E'; -- Okl_Api.HANDLE_EXCEPTIONS
      /*
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:BTCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type,
    x_btcv_tbl                     OUT NOCOPY btcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btcv_tbl.COUNT > 0) THEN
      i := p_btcv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btcv_rec                     => p_btcv_tbl(i),
          x_btcv_rec                     => x_btcv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_btcv_tbl.LAST);
        i := p_btcv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_CSH_BATCH_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btc_rec                      IN btc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_btc_rec IN btc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CSH_BATCH_B
     WHERE ID = p_btc_rec.id
       AND OBJECT_VERSION_NUMBER = p_btc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_btc_rec IN btc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CSH_BATCH_B
    WHERE ID = p_btc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_CSH_BATCH_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_CSH_BATCH_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_btc_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_btc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_btc_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_btc_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_CSH_BATCH_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_csh_batch_tl_rec IN okl_trx_csh_batch_tl_rec_type) IS
    SELECT *
      FROM OKL_TRX_CSH_BATCH_TL
     WHERE ID = p_okl_trx_csh_batch_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_trx_csh_batch_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_CSH_BATCH_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btc_rec                      btc_rec_type;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_btcv_rec, l_btc_rec);
    migrate(p_btcv_rec, l_okl_trx_csh_batch_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btc_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_batch_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:BTCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btcv_tbl.COUNT > 0) THEN
      i := p_btcv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btcv_rec                     => p_btcv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_btcv_tbl.LAST);
        i := p_btcv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_CSH_BATCH_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btc_rec                      IN btc_rec_type,
    x_btc_rec                      OUT NOCOPY btc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btc_rec                      btc_rec_type := p_btc_rec;
    l_def_btc_rec                  btc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_btc_rec	IN btc_rec_type,
      x_btc_rec	OUT NOCOPY btc_rec_type
    ) RETURN VARCHAR2 IS
      l_btc_rec                      btc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btc_rec := p_btc_rec;
      -- Get current database values
      l_btc_rec := get_rec(p_btc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_btc_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.id := l_btc_rec.id;
      END IF;
      IF (x_btc_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.object_version_number := l_btc_rec.object_version_number;
      END IF;
      IF (x_btc_rec.date_entered = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.date_entered := l_btc_rec.date_entered;
      END IF;
      IF (x_btc_rec.date_gl_requested = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.date_gl_requested := l_btc_rec.date_gl_requested;
      END IF;
      IF (x_btc_rec.date_deposit = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.date_deposit := l_btc_rec.date_deposit;
      END IF;
      IF (x_btc_rec.batch_qty = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.batch_qty := l_btc_rec.batch_qty;
      END IF;
      IF (x_btc_rec.batch_total = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.batch_total := l_btc_rec.batch_total;
      END IF;
      IF (x_btc_rec.batch_currency = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.batch_currency := l_btc_rec.batch_currency;
      END IF;
      IF (x_btc_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.irm_id := l_btc_rec.irm_id;
      END IF;
      IF (x_btc_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.request_id := l_btc_rec.request_id;
      END IF;
      IF (x_btc_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.program_application_id := l_btc_rec.program_application_id;
      END IF;
      IF (x_btc_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.program_id := l_btc_rec.program_id;
      END IF;
      IF (x_btc_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.program_update_date := l_btc_rec.program_update_date;
      END IF;
      IF (x_btc_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.org_id := l_btc_rec.org_id;
      END IF;
      IF (x_btc_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute_category := l_btc_rec.attribute_category;
      END IF;
      IF (x_btc_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute1 := l_btc_rec.attribute1;
      END IF;
      IF (x_btc_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute2 := l_btc_rec.attribute2;
      END IF;
      IF (x_btc_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute3 := l_btc_rec.attribute3;
      END IF;
      IF (x_btc_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute4 := l_btc_rec.attribute4;
      END IF;
      IF (x_btc_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute5 := l_btc_rec.attribute5;
      END IF;
      IF (x_btc_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute6 := l_btc_rec.attribute6;
      END IF;
      IF (x_btc_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute7 := l_btc_rec.attribute7;
      END IF;
      IF (x_btc_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute8 := l_btc_rec.attribute8;
      END IF;
      IF (x_btc_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute9 := l_btc_rec.attribute9;
      END IF;
      IF (x_btc_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute10 := l_btc_rec.attribute10;
      END IF;
      IF (x_btc_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute11 := l_btc_rec.attribute11;
      END IF;
      IF (x_btc_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute12 := l_btc_rec.attribute12;
      END IF;
      IF (x_btc_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute13 := l_btc_rec.attribute13;
      END IF;
      IF (x_btc_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute14 := l_btc_rec.attribute14;
      END IF;
      IF (x_btc_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.attribute15 := l_btc_rec.attribute15;
      END IF;
      IF (x_btc_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.created_by := l_btc_rec.created_by;
      END IF;
      IF (x_btc_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.creation_date := l_btc_rec.creation_date;
      END IF;
      IF (x_btc_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.last_updated_by := l_btc_rec.last_updated_by;
      END IF;
      IF (x_btc_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.last_update_date := l_btc_rec.last_update_date;
      END IF;
      IF (x_btc_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.last_update_login := l_btc_rec.last_update_login;
      END IF;
	  IF (x_btc_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.trx_status_code := l_btc_rec.trx_status_code;
      END IF;

	  IF (x_btc_rec.CURRENCY_CONVERSION_TYPE = Okl_Api.G_MISS_CHAR)
      THEN
        x_btc_rec.CURRENCY_CONVERSION_TYPE := l_btc_rec.CURRENCY_CONVERSION_TYPE;
      END IF;

      IF (x_btc_rec.CURRENCY_CONVERSION_RATE = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.CURRENCY_CONVERSION_RATE := l_btc_rec.CURRENCY_CONVERSION_RATE;
      END IF;

      IF (x_btc_rec.CURRENCY_CONVERSION_DATE = Okl_Api.G_MISS_DATE)
      THEN
        x_btc_rec.CURRENCY_CONVERSION_DATE := l_btc_rec.CURRENCY_CONVERSION_DATE;
      END IF;
      IF (x_btc_rec.REMIT_BANK_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_btc_rec.REMIT_BANK_ID := l_btc_rec.REMIT_BANK_ID;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_btc_rec IN  btc_rec_type,
      x_btc_rec OUT NOCOPY btc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btc_rec := p_btc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_btc_rec,                         -- IN
      l_btc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_btc_rec, l_def_btc_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_CSH_BATCH_B
    SET OBJECT_VERSION_NUMBER = l_def_btc_rec.object_version_number,
        DATE_ENTERED = l_def_btc_rec.date_entered,
        DATE_GL_REQUESTED = l_def_btc_rec.date_gl_requested,
        DATE_DEPOSIT = l_def_btc_rec.date_deposit,
        BATCH_QTY = l_def_btc_rec.batch_qty,
        BATCH_TOTAL = l_def_btc_rec.batch_total,
        BATCH_CURRENCY = l_def_btc_rec.batch_currency,
        IRM_ID = l_def_btc_rec.irm_id,
        REQUEST_ID = l_def_btc_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_btc_rec.program_application_id,
        PROGRAM_ID = l_def_btc_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_btc_rec.program_update_date,
        ORG_ID = l_def_btc_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_btc_rec.attribute_category,
        ATTRIBUTE1 = l_def_btc_rec.attribute1,
        ATTRIBUTE2 = l_def_btc_rec.attribute2,
        ATTRIBUTE3 = l_def_btc_rec.attribute3,
        ATTRIBUTE4 = l_def_btc_rec.attribute4,
        ATTRIBUTE5 = l_def_btc_rec.attribute5,
        ATTRIBUTE6 = l_def_btc_rec.attribute6,
        ATTRIBUTE7 = l_def_btc_rec.attribute7,
        ATTRIBUTE8 = l_def_btc_rec.attribute8,
        ATTRIBUTE9 = l_def_btc_rec.attribute9,
        ATTRIBUTE10 = l_def_btc_rec.attribute10,
        ATTRIBUTE11 = l_def_btc_rec.attribute11,
        ATTRIBUTE12 = l_def_btc_rec.attribute12,
        ATTRIBUTE13 = l_def_btc_rec.attribute13,
        ATTRIBUTE14 = l_def_btc_rec.attribute14,
        ATTRIBUTE15 = l_def_btc_rec.attribute15,
        CREATED_BY = l_def_btc_rec.created_by,
        CREATION_DATE = l_def_btc_rec.creation_date,
        LAST_UPDATED_BY = l_def_btc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_btc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_btc_rec.last_update_login,
        TRX_STATUS_CODE = l_def_btc_rec.trx_status_code,
        CURRENCY_CONVERSION_TYPE = l_def_btc_rec.CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE = l_def_btc_rec.CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE = l_def_btc_rec.CURRENCY_CONVERSION_DATE,
        REMIT_BANK_ID = l_def_btc_rec.REMIT_BANK_ID
    WHERE ID = l_def_btc_rec.id;

    x_btc_rec := l_def_btc_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_CSH_BATCH_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type,
    x_okl_trx_csh_batch_tl_rec     OUT NOCOPY okl_trx_csh_batch_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type := p_okl_trx_csh_batch_tl_rec;
    ldefokltrxcshbatchtlrec        okl_trx_csh_batch_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_csh_batch_tl_rec	IN okl_trx_csh_batch_tl_rec_type,
      x_okl_trx_csh_batch_tl_rec	OUT NOCOPY okl_trx_csh_batch_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_batch_tl_rec := p_okl_trx_csh_batch_tl_rec;
      -- Get current database values
      l_okl_trx_csh_batch_tl_rec := get_rec(p_okl_trx_csh_batch_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_batch_tl_rec.id := l_okl_trx_csh_batch_tl_rec.id;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_batch_tl_rec.LANGUAGE := l_okl_trx_csh_batch_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_batch_tl_rec.source_lang := l_okl_trx_csh_batch_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_batch_tl_rec.sfwt_flag := l_okl_trx_csh_batch_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_batch_tl_rec.name := l_okl_trx_csh_batch_tl_rec.name;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_batch_tl_rec.description := l_okl_trx_csh_batch_tl_rec.description;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_batch_tl_rec.created_by := l_okl_trx_csh_batch_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_csh_batch_tl_rec.creation_date := l_okl_trx_csh_batch_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_batch_tl_rec.last_updated_by := l_okl_trx_csh_batch_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_csh_batch_tl_rec.last_update_date := l_okl_trx_csh_batch_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_csh_batch_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_batch_tl_rec.last_update_login := l_okl_trx_csh_batch_tl_rec.last_update_login;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_batch_tl_rec IN  okl_trx_csh_batch_tl_rec_type,
      x_okl_trx_csh_batch_tl_rec OUT NOCOPY okl_trx_csh_batch_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_batch_tl_rec := p_okl_trx_csh_batch_tl_rec;
      x_okl_trx_csh_batch_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_csh_batch_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_csh_batch_tl_rec,        -- IN
      l_okl_trx_csh_batch_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_csh_batch_tl_rec, ldefokltrxcshbatchtlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_CSH_BATCH_TL
    SET NAME = ldefokltrxcshbatchtlrec.name,
        DESCRIPTION = ldefokltrxcshbatchtlrec.description,
        CREATED_BY = ldefokltrxcshbatchtlrec.created_by,
        CREATION_DATE = ldefokltrxcshbatchtlrec.creation_date,
        LAST_UPDATED_BY = ldefokltrxcshbatchtlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltrxcshbatchtlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltrxcshbatchtlrec.last_update_login
    WHERE ID = ldefokltrxcshbatchtlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TRX_CSH_BATCH_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltrxcshbatchtlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_csh_batch_tl_rec := ldefokltrxcshbatchtlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_CSH_BATCH_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type,
    x_btcv_rec                     OUT NOCOPY btcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btcv_rec                     btcv_rec_type := p_btcv_rec;
    l_def_btcv_rec                 btcv_rec_type;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
    lx_okl_trx_csh_batch_tl_rec    okl_trx_csh_batch_tl_rec_type;
    l_btc_rec                      btc_rec_type;
    lx_btc_rec                     btc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_btcv_rec	IN btcv_rec_type
    ) RETURN btcv_rec_type IS
      l_btcv_rec	btcv_rec_type := p_btcv_rec;
    BEGIN
      l_btcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_btcv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_btcv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_btcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_btcv_rec	IN btcv_rec_type,
      x_btcv_rec	OUT NOCOPY btcv_rec_type
    ) RETURN VARCHAR2 IS
      l_btcv_rec                     btcv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btcv_rec := p_btcv_rec;
      -- Get current database values
      l_btcv_rec := get_rec(p_btcv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_btcv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.id := l_btcv_rec.id;
      END IF;
      IF (x_btcv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.object_version_number := l_btcv_rec.object_version_number;
      END IF;
      IF (x_btcv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.sfwt_flag := l_btcv_rec.sfwt_flag;
      END IF;
      IF (x_btcv_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.name := l_btcv_rec.name;
      END IF;
      IF (x_btcv_rec.date_entered = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.date_entered := l_btcv_rec.date_entered;
      END IF;
      IF (x_btcv_rec.date_gl_requested = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.date_gl_requested := l_btcv_rec.date_gl_requested;
      END IF;
      IF (x_btcv_rec.date_deposit = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.date_deposit := l_btcv_rec.date_deposit;
      END IF;
      IF (x_btcv_rec.batch_qty = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.batch_qty := l_btcv_rec.batch_qty;
      END IF;
      IF (x_btcv_rec.batch_total = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.batch_total := l_btcv_rec.batch_total;
      END IF;
      IF (x_btcv_rec.batch_currency = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.batch_currency := l_btcv_rec.batch_currency;
      END IF;
      IF (x_btcv_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.irm_id := l_btcv_rec.irm_id;
      END IF;
      IF (x_btcv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.description := l_btcv_rec.description;
      END IF;
      IF (x_btcv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute_category := l_btcv_rec.attribute_category;
      END IF;
      IF (x_btcv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute1 := l_btcv_rec.attribute1;
      END IF;
      IF (x_btcv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute2 := l_btcv_rec.attribute2;
      END IF;
      IF (x_btcv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute3 := l_btcv_rec.attribute3;
      END IF;
      IF (x_btcv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute4 := l_btcv_rec.attribute4;
      END IF;
      IF (x_btcv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute5 := l_btcv_rec.attribute5;
      END IF;
      IF (x_btcv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute6 := l_btcv_rec.attribute6;
      END IF;
      IF (x_btcv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute7 := l_btcv_rec.attribute7;
      END IF;
      IF (x_btcv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute8 := l_btcv_rec.attribute8;
      END IF;
      IF (x_btcv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute9 := l_btcv_rec.attribute9;
      END IF;
      IF (x_btcv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute10 := l_btcv_rec.attribute10;
      END IF;
      IF (x_btcv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute11 := l_btcv_rec.attribute11;
      END IF;
      IF (x_btcv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute12 := l_btcv_rec.attribute12;
      END IF;
      IF (x_btcv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute13 := l_btcv_rec.attribute13;
      END IF;
      IF (x_btcv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute14 := l_btcv_rec.attribute14;
      END IF;
      IF (x_btcv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.attribute15 := l_btcv_rec.attribute15;
      END IF;
      IF (x_btcv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.request_id := l_btcv_rec.request_id;
      END IF;
      IF (x_btcv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.program_application_id := l_btcv_rec.program_application_id;
      END IF;
      IF (x_btcv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.program_id := l_btcv_rec.program_id;
      END IF;
      IF (x_btcv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.program_update_date := l_btcv_rec.program_update_date;
      END IF;
      IF (x_btcv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.org_id := l_btcv_rec.org_id;
      END IF;
      IF (x_btcv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.created_by := l_btcv_rec.created_by;
      END IF;
      IF (x_btcv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.creation_date := l_btcv_rec.creation_date;
      END IF;
      IF (x_btcv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.last_updated_by := l_btcv_rec.last_updated_by;
      END IF;
      IF (x_btcv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_btcv_rec.last_update_date := l_btcv_rec.last_update_date;
      END IF;
      IF (x_btcv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.last_update_login := l_btcv_rec.last_update_login;
      END IF;
	  IF (x_btcv_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcv_rec.trx_status_code := l_btcv_rec.trx_status_code;
      END IF;

      IF (x_btcV_rec.CURRENCY_CONVERSION_TYPE = Okl_Api.G_MISS_CHAR)
      THEN
        x_btcV_rec.CURRENCY_CONVERSION_TYPE := l_btcV_rec.CURRENCY_CONVERSION_TYPE;
      END IF;

      IF (x_btcV_rec.CURRENCY_CONVERSION_RATE = Okl_Api.G_MISS_NUM)
      THEN
        x_btcV_rec.CURRENCY_CONVERSION_RATE := l_btcV_rec.CURRENCY_CONVERSION_RATE;
      END IF;

      IF (x_btcV_rec.CURRENCY_CONVERSION_DATE = Okl_Api.G_MISS_DATE)
      THEN
        x_btcV_rec.CURRENCY_CONVERSION_DATE := l_btcV_rec.CURRENCY_CONVERSION_DATE;
      END IF;
      IF (x_btcv_rec.REMIT_BANK_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_btcv_rec.REMIT_BANK_ID := l_btcv_rec.REMIT_BANK_ID;
      END IF;


      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_btcv_rec IN  btcv_rec_type,
      x_btcv_rec OUT NOCOPY btcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_btcv_rec := p_btcv_rec;
      x_btcv_rec.OBJECT_VERSION_NUMBER := NVL(x_btcv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_btcv_rec,                        -- IN
      l_btcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_btcv_rec, l_def_btcv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_btcv_rec := fill_who_columns(l_def_btcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_btcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_btcv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_btcv_rec, l_okl_trx_csh_batch_tl_rec);
    migrate(l_def_btcv_rec, l_btc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_batch_tl_rec,
      lx_okl_trx_csh_batch_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_csh_batch_tl_rec, l_def_btcv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btc_rec,
      lx_btc_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_btc_rec, l_def_btcv_rec);
    x_btcv_rec := l_def_btcv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:BTCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type,
    x_btcv_tbl                     OUT NOCOPY btcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btcv_tbl.COUNT > 0) THEN
      i := p_btcv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btcv_rec                     => p_btcv_tbl(i),
          x_btcv_rec                     => x_btcv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_btcv_tbl.LAST);
        i := p_btcv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_CSH_BATCH_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btc_rec                      IN btc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btc_rec                      btc_rec_type:= p_btc_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_CSH_BATCH_B
     WHERE ID = l_btc_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_CSH_BATCH_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_batch_tl_rec     IN okl_trx_csh_batch_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type:= p_okl_trx_csh_batch_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_BATCH_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_batch_tl_rec IN  okl_trx_csh_batch_tl_rec_type,
      x_okl_trx_csh_batch_tl_rec OUT NOCOPY okl_trx_csh_batch_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_batch_tl_rec := p_okl_trx_csh_batch_tl_rec;
      x_okl_trx_csh_batch_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_csh_batch_tl_rec,        -- IN
      l_okl_trx_csh_batch_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_CSH_BATCH_TL
     WHERE ID = l_okl_trx_csh_batch_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_CSH_BATCH_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_rec                     IN btcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_btcv_rec                     btcv_rec_type := p_btcv_rec;
    l_okl_trx_csh_batch_tl_rec     okl_trx_csh_batch_tl_rec_type;
    l_btc_rec                      btc_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_btcv_rec, l_okl_trx_csh_batch_tl_rec);
    migrate(l_btcv_rec, l_btc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_batch_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btc_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:BTCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btcv_tbl                     IN btcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change


  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btcv_tbl.COUNT > 0) THEN
      i := p_btcv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btcv_rec                     => p_btcv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_btcv_tbl.LAST);
        i := p_btcv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Btc_Pvt;

/
