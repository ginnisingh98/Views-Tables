--------------------------------------------------------
--  DDL for Package Body OKL_CNR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNR_PVT" AS
/* $Header: OKLSCNRB.pls 120.5 2007/08/08 12:44:37 arajagop noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_cnrv_rec IN cnrv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cnrv_rec.id = Okl_Api.G_MISS_NUM OR
       p_cnrv_rec.id IS NULL
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

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_org_id (p_cnrv_rec IN cnrv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_cnrv_rec.org_id);

  END validate_org_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_cnrv_rec IN cnrv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cnrv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_cnrv_rec.object_version_number IS NULL
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

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_date_consolidated
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_consolidated (p_cnrv_rec IN cnrv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cnrv_rec.date_consolidated = Okl_Api.G_MISS_DATE OR
       p_cnrv_rec.date_consolidated IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'date_consolidated');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_date_consolidated;

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_currency_code
  ---------------------------------------------------------------------------
  PROCEDURE     validate_currency_code(p_cnrv_rec IN cnrv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_currency_code_csr IS
    SELECT '1'
	FROM FND_CURRENCIES_VL
	WHERE currency_code = p_cnrv_rec.currency_code;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_cnrv_rec.currency_code = Okl_Api.G_MISS_CHAR OR
       p_cnrv_rec.currency_code IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'currency_code');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;


	   IF (p_cnrv_rec.currency_code IS NOT NULL) THEN
	   	  OPEN l_currency_code_csr;
		  FETCH l_currency_code_csr INTO l_dummy_var;
		  CLOSE l_currency_code_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'CURRENCY_CODE_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_HDRS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_currency_code;

 -- for LE Uptake project 08-11-2006
 ---------------------------------------------------------------------------
  -- PROCEDURE validate_legal_entity_id
 ---------------------------------------------------------------------------
  PROCEDURE validate_legal_entity_id (p_cnrv_rec IN cnrv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_exists                NUMBER(1);
   item_not_found_error    EXCEPTION;
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_cnrv_rec.legal_entity_id IS NOT NULL) THEN
		l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_cnrv_rec.legal_entity_id);
	   IF(l_exists<>1) THEN
             Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
	     RAISE item_not_found_error;
           END IF;
	END IF;
EXCEPTION
WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

WHEN OTHERS THEN
-- store SQL error message on message stack for caller
Okc_Api.SET_MESSAGE(p_app_name      => g_app_name
                   ,p_msg_name      => g_unexpected_error
                   ,p_token1        => g_sqlcode_token
                   ,p_token1_value  =>SQLCODE
                   ,p_token2        => g_sqlerrm_token
                   ,p_token2_value  =>SQLERRM);

-- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
 END validate_legal_entity_id;

 -- for LE Uptake project 08-11-2006

 /*** view undefined *****
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_ibt_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_ibt_id(p_cnrv_rec IN cnrv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ibt_id_csr IS
    SELECT '1'
	FROM OKX_BILL_TOS_V
	WHERE id = p_cnrv_rec.ibt_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_cnrv_rec.ibt_id = Okl_api.G_MISS_NUM OR
       p_cnrv_rec.ibt_id IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'ibt_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

	   IF (p_cnrv_rec.ibt_id IS NOT NULL) THEN
	   	  OPEN l_ibt_id_csr;
		  FETCH l_ibt_id_csr INTO l_dummy_var;
		  CLOSE l_ibt_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IBT_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_HDRS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ibt_id;
 *********** View Undefined ***********/

 /******** View undefined ******
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_ixx_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_ixx_id(p_cnrv_rec IN cnrv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ixx_id_csr IS
    SELECT '1'
	FROM OKX_CSTR_ACCTS_V
	WHERE id = p_cnrv_rec.ixx_id;


  BEGIN
 	x_return_status := Okl_api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_cnrv_rec.ixx_id = Okl_api.G_MISS_NUM OR
       p_cnrv_rec.ixx_id IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'ixx_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

	   IF (p_cnrv_rec.ixx_id IS NOT NULL) THEN
	   	  OPEN l_ixx_id_csr;
		  FETCH l_ixx_id_csr INTO l_dummy_var;
		  CLOSE l_ixx_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IXX_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_HDRS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ixx_id;
 *********** View Undefined ***********/
 /******* View undefined *****
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_irm_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_irm_id(p_cnrv_rec IN cnrv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_irm_id_csr IS
    SELECT '1'
	FROM OKX_RECEIPT_METHODS_V
	WHERE id = p_cnrv_rec.irm_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_cnrv_rec.irm_id = Okl_api.G_MISS_NUM OR
       p_cnrv_rec.irm_id IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'irm_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;



	   IF (p_cnrv_rec.irm_id IS NOT NULL) THEN
	   	  OPEN l_irm_id_csr;
		  FETCH l_irm_id_csr INTO l_dummy_var;
		  CLOSE l_irm_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IRM_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_HDRS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_irm_id;
   *********** View Undefined ***********/

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_inf_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_inf_id(p_cnrv_rec IN cnrv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_inf_id_csr IS
    SELECT '1'
	FROM OKL_INVOICE_FORMATS_V
	WHERE id = p_cnrv_rec.inf_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_cnrv_rec.inf_id IS NOT NULL) THEN
	   	  OPEN l_inf_id_csr;
		  FETCH l_inf_id_csr INTO l_dummy_var;
		  CLOSE l_inf_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'INF_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_HDRS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_inf_id;

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
    DELETE FROM OKL_CNSLD_AR_HDRS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CNSLD_AR_HDRS_ALL_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_CNSLD_AR_HDRS_TL T SET (
        PRIVATE_LABEL_LOGO_URL) = (SELECT
                                  B.PRIVATE_LABEL_LOGO_URL
                                FROM OKL_CNSLD_AR_HDRS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_CNSLD_AR_HDRS_TL SUBB, OKL_CNSLD_AR_HDRS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.PRIVATE_LABEL_LOGO_URL <> SUBT.PRIVATE_LABEL_LOGO_URL
                      OR (SUBB.PRIVATE_LABEL_LOGO_URL IS NULL AND SUBT.PRIVATE_LABEL_LOGO_URL IS NOT NULL)
                      OR (SUBB.PRIVATE_LABEL_LOGO_URL IS NOT NULL AND SUBT.PRIVATE_LABEL_LOGO_URL IS NULL)
              ));

    INSERT INTO OKL_CNSLD_AR_HDRS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        PRIVATE_LABEL_LOGO_URL,
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
            B.PRIVATE_LABEL_LOGO_URL,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_CNSLD_AR_HDRS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_CNSLD_AR_HDRS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNSLD_AR_HDRS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnr_rec                      IN cnr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnr_rec_type IS
    CURSOR okl_cnsld_ar_hdrs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CONSOLIDATED_INVOICE_NUMBER,
            TRX_STATUS_CODE,
            CURRENCY_CODE,
            SET_OF_BOOKS_ID,
            IBT_ID,
            IXX_ID,
            IRM_ID,
            INF_ID,
            AMOUNT,
            DATE_CONSOLIDATED,
            INVOICE_PULL_YN,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
			DUE_DATE,
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
	    LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
      FROM Okl_Cnsld_Ar_Hdrs_B
     WHERE okl_cnsld_ar_hdrs_b.id = p_id;
    l_okl_cnsld_ar_hdrs_b_pk       okl_cnsld_ar_hdrs_b_pk_csr%ROWTYPE;
    l_cnr_rec                      cnr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cnsld_ar_hdrs_b_pk_csr (p_cnr_rec.id);
    FETCH okl_cnsld_ar_hdrs_b_pk_csr INTO
              l_cnr_rec.ID,
              l_cnr_rec.CONSOLIDATED_INVOICE_NUMBER,
              l_cnr_rec.TRX_STATUS_CODE,
              l_cnr_rec.CURRENCY_CODE,
              l_cnr_rec.SET_OF_BOOKS_ID,
              l_cnr_rec.IBT_ID,
              l_cnr_rec.IXX_ID,
              l_cnr_rec.IRM_ID,
              l_cnr_rec.INF_ID,
              l_cnr_rec.AMOUNT,
              l_cnr_rec.DATE_CONSOLIDATED,
              l_cnr_rec.INVOICE_PULL_YN,
              l_cnr_rec.OBJECT_VERSION_NUMBER,
              l_cnr_rec.REQUEST_ID,
              l_cnr_rec.PROGRAM_APPLICATION_ID,
              l_cnr_rec.PROGRAM_ID,
              l_cnr_rec.PROGRAM_UPDATE_DATE,
              l_cnr_rec.ORG_ID,
              l_cnr_rec.DUE_DATE,
              l_cnr_rec.ATTRIBUTE_CATEGORY,
              l_cnr_rec.ATTRIBUTE1,
              l_cnr_rec.ATTRIBUTE2,
              l_cnr_rec.ATTRIBUTE3,
              l_cnr_rec.ATTRIBUTE4,
              l_cnr_rec.ATTRIBUTE5,
              l_cnr_rec.ATTRIBUTE6,
              l_cnr_rec.ATTRIBUTE7,
              l_cnr_rec.ATTRIBUTE8,
              l_cnr_rec.ATTRIBUTE9,
              l_cnr_rec.ATTRIBUTE10,
              l_cnr_rec.ATTRIBUTE11,
              l_cnr_rec.ATTRIBUTE12,
              l_cnr_rec.ATTRIBUTE13,
              l_cnr_rec.ATTRIBUTE14,
              l_cnr_rec.ATTRIBUTE15,
              l_cnr_rec.CREATED_BY,
              l_cnr_rec.CREATION_DATE,
              l_cnr_rec.LAST_UPDATED_BY,
              l_cnr_rec.LAST_UPDATE_DATE,
              l_cnr_rec.LAST_UPDATE_LOGIN,
	      l_cnr_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006
    x_no_data_found := okl_cnsld_ar_hdrs_b_pk_csr%NOTFOUND;
    CLOSE okl_cnsld_ar_hdrs_b_pk_csr;
    RETURN(l_cnr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnr_rec                      IN cnr_rec_type
  ) RETURN cnr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNSLD_AR_HDRS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_cnsld_ar_hdrs_tl_rec_type IS
    CURSOR okl_cnsld_ar_hdrs_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            PRIVATE_LABEL_LOGO_URL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Cnsld_Ar_Hdrs_Tl
     WHERE okl_cnsld_ar_hdrs_tl.id = p_id
       AND okl_cnsld_ar_hdrs_tl.LANGUAGE = p_language;
    l_okl_cnsld_ar_hdrs_tl_pk      okl_cnsld_ar_hdrs_tl_pk_csr%ROWTYPE;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cnsld_ar_hdrs_tl_pk_csr (p_okl_cnsld_ar_hdrs_tl_rec.id,
                                      p_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE);
    FETCH okl_cnsld_ar_hdrs_tl_pk_csr INTO
              l_okl_cnsld_ar_hdrs_tl_rec.ID,
              l_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE,
              l_okl_cnsld_ar_hdrs_tl_rec.SOURCE_LANG,
              l_okl_cnsld_ar_hdrs_tl_rec.SFWT_FLAG,
              l_okl_cnsld_ar_hdrs_tl_rec.PRIVATE_LABEL_LOGO_URL,
              l_okl_cnsld_ar_hdrs_tl_rec.CREATED_BY,
              l_okl_cnsld_ar_hdrs_tl_rec.CREATION_DATE,
              l_okl_cnsld_ar_hdrs_tl_rec.LAST_UPDATED_BY,
              l_okl_cnsld_ar_hdrs_tl_rec.LAST_UPDATE_DATE,
              l_okl_cnsld_ar_hdrs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cnsld_ar_hdrs_tl_pk_csr%NOTFOUND;
    CLOSE okl_cnsld_ar_hdrs_tl_pk_csr;
    RETURN(l_okl_cnsld_ar_hdrs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type
  ) RETURN okl_cnsld_ar_hdrs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_cnsld_ar_hdrs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNSLD_AR_HDRS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cnrv_rec                     IN cnrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cnrv_rec_type IS
    CURSOR okl_cnrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            IBT_ID,
            IXX_ID,
            CURRENCY_CODE,
            IRM_ID,
            INF_ID,
            SET_OF_BOOKS_ID,
            CONSOLIDATED_INVOICE_NUMBER,
            TRX_STATUS_CODE,
            INVOICE_PULL_YN,
            DATE_CONSOLIDATED,
            PRIVATE_LABEL_LOGO_URL,
            AMOUNT,
			DUE_DATE,
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
	    LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
      FROM Okl_Cnsld_Ar_Hdrs_V
     WHERE okl_cnsld_ar_hdrs_v.id = p_id;
    l_okl_cnrv_pk                  okl_cnrv_pk_csr%ROWTYPE;
    l_cnrv_rec                     cnrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cnrv_pk_csr (p_cnrv_rec.id);
    FETCH okl_cnrv_pk_csr INTO
              l_cnrv_rec.ID,
              l_cnrv_rec.OBJECT_VERSION_NUMBER,
              l_cnrv_rec.SFWT_FLAG,
              l_cnrv_rec.IBT_ID,
              l_cnrv_rec.IXX_ID,
              l_cnrv_rec.CURRENCY_CODE,
              l_cnrv_rec.IRM_ID,
              l_cnrv_rec.INF_ID,
              l_cnrv_rec.SET_OF_BOOKS_ID,
              l_cnrv_rec.CONSOLIDATED_INVOICE_NUMBER,
              l_cnrv_rec.TRX_STATUS_CODE,
              l_cnrv_rec.INVOICE_PULL_YN,
              l_cnrv_rec.DATE_CONSOLIDATED,
              l_cnrv_rec.PRIVATE_LABEL_LOGO_URL,
              l_cnrv_rec.AMOUNT,
              l_cnrv_rec.DUE_DATE,
              l_cnrv_rec.ATTRIBUTE_CATEGORY,
              l_cnrv_rec.ATTRIBUTE1,
              l_cnrv_rec.ATTRIBUTE2,
              l_cnrv_rec.ATTRIBUTE3,
              l_cnrv_rec.ATTRIBUTE4,
              l_cnrv_rec.ATTRIBUTE5,
              l_cnrv_rec.ATTRIBUTE6,
              l_cnrv_rec.ATTRIBUTE7,
              l_cnrv_rec.ATTRIBUTE8,
              l_cnrv_rec.ATTRIBUTE9,
              l_cnrv_rec.ATTRIBUTE10,
              l_cnrv_rec.ATTRIBUTE11,
              l_cnrv_rec.ATTRIBUTE12,
              l_cnrv_rec.ATTRIBUTE13,
              l_cnrv_rec.ATTRIBUTE14,
              l_cnrv_rec.ATTRIBUTE15,
              l_cnrv_rec.REQUEST_ID,
              l_cnrv_rec.PROGRAM_APPLICATION_ID,
              l_cnrv_rec.PROGRAM_ID,
              l_cnrv_rec.PROGRAM_UPDATE_DATE,
              l_cnrv_rec.ORG_ID,
              l_cnrv_rec.CREATED_BY,
              l_cnrv_rec.CREATION_DATE,
              l_cnrv_rec.LAST_UPDATED_BY,
              l_cnrv_rec.LAST_UPDATE_DATE,
              l_cnrv_rec.LAST_UPDATE_LOGIN,
	      l_cnrv_rec.LEGAL_ENTITY_ID; -- for LE Uptake project 08-11-2006
    x_no_data_found := okl_cnrv_pk_csr%NOTFOUND;
    CLOSE okl_cnrv_pk_csr;
    RETURN(l_cnrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cnrv_rec                     IN cnrv_rec_type
  ) RETURN cnrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cnrv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CNSLD_AR_HDRS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cnrv_rec	IN cnrv_rec_type
  ) RETURN cnrv_rec_type IS
    l_cnrv_rec	cnrv_rec_type := p_cnrv_rec;
  BEGIN
    IF (l_cnrv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.object_version_number := NULL;
    END IF;
    IF (l_cnrv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cnrv_rec.ibt_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.ibt_id := NULL;
    END IF;
    IF (l_cnrv_rec.ixx_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.ixx_id := NULL;
    END IF;
    IF (l_cnrv_rec.currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.currency_code := NULL;
    END IF;
    IF (l_cnrv_rec.irm_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.irm_id := NULL;
    END IF;
    IF (l_cnrv_rec.inf_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.inf_id := NULL;
    END IF;
    IF (l_cnrv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_cnrv_rec.consolidated_invoice_number = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.consolidated_invoice_number := NULL;
    END IF;
    IF (l_cnrv_rec.trx_status_code = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.trx_status_code := NULL;
    END IF;
    IF (l_cnrv_rec.invoice_pull_yn = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.invoice_pull_yn := NULL;
    END IF;
    IF (l_cnrv_rec.date_consolidated = Okc_Api.G_MISS_DATE) THEN
      l_cnrv_rec.date_consolidated := NULL;
    END IF;
    IF (l_cnrv_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.private_label_logo_url := NULL;
    END IF;
    IF (l_cnrv_rec.amount = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.amount := NULL;
    END IF;
    IF (l_cnrv_rec.due_date = Okc_Api.G_MISS_DATE) THEN
      l_cnrv_rec.due_date := NULL;
    END IF;
    IF (l_cnrv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute_category := NULL;
    END IF;
    IF (l_cnrv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute1 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute2 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute3 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute4 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute5 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute6 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute7 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute8 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute9 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute10 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute11 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute12 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute13 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute14 := NULL;
    END IF;
    IF (l_cnrv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_cnrv_rec.attribute15 := NULL;
    END IF;
    IF (l_cnrv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.request_id := NULL;
    END IF;
    IF (l_cnrv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.program_application_id := NULL;
    END IF;
    IF (l_cnrv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.program_id := NULL;
    END IF;
    IF (l_cnrv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
      l_cnrv_rec.program_update_date := NULL;
    END IF;
    IF (l_cnrv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.org_id := NULL;
    END IF;
    IF (l_cnrv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.created_by := NULL;
    END IF;
    IF (l_cnrv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_cnrv_rec.creation_date := NULL;
    END IF;
    IF (l_cnrv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cnrv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_cnrv_rec.last_update_date := NULL;
    END IF;
    IF (l_cnrv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.last_update_login := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006
    IF (l_cnrv_rec.legal_entity_id = Okc_Api.G_MISS_NUM) THEN
      l_cnrv_rec.legal_entity_id := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006
    RETURN(l_cnrv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_CNSLD_AR_HDRS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cnrv_rec IN  cnrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	-- Added 04/19/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
	-- Added 04/19/2001 -- Sunil Mathew
    validate_currency_code(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
-- for LE Uptake project 08-11-2006
IF ( p_cnrv_rec.legal_entity_id = Okl_Api.G_MISS_NUM OR p_cnrv_rec.legal_entity_id IS NULL)
THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
ELSE
    validate_legal_entity_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
END IF;
-- for LE Uptake project 08-11-2006
--    validate_isob_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--    validate_ibt_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--    validate_ixx_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--    validate_irm_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_inf_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_org_id(p_cnrv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	-- End Addition 04/19/2001 -- Sunil Mathew

    IF p_cnrv_rec.id = Okc_Api.G_MISS_NUM OR
       p_cnrv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_cnrv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.ibt_id = Okc_Api.G_MISS_NUM OR
          p_cnrv_rec.ibt_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ibt_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.ixx_id = Okc_Api.G_MISS_NUM OR
          p_cnrv_rec.ixx_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ixx_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.currency_code = Okc_Api.G_MISS_CHAR OR
          p_cnrv_rec.currency_code IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.irm_id = Okc_Api.G_MISS_NUM OR
          p_cnrv_rec.irm_id IS NULL
    THEN
          NULL;
    ELSIF p_cnrv_rec.set_of_books_id = Okc_Api.G_MISS_NUM OR
          p_cnrv_rec.set_of_books_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'set_of_books_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.trx_status_code = Okc_Api.G_MISS_CHAR OR
          p_cnrv_rec.trx_status_code IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_status_code');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    ELSIF p_cnrv_rec.date_consolidated = Okc_Api.G_MISS_DATE OR
          p_cnrv_rec.date_consolidated IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_consolidated');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_CNSLD_AR_HDRS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_cnrv_rec IN cnrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cnrv_rec_type,
    p_to	OUT NOCOPY cnr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.consolidated_invoice_number := p_from.consolidated_invoice_number;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.currency_code := p_from.currency_code;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.ibt_id := p_from.ibt_id;
    p_to.ixx_id := p_from.ixx_id;
    p_to.irm_id := p_from.irm_id;
    p_to.inf_id := p_from.inf_id;
    p_to.amount := p_from.amount;
    p_to.date_consolidated := p_from.date_consolidated;
    p_to.invoice_pull_yn := p_from.invoice_pull_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.due_date := p_from.due_date;
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
    p_to.legal_entity_id   := p_from.legal_entity_id; -- for LE Uptake project 08-11-2006
  END migrate;
  PROCEDURE migrate (
    p_from	IN cnr_rec_type,
    p_to	OUT NOCOPY cnrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.consolidated_invoice_number := p_from.consolidated_invoice_number;
    p_to.trx_status_code := p_from.trx_status_code;
    p_to.currency_code := p_from.currency_code;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.ibt_id := p_from.ibt_id;
    p_to.ixx_id := p_from.ixx_id;
    p_to.irm_id := p_from.irm_id;
    p_to.inf_id := p_from.inf_id;
    p_to.amount := p_from.amount;
    p_to.date_consolidated := p_from.date_consolidated;
    p_to.invoice_pull_yn := p_from.invoice_pull_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.due_date := p_from.due_date;
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
    p_to.legal_entity_id := p_from.legal_entity_id; -- for LE Uptake project 08-11-2006
  END migrate;
  PROCEDURE migrate (
    p_from	IN cnrv_rec_type,
    p_to	OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.private_label_logo_url := p_from.private_label_logo_url;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_cnsld_ar_hdrs_tl_rec_type,
    p_to	OUT NOCOPY cnrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.private_label_logo_url := p_from.private_label_logo_url;
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
  -- validate_row for:OKL_CNSLD_AR_HDRS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_rec                     IN cnrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnrv_rec                     cnrv_rec_type := p_cnrv_rec;
    l_cnr_rec                      cnr_rec_type;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_cnrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cnrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:CNRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_tbl                     IN cnrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnrv_tbl.COUNT > 0) THEN
      i := p_cnrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnrv_rec                     => p_cnrv_tbl(i));
        EXIT WHEN (i = p_cnrv_tbl.LAST);
        i := p_cnrv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CNSLD_AR_HDRS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnr_rec                      IN cnr_rec_type,
    x_cnr_rec                      OUT NOCOPY cnr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnr_rec                      cnr_rec_type := p_cnr_rec;
    l_def_cnr_rec                  cnr_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cnr_rec IN  cnr_rec_type,
      x_cnr_rec OUT NOCOPY cnr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnr_rec := p_cnr_rec;
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
      p_cnr_rec,                         -- IN
      l_cnr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CNSLD_AR_HDRS_B(
        id,
        consolidated_invoice_number,
        trx_status_code,
        currency_code,
        set_of_books_id,
        ibt_id,
        ixx_id,
        irm_id,
        inf_id,
        amount,
        date_consolidated,
        invoice_pull_yn,
        object_version_number,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
		due_date,
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
        legal_entity_id) -- for LE Uptake project 08-11-2006
      VALUES (
        l_cnr_rec.id,
        l_cnr_rec.consolidated_invoice_number,
        l_cnr_rec.trx_status_code,
        l_cnr_rec.currency_code,
        l_cnr_rec.set_of_books_id,
        l_cnr_rec.ibt_id,
        l_cnr_rec.ixx_id,
        l_cnr_rec.irm_id,
        l_cnr_rec.inf_id,
        l_cnr_rec.amount,
        l_cnr_rec.date_consolidated,
        l_cnr_rec.invoice_pull_yn,
        l_cnr_rec.object_version_number,
        l_cnr_rec.request_id,
        l_cnr_rec.program_application_id,
        l_cnr_rec.program_id,
        l_cnr_rec.program_update_date,
        l_cnr_rec.org_id,
        l_cnr_rec.due_date,
        l_cnr_rec.attribute_category,
        l_cnr_rec.attribute1,
        l_cnr_rec.attribute2,
        l_cnr_rec.attribute3,
        l_cnr_rec.attribute4,
        l_cnr_rec.attribute5,
        l_cnr_rec.attribute6,
        l_cnr_rec.attribute7,
        l_cnr_rec.attribute8,
        l_cnr_rec.attribute9,
        l_cnr_rec.attribute10,
        l_cnr_rec.attribute11,
        l_cnr_rec.attribute12,
        l_cnr_rec.attribute13,
        l_cnr_rec.attribute14,
        l_cnr_rec.attribute15,
        l_cnr_rec.created_by,
        l_cnr_rec.creation_date,
        l_cnr_rec.last_updated_by,
        l_cnr_rec.last_update_date,
        l_cnr_rec.last_update_login,
        l_cnr_rec.legal_entity_id); -- for LE Uptake project 08-11-2006
    -- Set OUT values
    x_cnr_rec := l_cnr_rec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CNSLD_AR_HDRS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type,
    x_okl_cnsld_ar_hdrs_tl_rec     OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type := p_okl_cnsld_ar_hdrs_tl_rec;
    ldefoklcnsldarhdrstlrec        okl_cnsld_ar_hdrs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cnsld_ar_hdrs_tl_rec IN  okl_cnsld_ar_hdrs_tl_rec_type,
      x_okl_cnsld_ar_hdrs_tl_rec OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cnsld_ar_hdrs_tl_rec := p_okl_cnsld_ar_hdrs_tl_rec;
      x_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_cnsld_ar_hdrs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_cnsld_ar_hdrs_tl_rec,        -- IN
      l_okl_cnsld_ar_hdrs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_CNSLD_AR_HDRS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          private_label_logo_url,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_cnsld_ar_hdrs_tl_rec.id,
          l_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE,
          l_okl_cnsld_ar_hdrs_tl_rec.source_lang,
          l_okl_cnsld_ar_hdrs_tl_rec.sfwt_flag,
          l_okl_cnsld_ar_hdrs_tl_rec.private_label_logo_url,
          l_okl_cnsld_ar_hdrs_tl_rec.created_by,
          l_okl_cnsld_ar_hdrs_tl_rec.creation_date,
          l_okl_cnsld_ar_hdrs_tl_rec.last_updated_by,
          l_okl_cnsld_ar_hdrs_tl_rec.last_update_date,
          l_okl_cnsld_ar_hdrs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_cnsld_ar_hdrs_tl_rec := l_okl_cnsld_ar_hdrs_tl_rec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_CNSLD_AR_HDRS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_rec                     IN cnrv_rec_type,
    x_cnrv_rec                     OUT NOCOPY cnrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnrv_rec                     cnrv_rec_type;
    l_def_cnrv_rec                 cnrv_rec_type;
    l_cnr_rec                      cnr_rec_type;
    lx_cnr_rec                     cnr_rec_type;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
    lx_okl_cnsld_ar_hdrs_tl_rec    okl_cnsld_ar_hdrs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnrv_rec	IN cnrv_rec_type
    ) RETURN cnrv_rec_type IS
      l_cnrv_rec	cnrv_rec_type := p_cnrv_rec;
    BEGIN
      l_cnrv_rec.CREATION_DATE := SYSDATE;
      l_cnrv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_cnrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cnrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_cnrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cnrv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cnrv_rec IN  cnrv_rec_type,
      x_cnrv_rec OUT NOCOPY cnrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnrv_rec := p_cnrv_rec;
      x_cnrv_rec.OBJECT_VERSION_NUMBER := 1;
      x_cnrv_rec.SFWT_FLAG := 'N';

	IF (x_cnrv_rec.request_id IS NULL OR x_cnrv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_cnrv_rec.request_id,
	  	   x_cnrv_rec.program_application_id,
	  	   x_cnrv_rec.program_id,
	  	   x_cnrv_rec.program_update_date
	  FROM dual;
	END IF;

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
    l_cnrv_rec := null_out_defaults(p_cnrv_rec);
    -- Set primary key value
    l_cnrv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cnrv_rec,                        -- IN
      l_def_cnrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnrv_rec := fill_who_columns(l_def_cnrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnrv_rec, l_cnr_rec);
    migrate(l_def_cnrv_rec, l_okl_cnsld_ar_hdrs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnr_rec,
      lx_cnr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnr_rec, l_def_cnrv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cnsld_ar_hdrs_tl_rec,
      lx_okl_cnsld_ar_hdrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cnsld_ar_hdrs_tl_rec, l_def_cnrv_rec);
    -- Set OUT values
    x_cnrv_rec := l_def_cnrv_rec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CNRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_tbl                     IN cnrv_tbl_type,
    x_cnrv_tbl                     OUT NOCOPY cnrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnrv_tbl.COUNT > 0) THEN
      i := p_cnrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnrv_rec                     => p_cnrv_tbl(i),
          x_cnrv_rec                     => x_cnrv_tbl(i));
        EXIT WHEN (i = p_cnrv_tbl.LAST);
        i := p_cnrv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CNSLD_AR_HDRS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnr_rec                      IN cnr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cnr_rec IN cnr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNSLD_AR_HDRS_B
     WHERE ID = p_cnr_rec.id
       AND OBJECT_VERSION_NUMBER = p_cnr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cnr_rec IN cnr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNSLD_AR_HDRS_B
    WHERE ID = p_cnr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CNSLD_AR_HDRS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CNSLD_AR_HDRS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_cnr_rec);
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
      OPEN lchk_csr(p_cnr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cnr_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cnr_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CNSLD_AR_HDRS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_cnsld_ar_hdrs_tl_rec IN okl_cnsld_ar_hdrs_tl_rec_type) IS
    SELECT *
      FROM OKL_CNSLD_AR_HDRS_TL
     WHERE ID = p_okl_cnsld_ar_hdrs_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_okl_cnsld_ar_hdrs_tl_rec);
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_CNSLD_AR_HDRS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_rec                     IN cnrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnr_rec                      cnr_rec_type;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_cnrv_rec, l_cnr_rec);
    migrate(p_cnrv_rec, l_okl_cnsld_ar_hdrs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cnsld_ar_hdrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CNRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_tbl                     IN cnrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnrv_tbl.COUNT > 0) THEN
      i := p_cnrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnrv_rec                     => p_cnrv_tbl(i));
        EXIT WHEN (i = p_cnrv_tbl.LAST);
        i := p_cnrv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CNSLD_AR_HDRS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnr_rec                      IN cnr_rec_type,
    x_cnr_rec                      OUT NOCOPY cnr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnr_rec                      cnr_rec_type := p_cnr_rec;
    l_def_cnr_rec                  cnr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnr_rec	IN cnr_rec_type,
      x_cnr_rec	OUT NOCOPY cnr_rec_type
    ) RETURN VARCHAR2 IS
      l_cnr_rec                      cnr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnr_rec := p_cnr_rec;
      -- Get current database values
      l_cnr_rec := get_rec(p_cnr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnr_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.id := l_cnr_rec.id;
      END IF;
      IF (x_cnr_rec.consolidated_invoice_number = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.consolidated_invoice_number := l_cnr_rec.consolidated_invoice_number;
      END IF;
      IF (x_cnr_rec.trx_status_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.trx_status_code := l_cnr_rec.trx_status_code;
      END IF;
      IF (x_cnr_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.currency_code := l_cnr_rec.currency_code;
      END IF;
      IF (x_cnr_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.set_of_books_id := l_cnr_rec.set_of_books_id;
      END IF;
      IF (x_cnr_rec.ibt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.ibt_id := l_cnr_rec.ibt_id;
      END IF;
      IF (x_cnr_rec.ixx_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.ixx_id := l_cnr_rec.ixx_id;
      END IF;
      IF (x_cnr_rec.irm_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.irm_id := l_cnr_rec.irm_id;
      END IF;
      IF (x_cnr_rec.inf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.inf_id := l_cnr_rec.inf_id;
      END IF;
      IF (x_cnr_rec.amount = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.amount := l_cnr_rec.amount;
      END IF;
      IF (x_cnr_rec.date_consolidated = Okc_Api.G_MISS_DATE)
      THEN
        x_cnr_rec.date_consolidated := l_cnr_rec.date_consolidated;
      END IF;
      IF (x_cnr_rec.invoice_pull_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.invoice_pull_yn := l_cnr_rec.invoice_pull_yn;
      END IF;
      IF (x_cnr_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.object_version_number := l_cnr_rec.object_version_number;
      END IF;
      IF (x_cnr_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.request_id := l_cnr_rec.request_id;
      END IF;
      IF (x_cnr_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.program_application_id := l_cnr_rec.program_application_id;
      END IF;
      IF (x_cnr_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.program_id := l_cnr_rec.program_id;
      END IF;
      IF (x_cnr_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnr_rec.program_update_date := l_cnr_rec.program_update_date;
      END IF;
      IF (x_cnr_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.org_id := l_cnr_rec.org_id;
      END IF;
	  IF (x_cnr_rec.due_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnr_rec.due_date := l_cnr_rec.due_date;
      END IF;
      IF (x_cnr_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute_category := l_cnr_rec.attribute_category;
      END IF;
      IF (x_cnr_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute1 := l_cnr_rec.attribute1;
      END IF;
      IF (x_cnr_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute2 := l_cnr_rec.attribute2;
      END IF;
      IF (x_cnr_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute3 := l_cnr_rec.attribute3;
      END IF;
      IF (x_cnr_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute4 := l_cnr_rec.attribute4;
      END IF;
      IF (x_cnr_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute5 := l_cnr_rec.attribute5;
      END IF;
      IF (x_cnr_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute6 := l_cnr_rec.attribute6;
      END IF;
      IF (x_cnr_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute7 := l_cnr_rec.attribute7;
      END IF;
      IF (x_cnr_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute8 := l_cnr_rec.attribute8;
      END IF;
      IF (x_cnr_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute9 := l_cnr_rec.attribute9;
      END IF;
      IF (x_cnr_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute10 := l_cnr_rec.attribute10;
      END IF;
      IF (x_cnr_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute11 := l_cnr_rec.attribute11;
      END IF;
      IF (x_cnr_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute12 := l_cnr_rec.attribute12;
      END IF;
      IF (x_cnr_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute13 := l_cnr_rec.attribute13;
      END IF;
      IF (x_cnr_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute14 := l_cnr_rec.attribute14;
      END IF;
      IF (x_cnr_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnr_rec.attribute15 := l_cnr_rec.attribute15;
      END IF;
      IF (x_cnr_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.created_by := l_cnr_rec.created_by;
      END IF;
      IF (x_cnr_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnr_rec.creation_date := l_cnr_rec.creation_date;
      END IF;
      IF (x_cnr_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.last_updated_by := l_cnr_rec.last_updated_by;
      END IF;
      IF (x_cnr_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnr_rec.last_update_date := l_cnr_rec.last_update_date;
      END IF;
      IF (x_cnr_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.last_update_login := l_cnr_rec.last_update_login;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_cnr_rec.legal_entity_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnr_rec.legal_entity_id := l_cnr_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cnr_rec IN  cnr_rec_type,
      x_cnr_rec OUT NOCOPY cnr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnr_rec := p_cnr_rec;
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
      p_cnr_rec,                         -- IN
      l_cnr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnr_rec, l_def_cnr_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CNSLD_AR_HDRS_B
    SET CONSOLIDATED_INVOICE_NUMBER = l_def_cnr_rec.consolidated_invoice_number,
        TRX_STATUS_CODE = l_def_cnr_rec.trx_status_code,
        CURRENCY_CODE = l_def_cnr_rec.currency_code,
        SET_OF_BOOKS_ID = l_def_cnr_rec.set_of_books_id,
        IBT_ID = l_def_cnr_rec.ibt_id,
        IXX_ID = l_def_cnr_rec.ixx_id,
        IRM_ID = l_def_cnr_rec.irm_id,
        INF_ID = l_def_cnr_rec.inf_id,
        AMOUNT = l_def_cnr_rec.amount,
        DATE_CONSOLIDATED = l_def_cnr_rec.date_consolidated,
        INVOICE_PULL_YN = l_def_cnr_rec.invoice_pull_yn,
        OBJECT_VERSION_NUMBER = l_def_cnr_rec.object_version_number,
        REQUEST_ID = l_def_cnr_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_cnr_rec.program_application_id,
        PROGRAM_ID = l_def_cnr_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_cnr_rec.program_update_date,
        ORG_ID = l_def_cnr_rec.org_id,
        DUE_DATE = l_def_cnr_rec.due_date,
        ATTRIBUTE_CATEGORY = l_def_cnr_rec.attribute_category,
        ATTRIBUTE1 = l_def_cnr_rec.attribute1,
        ATTRIBUTE2 = l_def_cnr_rec.attribute2,
        ATTRIBUTE3 = l_def_cnr_rec.attribute3,
        ATTRIBUTE4 = l_def_cnr_rec.attribute4,
        ATTRIBUTE5 = l_def_cnr_rec.attribute5,
        ATTRIBUTE6 = l_def_cnr_rec.attribute6,
        ATTRIBUTE7 = l_def_cnr_rec.attribute7,
        ATTRIBUTE8 = l_def_cnr_rec.attribute8,
        ATTRIBUTE9 = l_def_cnr_rec.attribute9,
        ATTRIBUTE10 = l_def_cnr_rec.attribute10,
        ATTRIBUTE11 = l_def_cnr_rec.attribute11,
        ATTRIBUTE12 = l_def_cnr_rec.attribute12,
        ATTRIBUTE13 = l_def_cnr_rec.attribute13,
        ATTRIBUTE14 = l_def_cnr_rec.attribute14,
        ATTRIBUTE15 = l_def_cnr_rec.attribute15,
        CREATED_BY = l_def_cnr_rec.created_by,
        CREATION_DATE = l_def_cnr_rec.creation_date,
        LAST_UPDATED_BY = l_def_cnr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cnr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cnr_rec.last_update_login,
        LEGAL_ENTITY_ID = l_def_cnr_rec.legal_entity_id -- for LE Uptake project 08-11-2006
    WHERE ID = l_def_cnr_rec.id;

    x_cnr_rec := l_def_cnr_rec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CNSLD_AR_HDRS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type,
    x_okl_cnsld_ar_hdrs_tl_rec     OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type := p_okl_cnsld_ar_hdrs_tl_rec;
    ldefoklcnsldarhdrstlrec        okl_cnsld_ar_hdrs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_cnsld_ar_hdrs_tl_rec	IN okl_cnsld_ar_hdrs_tl_rec_type,
      x_okl_cnsld_ar_hdrs_tl_rec	OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cnsld_ar_hdrs_tl_rec := p_okl_cnsld_ar_hdrs_tl_rec;
      -- Get current database values
      l_okl_cnsld_ar_hdrs_tl_rec := get_rec(p_okl_cnsld_ar_hdrs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.id := l_okl_cnsld_ar_hdrs_tl_rec.id;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE := l_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.source_lang := l_okl_cnsld_ar_hdrs_tl_rec.source_lang;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.sfwt_flag := l_okl_cnsld_ar_hdrs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.private_label_logo_url := l_okl_cnsld_ar_hdrs_tl_rec.private_label_logo_url;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.created_by := l_okl_cnsld_ar_hdrs_tl_rec.created_by;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.creation_date := l_okl_cnsld_ar_hdrs_tl_rec.creation_date;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.last_updated_by := l_okl_cnsld_ar_hdrs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.last_update_date := l_okl_cnsld_ar_hdrs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_cnsld_ar_hdrs_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_cnsld_ar_hdrs_tl_rec.last_update_login := l_okl_cnsld_ar_hdrs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cnsld_ar_hdrs_tl_rec IN  okl_cnsld_ar_hdrs_tl_rec_type,
      x_okl_cnsld_ar_hdrs_tl_rec OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cnsld_ar_hdrs_tl_rec := p_okl_cnsld_ar_hdrs_tl_rec;
      x_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_cnsld_ar_hdrs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_cnsld_ar_hdrs_tl_rec,        -- IN
      l_okl_cnsld_ar_hdrs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_cnsld_ar_hdrs_tl_rec, ldefoklcnsldarhdrstlrec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CNSLD_AR_HDRS_TL
    SET PRIVATE_LABEL_LOGO_URL = ldefoklcnsldarhdrstlrec.private_label_logo_url,
        CREATED_BY = ldefoklcnsldarhdrstlrec.created_by,
        CREATION_DATE = ldefoklcnsldarhdrstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklcnsldarhdrstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklcnsldarhdrstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklcnsldarhdrstlrec.last_update_login
    WHERE ID = ldefoklcnsldarhdrstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_CNSLD_AR_HDRS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklcnsldarhdrstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_cnsld_ar_hdrs_tl_rec := ldefoklcnsldarhdrstlrec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_CNSLD_AR_HDRS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_rec                     IN cnrv_rec_type,
    x_cnrv_rec                     OUT NOCOPY cnrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnrv_rec                     cnrv_rec_type := p_cnrv_rec;
    l_def_cnrv_rec                 cnrv_rec_type;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
    lx_okl_cnsld_ar_hdrs_tl_rec    okl_cnsld_ar_hdrs_tl_rec_type;
    l_cnr_rec                      cnr_rec_type;
    lx_cnr_rec                     cnr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cnrv_rec	IN cnrv_rec_type
    ) RETURN cnrv_rec_type IS
      l_cnrv_rec	cnrv_rec_type := p_cnrv_rec;
    BEGIN
      l_cnrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cnrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_cnrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cnrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cnrv_rec	IN cnrv_rec_type,
      x_cnrv_rec	OUT NOCOPY cnrv_rec_type
    ) RETURN VARCHAR2 IS
      l_cnrv_rec                     cnrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnrv_rec := p_cnrv_rec;
      -- Get current database values
      l_cnrv_rec := get_rec(p_cnrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cnrv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.id := l_cnrv_rec.id;
      END IF;
      IF (x_cnrv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.object_version_number := l_cnrv_rec.object_version_number;
      END IF;
      IF (x_cnrv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.sfwt_flag := l_cnrv_rec.sfwt_flag;
      END IF;
      IF (x_cnrv_rec.ibt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.ibt_id := l_cnrv_rec.ibt_id;
      END IF;
      IF (x_cnrv_rec.ixx_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.ixx_id := l_cnrv_rec.ixx_id;
      END IF;
      IF (x_cnrv_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.currency_code := l_cnrv_rec.currency_code;
      END IF;
      IF (x_cnrv_rec.irm_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.irm_id := l_cnrv_rec.irm_id;
      END IF;
      IF (x_cnrv_rec.inf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.inf_id := l_cnrv_rec.inf_id;
      END IF;
      IF (x_cnrv_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.set_of_books_id := l_cnrv_rec.set_of_books_id;
      END IF;
      IF (x_cnrv_rec.consolidated_invoice_number = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.consolidated_invoice_number := l_cnrv_rec.consolidated_invoice_number;
      END IF;
      IF (x_cnrv_rec.trx_status_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.trx_status_code := l_cnrv_rec.trx_status_code;
      END IF;
      IF (x_cnrv_rec.invoice_pull_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.invoice_pull_yn := l_cnrv_rec.invoice_pull_yn;
      END IF;
      IF (x_cnrv_rec.date_consolidated = Okc_Api.G_MISS_DATE)
      THEN
        x_cnrv_rec.date_consolidated := l_cnrv_rec.date_consolidated;
      END IF;
      IF (x_cnrv_rec.private_label_logo_url = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.private_label_logo_url := l_cnrv_rec.private_label_logo_url;
      END IF;
      IF (x_cnrv_rec.amount = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.amount := l_cnrv_rec.amount;
      END IF;
	  IF (x_cnrv_rec.due_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnrv_rec.due_date := l_cnrv_rec.due_date;
      END IF;
      IF (x_cnrv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute_category := l_cnrv_rec.attribute_category;
      END IF;
      IF (x_cnrv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute1 := l_cnrv_rec.attribute1;
      END IF;
      IF (x_cnrv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute2 := l_cnrv_rec.attribute2;
      END IF;
      IF (x_cnrv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute3 := l_cnrv_rec.attribute3;
      END IF;
      IF (x_cnrv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute4 := l_cnrv_rec.attribute4;
      END IF;
      IF (x_cnrv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute5 := l_cnrv_rec.attribute5;
      END IF;
      IF (x_cnrv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute6 := l_cnrv_rec.attribute6;
      END IF;
      IF (x_cnrv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute7 := l_cnrv_rec.attribute7;
      END IF;
      IF (x_cnrv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute8 := l_cnrv_rec.attribute8;
      END IF;
      IF (x_cnrv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute9 := l_cnrv_rec.attribute9;
      END IF;
      IF (x_cnrv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute10 := l_cnrv_rec.attribute10;
      END IF;
      IF (x_cnrv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute11 := l_cnrv_rec.attribute11;
      END IF;
      IF (x_cnrv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute12 := l_cnrv_rec.attribute12;
      END IF;
      IF (x_cnrv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute13 := l_cnrv_rec.attribute13;
      END IF;
      IF (x_cnrv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute14 := l_cnrv_rec.attribute14;
      END IF;
      IF (x_cnrv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_cnrv_rec.attribute15 := l_cnrv_rec.attribute15;
      END IF;
      IF (x_cnrv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.request_id := l_cnrv_rec.request_id;
      END IF;
      IF (x_cnrv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.program_application_id := l_cnrv_rec.program_application_id;
      END IF;
      IF (x_cnrv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.program_id := l_cnrv_rec.program_id;
      END IF;
      IF (x_cnrv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnrv_rec.program_update_date := l_cnrv_rec.program_update_date;
      END IF;
      IF (x_cnrv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.org_id := l_cnrv_rec.org_id;
      END IF;
      IF (x_cnrv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.created_by := l_cnrv_rec.created_by;
      END IF;
      IF (x_cnrv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnrv_rec.creation_date := l_cnrv_rec.creation_date;
      END IF;
      IF (x_cnrv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.last_updated_by := l_cnrv_rec.last_updated_by;
      END IF;
      IF (x_cnrv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_cnrv_rec.last_update_date := l_cnrv_rec.last_update_date;
      END IF;
      IF (x_cnrv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.last_update_login := l_cnrv_rec.last_update_login;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_cnrv_rec.legal_entity_id = Okc_Api.G_MISS_NUM)
      THEN
        x_cnrv_rec.legal_entity_id := l_cnrv_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cnrv_rec IN  cnrv_rec_type,
      x_cnrv_rec OUT NOCOPY cnrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cnrv_rec := p_cnrv_rec;
      x_cnrv_rec.OBJECT_VERSION_NUMBER := NVL(x_cnrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
	IF (x_cnrv_rec.request_id IS NULL OR x_cnrv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_cnrv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_cnrv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_cnrv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_cnrv_rec.program_update_date,SYSDATE)
      INTO
        x_cnrv_rec.request_id,
        x_cnrv_rec.program_application_id,
        x_cnrv_rec.program_id,
        x_cnrv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
	END IF;

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
      p_cnrv_rec,                        -- IN
      l_cnrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cnrv_rec, l_def_cnrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cnrv_rec := fill_who_columns(l_def_cnrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cnrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cnrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cnrv_rec, l_okl_cnsld_ar_hdrs_tl_rec);
    migrate(l_def_cnrv_rec, l_cnr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cnsld_ar_hdrs_tl_rec,
      lx_okl_cnsld_ar_hdrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cnsld_ar_hdrs_tl_rec, l_def_cnrv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnr_rec,
      lx_cnr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cnr_rec, l_def_cnrv_rec);
    x_cnrv_rec := l_def_cnrv_rec;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:CNRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_tbl                     IN cnrv_tbl_type,
    x_cnrv_tbl                     OUT NOCOPY cnrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnrv_tbl.COUNT > 0) THEN
      i := p_cnrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnrv_rec                     => p_cnrv_tbl(i),
          x_cnrv_rec                     => x_cnrv_tbl(i));
        EXIT WHEN (i = p_cnrv_tbl.LAST);
        i := p_cnrv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CNSLD_AR_HDRS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnr_rec                      IN cnr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnr_rec                      cnr_rec_type:= p_cnr_rec;
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
    DELETE FROM OKL_CNSLD_AR_HDRS_B
     WHERE ID = l_cnr_rec.id;

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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CNSLD_AR_HDRS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cnsld_ar_hdrs_tl_rec     IN okl_cnsld_ar_hdrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type:= p_okl_cnsld_ar_hdrs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNSLD_AR_HDRS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cnsld_ar_hdrs_tl_rec IN  okl_cnsld_ar_hdrs_tl_rec_type,
      x_okl_cnsld_ar_hdrs_tl_rec OUT NOCOPY okl_cnsld_ar_hdrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cnsld_ar_hdrs_tl_rec := p_okl_cnsld_ar_hdrs_tl_rec;
      x_okl_cnsld_ar_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_cnsld_ar_hdrs_tl_rec,        -- IN
      l_okl_cnsld_ar_hdrs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CNSLD_AR_HDRS_TL
     WHERE ID = l_okl_cnsld_ar_hdrs_tl_rec.id;

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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_CNSLD_AR_HDRS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_rec                     IN cnrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_cnrv_rec                     cnrv_rec_type := p_cnrv_rec;
    l_okl_cnsld_ar_hdrs_tl_rec     okl_cnsld_ar_hdrs_tl_rec_type;
    l_cnr_rec                      cnr_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cnrv_rec, l_okl_cnsld_ar_hdrs_tl_rec);
    migrate(l_cnrv_rec, l_cnr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cnsld_ar_hdrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cnr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:CNRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnrv_tbl                     IN cnrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cnrv_tbl.COUNT > 0) THEN
      i := p_cnrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cnrv_rec                     => p_cnrv_tbl(i));
        EXIT WHEN (i = p_cnrv_tbl.LAST);
        i := p_cnrv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


END Okl_Cnr_Pvt;

/
