--------------------------------------------------------
--  DDL for Package Body OKL_XSI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XSI_PVT" AS
/* $Header: OKLSXSIB.pls 120.4 2007/08/08 12:57:39 arajagop ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_xsiv_rec IN xsiv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_xsiv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xsiv_rec.id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_id;

  --pjgome 11/18/2002 added procedure validate_curr_conv_type
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_curr_conv_type
  ---------------------------------------------------------------------------
  PROCEDURE validate_curr_conv_type (p_xsiv_rec IN xsiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
        --Check FK column
	IF (p_xsiv_rec.currency_conversion_type IS NOT NULL) THEN
	          --uncomment out the below line of code when currency conversion lookup type is finalized
                  --l_return_status := Okl_Util.CHECK_LOOKUP_CODE(--insert the lookup type ,p_xsiv_rec.currency_conversion_type);

		  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
			 Okl_Api.SET_MESSAGE(
				p_app_name	=> G_APP_NAME,
			 	p_msg_name	=> G_NO_PARENT_RECORD,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'CURRENCY_CONVERSION_TYPE',
				p_token2	=> G_CHILD_TABLE_TOKEN,
				p_token2_value	=> G_VIEW,
				p_token3	=> G_PARENT_TABLE_TOKEN,
				p_token3_value	=> 'FND_LOOKUPS');
		  END IF;

	END IF;
	x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_curr_conv_type;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_org_id (p_xsiv_rec IN xsiv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_xsiv_rec.org_id);

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_xsiv_rec IN xsiv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_xsiv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xsiv_rec.id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_object_version_number;

/* commented out because view not defined yet
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_isi_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_isi_id (p_xsiv_rec IN xsiv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_isi_id_csr IS
    SELECT '1'
	FROM OKX_SELL_INVOICES_V
	WHERE id = p_xsiv_rec.isi_id;

  BEGIN
    x_return_status := Okl_api.G_RET_STS_SUCCESS;

    IF (p_tldv_rec.isi_id IS NOT NULL) THEN
	   	  OPEN l_isi_id_csr;
		  FETCH l_isi_id_csr INTO l_dummy_var;
		  CLOSE l_isi_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'ISI_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_EXT_SELL_INVS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_isi_id;
****** End of comment */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_trx_status_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_trx_status_code (p_xsiv_rec IN xsiv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_xsiv_rec.trx_status_code = Okl_Api.G_MISS_CHAR OR
       p_xsiv_rec.trx_status_code IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'trx_status_code');
      RAISE G_EXCEPTION_HALT_VALIDATION;

     END IF;
     x_return_status := Okl_Util.CHECK_LOOKUP_CODE('OKL_TRANSACTION_STATUS',p_xsiv_rec.trx_status_code);
  END validate_trx_status_code;

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
    DELETE FROM OKL_EXT_SELL_INVS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_SELL_INVS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_EXT_SELL_INVS_TL T SET (
        XTRX_CONS_INVOICE_NUMBER,
        XTRX_FORMAT_TYPE,
        XTRX_PRIVATE_LABEL,
        INVOICE_MESSAGE,
        DESCRIPTION) = (SELECT
                                  B.XTRX_CONS_INVOICE_NUMBER,
                                  B.XTRX_FORMAT_TYPE,
                                  B.XTRX_PRIVATE_LABEL,
                                  B.INVOICE_MESSAGE,
                                  B.DESCRIPTION
                                FROM OKL_EXT_SELL_INVS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_EXT_SELL_INVS_TL SUBB, OKL_EXT_SELL_INVS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.XTRX_CONS_INVOICE_NUMBER <> SUBT.XTRX_CONS_INVOICE_NUMBER
                      OR SUBB.XTRX_FORMAT_TYPE <> SUBT.XTRX_FORMAT_TYPE
                      OR SUBB.XTRX_PRIVATE_LABEL <> SUBT.XTRX_PRIVATE_LABEL
                      OR SUBB.INVOICE_MESSAGE <> SUBT.INVOICE_MESSAGE
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.XTRX_CONS_INVOICE_NUMBER IS NULL AND SUBT.XTRX_CONS_INVOICE_NUMBER IS NOT NULL)
                      OR (SUBB.XTRX_CONS_INVOICE_NUMBER IS NOT NULL AND SUBT.XTRX_CONS_INVOICE_NUMBER IS NULL)
                      OR (SUBB.XTRX_FORMAT_TYPE IS NULL AND SUBT.XTRX_FORMAT_TYPE IS NOT NULL)
                      OR (SUBB.XTRX_FORMAT_TYPE IS NOT NULL AND SUBT.XTRX_FORMAT_TYPE IS NULL)
                      OR (SUBB.XTRX_PRIVATE_LABEL IS NULL AND SUBT.XTRX_PRIVATE_LABEL IS NOT NULL)
                      OR (SUBB.XTRX_PRIVATE_LABEL IS NOT NULL AND SUBT.XTRX_PRIVATE_LABEL IS NULL)
                      OR (SUBB.INVOICE_MESSAGE IS NULL AND SUBT.INVOICE_MESSAGE IS NOT NULL)
                      OR (SUBB.INVOICE_MESSAGE IS NOT NULL AND SUBT.INVOICE_MESSAGE IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_EXT_SELL_INVS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        XTRX_CONS_INVOICE_NUMBER,
        XTRX_FORMAT_TYPE,
        XTRX_PRIVATE_LABEL,
        INVOICE_MESSAGE,
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
            B.XTRX_CONS_INVOICE_NUMBER,
            B.XTRX_FORMAT_TYPE,
            B.XTRX_PRIVATE_LABEL,
            B.INVOICE_MESSAGE,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_EXT_SELL_INVS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_EXT_SELL_INVS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_SELL_INVS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xsi_rec                      IN xsi_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xsi_rec_type IS
    CURSOR okl_ext_sell_invs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ISI_ID,
            OBJECT_VERSION_NUMBER,
            RECEIVABLES_INVOICE_ID,
            SET_OF_BOOKS_ID,
            TRX_DATE,
            CURRENCY_CODE,
    --Start change by pgomes on 19-NOV-2002
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 19-NOV-2002
            CUSTOMER_ID,
            RECEIPT_METHOD_ID,
            TERM_ID,
            CUSTOMER_ADDRESS_ID,
            CUST_TRX_TYPE_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            inf_id,
/*              khr_id,  */
/*              clg_id,  */
/*              cpy_id,  */
/*              qte_id,                                      */
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
            REFERENCE_LINE_ID,
            TRX_NUMBER,
            CUSTOMER_BANK_ACCOUNT_ID,
            TAX_EXEMPT_FLAG,
            TAX_EXEMPT_REASON_CODE,
            XTRX_INVOICE_PULL_YN,
            TRX_STATUS_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Sell_Invs_B
     WHERE okl_ext_sell_invs_b.id = p_id;
    l_okl_ext_sell_invs_b_pk       okl_ext_sell_invs_b_pk_csr%ROWTYPE;
    l_xsi_rec                      xsi_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_sell_invs_b_pk_csr (p_xsi_rec.id);
    FETCH okl_ext_sell_invs_b_pk_csr INTO
              l_xsi_rec.ID,
              l_xsi_rec.ISI_ID,
              l_xsi_rec.OBJECT_VERSION_NUMBER,
              l_xsi_rec.RECEIVABLES_INVOICE_ID,
              l_xsi_rec.SET_OF_BOOKS_ID,
              l_xsi_rec.TRX_DATE,
              l_xsi_rec.CURRENCY_CODE,
    --Start change by pgomes on 19-NOV-2002
              l_xsi_rec.CURRENCY_CONVERSION_TYPE,
              l_xsi_rec.CURRENCY_CONVERSION_RATE,
              l_xsi_rec.CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 19-NOV-2002
              l_xsi_rec.CUSTOMER_ID,
              l_xsi_rec.RECEIPT_METHOD_ID,
              l_xsi_rec.TERM_ID,
              l_xsi_rec.CUSTOMER_ADDRESS_ID,
              l_xsi_rec.CUST_TRX_TYPE_ID,
              l_xsi_rec.REQUEST_ID,
              l_xsi_rec.PROGRAM_APPLICATION_ID,
              l_xsi_rec.PROGRAM_ID,
              l_xsi_rec.PROGRAM_UPDATE_DATE,
              l_xsi_rec.ORG_ID,
              l_xsi_rec.inf_ID,
/*                l_xsi_rec.khr_ID,                       */
/*                l_xsi_rec.clg_id,  */
/*                l_xsi_rec.cpy_id,  */
/*                l_xsi_rec.qte_id,                                                          */
              l_xsi_rec.ATTRIBUTE_CATEGORY,
              l_xsi_rec.ATTRIBUTE1,
              l_xsi_rec.ATTRIBUTE2,
              l_xsi_rec.ATTRIBUTE3,
              l_xsi_rec.ATTRIBUTE4,
              l_xsi_rec.ATTRIBUTE5,
              l_xsi_rec.ATTRIBUTE6,
              l_xsi_rec.ATTRIBUTE7,
              l_xsi_rec.ATTRIBUTE8,
              l_xsi_rec.ATTRIBUTE9,
              l_xsi_rec.ATTRIBUTE10,
              l_xsi_rec.ATTRIBUTE11,
              l_xsi_rec.ATTRIBUTE12,
              l_xsi_rec.ATTRIBUTE13,
              l_xsi_rec.ATTRIBUTE14,
              l_xsi_rec.ATTRIBUTE15,
              l_xsi_rec.REFERENCE_LINE_ID,
              l_xsi_rec.TRX_NUMBER,
              l_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID,
              l_xsi_rec.TAX_EXEMPT_FLAG,
              l_xsi_rec.TAX_EXEMPT_REASON_CODE,
              l_xsi_rec.XTRX_INVOICE_PULL_YN,
              l_xsi_rec.TRX_STATUS_CODE,
              l_xsi_rec.CREATED_BY,
              l_xsi_rec.CREATION_DATE,
              l_xsi_rec.LAST_UPDATED_BY,
              l_xsi_rec.LAST_UPDATE_DATE,
              l_xsi_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ext_sell_invs_b_pk_csr%NOTFOUND;
    CLOSE okl_ext_sell_invs_b_pk_csr;
    RETURN(l_xsi_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xsi_rec                      IN xsi_rec_type
  ) RETURN xsi_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xsi_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_SELL_INVS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_ext_sell_invs_tl_rec_type IS
    CURSOR okl_ext_sell_invs_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            XTRX_CONS_INVOICE_NUMBER,
            XTRX_FORMAT_TYPE,
            XTRX_PRIVATE_LABEL,
            INVOICE_MESSAGE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Sell_Invs_Tl
     WHERE okl_ext_sell_invs_tl.id = p_id
       AND okl_ext_sell_invs_tl.LANGUAGE = p_language;
    l_okl_ext_sell_invs_tl_pk      okl_ext_sell_invs_tl_pk_csr%ROWTYPE;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_sell_invs_tl_pk_csr (p_okl_ext_sell_invs_tl_rec.id,
                                      p_okl_ext_sell_invs_tl_rec.LANGUAGE);
    FETCH okl_ext_sell_invs_tl_pk_csr INTO
              l_okl_ext_sell_invs_tl_rec.ID,
              l_okl_ext_sell_invs_tl_rec.LANGUAGE,
              l_okl_ext_sell_invs_tl_rec.SOURCE_LANG,
              l_okl_ext_sell_invs_tl_rec.SFWT_FLAG,
              l_okl_ext_sell_invs_tl_rec.XTRX_CONS_INVOICE_NUMBER,
              l_okl_ext_sell_invs_tl_rec.XTRX_FORMAT_TYPE,
              l_okl_ext_sell_invs_tl_rec.XTRX_PRIVATE_LABEL,
              l_okl_ext_sell_invs_tl_rec.INVOICE_MESSAGE,
              l_okl_ext_sell_invs_tl_rec.DESCRIPTION,
              l_okl_ext_sell_invs_tl_rec.CREATED_BY,
              l_okl_ext_sell_invs_tl_rec.CREATION_DATE,
              l_okl_ext_sell_invs_tl_rec.LAST_UPDATED_BY,
              l_okl_ext_sell_invs_tl_rec.LAST_UPDATE_DATE,
              l_okl_ext_sell_invs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ext_sell_invs_tl_pk_csr%NOTFOUND;
    CLOSE okl_ext_sell_invs_tl_pk_csr;
    RETURN(l_okl_ext_sell_invs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type
  ) RETURN okl_ext_sell_invs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_ext_sell_invs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_SELL_INVS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xsiv_rec                     IN xsiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xsiv_rec_type IS
    CURSOR okl_xsiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ISI_ID,
            TRX_DATE,
            CUSTOMER_ID,
            RECEIPT_METHOD_ID,
            TERM_ID,
            CURRENCY_CODE,
    --Start change by pgomes on 19-NOV-2002
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 19-NOV-2002
            CUSTOMER_ADDRESS_ID,
            SET_OF_BOOKS_ID,
            RECEIVABLES_INVOICE_ID,
            CUST_TRX_TYPE_ID,
            INVOICE_MESSAGE,
            DESCRIPTION,
            XTRX_CONS_INVOICE_NUMBER,
            XTRX_FORMAT_TYPE,
            XTRX_PRIVATE_LABEL,
            inf_id,
/*              khr_id,              */
/*              clg_id,  */
/*              cpy_id,  */
/*              qte_id,              */
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
            REFERENCE_LINE_ID,
            TRX_NUMBER,
            CUSTOMER_BANK_ACCOUNT_ID,
            TAX_EXEMPT_FLAG,
            TAX_EXEMPT_REASON_CODE,
            XTRX_INVOICE_PULL_YN,
            TRX_STATUS_CODE,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Sell_Invs_V
     WHERE okl_ext_sell_invs_v.id = p_id;
    l_okl_xsiv_pk                  okl_xsiv_pk_csr%ROWTYPE;
    l_xsiv_rec                     xsiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xsiv_pk_csr (p_xsiv_rec.id);
    FETCH okl_xsiv_pk_csr INTO
              l_xsiv_rec.ID,
              l_xsiv_rec.OBJECT_VERSION_NUMBER,
              l_xsiv_rec.SFWT_FLAG,
              l_xsiv_rec.ISI_ID,
              l_xsiv_rec.TRX_DATE,
              l_xsiv_rec.CUSTOMER_ID,
              l_xsiv_rec.RECEIPT_METHOD_ID,
              l_xsiv_rec.TERM_ID,
              l_xsiv_rec.CURRENCY_CODE,
    --Start change by pgomes on 19-NOV-2002
              l_xsiv_rec.CURRENCY_CONVERSION_TYPE,
              l_xsiv_rec.CURRENCY_CONVERSION_RATE,
              l_xsiv_rec.CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 19-NOV-2002
              l_xsiv_rec.CUSTOMER_ADDRESS_ID,
              l_xsiv_rec.SET_OF_BOOKS_ID,
              l_xsiv_rec.RECEIVABLES_INVOICE_ID,
              l_xsiv_rec.CUST_TRX_TYPE_ID,
              l_xsiv_rec.INVOICE_MESSAGE,
              l_xsiv_rec.DESCRIPTION,
              l_xsiv_rec.XTRX_CONS_INVOICE_NUMBER,
              l_xsiv_rec.XTRX_FORMAT_TYPE,
              l_xsiv_rec.XTRX_PRIVATE_LABEL,
              l_xsiv_rec.inf_id,
/*                l_xsiv_rec.khr_id,                           */
/*                l_xsiv_rec.clg_id,  */
/*                l_xsiv_rec.cpy_id,  */
/*                l_xsiv_rec.qte_id,                                                  */
              l_xsiv_rec.ATTRIBUTE_CATEGORY,
              l_xsiv_rec.ATTRIBUTE1,
              l_xsiv_rec.ATTRIBUTE2,
              l_xsiv_rec.ATTRIBUTE3,
              l_xsiv_rec.ATTRIBUTE4,
              l_xsiv_rec.ATTRIBUTE5,
              l_xsiv_rec.ATTRIBUTE6,
              l_xsiv_rec.ATTRIBUTE7,
              l_xsiv_rec.ATTRIBUTE8,
              l_xsiv_rec.ATTRIBUTE9,
              l_xsiv_rec.ATTRIBUTE10,
              l_xsiv_rec.ATTRIBUTE11,
              l_xsiv_rec.ATTRIBUTE12,
              l_xsiv_rec.ATTRIBUTE13,
              l_xsiv_rec.ATTRIBUTE14,
              l_xsiv_rec.ATTRIBUTE15,
              l_xsiv_rec.REFERENCE_LINE_ID,
              l_xsiv_rec.TRX_NUMBER,
              l_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID,
              l_xsiv_rec.TAX_EXEMPT_FLAG,
              l_xsiv_rec.TAX_EXEMPT_REASON_CODE,
              l_xsiv_rec.XTRX_INVOICE_PULL_YN,
              l_xsiv_rec.TRX_STATUS_CODE,
              l_xsiv_rec.REQUEST_ID,
              l_xsiv_rec.PROGRAM_APPLICATION_ID,
              l_xsiv_rec.PROGRAM_ID,
              l_xsiv_rec.PROGRAM_UPDATE_DATE,
              l_xsiv_rec.ORG_ID,
              l_xsiv_rec.CREATED_BY,
              l_xsiv_rec.CREATION_DATE,
              l_xsiv_rec.LAST_UPDATED_BY,
              l_xsiv_rec.LAST_UPDATE_DATE,
              l_xsiv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xsiv_pk_csr%NOTFOUND;
    CLOSE okl_xsiv_pk_csr;
    RETURN(l_xsiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xsiv_rec                     IN xsiv_rec_type
  ) RETURN xsiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xsiv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_EXT_SELL_INVS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xsiv_rec	IN xsiv_rec_type
  ) RETURN xsiv_rec_type IS
    l_xsiv_rec	xsiv_rec_type := p_xsiv_rec;
  BEGIN
    IF (l_xsiv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.object_version_number := NULL;
    END IF;
    IF (l_xsiv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_xsiv_rec.isi_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.isi_id := NULL;
    END IF;
    IF (l_xsiv_rec.trx_date = Okl_Api.G_MISS_DATE) THEN
      l_xsiv_rec.trx_date := NULL;
    END IF;
    IF (l_xsiv_rec.customer_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.customer_id := NULL;
    END IF;
    IF (l_xsiv_rec.receipt_method_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.receipt_method_id := NULL;
    END IF;
    IF (l_xsiv_rec.term_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.term_id := NULL;
    END IF;
    IF (l_xsiv_rec.currency_code = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.currency_code := NULL;
    END IF;

    --Start change by pgomes on 19-NOV-2002
    IF (l_xsiv_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.currency_conversion_type := NULL;
    END IF;

    IF (l_xsiv_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.currency_conversion_rate := NULL;
    END IF;

    IF (l_xsiv_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
      l_xsiv_rec.currency_conversion_date := NULL;
    END IF;
    --End change by pgomes on 19-NOV-2002

    IF (l_xsiv_rec.customer_address_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.customer_address_id := NULL;
    END IF;
    IF (l_xsiv_rec.set_of_books_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_xsiv_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.receivables_invoice_id := NULL;
    END IF;
    IF (l_xsiv_rec.cust_trx_type_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.cust_trx_type_id := NULL;
    END IF;
    IF (l_xsiv_rec.invoice_message = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.invoice_message := NULL;
    END IF;
    IF (l_xsiv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.description := NULL;
    END IF;
    IF (l_xsiv_rec.xtrx_cons_invoice_number = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.xtrx_cons_invoice_number := NULL;
    END IF;
    IF (l_xsiv_rec.xtrx_format_type = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.xtrx_format_type := NULL;
    END IF;
    IF (l_xsiv_rec.xtrx_private_label = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.xtrx_private_label := NULL;
    END IF;

    IF (l_xsiv_rec.inf_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.inf_id := NULL;
    END IF;

/*      IF (l_xsiv_rec.khr_id = Okl_Api.G_MISS_NUM) THEN  */
/*        l_xsiv_rec.khr_id := NULL;  */
/*      END IF;  */
/*        */
/*      IF (l_xsiv_rec.clg_id = Okl_Api.G_MISS_NUM) THEN  */
/*        l_xsiv_rec.clg_id := NULL;  */
/*      END IF;  */
/*      IF (l_xsiv_rec.cpy_id = Okl_Api.G_MISS_NUM) THEN  */
/*        l_xsiv_rec.cpy_id := NULL;  */
/*      END IF;  */
/*      IF (l_xsiv_rec.qte_id = Okl_Api.G_MISS_NUM) THEN  */
/*        l_xsiv_rec.qte_id := NULL;  */
/*      END IF;  */

    IF (l_xsiv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute_category := NULL;
    END IF;
    IF (l_xsiv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute1 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute2 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute3 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute4 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute5 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute6 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute7 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute8 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute9 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute10 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute11 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute12 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute13 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute14 := NULL;
    END IF;
    IF (l_xsiv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.attribute15 := NULL;
    END IF;
    IF (l_xsiv_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.REFERENCE_LINE_ID := NULL;
    END IF;
    IF (l_xsiv_rec.TRX_NUMBER = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.TRX_NUMBER := NULL;
    END IF;
    IF (l_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID := NULL;
    END IF;
    IF (l_xsiv_rec.TAX_EXEMPT_FLAG = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.TAX_EXEMPT_FLAG := NULL;
    END IF;
    IF (l_xsiv_rec.TAX_EXEMPT_REASON_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.TAX_EXEMPT_REASON_CODE := NULL;
    END IF;
    IF (l_xsiv_rec.XTRX_INVOICE_PULL_YN = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.XTRX_INVOICE_PULL_YN := NULL;
    END IF;
    IF (l_xsiv_rec.TRX_STATUS_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_xsiv_rec.TRX_STATUS_CODE := NULL;
    END IF;
    IF (l_xsiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.request_id := NULL;
    END IF;
    IF (l_xsiv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.program_application_id := NULL;
    END IF;
    IF (l_xsiv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.program_id := NULL;
    END IF;
    IF (l_xsiv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xsiv_rec.program_update_date := NULL;
    END IF;
    IF (l_xsiv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.org_id := NULL;
    END IF;
    IF (l_xsiv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.created_by := NULL;
    END IF;
    IF (l_xsiv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_xsiv_rec.creation_date := NULL;
    END IF;
    IF (l_xsiv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xsiv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xsiv_rec.last_update_date := NULL;
    END IF;
    IF (l_xsiv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_xsiv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_xsiv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_EXT_SELL_INVS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_xsiv_rec IN  xsiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Added 04/17/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

--    validate_isi_id(p_xsiv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_id(p_xsiv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    --Start code added by pgomes on 19-NOV-2002
    validate_curr_conv_type(p_xsiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    --End code added by pgomes on 19-NOV-2002

	validate_object_version_number(p_xsiv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id (p_xsiv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_trx_status_code (p_xsiv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_EXT_SELL_INVS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_xsiv_rec IN xsiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN xsiv_rec_type,
    p_to	IN OUT NOCOPY xsi_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.isi_id := p_from.isi_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.trx_date := p_from.trx_date;
    p_to.currency_code := p_from.currency_code;

    --Start change by pgomes on 19-NOV-2002
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    --End change by pgomes on 19-NOV-2002

    p_to.customer_id := p_from.customer_id;
    p_to.receipt_method_id := p_from.receipt_method_id;
    p_to.term_id := p_from.term_id;
    p_to.customer_address_id := p_from.customer_address_id;
    p_to.cust_trx_type_id := p_from.cust_trx_type_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inf_id := p_from.inf_id;
/*      p_to.khr_id := p_from.khr_id;                */
/*      p_to.clg_id := p_from.clg_id;            */
/*      p_to.cpy_id := p_from.cpy_id;            */
/*      p_to.qte_id := p_from.qte_id;                                    */
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
    p_to.REFERENCE_LINE_ID := p_from.REFERENCE_LINE_ID;
    p_to.TRX_NUMBER := p_from.TRX_NUMBER;
    p_to.CUSTOMER_BANK_ACCOUNT_ID := p_from.CUSTOMER_BANK_ACCOUNT_ID;
    p_to.TAX_EXEMPT_FLAG := p_from.TAX_EXEMPT_FLAG;
    p_to.TAX_EXEMPT_REASON_CODE := p_from.TAX_EXEMPT_REASON_CODE;
    p_to.XTRX_INVOICE_PULL_YN := p_from.XTRX_INVOICE_PULL_YN;
    p_to.TRX_STATUS_CODE := p_from.TRX_STATUS_CODE;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN xsi_rec_type,
    p_to	IN OUT NOCOPY xsiv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.isi_id := p_from.isi_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.trx_date := p_from.trx_date;
    p_to.currency_code := p_from.currency_code;

    --Start change by pgomes on 19-NOV-2002
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    --End change by pgomes on 19-NOV-2002

    p_to.customer_id := p_from.customer_id;
    p_to.receipt_method_id := p_from.receipt_method_id;
    p_to.term_id := p_from.term_id;
    p_to.customer_address_id := p_from.customer_address_id;
    p_to.cust_trx_type_id := p_from.cust_trx_type_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inf_id := p_from.inf_id;
/*      p_to.khr_id := p_from.khr_id;         */
/*      p_to.clg_id := p_from.clg_id;     */
/*      p_to.cpy_id := p_from.cpy_id;     */
/*      p_to.qte_id := p_from.qte_id;                                       */
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
    p_to.REFERENCE_LINE_ID := p_from.REFERENCE_LINE_ID;
    p_to.TRX_NUMBER := p_from.TRX_NUMBER;
    p_to.CUSTOMER_BANK_ACCOUNT_ID := p_from.CUSTOMER_BANK_ACCOUNT_ID;
    p_to.TAX_EXEMPT_FLAG := p_from.TAX_EXEMPT_FLAG;
    p_to.TAX_EXEMPT_REASON_CODE := p_from.TAX_EXEMPT_REASON_CODE;
    p_to.XTRX_INVOICE_PULL_YN := p_from.XTRX_INVOICE_PULL_YN;
    p_to.TRX_STATUS_CODE := p_from.TRX_STATUS_CODE;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN xsiv_rec_type,
    p_to	IN OUT NOCOPY okl_ext_sell_invs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.xtrx_cons_invoice_number := p_from.xtrx_cons_invoice_number;
    p_to.xtrx_format_type := p_from.xtrx_format_type;
    p_to.xtrx_private_label := p_from.xtrx_private_label;
    p_to.invoice_message := p_from.invoice_message;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_ext_sell_invs_tl_rec_type,
    p_to	IN OUT NOCOPY xsiv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.xtrx_cons_invoice_number := p_from.xtrx_cons_invoice_number;
    p_to.xtrx_format_type := p_from.xtrx_format_type;
    p_to.xtrx_private_label := p_from.xtrx_private_label;
    p_to.invoice_message := p_from.invoice_message;
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
  -- validate_row for:OKL_EXT_SELL_INVS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsiv_rec                     xsiv_rec_type := p_xsiv_rec;
    l_xsi_rec                      xsi_rec_type;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_xsiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xsiv_rec);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:XSIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xsiv_tbl.COUNT > 0) THEN
      i := p_xsiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xsiv_rec                     => p_xsiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xsiv_tbl.LAST);
        i := p_xsiv_tbl.NEXT(i);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_EXT_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsi_rec                      IN xsi_rec_type,
    x_xsi_rec                      OUT NOCOPY xsi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsi_rec                      xsi_rec_type := p_xsi_rec;
    l_def_xsi_rec                  xsi_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xsi_rec IN  xsi_rec_type,
      x_xsi_rec OUT NOCOPY xsi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xsi_rec := p_xsi_rec;
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
      p_xsi_rec,                         -- IN
      l_xsi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_SELL_INVS_B(
        id,
        isi_id,
        object_version_number,
        receivables_invoice_id,
        set_of_books_id,
        trx_date,
        currency_code,
    --Start change by pgomes on 19-NOV-2002
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
    --End change by pgomes on 19-NOV-2002
        customer_id,
        receipt_method_id,
        term_id,
        customer_address_id,
        cust_trx_type_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        inf_id,
/*          khr_id,  */
/*          clg_id,  */
/*          cpy_id,  */
/*          qte_id,          */
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
        REFERENCE_LINE_ID,
        CUSTOMER_BANK_ACCOUNT_ID,
        TRX_NUMBER,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        trx_status_code,
        tax_exempt_flag,
        tax_exempt_reason_code,
        xtrx_invoice_pull_yn
)
      VALUES (
        l_xsi_rec.id,
        l_xsi_rec.isi_id,
        l_xsi_rec.object_version_number,
        l_xsi_rec.receivables_invoice_id,
        l_xsi_rec.set_of_books_id,
        l_xsi_rec.trx_date,
        l_xsi_rec.currency_code,
    --Start change by pgomes on 19-NOV-2002
        l_xsi_rec.currency_conversion_type,
        l_xsi_rec.currency_conversion_rate,
        l_xsi_rec.currency_conversion_date,
    --End change by pgomes on 19-NOV-2002
        l_xsi_rec.customer_id,
        l_xsi_rec.receipt_method_id,
        l_xsi_rec.term_id,
        l_xsi_rec.customer_address_id,
        l_xsi_rec.cust_trx_type_id,
        l_xsi_rec.request_id,
        l_xsi_rec.program_application_id,
        l_xsi_rec.program_id,
        l_xsi_rec.program_update_date,
        l_xsi_rec.org_id,
        l_xsi_rec.inf_id,
/*          l_xsi_rec.khr_id,                    */
/*          l_xsi_rec.clg_id,  */
/*          l_xsi_rec.cpy_id,  */
/*          l_xsi_rec.qte_id,                      */
        l_xsi_rec.attribute_category,
        l_xsi_rec.attribute1,
        l_xsi_rec.attribute2,
        l_xsi_rec.attribute3,
        l_xsi_rec.attribute4,
        l_xsi_rec.attribute5,
        l_xsi_rec.attribute6,
        l_xsi_rec.attribute7,
        l_xsi_rec.attribute8,
        l_xsi_rec.attribute9,
        l_xsi_rec.attribute10,
        l_xsi_rec.attribute11,
        l_xsi_rec.attribute12,
        l_xsi_rec.attribute13,
        l_xsi_rec.attribute14,
        l_xsi_rec.attribute15,
        l_xsi_rec.REFERENCE_LINE_ID,
        l_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID,
        l_xsi_rec.TRX_NUMBER,
        l_xsi_rec.created_by,
        l_xsi_rec.creation_date,
        l_xsi_rec.last_updated_by,
        l_xsi_rec.last_update_date,
        l_xsi_rec.last_update_login,
        l_xsi_rec.trx_status_code,
        l_xsi_rec.tax_exempt_flag,
        l_xsi_rec.tax_exempt_reason_code,
        l_xsi_rec.xtrx_invoice_pull_yn
		);
    -- Set OUT values
    x_xsi_rec := l_xsi_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_EXT_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type,
    x_okl_ext_sell_invs_tl_rec     OUT NOCOPY okl_ext_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type := p_okl_ext_sell_invs_tl_rec;
    ldefoklextsellinvstlrec        okl_ext_sell_invs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_sell_invs_tl_rec IN  okl_ext_sell_invs_tl_rec_type,
      x_okl_ext_sell_invs_tl_rec OUT NOCOPY okl_ext_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_sell_invs_tl_rec := p_okl_ext_sell_invs_tl_rec;
      x_okl_ext_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ext_sell_invs_tl_rec,        -- IN
      l_okl_ext_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_ext_sell_invs_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_EXT_SELL_INVS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          xtrx_cons_invoice_number,
          xtrx_format_type,
          xtrx_private_label,
          invoice_message,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ext_sell_invs_tl_rec.id,
          l_okl_ext_sell_invs_tl_rec.LANGUAGE,
          l_okl_ext_sell_invs_tl_rec.source_lang,
          l_okl_ext_sell_invs_tl_rec.sfwt_flag,
          l_okl_ext_sell_invs_tl_rec.xtrx_cons_invoice_number,
          l_okl_ext_sell_invs_tl_rec.xtrx_format_type,
          l_okl_ext_sell_invs_tl_rec.xtrx_private_label,
          l_okl_ext_sell_invs_tl_rec.invoice_message,
          l_okl_ext_sell_invs_tl_rec.description,
          l_okl_ext_sell_invs_tl_rec.created_by,
          l_okl_ext_sell_invs_tl_rec.creation_date,
          l_okl_ext_sell_invs_tl_rec.last_updated_by,
          l_okl_ext_sell_invs_tl_rec.last_update_date,
          l_okl_ext_sell_invs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_ext_sell_invs_tl_rec := l_okl_ext_sell_invs_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_EXT_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type,
    x_xsiv_rec                     OUT NOCOPY xsiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsiv_rec                     xsiv_rec_type;
    l_def_xsiv_rec                 xsiv_rec_type;
    l_xsi_rec                      xsi_rec_type;
    lx_xsi_rec                     xsi_rec_type;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
    lx_okl_ext_sell_invs_tl_rec    okl_ext_sell_invs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xsiv_rec	IN xsiv_rec_type
    ) RETURN xsiv_rec_type IS
      l_xsiv_rec	xsiv_rec_type := p_xsiv_rec;
    BEGIN
      l_xsiv_rec.CREATION_DATE := SYSDATE;
      l_xsiv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_xsiv_rec.LAST_UPDATE_DATE := l_xsiv_rec.CREATION_DATE;
      l_xsiv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xsiv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xsiv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xsiv_rec IN  xsiv_rec_type,
      x_xsiv_rec OUT NOCOPY xsiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN

      x_xsiv_rec := p_xsiv_rec;
      x_xsiv_rec.OBJECT_VERSION_NUMBER := 1;
      x_xsiv_rec.SFWT_FLAG := 'N';

	IF (x_xsiv_rec.request_id IS NULL OR x_xsiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_xsiv_rec.request_id,
	  	   x_xsiv_rec.program_application_id,
	  	   x_xsiv_rec.program_id,
	  	   x_xsiv_rec.program_update_date
	  FROM dual;
	END IF;

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
    l_xsiv_rec := null_out_defaults(p_xsiv_rec);
    -- Set primary key value
    l_xsiv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xsiv_rec,                        -- IN
      l_def_xsiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xsiv_rec := fill_who_columns(l_def_xsiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xsiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xsiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xsiv_rec, l_xsi_rec);
    migrate(l_def_xsiv_rec, l_okl_ext_sell_invs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xsi_rec,
      lx_xsi_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xsi_rec, l_def_xsiv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_sell_invs_tl_rec,
      lx_okl_ext_sell_invs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_sell_invs_tl_rec, l_def_xsiv_rec);
    -- Set OUT values
    x_xsiv_rec := l_def_xsiv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:XSIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type,
    x_xsiv_tbl                     OUT NOCOPY xsiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xsiv_tbl.COUNT > 0) THEN
      i := p_xsiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xsiv_rec                     => p_xsiv_tbl(i),
          x_xsiv_rec                     => x_xsiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xsiv_tbl.LAST);
        i := p_xsiv_tbl.NEXT(i);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_EXT_SELL_INVS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsi_rec                      IN xsi_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xsi_rec IN xsi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_SELL_INVS_B
     WHERE ID = p_xsi_rec.id
       AND OBJECT_VERSION_NUMBER = p_xsi_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xsi_rec IN xsi_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_SELL_INVS_B
    WHERE ID = p_xsi_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_EXT_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_EXT_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_xsi_rec);
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
      OPEN lchk_csr(p_xsi_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xsi_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xsi_rec.object_version_number THEN
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_EXT_SELL_INVS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_ext_sell_invs_tl_rec IN okl_ext_sell_invs_tl_rec_type) IS
    SELECT *
      FROM OKL_EXT_SELL_INVS_TL
     WHERE ID = p_okl_ext_sell_invs_tl_rec.id
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
      OPEN lock_csr(p_okl_ext_sell_invs_tl_rec);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_EXT_SELL_INVS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsi_rec                      xsi_rec_type;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
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
    migrate(p_xsiv_rec, l_xsi_rec);
    migrate(p_xsiv_rec, l_okl_ext_sell_invs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xsi_rec
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
      l_okl_ext_sell_invs_tl_rec
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:XSIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xsiv_tbl.COUNT > 0) THEN
      i := p_xsiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xsiv_rec                     => p_xsiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xsiv_tbl.LAST);
        i := p_xsiv_tbl.NEXT(i);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_EXT_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsi_rec                      IN xsi_rec_type,
    x_xsi_rec                      OUT NOCOPY xsi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsi_rec                      xsi_rec_type := p_xsi_rec;
    l_def_xsi_rec                  xsi_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xsi_rec	IN xsi_rec_type,
      x_xsi_rec	OUT NOCOPY xsi_rec_type
    ) RETURN VARCHAR2 IS
      l_xsi_rec                      xsi_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xsi_rec := p_xsi_rec;
      -- Get current database values
      l_xsi_rec := get_rec(p_xsi_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xsi_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.id := l_xsi_rec.id;
      END IF;
      IF (x_xsi_rec.isi_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.isi_id := l_xsi_rec.isi_id;
      END IF;
      IF (x_xsi_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.object_version_number := l_xsi_rec.object_version_number;
      END IF;
      IF (x_xsi_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.receivables_invoice_id := l_xsi_rec.receivables_invoice_id;
      END IF;
      IF (x_xsi_rec.set_of_books_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.set_of_books_id := l_xsi_rec.set_of_books_id;
      END IF;
      IF (x_xsi_rec.trx_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsi_rec.trx_date := l_xsi_rec.trx_date;
      END IF;
      IF (x_xsi_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.currency_code := l_xsi_rec.currency_code;
      END IF;

      --Start change by pgomes on 19-NOV-2002
      IF (x_xsi_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
        x_xsi_rec.currency_conversion_type := l_xsi_rec.currency_conversion_type;
      END IF;

      IF (x_xsi_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
        x_xsi_rec.currency_conversion_rate := l_xsi_rec.currency_conversion_rate;
      END IF;

      IF (x_xsi_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
        x_xsi_rec.currency_conversion_date := l_xsi_rec.currency_conversion_date;
      END IF;
      --End change by pgomes on 19-NOV-2002

      IF (x_xsi_rec.customer_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.customer_id := l_xsi_rec.customer_id;
      END IF;
      IF (x_xsi_rec.receipt_method_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.receipt_method_id := l_xsi_rec.receipt_method_id;
      END IF;
      IF (x_xsi_rec.term_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.term_id := l_xsi_rec.term_id;
      END IF;
      IF (x_xsi_rec.customer_address_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.customer_address_id := l_xsi_rec.customer_address_id;
      END IF;
      IF (x_xsi_rec.cust_trx_type_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.cust_trx_type_id := l_xsi_rec.cust_trx_type_id;
      END IF;
      IF (x_xsi_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.request_id := l_xsi_rec.request_id;
      END IF;
      IF (x_xsi_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.program_application_id := l_xsi_rec.program_application_id;
      END IF;
      IF (x_xsi_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.program_id := l_xsi_rec.program_id;
      END IF;
      IF (x_xsi_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsi_rec.program_update_date := l_xsi_rec.program_update_date;
      END IF;

      IF (x_xsi_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.org_id := l_xsi_rec.org_id;
      END IF;

      IF (x_xsi_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.inf_id := l_xsi_rec.inf_id;
      END IF;

/*        IF (x_xsi_rec.khr_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsi_rec.khr_id := l_xsi_rec.khr_id;  */
/*        END IF;  */
/*    */
/*        IF (x_xsi_rec.clg_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsi_rec.clg_id := l_xsi_rec.clg_id;  */
/*        END IF;  */
/*    */
/*        IF (x_xsi_rec.cpy_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsi_rec.cpy_id := l_xsi_rec.cpy_id;  */
/*        END IF;  */
/*    */
/*        IF (x_xsi_rec.qte_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsi_rec.qte_id := l_xsi_rec.qte_id;  */
/*        END IF;        */

      IF (x_xsi_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute_category := l_xsi_rec.attribute_category;
      END IF;
      IF (x_xsi_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute1 := l_xsi_rec.attribute1;
      END IF;
      IF (x_xsi_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute2 := l_xsi_rec.attribute2;
      END IF;
      IF (x_xsi_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute3 := l_xsi_rec.attribute3;
      END IF;
      IF (x_xsi_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute4 := l_xsi_rec.attribute4;
      END IF;
      IF (x_xsi_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute5 := l_xsi_rec.attribute5;
      END IF;
      IF (x_xsi_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute6 := l_xsi_rec.attribute6;
      END IF;
      IF (x_xsi_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute7 := l_xsi_rec.attribute7;
      END IF;
      IF (x_xsi_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute8 := l_xsi_rec.attribute8;
      END IF;
      IF (x_xsi_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute9 := l_xsi_rec.attribute9;
      END IF;
      IF (x_xsi_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute10 := l_xsi_rec.attribute10;
      END IF;
      IF (x_xsi_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute11 := l_xsi_rec.attribute11;
      END IF;
      IF (x_xsi_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute12 := l_xsi_rec.attribute12;
      END IF;
      IF (x_xsi_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute13 := l_xsi_rec.attribute13;
      END IF;
      IF (x_xsi_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute14 := l_xsi_rec.attribute14;
      END IF;
      IF (x_xsi_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.attribute15 := l_xsi_rec.attribute15;
      END IF;
      IF (x_xsi_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.REFERENCE_LINE_ID := l_xsi_rec.REFERENCE_LINE_ID;
      END IF;
      IF (x_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID := l_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID;
      END IF;
      IF (x_xsi_rec.TRX_NUMBER = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.TRX_NUMBER := l_xsi_rec.TRX_NUMBER;
      END IF;
      IF (x_xsi_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.created_by := l_xsi_rec.created_by;
      END IF;
      IF (x_xsi_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsi_rec.creation_date := l_xsi_rec.creation_date;
      END IF;
      IF (x_xsi_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.last_updated_by := l_xsi_rec.last_updated_by;
      END IF;
      IF (x_xsi_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsi_rec.last_update_date := l_xsi_rec.last_update_date;
      END IF;
      IF (x_xsi_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xsi_rec.last_update_login := l_xsi_rec.last_update_login;
      END IF;
      IF (x_xsi_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.trx_status_code := l_xsi_rec.trx_status_code;
      END IF;
      IF (x_xsi_rec.tax_exempt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.tax_exempt_flag := l_xsi_rec.tax_exempt_flag;
      END IF;
      IF (x_xsi_rec.tax_exempt_reason_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.tax_exempt_reason_code := l_xsi_rec.tax_exempt_reason_code;
      END IF;
      IF (x_xsi_rec.xtrx_invoice_pull_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsi_rec.xtrx_invoice_pull_yn := l_xsi_rec.xtrx_invoice_pull_yn;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xsi_rec IN  xsi_rec_type,
      x_xsi_rec OUT NOCOPY xsi_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xsi_rec := p_xsi_rec;
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
      p_xsi_rec,                         -- IN
      l_xsi_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xsi_rec, l_def_xsi_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_SELL_INVS_B
    SET ISI_ID = l_def_xsi_rec.isi_id,
        OBJECT_VERSION_NUMBER = l_def_xsi_rec.object_version_number,
        RECEIVABLES_INVOICE_ID = l_def_xsi_rec.receivables_invoice_id,
        SET_OF_BOOKS_ID = l_def_xsi_rec.set_of_books_id,
        TRX_DATE = l_def_xsi_rec.trx_date,
        CURRENCY_CODE = l_def_xsi_rec.currency_code,
    --Start change by pgomes on 19-NOV-2002
        currency_conversion_type = l_def_xsi_rec.currency_conversion_type,
        currency_conversion_rate = l_def_xsi_rec.currency_conversion_rate,
        currency_conversion_date = l_def_xsi_rec.currency_conversion_date,
    --End change by pgomes on 19-NOV-2002
        CUSTOMER_ID = l_def_xsi_rec.customer_id,
        RECEIPT_METHOD_ID = l_def_xsi_rec.receipt_method_id,
        TERM_ID = l_def_xsi_rec.term_id,
        CUSTOMER_ADDRESS_ID = l_def_xsi_rec.customer_address_id,
        CUST_TRX_TYPE_ID = l_def_xsi_rec.cust_trx_type_id,
        REQUEST_ID = l_def_xsi_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xsi_rec.program_application_id,
        PROGRAM_ID = l_def_xsi_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xsi_rec.program_update_date,
        ORG_ID = l_def_xsi_rec.org_id,
        INF_ID = l_def_xsi_rec.inf_id,
/*          KHR_ID = l_def_xsi_rec.khr_id,            */
/*          CLG_ID = l_def_xsi_rec.clg_id,    */
/*          CPY_ID = l_def_xsi_rec.cpy_id,    */
/*          QTE_ID = l_def_xsi_rec.qte_id,                                                                  */
        ATTRIBUTE_CATEGORY = l_def_xsi_rec.attribute_category,
        ATTRIBUTE1 = l_def_xsi_rec.attribute1,
        ATTRIBUTE2 = l_def_xsi_rec.attribute2,
        ATTRIBUTE3 = l_def_xsi_rec.attribute3,
        ATTRIBUTE4 = l_def_xsi_rec.attribute4,
        ATTRIBUTE5 = l_def_xsi_rec.attribute5,
        ATTRIBUTE6 = l_def_xsi_rec.attribute6,
        ATTRIBUTE7 = l_def_xsi_rec.attribute7,
        ATTRIBUTE8 = l_def_xsi_rec.attribute8,
        ATTRIBUTE9 = l_def_xsi_rec.attribute9,
        ATTRIBUTE10 = l_def_xsi_rec.attribute10,
        ATTRIBUTE11 = l_def_xsi_rec.attribute11,
        ATTRIBUTE12 = l_def_xsi_rec.attribute12,
        ATTRIBUTE13 = l_def_xsi_rec.attribute13,
        ATTRIBUTE14 = l_def_xsi_rec.attribute14,
        ATTRIBUTE15 = l_def_xsi_rec.attribute15,
        REFERENCE_LINE_ID = l_def_xsi_rec.REFERENCE_LINE_ID,
        CUSTOMER_BANK_ACCOUNT_ID = l_def_xsi_rec.CUSTOMER_BANK_ACCOUNT_ID,
        TRX_NUMBER = l_def_xsi_rec.TRX_NUMBER,
        CREATED_BY = l_def_xsi_rec.created_by,
        CREATION_DATE = l_def_xsi_rec.creation_date,
        LAST_UPDATED_BY = l_def_xsi_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xsi_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xsi_rec.last_update_login,
        TRX_STATUS_CODE = l_def_xsi_rec.trx_status_code,
        TAX_EXEMPT_FLAG = l_def_xsi_rec.tax_exempt_flag,
        TAX_EXEMPT_REASON_CODE = l_def_xsi_rec.tax_exempt_reason_code,
        XTRX_INVOICE_PULL_YN = l_def_xsi_rec.xtrx_invoice_pull_yn
    WHERE ID = l_def_xsi_rec.id;

    x_xsi_rec := l_def_xsi_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_EXT_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type,
    x_okl_ext_sell_invs_tl_rec     OUT NOCOPY okl_ext_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type := p_okl_ext_sell_invs_tl_rec;
    ldefoklextsellinvstlrec        okl_ext_sell_invs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_ext_sell_invs_tl_rec	IN okl_ext_sell_invs_tl_rec_type,
      x_okl_ext_sell_invs_tl_rec	OUT NOCOPY okl_ext_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_sell_invs_tl_rec := p_okl_ext_sell_invs_tl_rec;
      -- Get current database values
      l_okl_ext_sell_invs_tl_rec := get_rec(p_okl_ext_sell_invs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_sell_invs_tl_rec.id := l_okl_ext_sell_invs_tl_rec.id;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.LANGUAGE := l_okl_ext_sell_invs_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.source_lang := l_okl_ext_sell_invs_tl_rec.source_lang;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.sfwt_flag := l_okl_ext_sell_invs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.xtrx_cons_invoice_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.xtrx_cons_invoice_number := l_okl_ext_sell_invs_tl_rec.xtrx_cons_invoice_number;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.xtrx_format_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.xtrx_format_type := l_okl_ext_sell_invs_tl_rec.xtrx_format_type;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.xtrx_private_label = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.xtrx_private_label := l_okl_ext_sell_invs_tl_rec.xtrx_private_label;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.invoice_message = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.invoice_message := l_okl_ext_sell_invs_tl_rec.invoice_message;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_ext_sell_invs_tl_rec.description := l_okl_ext_sell_invs_tl_rec.description;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_sell_invs_tl_rec.created_by := l_okl_ext_sell_invs_tl_rec.created_by;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_ext_sell_invs_tl_rec.creation_date := l_okl_ext_sell_invs_tl_rec.creation_date;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_sell_invs_tl_rec.last_updated_by := l_okl_ext_sell_invs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_ext_sell_invs_tl_rec.last_update_date := l_okl_ext_sell_invs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_ext_sell_invs_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_ext_sell_invs_tl_rec.last_update_login := l_okl_ext_sell_invs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_sell_invs_tl_rec IN  okl_ext_sell_invs_tl_rec_type,
      x_okl_ext_sell_invs_tl_rec OUT NOCOPY okl_ext_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_sell_invs_tl_rec := p_okl_ext_sell_invs_tl_rec;
      x_okl_ext_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ext_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ext_sell_invs_tl_rec,        -- IN
      l_okl_ext_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_ext_sell_invs_tl_rec, ldefoklextsellinvstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_EXT_SELL_INVS_TL
    SET XTRX_CONS_INVOICE_NUMBER = ldefoklextsellinvstlrec.xtrx_cons_invoice_number,
        XTRX_FORMAT_TYPE = ldefoklextsellinvstlrec.xtrx_format_type,
        XTRX_PRIVATE_LABEL = ldefoklextsellinvstlrec.xtrx_private_label,
        INVOICE_MESSAGE = ldefoklextsellinvstlrec.invoice_message,
        DESCRIPTION = ldefoklextsellinvstlrec.description,
        SOURCE_LANG = ldefoklextsellinvstlrec.source_lang,
        CREATED_BY = ldefoklextsellinvstlrec.created_by,
        CREATION_DATE = ldefoklextsellinvstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklextsellinvstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklextsellinvstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklextsellinvstlrec.last_update_login
    WHERE ID = ldefoklextsellinvstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_EXT_SELL_INVS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklextsellinvstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_ext_sell_invs_tl_rec := ldefoklextsellinvstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_EXT_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type,
    x_xsiv_rec                     OUT NOCOPY xsiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsiv_rec                     xsiv_rec_type := p_xsiv_rec;
    l_def_xsiv_rec                 xsiv_rec_type;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
    lx_okl_ext_sell_invs_tl_rec    okl_ext_sell_invs_tl_rec_type;
    l_xsi_rec                      xsi_rec_type;
    lx_xsi_rec                     xsi_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xsiv_rec	IN xsiv_rec_type
    ) RETURN xsiv_rec_type IS
      l_xsiv_rec	xsiv_rec_type := p_xsiv_rec;
    BEGIN
      l_xsiv_rec.LAST_UPDATE_DATE := l_xsiv_rec.CREATION_DATE;
      l_xsiv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xsiv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xsiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xsiv_rec	IN xsiv_rec_type,
      x_xsiv_rec	OUT NOCOPY xsiv_rec_type
    ) RETURN VARCHAR2 IS
      l_xsiv_rec                     xsiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xsiv_rec := p_xsiv_rec;
      -- Get current database values
      l_xsiv_rec := get_rec(p_xsiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xsiv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.id := l_xsiv_rec.id;
      END IF;
      IF (x_xsiv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.object_version_number := l_xsiv_rec.object_version_number;
      END IF;
      IF (x_xsiv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.sfwt_flag := l_xsiv_rec.sfwt_flag;
      END IF;
      IF (x_xsiv_rec.isi_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.isi_id := l_xsiv_rec.isi_id;
      END IF;
      IF (x_xsiv_rec.trx_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsiv_rec.trx_date := l_xsiv_rec.trx_date;
      END IF;
      IF (x_xsiv_rec.customer_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.customer_id := l_xsiv_rec.customer_id;
      END IF;
      IF (x_xsiv_rec.receipt_method_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.receipt_method_id := l_xsiv_rec.receipt_method_id;
      END IF;
      IF (x_xsiv_rec.term_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.term_id := l_xsiv_rec.term_id;
      END IF;
      IF (x_xsiv_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.currency_code := l_xsiv_rec.currency_code;
      END IF;

      --Start change by pgomes on 19-NOV-2002
      IF (x_xsiv_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
        x_xsiv_rec.currency_conversion_type := l_xsiv_rec.currency_conversion_type;
      END IF;

      IF (x_xsiv_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
        x_xsiv_rec.currency_conversion_rate := l_xsiv_rec.currency_conversion_rate;
      END IF;

      IF (x_xsiv_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
        x_xsiv_rec.currency_conversion_date := l_xsiv_rec.currency_conversion_date;
      END IF;
      --End change by pgomes on 19-NOV-2002

      IF (x_xsiv_rec.customer_address_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.customer_address_id := l_xsiv_rec.customer_address_id;
      END IF;
      IF (x_xsiv_rec.set_of_books_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.set_of_books_id := l_xsiv_rec.set_of_books_id;
      END IF;
      IF (x_xsiv_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.receivables_invoice_id := l_xsiv_rec.receivables_invoice_id;
      END IF;
      IF (x_xsiv_rec.cust_trx_type_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.cust_trx_type_id := l_xsiv_rec.cust_trx_type_id;
      END IF;
      IF (x_xsiv_rec.invoice_message = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.invoice_message := l_xsiv_rec.invoice_message;
      END IF;
      IF (x_xsiv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.description := l_xsiv_rec.description;
      END IF;
      IF (x_xsiv_rec.xtrx_cons_invoice_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.xtrx_cons_invoice_number := l_xsiv_rec.xtrx_cons_invoice_number;
      END IF;
      IF (x_xsiv_rec.xtrx_format_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.xtrx_format_type := l_xsiv_rec.xtrx_format_type;
      END IF;
      IF (x_xsiv_rec.xtrx_private_label = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.xtrx_private_label := l_xsiv_rec.xtrx_private_label;
      END IF;

      IF (x_xsiv_rec.inf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.inf_id := l_xsiv_rec.inf_id;
      END IF;

/*        IF (x_xsiv_rec.khr_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsiv_rec.khr_id := l_xsiv_rec.khr_id;  */
/*        END IF;  */
/*          */
/*        IF (x_xsiv_rec.clg_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsiv_rec.clg_id := l_xsiv_rec.clg_id;  */
/*        END IF;        */
/*          */
/*        IF (x_xsiv_rec.cpy_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsiv_rec.cpy_id := l_xsiv_rec.cpy_id;  */
/*        END IF;  */
/*          */
/*        IF (x_xsiv_rec.qte_id = Okl_Api.G_MISS_NUM)  */
/*        THEN  */
/*          x_xsiv_rec.qte_id := l_xsiv_rec.qte_id;  */
/*        END IF;              */

      IF (x_xsiv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute_category := l_xsiv_rec.attribute_category;
      END IF;
      IF (x_xsiv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute1 := l_xsiv_rec.attribute1;
      END IF;
      IF (x_xsiv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute2 := l_xsiv_rec.attribute2;
      END IF;
      IF (x_xsiv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute3 := l_xsiv_rec.attribute3;
      END IF;
      IF (x_xsiv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute4 := l_xsiv_rec.attribute4;
      END IF;
      IF (x_xsiv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute5 := l_xsiv_rec.attribute5;
      END IF;
      IF (x_xsiv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute6 := l_xsiv_rec.attribute6;
      END IF;
      IF (x_xsiv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute7 := l_xsiv_rec.attribute7;
      END IF;
      IF (x_xsiv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute8 := l_xsiv_rec.attribute8;
      END IF;
      IF (x_xsiv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute9 := l_xsiv_rec.attribute9;
      END IF;
      IF (x_xsiv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute10 := l_xsiv_rec.attribute10;
      END IF;
      IF (x_xsiv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute11 := l_xsiv_rec.attribute11;
      END IF;
      IF (x_xsiv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute12 := l_xsiv_rec.attribute12;
      END IF;
      IF (x_xsiv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute13 := l_xsiv_rec.attribute13;
      END IF;
      IF (x_xsiv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute14 := l_xsiv_rec.attribute14;
      END IF;
      IF (x_xsiv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.attribute15 := l_xsiv_rec.attribute15;
      END IF;
      IF (x_xsiv_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.REFERENCE_LINE_ID := l_xsiv_rec.REFERENCE_LINE_ID;
      END IF;
      IF (x_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID := l_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID;
      END IF;
      IF (x_xsiv_rec.TRX_NUMBER = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.TRX_NUMBER := l_xsiv_rec.TRX_NUMBER;
      END IF;
      IF (x_xsiv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.request_id := l_xsiv_rec.request_id;
      END IF;
      IF (x_xsiv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.program_application_id := l_xsiv_rec.program_application_id;
      END IF;
      IF (x_xsiv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.program_id := l_xsiv_rec.program_id;
      END IF;
      IF (x_xsiv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsiv_rec.program_update_date := l_xsiv_rec.program_update_date;
      END IF;
      IF (x_xsiv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.org_id := l_xsiv_rec.org_id;
      END IF;
      IF (x_xsiv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.created_by := l_xsiv_rec.created_by;
      END IF;
      IF (x_xsiv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsiv_rec.creation_date := l_xsiv_rec.creation_date;
      END IF;
      IF (x_xsiv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.last_updated_by := l_xsiv_rec.last_updated_by;
      END IF;
      IF (x_xsiv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xsiv_rec.last_update_date := l_xsiv_rec.last_update_date;
      END IF;
      IF (x_xsiv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xsiv_rec.last_update_login := l_xsiv_rec.last_update_login;
      END IF;
      IF (x_xsiv_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.trx_status_code := l_xsiv_rec.trx_status_code;
      END IF;
      IF (x_xsiv_rec.tax_exempt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.tax_exempt_flag := l_xsiv_rec.tax_exempt_flag;
      END IF;
      IF (x_xsiv_rec.tax_exempt_reason_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.tax_exempt_reason_code := l_xsiv_rec.tax_exempt_reason_code;
      END IF;
      IF (x_xsiv_rec.xtrx_invoice_pull_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_xsiv_rec.xtrx_invoice_pull_yn := l_xsiv_rec.xtrx_invoice_pull_yn;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xsiv_rec IN  xsiv_rec_type,
      x_xsiv_rec OUT NOCOPY xsiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xsiv_rec := p_xsiv_rec;
      x_xsiv_rec.OBJECT_VERSION_NUMBER := NVL(x_xsiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

  	  IF (x_xsiv_rec.request_id IS NULL OR x_xsiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xsiv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xsiv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xsiv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xsiv_rec.program_update_date,SYSDATE)
      INTO
        x_xsiv_rec.request_id,
        x_xsiv_rec.program_application_id,
        x_xsiv_rec.program_id,
        x_xsiv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change

	  END IF;
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
      p_xsiv_rec,                        -- IN
      l_xsiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xsiv_rec, l_def_xsiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xsiv_rec := fill_who_columns(l_def_xsiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xsiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xsiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xsiv_rec, l_okl_ext_sell_invs_tl_rec);
    migrate(l_def_xsiv_rec, l_xsi_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_sell_invs_tl_rec,
      lx_okl_ext_sell_invs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ext_sell_invs_tl_rec, l_def_xsiv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xsi_rec,
      lx_xsi_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xsi_rec, l_def_xsiv_rec);
    x_xsiv_rec := l_def_xsiv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:XSIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type,
    x_xsiv_tbl                     OUT NOCOPY xsiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xsiv_tbl.COUNT > 0) THEN
      i := p_xsiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xsiv_rec                     => p_xsiv_tbl(i),
          x_xsiv_rec                     => x_xsiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xsiv_tbl.LAST);
        i := p_xsiv_tbl.NEXT(i);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_EXT_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsi_rec                      IN xsi_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsi_rec                      xsi_rec_type:= p_xsi_rec;
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
    DELETE FROM OKL_EXT_SELL_INVS_B
     WHERE ID = l_xsi_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_EXT_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ext_sell_invs_tl_rec     IN okl_ext_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type:= p_okl_ext_sell_invs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_EXT_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ext_sell_invs_tl_rec IN  okl_ext_sell_invs_tl_rec_type,
      x_okl_ext_sell_invs_tl_rec OUT NOCOPY okl_ext_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ext_sell_invs_tl_rec := p_okl_ext_sell_invs_tl_rec;
      x_okl_ext_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_ext_sell_invs_tl_rec,        -- IN
      l_okl_ext_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_EXT_SELL_INVS_TL
     WHERE ID = l_okl_ext_sell_invs_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_EXT_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xsiv_rec                     xsiv_rec_type := p_xsiv_rec;
    l_okl_ext_sell_invs_tl_rec     okl_ext_sell_invs_tl_rec_type;
    l_xsi_rec                      xsi_rec_type;
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
    migrate(l_xsiv_rec, l_okl_ext_sell_invs_tl_rec);
    migrate(l_xsiv_rec, l_xsi_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ext_sell_invs_tl_rec
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
      l_xsi_rec
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:XSIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xsiv_tbl.COUNT > 0) THEN
      i := p_xsiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xsiv_rec                     => p_xsiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xsiv_tbl.LAST);
        i := p_xsiv_tbl.NEXT(i);
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
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
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

END Okl_Xsi_Pvt;

/
