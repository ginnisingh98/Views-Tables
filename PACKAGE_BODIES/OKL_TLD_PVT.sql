--------------------------------------------------------
--  DDL for Package Body OKL_TLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TLD_PVT" AS
/* $Header: OKLSTLDB.pls 120.10 2007/07/17 09:32:20 gkhuntet ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_tldv_rec IN tldv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_tldv_rec.id = Okl_api.G_MISS_NUM OR
       p_tldv_rec.id IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;



  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_org_id (p_tldv_rec IN tldv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_api.G_RET_STS_SUCCESS;
	IF (p_tldv_rec.org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_tldv_rec.org_id);
	END IF;
  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_inventory_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_inventory_org_id (p_tldv_rec IN tldv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_tldv_rec.inventory_org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_tldv_rec.inventory_org_id);
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
  PROCEDURE validate_object_version_number (p_tldv_rec IN tldv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_tldv_rec.id = Okl_api.G_MISS_NUM OR
       p_tldv_rec.id IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;



  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_line_detail_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_line_detail_number (p_tldv_rec IN tldv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_tldv_rec.line_detail_number = Okl_api.G_MISS_NUM OR
       p_tldv_rec.line_detail_number IS NULL
    THEN

      x_return_status := Okl_api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'line_detail_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

  END validate_line_detail_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_bch_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_bch_id (p_tldv_rec IN tldv_rec_type,
  											x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_bch_id_csr IS
    SELECT '1'
	FROM OKL_BILLING_CHARGES_B
	WHERE id = p_tldv_rec.bch_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.bch_id IS NOT NULL) THEN
	   	  OPEN l_bch_id_csr;
		  FETCH l_bch_id_csr INTO l_dummy_var;
		  CLOSE l_bch_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'BCH_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_bch_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_bcl_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_bcl_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_bcl_id_csr IS
    SELECT '1'
	FROM OKS_BILL_CONT_LINES
	WHERE id = p_tldv_rec.bcl_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.bcl_id IS NOT NULL) THEN
	   	  OPEN l_bcl_id_csr;
		  FETCH l_bcl_id_csr INTO l_dummy_var;
		  CLOSE l_bcl_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'BCL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_bcl_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_bsl_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_bsl_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_bsl_id_csr IS
    SELECT '1'
	FROM OKS_BILL_SUB_LINES
	WHERE id = p_tldv_rec.bsl_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.bsl_id IS NOT NULL) THEN
	   	  OPEN l_bsl_id_csr;
		  FETCH l_bsl_id_csr INTO l_dummy_var;
		  CLOSE l_bsl_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'BSL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_bsl_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_bgh_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_bgh_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_bgh_id_csr IS
    SELECT '1'
	FROM OKL_BLLNG_CHRG_HDRS_B
	WHERE id = p_tldv_rec.bgh_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.bgh_id IS NOT NULL) THEN
	   	  OPEN l_bgh_id_csr;
		  FETCH l_bgh_id_csr INTO l_dummy_var;
		  CLOSE l_bgh_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'BGH_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_bgh_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_idx_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_idx_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_idx_id_csr IS
    SELECT '1'
	FROM OKL_INDICES
	WHERE id = p_tldv_rec.idx_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.idx_id IS NOT NULL) THEN
	   	  OPEN l_idx_id_csr;
		  FETCH l_idx_id_csr INTO l_dummy_var;
		  CLOSE l_idx_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IDX_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_idx_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sel_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_sel_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_sel_id_csr IS
    SELECT '1'
	FROM OKL_STRM_ELEMENTS
	WHERE id = p_tldv_rec.sel_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.sel_id IS NOT NULL) THEN
	   	  OPEN l_sel_id_csr;
		  FETCH l_sel_id_csr INTO l_dummy_var;
		  CLOSE l_sel_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'SEL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_sel_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sty_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_sty_id (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_sty_id_csr IS
    SELECT '1'
	FROM OKL_STRM_TYPE_B
	WHERE id = p_tldv_rec.sty_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.sty_id IS NOT NULL) THEN
	   	  OPEN l_sty_id_csr;
		  FETCH l_sty_id_csr INTO l_dummy_var;
		  CLOSE l_sty_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'STY_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_sty_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_til_id_details
  ---------------------------------------------------------------------------
  PROCEDURE validate_til_id_details (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_til_id_details_csr IS
    SELECT '1'
	FROM OKL_TXL_AR_INV_LNS_B
	WHERE id = p_tldv_rec.til_id_details;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.til_id_details IS NOT NULL) THEN
	   	  OPEN l_til_id_details_csr;
		  FETCH l_til_id_details_csr INTO l_dummy_var;
		  CLOSE l_til_id_details_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TIL_ID_DETAILS_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_til_id_details;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tld_id_reverses
  ---------------------------------------------------------------------------
  PROCEDURE validate_tld_id_reverses (p_tldv_rec IN tldv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tld_id_reverses_csr IS
    SELECT '1'
	FROM OKL_TXD_AR_LN_DTLS_B
	WHERE id = p_tldv_rec.tld_id_reverses;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_tldv_rec.tld_id_reverses IS NOT NULL) THEN
	   	  OPEN l_tld_id_reverses_csr;
		  FETCH l_tld_id_reverses_csr INTO l_dummy_var;
		  CLOSE l_tld_id_reverses_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TIL_ID_REVERSES_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXD_AR_LN_DTLS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tld_id_reverses;

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
-- start: cklee 03/13/07
  FUNCTION get_seq_id RETURN NUMBER IS
    cursor c_seq is
	SELECT OKL_TXD_AR_LN_DTLS_B_S.NEXTVAL
	FROM dual;
    l_seq number;
  BEGIN
--    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
    open c_seq;
    fetch c_seq into l_seq;
    close c_seq;
    RETURN(l_seq);
  END get_seq_id;
-- end: cklee 03/13/07

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
    DELETE FROM OKL_TXD_AR_LN_DTLS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXD_AR_LN_DTLS_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_TXD_AR_LN_DTLS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXD_AR_LN_DTLS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXD_AR_LN_DTLS_TL SUBB, OKL_TXD_AR_LN_DTLS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXD_AR_LN_DTLS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        ERROR_MESSAGE,
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
            B.ERROR_MESSAGE,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TXD_AR_LN_DTLS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXD_AR_LN_DTLS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_AR_LN_DTLS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tld_rec                      IN tld_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tld_rec_type IS
    CURSOR okl_txd_ar_ln_dtls_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            BCH_ID,
            BCL_ID,
            BSL_ID,
            BGH_ID,
            IDX_ID,
            SEL_ID,
            STY_ID,
            TIL_ID_DETAILS,
            TLD_ID_REVERSES,
            LINE_DETAIL_NUMBER,
            OBJECT_VERSION_NUMBER,
            LATE_CHARGE_YN,
            DATE_CALCULATION,
            FIXED_RATE_YN,
            AMOUNT,
            RECEIVABLES_INVOICE_ID,
            AMOUNT_APPLIED,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            INVENTORY_ORG_ID,
-- Start bug 4055540 fmiao 12/12/04 --
            INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
    TXL_AR_LINE_NUMBER,
    INVOICE_FORMAT_TYPE,
    INVOICE_FORMAT_LINE_TYPE,
    LATE_CHARGE_ASSESS_DATE,
    LATE_INT_ASSESS_DATE,
    LATE_CHARGE_ASS_YN,
    LATE_INT_ASS_YN,
    INVESTOR_DISB_STATUS,
    INVESTOR_DISB_ERR_MG,
    DATE_DISBURSED,
    PAY_STATUS_CODE,
    RBK_ORI_INVOICE_NUMBER,
    RBK_ORI_INVOICE_LINE_NUMBER,
    RBK_ADJUSTMENT_DATE,
    KHR_ID,
    KLE_ID,
    TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

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
      FROM Okl_Txd_Ar_Ln_Dtls_B
     WHERE okl_txd_ar_ln_dtls_b.id = p_id;
    l_okl_txd_ar_ln_dtls_b_pk      okl_txd_ar_ln_dtls_b_pk_csr%ROWTYPE;
    l_tld_rec                      tld_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txd_ar_ln_dtls_b_pk_csr (p_tld_rec.id);
    FETCH okl_txd_ar_ln_dtls_b_pk_csr INTO
              l_tld_rec.ID,
              l_tld_rec.BCH_ID,
              l_tld_rec.BCL_ID,
              l_tld_rec.BSL_ID,
              l_tld_rec.BGH_ID,
              l_tld_rec.IDX_ID,
              l_tld_rec.SEL_ID,
              l_tld_rec.STY_ID,
              l_tld_rec.TIL_ID_DETAILS,
              l_tld_rec.TLD_ID_REVERSES,
              l_tld_rec.LINE_DETAIL_NUMBER,
              l_tld_rec.OBJECT_VERSION_NUMBER,
              l_tld_rec.LATE_CHARGE_YN,
              l_tld_rec.DATE_CALCULATION,
              l_tld_rec.FIXED_RATE_YN,
              l_tld_rec.AMOUNT,
              l_tld_rec.RECEIVABLES_INVOICE_ID,
              l_tld_rec.AMOUNT_APPLIED,
              l_tld_rec.REQUEST_ID,
              l_tld_rec.PROGRAM_APPLICATION_ID,
              l_tld_rec.PROGRAM_ID,
              l_tld_rec.PROGRAM_UPDATE_DATE,
              l_tld_rec.ORG_ID,
              l_tld_rec.INVENTORY_ORG_ID,
-- Start bug 4055540 fmiao 12/12/04 --
              l_tld_rec.INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
              l_tld_rec.TXL_AR_LINE_NUMBER,
              l_tld_rec.INVOICE_FORMAT_TYPE,
              l_tld_rec.INVOICE_FORMAT_LINE_TYPE,
              l_tld_rec.LATE_CHARGE_ASSESS_DATE,
              l_tld_rec.LATE_INT_ASSESS_DATE,
              l_tld_rec.LATE_CHARGE_ASS_YN,
              l_tld_rec.LATE_INT_ASS_YN,
              l_tld_rec.INVESTOR_DISB_STATUS,
              l_tld_rec.INVESTOR_DISB_ERR_MG,
              l_tld_rec.DATE_DISBURSED,
              l_tld_rec.PAY_STATUS_CODE,
              l_tld_rec.RBK_ORI_INVOICE_NUMBER,
              l_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER,
              l_tld_rec.RBK_ADJUSTMENT_DATE,
              l_tld_rec.KHR_ID,
              l_tld_rec.KLE_ID,
              l_tld_rec.TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

              l_tld_rec.ATTRIBUTE_CATEGORY,
              l_tld_rec.ATTRIBUTE1,
              l_tld_rec.ATTRIBUTE2,
              l_tld_rec.ATTRIBUTE3,
              l_tld_rec.ATTRIBUTE4,
              l_tld_rec.ATTRIBUTE5,
              l_tld_rec.ATTRIBUTE6,
              l_tld_rec.ATTRIBUTE7,
              l_tld_rec.ATTRIBUTE8,
              l_tld_rec.ATTRIBUTE9,
              l_tld_rec.ATTRIBUTE10,
              l_tld_rec.ATTRIBUTE11,
              l_tld_rec.ATTRIBUTE12,
              l_tld_rec.ATTRIBUTE13,
              l_tld_rec.ATTRIBUTE14,
              l_tld_rec.ATTRIBUTE15,
              l_tld_rec.CREATED_BY,
              l_tld_rec.CREATION_DATE,
              l_tld_rec.LAST_UPDATED_BY,
              l_tld_rec.LAST_UPDATE_DATE,
              l_tld_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txd_ar_ln_dtls_b_pk_csr%NOTFOUND;
    CLOSE okl_txd_ar_ln_dtls_b_pk_csr;
    RETURN(l_tld_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tld_rec                      IN tld_rec_type
  ) RETURN tld_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tld_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_AR_LN_DTLS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txd_ar_ln_dtls_tl_rec_type IS
    CURSOR okl_txd_ar_ln_dtls_tl_pk_csr (p_id                 IN NUMBER,
                                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            ERROR_MESSAGE,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Txd_Ar_Ln_Dtls_Tl
     WHERE okl_txd_ar_ln_dtls_tl.id = p_id
       AND okl_txd_ar_ln_dtls_tl.LANGUAGE = p_language;
    l_okl_txd_ar_ln_dtls_tl_pk     okl_txd_ar_ln_dtls_tl_pk_csr%ROWTYPE;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txd_ar_ln_dtls_tl_pk_csr (p_okl_txd_ar_ln_dtls_tl_rec.id,
                                       p_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE);
    FETCH okl_txd_ar_ln_dtls_tl_pk_csr INTO
              l_okl_txd_ar_ln_dtls_tl_rec.ID,
              l_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE,
              l_okl_txd_ar_ln_dtls_tl_rec.SOURCE_LANG,
              l_okl_txd_ar_ln_dtls_tl_rec.ERROR_MESSAGE,
              l_okl_txd_ar_ln_dtls_tl_rec.SFWT_FLAG,
              l_okl_txd_ar_ln_dtls_tl_rec.DESCRIPTION,
              l_okl_txd_ar_ln_dtls_tl_rec.CREATED_BY,
              l_okl_txd_ar_ln_dtls_tl_rec.CREATION_DATE,
              l_okl_txd_ar_ln_dtls_tl_rec.LAST_UPDATED_BY,
              l_okl_txd_ar_ln_dtls_tl_rec.LAST_UPDATE_DATE,
              l_okl_txd_ar_ln_dtls_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txd_ar_ln_dtls_tl_pk_csr%NOTFOUND;
    CLOSE okl_txd_ar_ln_dtls_tl_pk_csr;
    RETURN(l_okl_txd_ar_ln_dtls_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type
  ) RETURN okl_txd_ar_ln_dtls_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txd_ar_ln_dtls_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_AR_LN_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tldv_rec                     IN tldv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tldv_rec_type IS
    CURSOR okl_tldv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ERROR_MESSAGE,
            SFWT_FLAG,
            BCH_ID,
            BGH_ID,
            IDX_ID,
            TLD_ID_REVERSES,
            STY_ID,
            SEL_ID,
            TIL_ID_DETAILS,
            BCL_ID,
            BSL_ID,
            AMOUNT,
            LINE_DETAIL_NUMBER,
            RECEIVABLES_INVOICE_ID,
            LATE_CHARGE_YN,
            DESCRIPTION,
            AMOUNT_APPLIED,
            DATE_CALCULATION,
            FIXED_RATE_YN,
-- Start bug 4055540 fmiao 12/12/04 --
            inventory_item_id,
-- End bug 4055540 fmiao 12/12/04 --
--start: 30-Jan-07 cklee  Billing R12 project                             |
            TXL_AR_LINE_NUMBER,
            INVOICE_FORMAT_TYPE,
            INVOICE_FORMAT_LINE_TYPE,
            LATE_CHARGE_ASSESS_DATE,
            LATE_INT_ASSESS_DATE,
            LATE_CHARGE_ASS_YN,
            LATE_INT_ASS_YN,
            INVESTOR_DISB_STATUS,
            INVESTOR_DISB_ERR_MG,
            DATE_DISBURSED,
            PAY_STATUS_CODE,
            RBK_ORI_INVOICE_NUMBER,
            RBK_ORI_INVOICE_LINE_NUMBER,
            RBK_ADJUSTMENT_DATE,
            KHR_ID,
            KLE_ID,
            TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

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
      FROM Okl_Txd_Ar_Ln_Dtls_V
     WHERE okl_txd_ar_ln_dtls_v.id = p_id;
    l_okl_tldv_pk                  okl_tldv_pk_csr%ROWTYPE;
    l_tldv_rec                     tldv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tldv_pk_csr (p_tldv_rec.id);
    FETCH okl_tldv_pk_csr INTO
              l_tldv_rec.ID,
              l_tldv_rec.OBJECT_VERSION_NUMBER,
              l_tldv_rec.ERROR_MESSAGE,
              l_tldv_rec.SFWT_FLAG,
              l_tldv_rec.BCH_ID,
              l_tldv_rec.BGH_ID,
              l_tldv_rec.IDX_ID,
              l_tldv_rec.TLD_ID_REVERSES,
              l_tldv_rec.STY_ID,
              l_tldv_rec.SEL_ID,
              l_tldv_rec.TIL_ID_DETAILS,
              l_tldv_rec.BCL_ID,
              l_tldv_rec.BSL_ID,
              l_tldv_rec.AMOUNT,
              l_tldv_rec.LINE_DETAIL_NUMBER,
              l_tldv_rec.RECEIVABLES_INVOICE_ID,
              l_tldv_rec.LATE_CHARGE_YN,
              l_tldv_rec.DESCRIPTION,
              l_tldv_rec.AMOUNT_APPLIED,
              l_tldv_rec.DATE_CALCULATION,
              l_tldv_rec.FIXED_RATE_YN,
-- Start bug 4055540 fmiao 12/12/04 --
              l_tldv_rec.INVENTORY_ITEM_ID,
-- End bug 4055540 fmiao 12/12/04 --
--start: 30-Jan-07 cklee  Billing R12 project                             |
              l_tldv_rec.TXL_AR_LINE_NUMBER,
              l_tldv_rec.INVOICE_FORMAT_TYPE,
              l_tldv_rec.INVOICE_FORMAT_LINE_TYPE,
              l_tldv_rec.LATE_CHARGE_ASSESS_DATE,
              l_tldv_rec.LATE_INT_ASSESS_DATE,
              l_tldv_rec.LATE_CHARGE_ASS_YN,
              l_tldv_rec.LATE_INT_ASS_YN,
              l_tldv_rec.INVESTOR_DISB_STATUS,
              l_tldv_rec.INVESTOR_DISB_ERR_MG,
              l_tldv_rec.DATE_DISBURSED,
              l_tldv_rec.PAY_STATUS_CODE,
              l_tldv_rec.RBK_ORI_INVOICE_NUMBER,
              l_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER,
              l_tldv_rec.RBK_ADJUSTMENT_DATE,
              l_tldv_rec.KHR_ID,
              l_tldv_rec.KLE_ID,
              l_tldv_rec.TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

              l_tldv_rec.ATTRIBUTE_CATEGORY,
              l_tldv_rec.ATTRIBUTE1,
              l_tldv_rec.ATTRIBUTE2,
              l_tldv_rec.ATTRIBUTE3,
              l_tldv_rec.ATTRIBUTE4,
              l_tldv_rec.ATTRIBUTE5,
              l_tldv_rec.ATTRIBUTE6,
              l_tldv_rec.ATTRIBUTE7,
              l_tldv_rec.ATTRIBUTE8,
              l_tldv_rec.ATTRIBUTE9,
              l_tldv_rec.ATTRIBUTE10,
              l_tldv_rec.ATTRIBUTE11,
              l_tldv_rec.ATTRIBUTE12,
              l_tldv_rec.ATTRIBUTE13,
              l_tldv_rec.ATTRIBUTE14,
              l_tldv_rec.ATTRIBUTE15,
              l_tldv_rec.REQUEST_ID,
              l_tldv_rec.PROGRAM_APPLICATION_ID,
              l_tldv_rec.PROGRAM_ID,
              l_tldv_rec.PROGRAM_UPDATE_DATE,
              l_tldv_rec.ORG_ID,
              l_tldv_rec.INVENTORY_ORG_ID,
              l_tldv_rec.CREATED_BY,
              l_tldv_rec.CREATION_DATE,
              l_tldv_rec.LAST_UPDATED_BY,
              l_tldv_rec.LAST_UPDATE_DATE,
              l_tldv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_tldv_pk_csr%NOTFOUND;
    CLOSE okl_tldv_pk_csr;
    RETURN(l_tldv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tldv_rec                     IN tldv_rec_type
  ) RETURN tldv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tldv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXD_AR_LN_DTLS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tldv_rec	IN tldv_rec_type
  ) RETURN tldv_rec_type IS
    l_tldv_rec	tldv_rec_type := p_tldv_rec;
  BEGIN
    IF (l_tldv_rec.object_version_number = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.object_version_number := NULL;
    END IF;
    IF (l_tldv_rec.error_message = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.error_message := NULL;
    END IF;
    IF (l_tldv_rec.sfwt_flag = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tldv_rec.bch_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.bch_id := NULL;
    END IF;
    IF (l_tldv_rec.bgh_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.bgh_id := NULL;
    END IF;
    IF (l_tldv_rec.idx_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.idx_id := NULL;
    END IF;
    IF (l_tldv_rec.tld_id_reverses = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.tld_id_reverses := NULL;
    END IF;
    IF (l_tldv_rec.sty_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.sty_id := NULL;
    END IF;
    IF (l_tldv_rec.sel_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.sel_id := NULL;
    END IF;
    IF (l_tldv_rec.til_id_details = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.til_id_details := NULL;
    END IF;
    IF (l_tldv_rec.bcl_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.bcl_id := NULL;
    END IF;
    IF (l_tldv_rec.bsl_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.bsl_id := NULL;
    END IF;
    IF (l_tldv_rec.amount = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.amount := NULL;
    END IF;
    IF (l_tldv_rec.line_detail_number = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.line_detail_number := NULL;
    END IF;
    IF (l_tldv_rec.receivables_invoice_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.receivables_invoice_id := NULL;
    END IF;
    IF (l_tldv_rec.late_charge_yn = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.late_charge_yn := NULL;
    END IF;
    IF (l_tldv_rec.description = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.description := NULL;
    END IF;
    IF (l_tldv_rec.amount_applied = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.amount_applied := NULL;
    END IF;
    IF (l_tldv_rec.date_calculation = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.date_calculation := NULL;
    END IF;
    IF (l_tldv_rec.fixed_rate_yn = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.fixed_rate_yn := NULL;
    END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
    IF (l_tldv_rec.inventory_item_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.inventory_item_id := NULL;
    END IF;
-- End changes on remarketing by fmiao on 10/18/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
    IF (l_tldv_rec.TXL_AR_LINE_NUMBER = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.TXL_AR_LINE_NUMBER := NULL;
    END IF;

    IF (l_tldv_rec.INVOICE_FORMAT_TYPE = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.INVOICE_FORMAT_TYPE := NULL;
    END IF;

    IF (l_tldv_rec.INVOICE_FORMAT_LINE_TYPE = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.INVOICE_FORMAT_LINE_TYPE := NULL;
    END IF;

    IF (l_tldv_rec.LATE_CHARGE_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.LATE_CHARGE_ASSESS_DATE := NULL;
    END IF;

    IF (l_tldv_rec.LATE_INT_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.LATE_INT_ASSESS_DATE := NULL;
    END IF;

    IF (l_tldv_rec.LATE_CHARGE_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.LATE_CHARGE_ASS_YN := NULL;
    END IF;

    IF (l_tldv_rec.LATE_INT_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.LATE_INT_ASS_YN := NULL;
    END IF;

    IF (l_tldv_rec.INVESTOR_DISB_STATUS = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.INVESTOR_DISB_STATUS := NULL;
    END IF;

    IF (l_tldv_rec.INVESTOR_DISB_ERR_MG = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.INVESTOR_DISB_ERR_MG := NULL;
    END IF;

    IF (l_tldv_rec.DATE_DISBURSED = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.DATE_DISBURSED := NULL;
    END IF;

    IF (l_tldv_rec.PAY_STATUS_CODE = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.PAY_STATUS_CODE := NULL;
    END IF;

    IF (l_tldv_rec.RBK_ORI_INVOICE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.RBK_ORI_INVOICE_NUMBER := NULL;
    END IF;

    IF (l_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER := NULL;
    END IF;

    IF (l_tldv_rec.RBK_ADJUSTMENT_DATE = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.RBK_ADJUSTMENT_DATE := NULL;
    END IF;

--start: 26-02-07 gkhuntet  Invalid assignment.
    IF (l_tldv_rec.KHR_ID = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.KHR_ID := NULL;
    END IF;

    IF (l_tldv_rec.KLE_ID = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.KLE_ID := NULL;
    END IF;
--end: 26-02-07 gkhuntet

    IF (l_tldv_rec.TAX_AMOUNT = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.TAX_AMOUNT := NULL;
    END IF;

--end: 30-Jan-07 cklee  Billing R12 project                             |



    IF (l_tldv_rec.attribute_category = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute_category := NULL;
    END IF;
    IF (l_tldv_rec.attribute1 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute1 := NULL;
    END IF;
    IF (l_tldv_rec.attribute2 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute2 := NULL;
    END IF;
    IF (l_tldv_rec.attribute3 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute3 := NULL;
    END IF;
    IF (l_tldv_rec.attribute4 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute4 := NULL;
    END IF;
    IF (l_tldv_rec.attribute5 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute5 := NULL;
    END IF;
    IF (l_tldv_rec.attribute6 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute6 := NULL;
    END IF;
    IF (l_tldv_rec.attribute7 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute7 := NULL;
    END IF;
    IF (l_tldv_rec.attribute8 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute8 := NULL;
    END IF;
    IF (l_tldv_rec.attribute9 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute9 := NULL;
    END IF;
    IF (l_tldv_rec.attribute10 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute10 := NULL;
    END IF;
    IF (l_tldv_rec.attribute11 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute11 := NULL;
    END IF;
    IF (l_tldv_rec.attribute12 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute12 := NULL;
    END IF;
    IF (l_tldv_rec.attribute13 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute13 := NULL;
    END IF;
    IF (l_tldv_rec.attribute14 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute14 := NULL;
    END IF;
    IF (l_tldv_rec.attribute15 = Okl_api.G_MISS_CHAR) THEN
      l_tldv_rec.attribute15 := NULL;
    END IF;
    IF (l_tldv_rec.request_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.request_id := NULL;
    END IF;
    IF (l_tldv_rec.program_application_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.program_application_id := NULL;
    END IF;
    IF (l_tldv_rec.program_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.program_id := NULL;
    END IF;
    IF (l_tldv_rec.program_update_date = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.program_update_date := NULL;
    END IF;

    IF (l_tldv_rec.org_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.org_id := NULL;
    END IF;

    IF (l_tldv_rec.inventory_org_id = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.inventory_org_id := NULL;
    END IF;

    IF (l_tldv_rec.created_by = Okl_api.G_MISS_NUM) THEN

      l_tldv_rec.created_by := NULL;
    END IF;
    IF (l_tldv_rec.creation_date = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.creation_date := NULL;
    END IF;
    IF (l_tldv_rec.last_updated_by = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tldv_rec.last_update_date = Okl_api.G_MISS_DATE) THEN
      l_tldv_rec.last_update_date := NULL;
    END IF;
    IF (l_tldv_rec.last_update_login = Okl_api.G_MISS_NUM) THEN
      l_tldv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_tldv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_TXD_AR_LN_DTLS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tldv_rec IN  tldv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
	-- Added 04/17/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
  BEGIN
  	-- Added 04/17/2001 -- Sunil Mathew
    validate_bch_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_bcl_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_bsl_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_bgh_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_idx_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sel_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sty_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_til_id_details(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_tld_id_reverses(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

 	validate_object_version_number(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_line_detail_number(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_org_id(p_tldv_rec, x_return_status);
	IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_inventory_org_id(p_tldv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	-- End Addition 04/17/2001 -- Sunil Mathew

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_TXD_AR_LN_DTLS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_tldv_rec IN tldv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;

  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tldv_rec_type,
    p_to	IN OUT NOCOPY tld_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bch_id := p_from.bch_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bgh_id := p_from.bgh_id;
    p_to.idx_id := p_from.idx_id;
    p_to.sel_id := p_from.sel_id;
    p_to.sty_id := p_from.sty_id;
    p_to.til_id_details := p_from.til_id_details;
    p_to.tld_id_reverses := p_from.tld_id_reverses;
    p_to.line_detail_number := p_from.line_detail_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_charge_yn := p_from.late_charge_yn;
    p_to.date_calculation := p_from.date_calculation;
    p_to.fixed_rate_yn := p_from.fixed_rate_yn;
    p_to.amount := p_from.amount;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.amount_applied := p_from.amount_applied;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
    p_to.TXL_AR_LINE_NUMBER := p_from.TXL_AR_LINE_NUMBER;
    p_to.INVOICE_FORMAT_TYPE := p_from.INVOICE_FORMAT_TYPE;
    p_to.INVOICE_FORMAT_LINE_TYPE := p_from.INVOICE_FORMAT_LINE_TYPE;
    p_to.LATE_CHARGE_ASSESS_DATE := p_from.LATE_CHARGE_ASSESS_DATE;
    p_to.LATE_INT_ASSESS_DATE := p_from.LATE_INT_ASSESS_DATE;
    p_to.LATE_CHARGE_ASS_YN := p_from.LATE_CHARGE_ASS_YN;
    p_to.LATE_INT_ASS_YN := p_from.LATE_INT_ASS_YN;
    p_to.INVESTOR_DISB_STATUS := p_from.INVESTOR_DISB_STATUS;
    p_to.INVESTOR_DISB_ERR_MG := p_from.INVESTOR_DISB_ERR_MG;
    p_to.DATE_DISBURSED := p_from.DATE_DISBURSED;
    p_to.PAY_STATUS_CODE := p_from.PAY_STATUS_CODE;
    p_to.RBK_ORI_INVOICE_NUMBER := p_from.RBK_ORI_INVOICE_NUMBER;
    p_to.RBK_ORI_INVOICE_LINE_NUMBER := p_from.RBK_ORI_INVOICE_LINE_NUMBER;
    p_to.RBK_ADJUSTMENT_DATE := p_from.RBK_ADJUSTMENT_DATE;
    p_to.KHR_ID := p_from.KHR_ID;
    p_to.KLE_ID := p_from.KLE_ID;
    p_to.TAX_AMOUNT := p_from.TAX_AMOUNT;
--end: 30-Jan-07 cklee  Billing R12 project                             |

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
    p_from	IN tld_rec_type,
    p_to	IN OUT NOCOPY tldv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bch_id := p_from.bch_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bgh_id := p_from.bgh_id;
    p_to.idx_id := p_from.idx_id;
    p_to.sel_id := p_from.sel_id;
    p_to.sty_id := p_from.sty_id;
    p_to.til_id_details := p_from.til_id_details;
    p_to.tld_id_reverses := p_from.tld_id_reverses;
    p_to.line_detail_number := p_from.line_detail_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_charge_yn := p_from.late_charge_yn;
    p_to.date_calculation := p_from.date_calculation;
    p_to.fixed_rate_yn := p_from.fixed_rate_yn;
    p_to.amount := p_from.amount;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.amount_applied := p_from.amount_applied;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
    p_to.TXL_AR_LINE_NUMBER := p_from.TXL_AR_LINE_NUMBER;
    p_to.INVOICE_FORMAT_TYPE := p_from.INVOICE_FORMAT_TYPE;
    p_to.INVOICE_FORMAT_LINE_TYPE := p_from.INVOICE_FORMAT_LINE_TYPE;
    p_to.LATE_CHARGE_ASSESS_DATE := p_from.LATE_CHARGE_ASSESS_DATE;
    p_to.LATE_INT_ASSESS_DATE := p_from.LATE_INT_ASSESS_DATE;
    p_to.LATE_CHARGE_ASS_YN := p_from.LATE_CHARGE_ASS_YN;
    p_to.LATE_INT_ASS_YN := p_from.LATE_INT_ASS_YN;
    p_to.INVESTOR_DISB_STATUS := p_from.INVESTOR_DISB_STATUS;
    p_to.INVESTOR_DISB_ERR_MG := p_from.INVESTOR_DISB_ERR_MG;
    p_to.DATE_DISBURSED := p_from.DATE_DISBURSED;
    p_to.PAY_STATUS_CODE := p_from.PAY_STATUS_CODE;
    p_to.RBK_ORI_INVOICE_NUMBER := p_from.RBK_ORI_INVOICE_NUMBER;
    p_to.RBK_ORI_INVOICE_LINE_NUMBER := p_from.RBK_ORI_INVOICE_LINE_NUMBER;
    p_to.RBK_ADJUSTMENT_DATE := p_from.RBK_ADJUSTMENT_DATE;
    p_to.KHR_ID := p_from.KHR_ID;
    p_to.KLE_ID := p_from.KLE_ID;
    p_to.TAX_AMOUNT := p_from.TAX_AMOUNT;
--end: 30-Jan-07 cklee  Billing R12 project                             |

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
    p_from	IN tldv_rec_type,
    p_to	IN OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.error_message := p_from.error_message;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_txd_ar_ln_dtls_tl_rec_type,
    p_to	IN OUT NOCOPY tldv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.error_message := p_from.error_message;
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
  -------------------------------------------
  -- validate_row for:OKL_TXD_AR_LN_DTLS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tldv_rec                     tldv_rec_type := p_tldv_rec;
    l_tld_rec                      tld_rec_type;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_tldv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tldv_rec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:TLDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tldv_tbl.COUNT > 0) THEN
      i := p_tldv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tldv_rec                     => p_tldv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tldv_tbl.LAST);
        i := p_tldv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- insert_row for:OKL_TXD_AR_LN_DTLS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tld_rec                      IN tld_rec_type,
    x_tld_rec                      OUT NOCOPY tld_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tld_rec                      tld_rec_type := p_tld_rec;
    l_def_tld_rec                  tld_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tld_rec IN  tld_rec_type,
      x_tld_rec OUT NOCOPY tld_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tld_rec := p_tld_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tld_rec,                         -- IN
      l_tld_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXD_AR_LN_DTLS_B(
        id,
        bch_id,
        bcl_id,
        bsl_id,
        bgh_id,
        idx_id,
        sel_id,
        sty_id,
        til_id_details,
        tld_id_reverses,
        line_detail_number,
        object_version_number,
        late_charge_yn,
        date_calculation,
        fixed_rate_yn,
        amount,
        receivables_invoice_id,
        amount_applied,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        inventory_org_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
    TXL_AR_LINE_NUMBER,
    INVOICE_FORMAT_TYPE,
    INVOICE_FORMAT_LINE_TYPE,
    LATE_CHARGE_ASSESS_DATE,
    LATE_INT_ASSESS_DATE,
    LATE_CHARGE_ASS_YN,
    LATE_INT_ASS_YN,
    INVESTOR_DISB_STATUS,
    INVESTOR_DISB_ERR_MG,
    DATE_DISBURSED,
    PAY_STATUS_CODE,
    RBK_ORI_INVOICE_NUMBER,
    RBK_ORI_INVOICE_LINE_NUMBER,
    RBK_ADJUSTMENT_DATE,
    KHR_ID,
    KLE_ID,
    TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

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
        l_tld_rec.id,
        l_tld_rec.bch_id,
        l_tld_rec.bcl_id,
        l_tld_rec.bsl_id,
        l_tld_rec.bgh_id,
        l_tld_rec.idx_id,
        l_tld_rec.sel_id,
        l_tld_rec.sty_id,
        l_tld_rec.til_id_details,
        l_tld_rec.tld_id_reverses,
        l_tld_rec.line_detail_number,
        l_tld_rec.object_version_number,
        l_tld_rec.late_charge_yn,
        l_tld_rec.date_calculation,
        l_tld_rec.fixed_rate_yn,
        l_tld_rec.amount,
        l_tld_rec.receivables_invoice_id,
        l_tld_rec.amount_applied,
        l_tld_rec.request_id,
        l_tld_rec.program_application_id,
        l_tld_rec.program_id,
        l_tld_rec.program_update_date,
        l_tld_rec.org_id,
        l_tld_rec.inventory_org_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		l_tld_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --

--start: 30-Jan-07 cklee  Billing R12 project                             |
        l_tld_rec.TXL_AR_LINE_NUMBER,
        l_tld_rec.INVOICE_FORMAT_TYPE,
        l_tld_rec.INVOICE_FORMAT_LINE_TYPE,
        l_tld_rec.LATE_CHARGE_ASSESS_DATE,
        l_tld_rec.LATE_INT_ASSESS_DATE,
        l_tld_rec.LATE_CHARGE_ASS_YN,
        l_tld_rec.LATE_INT_ASS_YN,
        l_tld_rec.INVESTOR_DISB_STATUS,
        l_tld_rec.INVESTOR_DISB_ERR_MG,
        l_tld_rec.DATE_DISBURSED,
        l_tld_rec.PAY_STATUS_CODE,
        l_tld_rec.RBK_ORI_INVOICE_NUMBER,
        l_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER,
        l_tld_rec.RBK_ADJUSTMENT_DATE,
        l_tld_rec.KHR_ID,
        l_tld_rec.KLE_ID,
        l_tld_rec.TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

        l_tld_rec.attribute_category,
        l_tld_rec.attribute1,
        l_tld_rec.attribute2,
        l_tld_rec.attribute3,
        l_tld_rec.attribute4,
        l_tld_rec.attribute5,
        l_tld_rec.attribute6,
        l_tld_rec.attribute7,
        l_tld_rec.attribute8,
        l_tld_rec.attribute9,
        l_tld_rec.attribute10,
        l_tld_rec.attribute11,
        l_tld_rec.attribute12,
        l_tld_rec.attribute13,
        l_tld_rec.attribute14,
        l_tld_rec.attribute15,
        l_tld_rec.created_by,
        l_tld_rec.creation_date,
        l_tld_rec.last_updated_by,
        l_tld_rec.last_update_date,
        l_tld_rec.last_update_login);
    -- Set OUT values
    x_tld_rec := l_tld_rec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TXD_AR_LN_DTLS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type,
    x_okl_txd_ar_ln_dtls_tl_rec    OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type := p_okl_txd_ar_ln_dtls_tl_rec;
    ldefokltxdarlndtlstlrec        okl_txd_ar_ln_dtls_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_ar_ln_dtls_tl_rec IN  okl_txd_ar_ln_dtls_tl_rec_type,
      x_okl_txd_ar_ln_dtls_tl_rec OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_ar_ln_dtls_tl_rec := p_okl_txd_ar_ln_dtls_tl_rec;
      x_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txd_ar_ln_dtls_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txd_ar_ln_dtls_tl_rec,       -- IN
      l_okl_txd_ar_ln_dtls_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TXD_AR_LN_DTLS_TL(
          id,
          LANGUAGE,
          source_lang,
          error_message,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_txd_ar_ln_dtls_tl_rec.id,
          l_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE,
          l_okl_txd_ar_ln_dtls_tl_rec.source_lang,
          l_okl_txd_ar_ln_dtls_tl_rec.error_message,
          l_okl_txd_ar_ln_dtls_tl_rec.sfwt_flag,
          l_okl_txd_ar_ln_dtls_tl_rec.description,
          l_okl_txd_ar_ln_dtls_tl_rec.created_by,
          l_okl_txd_ar_ln_dtls_tl_rec.creation_date,
          l_okl_txd_ar_ln_dtls_tl_rec.last_updated_by,
          l_okl_txd_ar_ln_dtls_tl_rec.last_update_date,
          l_okl_txd_ar_ln_dtls_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txd_ar_ln_dtls_tl_rec := l_okl_txd_ar_ln_dtls_tl_rec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TXD_AR_LN_DTLS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type,
    x_tldv_rec                     OUT NOCOPY tldv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tldv_rec                     tldv_rec_type;
    l_def_tldv_rec                 tldv_rec_type;
    l_tld_rec                      tld_rec_type;
    lx_tld_rec                     tld_rec_type;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
    lx_okl_txd_ar_ln_dtls_tl_rec   okl_txd_ar_ln_dtls_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tldv_rec	IN tldv_rec_type
    ) RETURN tldv_rec_type IS
      l_tldv_rec	tldv_rec_type := p_tldv_rec;
    BEGIN
      l_tldv_rec.CREATION_DATE := SYSDATE;
      l_tldv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_tldv_rec.LAST_UPDATE_DATE := l_tldv_rec.CREATION_DATE;
      l_tldv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tldv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_tldv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tldv_rec IN  tldv_rec_type,
      x_tldv_rec OUT NOCOPY tldv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tldv_rec := p_tldv_rec;
      x_tldv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tldv_rec.SFWT_FLAG := 'N';

	IF (x_tldv_rec.request_id IS NULL OR x_tldv_rec.request_id = Okl_api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_tldv_rec.request_id,
	  	   x_tldv_rec.program_application_id,
	  	   x_tldv_rec.program_id,
	  	   x_tldv_rec.program_update_date
	  FROM dual;
	END IF;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_tldv_rec := null_out_defaults(p_tldv_rec);
    -- Set primary key value
    l_tldv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tldv_rec,                        -- IN
      l_def_tldv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tldv_rec := fill_who_columns(l_def_tldv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tldv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tldv_rec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tldv_rec, l_tld_rec);
    migrate(l_def_tldv_rec, l_okl_txd_ar_ln_dtls_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tld_rec,
      lx_tld_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tld_rec, l_def_tldv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_ar_ln_dtls_tl_rec,
      lx_okl_txd_ar_ln_dtls_tl_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txd_ar_ln_dtls_tl_rec, l_def_tldv_rec);
    -- Set OUT values
    x_tldv_rec := l_def_tldv_rec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TLDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type,
    x_tldv_tbl                     OUT NOCOPY tldv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

    i                              NUMBER := 0;
  BEGIN
    Okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tldv_tbl.COUNT > 0) THEN
      i := p_tldv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tldv_rec                     => p_tldv_tbl(i),
          x_tldv_rec                     => x_tldv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tldv_tbl.LAST);
        i := p_tldv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- lock_row for:OKL_TXD_AR_LN_DTLS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tld_rec                      IN tld_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tld_rec IN tld_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_AR_LN_DTLS_B
     WHERE ID = p_tld_rec.id
       AND OBJECT_VERSION_NUMBER = p_tld_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tld_rec IN tld_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_AR_LN_DTLS_B
    WHERE ID = p_tld_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXD_AR_LN_DTLS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXD_AR_LN_DTLS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tld_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_tld_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tld_rec.object_version_number THEN
      Okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tld_rec.object_version_number THEN
      Okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TXD_AR_LN_DTLS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txd_ar_ln_dtls_tl_rec IN okl_txd_ar_ln_dtls_tl_rec_type) IS
    SELECT *
      FROM OKL_TXD_AR_LN_DTLS_TL
     WHERE ID = p_okl_txd_ar_ln_dtls_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_txd_ar_ln_dtls_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TXD_AR_LN_DTLS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tld_rec                      tld_rec_type;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tldv_rec, l_tld_rec);
    migrate(p_tldv_rec, l_okl_txd_ar_ln_dtls_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tld_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_ar_ln_dtls_tl_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:TLDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tldv_tbl.COUNT > 0) THEN
      i := p_tldv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tldv_rec                     => p_tldv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tldv_tbl.LAST);
        i := p_tldv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- update_row for:OKL_TXD_AR_LN_DTLS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tld_rec                      IN tld_rec_type,
    x_tld_rec                      OUT NOCOPY tld_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tld_rec                      tld_rec_type := p_tld_rec;
    l_def_tld_rec                  tld_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tld_rec	IN tld_rec_type,
      x_tld_rec	OUT NOCOPY tld_rec_type
    ) RETURN VARCHAR2 IS
      l_tld_rec                      tld_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tld_rec := p_tld_rec;
      -- Get current database values
      l_tld_rec := get_rec(p_tld_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tld_rec.id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.id := l_tld_rec.id;
      END IF;
      IF (x_tld_rec.bch_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.bch_id := l_tld_rec.bch_id;
      END IF;
      IF (x_tld_rec.bcl_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.bcl_id := l_tld_rec.bcl_id;
      END IF;
      IF (x_tld_rec.bsl_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.bsl_id := l_tld_rec.bsl_id;
      END IF;
      IF (x_tld_rec.bgh_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.bgh_id := l_tld_rec.bgh_id;
      END IF;
      IF (x_tld_rec.idx_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.idx_id := l_tld_rec.idx_id;
      END IF;
      IF (x_tld_rec.sel_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.sel_id := l_tld_rec.sel_id;
      END IF;
      IF (x_tld_rec.sty_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.sty_id := l_tld_rec.sty_id;
      END IF;
      IF (x_tld_rec.til_id_details = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.til_id_details := l_tld_rec.til_id_details;
      END IF;
      IF (x_tld_rec.tld_id_reverses = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.tld_id_reverses := l_tld_rec.tld_id_reverses;
      END IF;
      IF (x_tld_rec.line_detail_number = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.line_detail_number := l_tld_rec.line_detail_number;
      END IF;
      IF (x_tld_rec.object_version_number = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.object_version_number := l_tld_rec.object_version_number;
      END IF;
      IF (x_tld_rec.late_charge_yn = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.late_charge_yn := l_tld_rec.late_charge_yn;
      END IF;
      IF (x_tld_rec.date_calculation = Okl_api.G_MISS_DATE)
      THEN
        x_tld_rec.date_calculation := l_tld_rec.date_calculation;
      END IF;
      IF (x_tld_rec.fixed_rate_yn = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.fixed_rate_yn := l_tld_rec.fixed_rate_yn;
      END IF;
      IF (x_tld_rec.amount = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.amount := l_tld_rec.amount;
      END IF;
      IF (x_tld_rec.receivables_invoice_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.receivables_invoice_id := l_tld_rec.receivables_invoice_id;
      END IF;
      IF (x_tld_rec.amount_applied = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.amount_applied := l_tld_rec.amount_applied;
      END IF;
      IF (x_tld_rec.request_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.request_id := l_tld_rec.request_id;
      END IF;
      IF (x_tld_rec.program_application_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.program_application_id := l_tld_rec.program_application_id;
      END IF;
      IF (x_tld_rec.program_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.program_id := l_tld_rec.program_id;
      END IF;
      IF (x_tld_rec.program_update_date = Okl_api.G_MISS_DATE)
      THEN
        x_tld_rec.program_update_date := l_tld_rec.program_update_date;
      END IF;
      IF (x_tld_rec.org_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.org_id := l_tld_rec.org_id;
      END IF;

      IF (x_tld_rec.inventory_org_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.inventory_org_id := l_tld_rec.inventory_org_id;
      END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_tld_rec.inventory_item_id = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.inventory_item_id := l_tld_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --
--cklee
--start: 30-Jan-07 cklee  Billing R12 project                             |
  --gkhuntet 10-JUL_2007 Start
    IF (x_tld_rec.TXL_AR_LINE_NUMBER = Okl_api.G_MISS_NUM) THEN
      x_tld_rec.TXL_AR_LINE_NUMBER := l_tld_rec.TXL_AR_LINE_NUMBER;
    END IF;

    IF (x_tld_rec.INVOICE_FORMAT_TYPE = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.INVOICE_FORMAT_TYPE := l_tld_rec.INVOICE_FORMAT_TYPE;
    END IF;

    IF (x_tld_rec.INVOICE_FORMAT_LINE_TYPE = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.INVOICE_FORMAT_LINE_TYPE := l_tld_rec.INVOICE_FORMAT_LINE_TYPE;
    END IF;

    IF (x_tld_rec.LATE_CHARGE_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      x_tld_rec.LATE_CHARGE_ASSESS_DATE := l_tld_rec.LATE_CHARGE_ASSESS_DATE;
    END IF;

    IF (x_tld_rec.LATE_INT_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      x_tld_rec.LATE_INT_ASSESS_DATE := l_tld_rec.LATE_INT_ASSESS_DATE;
    END IF;

    IF (x_tld_rec.LATE_CHARGE_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.LATE_CHARGE_ASS_YN := l_tld_rec.LATE_CHARGE_ASS_YN;
    END IF;

    IF (x_tld_rec.LATE_INT_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.LATE_INT_ASS_YN := l_tld_rec.LATE_INT_ASS_YN;
    END IF;

    IF (x_tld_rec.INVESTOR_DISB_STATUS = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.INVESTOR_DISB_STATUS := l_tld_rec.INVESTOR_DISB_STATUS;
    END IF;

    IF (x_tld_rec.INVESTOR_DISB_ERR_MG = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.INVESTOR_DISB_ERR_MG := l_tld_rec.INVESTOR_DISB_ERR_MG;
    END IF;

    IF (x_tld_rec.DATE_DISBURSED = Okl_api.G_MISS_DATE) THEN
      x_tld_rec.DATE_DISBURSED := l_tld_rec.DATE_DISBURSED;
    END IF;

    IF (x_tld_rec.PAY_STATUS_CODE = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.PAY_STATUS_CODE := l_tld_rec.PAY_STATUS_CODE;
    END IF;

    IF (x_tld_rec.RBK_ORI_INVOICE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.RBK_ORI_INVOICE_NUMBER := l_tld_rec.RBK_ORI_INVOICE_NUMBER;
    END IF;

    IF (x_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      x_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER := l_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER;
    END IF;

    IF (x_tld_rec.RBK_ADJUSTMENT_DATE = Okl_api.G_MISS_DATE) THEN
      x_tld_rec.RBK_ADJUSTMENT_DATE := l_tld_rec.RBK_ADJUSTMENT_DATE;
    END IF;

    IF (x_tld_rec.KHR_ID = Okl_api.G_MISS_NUM) THEN
      x_tld_rec.KHR_ID := l_tld_rec.KHR_ID;
    END IF;

    IF (x_tld_rec.KLE_ID = Okl_api.G_MISS_NUM) THEN
      x_tld_rec.KLE_ID := l_tld_rec.KLE_ID;
    END IF;

    IF (x_tld_rec.TAX_AMOUNT = Okl_api.G_MISS_NUM) THEN
      x_tld_rec.TAX_AMOUNT := l_tld_rec.TAX_AMOUNT;
    END IF;

--gkhuntet 10-JUL_2007 End
--end: 30-Jan-07 cklee  Billing R12 project                             |




      IF (x_tld_rec.attribute_category = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute_category := l_tld_rec.attribute_category;
      END IF;
      IF (x_tld_rec.attribute1 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute1 := l_tld_rec.attribute1;
      END IF;
      IF (x_tld_rec.attribute2 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute2 := l_tld_rec.attribute2;
      END IF;
      IF (x_tld_rec.attribute3 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute3 := l_tld_rec.attribute3;
      END IF;
      IF (x_tld_rec.attribute4 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute4 := l_tld_rec.attribute4;
      END IF;
      IF (x_tld_rec.attribute5 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute5 := l_tld_rec.attribute5;
      END IF;
      IF (x_tld_rec.attribute6 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute6 := l_tld_rec.attribute6;
      END IF;
      IF (x_tld_rec.attribute7 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute7 := l_tld_rec.attribute7;
      END IF;
      IF (x_tld_rec.attribute8 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute8 := l_tld_rec.attribute8;
      END IF;
      IF (x_tld_rec.attribute9 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute9 := l_tld_rec.attribute9;
      END IF;
      IF (x_tld_rec.attribute10 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute10 := l_tld_rec.attribute10;
      END IF;
      IF (x_tld_rec.attribute11 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute11 := l_tld_rec.attribute11;
      END IF;
      IF (x_tld_rec.attribute12 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute12 := l_tld_rec.attribute12;
      END IF;
      IF (x_tld_rec.attribute13 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute13 := l_tld_rec.attribute13;
      END IF;
      IF (x_tld_rec.attribute14 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute14 := l_tld_rec.attribute14;
      END IF;
      IF (x_tld_rec.attribute15 = Okl_api.G_MISS_CHAR)
      THEN
        x_tld_rec.attribute15 := l_tld_rec.attribute15;
      END IF;
      IF (x_tld_rec.created_by = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.created_by := l_tld_rec.created_by;
      END IF;
      IF (x_tld_rec.creation_date = Okl_api.G_MISS_DATE)
      THEN
        x_tld_rec.creation_date := l_tld_rec.creation_date;
      END IF;
      IF (x_tld_rec.last_updated_by = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.last_updated_by := l_tld_rec.last_updated_by;
      END IF;
      IF (x_tld_rec.last_update_date = Okl_api.G_MISS_DATE)
      THEN
        x_tld_rec.last_update_date := l_tld_rec.last_update_date;
      END IF;
      IF (x_tld_rec.last_update_login = Okl_api.G_MISS_NUM)
      THEN
        x_tld_rec.last_update_login := l_tld_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tld_rec IN  tld_rec_type,
      x_tld_rec OUT NOCOPY tld_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tld_rec := p_tld_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tld_rec,                         -- IN
      l_tld_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tld_rec, l_def_tld_rec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXD_AR_LN_DTLS_B
    SET BCH_ID = l_def_tld_rec.bch_id,
        BCL_ID = l_def_tld_rec.bcl_id,
        BSL_ID = l_def_tld_rec.bsl_id,
        BGH_ID = l_def_tld_rec.bgh_id,
        IDX_ID = l_def_tld_rec.idx_id,
        SEL_ID = l_def_tld_rec.sel_id,
        STY_ID = l_def_tld_rec.sty_id,
        TIL_ID_DETAILS = l_def_tld_rec.til_id_details,
        TLD_ID_REVERSES = l_def_tld_rec.tld_id_reverses,
        LINE_DETAIL_NUMBER = l_def_tld_rec.line_detail_number,
        OBJECT_VERSION_NUMBER = l_def_tld_rec.object_version_number,
        LATE_CHARGE_YN = l_def_tld_rec.late_charge_yn,
        DATE_CALCULATION = l_def_tld_rec.date_calculation,
        FIXED_RATE_YN = l_def_tld_rec.fixed_rate_yn,
        AMOUNT = l_def_tld_rec.amount,
        RECEIVABLES_INVOICE_ID = l_def_tld_rec.receivables_invoice_id,
        AMOUNT_APPLIED = l_def_tld_rec.amount_applied,
        REQUEST_ID = l_def_tld_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tld_rec.program_application_id,
        PROGRAM_ID = l_def_tld_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_tld_rec.program_update_date,
        ORG_ID = l_def_tld_rec.org_id,
        INVENTORY_ORG_ID = l_def_tld_rec.inventory_org_id,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		INVENTORY_ITEM_ID = l_def_tld_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
--cklee
--start: 30-Jan-07 cklee  Billing R12 project                             |
   		TXL_AR_LINE_NUMBER = l_def_tld_rec.TXL_AR_LINE_NUMBER,
   		INVOICE_FORMAT_TYPE = l_def_tld_rec.INVOICE_FORMAT_TYPE,
   		INVOICE_FORMAT_LINE_TYPE = l_def_tld_rec.INVOICE_FORMAT_LINE_TYPE,
   		LATE_CHARGE_ASSESS_DATE = l_def_tld_rec.LATE_CHARGE_ASSESS_DATE,
   		LATE_INT_ASSESS_DATE = l_def_tld_rec.LATE_INT_ASSESS_DATE,
   		LATE_CHARGE_ASS_YN = l_def_tld_rec.LATE_CHARGE_ASS_YN,
   		LATE_INT_ASS_YN = l_def_tld_rec.LATE_INT_ASS_YN,
   		INVESTOR_DISB_STATUS = l_def_tld_rec.INVESTOR_DISB_STATUS,
   		INVESTOR_DISB_ERR_MG = l_def_tld_rec.INVESTOR_DISB_ERR_MG,
   		DATE_DISBURSED = l_def_tld_rec.DATE_DISBURSED,
   		PAY_STATUS_CODE = l_def_tld_rec.PAY_STATUS_CODE,
   		RBK_ORI_INVOICE_NUMBER = l_def_tld_rec.RBK_ORI_INVOICE_NUMBER,
   		RBK_ORI_INVOICE_LINE_NUMBER = l_def_tld_rec.RBK_ORI_INVOICE_LINE_NUMBER,
   		RBK_ADJUSTMENT_DATE = l_def_tld_rec.RBK_ADJUSTMENT_DATE,
   		KHR_ID = l_def_tld_rec.KHR_ID,
   		KLE_ID = l_def_tld_rec.KLE_ID,
   		TAX_AMOUNT = l_def_tld_rec.TAX_AMOUNT,
--end: 30-Jan-07 cklee  Billing R12 project                             |

        ATTRIBUTE_CATEGORY = l_def_tld_rec.attribute_category,
        ATTRIBUTE1 = l_def_tld_rec.attribute1,
        ATTRIBUTE2 = l_def_tld_rec.attribute2,
        ATTRIBUTE3 = l_def_tld_rec.attribute3,
        ATTRIBUTE4 = l_def_tld_rec.attribute4,
        ATTRIBUTE5 = l_def_tld_rec.attribute5,
        ATTRIBUTE6 = l_def_tld_rec.attribute6,
        ATTRIBUTE7 = l_def_tld_rec.attribute7,
        ATTRIBUTE8 = l_def_tld_rec.attribute8,
        ATTRIBUTE9 = l_def_tld_rec.attribute9,
        ATTRIBUTE10 = l_def_tld_rec.attribute10,
        ATTRIBUTE11 = l_def_tld_rec.attribute11,
        ATTRIBUTE12 = l_def_tld_rec.attribute12,
        ATTRIBUTE13 = l_def_tld_rec.attribute13,
        ATTRIBUTE14 = l_def_tld_rec.attribute14,
        ATTRIBUTE15 = l_def_tld_rec.attribute15,
        CREATED_BY = l_def_tld_rec.created_by,
        CREATION_DATE = l_def_tld_rec.creation_date,
        LAST_UPDATED_BY = l_def_tld_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tld_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tld_rec.last_update_login
    WHERE ID = l_def_tld_rec.id;

    x_tld_rec := l_def_tld_rec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TXD_AR_LN_DTLS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type,
    x_okl_txd_ar_ln_dtls_tl_rec    OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type := p_okl_txd_ar_ln_dtls_tl_rec;
    ldefokltxdarlndtlstlrec        okl_txd_ar_ln_dtls_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txd_ar_ln_dtls_tl_rec	IN okl_txd_ar_ln_dtls_tl_rec_type,
      x_okl_txd_ar_ln_dtls_tl_rec	OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_ar_ln_dtls_tl_rec := p_okl_txd_ar_ln_dtls_tl_rec;
      -- Get current database values
      l_okl_txd_ar_ln_dtls_tl_rec := get_rec(p_okl_txd_ar_ln_dtls_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.id = Okl_api.G_MISS_NUM)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.id := l_okl_txd_ar_ln_dtls_tl_rec.id;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE = Okl_api.G_MISS_CHAR)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE := l_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.source_lang = Okl_api.G_MISS_CHAR)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.source_lang := l_okl_txd_ar_ln_dtls_tl_rec.source_lang;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.error_message = Okl_api.G_MISS_CHAR)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.error_message := l_okl_txd_ar_ln_dtls_tl_rec.error_message;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.sfwt_flag = Okl_api.G_MISS_CHAR)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.sfwt_flag := l_okl_txd_ar_ln_dtls_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.description = Okl_api.G_MISS_CHAR)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.description := l_okl_txd_ar_ln_dtls_tl_rec.description;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.created_by = Okl_api.G_MISS_NUM)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.created_by := l_okl_txd_ar_ln_dtls_tl_rec.created_by;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.creation_date = Okl_api.G_MISS_DATE)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.creation_date := l_okl_txd_ar_ln_dtls_tl_rec.creation_date;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.last_updated_by = Okl_api.G_MISS_NUM)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.last_updated_by := l_okl_txd_ar_ln_dtls_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.last_update_date = Okl_api.G_MISS_DATE)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.last_update_date := l_okl_txd_ar_ln_dtls_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txd_ar_ln_dtls_tl_rec.last_update_login = Okl_api.G_MISS_NUM)
      THEN
        x_okl_txd_ar_ln_dtls_tl_rec.last_update_login := l_okl_txd_ar_ln_dtls_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_ar_ln_dtls_tl_rec IN  okl_txd_ar_ln_dtls_tl_rec_type,
      x_okl_txd_ar_ln_dtls_tl_rec OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_ar_ln_dtls_tl_rec := p_okl_txd_ar_ln_dtls_tl_rec;
      x_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txd_ar_ln_dtls_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txd_ar_ln_dtls_tl_rec,       -- IN
      l_okl_txd_ar_ln_dtls_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txd_ar_ln_dtls_tl_rec, ldefokltxdarlndtlstlrec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXD_AR_LN_DTLS_TL
    SET DESCRIPTION = ldefokltxdarlndtlstlrec.description,
        ERROR_MESSAGE = ldefokltxdarlndtlstlrec.error_message,
        SOURCE_LANG = ldefokltxdarlndtlstlrec.source_lang,
        CREATED_BY = ldefokltxdarlndtlstlrec.created_by,
        CREATION_DATE = ldefokltxdarlndtlstlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxdarlndtlstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxdarlndtlstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxdarlndtlstlrec.last_update_login
    WHERE ID = ldefokltxdarlndtlstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TXD_AR_LN_DTLS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxdarlndtlstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txd_ar_ln_dtls_tl_rec := ldefokltxdarlndtlstlrec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TXD_AR_LN_DTLS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type,
    x_tldv_rec                     OUT NOCOPY tldv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tldv_rec                     tldv_rec_type := p_tldv_rec;
    l_def_tldv_rec                 tldv_rec_type;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
    lx_okl_txd_ar_ln_dtls_tl_rec   okl_txd_ar_ln_dtls_tl_rec_type;
    l_tld_rec                      tld_rec_type;
    lx_tld_rec                     tld_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tldv_rec	IN tldv_rec_type
    ) RETURN tldv_rec_type IS
      l_tldv_rec	tldv_rec_type := p_tldv_rec;
    BEGIN
      l_tldv_rec.LAST_UPDATE_DATE := l_tldv_rec.CREATION_DATE;
      l_tldv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tldv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_tldv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tldv_rec	IN tldv_rec_type,
      x_tldv_rec	OUT NOCOPY tldv_rec_type
    ) RETURN VARCHAR2 IS
      l_tldv_rec                     tldv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tldv_rec := p_tldv_rec;
      -- Get current database values
      l_tldv_rec := get_rec(p_tldv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tldv_rec.id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.id := l_tldv_rec.id;
      END IF;
      IF (x_tldv_rec.object_version_number = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.object_version_number := l_tldv_rec.object_version_number;
      END IF;
      IF (x_tldv_rec.error_message = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.error_message := l_tldv_rec.error_message;
      END IF;
      IF (x_tldv_rec.sfwt_flag = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.sfwt_flag := l_tldv_rec.sfwt_flag;
      END IF;
      IF (x_tldv_rec.bch_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.bch_id := l_tldv_rec.bch_id;
      END IF;
      IF (x_tldv_rec.bgh_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.bgh_id := l_tldv_rec.bgh_id;
      END IF;
      IF (x_tldv_rec.idx_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.idx_id := l_tldv_rec.idx_id;
      END IF;
      IF (x_tldv_rec.tld_id_reverses = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.tld_id_reverses := l_tldv_rec.tld_id_reverses;
      END IF;
      IF (x_tldv_rec.sty_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.sty_id := l_tldv_rec.sty_id;
      END IF;
      IF (x_tldv_rec.sel_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.sel_id := l_tldv_rec.sel_id;
      END IF;
      IF (x_tldv_rec.til_id_details = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.til_id_details := l_tldv_rec.til_id_details;
      END IF;
      IF (x_tldv_rec.bcl_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.bcl_id := l_tldv_rec.bcl_id;
      END IF;
      IF (x_tldv_rec.bsl_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.bsl_id := l_tldv_rec.bsl_id;
      END IF;
      IF (x_tldv_rec.amount = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.amount := l_tldv_rec.amount;
      END IF;
      IF (x_tldv_rec.line_detail_number = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.line_detail_number := l_tldv_rec.line_detail_number;
      END IF;
      IF (x_tldv_rec.receivables_invoice_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.receivables_invoice_id := l_tldv_rec.receivables_invoice_id;
      END IF;
      IF (x_tldv_rec.late_charge_yn = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.late_charge_yn := l_tldv_rec.late_charge_yn;
      END IF;
      IF (x_tldv_rec.description = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.description := l_tldv_rec.description;
      END IF;
      IF (x_tldv_rec.amount_applied = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.amount_applied := l_tldv_rec.amount_applied;
      END IF;
      IF (x_tldv_rec.date_calculation = Okl_api.G_MISS_DATE)
      THEN
        x_tldv_rec.date_calculation := l_tldv_rec.date_calculation;
      END IF;
      IF (x_tldv_rec.fixed_rate_yn = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.fixed_rate_yn := l_tldv_rec.fixed_rate_yn;
      END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_tldv_rec.inventory_item_id = Okl_api.G_MISS_num)
      THEN
        x_tldv_rec.inventory_item_id := l_tldv_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --
--cklee
--start: 30-Jan-07 cklee  Billing R12 project                             |
  --gkhuntet 10-Jul-07 started .                           |
    IF (x_tldv_rec.TXL_AR_LINE_NUMBER = Okl_api.G_MISS_NUM) THEN
      x_tldv_rec.TXL_AR_LINE_NUMBER := l_tldv_rec.TXL_AR_LINE_NUMBER;
    END IF;

    IF (x_tldv_rec.INVOICE_FORMAT_TYPE = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.INVOICE_FORMAT_TYPE := l_tldv_rec.INVOICE_FORMAT_TYPE;
    END IF;

    IF (x_tldv_rec.INVOICE_FORMAT_LINE_TYPE = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.INVOICE_FORMAT_LINE_TYPE := l_tldv_rec.INVOICE_FORMAT_LINE_TYPE;
    END IF;

    IF (x_tldv_rec.LATE_CHARGE_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      x_tldv_rec.LATE_CHARGE_ASSESS_DATE := l_tldv_rec.LATE_CHARGE_ASSESS_DATE;
    END IF;

    IF (x_tldv_rec.LATE_INT_ASSESS_DATE = Okl_api.G_MISS_DATE) THEN
      x_tldv_rec.LATE_INT_ASSESS_DATE := l_tldv_rec.LATE_INT_ASSESS_DATE;
    END IF;

    IF (x_tldv_rec.LATE_CHARGE_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.LATE_CHARGE_ASS_YN := l_tldv_rec.LATE_CHARGE_ASS_YN;
    END IF;

    IF (x_tldv_rec.LATE_INT_ASS_YN = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.LATE_INT_ASS_YN := l_tldv_rec.LATE_INT_ASS_YN;
    END IF;

    IF (x_tldv_rec.INVESTOR_DISB_STATUS = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.INVESTOR_DISB_STATUS := l_tldv_rec.INVESTOR_DISB_STATUS;
    END IF;

    IF (x_tldv_rec.INVESTOR_DISB_ERR_MG = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.INVESTOR_DISB_ERR_MG := l_tldv_rec.INVESTOR_DISB_ERR_MG;
    END IF;

    IF (x_tldv_rec.DATE_DISBURSED = Okl_api.G_MISS_DATE) THEN
      x_tldv_rec.DATE_DISBURSED := l_tldv_rec.DATE_DISBURSED;
    END IF;

    IF (x_tldv_rec.PAY_STATUS_CODE = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.PAY_STATUS_CODE := l_tldv_rec.PAY_STATUS_CODE;
    END IF;

    IF (x_tldv_rec.RBK_ORI_INVOICE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.RBK_ORI_INVOICE_NUMBER := l_tldv_rec.RBK_ORI_INVOICE_NUMBER;
    END IF;

    IF (x_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER = Okl_api.G_MISS_CHAR) THEN
      x_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER := l_tldv_rec.RBK_ORI_INVOICE_LINE_NUMBER;
    END IF;

    IF (x_tldv_rec.RBK_ADJUSTMENT_DATE = Okl_api.G_MISS_DATE) THEN
      x_tldv_rec.RBK_ADJUSTMENT_DATE := l_tldv_rec.RBK_ADJUSTMENT_DATE;
    END IF;

    IF (x_tldv_rec.KHR_ID = Okl_api.G_MISS_NUM) THEN
      x_tldv_rec.KHR_ID := l_tldv_rec.KHR_ID;
    END IF;

    IF (x_tldv_rec.KLE_ID = Okl_api.G_MISS_NUM) THEN
      x_tldv_rec.KLE_ID := l_tldv_rec.KLE_ID;
    END IF;

    IF (x_tldv_rec.TAX_AMOUNT = Okl_api.G_MISS_NUM) THEN
      x_tldv_rec.TAX_AMOUNT := l_tldv_rec.TAX_AMOUNT;
    END IF;
 --gkhuntet 10-Jul-07  Ended .

--end: 30-Jan-07 cklee  Billing R12 project                             |


      IF (x_tldv_rec.attribute_category = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute_category := l_tldv_rec.attribute_category;
      END IF;
      IF (x_tldv_rec.attribute1 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute1 := l_tldv_rec.attribute1;
      END IF;
      IF (x_tldv_rec.attribute2 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute2 := l_tldv_rec.attribute2;
      END IF;
      IF (x_tldv_rec.attribute3 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute3 := l_tldv_rec.attribute3;
      END IF;
      IF (x_tldv_rec.attribute4 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute4 := l_tldv_rec.attribute4;
      END IF;
      IF (x_tldv_rec.attribute5 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute5 := l_tldv_rec.attribute5;
      END IF;
      IF (x_tldv_rec.attribute6 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute6 := l_tldv_rec.attribute6;
      END IF;
      IF (x_tldv_rec.attribute7 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute7 := l_tldv_rec.attribute7;
      END IF;
      IF (x_tldv_rec.attribute8 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute8 := l_tldv_rec.attribute8;
      END IF;
      IF (x_tldv_rec.attribute9 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute9 := l_tldv_rec.attribute9;
      END IF;
      IF (x_tldv_rec.attribute10 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute10 := l_tldv_rec.attribute10;
      END IF;
      IF (x_tldv_rec.attribute11 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute11 := l_tldv_rec.attribute11;
      END IF;
      IF (x_tldv_rec.attribute12 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute12 := l_tldv_rec.attribute12;
      END IF;
      IF (x_tldv_rec.attribute13 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute13 := l_tldv_rec.attribute13;
      END IF;
      IF (x_tldv_rec.attribute14 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute14 := l_tldv_rec.attribute14;
      END IF;
      IF (x_tldv_rec.attribute15 = Okl_api.G_MISS_CHAR)
      THEN
        x_tldv_rec.attribute15 := l_tldv_rec.attribute15;
      END IF;
      IF (x_tldv_rec.request_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.request_id := l_tldv_rec.request_id;
      END IF;
      IF (x_tldv_rec.program_application_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.program_application_id := l_tldv_rec.program_application_id;
      END IF;
      IF (x_tldv_rec.program_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.program_id := l_tldv_rec.program_id;
      END IF;
      IF (x_tldv_rec.program_update_date = Okl_api.G_MISS_DATE)
      THEN
        x_tldv_rec.program_update_date := l_tldv_rec.program_update_date;
      END IF;
      IF (x_tldv_rec.org_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.org_id := l_tldv_rec.org_id;
      END IF;

      IF (x_tldv_rec.inventory_org_id = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.inventory_org_id := l_tldv_rec.inventory_org_id;
      END IF;

      IF (x_tldv_rec.created_by = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.created_by := l_tldv_rec.created_by;
      END IF;
      IF (x_tldv_rec.creation_date = Okl_api.G_MISS_DATE)
      THEN
        x_tldv_rec.creation_date := l_tldv_rec.creation_date;
      END IF;
      IF (x_tldv_rec.last_updated_by = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.last_updated_by := l_tldv_rec.last_updated_by;
      END IF;
      IF (x_tldv_rec.last_update_date = Okl_api.G_MISS_DATE)
      THEN
        x_tldv_rec.last_update_date := l_tldv_rec.last_update_date;
      END IF;
      IF (x_tldv_rec.last_update_login = Okl_api.G_MISS_NUM)
      THEN
        x_tldv_rec.last_update_login := l_tldv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tldv_rec IN  tldv_rec_type,
      x_tldv_rec OUT NOCOPY tldv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_tldv_rec := p_tldv_rec;
      x_tldv_rec.OBJECT_VERSION_NUMBER := NVL(x_tldv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_tldv_rec.request_id IS NULL OR x_tldv_rec.request_id = Okl_api.G_MISS_NUM) THEN

	     -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_tldv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_tldv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_tldv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_tldv_rec.program_update_date,SYSDATE)
      INTO
        x_tldv_rec.request_id,
        x_tldv_rec.program_application_id,
        x_tldv_rec.program_id,
        x_tldv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change

	END IF;


      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tldv_rec,                        -- IN
      l_tldv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tldv_rec, l_def_tldv_rec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tldv_rec := fill_who_columns(l_def_tldv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tldv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tldv_rec);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tldv_rec, l_okl_txd_ar_ln_dtls_tl_rec);
    migrate(l_def_tldv_rec, l_tld_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_ar_ln_dtls_tl_rec,
      lx_okl_txd_ar_ln_dtls_tl_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txd_ar_ln_dtls_tl_rec, l_def_tldv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tld_rec,
      lx_tld_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tld_rec, l_def_tldv_rec);
    x_tldv_rec := l_def_tldv_rec;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:TLDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type,
    x_tldv_tbl                     OUT NOCOPY tldv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tldv_tbl.COUNT > 0) THEN
      i := p_tldv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tldv_rec                     => p_tldv_tbl(i),
          x_tldv_rec                     => x_tldv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tldv_tbl.LAST);
        i := p_tldv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- delete_row for:OKL_TXD_AR_LN_DTLS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tld_rec                      IN tld_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tld_rec                      tld_rec_type:= p_tld_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXD_AR_LN_DTLS_B
     WHERE ID = l_tld_rec.id;

    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TXD_AR_LN_DTLS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_ar_ln_dtls_tl_rec    IN okl_txd_ar_ln_dtls_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type:= p_okl_txd_ar_ln_dtls_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXD_AR_LN_DTLS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_ar_ln_dtls_tl_rec IN  okl_txd_ar_ln_dtls_tl_rec_type,
      x_okl_txd_ar_ln_dtls_tl_rec OUT NOCOPY okl_txd_ar_ln_dtls_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_ar_ln_dtls_tl_rec := p_okl_txd_ar_ln_dtls_tl_rec;
      x_okl_txd_ar_ln_dtls_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txd_ar_ln_dtls_tl_rec,       -- IN
      l_okl_txd_ar_ln_dtls_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXD_AR_LN_DTLS_TL
     WHERE ID = l_okl_txd_ar_ln_dtls_tl_rec.id;

    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TXD_AR_LN_DTLS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    l_tldv_rec                     tldv_rec_type := p_tldv_rec;
    l_okl_txd_ar_ln_dtls_tl_rec    okl_txd_ar_ln_dtls_tl_rec_type;
    l_tld_rec                      tld_rec_type;
  BEGIN
    l_return_status := Okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tldv_rec, l_okl_txd_ar_ln_dtls_tl_rec);
    migrate(l_tldv_rec, l_tld_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_ar_ln_dtls_tl_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tld_rec
    );
    IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_api.G_RET_STS_ERROR) THEN
      RAISE Okl_api.G_EXCEPTION_ERROR;
    END IF;
    Okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:TLDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tldv_tbl.COUNT > 0) THEN
      i := p_tldv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tldv_rec                     => p_tldv_tbl(i));
	    -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tldv_tbl.LAST);
        i := p_tldv_tbl.NEXT(i);
      END LOOP;
	   -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Tld_Pvt;

/
