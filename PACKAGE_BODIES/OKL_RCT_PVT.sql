--------------------------------------------------------
--  DDL for Package Body OKL_RCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RCT_PVT" AS
/* $Header: OKLSRCTB.pls 120.5 2007/08/08 12:51:01 arajagop ship $ */
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
    DELETE FROM OKL_TRX_CSH_RECEIPT_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_CSH_RCPT_ALL_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TRX_CSH_RECEIPT_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TRX_CSH_RECEIPT_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_CSH_RECEIPT_TL SUBB, OKL_TRX_CSH_RECEIPT_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TRX_CSH_RECEIPT_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
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
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TRX_CSH_RECEIPT_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_CSH_RECEIPT_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_RECEIPT_B
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Trx_Csh_Receipt_B table.
  -- Business Rules  :
  -- Parameters      : p_rct_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_rct_rec                      IN rct_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rct_rec_type IS
    CURSOR rct_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CODE,
            EXCHANGE_RATE_TYPE,
            EXCHANGE_RATE_DATE,
            EXCHANGE_RATE,
            BTC_ID,
            IBA_ID,
            GL_DATE,
            ILE_ID,
            IRM_ID,
            OBJECT_VERSION_NUMBER,
            CHECK_NUMBER,
            AMOUNT,
            DATE_EFFECTIVE,
            RCPT_STATUS_CODE,
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
-- New column receipt type added.
            RECEIPT_TYPE,
	    CASH_RECEIPT_ID,
	    FULLY_APPLIED_FLAG,
	    EXPIRED_FLAG
      FROM Okl_Trx_Csh_Receipt_B
     WHERE okl_trx_csh_receipt_b.id = p_id;
    l_rct_pk                       rct_pk_csr%ROWTYPE;
    l_rct_rec                      rct_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rct_pk_csr (p_rct_rec.id);
    FETCH rct_pk_csr INTO
              l_rct_rec.ID,
              l_rct_rec.CURRENCY_CODE,
              l_rct_rec.EXCHANGE_RATE_TYPE,
              l_rct_rec.EXCHANGE_RATE_DATE,
              l_rct_rec.EXCHANGE_RATE,
              l_rct_rec.BTC_ID,
              l_rct_rec.IBA_ID,
              l_rct_rec.GL_DATE,
              l_rct_rec.ILE_ID,
              l_rct_rec.IRM_ID,
              l_rct_rec.OBJECT_VERSION_NUMBER,
              l_rct_rec.CHECK_NUMBER,
              l_rct_rec.AMOUNT,
              l_rct_rec.DATE_EFFECTIVE,
              l_rct_rec.RCPT_STATUS_CODE,
              l_rct_rec.REQUEST_ID,
              l_rct_rec.PROGRAM_APPLICATION_ID,
              l_rct_rec.PROGRAM_ID,
              l_rct_rec.PROGRAM_UPDATE_DATE,
              l_rct_rec.ORG_ID,
              l_rct_rec.ATTRIBUTE_CATEGORY,
              l_rct_rec.ATTRIBUTE1,
              l_rct_rec.ATTRIBUTE2,
              l_rct_rec.ATTRIBUTE3,
              l_rct_rec.ATTRIBUTE4,
              l_rct_rec.ATTRIBUTE5,
              l_rct_rec.ATTRIBUTE6,
              l_rct_rec.ATTRIBUTE7,
              l_rct_rec.ATTRIBUTE8,
              l_rct_rec.ATTRIBUTE9,
              l_rct_rec.ATTRIBUTE10,
              l_rct_rec.ATTRIBUTE11,
              l_rct_rec.ATTRIBUTE12,
              l_rct_rec.ATTRIBUTE13,
              l_rct_rec.ATTRIBUTE14,
              l_rct_rec.ATTRIBUTE15,
              l_rct_rec.CREATED_BY,
              l_rct_rec.CREATION_DATE,
              l_rct_rec.LAST_UPDATED_BY,
              l_rct_rec.LAST_UPDATE_DATE,
              l_rct_rec.LAST_UPDATE_LOGIN,
-- New column receipt type added.
              l_rct_rec.RECEIPT_TYPE,
	      l_rct_rec.CASH_RECEIPT_ID,
	      l_rct_rec.FULLY_APPLIED_FLAG,
	      l_rct_rec.EXPIRED_FLAG;
    x_no_data_found := rct_pk_csr%NOTFOUND;
    CLOSE rct_pk_csr;
    RETURN(l_rct_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rct_rec                      IN rct_rec_type
  ) RETURN rct_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rct_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_RECEIPT_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklTrxCshReceiptTlRecType IS
    CURSOR okl_trx_csh_receipt_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Trx_Csh_Receipt_Tl
     WHERE okl_trx_csh_receipt_tl.id = p_id
       AND okl_trx_csh_receipt_tl.LANGUAGE = p_language;
    l_okl_trx_csh_receipt_tl_pk    okl_trx_csh_receipt_tl_pk_csr%ROWTYPE;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_csh_receipt_tl_pk_csr (p_okl_trx_csh_receipt_tl_rec.id,
                                        p_okl_trx_csh_receipt_tl_rec.LANGUAGE);
    FETCH okl_trx_csh_receipt_tl_pk_csr INTO
              l_okl_trx_csh_receipt_tl_rec.ID,
              l_okl_trx_csh_receipt_tl_rec.LANGUAGE,
              l_okl_trx_csh_receipt_tl_rec.SOURCE_LANG,
              l_okl_trx_csh_receipt_tl_rec.SFWT_FLAG,
              l_okl_trx_csh_receipt_tl_rec.DESCRIPTION,
              l_okl_trx_csh_receipt_tl_rec.CREATED_BY,
              l_okl_trx_csh_receipt_tl_rec.CREATION_DATE,
              l_okl_trx_csh_receipt_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_csh_receipt_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_csh_receipt_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_csh_receipt_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_csh_receipt_tl_pk_csr;
    RETURN(l_okl_trx_csh_receipt_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType
  ) RETURN OklTrxCshReceiptTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_csh_receipt_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CSH_RECEIPT_V
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Trx_Csh_Receipt_B table.
  -- Business Rules  :
  -- Parameters      : p_rctv_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_rctv_rec                     IN rctv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rctv_rec_type IS
    CURSOR okl_rctv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            BTC_ID,
            IBA_ID,
            GL_DATE,
            ILE_ID,
            IRM_ID,
            CHECK_NUMBER,
            CURRENCY_CODE,
            EXCHANGE_RATE_TYPE,
            EXCHANGE_RATE_DATE,
            EXCHANGE_RATE,
            AMOUNT,
            DATE_EFFECTIVE,
            RCPT_STATUS_CODE,
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
-- New column receipt type added.
            RECEIPT_TYPE,
	    CASH_RECEIPT_ID,
	    FULLY_APPLIED_FLAG,
	    EXPIRED_FLAG
      FROM Okl_Trx_Csh_Receipt_V
     WHERE okl_trx_csh_receipt_v.id = p_id;
    l_okl_rctv_pk                  okl_rctv_pk_csr%ROWTYPE;
    l_rctv_rec                     rctv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_rctv_pk_csr (p_rctv_rec.id);
    FETCH okl_rctv_pk_csr INTO
              l_rctv_rec.ID,
              l_rctv_rec.OBJECT_VERSION_NUMBER,
              l_rctv_rec.SFWT_FLAG,
              l_rctv_rec.BTC_ID,
              l_rctv_rec.IBA_ID,
              l_rctv_rec.GL_DATE,
              l_rctv_rec.ILE_ID,
              l_rctv_rec.IRM_ID,
              l_rctv_rec.CHECK_NUMBER,
              l_rctv_rec.CURRENCY_CODE,
              l_rctv_rec.EXCHANGE_RATE_TYPE,
              l_rctv_rec.EXCHANGE_RATE_DATE,
              l_rctv_rec.EXCHANGE_RATE,
              l_rctv_rec.AMOUNT,
              l_rctv_rec.DATE_EFFECTIVE,
              l_rctv_rec.RCPT_STATUS_CODE,
              l_rctv_rec.DESCRIPTION,
              l_rctv_rec.ATTRIBUTE_CATEGORY,
              l_rctv_rec.ATTRIBUTE1,
              l_rctv_rec.ATTRIBUTE2,
              l_rctv_rec.ATTRIBUTE3,
              l_rctv_rec.ATTRIBUTE4,
              l_rctv_rec.ATTRIBUTE5,
              l_rctv_rec.ATTRIBUTE6,
              l_rctv_rec.ATTRIBUTE7,
              l_rctv_rec.ATTRIBUTE8,
              l_rctv_rec.ATTRIBUTE9,
              l_rctv_rec.ATTRIBUTE10,
              l_rctv_rec.ATTRIBUTE11,
              l_rctv_rec.ATTRIBUTE12,
              l_rctv_rec.ATTRIBUTE13,
              l_rctv_rec.ATTRIBUTE14,
              l_rctv_rec.ATTRIBUTE15,
              l_rctv_rec.REQUEST_ID,
              l_rctv_rec.PROGRAM_APPLICATION_ID,
              l_rctv_rec.PROGRAM_ID,
              l_rctv_rec.PROGRAM_UPDATE_DATE,
              l_rctv_rec.ORG_ID,
              l_rctv_rec.CREATED_BY,
              l_rctv_rec.CREATION_DATE,
              l_rctv_rec.LAST_UPDATED_BY,
              l_rctv_rec.LAST_UPDATE_DATE,
              l_rctv_rec.LAST_UPDATE_LOGIN,
-- New column receipt type added.
              l_rctv_rec.RECEIPT_TYPE,
	      l_rctv_rec.CASH_RECEIPT_ID,
	      l_rctv_rec.FULLY_APPLIED_FLAG,
	      l_rctv_rec.EXPIRED_FLAG;
    x_no_data_found := okl_rctv_pk_csr%NOTFOUND;
    CLOSE okl_rctv_pk_csr;
    RETURN(l_rctv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rctv_rec                     IN rctv_rec_type
  ) RETURN rctv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rctv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_CSH_RECEIPT_V --
  -----------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : If the field has default values then equate it to null.
  -- Business Rules  :
  -- Parameters      : p_rctv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults (
    p_rctv_rec	IN rctv_rec_type
  ) RETURN rctv_rec_type IS
    l_rctv_rec	rctv_rec_type := p_rctv_rec;
  BEGIN
    IF (l_rctv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.object_version_number := NULL;
    END IF;
    IF (l_rctv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_rctv_rec.btc_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.btc_id := NULL;
    END IF;
    IF (l_rctv_rec.iba_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.iba_id := NULL;
    END IF;
    IF (l_rctv_rec.gl_date = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.gl_date := NULL;
    END IF;
    IF (l_rctv_rec.ile_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.ile_id := NULL;
    END IF;
    IF (l_rctv_rec.irm_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.irm_id := NULL;
    END IF;
    IF (l_rctv_rec.check_number = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.check_number := NULL;
    END IF;
    IF (l_rctv_rec.currency_code = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.currency_code := NULL;
    END IF;
    IF (l_rctv_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.exchange_rate_type := NULL;
    END IF;
    IF (l_rctv_rec.exchange_rate_date = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.exchange_rate_date := NULL;
    END IF;
    IF (l_rctv_rec.exchange_rate = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.exchange_rate := NULL;
    END IF;
    IF (l_rctv_rec.amount = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.amount := NULL;
    END IF;
    IF (l_rctv_rec.date_effective = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.date_effective := NULL;
    END IF;
    IF (l_rctv_rec.rcpt_status_code = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.rcpt_status_code := NULL;
    END IF;

    IF (l_rctv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.description := NULL;
    END IF;
    IF (l_rctv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute_category := NULL;
    END IF;
    IF (l_rctv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute1 := NULL;
    END IF;
    IF (l_rctv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute2 := NULL;
    END IF;
    IF (l_rctv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute3 := NULL;
    END IF;
    IF (l_rctv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute4 := NULL;
    END IF;
    IF (l_rctv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute5 := NULL;
    END IF;
    IF (l_rctv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute6 := NULL;
    END IF;
    IF (l_rctv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute7 := NULL;
    END IF;
    IF (l_rctv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute8 := NULL;
    END IF;
    IF (l_rctv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute9 := NULL;
    END IF;
    IF (l_rctv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute10 := NULL;
    END IF;
    IF (l_rctv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute11 := NULL;
    END IF;
    IF (l_rctv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute12 := NULL;
    END IF;
    IF (l_rctv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute13 := NULL;
    END IF;
    IF (l_rctv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute14 := NULL;
    END IF;
    IF (l_rctv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_rctv_rec.attribute15 := NULL;
    END IF;
    IF (l_rctv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.request_id := NULL;
    END IF;
    IF (l_rctv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.program_application_id := NULL;
    END IF;
    IF (l_rctv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.program_id := NULL;
    END IF;
    IF (l_rctv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.program_update_date := NULL;
    END IF;
    IF (l_rctv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.org_id := NULL;
    END IF;
    IF (l_rctv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.created_by := NULL;
    END IF;
    IF (l_rctv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.creation_date := NULL;
    END IF;
    IF (l_rctv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rctv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_rctv_rec.last_update_date := NULL;
    END IF;
    IF (l_rctv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_rctv_rec.last_update_login := NULL;
    END IF;
-- New column receipt type added.
    IF (l_rctv_rec.receipt_type = Okl_Api.G_MISS_CHAR) THEN
          l_rctv_rec.receipt_type := NULL;
    END IF;
    IF (l_rctv_rec.cash_receipt_id = Okl_Api.G_MISS_NUM) THEN
          l_rctv_rec.cash_receipt_id := NULL;
    END IF;
    IF (l_rctv_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR) THEN
          l_rctv_rec.fully_applied_flag := NULL;
    END IF;
    IF (l_rctv_rec.expired_flag = Okl_Api.G_MISS_CHAR) THEN
          l_rctv_rec.expired_flag := NULL;
    END IF;

    RETURN(l_rctv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/17/2001
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

PROCEDURE validate_id(p_rctv_rec 		IN 	rctv_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_rctv_rec.id IS NULL) OR (p_rctv_rec.id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ID');
     RAISE G_EXCEPTION_HALT_VALIDATION;
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
-- Procedure Name  : validate_org_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_org_id (p_rctv_rec IN rctv_rec_type,

  			                 x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      x_return_status := Okl_Util.check_org_id(p_rctv_rec.org_id);

  END validate_org_id;

-- Start of comments
-- Procedure Name  : validate_btc_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_btc_id(p_rctv_rec 		IN 	rctv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_btc_id_csr IS
   SELECT '1'
   FROM   okl_trx_csh_batch_b
   WHERE  id = p_rctv_rec.btc_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

   --check FK Relation with okl_trx_csh_batch_b
  IF p_rctv_rec.btc_id IS NOT NULL THEN

   	  OPEN l_btc_id_csr;
   	  FETCH l_btc_id_csr INTO l_dummy_var;
   	  CLOSE l_btc_id_csr;
      IF (l_dummy_var<>'1') THEN

	  	 --Corresponding Column value not found
  	  	 x_return_status:= Okl_Api.G_RET_STS_ERROR;
    	 --set error message in message stack
     	 Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
         					 p_msg_name     => G_NO_PARENT_RECORD,
                        	 p_token1       => G_COL_NAME_TOKEN,
                        	 p_token1_value => 'BTC_ID',
                        	 p_token2       => G_CHILD_TABLE_TOKEN,
                     	   	 p_token2_value => G_VIEW,
                    		 p_token3       => G_PARENT_TABLE_TOKEN,
                   			 p_token3_value => 'OKL_TRX_CSH_BATCH_B');

							 RAISE G_EXCEPTION_HALT_VALIDATION;
  	  END IF;
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

END validate_btc_id;

-- Start of comments
-- Procedure Name  : validate_iba_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_iba_id(p_rctv_rec 		IN 	rctv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

/*   CURSOR l_iba_id_csr IS
   SELECT '1'
   FROM   okx_bnk_acts_v
   WHERE  id = p_rctv_rec.iba_id;  */  -- okx view not present

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_rctv_rec.iba_id IS NOT NULL THEN

   --   check FK Relation with okx_bnk_acts_v
   --   OPEN l_iba_id_csr;
   --   FETCH l_iba_id_csr INTO l_dummy_var;
   --   CLOSE l_iba_id_csr;

   		IF (l_dummy_var<>'1') THEN

		   --Corresponding Column value not found
  		   x_return_status:= Okl_Api.G_RET_STS_ERROR;
    	   --set error message in message stack
     	   Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_PARENT_RECORD,
                         	   p_token1       => G_COL_NAME_TOKEN,
                         	   p_token1_value => 'IBA_ID',
                         	   p_token2       => G_CHILD_TABLE_TOKEN,
                         	   p_token2_value => G_VIEW,
                         	   p_token3       => G_PARENT_TABLE_TOKEN,
                         	   p_token3_value => 'OKX_BNK_ACTS_V');

  		   RAISE G_EXCEPTION_HALT_VALIDATION;

  	    END IF;
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

END validate_iba_id;

-- Start of comments
-- Procedure Name  : validate_ile_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_ile_id(p_rctv_rec 		IN 	rctv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

 CURSOR l_ile_id_csr IS
 SELECT '1'
 FROM okx_customer_accounts_v
 WHERE id1 = p_rctv_rec.ile_id;

 l_dummy_var   VARCHAR2(1):='0';

 BEGIN

 x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
 IF p_rctv_rec.ile_id IS NOT NULL THEN

   --check FK Relation with okx_custmrs_v
   OPEN l_ile_id_csr;
   FETCH l_ile_id_csr INTO l_dummy_var;
   CLOSE l_ile_id_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ILE_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKX_CUSTOMER_ACCOUNTS_V');

  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

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

END validate_ile_id;

-- Start of comments
-- Procedure Name  : validate_irm_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_irm_id(p_rctv_rec 		IN 	rctv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_irm_id_csr IS
   SELECT '1'
   FROM   ar_receipt_methods
   WHERE  receipt_method_id = p_rctv_rec.irm_id; 		-- view does not exist

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_rctv_rec.irm_id IS NOT NULL THEN

   --check FK Relation with okx_receipt_methods_v
   OPEN l_irm_id_csr;
   FETCH l_irm_id_csr INTO l_dummy_var;
   CLOSE l_irm_id_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'IRM_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKX_RECEIPT_METHODS_V');

  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

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

END validate_irm_id;


-- Start of comments
-- Procedure Name  : validate_currency_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_currency_code (p_rctv_rec 		IN 	rctv_rec_type,
                          		  x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_currency_code_csr IS
   SELECT '1'
   FROM   fnd_currencies
   WHERE  currency_code = p_rctv_rec.currency_code;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN

  x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
  --check not null

/*
  IF p_rctv_rec.currency_code IS NULL OR
     p_rctv_rec.currency_code = Okl_Api.G_MISS_NUM THEN
        x_return_status:=Okl_Api.G_RET_STS_ERROR;
        --set error message in message stack
        Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'CURRENCY_CODE');
        RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
*/

   --check FK Relation with fnd_currencies
   OPEN l_currency_code_csr;
   FETCH l_currency_code_csr INTO l_dummy_var;
   CLOSE l_currency_code_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'CURRENCY_CODE',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'FND_CURRENCIES');

   RAISE G_EXCEPTION_HALT_VALIDATION;
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

END validate_currency_code;

  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_receipt_type
  -- Description     : The receipt type can hold only two values 'REG' or 'ADV'.
  -- Business Rules  :
  -- Parameters      : p_rctv_rec, x_return_status
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal created.
  -- End of comments
-------------------------------------------------------------------------------
PROCEDURE validate_receipt_type(p_rctv_rec 		IN 	rctv_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_rctv_rec.receipt_type  <> 'REG') AND  (p_rctv_rec.receipt_type  <> 'ADV')  THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_USER_MESSAGE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'RECEIPT TYPE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
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

  END validate_receipt_type;



/*FUNCTION IS_UNIQUE (p_rctv_rec rctv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_chr_csr IS
		 SELECT 'x'
		 FROM okl_trx_csh_receipt_b
		 WHERE check_number = p_rctv_rec.check_number
		 AND   ile_id = p_rctv_rec.ile_id
		 AND   id <> NVL(p_rctv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1) DEFAULT NULL;
    l_found             BOOLEAN;

  BEGIN
--check for unique ile_id and check_number
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_dummy;
	CLOSE l_chr_csr;

    IF (l_dummy = 'x') THEN

        l_return_status := Okl_Api.G_RET_STS_ERROR;

  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					        p_msg_name		=> 'ILE_ID and CHECK_NUMBER NOT UNIQUE',
					        p_token1		=> 'VALUE1',
					        p_token1_value	=> p_rctv_rec.ile_id,
					        p_token2		=> 'VALUE2',
					        p_token2_value	=> NVL(p_rctv_rec.check_number,' '));

	  -- notify caller of an error

      l_return_status := Okl_Api.G_RET_STS_ERROR;

    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;*/

  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/17/2001
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_CSH_RECEIPT_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rctv_rec IN  rctv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Added 04/16/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

    validate_id(p_rctv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_rctv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

/*
    validate_btc_id(p_rctv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
/*
    validate_iba_id(p_rctv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
    validate_ile_id(p_rctv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
/*
    validate_irm_id(p_rctv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
/*
    validate_currency_code(p_rctv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
-- end 04/17/2001 Bruno Vaghela ---

-- added 25-AUG-04 abindal --
	validate_receipt_type(p_rctv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
-- ended 25-AUG-04 abindal --


    IF p_rctv_rec.id = Okl_Api.G_MISS_NUM OR
       p_rctv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_rctv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_rctv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_rctv_rec.currency_code = Okl_Api.G_MISS_CHAR OR
          p_rctv_rec.currency_code IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_TRX_CSH_RECEIPT_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_rctv_rec IN rctv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    --l_return_status := IS_UNIQUE(p_rctv_rec);

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN rctv_rec_type,
    p_to	IN OUT NOCOPY rct_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.exchange_rate_type := p_from.exchange_rate_type;
    p_to.exchange_rate_date := p_from.exchange_rate_date;
    p_to.exchange_rate := p_from.exchange_rate;
    p_to.btc_id := p_from.btc_id;
    p_to.iba_id := p_from.iba_id;
    p_to.gl_date := p_from.gl_date;
    p_to.ile_id := p_from.ile_id;
    p_to.irm_id := p_from.irm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.check_number := p_from.check_number;
    p_to.amount := p_from.amount;
    p_to.date_effective := p_from.date_effective;
    p_to.rcpt_status_code := p_from.rcpt_status_code;
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
-- New column receipt type added.
    p_to.receipt_type := p_from.receipt_type;
    p_to.cash_receipt_id := p_from.cash_receipt_id;
    p_to.fully_applied_flag := p_from.fully_applied_flag;
    p_to.expired_flag := p_from.expired_flag;
  END migrate;
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN rct_rec_type,
    p_to	IN OUT NOCOPY rctv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.exchange_rate_type := p_from.exchange_rate_type;
    p_to.exchange_rate_date := p_from.exchange_rate_date;
    p_to.exchange_rate := p_from.exchange_rate;
    p_to.btc_id := p_from.btc_id;
    p_to.iba_id := p_from.iba_id;
    p_to.gl_date := p_from.gl_date;
    p_to.ile_id := p_from.ile_id;
    p_to.irm_id := p_from.irm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.check_number := p_from.check_number;
    p_to.amount := p_from.amount;
    p_to.date_effective := p_from.date_effective;
    p_to.rcpt_status_code := p_from.rcpt_status_code;
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
-- New column receipt type added.
     p_to.receipt_type := p_from.receipt_type;
     p_to.cash_receipt_id := p_from.cash_receipt_id;
     p_to.fully_applied_flag := p_from.fully_applied_flag;
     p_to.expired_flag := p_from.expired_flag;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rctv_rec_type,
    p_to	IN OUT NOCOPY OklTrxCshReceiptTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklTrxCshReceiptTlRecType,
    p_to	IN OUT NOCOPY rctv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
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
  --------------------------------------------
  -- validate_row for:OKL_TRX_CSH_RECEIPT_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rctv_rec                     rctv_rec_type := p_rctv_rec;
    l_rct_rec                      rct_rec_type;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
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
    l_return_status := Validate_Attributes(l_rctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rctv_rec);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:RCTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rctv_tbl.COUNT > 0) THEN
      i := p_rctv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rctv_rec                     => p_rctv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rctv_tbl.LAST);
        i := p_rctv_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_CSH_RECEIPT_B --
  ------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : insert_row
  -- Description     : Inserts the row in the table OKL_TRX_CSH_RECEIPT_B
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rct_rec, x_rct_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rct_rec                      IN rct_rec_type,
    x_rct_rec                      OUT NOCOPY rct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rct_rec                      rct_rec_type := p_rct_rec;
    l_def_rct_rec                  rct_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_B --
    ----------------------------------------------

    FUNCTION Set_Attributes (
      p_rct_rec IN  rct_rec_type,
      x_rct_rec OUT NOCOPY rct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rct_rec := p_rct_rec;
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
      p_rct_rec,                         -- IN
      l_rct_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_CSH_RECEIPT_B(
        id,
        currency_code,
        exchange_rate_type,
        exchange_rate_date,
        exchange_rate,
        btc_id,
        iba_id,
        gl_date,
        ile_id,
        irm_id,
        object_version_number,
        check_number,
        amount,
        date_effective,
        rcpt_status_code,
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
-- New column receipt type added.
     	receipt_type,
	cash_receipt_id,
	fully_applied_flag,
	expired_flag)
      VALUES (
        l_rct_rec.id,
        l_rct_rec.currency_code,
        l_rct_rec.exchange_rate_type,
        l_rct_rec.exchange_rate_date,
        l_rct_rec.exchange_rate,
        l_rct_rec.btc_id,
        l_rct_rec.iba_id,
        l_rct_rec.gl_date,
        l_rct_rec.ile_id,
        l_rct_rec.irm_id,
        l_rct_rec.object_version_number,
        l_rct_rec.check_number,
        l_rct_rec.amount,
        l_rct_rec.date_effective,
        l_rct_rec.rcpt_status_code,
        l_rct_rec.request_id,
        l_rct_rec.program_application_id,
        l_rct_rec.program_id,
        l_rct_rec.program_update_date,
        l_rct_rec.org_id,
        l_rct_rec.attribute_category,
        l_rct_rec.attribute1,
        l_rct_rec.attribute2,
        l_rct_rec.attribute3,
        l_rct_rec.attribute4,
        l_rct_rec.attribute5,
        l_rct_rec.attribute6,
        l_rct_rec.attribute7,
        l_rct_rec.attribute8,
        l_rct_rec.attribute9,
        l_rct_rec.attribute10,
        l_rct_rec.attribute11,
        l_rct_rec.attribute12,
        l_rct_rec.attribute13,
        l_rct_rec.attribute14,
        l_rct_rec.attribute15,
        l_rct_rec.created_by,
        l_rct_rec.creation_date,
        l_rct_rec.last_updated_by,
        l_rct_rec.last_update_date,
        l_rct_rec.last_update_login,
-- New column receipt type added.
    	l_rct_rec.receipt_type,
	l_rct_rec.cash_receipt_id,
	l_rct_rec.fully_applied_flag,
	l_rct_rec.expired_flag);
    -- Set OUT values
    x_rct_rec := l_rct_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------------
  -- insert_row for:OKL_TRX_CSH_RECEIPT_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType,
    x_okl_trx_csh_receipt_tl_rec   OUT NOCOPY OklTrxCshReceiptTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType := p_okl_trx_csh_receipt_tl_rec;
    ldefokltrxcshreceipttlrec      OklTrxCshReceiptTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_receipt_tl_rec IN  OklTrxCshReceiptTlRecType,
      x_okl_trx_csh_receipt_tl_rec OUT NOCOPY OklTrxCshReceiptTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_receipt_tl_rec := p_okl_trx_csh_receipt_tl_rec;
      x_okl_trx_csh_receipt_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_csh_receipt_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_csh_receipt_tl_rec,      -- IN
      l_okl_trx_csh_receipt_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_csh_receipt_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_CSH_RECEIPT_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_trx_csh_receipt_tl_rec.id,
          l_okl_trx_csh_receipt_tl_rec.LANGUAGE,
          l_okl_trx_csh_receipt_tl_rec.source_lang,
          l_okl_trx_csh_receipt_tl_rec.sfwt_flag,
          l_okl_trx_csh_receipt_tl_rec.description,
          l_okl_trx_csh_receipt_tl_rec.created_by,
          l_okl_trx_csh_receipt_tl_rec.creation_date,
          l_okl_trx_csh_receipt_tl_rec.last_updated_by,
          l_okl_trx_csh_receipt_tl_rec.last_update_date,
          l_okl_trx_csh_receipt_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_csh_receipt_tl_rec := l_okl_trx_csh_receipt_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_CSH_RECEIPT_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type,
    x_rctv_rec                     OUT NOCOPY rctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rctv_rec                     rctv_rec_type;
    l_def_rctv_rec                 rctv_rec_type;
    l_rct_rec                      rct_rec_type;
    lx_rct_rec                     rct_rec_type;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
    lx_okl_trx_csh_receipt_tl_rec  OklTrxCshReceiptTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rctv_rec	IN rctv_rec_type
    ) RETURN rctv_rec_type IS
      l_rctv_rec	rctv_rec_type := p_rctv_rec;
    BEGIN
	  l_rctv_rec.CREATION_DATE := SYSDATE;
      l_rctv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_rctv_rec.LAST_UPDATE_DATE := l_rctv_rec.CREATION_DATE;
      l_rctv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_rctv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_rctv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rctv_rec IN  rctv_rec_type,
      x_rctv_rec OUT NOCOPY rctv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rctv_rec := p_rctv_rec;
      x_rctv_rec.OBJECT_VERSION_NUMBER := 1;
      x_rctv_rec.SFWT_FLAG := 'N';
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

    l_rctv_rec := null_out_defaults(p_rctv_rec);
    -- Set primary key value
    l_rctv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rctv_rec,                        -- IN
      l_def_rctv_rec);                   -- OUT
    --- If any errors happen abort API

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_rctv_rec := fill_who_columns(l_def_rctv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rctv_rec);  -- ?
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rctv_rec, l_rct_rec);
    migrate(l_def_rctv_rec, l_okl_trx_csh_receipt_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rct_rec,
      lx_rct_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rct_rec, l_def_rctv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_receipt_tl_rec,
      lx_okl_trx_csh_receipt_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_csh_receipt_tl_rec, l_def_rctv_rec);
    -- Set OUT values
    x_rctv_rec := l_def_rctv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:RCTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type,
    x_rctv_tbl                     OUT NOCOPY rctv_tbl_type) IS

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
    IF (p_rctv_tbl.COUNT > 0) THEN
      i := p_rctv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rctv_rec                     => p_rctv_tbl(i),
          x_rctv_rec                     => x_rctv_tbl(i));
		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rctv_tbl.LAST);
        i := p_rctv_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_CSH_RECEIPT_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rct_rec                      IN rct_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rct_rec IN rct_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CSH_RECEIPT_B
     WHERE ID = p_rct_rec.id
       AND OBJECT_VERSION_NUMBER = p_rct_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rct_rec IN rct_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CSH_RECEIPT_B
    WHERE ID = p_rct_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_CSH_RECEIPT_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_CSH_RECEIPT_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rct_rec);
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
      OPEN lchk_csr(p_rct_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rct_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rct_rec.object_version_number THEN
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -----------------------------------------
  -- lock_row for:OKL_TRX_CSH_RECEIPT_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_csh_receipt_tl_rec IN OklTrxCshReceiptTlRecType) IS
    SELECT *
      FROM OKL_TRX_CSH_RECEIPT_TL
     WHERE ID = p_okl_trx_csh_receipt_tl_rec.id
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
      OPEN lock_csr(p_okl_trx_csh_receipt_tl_rec);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_CSH_RECEIPT_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rct_rec                      rct_rec_type;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
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
    migrate(p_rctv_rec, l_rct_rec);
    migrate(p_rctv_rec, l_okl_trx_csh_receipt_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rct_rec
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
      l_okl_trx_csh_receipt_tl_rec
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:RCTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type) IS

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
    IF (p_rctv_tbl.COUNT > 0) THEN
      i := p_rctv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rctv_rec                     => p_rctv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rctv_tbl.LAST);
        i := p_rctv_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- update_row for:OKL_TRX_CSH_RECEIPT_B --
  ------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Updates the row in the table OKL_TRX_CSH_RECEIPT_B
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rct_rec, x_rct_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rct_rec                      IN rct_rec_type,
    x_rct_rec                      OUT NOCOPY rct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rct_rec                      rct_rec_type := p_rct_rec;
    l_def_rct_rec                  rct_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_rct_rec	IN rct_rec_type,
      x_rct_rec	OUT NOCOPY rct_rec_type
    ) RETURN VARCHAR2 IS
      l_rct_rec                      rct_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rct_rec := p_rct_rec;
      -- Get current database values
      l_rct_rec := get_rec(p_rct_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rct_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.id := l_rct_rec.id;
      END IF;
      IF (x_rct_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.currency_code := l_rct_rec.currency_code;
      END IF;
      IF (x_rct_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.exchange_rate_type := l_rct_rec.exchange_rate_type;
      END IF;
      IF (x_rct_rec.exchange_rate_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.exchange_rate_date := l_rct_rec.exchange_rate_date;
      END IF;
      IF (x_rct_rec.exchange_rate = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.exchange_rate := l_rct_rec.exchange_rate;
      END IF;
      IF (x_rct_rec.btc_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.btc_id := l_rct_rec.btc_id;
      END IF;
      IF (x_rct_rec.iba_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.iba_id := l_rct_rec.iba_id;
      END IF;
      IF (x_rct_rec.gl_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.gl_date := l_rct_rec.gl_date;
      END IF;
      IF (x_rct_rec.ile_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.ile_id := l_rct_rec.ile_id;
      END IF;
      IF (x_rct_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.irm_id := l_rct_rec.irm_id;
      END IF;
      IF (x_rct_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.object_version_number := l_rct_rec.object_version_number;
      END IF;
      IF (x_rct_rec.check_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.check_number := l_rct_rec.check_number;
      END IF;
      IF (x_rct_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.amount := l_rct_rec.amount;
      END IF;
      IF (x_rct_rec.date_effective = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.date_effective := l_rct_rec.date_effective;
      END IF;
      IF (x_rct_rec.rcpt_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.rcpt_status_code := l_rct_rec.rcpt_status_code;
      END IF;
      IF (x_rct_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.request_id := l_rct_rec.request_id;
      END IF;
      IF (x_rct_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.program_application_id := l_rct_rec.program_application_id;
      END IF;
      IF (x_rct_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.program_id := l_rct_rec.program_id;
      END IF;
      IF (x_rct_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.program_update_date := l_rct_rec.program_update_date;
      END IF;
      IF (x_rct_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.org_id := l_rct_rec.org_id;
      END IF;
      IF (x_rct_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute_category := l_rct_rec.attribute_category;
      END IF;
      IF (x_rct_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute1 := l_rct_rec.attribute1;
      END IF;
      IF (x_rct_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute2 := l_rct_rec.attribute2;
      END IF;
      IF (x_rct_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute3 := l_rct_rec.attribute3;
      END IF;
      IF (x_rct_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute4 := l_rct_rec.attribute4;
      END IF;
      IF (x_rct_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute5 := l_rct_rec.attribute5;
      END IF;
      IF (x_rct_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute6 := l_rct_rec.attribute6;
      END IF;
      IF (x_rct_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute7 := l_rct_rec.attribute7;
      END IF;
      IF (x_rct_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute8 := l_rct_rec.attribute8;
      END IF;
      IF (x_rct_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute9 := l_rct_rec.attribute9;
      END IF;
      IF (x_rct_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute10 := l_rct_rec.attribute10;
      END IF;
      IF (x_rct_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute11 := l_rct_rec.attribute11;
      END IF;
      IF (x_rct_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute12 := l_rct_rec.attribute12;
      END IF;
      IF (x_rct_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute13 := l_rct_rec.attribute13;
      END IF;
      IF (x_rct_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute14 := l_rct_rec.attribute14;
      END IF;
      IF (x_rct_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.attribute15 := l_rct_rec.attribute15;
      END IF;
      IF (x_rct_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.created_by := l_rct_rec.created_by;
      END IF;
      IF (x_rct_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.creation_date := l_rct_rec.creation_date;
      END IF;
      IF (x_rct_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.last_updated_by := l_rct_rec.last_updated_by;
      END IF;
      IF (x_rct_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rct_rec.last_update_date := l_rct_rec.last_update_date;
      END IF;
      IF (x_rct_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.last_update_login := l_rct_rec.last_update_login;
      END IF;
-- New column receipt type added.
      IF (x_rct_rec.receipt_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.receipt_type := l_rct_rec.receipt_type;
      END IF;
      IF (x_rct_rec.cash_receipt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rct_rec.cash_receipt_id := l_rct_rec.cash_receipt_id;
      END IF;
      IF (x_rct_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.fully_applied_flag := l_rct_rec.fully_applied_flag;
      END IF;
      IF (x_rct_rec.expired_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rct_rec.expired_flag := l_rct_rec.expired_flag;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_B --
    ----------------------------------------------

    FUNCTION Set_Attributes (
      p_rct_rec IN  rct_rec_type,
      x_rct_rec OUT NOCOPY rct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rct_rec := p_rct_rec;
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
      p_rct_rec,                         -- IN
      l_rct_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rct_rec, l_def_rct_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_CSH_RECEIPT_B
    SET CURRENCY_CODE = l_def_rct_rec.currency_code,
        EXCHANGE_RATE_TYPE = l_def_rct_rec.exchange_rate_type,
        EXCHANGE_RATE_DATE = l_def_rct_rec.exchange_rate_date,
        EXCHANGE_RATE = l_def_rct_rec.exchange_rate,
        BTC_ID = l_def_rct_rec.btc_id,
        IBA_ID = l_def_rct_rec.iba_id,
        GL_DATE = l_def_rct_rec.gl_date,
        ILE_ID = l_def_rct_rec.ile_id,
        IRM_ID = l_def_rct_rec.irm_id,
        OBJECT_VERSION_NUMBER = l_def_rct_rec.object_version_number,
        CHECK_NUMBER = l_def_rct_rec.check_number,
        AMOUNT = l_def_rct_rec.amount,
        DATE_EFFECTIVE = l_def_rct_rec.date_effective,
        RCPT_STATUS_CODE = l_def_rct_rec.rcpt_status_code,
        REQUEST_ID = l_def_rct_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_rct_rec.program_application_id,
        PROGRAM_ID = l_def_rct_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_rct_rec.program_update_date,
        ORG_ID = l_def_rct_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_rct_rec.attribute_category,
        ATTRIBUTE1 = l_def_rct_rec.attribute1,
        ATTRIBUTE2 = l_def_rct_rec.attribute2,
        ATTRIBUTE3 = l_def_rct_rec.attribute3,
        ATTRIBUTE4 = l_def_rct_rec.attribute4,
        ATTRIBUTE5 = l_def_rct_rec.attribute5,
        ATTRIBUTE6 = l_def_rct_rec.attribute6,
        ATTRIBUTE7 = l_def_rct_rec.attribute7,
        ATTRIBUTE8 = l_def_rct_rec.attribute8,
        ATTRIBUTE9 = l_def_rct_rec.attribute9,
        ATTRIBUTE10 = l_def_rct_rec.attribute10,
        ATTRIBUTE11 = l_def_rct_rec.attribute11,
        ATTRIBUTE12 = l_def_rct_rec.attribute12,
        ATTRIBUTE13 = l_def_rct_rec.attribute13,
        ATTRIBUTE14 = l_def_rct_rec.attribute14,
        ATTRIBUTE15 = l_def_rct_rec.attribute15,
        CREATED_BY = l_def_rct_rec.created_by,
        CREATION_DATE = l_def_rct_rec.creation_date,
        LAST_UPDATED_BY = l_def_rct_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rct_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rct_rec.last_update_login,
-- New column receipt type added.
        RECEIPT_TYPE = l_def_rct_rec.receipt_type,
	CASH_RECEIPT_ID = l_def_rct_rec.cash_receipt_id,
	FULLY_APPLIED_FLAG = l_def_rct_rec.fully_applied_flag,
	EXPIRED_FLAG = l_def_rct_rec.expired_flag
    WHERE ID = l_def_rct_rec.id;

    x_rct_rec := l_def_rct_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------------
  -- update_row for:OKL_TRX_CSH_RECEIPT_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType,
    x_okl_trx_csh_receipt_tl_rec   OUT NOCOPY OklTrxCshReceiptTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType := p_okl_trx_csh_receipt_tl_rec;
    ldefokltrxcshreceipttlrec      OklTrxCshReceiptTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_csh_receipt_tl_rec	IN OklTrxCshReceiptTlRecType,
      x_okl_trx_csh_receipt_tl_rec	OUT NOCOPY OklTrxCshReceiptTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_receipt_tl_rec := p_okl_trx_csh_receipt_tl_rec;
      -- Get current database values
      l_okl_trx_csh_receipt_tl_rec := get_rec(p_okl_trx_csh_receipt_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_receipt_tl_rec.id := l_okl_trx_csh_receipt_tl_rec.id;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_receipt_tl_rec.LANGUAGE := l_okl_trx_csh_receipt_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_receipt_tl_rec.source_lang := l_okl_trx_csh_receipt_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_receipt_tl_rec.sfwt_flag := l_okl_trx_csh_receipt_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_csh_receipt_tl_rec.description := l_okl_trx_csh_receipt_tl_rec.description;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_receipt_tl_rec.created_by := l_okl_trx_csh_receipt_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_csh_receipt_tl_rec.creation_date := l_okl_trx_csh_receipt_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_receipt_tl_rec.last_updated_by := l_okl_trx_csh_receipt_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_csh_receipt_tl_rec.last_update_date := l_okl_trx_csh_receipt_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_csh_receipt_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_csh_receipt_tl_rec.last_update_login := l_okl_trx_csh_receipt_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_receipt_tl_rec IN  OklTrxCshReceiptTlRecType,
      x_okl_trx_csh_receipt_tl_rec OUT NOCOPY OklTrxCshReceiptTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_receipt_tl_rec := p_okl_trx_csh_receipt_tl_rec;
      x_okl_trx_csh_receipt_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_csh_receipt_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_csh_receipt_tl_rec,      -- IN
      l_okl_trx_csh_receipt_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_csh_receipt_tl_rec, ldefokltrxcshreceipttlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_CSH_RECEIPT_TL
    SET DESCRIPTION = ldefokltrxcshreceipttlrec.description,
        SOURCE_LANG = ldefokltrxcshreceipttlrec.source_lang,
        CREATED_BY = ldefokltrxcshreceipttlrec.created_by,
        CREATION_DATE = ldefokltrxcshreceipttlrec.creation_date,
        LAST_UPDATED_BY = ldefokltrxcshreceipttlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltrxcshreceipttlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltrxcshreceipttlrec.last_update_login
    WHERE ID = ldefokltrxcshreceipttlrec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TRX_CSH_RECEIPT_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltrxcshreceipttlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_csh_receipt_tl_rec := ldefokltrxcshreceipttlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- update_row for:OKL_TRX_CSH_RECEIPT_V --
  ------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Updates the row in the table OKL_TRX_CSH_RECEIPT_B
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rctv_rec, x_rctv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     receipt type.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type,
    x_rctv_rec                     OUT NOCOPY rctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rctv_rec                     rctv_rec_type := p_rctv_rec;
    l_def_rctv_rec                 rctv_rec_type;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
    lx_okl_trx_csh_receipt_tl_rec  OklTrxCshReceiptTlRecType;
    l_rct_rec                      rct_rec_type;
    lx_rct_rec                     rct_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rctv_rec	IN rctv_rec_type
    ) RETURN rctv_rec_type IS
      l_rctv_rec	rctv_rec_type := p_rctv_rec;
    BEGIN
      l_rctv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rctv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_rctv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_rctv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_rctv_rec	IN rctv_rec_type,
      x_rctv_rec	OUT NOCOPY rctv_rec_type
    ) RETURN VARCHAR2 IS
      l_rctv_rec                     rctv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rctv_rec := p_rctv_rec;
      -- Get current database values
      l_rctv_rec := get_rec(p_rctv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rctv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.id := l_rctv_rec.id;
      END IF;
      IF (x_rctv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.object_version_number := l_rctv_rec.object_version_number;
      END IF;
      IF (x_rctv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.sfwt_flag := l_rctv_rec.sfwt_flag;
      END IF;
      IF (x_rctv_rec.btc_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.btc_id := l_rctv_rec.btc_id;
      END IF;
      IF (x_rctv_rec.iba_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.iba_id := l_rctv_rec.iba_id;
      END IF;
      IF (x_rctv_rec.gl_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.gl_date := l_rctv_rec.gl_date;
      END IF;
      IF (x_rctv_rec.ile_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.ile_id := l_rctv_rec.ile_id;
      END IF;
      IF (x_rctv_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.irm_id := l_rctv_rec.irm_id;
      END IF;
      IF (x_rctv_rec.check_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.check_number := l_rctv_rec.check_number;
      END IF;
      IF (x_rctv_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.currency_code := l_rctv_rec.currency_code;
      END IF;
      IF (x_rctv_rec.exchange_rate_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.exchange_rate_type := l_rctv_rec.exchange_rate_type;
      END IF;
      IF (x_rctv_rec.exchange_rate_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.exchange_rate_date := l_rctv_rec.exchange_rate_date;
      END IF;
      IF (x_rctv_rec.exchange_rate = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.exchange_rate := l_rctv_rec.exchange_rate;
      END IF;
      IF (x_rctv_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.amount := l_rctv_rec.amount;
      END IF;
      IF (x_rctv_rec.date_effective = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.date_effective := l_rctv_rec.date_effective;
      END IF;
      IF (x_rctv_rec.rcpt_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.rcpt_status_code := l_rctv_rec.rcpt_status_code;
      END IF;
      IF (x_rctv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.description := l_rctv_rec.description;
      END IF;
      IF (x_rctv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute_category := l_rctv_rec.attribute_category;
      END IF;
      IF (x_rctv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute1 := l_rctv_rec.attribute1;
      END IF;
      IF (x_rctv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute2 := l_rctv_rec.attribute2;
      END IF;
      IF (x_rctv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute3 := l_rctv_rec.attribute3;
      END IF;
      IF (x_rctv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute4 := l_rctv_rec.attribute4;
      END IF;
      IF (x_rctv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute5 := l_rctv_rec.attribute5;
      END IF;
      IF (x_rctv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute6 := l_rctv_rec.attribute6;
      END IF;
      IF (x_rctv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute7 := l_rctv_rec.attribute7;
      END IF;
      IF (x_rctv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute8 := l_rctv_rec.attribute8;
      END IF;
      IF (x_rctv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute9 := l_rctv_rec.attribute9;
      END IF;
      IF (x_rctv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute10 := l_rctv_rec.attribute10;
      END IF;
      IF (x_rctv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute11 := l_rctv_rec.attribute11;
      END IF;
      IF (x_rctv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute12 := l_rctv_rec.attribute12;
      END IF;
      IF (x_rctv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute13 := l_rctv_rec.attribute13;
      END IF;
      IF (x_rctv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute14 := l_rctv_rec.attribute14;
      END IF;
      IF (x_rctv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.attribute15 := l_rctv_rec.attribute15;
      END IF;
      IF (x_rctv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.request_id := l_rctv_rec.request_id;
      END IF;
      IF (x_rctv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.program_application_id := l_rctv_rec.program_application_id;
      END IF;
      IF (x_rctv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.program_id := l_rctv_rec.program_id;
      END IF;
      IF (x_rctv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.program_update_date := l_rctv_rec.program_update_date;
      END IF;
      IF (x_rctv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.org_id := l_rctv_rec.org_id;
      END IF;
      IF (x_rctv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.created_by := l_rctv_rec.created_by;
      END IF;
      IF (x_rctv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.creation_date := l_rctv_rec.creation_date;
      END IF;
      IF (x_rctv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.last_updated_by := l_rctv_rec.last_updated_by;
      END IF;
      IF (x_rctv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rctv_rec.last_update_date := l_rctv_rec.last_update_date;
      END IF;
      IF (x_rctv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.last_update_login := l_rctv_rec.last_update_login;
      END IF;
-- New column receipt type added.
      IF (x_rctv_rec.receipt_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.receipt_type := l_rctv_rec.receipt_type;
      END IF;
      IF (x_rctv_rec.cash_receipt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rctv_rec.cash_receipt_id := l_rctv_rec.cash_receipt_id;
      END IF;
      IF (x_rctv_rec.fully_applied_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.fully_applied_flag := l_rctv_rec.fully_applied_flag;
      END IF;
      IF (x_rctv_rec.expired_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rctv_rec.expired_flag := l_rctv_rec.expired_flag;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rctv_rec IN  rctv_rec_type,
      x_rctv_rec OUT NOCOPY rctv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rctv_rec := p_rctv_rec;
      x_rctv_rec.OBJECT_VERSION_NUMBER := NVL(x_rctv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rctv_rec,                        -- IN
      l_rctv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rctv_rec, l_def_rctv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_rctv_rec := fill_who_columns(l_def_rctv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rctv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rctv_rec, l_okl_trx_csh_receipt_tl_rec);
    migrate(l_def_rctv_rec, l_rct_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_receipt_tl_rec,
      lx_okl_trx_csh_receipt_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_csh_receipt_tl_rec, l_def_rctv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rct_rec,
      lx_rct_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rct_rec, l_def_rctv_rec);
    x_rctv_rec := l_def_rctv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:RCTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type,
    x_rctv_tbl                     OUT NOCOPY rctv_tbl_type) IS

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
    IF (p_rctv_tbl.COUNT > 0) THEN
      i := p_rctv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rctv_rec                     => p_rctv_tbl(i),
          x_rctv_rec                     => x_rctv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rctv_tbl.LAST);
        i := p_rctv_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- delete_row for:OKL_TRX_CSH_RECEIPT_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rct_rec                      IN rct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rct_rec                      rct_rec_type:= p_rct_rec;
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
    DELETE FROM OKL_TRX_CSH_RECEIPT_B
     WHERE ID = l_rct_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------------
  -- delete_row for:OKL_TRX_CSH_RECEIPT_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_csh_receipt_tl_rec   IN OklTrxCshReceiptTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType:= p_okl_trx_csh_receipt_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_CSH_RECEIPT_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_csh_receipt_tl_rec IN  OklTrxCshReceiptTlRecType,
      x_okl_trx_csh_receipt_tl_rec OUT NOCOPY OklTrxCshReceiptTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_csh_receipt_tl_rec := p_okl_trx_csh_receipt_tl_rec;
      x_okl_trx_csh_receipt_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_trx_csh_receipt_tl_rec,      -- IN
      l_okl_trx_csh_receipt_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_CSH_RECEIPT_TL
     WHERE ID = l_okl_trx_csh_receipt_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- delete_row for:OKL_TRX_CSH_RECEIPT_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_rec                     IN rctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rctv_rec                     rctv_rec_type := p_rctv_rec;
    l_okl_trx_csh_receipt_tl_rec   OklTrxCshReceiptTlRecType;
    l_rct_rec                      rct_rec_type;
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
    migrate(l_rctv_rec, l_okl_trx_csh_receipt_tl_rec);
    migrate(l_rctv_rec, l_rct_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_csh_receipt_tl_rec
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
      l_rct_rec
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:RCTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rctv_tbl                     IN rctv_tbl_type) IS

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
    IF (p_rctv_tbl.COUNT > 0) THEN
      i := p_rctv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rctv_rec                     => p_rctv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rctv_tbl.LAST);
        i := p_rctv_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
END Okl_Rct_Pvt;

/
