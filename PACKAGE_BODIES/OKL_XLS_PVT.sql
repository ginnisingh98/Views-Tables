--------------------------------------------------------
--  DDL for Package Body OKL_XLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XLS_PVT" AS
/* $Header: OKLSXLSB.pls 120.5 2005/10/30 03:47:32 appldev noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_xlsv_rec IN xlsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_xlsv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xlsv_rec.id IS NULL
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

  PROCEDURE validate_org_id (p_xlsv_rec IN xlsv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_xlsv_rec.org_id);

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_inventory_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_inventory_org_id (p_xlsv_rec IN xlsv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_xlsv_rec.inventory_org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_xlsv_rec.inventory_org_id);
	END IF;

  IF x_return_status <>  Okl_Api.G_RET_STS_SUCCESS THEN
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'INVENTORY_ORG_ID');
  END IF;

  END validate_inventory_org_id;



  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_xlsv_rec IN xlsv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_xlsv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xlsv_rec.id IS NULL
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
  -- PROCEDURE validate_ill_id
  ---------------------------------------------------------------------------
  /******************** Commented out OKX_SELL_INV_LNS_V not defined
  PROCEDURE validate_ill_id (p_xlsv_rec IN xlsv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ill_id_csr IS
    SELECT '1'
	FROM OKX_SELL_INV_LNS_V
	WHERE id = p_xlsv_rec.ill_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_xlsv_rec.ill_id IS NOT NULL) THEN
	   	  OPEN l_ill_id_csr;
		  FETCH l_ill_id_csr INTO l_dummy_var;
		  CLOSE l_ill_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'ILL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTL_SELL_INVS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ill_id;
***************** Commented out OKX_SELL_INV_LNS_V not defined ******/
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tld_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_tld_id (p_xlsv_rec IN xlsv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tld_id_csr IS
    SELECT '1'
	FROM OKL_TXD_AR_LN_DTLS_B
	WHERE id = p_xlsv_rec.tld_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_xlsv_rec.tld_id IS NOT NULL) THEN
	   	  OPEN l_tld_id_csr;
		  FETCH l_tld_id_csr INTO l_dummy_var;
		  CLOSE l_tld_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TLD_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTL_SELL_INVS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tld_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_lsm_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_lsm_id (p_xlsv_rec IN xlsv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_lsm_id_csr IS
    SELECT '1'
	FROM OKL_CNSLD_AR_STRMS_B
	WHERE id = p_xlsv_rec.lsm_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_xlsv_rec.lsm_id IS NOT NULL) THEN
	   	  OPEN l_lsm_id_csr;
		  FETCH l_lsm_id_csr INTO l_dummy_var;
		  CLOSE l_lsm_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'LSM_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTL_SELL_INVS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_lsm_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_til_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_til_id (p_xlsv_rec IN xlsv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_til_id_csr IS
    SELECT '1'
	FROM OKL_TXL_AR_INV_LNS_B
	WHERE id = p_xlsv_rec.til_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_xlsv_rec.til_id IS NOT NULL) THEN
	   	  OPEN l_til_id_csr;
		  FETCH l_til_id_csr INTO l_dummy_var;
		  CLOSE l_til_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TIL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTL_SELL_INVS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_til_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_xsi_id_details
  ---------------------------------------------------------------------------
  PROCEDURE validate_xsi_id_details (p_xlsv_rec IN xlsv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_xsi_id_details_csr IS
    SELECT '1'
	FROM OKL_EXT_SELL_INVS_B
	WHERE id = p_xlsv_rec.xsi_id_details;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	   --Check for Null
       IF p_xlsv_rec.id = Okl_Api.G_MISS_NUM OR
       	  p_xlsv_rec.id IS NULL
    	  THEN

      	  x_return_status := Okl_Api.G_RET_STS_ERROR;
		  --set error message in message stack
	  	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        					  p_msg_name     =>  G_REQUIRED_VALUE,
          				   	  p_token1       => G_COL_NAME_TOKEN,
						      p_token1_value => 'object_version_number');
      	  RAISE G_EXCEPTION_HALT_VALIDATION;

	  END IF;


	   IF (p_xlsv_rec.xsi_id_details IS NOT NULL) THEN
	   	  OPEN l_xsi_id_details_csr;
		  FETCH l_xsi_id_details_csr INTO l_dummy_var;
		  CLOSE l_xsi_id_details_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'XSI_ID_DETAILS_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTL_SELL_INVS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_xsi_id_details;

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
    DELETE FROM OKL_XTL_SELL_INVS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_XTL_SELL_INVS_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_XTL_SELL_INVS_TL T SET (
        DESCRIPTION,
        XTRX_CONTRACT,
        XTRX_ASSET,
        XTRX_STREAM_GROUP,
        XTRX_STREAM_TYPE) = (SELECT
                                  B.DESCRIPTION,
                                  B.XTRX_CONTRACT,
                                  B.XTRX_ASSET,
                                  B.XTRX_STREAM_GROUP,
                                  B.XTRX_STREAM_TYPE
                                FROM OKL_XTL_SELL_INVS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_XTL_SELL_INVS_TL SUBB, OKL_XTL_SELL_INVS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.XTRX_CONTRACT <> SUBT.XTRX_CONTRACT
                      OR SUBB.XTRX_ASSET <> SUBT.XTRX_ASSET
                      OR SUBB.XTRX_STREAM_GROUP <> SUBT.XTRX_STREAM_GROUP
                      OR SUBB.XTRX_STREAM_TYPE <> SUBT.XTRX_STREAM_TYPE
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.XTRX_CONTRACT IS NULL AND SUBT.XTRX_CONTRACT IS NOT NULL)
                      OR (SUBB.XTRX_CONTRACT IS NOT NULL AND SUBT.XTRX_CONTRACT IS NULL)
                      OR (SUBB.XTRX_ASSET IS NULL AND SUBT.XTRX_ASSET IS NOT NULL)
                      OR (SUBB.XTRX_ASSET IS NOT NULL AND SUBT.XTRX_ASSET IS NULL)
                      OR (SUBB.XTRX_STREAM_GROUP IS NULL AND SUBT.XTRX_STREAM_GROUP IS NOT NULL)
                      OR (SUBB.XTRX_STREAM_GROUP IS NOT NULL AND SUBT.XTRX_STREAM_GROUP IS NULL)
                      OR (SUBB.XTRX_STREAM_TYPE IS NULL AND SUBT.XTRX_STREAM_TYPE IS NOT NULL)
                      OR (SUBB.XTRX_STREAM_TYPE IS NOT NULL AND SUBT.XTRX_STREAM_TYPE IS NULL)
              ));

    INSERT INTO OKL_XTL_SELL_INVS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        XTRX_CONTRACT,
        XTRX_ASSET,
        XTRX_STREAM_GROUP,
        XTRX_STREAM_TYPE,
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
            B.XTRX_CONTRACT,
            B.XTRX_ASSET,
            B.XTRX_STREAM_GROUP,
            B.XTRX_STREAM_TYPE,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_XTL_SELL_INVS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_XTL_SELL_INVS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_SELL_INVS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xls_rec                      IN xls_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xls_rec_type IS
    CURSOR okl_xtl_sell_invs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ILL_ID,
            TLD_ID,
            LSM_ID,
            TIL_ID,
            XSI_ID_DETAILS,
            OBJECT_VERSION_NUMBER,
            LINE_TYPE,
            AMOUNT,
            QUANTITY,
            XTRX_CONS_LINE_NUMBER,
            XTRX_CONS_STREAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            INVENTORY_ORG_ID,
			ISL_ID,
            SEL_ID,
-- Start bug 4055540 fmiao 12/12/04--
            INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04--
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
      FROM Okl_Xtl_Sell_Invs_B
     WHERE okl_xtl_sell_invs_b.id = p_id;
    l_okl_xtl_sell_invs_b_pk       okl_xtl_sell_invs_b_pk_csr%ROWTYPE;
    l_xls_rec                      xls_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xtl_sell_invs_b_pk_csr (p_xls_rec.id);
    FETCH okl_xtl_sell_invs_b_pk_csr INTO
              l_xls_rec.ID,
              l_xls_rec.ILL_ID,
              l_xls_rec.TLD_ID,
              l_xls_rec.LSM_ID,
              l_xls_rec.TIL_ID,
              l_xls_rec.XSI_ID_DETAILS,
              l_xls_rec.OBJECT_VERSION_NUMBER,
              l_xls_rec.LINE_TYPE,
              l_xls_rec.AMOUNT,
              l_xls_rec.QUANTITY,
              l_xls_rec.XTRX_CONS_LINE_NUMBER,
              l_xls_rec.XTRX_CONS_STREAM_ID,
              l_xls_rec.REQUEST_ID,
              l_xls_rec.PROGRAM_APPLICATION_ID,
              l_xls_rec.PROGRAM_ID,
              l_xls_rec.PROGRAM_UPDATE_DATE,
              l_xls_rec.ORG_ID,
              l_xls_rec.INVENTORY_ORG_ID,
              l_xls_rec.ISL_ID,
              l_xls_rec.SEL_ID,
-- Start bug 4055540 fmiao 12/12/04--
              l_xls_rec.INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04--
              l_xls_rec.ATTRIBUTE_CATEGORY,
              l_xls_rec.ATTRIBUTE1,
              l_xls_rec.ATTRIBUTE2,
              l_xls_rec.ATTRIBUTE3,
              l_xls_rec.ATTRIBUTE4,
              l_xls_rec.ATTRIBUTE5,
              l_xls_rec.ATTRIBUTE6,
              l_xls_rec.ATTRIBUTE7,
              l_xls_rec.ATTRIBUTE8,
              l_xls_rec.ATTRIBUTE9,
              l_xls_rec.ATTRIBUTE10,
              l_xls_rec.ATTRIBUTE11,
              l_xls_rec.ATTRIBUTE12,
              l_xls_rec.ATTRIBUTE13,
              l_xls_rec.ATTRIBUTE14,
              l_xls_rec.ATTRIBUTE15,
              l_xls_rec.CREATED_BY,
              l_xls_rec.CREATION_DATE,
              l_xls_rec.LAST_UPDATED_BY,
              l_xls_rec.LAST_UPDATE_DATE,
              l_xls_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xtl_sell_invs_b_pk_csr%NOTFOUND;
    CLOSE okl_xtl_sell_invs_b_pk_csr;
    RETURN(l_xls_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xls_rec                      IN xls_rec_type
  ) RETURN xls_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xls_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_SELL_INVS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_xtl_sell_invs_tl_rec_type IS
    CURSOR okl_xtl_sell_invs_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            XTRX_CONTRACT,
            XTRX_ASSET,
            XTRX_STREAM_GROUP,
            XTRX_STREAM_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Sell_Invs_Tl
     WHERE okl_xtl_sell_invs_tl.id = p_id
       AND okl_xtl_sell_invs_tl.LANGUAGE = p_language;
    l_okl_xtl_sell_invs_tl_pk      okl_xtl_sell_invs_tl_pk_csr%ROWTYPE;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xtl_sell_invs_tl_pk_csr (p_okl_xtl_sell_invs_tl_rec.id,
                                      p_okl_xtl_sell_invs_tl_rec.LANGUAGE);
    FETCH okl_xtl_sell_invs_tl_pk_csr INTO
              l_okl_xtl_sell_invs_tl_rec.ID,
              l_okl_xtl_sell_invs_tl_rec.LANGUAGE,
              l_okl_xtl_sell_invs_tl_rec.SOURCE_LANG,
              l_okl_xtl_sell_invs_tl_rec.SFWT_FLAG,
              l_okl_xtl_sell_invs_tl_rec.DESCRIPTION,
              l_okl_xtl_sell_invs_tl_rec.XTRX_CONTRACT,
              l_okl_xtl_sell_invs_tl_rec.XTRX_ASSET,
              l_okl_xtl_sell_invs_tl_rec.XTRX_STREAM_GROUP,
              l_okl_xtl_sell_invs_tl_rec.XTRX_STREAM_TYPE,
              l_okl_xtl_sell_invs_tl_rec.CREATED_BY,
              l_okl_xtl_sell_invs_tl_rec.CREATION_DATE,
              l_okl_xtl_sell_invs_tl_rec.LAST_UPDATED_BY,
              l_okl_xtl_sell_invs_tl_rec.LAST_UPDATE_DATE,
              l_okl_xtl_sell_invs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xtl_sell_invs_tl_pk_csr%NOTFOUND;
    CLOSE okl_xtl_sell_invs_tl_pk_csr;
    RETURN(l_okl_xtl_sell_invs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type
  ) RETURN okl_xtl_sell_invs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_xtl_sell_invs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_SELL_INVS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xlsv_rec                     IN xlsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xlsv_rec_type IS
    CURSOR okl_xlsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            TLD_ID,
            LSM_ID,
            TIL_ID,
            ILL_ID,
            XSI_ID_DETAILS,
            LINE_TYPE,
            DESCRIPTION,
            AMOUNT,
            QUANTITY,
            XTRX_CONS_LINE_NUMBER,
            XTRX_CONTRACT,
            XTRX_ASSET,
            XTRX_STREAM_GROUP,
            XTRX_STREAM_TYPE,
            XTRX_CONS_STREAM_ID,
            ISL_ID,
            SEL_ID,
-- Start bug 4055540 fmiao 12/12/04--
            INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04--
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
            INVENTORY_ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Sell_Invs_V
     WHERE okl_xtl_sell_invs_v.id = p_id;
    l_okl_xlsv_pk                  okl_xlsv_pk_csr%ROWTYPE;
    l_xlsv_rec                     xlsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xlsv_pk_csr (p_xlsv_rec.id);
    FETCH okl_xlsv_pk_csr INTO
              l_xlsv_rec.ID,
              l_xlsv_rec.OBJECT_VERSION_NUMBER,
              l_xlsv_rec.SFWT_FLAG,
              l_xlsv_rec.TLD_ID,
              l_xlsv_rec.LSM_ID,
              l_xlsv_rec.TIL_ID,
              l_xlsv_rec.ILL_ID,
              l_xlsv_rec.XSI_ID_DETAILS,
              l_xlsv_rec.LINE_TYPE,
              l_xlsv_rec.DESCRIPTION,
              l_xlsv_rec.AMOUNT,
              l_xlsv_rec.QUANTITY,
              l_xlsv_rec.XTRX_CONS_LINE_NUMBER,
              l_xlsv_rec.XTRX_CONTRACT,
              l_xlsv_rec.XTRX_ASSET,
              l_xlsv_rec.XTRX_STREAM_GROUP,
              l_xlsv_rec.XTRX_STREAM_TYPE,
              l_xlsv_rec.XTRX_CONS_STREAM_ID,
              l_xlsv_rec.ISL_ID,
              l_xlsv_rec.SEL_ID,
-- Start bug 4055540 fmiao 12/12/04--
              l_xlsv_rec.INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04--
              l_xlsv_rec.ATTRIBUTE_CATEGORY,
              l_xlsv_rec.ATTRIBUTE1,
              l_xlsv_rec.ATTRIBUTE2,
              l_xlsv_rec.ATTRIBUTE3,
              l_xlsv_rec.ATTRIBUTE4,
              l_xlsv_rec.ATTRIBUTE5,
              l_xlsv_rec.ATTRIBUTE6,
              l_xlsv_rec.ATTRIBUTE7,
              l_xlsv_rec.ATTRIBUTE8,
              l_xlsv_rec.ATTRIBUTE9,
              l_xlsv_rec.ATTRIBUTE10,
              l_xlsv_rec.ATTRIBUTE11,
              l_xlsv_rec.ATTRIBUTE12,
              l_xlsv_rec.ATTRIBUTE13,
              l_xlsv_rec.ATTRIBUTE14,
              l_xlsv_rec.ATTRIBUTE15,
              l_xlsv_rec.REQUEST_ID,
              l_xlsv_rec.PROGRAM_APPLICATION_ID,
              l_xlsv_rec.PROGRAM_ID,
              l_xlsv_rec.PROGRAM_UPDATE_DATE,
              l_xlsv_rec.ORG_ID,
              l_xlsv_rec.INVENTORY_ORG_ID,
              l_xlsv_rec.CREATED_BY,
              l_xlsv_rec.CREATION_DATE,
              l_xlsv_rec.LAST_UPDATED_BY,
              l_xlsv_rec.LAST_UPDATE_DATE,
              l_xlsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xlsv_pk_csr%NOTFOUND;
    CLOSE okl_xlsv_pk_csr;
    RETURN(l_xlsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xlsv_rec                     IN xlsv_rec_type
  ) RETURN xlsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xlsv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_XTL_SELL_INVS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xlsv_rec	IN xlsv_rec_type
  ) RETURN xlsv_rec_type IS
    l_xlsv_rec	xlsv_rec_type := p_xlsv_rec;
  BEGIN
    IF (l_xlsv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.object_version_number := NULL;
    END IF;
    IF (l_xlsv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_xlsv_rec.tld_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.tld_id := NULL;
    END IF;
    IF (l_xlsv_rec.lsm_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.lsm_id := NULL;
    END IF;
    IF (l_xlsv_rec.til_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.til_id := NULL;
    END IF;
    IF (l_xlsv_rec.ill_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.ill_id := NULL;
    END IF;
    IF (l_xlsv_rec.xsi_id_details = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.xsi_id_details := NULL;
    END IF;
    IF (l_xlsv_rec.line_type = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.line_type := NULL;
    END IF;
    IF (l_xlsv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.description := NULL;
    END IF;
    IF (l_xlsv_rec.amount = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.amount := NULL;
    END IF;
    IF (l_xlsv_rec.quantity = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.quantity := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_cons_line_number = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.xtrx_cons_line_number := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_contract = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.xtrx_contract := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_asset = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.xtrx_asset := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_stream_group = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.xtrx_stream_group := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_stream_type = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.xtrx_stream_type := NULL;
    END IF;
    IF (l_xlsv_rec.xtrx_cons_stream_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.xtrx_cons_stream_id := NULL;
    END IF;
    IF (l_xlsv_rec.isl_id  = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.isl_id := NULL;
    END IF;

    IF (l_xlsv_rec.sel_id  = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.sel_id := NULL;
    END IF;

-- Start changes on remarketing by fmiao on 10/18/04 --
    IF (l_xlsv_rec.inventory_item_id  = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.inventory_item_id := NULL;
    END IF;
-- End changes on remarketing by fmiao on 10/18/04 --

    IF (l_xlsv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute_category := NULL;
    END IF;
    IF (l_xlsv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute1 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute2 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute3 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute4 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute5 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute6 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute7 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute8 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute9 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute10 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute11 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute12 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute13 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute14 := NULL;
    END IF;
    IF (l_xlsv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_xlsv_rec.attribute15 := NULL;
    END IF;
    IF (l_xlsv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.request_id := NULL;
    END IF;
    IF (l_xlsv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.program_application_id := NULL;
    END IF;
    IF (l_xlsv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.program_id := NULL;
    END IF;
    IF (l_xlsv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xlsv_rec.program_update_date := NULL;
    END IF;
    IF (l_xlsv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.org_id := NULL;
    END IF;

    IF (l_xlsv_rec.inventory_org_id = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.inventory_org_id := NULL;
    END IF;

    IF (l_xlsv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.created_by := NULL;
    END IF;
    IF (l_xlsv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_xlsv_rec.creation_date := NULL;
    END IF;
    IF (l_xlsv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xlsv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_xlsv_rec.last_update_date := NULL;
    END IF;
    IF (l_xlsv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_xlsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_xlsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_XTL_SELL_INVS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_xlsv_rec IN  xlsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Added 04/18/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    --Added 04/18/2001 Sunil Mathew ---
	/***  Commented out because view not defined
    validate_ill_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    ****************** End comment ****************/
    validate_tld_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_lsm_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_til_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_xsi_id_details (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    validate_id(p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_inventory_org_id (p_xlsv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    --End Addition 04/18/2001 Sunil Mathew ---


    IF p_xlsv_rec.id = Okl_Api.G_MISS_NUM OR
       p_xlsv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_xlsv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_xlsv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_xlsv_rec.xsi_id_details = Okl_Api.G_MISS_NUM OR
          p_xlsv_rec.xsi_id_details IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'xsi_id_details');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_XTL_SELL_INVS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_xlsv_rec IN xlsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN xlsv_rec_type,
    p_to	IN OUT NOCOPY xls_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ill_id := p_from.ill_id;
    p_to.tld_id := p_from.tld_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.til_id := p_from.til_id;
    p_to.xsi_id_details := p_from.xsi_id_details;
    p_to.object_version_number := p_from.object_version_number;
    p_to.line_type := p_from.line_type;
    p_to.amount := p_from.amount;
    p_to.quantity := p_from.quantity;
    p_to.xtrx_cons_line_number := p_from.xtrx_cons_line_number;
    p_to.xtrx_cons_stream_id := p_from.xtrx_cons_stream_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
    p_to.isl_id := p_from.isl_id;
    p_to.sel_id := p_from.sel_id;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --
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
    p_from	IN xls_rec_type,
    p_to	IN OUT NOCOPY xlsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ill_id := p_from.ill_id;
    p_to.tld_id := p_from.tld_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.til_id := p_from.til_id;
    p_to.xsi_id_details := p_from.xsi_id_details;
    p_to.object_version_number := p_from.object_version_number;
    p_to.line_type := p_from.line_type;
    p_to.amount := p_from.amount;
    p_to.quantity := p_from.quantity;
    p_to.xtrx_cons_line_number := p_from.xtrx_cons_line_number;
    p_to.xtrx_cons_stream_id := p_from.xtrx_cons_stream_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
    p_to.isl_id := p_from.isl_id;
    p_to.sel_id := p_from.sel_id;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --
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
    p_from	IN xlsv_rec_type,
    p_to	IN OUT NOCOPY okl_xtl_sell_invs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.xtrx_contract := p_from.xtrx_contract;
    p_to.xtrx_asset := p_from.xtrx_asset;
    p_to.xtrx_stream_group := p_from.xtrx_stream_group;
    p_to.xtrx_stream_type := p_from.xtrx_stream_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_xtl_sell_invs_tl_rec_type,
    p_to	IN OUT NOCOPY xlsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.xtrx_contract := p_from.xtrx_contract;
    p_to.xtrx_asset := p_from.xtrx_asset;
    p_to.xtrx_stream_group := p_from.xtrx_stream_group;
    p_to.xtrx_stream_type := p_from.xtrx_stream_type;
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
  -- validate_row for:OKL_XTL_SELL_INVS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xlsv_rec                     xlsv_rec_type := p_xlsv_rec;
    l_xls_rec                      xls_rec_type;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_xlsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xlsv_rec);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:XLSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type) IS

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
    IF (p_xlsv_tbl.COUNT > 0) THEN
      i := p_xlsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlsv_rec                     => p_xlsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_xlsv_tbl.LAST);
        i := p_xlsv_tbl.NEXT(i);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_XTL_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xls_rec                      IN xls_rec_type,
    x_xls_rec                      OUT NOCOPY xls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xls_rec                      xls_rec_type := p_xls_rec;
    l_def_xls_rec                  xls_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xls_rec IN  xls_rec_type,
      x_xls_rec OUT NOCOPY xls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xls_rec := p_xls_rec;
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
      p_xls_rec,                         -- IN
      l_xls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_XTL_SELL_INVS_B(
        id,
        ill_id,
        tld_id,
        lsm_id,
        til_id,
        xsi_id_details,
        object_version_number,
        line_type,
        amount,
        quantity,
        xtrx_cons_line_number,
        xtrx_cons_stream_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        inventory_org_id,
		isl_id,
        sel_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
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
        last_update_login)
      VALUES (
        l_xls_rec.id,
        l_xls_rec.ill_id,
        l_xls_rec.tld_id,
        l_xls_rec.lsm_id,
        l_xls_rec.til_id,
        l_xls_rec.xsi_id_details,
        l_xls_rec.object_version_number,
        l_xls_rec.line_type,
        l_xls_rec.amount,
        l_xls_rec.quantity,
        l_xls_rec.xtrx_cons_line_number,
        l_xls_rec.xtrx_cons_stream_id,
        l_xls_rec.request_id,
        l_xls_rec.program_application_id,
        l_xls_rec.program_id,
        l_xls_rec.program_update_date,
        l_xls_rec.org_id,
        l_xls_rec.inventory_org_id,
        l_xls_rec.isl_id,
        l_xls_rec.sel_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
        l_xls_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
        l_xls_rec.attribute_category,
        l_xls_rec.attribute1,
        l_xls_rec.attribute2,
        l_xls_rec.attribute3,
        l_xls_rec.attribute4,
        l_xls_rec.attribute5,
        l_xls_rec.attribute6,
        l_xls_rec.attribute7,
        l_xls_rec.attribute8,
        l_xls_rec.attribute9,
        l_xls_rec.attribute10,
        l_xls_rec.attribute11,
        l_xls_rec.attribute12,
        l_xls_rec.attribute13,
        l_xls_rec.attribute14,
        l_xls_rec.attribute15,
        l_xls_rec.created_by,
        l_xls_rec.creation_date,
        l_xls_rec.last_updated_by,
        l_xls_rec.last_update_date,
        l_xls_rec.last_update_login);
    -- Set OUT values
    x_xls_rec := l_xls_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_XTL_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type,
    x_okl_xtl_sell_invs_tl_rec     OUT NOCOPY okl_xtl_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type := p_okl_xtl_sell_invs_tl_rec;
    ldefoklxtlsellinvstlrec        okl_xtl_sell_invs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_sell_invs_tl_rec IN  okl_xtl_sell_invs_tl_rec_type,
      x_okl_xtl_sell_invs_tl_rec OUT NOCOPY okl_xtl_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_sell_invs_tl_rec := p_okl_xtl_sell_invs_tl_rec;
      x_okl_xtl_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_xtl_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_xtl_sell_invs_tl_rec,        -- IN
      l_okl_xtl_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_xtl_sell_invs_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_XTL_SELL_INVS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          description,
          xtrx_contract,
          xtrx_asset,
          xtrx_stream_group,
          xtrx_stream_type,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_xtl_sell_invs_tl_rec.id,
          l_okl_xtl_sell_invs_tl_rec.LANGUAGE,
          l_okl_xtl_sell_invs_tl_rec.source_lang,
          l_okl_xtl_sell_invs_tl_rec.sfwt_flag,
          l_okl_xtl_sell_invs_tl_rec.description,
          l_okl_xtl_sell_invs_tl_rec.xtrx_contract,
          l_okl_xtl_sell_invs_tl_rec.xtrx_asset,
          l_okl_xtl_sell_invs_tl_rec.xtrx_stream_group,
          l_okl_xtl_sell_invs_tl_rec.xtrx_stream_type,
          l_okl_xtl_sell_invs_tl_rec.created_by,
          l_okl_xtl_sell_invs_tl_rec.creation_date,
          l_okl_xtl_sell_invs_tl_rec.last_updated_by,
          l_okl_xtl_sell_invs_tl_rec.last_update_date,
          l_okl_xtl_sell_invs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_xtl_sell_invs_tl_rec := l_okl_xtl_sell_invs_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_XTL_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type,
    x_xlsv_rec                     OUT NOCOPY xlsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xlsv_rec                     xlsv_rec_type;
    l_def_xlsv_rec                 xlsv_rec_type;
    l_xls_rec                      xls_rec_type;
    lx_xls_rec                     xls_rec_type;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
    lx_okl_xtl_sell_invs_tl_rec    okl_xtl_sell_invs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlsv_rec	IN xlsv_rec_type
    ) RETURN xlsv_rec_type IS
      l_xlsv_rec	xlsv_rec_type := p_xlsv_rec;
    BEGIN
      l_xlsv_rec.CREATION_DATE := SYSDATE;
      l_xlsv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_xlsv_rec.LAST_UPDATE_DATE := l_xlsv_rec.creation_date;
      l_xlsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xlsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xlsv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlsv_rec IN  xlsv_rec_type,
      x_xlsv_rec OUT NOCOPY xlsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN

      x_xlsv_rec := p_xlsv_rec;
      x_xlsv_rec.OBJECT_VERSION_NUMBER := 1;
      x_xlsv_rec.SFWT_FLAG := 'N';
	IF (x_xlsv_rec.request_id IS NULL OR x_xlsv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_xlsv_rec.request_id,
	  	   x_xlsv_rec.program_application_id,
	  	   x_xlsv_rec.program_id,
	  	   x_xlsv_rec.program_update_date
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
    l_xlsv_rec := null_out_defaults(p_xlsv_rec);
    -- Set primary key value
    l_xlsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xlsv_rec,                        -- IN
      l_def_xlsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlsv_rec := fill_who_columns(l_def_xlsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlsv_rec, l_xls_rec);
    migrate(l_def_xlsv_rec, l_okl_xtl_sell_invs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xls_rec,
      lx_xls_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xls_rec, l_def_xlsv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_sell_invs_tl_rec,
      lx_okl_xtl_sell_invs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_xtl_sell_invs_tl_rec, l_def_xlsv_rec);
    -- Set OUT values
    x_xlsv_rec := l_def_xlsv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:XLSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type,
    x_xlsv_tbl                     OUT NOCOPY xlsv_tbl_type) IS

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
    IF (p_xlsv_tbl.COUNT > 0) THEN
      i := p_xlsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlsv_rec                     => p_xlsv_tbl(i),
          x_xlsv_rec                     => x_xlsv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
        EXIT WHEN (i = p_xlsv_tbl.LAST);
        i := p_xlsv_tbl.NEXT(i);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_XTL_SELL_INVS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xls_rec                      IN xls_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xls_rec IN xls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_SELL_INVS_B
     WHERE ID = p_xls_rec.id
       AND OBJECT_VERSION_NUMBER = p_xls_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xls_rec IN xls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_SELL_INVS_B
    WHERE ID = p_xls_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_XTL_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_XTL_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_xls_rec);
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
      OPEN lchk_csr(p_xls_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xls_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xls_rec.object_version_number THEN
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_XTL_SELL_INVS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_xtl_sell_invs_tl_rec IN okl_xtl_sell_invs_tl_rec_type) IS
    SELECT *
      FROM OKL_XTL_SELL_INVS_TL
     WHERE ID = p_okl_xtl_sell_invs_tl_rec.id
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
      OPEN lock_csr(p_okl_xtl_sell_invs_tl_rec);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_XTL_SELL_INVS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xls_rec                      xls_rec_type;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
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
    migrate(p_xlsv_rec, l_xls_rec);
    migrate(p_xlsv_rec, l_okl_xtl_sell_invs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xls_rec
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
      l_okl_xtl_sell_invs_tl_rec
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:XLSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type) IS

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
    IF (p_xlsv_tbl.COUNT > 0) THEN
      i := p_xlsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlsv_rec                     => p_xlsv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change


        EXIT WHEN (i = p_xlsv_tbl.LAST);
        i := p_xlsv_tbl.NEXT(i);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_XTL_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xls_rec                      IN xls_rec_type,
    x_xls_rec                      OUT NOCOPY xls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xls_rec                      xls_rec_type := p_xls_rec;
    l_def_xls_rec                  xls_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xls_rec	IN xls_rec_type,
      x_xls_rec	OUT NOCOPY xls_rec_type
    ) RETURN VARCHAR2 IS
      l_xls_rec                      xls_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xls_rec := p_xls_rec;
      -- Get current database values
      l_xls_rec := get_rec(p_xls_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xls_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.id := l_xls_rec.id;
      END IF;
      IF (x_xls_rec.ill_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.ill_id := l_xls_rec.ill_id;
      END IF;
      IF (x_xls_rec.tld_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.tld_id := l_xls_rec.tld_id;
      END IF;
      IF (x_xls_rec.lsm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.lsm_id := l_xls_rec.lsm_id;
      END IF;
      IF (x_xls_rec.til_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.til_id := l_xls_rec.til_id;
      END IF;
      IF (x_xls_rec.xsi_id_details = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.xsi_id_details := l_xls_rec.xsi_id_details;
      END IF;
      IF (x_xls_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.object_version_number := l_xls_rec.object_version_number;
      END IF;
      IF (x_xls_rec.line_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.line_type := l_xls_rec.line_type;
      END IF;
      IF (x_xls_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.amount := l_xls_rec.amount;
      END IF;
      IF (x_xls_rec.quantity = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.quantity := l_xls_rec.quantity;
      END IF;
      IF (x_xls_rec.xtrx_cons_line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.xtrx_cons_line_number := l_xls_rec.xtrx_cons_line_number;
      END IF;
      IF (x_xls_rec.xtrx_cons_stream_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.xtrx_cons_stream_id := l_xls_rec.xtrx_cons_stream_id;
      END IF;
      IF (x_xls_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.request_id := l_xls_rec.request_id;
      END IF;
      IF (x_xls_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.program_application_id := l_xls_rec.program_application_id;
      END IF;
      IF (x_xls_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.program_id := l_xls_rec.program_id;
      END IF;
      IF (x_xls_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xls_rec.program_update_date := l_xls_rec.program_update_date;
      END IF;
      IF (x_xls_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.org_id := l_xls_rec.org_id;
      END IF;

      IF (x_xls_rec.inventory_org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.inventory_org_id := l_xls_rec.inventory_org_id;
      END IF;

      IF (x_xls_rec.isl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.isl_id := l_xls_rec.isl_id;
      END IF;

      IF (x_xls_rec.sel_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.sel_id := l_xls_rec.sel_id;
      END IF;

-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_xls_rec.inventory_item_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.inventory_item_id := l_xls_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --

      IF (x_xls_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute_category := l_xls_rec.attribute_category;
      END IF;
      IF (x_xls_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute1 := l_xls_rec.attribute1;
      END IF;
      IF (x_xls_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute2 := l_xls_rec.attribute2;
      END IF;
      IF (x_xls_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute3 := l_xls_rec.attribute3;
      END IF;
      IF (x_xls_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute4 := l_xls_rec.attribute4;
      END IF;
      IF (x_xls_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute5 := l_xls_rec.attribute5;
      END IF;
      IF (x_xls_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute6 := l_xls_rec.attribute6;
      END IF;
      IF (x_xls_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute7 := l_xls_rec.attribute7;
      END IF;
      IF (x_xls_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute8 := l_xls_rec.attribute8;
      END IF;
      IF (x_xls_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute9 := l_xls_rec.attribute9;
      END IF;
      IF (x_xls_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute10 := l_xls_rec.attribute10;
      END IF;
      IF (x_xls_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute11 := l_xls_rec.attribute11;
      END IF;
      IF (x_xls_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute12 := l_xls_rec.attribute12;
      END IF;
      IF (x_xls_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute13 := l_xls_rec.attribute13;
      END IF;
      IF (x_xls_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute14 := l_xls_rec.attribute14;
      END IF;
      IF (x_xls_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xls_rec.attribute15 := l_xls_rec.attribute15;
      END IF;
      IF (x_xls_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.created_by := l_xls_rec.created_by;
      END IF;
      IF (x_xls_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xls_rec.creation_date := l_xls_rec.creation_date;
      END IF;
      IF (x_xls_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.last_updated_by := l_xls_rec.last_updated_by;
      END IF;
      IF (x_xls_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xls_rec.last_update_date := l_xls_rec.last_update_date;
      END IF;
      IF (x_xls_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xls_rec.last_update_login := l_xls_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xls_rec IN  xls_rec_type,
      x_xls_rec OUT NOCOPY xls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xls_rec := p_xls_rec;
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
      p_xls_rec,                         -- IN
      l_xls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xls_rec, l_def_xls_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_XTL_SELL_INVS_B
    SET ILL_ID = l_def_xls_rec.ill_id,
        TLD_ID = l_def_xls_rec.tld_id,
        LSM_ID = l_def_xls_rec.lsm_id,
        TIL_ID = l_def_xls_rec.til_id,
        XSI_ID_DETAILS = l_def_xls_rec.xsi_id_details,
        OBJECT_VERSION_NUMBER = l_def_xls_rec.object_version_number,
        LINE_TYPE = l_def_xls_rec.line_type,
        AMOUNT = l_def_xls_rec.amount,
        QUANTITY = l_def_xls_rec.quantity,
        XTRX_CONS_LINE_NUMBER = l_def_xls_rec.xtrx_cons_line_number,
        XTRX_CONS_STREAM_ID = l_def_xls_rec.xtrx_cons_stream_id,
        REQUEST_ID = l_def_xls_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xls_rec.program_application_id,
        PROGRAM_ID = l_def_xls_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xls_rec.program_update_date,
        ORG_ID = l_def_xls_rec.org_id,
        INVENTORY_ORG_ID = l_def_xls_rec.inventory_org_id,
        ISL_ID = l_def_xls_rec.isl_id,
        SEL_ID = l_def_xls_rec.sel_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		INVENTORY_ITEM_ID = l_def_xls_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
        ATTRIBUTE_CATEGORY = l_def_xls_rec.attribute_category,
        ATTRIBUTE1 = l_def_xls_rec.attribute1,
        ATTRIBUTE2 = l_def_xls_rec.attribute2,
        ATTRIBUTE3 = l_def_xls_rec.attribute3,
        ATTRIBUTE4 = l_def_xls_rec.attribute4,
        ATTRIBUTE5 = l_def_xls_rec.attribute5,
        ATTRIBUTE6 = l_def_xls_rec.attribute6,
        ATTRIBUTE7 = l_def_xls_rec.attribute7,
        ATTRIBUTE8 = l_def_xls_rec.attribute8,
        ATTRIBUTE9 = l_def_xls_rec.attribute9,
        ATTRIBUTE10 = l_def_xls_rec.attribute10,
        ATTRIBUTE11 = l_def_xls_rec.attribute11,
        ATTRIBUTE12 = l_def_xls_rec.attribute12,
        ATTRIBUTE13 = l_def_xls_rec.attribute13,
        ATTRIBUTE14 = l_def_xls_rec.attribute14,
        ATTRIBUTE15 = l_def_xls_rec.attribute15,
        CREATED_BY = l_def_xls_rec.created_by,
        CREATION_DATE = l_def_xls_rec.creation_date,
        LAST_UPDATED_BY = l_def_xls_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xls_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xls_rec.last_update_login
    WHERE ID = l_def_xls_rec.id;

    x_xls_rec := l_def_xls_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_XTL_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type,
    x_okl_xtl_sell_invs_tl_rec     OUT NOCOPY okl_xtl_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type := p_okl_xtl_sell_invs_tl_rec;
    ldefoklxtlsellinvstlrec        okl_xtl_sell_invs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_xtl_sell_invs_tl_rec	IN okl_xtl_sell_invs_tl_rec_type,
      x_okl_xtl_sell_invs_tl_rec	OUT NOCOPY okl_xtl_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_sell_invs_tl_rec := p_okl_xtl_sell_invs_tl_rec;
      -- Get current database values
      l_okl_xtl_sell_invs_tl_rec := get_rec(p_okl_xtl_sell_invs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_xtl_sell_invs_tl_rec.id := l_okl_xtl_sell_invs_tl_rec.id;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.LANGUAGE := l_okl_xtl_sell_invs_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.source_lang := l_okl_xtl_sell_invs_tl_rec.source_lang;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.sfwt_flag := l_okl_xtl_sell_invs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.description := l_okl_xtl_sell_invs_tl_rec.description;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.xtrx_contract = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.xtrx_contract := l_okl_xtl_sell_invs_tl_rec.xtrx_contract;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.xtrx_asset = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.xtrx_asset := l_okl_xtl_sell_invs_tl_rec.xtrx_asset;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.xtrx_stream_group = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.xtrx_stream_group := l_okl_xtl_sell_invs_tl_rec.xtrx_stream_group;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.xtrx_stream_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_xtl_sell_invs_tl_rec.xtrx_stream_type := l_okl_xtl_sell_invs_tl_rec.xtrx_stream_type;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_xtl_sell_invs_tl_rec.created_by := l_okl_xtl_sell_invs_tl_rec.created_by;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_xtl_sell_invs_tl_rec.creation_date := l_okl_xtl_sell_invs_tl_rec.creation_date;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_xtl_sell_invs_tl_rec.last_updated_by := l_okl_xtl_sell_invs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_xtl_sell_invs_tl_rec.last_update_date := l_okl_xtl_sell_invs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_xtl_sell_invs_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_xtl_sell_invs_tl_rec.last_update_login := l_okl_xtl_sell_invs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_sell_invs_tl_rec IN  okl_xtl_sell_invs_tl_rec_type,
      x_okl_xtl_sell_invs_tl_rec OUT NOCOPY okl_xtl_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_sell_invs_tl_rec := p_okl_xtl_sell_invs_tl_rec;
      x_okl_xtl_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_xtl_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_xtl_sell_invs_tl_rec,        -- IN
      l_okl_xtl_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_xtl_sell_invs_tl_rec, ldefoklxtlsellinvstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_XTL_SELL_INVS_TL
    SET DESCRIPTION = ldefoklxtlsellinvstlrec.description,
        XTRX_CONTRACT = ldefoklxtlsellinvstlrec.xtrx_contract,
        XTRX_ASSET = ldefoklxtlsellinvstlrec.xtrx_asset,
        XTRX_STREAM_GROUP = ldefoklxtlsellinvstlrec.xtrx_stream_group,
        XTRX_STREAM_TYPE = ldefoklxtlsellinvstlrec.xtrx_stream_type,
        SOURCE_LANG = ldefoklxtlsellinvstlrec.source_lang,
        CREATED_BY = ldefoklxtlsellinvstlrec.created_by,
        CREATION_DATE = ldefoklxtlsellinvstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklxtlsellinvstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklxtlsellinvstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklxtlsellinvstlrec.last_update_login
    WHERE ID = ldefoklxtlsellinvstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_XTL_SELL_INVS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklxtlsellinvstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_xtl_sell_invs_tl_rec := ldefoklxtlsellinvstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_XTL_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type,
    x_xlsv_rec                     OUT NOCOPY xlsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xlsv_rec                     xlsv_rec_type := p_xlsv_rec;
    l_def_xlsv_rec                 xlsv_rec_type;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
    lx_okl_xtl_sell_invs_tl_rec    okl_xtl_sell_invs_tl_rec_type;
    l_xls_rec                      xls_rec_type;
    lx_xls_rec                     xls_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlsv_rec	IN xlsv_rec_type
    ) RETURN xlsv_rec_type IS
      l_xlsv_rec	xlsv_rec_type := p_xlsv_rec;
    BEGIN
      l_xlsv_rec.LAST_UPDATE_DATE := l_xlsv_rec.creation_date;
      l_xlsv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_xlsv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_xlsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xlsv_rec	IN xlsv_rec_type,
      x_xlsv_rec	OUT NOCOPY xlsv_rec_type
    ) RETURN VARCHAR2 IS
      l_xlsv_rec                     xlsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xlsv_rec := p_xlsv_rec;
      -- Get current database values
      l_xlsv_rec := get_rec(p_xlsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xlsv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.id := l_xlsv_rec.id;
      END IF;
      IF (x_xlsv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.object_version_number := l_xlsv_rec.object_version_number;
      END IF;
      IF (x_xlsv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.sfwt_flag := l_xlsv_rec.sfwt_flag;
      END IF;
      IF (x_xlsv_rec.tld_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.tld_id := l_xlsv_rec.tld_id;
      END IF;
      IF (x_xlsv_rec.lsm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.lsm_id := l_xlsv_rec.lsm_id;
      END IF;
      IF (x_xlsv_rec.til_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.til_id := l_xlsv_rec.til_id;
      END IF;
      IF (x_xlsv_rec.ill_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.ill_id := l_xlsv_rec.ill_id;
      END IF;
      IF (x_xlsv_rec.xsi_id_details = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.xsi_id_details := l_xlsv_rec.xsi_id_details;
      END IF;
      IF (x_xlsv_rec.line_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.line_type := l_xlsv_rec.line_type;
      END IF;
      IF (x_xlsv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.description := l_xlsv_rec.description;
      END IF;
      IF (x_xlsv_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.amount := l_xlsv_rec.amount;
      END IF;
      IF (x_xlsv_rec.quantity = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.quantity := l_xlsv_rec.quantity;
      END IF;
      IF (x_xlsv_rec.xtrx_cons_line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.xtrx_cons_line_number := l_xlsv_rec.xtrx_cons_line_number;
      END IF;
      IF (x_xlsv_rec.xtrx_contract = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.xtrx_contract := l_xlsv_rec.xtrx_contract;
      END IF;
      IF (x_xlsv_rec.xtrx_asset = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.xtrx_asset := l_xlsv_rec.xtrx_asset;
      END IF;
      IF (x_xlsv_rec.xtrx_stream_group = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.xtrx_stream_group := l_xlsv_rec.xtrx_stream_group;
      END IF;
      IF (x_xlsv_rec.xtrx_stream_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.xtrx_stream_type := l_xlsv_rec.xtrx_stream_type;
      END IF;
      IF (x_xlsv_rec.xtrx_cons_stream_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.xtrx_cons_stream_id := l_xlsv_rec.xtrx_cons_stream_id;
      END IF;
      IF (x_xlsv_rec.isl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.isl_id := l_xlsv_rec.isl_id;
      END IF;

      IF (x_xlsv_rec.sel_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.sel_id := l_xlsv_rec.sel_id;
      END IF;

-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_xlsv_rec.inventory_item_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.inventory_item_id := l_xlsv_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --

      IF (x_xlsv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute_category := l_xlsv_rec.attribute_category;
      END IF;
      IF (x_xlsv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute1 := l_xlsv_rec.attribute1;
      END IF;
      IF (x_xlsv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute2 := l_xlsv_rec.attribute2;
      END IF;
      IF (x_xlsv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute3 := l_xlsv_rec.attribute3;
      END IF;
      IF (x_xlsv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute4 := l_xlsv_rec.attribute4;
      END IF;
      IF (x_xlsv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute5 := l_xlsv_rec.attribute5;
      END IF;
      IF (x_xlsv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute6 := l_xlsv_rec.attribute6;
      END IF;
      IF (x_xlsv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute7 := l_xlsv_rec.attribute7;
      END IF;
      IF (x_xlsv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute8 := l_xlsv_rec.attribute8;
      END IF;
      IF (x_xlsv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute9 := l_xlsv_rec.attribute9;
      END IF;
      IF (x_xlsv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute10 := l_xlsv_rec.attribute10;
      END IF;
      IF (x_xlsv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute11 := l_xlsv_rec.attribute11;
      END IF;
      IF (x_xlsv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute12 := l_xlsv_rec.attribute12;
      END IF;
      IF (x_xlsv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute13 := l_xlsv_rec.attribute13;
      END IF;
      IF (x_xlsv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute14 := l_xlsv_rec.attribute14;
      END IF;
      IF (x_xlsv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_xlsv_rec.attribute15 := l_xlsv_rec.attribute15;
      END IF;
      IF (x_xlsv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.request_id := l_xlsv_rec.request_id;
      END IF;
      IF (x_xlsv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.program_application_id := l_xlsv_rec.program_application_id;
      END IF;
      IF (x_xlsv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.program_id := l_xlsv_rec.program_id;
      END IF;
      IF (x_xlsv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xlsv_rec.program_update_date := l_xlsv_rec.program_update_date;
      END IF;
      IF (x_xlsv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.org_id := l_xlsv_rec.org_id;
      END IF;

      IF (x_xlsv_rec.inventory_org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.inventory_org_id := l_xlsv_rec.inventory_org_id;
      END IF;

      IF (x_xlsv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.created_by := l_xlsv_rec.created_by;
      END IF;
      IF (x_xlsv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xlsv_rec.creation_date := l_xlsv_rec.creation_date;
      END IF;
      IF (x_xlsv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.last_updated_by := l_xlsv_rec.last_updated_by;
      END IF;
      IF (x_xlsv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_xlsv_rec.last_update_date := l_xlsv_rec.last_update_date;
      END IF;
      IF (x_xlsv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_xlsv_rec.last_update_login := l_xlsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlsv_rec IN  xlsv_rec_type,
      x_xlsv_rec OUT NOCOPY xlsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_xlsv_rec := p_xlsv_rec;
      x_xlsv_rec.OBJECT_VERSION_NUMBER := NVL(x_xlsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_xlsv_rec.request_id IS NULL OR x_xlsv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xlsv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xlsv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xlsv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xlsv_rec.program_update_date,SYSDATE)
      INTO
        x_xlsv_rec.request_id,
        x_xlsv_rec.program_application_id,
        x_xlsv_rec.program_id,
        x_xlsv_rec.program_update_date
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
      p_xlsv_rec,                        -- IN
      l_xlsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xlsv_rec, l_def_xlsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlsv_rec := fill_who_columns(l_def_xlsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlsv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlsv_rec, l_okl_xtl_sell_invs_tl_rec);
    migrate(l_def_xlsv_rec, l_xls_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_sell_invs_tl_rec,
      lx_okl_xtl_sell_invs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_xtl_sell_invs_tl_rec, l_def_xlsv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xls_rec,
      lx_xls_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xls_rec, l_def_xlsv_rec);
    x_xlsv_rec := l_def_xlsv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:XLSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type,
    x_xlsv_tbl                     OUT NOCOPY xlsv_tbl_type) IS

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
    IF (p_xlsv_tbl.COUNT > 0) THEN
      i := p_xlsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlsv_rec                     => p_xlsv_tbl(i),
          x_xlsv_rec                     => x_xlsv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_xlsv_tbl.LAST);
        i := p_xlsv_tbl.NEXT(i);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_XTL_SELL_INVS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xls_rec                      IN xls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xls_rec                      xls_rec_type:= p_xls_rec;
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
    DELETE FROM OKL_XTL_SELL_INVS_B
     WHERE ID = l_xls_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_XTL_SELL_INVS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_sell_invs_tl_rec     IN okl_xtl_sell_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type:= p_okl_xtl_sell_invs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_XTL_SELL_INVS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_sell_invs_tl_rec IN  okl_xtl_sell_invs_tl_rec_type,
      x_okl_xtl_sell_invs_tl_rec OUT NOCOPY okl_xtl_sell_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_sell_invs_tl_rec := p_okl_xtl_sell_invs_tl_rec;
      x_okl_xtl_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_xtl_sell_invs_tl_rec,        -- IN
      l_okl_xtl_sell_invs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_XTL_SELL_INVS_TL
     WHERE ID = l_okl_xtl_sell_invs_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_XTL_SELL_INVS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_rec                     IN xlsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xlsv_rec                     xlsv_rec_type := p_xlsv_rec;
    l_okl_xtl_sell_invs_tl_rec     okl_xtl_sell_invs_tl_rec_type;
    l_xls_rec                      xls_rec_type;
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
    migrate(l_xlsv_rec, l_okl_xtl_sell_invs_tl_rec);
    migrate(l_xlsv_rec, l_xls_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_sell_invs_tl_rec
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
      l_xls_rec
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:XLSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlsv_tbl                     IN xlsv_tbl_type) IS

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
    IF (p_xlsv_tbl.COUNT > 0) THEN
      i := p_xlsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlsv_rec                     => p_xlsv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_xlsv_tbl.LAST);
        i := p_xlsv_tbl.NEXT(i);
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
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
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
END Okl_Xls_Pvt;

/
