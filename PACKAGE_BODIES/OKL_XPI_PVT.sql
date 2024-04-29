--------------------------------------------------------
--  DDL for Package Body OKL_XPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XPI_PVT" AS
/* $Header: OKLSXPIB.pls 120.5 2007/08/08 12:57:08 arajagop noship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages and Variables                 = Done Msg=5; Var=3
  -- BODY:
  -- 0. Check for Not Null Columns                    = Done 3, n/a:sfwt_flag
  -- 1. Check for Not Null Primary Keys               = Done 1
  -- 2. Check for Not Null Foreign Keys               = N/A, No Foreign Keys
  -- 3. Validity of Foreign Keys                      = N/A, No Foreign Keys
  -- 4. Validity of Unique Keys                       = N/A, No Unique Keys
  -- 5. Validity of Org_id                            = Done
  -- 6. Added domain validation                       = Done yn=1
  -- 7. Added the Concurrent Manager Columns (p104)   = Done 2 (for insert, update view)
  -- 8. Validate fnd_lookup code using OKL_UTIL pkg   = N/A, No FK to fnd_lookups
  -- 9. Capture most severe error in loops (p103)     = Done 5 loops (except l_lang_rec)
  --10. Reduce use of SYSDATE fill_who_columns (p104) = Done 1 (for insert)
  --11. Fix Migrate Parameter p_to IN OUT (p104)      = Done 4
  --12. Call validate procs. in Validate_Attributes   = Done 5
  --06/01/00: Post postgen changes:
  --14. Added 1 new column: TRX_STATUS_CODE + support,validations
  --15. 02/04/02: Added new columns vendor_invoice_number, pay_group_lookup_code, nettable_yn.
  --16. Added New column : Legal entity Id : 30-OCT-2006 ANSETHUR  R12B - Legal Entity
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id - PostGen-1
  ---------------------------------------------------------------------------
  PROCEDURE validate_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xpiv_rec.id IS NULL) OR (p_xpiv_rec.id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xpiv_rec.object_version_number IS NULL)
       OR (p_xpiv_rec.object_version_number = OKL_Api.G_MISS_NUM) THEN

          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'object_version_number'
                ) ;

          x_return_status := OKL_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_invoice_id - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_invoice_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xpiv_rec.invoice_id IS NULL) OR (p_xpiv_rec.invoice_id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'invoice_id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_invoice_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id - PostGen-5
  ---------------------------------------------------------------------------
  PROCEDURE validate_org_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xpiv_rec.org_id IS NULL) OR (p_xpiv_rec.org_id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'org_id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSE

      x_return_status := OKL_UTIL.CHECK_ORG_ID(p_xpiv_rec.org_id);

      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'org_id'
               ) ;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_wait_vend_inv_yn - PostGen-6
  ---------------------------------------------------------------------------
  PROCEDURE validate_wait_vend_inv_yn
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xpiv_rec.wait_vendor_invoice_yn IS NOT NULL) THEN

      x_return_status := OKL_UTIL.CHECK_DOMAIN_YN(p_xpiv_rec.wait_vendor_invoice_yn);

      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'wait_vendor_invoice_yn'
               ) ;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_wait_vend_inv_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_trx_status_code - Post postgen 14
  ---------------------------------------------------------------------------
  PROCEDURE validate_trx_status_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF (p_xpiv_rec.trx_status_code IS NULL)
    OR (p_xpiv_rec.trx_status_code  = OKL_Api.G_MISS_CHAR)
    THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_required_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'trx_status_code'
             ) ;
       x_return_status := OKL_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                       ( 'OKL_TRANSACTION_STATUS'
                       , p_xpiv_rec.trx_status_code
                       );

    IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_invalid_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'trx_status_code'
             ) ;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_trx_status_code;

 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity --- Start changes
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_le_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_le_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xpiv_rec               IN        xpiv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

   IF (p_xpiv_rec.legal_entity_id IS NULL)
    OR (p_xpiv_rec.legal_entity_id  = OKL_Api.G_MISS_NUM)
    THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_required_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'legal_entity_id'
             ) ;
       x_return_status := OKL_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
         l_return_status := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists
                         ( p_xpiv_rec.legal_entity_id);

         IF l_return_status = 1 then
           x_return_status := OKL_Api.G_RET_STS_SUCCESS;
         ELSE
           x_return_status := OKL_Api.G_RET_STS_ERROR;
         END IF;

         IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
            OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'legal_entity_id' ) ;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;
    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error
  END validate_le_id;

 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity --- End changes
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(OKC_p_util.raw_to_number(sys_guid()));
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
    DELETE FROM OKL_EXT_PAY_INVS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_PAY_INVS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_EXT_PAY_INVS_TL T SET (
        DESCRIPTION,
        SOURCE,
        STREAM_TYPE) = (SELECT
                                  B.DESCRIPTION,
                                  B.SOURCE,
                                  B.STREAM_TYPE
                                FROM OKL_EXT_PAY_INVS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_EXT_PAY_INVS_TL SUBB, OKL_EXT_PAY_INVS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.SOURCE <> SUBT.SOURCE
                      OR SUBB.STREAM_TYPE <> SUBT.STREAM_TYPE
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.SOURCE IS NULL AND SUBT.SOURCE IS NOT NULL)
                      OR (SUBB.SOURCE IS NOT NULL AND SUBT.SOURCE IS NULL)
                      OR (SUBB.STREAM_TYPE IS NULL AND SUBT.STREAM_TYPE IS NOT NULL)
                      OR (SUBB.STREAM_TYPE IS NOT NULL AND SUBT.STREAM_TYPE IS NULL)
              ));

    INSERT INTO OKL_EXT_PAY_INVS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        SOURCE,
        STREAM_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
        )
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.SOURCE,
            B.STREAM_TYPE,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_EXT_PAY_INVS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_EXT_PAY_INVS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_PAY_INVS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xpi_rec                      IN xpi_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xpi_rec_type IS
    CURSOR xpi_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TRX_STATUS_CODE,
            INVOICE_ID,
            OBJECT_VERSION_NUMBER,
            INVOICE_NUM,
            INVOICE_TYPE,
            INVOICE_DATE,
            VENDOR_ID,
            VENDOR_SITE_ID,
            INVOICE_AMOUNT,
            INVOICE_CURRENCY_CODE,
            TERMS_ID,
            WORKFLOW_FLAG,
            DOC_CATEGORY_CODE,
            PAYMENT_METHOD,
            GL_DATE,
            ACCTS_PAY_CC_ID,
            PAY_ALONE_FLAG,
            WAIT_VENDOR_INVOICE_YN,
            PAYABLES_INVOICE_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
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
            pay_group_lookup_code,
            vendor_invoice_number,
            nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
            legal_entity_id,
            CNSLD_AP_INV_ID
      FROM Okl_Ext_Pay_Invs_B
     WHERE okl_ext_pay_invs_b.id = p_id;
    l_xpi_pk                       xpi_pk_csr%ROWTYPE;
    l_xpi_rec                      xpi_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN xpi_pk_csr (p_xpi_rec.id);
    FETCH xpi_pk_csr INTO
              l_xpi_rec.ID,
              l_xpi_rec.TRX_STATUS_CODE,
              l_xpi_rec.INVOICE_ID,
              l_xpi_rec.OBJECT_VERSION_NUMBER,
              l_xpi_rec.INVOICE_NUM,
              l_xpi_rec.INVOICE_TYPE,
              l_xpi_rec.INVOICE_DATE,
              l_xpi_rec.VENDOR_ID,
              l_xpi_rec.VENDOR_SITE_ID,
              l_xpi_rec.INVOICE_AMOUNT,
              l_xpi_rec.INVOICE_CURRENCY_CODE,
              l_xpi_rec.TERMS_ID,
              l_xpi_rec.WORKFLOW_FLAG,
              l_xpi_rec.DOC_CATEGORY_CODE,
              l_xpi_rec.PAYMENT_METHOD,
              l_xpi_rec.GL_DATE,
              l_xpi_rec.ACCTS_PAY_CC_ID,
              l_xpi_rec.PAY_ALONE_FLAG,
              l_xpi_rec.WAIT_VENDOR_INVOICE_YN,
              l_xpi_rec.PAYABLES_INVOICE_ID,
              l_xpi_rec.REQUEST_ID,
              l_xpi_rec.PROGRAM_APPLICATION_ID,
              l_xpi_rec.PROGRAM_ID,
              l_xpi_rec.PROGRAM_UPDATE_DATE,
              l_xpi_rec.ORG_ID,
              l_xpi_rec.CURRENCY_CONVERSION_TYPE,
              l_xpi_rec.CURRENCY_CONVERSION_RATE,
              l_xpi_rec.CURRENCY_CONVERSION_DATE,
              l_xpi_rec.ATTRIBUTE_CATEGORY,
              l_xpi_rec.ATTRIBUTE1,
              l_xpi_rec.ATTRIBUTE2,
              l_xpi_rec.ATTRIBUTE3,
              l_xpi_rec.ATTRIBUTE4,
              l_xpi_rec.ATTRIBUTE5,
              l_xpi_rec.ATTRIBUTE6,
              l_xpi_rec.ATTRIBUTE7,
              l_xpi_rec.ATTRIBUTE8,
              l_xpi_rec.ATTRIBUTE9,
              l_xpi_rec.ATTRIBUTE10,
              l_xpi_rec.ATTRIBUTE11,
              l_xpi_rec.ATTRIBUTE12,
              l_xpi_rec.ATTRIBUTE13,
              l_xpi_rec.ATTRIBUTE14,
              l_xpi_rec.ATTRIBUTE15,
              l_xpi_rec.CREATED_BY,
              l_xpi_rec.CREATION_DATE,
              l_xpi_rec.LAST_UPDATED_BY,
              l_xpi_rec.LAST_UPDATE_DATE,
              l_xpi_rec.LAST_UPDATE_LOGIN,
              l_xpi_rec.pay_group_lookup_code,
              l_xpi_rec.vendor_invoice_number,
              l_xpi_rec.nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
              l_xpi_rec.legal_entity_id,
              l_xpi_rec.CNSLD_AP_INV_ID;
    x_no_data_found := xpi_pk_csr%NOTFOUND;
    CLOSE xpi_pk_csr;
    RETURN(l_xpi_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xpi_rec                      IN xpi_rec_type
  ) RETURN xpi_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xpi_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_PAY_INVS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_ext_pay_invs_tl_rec_type IS
    CURSOR okl_ext_pay_invs_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            SOURCE,
            STREAM_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Pay_Invs_Tl
     WHERE okl_ext_pay_invs_tl.id = p_id
       AND okl_ext_pay_invs_tl.language = p_language;
    l_okl_ext_pay_invs_tl_pk       okl_ext_pay_invs_tl_pk_csr%ROWTYPE;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_pay_invs_tl_pk_csr (p_okl_ext_pay_invs_tl_rec.id,
                                     p_okl_ext_pay_invs_tl_rec.language);
    FETCH okl_ext_pay_invs_tl_pk_csr INTO
              l_okl_ext_pay_invs_tl_rec.ID,
              l_okl_ext_pay_invs_tl_rec.LANGUAGE,
              l_okl_ext_pay_invs_tl_rec.SOURCE_LANG,
              l_okl_ext_pay_invs_tl_rec.SFWT_FLAG,
              l_okl_ext_pay_invs_tl_rec.DESCRIPTION,
              l_okl_ext_pay_invs_tl_rec.SOURCE,
              l_okl_ext_pay_invs_tl_rec.STREAM_TYPE,
              l_okl_ext_pay_invs_tl_rec.CREATED_BY,
              l_okl_ext_pay_invs_tl_rec.CREATION_DATE,
              l_okl_ext_pay_invs_tl_rec.LAST_UPDATED_BY,
              l_okl_ext_pay_invs_tl_rec.LAST_UPDATE_DATE,
              l_okl_ext_pay_invs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ext_pay_invs_tl_pk_csr%NOTFOUND;
    CLOSE okl_ext_pay_invs_tl_pk_csr;
    RETURN(l_okl_ext_pay_invs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type
  ) RETURN okl_ext_pay_invs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_ext_pay_invs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_PAY_INVS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xpiv_rec                     IN xpiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xpiv_rec_type IS
    CURSOR okl_xpiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            TRX_STATUS_CODE,
            INVOICE_ID,
            INVOICE_NUM,
            INVOICE_TYPE,
            INVOICE_DATE,
            VENDOR_ID,
            VENDOR_SITE_ID,
            INVOICE_AMOUNT,
            INVOICE_CURRENCY_CODE,
            TERMS_ID,
            DESCRIPTION,
            SOURCE,
            WORKFLOW_FLAG,
            DOC_CATEGORY_CODE,
            PAYMENT_METHOD,
            GL_DATE,
            ACCTS_PAY_CC_ID,
            PAY_ALONE_FLAG,
            WAIT_VENDOR_INVOICE_YN,
            STREAM_TYPE,
            PAYABLES_INVOICE_ID,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
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
            pay_group_lookup_code,
            vendor_invoice_number,
            nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
            legal_entity_id,
            CNSLD_AP_INV_ID
     FROM Okl_Ext_Pay_Invs_V
     WHERE okl_ext_pay_invs_v.id = p_id;
    l_okl_xpiv_pk                  okl_xpiv_pk_csr%ROWTYPE;
    l_xpiv_rec                     xpiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xpiv_pk_csr (p_xpiv_rec.id);
    FETCH okl_xpiv_pk_csr INTO
              l_xpiv_rec.ID,
              l_xpiv_rec.OBJECT_VERSION_NUMBER,
              l_xpiv_rec.SFWT_FLAG,
              l_xpiv_rec.TRX_STATUS_CODE,
              l_xpiv_rec.INVOICE_ID,
              l_xpiv_rec.INVOICE_NUM,
              l_xpiv_rec.INVOICE_TYPE,
              l_xpiv_rec.INVOICE_DATE,
              l_xpiv_rec.VENDOR_ID,
              l_xpiv_rec.VENDOR_SITE_ID,
              l_xpiv_rec.INVOICE_AMOUNT,
              l_xpiv_rec.INVOICE_CURRENCY_CODE,
              l_xpiv_rec.TERMS_ID,
              l_xpiv_rec.DESCRIPTION,
              l_xpiv_rec.SOURCE,
              l_xpiv_rec.WORKFLOW_FLAG,
              l_xpiv_rec.DOC_CATEGORY_CODE,
              l_xpiv_rec.PAYMENT_METHOD,
              l_xpiv_rec.GL_DATE,
              l_xpiv_rec.ACCTS_PAY_CC_ID,
              l_xpiv_rec.PAY_ALONE_FLAG,
              l_xpiv_rec.WAIT_VENDOR_INVOICE_YN,
              l_xpiv_rec.STREAM_TYPE,
              l_xpiv_rec.PAYABLES_INVOICE_ID,
              l_xpiv_rec.CURRENCY_CONVERSION_TYPE,
              l_xpiv_rec.CURRENCY_CONVERSION_RATE,
              l_xpiv_rec.CURRENCY_CONVERSION_DATE,
              l_xpiv_rec.ATTRIBUTE_CATEGORY,
              l_xpiv_rec.ATTRIBUTE1,
              l_xpiv_rec.ATTRIBUTE2,
              l_xpiv_rec.ATTRIBUTE3,
              l_xpiv_rec.ATTRIBUTE4,
              l_xpiv_rec.ATTRIBUTE5,
              l_xpiv_rec.ATTRIBUTE6,
              l_xpiv_rec.ATTRIBUTE7,
              l_xpiv_rec.ATTRIBUTE8,
              l_xpiv_rec.ATTRIBUTE9,
              l_xpiv_rec.ATTRIBUTE10,
              l_xpiv_rec.ATTRIBUTE11,
              l_xpiv_rec.ATTRIBUTE12,
              l_xpiv_rec.ATTRIBUTE13,
              l_xpiv_rec.ATTRIBUTE14,
              l_xpiv_rec.ATTRIBUTE15,
              l_xpiv_rec.REQUEST_ID,
              l_xpiv_rec.PROGRAM_APPLICATION_ID,
              l_xpiv_rec.PROGRAM_ID,
              l_xpiv_rec.PROGRAM_UPDATE_DATE,
              l_xpiv_rec.ORG_ID,
              l_xpiv_rec.CREATED_BY,
              l_xpiv_rec.CREATION_DATE,
              l_xpiv_rec.LAST_UPDATED_BY,
              l_xpiv_rec.LAST_UPDATE_DATE,
              l_xpiv_rec.LAST_UPDATE_LOGIN,
              l_xpiv_rec.pay_group_lookup_code,
              l_xpiv_rec.vendor_invoice_number,
              l_xpiv_rec.nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
              l_xpiv_rec.legal_entity_id,
              l_xpiv_rec.CNSLD_AP_INV_ID;
    x_no_data_found := okl_xpiv_pk_csr%NOTFOUND;
    CLOSE okl_xpiv_pk_csr;
    RETURN(l_xpiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xpiv_rec                     IN xpiv_rec_type
  ) RETURN xpiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xpiv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_EXT_PAY_INVS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xpiv_rec	IN xpiv_rec_type
  ) RETURN xpiv_rec_type IS
    l_xpiv_rec	xpiv_rec_type := p_xpiv_rec;
  BEGIN
    IF (l_xpiv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.object_version_number := NULL;
    END IF;
    IF (l_xpiv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_xpiv_rec.trx_status_code = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.trx_status_code := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.invoice_id := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_num = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.invoice_num := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_type = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.invoice_type := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_date = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.invoice_date := NULL;
    END IF;
    IF (l_xpiv_rec.vendor_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.vendor_id := NULL;
    END IF;
    IF (l_xpiv_rec.vendor_site_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.vendor_site_id := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_amount = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.invoice_amount := NULL;
    END IF;
    IF (l_xpiv_rec.invoice_currency_code = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.invoice_currency_code := NULL;
    END IF;
    IF (l_xpiv_rec.terms_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.terms_id := NULL;
    END IF;
    IF (l_xpiv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.description := NULL;
    END IF;
    IF (l_xpiv_rec.source = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.source := NULL;
    END IF;
    IF (l_xpiv_rec.workflow_flag = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.workflow_flag := NULL;
    END IF;
    IF (l_xpiv_rec.doc_category_code = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.doc_category_code := NULL;
    END IF;
    IF (l_xpiv_rec.payment_method = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.payment_method := NULL;
    END IF;
    IF (l_xpiv_rec.gl_date = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.gl_date := NULL;
    END IF;
    IF (l_xpiv_rec.accts_pay_cc_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.accts_pay_cc_id := NULL;
    END IF;
    IF (l_xpiv_rec.pay_alone_flag = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.pay_alone_flag := NULL;
    END IF;
    IF (l_xpiv_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.wait_vendor_invoice_yn := NULL;
    END IF;
    IF (l_xpiv_rec.stream_type = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.stream_type := NULL;
    END IF;
    IF (l_xpiv_rec.payables_invoice_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.payables_invoice_id := NULL;
    END IF;
    IF (l_xpiv_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.CURRENCY_CONVERSION_TYPE := NULL;
    END IF;
    IF (l_xpiv_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.CURRENCY_CONVERSION_RATE := NULL;
    END IF;
    IF (l_xpiv_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.CURRENCY_CONVERSION_DATE := NULL;
    END IF;
    IF (l_xpiv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute_category := NULL;
    END IF;
    IF (l_xpiv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute1 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute2 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute3 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute4 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute5 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute6 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute7 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute8 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute9 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute10 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute11 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute12 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute13 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute14 := NULL;
    END IF;
    IF (l_xpiv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.attribute15 := NULL;
    END IF;
    IF (l_xpiv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.request_id := NULL;
    END IF;
    IF (l_xpiv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.program_application_id := NULL;
    END IF;
    IF (l_xpiv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.program_id := NULL;
    END IF;
    IF (l_xpiv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.program_update_date := NULL;
    END IF;
    IF (l_xpiv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.org_id := NULL;
    END IF;
    IF (l_xpiv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.created_by := NULL;
    END IF;
    IF (l_xpiv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.creation_date := NULL;
    END IF;
    IF (l_xpiv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xpiv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_xpiv_rec.last_update_date := NULL;
    END IF;
    IF (l_xpiv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.last_update_login := NULL;
    END IF;
        IF (l_xpiv_rec.pay_group_lookup_code = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.pay_group_lookup_code := NULL;
    END IF;
    IF (l_xpiv_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.vendor_invoice_number := NULL;
    END IF;
    IF (l_xpiv_rec.nettable_yn = OKL_API.G_MISS_CHAR) THEN
      l_xpiv_rec.nettable_yn := NULL;
    END IF;

 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    IF (l_xpiv_rec.legal_entity_id = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.legal_entity_id := NULL;
    END IF;

    IF (l_xpiv_rec.CNSLD_AP_INV_ID = OKL_API.G_MISS_NUM) THEN
      l_xpiv_rec.CNSLD_AP_INV_ID := NULL;
    END IF;

    RETURN(l_xpiv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes for OKL_EXT_PAY_INVS_V : Modified for PostGen-12
  ---------------------------------------------------------------------------------
  FUNCTION Validate_Attributes
         ( p_xpiv_rec IN  xpiv_rec_type
         ) RETURN VARCHAR2 IS

    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_id ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number
                ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_invoice_id
                ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_org_id
                ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_wait_vend_inv_yn
                ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_trx_status_code
                ( x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity  start changes
    validate_le_id(x_return_status      => l_return_status
                , p_xpiv_rec           => p_xpiv_rec) ;

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity  End changes

    RETURN x_return_status;  -- Return status to the caller

  /*------------------------------- TAPI Generated Code ---------------------------------------+
    IF p_xpiv_rec.id = OKL_API.G_MISS_NUM OR
       p_xpiv_rec.id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_xpiv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_xpiv_rec.object_version_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_xpiv_rec.invoice_id = OKL_API.G_MISS_NUM OR
          p_xpiv_rec.invoice_id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'invoice_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
  +------------------------------ TAPI Generated Code ----------------------------------------*/

  EXCEPTION

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      return x_return_status;                            -- Return status to the caller

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_EXT_PAY_INVS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_xpiv_rec IN xpiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN xpiv_rec_type,
    p_to	IN OUT NOCOPY xpi_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.invoice_id := p_from.invoice_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.invoice_num := p_from.invoice_num;
    p_to.invoice_type := p_from.invoice_type;
    p_to.invoice_date := p_from.invoice_date;
    p_to.vendor_id := p_from.vendor_id;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.invoice_amount := p_from.invoice_amount;
    p_to.invoice_currency_code := p_from.invoice_currency_code;
    p_to.terms_id := p_from.terms_id;
    p_to.workflow_flag := p_from.workflow_flag;
    p_to.doc_category_code := p_from.doc_category_code;
    p_to.payment_method := p_from.payment_method;
    p_to.gl_date := p_from.gl_date;
    p_to.accts_pay_cc_id := p_from.accts_pay_cc_id;
    p_to.pay_alone_flag := p_from.pay_alone_flag;
    p_to.wait_vendor_invoice_yn := p_from.wait_vendor_invoice_yn;
    p_to.payables_invoice_id := p_from.payables_invoice_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
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
    p_to.pay_group_lookup_code := p_from.pay_group_lookup_code;
    p_to.vendor_invoice_number := p_from.vendor_invoice_number;
    p_to.nettable_yn := p_from.nettable_yn;
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.CNSLD_AP_INV_ID := p_from.CNSLD_AP_INV_ID;
  END migrate;
  PROCEDURE migrate (
    p_from	IN xpi_rec_type,
    p_to	IN OUT NOCOPY xpiv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.invoice_id := p_from.invoice_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.invoice_num := p_from.invoice_num;
    p_to.invoice_type := p_from.invoice_type;
    p_to.invoice_date := p_from.invoice_date;
    p_to.vendor_id := p_from.vendor_id;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.invoice_amount := p_from.invoice_amount;
    p_to.invoice_currency_code := p_from.invoice_currency_code;
    p_to.terms_id := p_from.terms_id;
    p_to.workflow_flag := p_from.workflow_flag;
    p_to.doc_category_code := p_from.doc_category_code;
    p_to.payment_method := p_from.payment_method;
    p_to.gl_date := p_from.gl_date;
    p_to.accts_pay_cc_id := p_from.accts_pay_cc_id;
    p_to.pay_alone_flag := p_from.pay_alone_flag;
    p_to.wait_vendor_invoice_yn := p_from.wait_vendor_invoice_yn;
    p_to.payables_invoice_id := p_from.payables_invoice_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
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
    p_to.pay_group_lookup_code := p_from.pay_group_lookup_code;
    p_to.vendor_invoice_number := p_from.vendor_invoice_number;
    p_to.nettable_yn := p_from.nettable_yn;
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.CNSLD_AP_INV_ID := p_from.CNSLD_AP_INV_ID;

  END migrate;
  PROCEDURE migrate (
    p_from	IN xpiv_rec_type,
    p_to	IN OUT NOCOPY okl_ext_pay_invs_tl_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.source := p_from.source;
    p_to.stream_type := p_from.stream_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_ext_pay_invs_tl_rec_type,
    p_to	IN OUT NOCOPY xpiv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.source := p_from.source;
    p_to.stream_type := p_from.stream_type;
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
  -- validate_row for:OKL_EXT_PAY_INVS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpiv_rec                     xpiv_rec_type := p_xpiv_rec;
    l_xpi_rec                      xpi_rec_type;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_xpiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xpiv_rec);
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
  -- PL/SQL TBL validate_row for:XPIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xpiv_tbl.COUNT > 0) THEN
      i := p_xpiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xpiv_rec                     => p_xpiv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xpiv_tbl.LAST);
        i := p_xpiv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

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
  -- insert_row for:OKL_EXT_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpi_rec                      IN xpi_rec_type,
    x_xpi_rec                      OUT NOCOPY xpi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpi_rec                      xpi_rec_type := p_xpi_rec;
    l_def_xpi_rec                  xpi_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xpi_rec IN  xpi_rec_type,
      x_xpi_rec OUT NOCOPY xpi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpi_rec := p_xpi_rec;
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
      p_xpi_rec,                         -- IN
      l_xpi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_PAY_INVS_B(
        id,
        trx_status_code,
        invoice_id,
        object_version_number,
        invoice_num,
        invoice_type,
        invoice_date,
        vendor_id,
        vendor_site_id,
        invoice_amount,
        invoice_currency_code,
        terms_id,
        workflow_flag,
        doc_category_code,
        payment_method,
        gl_date,
        accts_pay_cc_id,
        pay_alone_flag,
        wait_vendor_invoice_yn,
        payables_invoice_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
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
        pay_group_lookup_code,
        vendor_invoice_number,
        nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
        legal_entity_id,
        CNSLD_AP_INV_ID
)
      VALUES (
        l_xpi_rec.id,
        l_xpi_rec.trx_status_code,
        l_xpi_rec.invoice_id,
        l_xpi_rec.object_version_number,
        l_xpi_rec.invoice_num,
        l_xpi_rec.invoice_type,
        l_xpi_rec.invoice_date,
        l_xpi_rec.vendor_id,
        l_xpi_rec.vendor_site_id,
        l_xpi_rec.invoice_amount,
        l_xpi_rec.invoice_currency_code,
        l_xpi_rec.terms_id,
        l_xpi_rec.workflow_flag,
        l_xpi_rec.doc_category_code,
        l_xpi_rec.payment_method,
        l_xpi_rec.gl_date,
        l_xpi_rec.accts_pay_cc_id,
        l_xpi_rec.pay_alone_flag,
        l_xpi_rec.wait_vendor_invoice_yn,
        l_xpi_rec.payables_invoice_id,
        l_xpi_rec.request_id,
        l_xpi_rec.program_application_id,
        l_xpi_rec.program_id,
        l_xpi_rec.program_update_date,
        l_xpi_rec.org_id,
        l_xpi_rec.CURRENCY_CONVERSION_TYPE,
        l_xpi_rec.CURRENCY_CONVERSION_RATE,
        l_xpi_rec.CURRENCY_CONVERSION_DATE,
        l_xpi_rec.attribute_category,
        l_xpi_rec.attribute1,
        l_xpi_rec.attribute2,
        l_xpi_rec.attribute3,
        l_xpi_rec.attribute4,
        l_xpi_rec.attribute5,
        l_xpi_rec.attribute6,
        l_xpi_rec.attribute7,
        l_xpi_rec.attribute8,
        l_xpi_rec.attribute9,
        l_xpi_rec.attribute10,
        l_xpi_rec.attribute11,
        l_xpi_rec.attribute12,
        l_xpi_rec.attribute13,
        l_xpi_rec.attribute14,
        l_xpi_rec.attribute15,
        l_xpi_rec.created_by,
        l_xpi_rec.creation_date,
        l_xpi_rec.last_updated_by,
        l_xpi_rec.last_update_date,
        l_xpi_rec.last_update_login,
        l_xpi_rec.pay_group_lookup_code,
        l_xpi_rec.vendor_invoice_number,
        l_xpi_rec.nettable_yn,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
        l_xpi_rec.legal_entity_id,
        l_xpi_rec.CNSLD_AP_INV_ID);
    -- Set OUT values
    x_xpi_rec := l_xpi_rec;
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
  -- insert_row for:OKL_EXT_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type,
    x_okl_ext_pay_invs_tl_rec      OUT NOCOPY okl_ext_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type := p_okl_ext_pay_invs_tl_rec;
    ldefoklextpayinvstlrec         okl_ext_pay_invs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_pay_invs_tl_rec IN  okl_ext_pay_invs_tl_rec_type,
      x_okl_ext_pay_invs_tl_rec OUT NOCOPY okl_ext_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_pay_invs_tl_rec := p_okl_ext_pay_invs_tl_rec;
      x_okl_ext_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_pay_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ext_pay_invs_tl_rec,         -- IN
      l_okl_ext_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_ext_pay_invs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_EXT_PAY_INVS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          source,
          stream_type,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ext_pay_invs_tl_rec.id,
          l_okl_ext_pay_invs_tl_rec.language,
          l_okl_ext_pay_invs_tl_rec.source_lang,
          l_okl_ext_pay_invs_tl_rec.sfwt_flag,
          l_okl_ext_pay_invs_tl_rec.description,
          l_okl_ext_pay_invs_tl_rec.source,
          l_okl_ext_pay_invs_tl_rec.stream_type,
          l_okl_ext_pay_invs_tl_rec.created_by,
          l_okl_ext_pay_invs_tl_rec.creation_date,
          l_okl_ext_pay_invs_tl_rec.last_updated_by,
          l_okl_ext_pay_invs_tl_rec.last_update_date,
          l_okl_ext_pay_invs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_ext_pay_invs_tl_rec := l_okl_ext_pay_invs_tl_rec;
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
  -- insert_row for:OKL_EXT_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type,
    x_xpiv_rec                     OUT NOCOPY xpiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpiv_rec                     xpiv_rec_type;
    l_def_xpiv_rec                 xpiv_rec_type;
    l_xpi_rec                      xpi_rec_type;
    lx_xpi_rec                     xpi_rec_type;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
    lx_okl_ext_pay_invs_tl_rec     okl_ext_pay_invs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xpiv_rec	IN xpiv_rec_type
    ) RETURN xpiv_rec_type IS
      l_xpiv_rec	xpiv_rec_type := p_xpiv_rec;
    BEGIN
      l_xpiv_rec.CREATION_DATE := SYSDATE;
      l_xpiv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_xpiv_rec.LAST_UPDATE_DATE := l_xpiv_rec.CREATION_DATE;     -- PostGen-10
      l_xpiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xpiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xpiv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xpiv_rec IN  xpiv_rec_type,
      x_xpiv_rec OUT NOCOPY xpiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpiv_rec := p_xpiv_rec;
      x_xpiv_rec.OBJECT_VERSION_NUMBER := 1;
      x_xpiv_rec.SFWT_FLAG := 'N';

      -- Begin PostGen-7
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_xpiv_rec.request_id,
        x_xpiv_rec.program_application_id,
        x_xpiv_rec.program_id,
        x_xpiv_rec.program_update_date
      FROM   dual;
      -- End  PostGen-7

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
    l_xpiv_rec := null_out_defaults(p_xpiv_rec);
    -- Set primary key value
    l_xpiv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xpiv_rec,                        -- IN
      l_def_xpiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xpiv_rec := fill_who_columns(l_def_xpiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xpiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xpiv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xpiv_rec, l_xpi_rec);
    migrate(l_def_xpiv_rec, l_okl_ext_pay_invs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xpi_rec,
      lx_xpi_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xpi_rec, l_def_xpiv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_pay_invs_tl_rec,
      lx_okl_ext_pay_invs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_pay_invs_tl_rec, l_def_xpiv_rec);
    -- Set OUT values
    x_xpiv_rec := l_def_xpiv_rec;
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
  -- PL/SQL TBL insert_row for:XPIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type,
    x_xpiv_tbl                     OUT NOCOPY xpiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xpiv_tbl.COUNT > 0) THEN
      i := p_xpiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xpiv_rec                     => p_xpiv_tbl(i),
          x_xpiv_rec                     => x_xpiv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xpiv_tbl.LAST);
        i := p_xpiv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

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
  -- lock_row for:OKL_EXT_PAY_INVS_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpi_rec                      IN xpi_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xpi_rec IN xpi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_PAY_INVS_B
     WHERE ID = p_xpi_rec.id
       AND OBJECT_VERSION_NUMBER = p_xpi_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xpi_rec IN xpi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_PAY_INVS_B
    WHERE ID = p_xpi_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_EXT_PAY_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_EXT_PAY_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_xpi_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_xpi_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xpi_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xpi_rec.object_version_number THEN
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
  -- lock_row for:OKL_EXT_PAY_INVS_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_ext_pay_invs_tl_rec IN okl_ext_pay_invs_tl_rec_type) IS
    SELECT *
      FROM OKL_EXT_PAY_INVS_TL
     WHERE ID = p_okl_ext_pay_invs_tl_rec.id
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
      OPEN lock_csr(p_okl_ext_pay_invs_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
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
  -- lock_row for:OKL_EXT_PAY_INVS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpi_rec                      xpi_rec_type;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
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
    migrate(p_xpiv_rec, l_xpi_rec);
    migrate(p_xpiv_rec, l_okl_ext_pay_invs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xpi_rec
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
      l_okl_ext_pay_invs_tl_rec
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
  -- PL/SQL TBL lock_row for:XPIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xpiv_tbl.COUNT > 0) THEN
      i := p_xpiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xpiv_rec                     => p_xpiv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xpiv_tbl.LAST);
        i := p_xpiv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

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
  -- update_row for:OKL_EXT_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpi_rec                      IN xpi_rec_type,
    x_xpi_rec                      OUT NOCOPY xpi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpi_rec                      xpi_rec_type := p_xpi_rec;
    l_def_xpi_rec                  xpi_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xpi_rec	IN xpi_rec_type,
      x_xpi_rec	OUT NOCOPY xpi_rec_type
    ) RETURN VARCHAR2 IS
      l_xpi_rec                      xpi_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpi_rec := p_xpi_rec;
      -- Get current database values
      l_xpi_rec := get_rec(p_xpi_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xpi_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.id := l_xpi_rec.id;
      END IF;
      IF (x_xpi_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.trx_status_code := l_xpi_rec.trx_status_code;
      END IF;
      IF (x_xpi_rec.invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.invoice_id := l_xpi_rec.invoice_id;
      END IF;
      IF (x_xpi_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.object_version_number := l_xpi_rec.object_version_number;
      END IF;
      IF (x_xpi_rec.invoice_num = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.invoice_num := l_xpi_rec.invoice_num;
      END IF;
      IF (x_xpi_rec.invoice_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.invoice_type := l_xpi_rec.invoice_type;
      END IF;
      IF (x_xpi_rec.invoice_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.invoice_date := l_xpi_rec.invoice_date;
      END IF;
      IF (x_xpi_rec.vendor_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.vendor_id := l_xpi_rec.vendor_id;
      END IF;
      IF (x_xpi_rec.vendor_site_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.vendor_site_id := l_xpi_rec.vendor_site_id;
      END IF;
      IF (x_xpi_rec.invoice_amount = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.invoice_amount := l_xpi_rec.invoice_amount;
      END IF;
      IF (x_xpi_rec.invoice_currency_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.invoice_currency_code := l_xpi_rec.invoice_currency_code;
      END IF;
      IF (x_xpi_rec.terms_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.terms_id := l_xpi_rec.terms_id;
      END IF;
      IF (x_xpi_rec.workflow_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.workflow_flag := l_xpi_rec.workflow_flag;
      END IF;
      IF (x_xpi_rec.doc_category_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.doc_category_code := l_xpi_rec.doc_category_code;
      END IF;
      IF (x_xpi_rec.payment_method = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.payment_method := l_xpi_rec.payment_method;
      END IF;
      IF (x_xpi_rec.gl_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.gl_date := l_xpi_rec.gl_date;
      END IF;
      IF (x_xpi_rec.accts_pay_cc_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.accts_pay_cc_id := l_xpi_rec.accts_pay_cc_id;
      END IF;
      IF (x_xpi_rec.pay_alone_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.pay_alone_flag := l_xpi_rec.pay_alone_flag;
      END IF;
      IF (x_xpi_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.wait_vendor_invoice_yn := l_xpi_rec.wait_vendor_invoice_yn;
      END IF;
      IF (x_xpi_rec.payables_invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.payables_invoice_id := l_xpi_rec.payables_invoice_id;
      END IF;
      IF (x_xpi_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.request_id := l_xpi_rec.request_id;
      END IF;
      IF (x_xpi_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.program_application_id := l_xpi_rec.program_application_id;
      END IF;
      IF (x_xpi_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.program_id := l_xpi_rec.program_id;
      END IF;
      IF (x_xpi_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.program_update_date := l_xpi_rec.program_update_date;
      END IF;
      IF (x_xpi_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.org_id := l_xpi_rec.org_id;
      END IF;
      IF (x_xpi_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
        x_xpi_rec.CURRENCY_CONVERSION_TYPE := l_xpi_rec.CURRENCY_CONVERSION_TYPE;
      END IF;
      IF (x_xpi_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
        x_xpi_rec.CURRENCY_CONVERSION_RATE := l_xpi_rec.CURRENCY_CONVERSION_RATE;
      END IF;
      IF (x_xpi_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
        x_xpi_rec.CURRENCY_CONVERSION_DATE := l_xpi_rec.CURRENCY_CONVERSION_DATE;
      END IF;
      IF (x_xpi_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute_category := l_xpi_rec.attribute_category;
      END IF;
      IF (x_xpi_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute1 := l_xpi_rec.attribute1;
      END IF;
      IF (x_xpi_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute2 := l_xpi_rec.attribute2;
      END IF;
      IF (x_xpi_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute3 := l_xpi_rec.attribute3;
      END IF;
      IF (x_xpi_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute4 := l_xpi_rec.attribute4;
      END IF;
      IF (x_xpi_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute5 := l_xpi_rec.attribute5;
      END IF;
      IF (x_xpi_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute6 := l_xpi_rec.attribute6;
      END IF;
      IF (x_xpi_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute7 := l_xpi_rec.attribute7;
      END IF;
      IF (x_xpi_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute8 := l_xpi_rec.attribute8;
      END IF;
      IF (x_xpi_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute9 := l_xpi_rec.attribute9;
      END IF;
      IF (x_xpi_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute10 := l_xpi_rec.attribute10;
      END IF;
      IF (x_xpi_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute11 := l_xpi_rec.attribute11;
      END IF;
      IF (x_xpi_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute12 := l_xpi_rec.attribute12;
      END IF;
      IF (x_xpi_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute13 := l_xpi_rec.attribute13;
      END IF;
      IF (x_xpi_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute14 := l_xpi_rec.attribute14;
      END IF;
      IF (x_xpi_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpi_rec.attribute15 := l_xpi_rec.attribute15;
      END IF;
      IF (x_xpi_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.created_by := l_xpi_rec.created_by;
      END IF;
      IF (x_xpi_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.creation_date := l_xpi_rec.creation_date;
      END IF;
      IF (x_xpi_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.last_updated_by := l_xpi_rec.last_updated_by;
      END IF;
      IF (x_xpi_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.last_update_date := l_xpi_rec.last_update_date;
      END IF;
      IF (x_xpi_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.last_update_login := l_xpi_rec.last_update_login;
      END IF;
      IF (x_xpi_rec.pay_group_lookup_code = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.pay_group_lookup_code := l_xpi_rec.pay_group_lookup_code;
      END IF;
      IF (x_xpi_rec.vendor_invoice_number = OKL_API.G_MISS_DATE)
      THEN
        x_xpi_rec.vendor_invoice_number := l_xpi_rec.vendor_invoice_number;
      END IF;
      IF (x_xpi_rec.nettable_yn = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.nettable_yn := l_xpi_rec.nettable_yn;
      END IF;
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity

      IF (x_xpi_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.legal_entity_id := l_xpi_rec.legal_entity_id;
      END IF;

      IF (x_xpi_rec.CNSLD_AP_INV_ID = OKL_API.G_MISS_NUM)
      THEN
        x_xpi_rec.CNSLD_AP_INV_ID := l_xpi_rec.CNSLD_AP_INV_ID;
      END IF;


      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xpi_rec IN  xpi_rec_type,
      x_xpi_rec OUT NOCOPY xpi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpi_rec := p_xpi_rec;
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
      p_xpi_rec,                         -- IN
      l_xpi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xpi_rec, l_def_xpi_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_PAY_INVS_B
    SET INVOICE_ID = l_def_xpi_rec.invoice_id,
        TRX_STATUS_CODE = l_def_xpi_rec.trx_status_code,
        OBJECT_VERSION_NUMBER = l_def_xpi_rec.object_version_number,
        INVOICE_NUM = l_def_xpi_rec.invoice_num,
        INVOICE_TYPE = l_def_xpi_rec.invoice_type,
        INVOICE_DATE = l_def_xpi_rec.invoice_date,
        VENDOR_ID = l_def_xpi_rec.vendor_id,
        VENDOR_SITE_ID = l_def_xpi_rec.vendor_site_id,
        INVOICE_AMOUNT = l_def_xpi_rec.invoice_amount,
        INVOICE_CURRENCY_CODE = l_def_xpi_rec.invoice_currency_code,
        TERMS_ID = l_def_xpi_rec.terms_id,
        WORKFLOW_FLAG = l_def_xpi_rec.workflow_flag,
        DOC_CATEGORY_CODE = l_def_xpi_rec.doc_category_code,
        PAYMENT_METHOD = l_def_xpi_rec.payment_method,
        GL_DATE = l_def_xpi_rec.gl_date,
        ACCTS_PAY_CC_ID = l_def_xpi_rec.accts_pay_cc_id,
        PAY_ALONE_FLAG = l_def_xpi_rec.pay_alone_flag,
        WAIT_VENDOR_INVOICE_YN = l_def_xpi_rec.wait_vendor_invoice_yn,
        PAYABLES_INVOICE_ID = l_def_xpi_rec.payables_invoice_id,
        REQUEST_ID = l_def_xpi_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xpi_rec.program_application_id,
        PROGRAM_ID = l_def_xpi_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xpi_rec.program_update_date,
        ORG_ID = l_def_xpi_rec.org_id,
        CURRENCY_CONVERSION_TYPE = l_def_xpi_rec.CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE = l_def_xpi_rec.CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE = l_def_xpi_rec.CURRENCY_CONVERSION_DATE,
        ATTRIBUTE_CATEGORY = l_def_xpi_rec.attribute_category,
        ATTRIBUTE1 = l_def_xpi_rec.attribute1,
        ATTRIBUTE2 = l_def_xpi_rec.attribute2,
        ATTRIBUTE3 = l_def_xpi_rec.attribute3,
        ATTRIBUTE4 = l_def_xpi_rec.attribute4,
        ATTRIBUTE5 = l_def_xpi_rec.attribute5,
        ATTRIBUTE6 = l_def_xpi_rec.attribute6,
        ATTRIBUTE7 = l_def_xpi_rec.attribute7,
        ATTRIBUTE8 = l_def_xpi_rec.attribute8,
        ATTRIBUTE9 = l_def_xpi_rec.attribute9,
        ATTRIBUTE10 = l_def_xpi_rec.attribute10,
        ATTRIBUTE11 = l_def_xpi_rec.attribute11,
        ATTRIBUTE12 = l_def_xpi_rec.attribute12,
        ATTRIBUTE13 = l_def_xpi_rec.attribute13,
        ATTRIBUTE14 = l_def_xpi_rec.attribute14,
        ATTRIBUTE15 = l_def_xpi_rec.attribute15,
        CREATED_BY = l_def_xpi_rec.created_by,
        CREATION_DATE = l_def_xpi_rec.creation_date,
        LAST_UPDATED_BY = l_def_xpi_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xpi_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xpi_rec.last_update_login,
        pay_group_lookup_code = l_def_xpi_rec.pay_group_lookup_code,
        vendor_invoice_number = l_def_xpi_rec.vendor_invoice_number,
        nettable_yn = l_def_xpi_rec.nettable_yn,
     -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
        legal_entity_id = l_def_xpi_rec.legal_entity_id,
        CNSLD_AP_INV_ID = l_def_xpi_rec.CNSLD_AP_INV_ID

    WHERE ID = l_def_xpi_rec.id;

    x_xpi_rec := l_def_xpi_rec;
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
  -- update_row for:OKL_EXT_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type,
    x_okl_ext_pay_invs_tl_rec      OUT NOCOPY okl_ext_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type := p_okl_ext_pay_invs_tl_rec;
    ldefoklextpayinvstlrec         okl_ext_pay_invs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_ext_pay_invs_tl_rec	IN okl_ext_pay_invs_tl_rec_type,
      x_okl_ext_pay_invs_tl_rec	OUT NOCOPY okl_ext_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_pay_invs_tl_rec := p_okl_ext_pay_invs_tl_rec;
      -- Get current database values
      l_okl_ext_pay_invs_tl_rec := get_rec(p_okl_ext_pay_invs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_ext_pay_invs_tl_rec.id := l_okl_ext_pay_invs_tl_rec.id;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.language := l_okl_ext_pay_invs_tl_rec.language;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.source_lang := l_okl_ext_pay_invs_tl_rec.source_lang;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.sfwt_flag := l_okl_ext_pay_invs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.description := l_okl_ext_pay_invs_tl_rec.description;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.source = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.source := l_okl_ext_pay_invs_tl_rec.source;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.stream_type = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_ext_pay_invs_tl_rec.stream_type := l_okl_ext_pay_invs_tl_rec.stream_type;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_ext_pay_invs_tl_rec.created_by := l_okl_ext_pay_invs_tl_rec.created_by;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_ext_pay_invs_tl_rec.creation_date := l_okl_ext_pay_invs_tl_rec.creation_date;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_ext_pay_invs_tl_rec.last_updated_by := l_okl_ext_pay_invs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_ext_pay_invs_tl_rec.last_update_date := l_okl_ext_pay_invs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_ext_pay_invs_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_ext_pay_invs_tl_rec.last_update_login := l_okl_ext_pay_invs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_pay_invs_tl_rec IN  okl_ext_pay_invs_tl_rec_type,
      x_okl_ext_pay_invs_tl_rec OUT NOCOPY okl_ext_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_pay_invs_tl_rec := p_okl_ext_pay_invs_tl_rec;
      x_okl_ext_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_pay_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ext_pay_invs_tl_rec,         -- IN
      l_okl_ext_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_ext_pay_invs_tl_rec, ldefoklextpayinvstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_PAY_INVS_TL
    SET DESCRIPTION = ldefoklextpayinvstlrec.description,
        SOURCE = ldefoklextpayinvstlrec.source,
        STREAM_TYPE = ldefoklextpayinvstlrec.stream_type,
        SOURCE_LANG = ldefoklextpayinvstlrec.source_lang,
        CREATED_BY = ldefoklextpayinvstlrec.created_by,
        CREATION_DATE = ldefoklextpayinvstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklextpayinvstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklextpayinvstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklextpayinvstlrec.last_update_login
    WHERE ID = ldefoklextpayinvstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_EXT_PAY_INVS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklextpayinvstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_ext_pay_invs_tl_rec := ldefoklextpayinvstlrec;
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
  -- update_row for:OKL_EXT_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type,
    x_xpiv_rec                     OUT NOCOPY xpiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpiv_rec                     xpiv_rec_type := p_xpiv_rec;
    l_def_xpiv_rec                 xpiv_rec_type;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
    lx_okl_ext_pay_invs_tl_rec     okl_ext_pay_invs_tl_rec_type;
    l_xpi_rec                      xpi_rec_type;
    lx_xpi_rec                     xpi_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xpiv_rec	IN xpiv_rec_type
    ) RETURN xpiv_rec_type IS
      l_xpiv_rec	xpiv_rec_type := p_xpiv_rec;
    BEGIN
      l_xpiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xpiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xpiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xpiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xpiv_rec	IN xpiv_rec_type,
      x_xpiv_rec	OUT NOCOPY xpiv_rec_type
    ) RETURN VARCHAR2 IS
      l_xpiv_rec                     xpiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpiv_rec := p_xpiv_rec;
      -- Get current database values
      l_xpiv_rec := get_rec(p_xpiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xpiv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.id := l_xpiv_rec.id;
      END IF;
      IF (x_xpiv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.object_version_number := l_xpiv_rec.object_version_number;
      END IF;
      IF (x_xpiv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.sfwt_flag := l_xpiv_rec.sfwt_flag;
      END IF;
      IF (x_xpiv_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.trx_status_code := l_xpiv_rec.trx_status_code;
      END IF;
      IF (x_xpiv_rec.invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.invoice_id := l_xpiv_rec.invoice_id;
      END IF;
      IF (x_xpiv_rec.invoice_num = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.invoice_num := l_xpiv_rec.invoice_num;
      END IF;
      IF (x_xpiv_rec.invoice_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.invoice_type := l_xpiv_rec.invoice_type;
      END IF;
      IF (x_xpiv_rec.invoice_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.invoice_date := l_xpiv_rec.invoice_date;
      END IF;
      IF (x_xpiv_rec.vendor_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.vendor_id := l_xpiv_rec.vendor_id;
      END IF;
      IF (x_xpiv_rec.vendor_site_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.vendor_site_id := l_xpiv_rec.vendor_site_id;
      END IF;
      IF (x_xpiv_rec.invoice_amount = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.invoice_amount := l_xpiv_rec.invoice_amount;
      END IF;
      IF (x_xpiv_rec.invoice_currency_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.invoice_currency_code := l_xpiv_rec.invoice_currency_code;
      END IF;
      IF (x_xpiv_rec.terms_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.terms_id := l_xpiv_rec.terms_id;
      END IF;
      IF (x_xpiv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.description := l_xpiv_rec.description;
      END IF;
      IF (x_xpiv_rec.source = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.source := l_xpiv_rec.source;
      END IF;
      IF (x_xpiv_rec.workflow_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.workflow_flag := l_xpiv_rec.workflow_flag;
      END IF;
      IF (x_xpiv_rec.doc_category_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.doc_category_code := l_xpiv_rec.doc_category_code;
      END IF;
      IF (x_xpiv_rec.payment_method = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.payment_method := l_xpiv_rec.payment_method;
      END IF;
      IF (x_xpiv_rec.gl_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.gl_date := l_xpiv_rec.gl_date;
      END IF;
      IF (x_xpiv_rec.accts_pay_cc_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.accts_pay_cc_id := l_xpiv_rec.accts_pay_cc_id;
      END IF;
      IF (x_xpiv_rec.pay_alone_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.pay_alone_flag := l_xpiv_rec.pay_alone_flag;
      END IF;
      IF (x_xpiv_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.wait_vendor_invoice_yn := l_xpiv_rec.wait_vendor_invoice_yn;
      END IF;
      IF (x_xpiv_rec.stream_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.stream_type := l_xpiv_rec.stream_type;
      END IF;
      IF (x_xpiv_rec.payables_invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.payables_invoice_id := l_xpiv_rec.payables_invoice_id;
      END IF;
      IF (x_xpiv_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
        x_xpiv_rec.CURRENCY_CONVERSION_TYPE := l_xpiv_rec.CURRENCY_CONVERSION_TYPE;
      END IF;
      IF (x_xpiv_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
        x_xpiv_rec.CURRENCY_CONVERSION_RATE := l_xpiv_rec.CURRENCY_CONVERSION_RATE;
      END IF;
      IF (x_xpiv_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
        x_xpiv_rec.CURRENCY_CONVERSION_DATE := l_xpiv_rec.CURRENCY_CONVERSION_DATE;
      END IF;
      IF (x_xpiv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute_category := l_xpiv_rec.attribute_category;
      END IF;
      IF (x_xpiv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute1 := l_xpiv_rec.attribute1;
      END IF;
      IF (x_xpiv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute2 := l_xpiv_rec.attribute2;
      END IF;
      IF (x_xpiv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute3 := l_xpiv_rec.attribute3;
      END IF;
      IF (x_xpiv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute4 := l_xpiv_rec.attribute4;
      END IF;
      IF (x_xpiv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute5 := l_xpiv_rec.attribute5;
      END IF;
      IF (x_xpiv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute6 := l_xpiv_rec.attribute6;
      END IF;
      IF (x_xpiv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute7 := l_xpiv_rec.attribute7;
      END IF;
      IF (x_xpiv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute8 := l_xpiv_rec.attribute8;
      END IF;
      IF (x_xpiv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute9 := l_xpiv_rec.attribute9;
      END IF;
      IF (x_xpiv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute10 := l_xpiv_rec.attribute10;
      END IF;
      IF (x_xpiv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute11 := l_xpiv_rec.attribute11;
      END IF;
      IF (x_xpiv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute12 := l_xpiv_rec.attribute12;
      END IF;
      IF (x_xpiv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute13 := l_xpiv_rec.attribute13;
      END IF;
      IF (x_xpiv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute14 := l_xpiv_rec.attribute14;
      END IF;
      IF (x_xpiv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_xpiv_rec.attribute15 := l_xpiv_rec.attribute15;
      END IF;
      IF (x_xpiv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.request_id := l_xpiv_rec.request_id;
      END IF;
      IF (x_xpiv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.program_application_id := l_xpiv_rec.program_application_id;
      END IF;
      IF (x_xpiv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.program_id := l_xpiv_rec.program_id;
      END IF;
      IF (x_xpiv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.program_update_date := l_xpiv_rec.program_update_date;
      END IF;
      IF (x_xpiv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.org_id := l_xpiv_rec.org_id;
      END IF;
      IF (x_xpiv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.created_by := l_xpiv_rec.created_by;
      END IF;
      IF (x_xpiv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.creation_date := l_xpiv_rec.creation_date;
      END IF;
      IF (x_xpiv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.last_updated_by := l_xpiv_rec.last_updated_by;
      END IF;
      IF (x_xpiv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.last_update_date := l_xpiv_rec.last_update_date;
      END IF;
      IF (x_xpiv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.last_update_login := l_xpiv_rec.last_update_login;
      END IF;
      IF (x_xpiv_rec.pay_group_lookup_code = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.pay_group_lookup_code := l_xpiv_rec.pay_group_lookup_code;
      END IF;
      IF (x_xpiv_rec.vendor_invoice_number = OKL_API.G_MISS_DATE)
      THEN
        x_xpiv_rec.vendor_invoice_number := l_xpiv_rec.vendor_invoice_number;
      END IF;
      IF (x_xpiv_rec.nettable_yn = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.nettable_yn := l_xpiv_rec.nettable_yn;
      END IF;

   -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
      IF (x_xpiv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.legal_entity_id := l_xpiv_rec.legal_entity_id;
      END IF;


      IF (x_xpiv_rec.CNSLD_AP_INV_ID = OKL_API.G_MISS_NUM)
      THEN
        x_xpiv_rec.CNSLD_AP_INV_ID := l_xpiv_rec.CNSLD_AP_INV_ID;
      END IF;



      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xpiv_rec IN  xpiv_rec_type,
      x_xpiv_rec OUT NOCOPY xpiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xpiv_rec := p_xpiv_rec;
      x_xpiv_rec.OBJECT_VERSION_NUMBER := NVL(x_xpiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

      -- Begin PostGen-7
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xpiv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xpiv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xpiv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xpiv_rec.program_update_date,SYSDATE)
      INTO
        x_xpiv_rec.request_id,
        x_xpiv_rec.program_application_id,
        x_xpiv_rec.program_id,
        x_xpiv_rec.program_update_date
      FROM   dual;
      -- End PostGen-7

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
      p_xpiv_rec,                        -- IN
      l_xpiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xpiv_rec, l_def_xpiv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xpiv_rec := fill_who_columns(l_def_xpiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xpiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xpiv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xpiv_rec, l_okl_ext_pay_invs_tl_rec);
    migrate(l_def_xpiv_rec, l_xpi_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_pay_invs_tl_rec,
      lx_okl_ext_pay_invs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_pay_invs_tl_rec, l_def_xpiv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xpi_rec,
      lx_xpi_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xpi_rec, l_def_xpiv_rec);
    x_xpiv_rec := l_def_xpiv_rec;
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
  -- PL/SQL TBL update_row for:XPIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type,
    x_xpiv_tbl                     OUT NOCOPY xpiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xpiv_tbl.COUNT > 0) THEN
      i := p_xpiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xpiv_rec                     => p_xpiv_tbl(i),
          x_xpiv_rec                     => x_xpiv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xpiv_tbl.LAST);
        i := p_xpiv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

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
  -- delete_row for:OKL_EXT_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpi_rec                      IN xpi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpi_rec                      xpi_rec_type:= p_xpi_rec;
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
    DELETE FROM OKL_EXT_PAY_INVS_B
     WHERE ID = l_xpi_rec.id;

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
  -- delete_row for:OKL_EXT_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_pay_invs_tl_rec      IN okl_ext_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type:= p_okl_ext_pay_invs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_pay_invs_tl_rec IN  okl_ext_pay_invs_tl_rec_type,
      x_okl_ext_pay_invs_tl_rec OUT NOCOPY okl_ext_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_pay_invs_tl_rec := p_okl_ext_pay_invs_tl_rec;
      x_okl_ext_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_ext_pay_invs_tl_rec,         -- IN
      l_okl_ext_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_EXT_PAY_INVS_TL
     WHERE ID = l_okl_ext_pay_invs_tl_rec.id;

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
  -- delete_row for:OKL_EXT_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xpiv_rec                     xpiv_rec_type := p_xpiv_rec;
    l_okl_ext_pay_invs_tl_rec      okl_ext_pay_invs_tl_rec_type;
    l_xpi_rec                      xpi_rec_type;
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
    migrate(l_xpiv_rec, l_okl_ext_pay_invs_tl_rec);
    migrate(l_xpiv_rec, l_xpi_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_pay_invs_tl_rec
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
      l_xpi_rec
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
  -- PL/SQL TBL delete_row for:XPIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xpiv_tbl.COUNT > 0) THEN
      i := p_xpiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xpiv_rec                     => p_xpiv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xpiv_tbl.LAST);
        i := p_xpiv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

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
END OKL_XPI_PVT;

/
