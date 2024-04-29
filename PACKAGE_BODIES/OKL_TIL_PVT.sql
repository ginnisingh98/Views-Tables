--------------------------------------------------------
--  DDL for Package Body OKL_TIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TIL_PVT" AS
/* $Header: OKLSTILB.pls 120.12 2008/05/15 18:20:01 sechawla ship $ */


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_line_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_line_number (p_tilv_rec IN tilv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_tilv_rec.line_number = Okl_Api.G_MISS_NUM OR
       p_tilv_rec.line_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'line_number');
      --RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_line_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_org_id (p_tilv_rec IN tilv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_tilv_rec.org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_tilv_rec.org_id);
	END IF;
  END validate_org_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_inventory_org_id
  ---------------------------------------------------------------------------

  PROCEDURE validate_inventory_org_id (p_tilv_rec IN tilv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_tilv_rec.inventory_org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_tilv_rec.inventory_org_id);
	END IF;

  IF x_return_status <>  Okl_Api.G_RET_STS_SUCCESS THEN
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'INVENTORY_ORG_ID');
  END IF;

  END validate_inventory_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_tilv_rec IN tilv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_tilv_rec.id = Okl_Api.G_MISS_NUM OR
       p_tilv_rec.id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'id');
      --RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_tilv_rec IN tilv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_tilv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_tilv_rec.object_version_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;

  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'object_version_number');
      --RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

  END validate_object_version_number;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_inv_receiv_line_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_inv_receiv_line_code (p_tilv_rec IN tilv_rec_type,
  								   			x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF p_tilv_rec.inv_receiv_line_code = Okl_Api.G_MISS_CHAR OR
          p_tilv_rec.inv_receiv_line_code IS NULL
       THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;

  	     --set error message in message stack
	     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	                 p_msg_name     =>  G_REQUIRED_VALUE,
          				     p_token1       => G_COL_NAME_TOKEN,
						     p_token1_value => 'inv_receiv_line_code');
	      --RAISE G_EXCEPTION_HALT_VALIDATION;

	   END IF;


       --Check FK
--	   x_return_status := Okl_Util.check_fnd_lookup_code('INV_RECEIV_LINE_CODE', p_tilv_rec.inv_receiv_line_code);
--start: 26-02-07 gkhuntet  x_return_status is always set to 'S' so commented.
--	   x_return_status := 'S';
--end: 26-02-07 gkhuntet
  END validate_inv_receiv_line_code;
----------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tai_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_tai_id (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tai_id_csr IS
    SELECT '1'
	FROM OKL_TRX_AR_INVOICES_B
	WHERE id = p_tilv_rec.tai_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF p_tilv_rec.tai_id = Okl_Api.G_MISS_NUM OR
          p_tilv_rec.tai_id IS NULL
       THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;

  	     --set error message in message stack
	     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	                 p_msg_name     =>  G_REQUIRED_VALUE,
          				     p_token1       => G_COL_NAME_TOKEN,
						     p_token1_value => 'tai_id');
	      --RAISE G_EXCEPTION_HALT_VALIDATION;

	   END IF;



	   	  OPEN l_tai_id_csr;
		  FETCH l_tai_id_csr INTO l_dummy_var;
		  CLOSE l_tai_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TAI_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXL_AR_INV_LNS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;


  END validate_tai_id;

----------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_kle_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_kle_id (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   -- sjalasut commented the cursor. see new cursor below
   /*
    CURSOR l_kle_id_csr IS
    SELECT '1'
   	FROM OKC_K_LINES_B
	   WHERE id = p_tilv_rec.kle_id;
   */
   -- sjalasut: new cursor to validate that the asset and the contract are related
   -- fix for bug 2783255
   -- since the contract and the asset lov are org stripped, no need of org_id here
   -- in the where clause
   -- sjalasut: start of code changes
   CURSOR l_kle_id_csr IS
      SELECT '1'
        FROM OKC_K_LINES_B line,
             OKL_TRX_AR_INVOICES_B invoice
       WHERE
             line.id = p_tilv_rec.kle_id
         AND invoice.id = p_tilv_rec.tai_id
         AND line.dnz_chr_id = invoice.khr_id(+);

   CURSOR l_asset_number_csr IS
     SELECT name
       FROM OKC_K_LINES_V
      WHERE id = p_tilv_rec.kle_id;

      lv_asset_number okc_k_lines_v.name%TYPE;
      -- sjalasut: end of code changes
  BEGIN
	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	   -- sjalasut changed the cursor and added a user-friendly message as per bug 2783255
	   IF(p_tilv_rec.kle_id IS NOT NULL) THEN
	   	 OPEN l_kle_id_csr;
		    FETCH l_kle_id_csr INTO l_dummy_var;
		    CLOSE l_kle_id_csr;
		    IF(l_dummy_var <> '1') THEN
		  	   x_return_status := Okl_Api.G_RET_STS_ERROR;
        OPEN l_asset_number_csr;
        FETCH l_asset_number_csr INTO lv_asset_number;
        CLOSE l_asset_number_csr;
			     Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
			 					                   p_msg_name => 'OKL_OP_ASSET_NOT_FOR_CONTRACT',
                            p_token1   => 'ASSET_NUM',
                            p_token1_value => lv_asset_number
                            );
			     --RAISE G_EXCEPTION_HALT_VALIDATION;
		    END IF;
	   END IF;
  END validate_kle_id;

----------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tpl_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_tpl_id (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tpl_id_csr IS
    SELECT '1'
	FROM OKL_TXL_AP_INV_LNS_B
	WHERE id = p_tilv_rec.tpl_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_tilv_rec.tpl_id IS NOT NULL) THEN
	   	  OPEN l_tpl_id_csr;
		  FETCH l_tpl_id_csr INTO l_dummy_var;
		  CLOSE l_tpl_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TPL_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXL_AR_INV_LNS_V'	);

			 --RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tpl_id;

----------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sty_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_sty_id (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';
   -- sjalasut modified cursor for bug 2783255
   -- sjalasut start of code changes
   CURSOR l_sty_id_csr IS
    /*SELECT '1'
     	FROM OKL_STRM_TYPE_B
      WHERE id = p_tilv_rec.sty_id;*/
     SELECT '1'
     FROM
       OKL_STRM_TMPT_FULL_UV st,
       OKL_K_HEADERS KHR,
       OKL_TRX_AR_INVOICES_B invoice
     WHERE
         invoice.id = p_tilv_rec.tai_id
     AND st.PDT_ID = khr.PDT_ID
     AND st.TMPT_STATUS = 'ACTIVE'
     AND st.sty_id = p_tilv_rec.sty_id
     AND invoice.khr_id(+) = khr.id;

     lv_sty_name OKL_STRM_TMPT_FULL_UV.sty_name%TYPE;
     -- cursor to pick up the stream name to show in the message
     CURSOR l_sty_name_csr IS
     SELECT st.NAME
     FROM OKL_STRM_TYPE_V st
     WHERE id = p_tilv_rec.sty_id;

   -- sjalasut. end of code changes
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF(p_tilv_rec.sty_id IS NOT NULL) THEN
	   	  OPEN l_sty_id_csr;
		     FETCH l_sty_id_csr INTO l_dummy_var;
		     CLOSE l_sty_id_csr;

       IF (l_dummy_var <> '1') THEN
         x_return_status := Okl_Api.G_RET_STS_ERROR;
         OPEN l_sty_name_csr;
         FETCH l_sty_name_csr INTO lv_sty_name;
         CLOSE l_sty_name_csr;
         Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
             p_msg_name	=> 'OKL_OP_FEETYP_NOT_CONTRACT',
             p_token1	=> 'FEE_TYPE',
             p_token1_value		=> lv_sty_name);
         --RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
	   END IF;

  END validate_sty_id;
----------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_acn_id_cost
  ---------------------------------------------------------------------------
  PROCEDURE validate_acn_id_cost (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_acn_id_cost_csr IS
    SELECT '1'
	FROM OKL_ASSET_CNDTN_LNS_B
	WHERE id = p_tilv_rec.acn_id_cost;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_tilv_rec.acn_id_cost IS NOT NULL) THEN
	   	  OPEN l_acn_id_cost_csr;
		  FETCH l_acn_id_cost_csr INTO l_dummy_var;
		  CLOSE l_acn_id_cost_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'ACN_ID_COST_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXL_AR_INV_LNS_V'	);

			 --RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_acn_id_cost;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_acn_id_cost
  ---------------------------------------------------------------------------
  PROCEDURE validate_til_id_reverses (p_tilv_rec IN tilv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_til_id_reverses_csr IS
    SELECT '1'
	FROM OKL_TXL_AR_INV_LNS_B
	WHERE id = p_tilv_rec.til_id_reverses;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_tilv_rec.til_id_reverses IS NOT NULL) THEN
	   	  OPEN l_til_id_reverses_csr;
		  FETCH l_til_id_reverses_csr INTO l_dummy_var;
		  CLOSE l_til_id_reverses_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TIL_ID_REVERSES_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TXL_AR_INV_LNS_V'	);

			 --RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_til_id_reverses;

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
    DELETE FROM OKL_TXL_AR_INV_LNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_AR_INV_LNS_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_TXL_AR_INV_LNS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXL_AR_INV_LNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_AR_INV_LNS_TL SUBB, OKL_TXL_AR_INV_LNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXL_AR_INV_LNS_TL (
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
        FROM OKL_TXL_AR_INV_LNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_AR_INV_LNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AR_INV_LNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_til_rec                      IN til_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN til_rec_type IS
    CURSOR til_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            INV_RECEIV_LINE_CODE,
            TAI_ID,
            KLE_ID,
            TPL_ID,
            STY_ID,
            ACN_ID_COST,
            TIL_ID_REVERSES,
            LINE_NUMBER,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
            QUANTITY,
            RECEIVABLES_INVOICE_ID,
            AMOUNT_APPLIED,
            DATE_BILL_PERIOD_START,
            DATE_BILL_PERIOD_END,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            INVENTORY_ORG_ID,
			ISL_ID,
			IBT_ID,
			LATE_CHARGE_REC_ID,
			CLL_ID,
-- Start Bug 4055540 fmiao 12/12/04--
   		 	INVENTORY_ITEM_ID,
-- End Bug 4055540 fmiao 12/12/04--
            QTE_LINE_ID,
            TXS_TRX_ID,
            -- Start Bug 4673593
            bank_acct_id,
            -- End Bug 4673593
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
-- start: 30-Jan-07 cklee  Billing R12 project                             |
TXL_AR_LINE_NUMBER,
TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project                             |
,TAX_LINE_ID --14-May-08 sechawla 6619311 : ADDED

      FROM Okl_Txl_Ar_Inv_Lns_B
     WHERE okl_txl_ar_inv_lns_b.id = p_id;
    l_til_pk                       til_pk_csr%ROWTYPE;
    l_til_rec                      til_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN til_pk_csr (p_til_rec.id);
    FETCH til_pk_csr INTO
              l_til_rec.ID,
              l_til_rec.INV_RECEIV_LINE_CODE,
              l_til_rec.TAI_ID,
              l_til_rec.KLE_ID,
              l_til_rec.TPL_ID,
              l_til_rec.STY_ID,
              l_til_rec.ACN_ID_COST,
              l_til_rec.TIL_ID_REVERSES,
              l_til_rec.LINE_NUMBER,
              l_til_rec.OBJECT_VERSION_NUMBER,
              l_til_rec.AMOUNT,
              l_til_rec.QUANTITY,
              l_til_rec.RECEIVABLES_INVOICE_ID,
              l_til_rec.AMOUNT_APPLIED,
              l_til_rec.DATE_BILL_PERIOD_START,
              l_til_rec.DATE_BILL_PERIOD_END,
              l_til_rec.REQUEST_ID,
              l_til_rec.PROGRAM_APPLICATION_ID,
              l_til_rec.PROGRAM_ID,
              l_til_rec.PROGRAM_UPDATE_DATE,
              l_til_rec.ORG_ID,
              l_til_rec.INVENTORY_ORG_ID,
              l_til_rec.ISL_ID,
              l_til_rec.IBT_ID,
			  l_til_rec.LATE_CHARGE_REC_ID,
			  l_til_rec.CLL_ID,
-- Start Bug 4055540 fmiao 12/12/04--
   		 	  l_til_rec.INVENTORY_ITEM_ID,
-- End Bug 4055540 fmiao 12/12/04--
              l_til_rec.QTE_LINE_ID,
              l_til_rec.TXS_TRX_ID,
              -- Start Bug 4673593
              l_til_rec.bank_acct_id,
              -- End Bug 4673593
              l_til_rec.ATTRIBUTE_CATEGORY,
              l_til_rec.ATTRIBUTE1,
              l_til_rec.ATTRIBUTE2,
              l_til_rec.ATTRIBUTE3,
              l_til_rec.ATTRIBUTE4,
              l_til_rec.ATTRIBUTE5,
              l_til_rec.ATTRIBUTE6,
              l_til_rec.ATTRIBUTE7,
              l_til_rec.ATTRIBUTE8,
              l_til_rec.ATTRIBUTE9,
              l_til_rec.ATTRIBUTE10,
              l_til_rec.ATTRIBUTE11,
              l_til_rec.ATTRIBUTE12,
              l_til_rec.ATTRIBUTE13,
              l_til_rec.ATTRIBUTE14,
              l_til_rec.ATTRIBUTE15,
              l_til_rec.CREATED_BY,
              l_til_rec.CREATION_DATE,
              l_til_rec.LAST_UPDATED_BY,
              l_til_rec.LAST_UPDATE_DATE,
              l_til_rec.LAST_UPDATE_LOGIN,
-- start: 30-Jan-07 cklee  Billing R12 project                             |
              l_til_rec.TXL_AR_LINE_NUMBER,
              l_til_rec.TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project
              ,l_til_rec.TAX_LINE_ID --14-May-08 sechawla 6619311                         |
;

    x_no_data_found := til_pk_csr%NOTFOUND;
    CLOSE til_pk_csr;
    RETURN(l_til_rec);
  END get_rec;

  FUNCTION get_rec (
    p_til_rec                      IN til_rec_type
  ) RETURN til_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_til_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AR_INV_LNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txl_ar_inv_lns_tl_rec_type IS
    CURSOR okl_txl_ar_inv_lns_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Txl_Ar_Inv_Lns_Tl
     WHERE okl_txl_ar_inv_lns_tl.id = p_id
       AND okl_txl_ar_inv_lns_tl.LANGUAGE = p_language;
    l_okl_txl_ar_inv_lns_tl_pk     okl_txl_ar_inv_lns_tl_pk_csr%ROWTYPE;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_ar_inv_lns_tl_pk_csr (p_okl_txl_ar_inv_lns_tl_rec.id,
                                       p_okl_txl_ar_inv_lns_tl_rec.LANGUAGE);
    FETCH okl_txl_ar_inv_lns_tl_pk_csr INTO
              l_okl_txl_ar_inv_lns_tl_rec.ID,
              l_okl_txl_ar_inv_lns_tl_rec.LANGUAGE,
              l_okl_txl_ar_inv_lns_tl_rec.SOURCE_LANG,
              l_okl_txl_ar_inv_lns_tl_rec.ERROR_MESSAGE,
              l_okl_txl_ar_inv_lns_tl_rec.SFWT_FLAG,
              l_okl_txl_ar_inv_lns_tl_rec.DESCRIPTION,
              l_okl_txl_ar_inv_lns_tl_rec.CREATED_BY,
              l_okl_txl_ar_inv_lns_tl_rec.CREATION_DATE,
              l_okl_txl_ar_inv_lns_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_ar_inv_lns_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_ar_inv_lns_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_ar_inv_lns_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_ar_inv_lns_tl_pk_csr;
    RETURN(l_okl_txl_ar_inv_lns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type
  ) RETURN okl_txl_ar_inv_lns_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_ar_inv_lns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AR_INV_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tilv_rec                     IN tilv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tilv_rec_type IS
    CURSOR okl_tilv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ERROR_MESSAGE,
            SFWT_FLAG,
            KLE_ID,
            TPL_ID,
            TIL_ID_REVERSES,
            INV_RECEIV_LINE_CODE,
            STY_ID,
            TAI_ID,
            ACN_ID_COST,
            AMOUNT,
            LINE_NUMBER,
            QUANTITY,
            DESCRIPTION,
            RECEIVABLES_INVOICE_ID,
            DATE_BILL_PERIOD_START,
            AMOUNT_APPLIED,
            DATE_BILL_PERIOD_END,
			ISL_ID,
			IBT_ID,
			LATE_CHARGE_REC_ID,
			CLL_ID,
-- Start Bug 4055540 fmiao 12/12/04--
   		 	INVENTORY_ITEM_ID,
-- End Bug 4055540 fmiao 12/12/04--
            QTE_LINE_ID,
            TXS_TRX_ID,
            -- Start Bug 4673593
            bank_acct_id,
            -- End Bug 4673593
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
            LAST_UPDATE_LOGIN,
-- start: 30-Jan-07 cklee  Billing R12 project                             |
            TXL_AR_LINE_NUMBER,
            TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project
            ,TAX_LINE_ID --14-May-08 sechawla 6619311                           |

      FROM Okl_Txl_Ar_Inv_Lns_V
     WHERE okl_txl_ar_inv_lns_v.id = p_id;
    l_okl_tilv_pk                  okl_tilv_pk_csr%ROWTYPE;
    l_tilv_rec                     tilv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tilv_pk_csr (p_tilv_rec.id);
    FETCH okl_tilv_pk_csr INTO
              l_tilv_rec.ID,
              l_tilv_rec.OBJECT_VERSION_NUMBER,
              l_tilv_rec.ERROR_MESSAGE,
              l_tilv_rec.SFWT_FLAG,
              l_tilv_rec.KLE_ID,
              l_tilv_rec.TPL_ID,
              l_tilv_rec.TIL_ID_REVERSES,
              l_tilv_rec.INV_RECEIV_LINE_CODE,
              l_tilv_rec.STY_ID,
              l_tilv_rec.TAI_ID,
              l_tilv_rec.ACN_ID_COST,
              l_tilv_rec.AMOUNT,
              l_tilv_rec.LINE_NUMBER,
              l_tilv_rec.QUANTITY,
              l_tilv_rec.DESCRIPTION,
              l_tilv_rec.RECEIVABLES_INVOICE_ID,
              l_tilv_rec.DATE_BILL_PERIOD_START,
              l_tilv_rec.AMOUNT_APPLIED,
              l_tilv_rec.DATE_BILL_PERIOD_END,
              l_tilv_rec.ISL_ID,
              l_tilv_rec.IBT_ID,
              l_tilv_rec.LATE_CHARGE_REC_ID,
              l_tilv_rec.CLL_ID,
-- Start Bug 4055540 fmiao 12/12/04--
   		 	  l_tilv_rec.INVENTORY_ITEM_ID,
-- End Bug 4055540 fmiao 12/12/04--
              l_tilv_rec.QTE_LINE_ID,
              l_tilv_rec.TXS_TRX_ID,
            -- Start Bug 4673593
   		 	  l_tilv_rec.bank_acct_id,
            -- End Bug 4673593
              l_tilv_rec.ATTRIBUTE_CATEGORY,
              l_tilv_rec.ATTRIBUTE1,
              l_tilv_rec.ATTRIBUTE2,
              l_tilv_rec.ATTRIBUTE3,
              l_tilv_rec.ATTRIBUTE4,
              l_tilv_rec.ATTRIBUTE5,
              l_tilv_rec.ATTRIBUTE6,
              l_tilv_rec.ATTRIBUTE7,
              l_tilv_rec.ATTRIBUTE8,
              l_tilv_rec.ATTRIBUTE9,
              l_tilv_rec.ATTRIBUTE10,
              l_tilv_rec.ATTRIBUTE11,
              l_tilv_rec.ATTRIBUTE12,
              l_tilv_rec.ATTRIBUTE13,
              l_tilv_rec.ATTRIBUTE14,
              l_tilv_rec.ATTRIBUTE15,
              l_tilv_rec.REQUEST_ID,
              l_tilv_rec.PROGRAM_APPLICATION_ID,
              l_tilv_rec.PROGRAM_ID,
              l_tilv_rec.PROGRAM_UPDATE_DATE,
              l_tilv_rec.ORG_ID,
              l_tilv_rec.INVENTORY_ORG_ID,
              l_tilv_rec.CREATED_BY,
              l_tilv_rec.CREATION_DATE,
              l_tilv_rec.LAST_UPDATED_BY,
              l_tilv_rec.LAST_UPDATE_DATE,
              l_tilv_rec.LAST_UPDATE_LOGIN,

-- start: 30-Jan-07 cklee  Billing R12 project                             |
              l_tilv_rec.TXL_AR_LINE_NUMBER,
              l_tilv_rec.TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project                             |
              ,l_tilv_rec.TAX_LINE_ID; --14-May-08 sechawla 6619311
    x_no_data_found := okl_tilv_pk_csr%NOTFOUND;
    CLOSE okl_tilv_pk_csr;
    RETURN(l_tilv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tilv_rec                     IN tilv_rec_type
  ) RETURN tilv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tilv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_AR_INV_LNS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tilv_rec	IN tilv_rec_type
  ) RETURN tilv_rec_type IS
    l_tilv_rec	tilv_rec_type := p_tilv_rec;
  BEGIN
    IF (l_tilv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.object_version_number := NULL;
    END IF;
    IF (l_tilv_rec.error_message = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.error_message := NULL;
    END IF;
    IF (l_tilv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tilv_rec.kle_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.kle_id := NULL;
    END IF;
    IF (l_tilv_rec.tpl_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.tpl_id := NULL;
    END IF;
    IF (l_tilv_rec.til_id_reverses = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.til_id_reverses := NULL;
    END IF;
    IF (l_tilv_rec.inv_receiv_line_code = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.inv_receiv_line_code := NULL;
    END IF;
    IF (l_tilv_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.sty_id := NULL;
    END IF;
    IF (l_tilv_rec.tai_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.tai_id := NULL;
    END IF;
    IF (l_tilv_rec.acn_id_cost = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.acn_id_cost := NULL;
    END IF;
    IF (l_tilv_rec.amount = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.amount := NULL;
    END IF;
    IF (l_tilv_rec.line_number = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.line_number := NULL;
    END IF;
    IF (l_tilv_rec.quantity = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.quantity := NULL;
    END IF;
    IF (l_tilv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.description := NULL;
    END IF;
    IF (l_tilv_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.receivables_invoice_id := NULL;
    END IF;
    IF (l_tilv_rec.date_bill_period_start = Okl_Api.G_MISS_DATE) THEN
      l_tilv_rec.date_bill_period_start := NULL;
    END IF;
    IF (l_tilv_rec.amount_applied = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.amount_applied := NULL;
    END IF;
    IF (l_tilv_rec.date_bill_period_end = Okl_Api.G_MISS_DATE) THEN
      l_tilv_rec.date_bill_period_end := NULL;
    END IF;
    IF (l_tilv_rec.isl_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.isl_id := NULL;
    END IF;
    IF (l_tilv_rec.ibt_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.ibt_id := NULL;
    END IF;
    IF (l_tilv_rec.LATE_CHARGE_REC_ID = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.LATE_CHARGE_REC_ID := NULL;
    END IF;
    IF (l_tilv_rec.CLL_ID = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.CLL_ID := NULL;
    END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
    IF (l_tilv_rec.inventory_item_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.inventory_item_id := NULL;
    END IF;
-- End changes on remarketing by fmiao on 10/18/04 --
    IF (l_tilv_rec.qte_line_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.qte_line_id := NULL;
    END IF;
    IF (l_tilv_rec.txs_trx_id= Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.txs_trx_id := NULL;
    END IF;
-- Start Bug 4673593 --
    IF (l_tilv_rec.bank_acct_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.bank_acct_id := NULL;
    END IF;
-- End Bug 4673593 --
    IF (l_tilv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute_category := NULL;
    END IF;
    IF (l_tilv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute1 := NULL;
    END IF;
    IF (l_tilv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute2 := NULL;
    END IF;
    IF (l_tilv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute3 := NULL;
    END IF;
    IF (l_tilv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute4 := NULL;
    END IF;
    IF (l_tilv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute5 := NULL;
    END IF;
    IF (l_tilv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute6 := NULL;
    END IF;
    IF (l_tilv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute7 := NULL;
    END IF;
    IF (l_tilv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute8 := NULL;
    END IF;
    IF (l_tilv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute9 := NULL;
    END IF;
    IF (l_tilv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute10 := NULL;
    END IF;
    IF (l_tilv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute11 := NULL;
    END IF;
    IF (l_tilv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute12 := NULL;
    END IF;
    IF (l_tilv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute13 := NULL;
    END IF;
    IF (l_tilv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute14 := NULL;
    END IF;
    IF (l_tilv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_tilv_rec.attribute15 := NULL;
    END IF;
    IF (l_tilv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.request_id := NULL;
    END IF;
    IF (l_tilv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.program_application_id := NULL;
    END IF;
    IF (l_tilv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.program_id := NULL;
    END IF;
    IF (l_tilv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_tilv_rec.program_update_date := NULL;
    END IF;
    IF (l_tilv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.org_id := NULL;
    END IF;

    IF (l_tilv_rec.INVENTORY_org_id = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.INVENTORY_org_id := NULL;
    END IF;

    IF (l_tilv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.created_by := NULL;
    END IF;
    IF (l_tilv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_tilv_rec.creation_date := NULL;
    END IF;
    IF (l_tilv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tilv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_tilv_rec.last_update_date := NULL;
    END IF;
    IF (l_tilv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.last_update_login := NULL;
    END IF;


-- start: 30-Jan-07 cklee  Billing R12 project                             |
    IF (l_tilv_rec.TXL_AR_LINE_NUMBER = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.TXL_AR_LINE_NUMBER := NULL;
    END IF;
    IF (l_tilv_rec.TXS_TRX_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.TXS_TRX_LINE_ID := NULL;
    END IF;
-- end: 30-Jan-07 cklee  Billing R12 project                             |
    --14-May-08 sechawla 6619311
    IF (l_tilv_rec.TAX_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      l_tilv_rec.TAX_LINE_ID := NULL;
    END IF;

    RETURN(l_tilv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_AR_INV_LNS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tilv_rec IN  tilv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  	-- Added 04/16/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

--Added 04/17/2001 Sunil Mathew ---
    validate_inv_receiv_line_code (p_tilv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_tai_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_kle_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_tpl_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_sty_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_acn_id_cost(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_til_id_reverses(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_line_number(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_inventory_org_id(p_tilv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--Added 04/17/2001 Sunil Mathew ---

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_TXL_AR_INV_LNS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_tilv_rec IN tilv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tilv_rec_type,
    p_to	IN OUT NOCOPY til_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inv_receiv_line_code := p_from.inv_receiv_line_code;
    p_to.tai_id := p_from.tai_id;
    p_to.kle_id := p_from.kle_id;
    p_to.tpl_id := p_from.tpl_id;
    p_to.sty_id := p_from.sty_id;
    p_to.acn_id_cost := p_from.acn_id_cost;
    p_to.til_id_reverses := p_from.til_id_reverses;
    p_to.line_number := p_from.line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.quantity := p_from.quantity;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.amount_applied := p_from.amount_applied;
    p_to.date_bill_period_start := p_from.date_bill_period_start;
    p_to.date_bill_period_end := p_from.date_bill_period_end;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
    p_to.isl_id := p_from.isl_id;
    p_to.ibt_id := p_from.ibt_id;
	p_to.LATE_CHARGE_REC_ID := p_from.LATE_CHARGE_REC_ID;
	p_to.CLL_ID := p_from.CLL_ID;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --
    p_to.qte_line_id := p_from.qte_line_id;
    p_to.txs_trx_id := p_from.txs_trx_id;
-- Start Bug 4673593 --
    p_to.bank_acct_id := p_from.bank_acct_id;
-- End Bug 4673593 --
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

-- start: 30-Jan-07 cklee  Billing R12 project                             |
    p_to.TXL_AR_LINE_NUMBER := p_from.TXL_AR_LINE_NUMBER;
    p_to.TXS_TRX_LINE_ID := p_from.TXS_TRX_LINE_ID;

-- end: 30-Jan-07 cklee  Billing R12 project

   --14-May-08 sechawla 6619311
   p_to.TAX_LINE_ID := p_from.TAX_LINE_ID;

  END migrate;
  PROCEDURE migrate (
    p_from	IN til_rec_type,
    p_to	IN OUT NOCOPY tilv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inv_receiv_line_code := p_from.inv_receiv_line_code;
    p_to.tai_id := p_from.tai_id;
    p_to.kle_id := p_from.kle_id;
    p_to.tpl_id := p_from.tpl_id;
    p_to.sty_id := p_from.sty_id;
    p_to.acn_id_cost := p_from.acn_id_cost;
    p_to.til_id_reverses := p_from.til_id_reverses;
    p_to.line_number := p_from.line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.quantity := p_from.quantity;
    p_to.receivables_invoice_id := p_from.receivables_invoice_id;
    p_to.amount_applied := p_from.amount_applied;
    p_to.date_bill_period_start := p_from.date_bill_period_start;
    p_to.date_bill_period_end := p_from.date_bill_period_end;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.inventory_org_id := p_from.inventory_org_id;
    p_to.isl_id := p_from.isl_id;
    p_to.ibt_id := p_from.ibt_id;
    p_to.LATE_CHARGE_REC_ID := p_from.LATE_CHARGE_REC_ID;
    p_to.CLL_ID := p_from.CLL_ID;
-- Start changes on remarketing by fmiao on 10/18/04 --
    p_to.inventory_item_id := p_from.inventory_item_id;
-- End changes on remarketing by fmiao on 10/18/04 --
    p_to.qte_line_id := p_from.qte_line_id;
    p_to.txs_trx_id := p_from.txs_trx_id;
-- Start Bug 4673593--
    p_to.bank_acct_id := p_from.bank_acct_id;
-- End Bug 4673593 --
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

-- start: 30-Jan-07 cklee  Billing R12 project                             |
    p_to.TXL_AR_LINE_NUMBER := p_from.TXL_AR_LINE_NUMBER;
    p_to.TXS_TRX_LINE_ID := p_from.TXS_TRX_LINE_ID;

-- end: 30-Jan-07 cklee  Billing R12 project

    --14-May-08 sechawla 6619311
    p_to.TAX_LINE_ID := p_from.TAX_LINE_ID;

  END migrate;
  PROCEDURE migrate (
    p_from	IN tilv_rec_type,
    p_to	IN OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type
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
    p_from	IN okl_txl_ar_inv_lns_tl_rec_type,
    p_to	IN OUT NOCOPY tilv_rec_type
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
  -- validate_row for:OKL_TXL_AR_INV_LNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tilv_rec                     tilv_rec_type := p_tilv_rec;
    l_til_rec                      til_rec_type;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_tilv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tilv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- PL/SQL TBL validate_row for:TILV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type) IS

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
    IF (p_tilv_tbl.COUNT > 0) THEN
      i := p_tilv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tilv_rec                     => p_tilv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
	    EXIT WHEN (i = p_tilv_tbl.LAST);
        i := p_tilv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -----------------------------------------
  -- insert_row for:OKL_TXL_AR_INV_LNS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_til_rec                      IN til_rec_type,
    x_til_rec                      OUT NOCOPY til_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_til_rec                      til_rec_type := p_til_rec;
    l_def_til_rec                  til_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_til_rec IN  til_rec_type,
      x_til_rec OUT NOCOPY til_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_til_rec := p_til_rec;
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
      p_til_rec,                         -- IN
      l_til_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_AR_INV_LNS_B(
        id,
        inv_receiv_line_code,
        tai_id,
        kle_id,
        tpl_id,
        sty_id,
        acn_id_cost,
        til_id_reverses,
        line_number,
        object_version_number,
        amount,
        quantity,
        receivables_invoice_id,
        amount_applied,
        date_bill_period_start,
        date_bill_period_end,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        inventory_org_id,
		isl_id,
		ibt_id,
		LATE_CHARGE_REC_ID,
		CLL_ID,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
        qte_line_id,
        txs_trx_id,
-- Start Bug 4673593 --
   		bank_acct_id,
-- End Bug 4673593 --
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
-- start: 30-Jan-07 cklee  Billing R12 project                             |
        TXL_AR_LINE_NUMBER,
        TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project                             |
        ,TAX_LINE_ID --14-May-08 sechawla 6619311
)

      VALUES (
        l_til_rec.id,
        l_til_rec.inv_receiv_line_code,
        l_til_rec.tai_id,
        l_til_rec.kle_id,
        l_til_rec.tpl_id,
        l_til_rec.sty_id,
        l_til_rec.acn_id_cost,
        l_til_rec.til_id_reverses,
        l_til_rec.line_number,
        l_til_rec.object_version_number,
        l_til_rec.amount,
        l_til_rec.quantity,
        l_til_rec.receivables_invoice_id,
        l_til_rec.amount_applied,
        l_til_rec.date_bill_period_start,
        l_til_rec.date_bill_period_end,
        l_til_rec.request_id,
        l_til_rec.program_application_id,
        l_til_rec.program_id,
        l_til_rec.program_update_date,
        l_til_rec.org_id,
        l_til_rec.inventory_org_id,
        l_til_rec.isl_id,
        l_til_rec.ibt_id,
        l_til_rec.LATE_CHARGE_REC_ID,
        l_til_rec.CLL_ID,
-- Start changes on remarketing by fmiao on 10/18/04 --
        l_til_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
        l_til_rec.qte_line_id,
        l_til_rec.txs_trx_id,
-- Start Bug 4673593 --
        l_til_rec.bank_acct_id,
-- End Bug 4673593 --

        l_til_rec.attribute_category,
        l_til_rec.attribute1,
        l_til_rec.attribute2,
        l_til_rec.attribute3,
        l_til_rec.attribute4,
        l_til_rec.attribute5,
        l_til_rec.attribute6,
        l_til_rec.attribute7,
        l_til_rec.attribute8,
        l_til_rec.attribute9,
        l_til_rec.attribute10,
        l_til_rec.attribute11,
        l_til_rec.attribute12,
        l_til_rec.attribute13,
        l_til_rec.attribute14,
        l_til_rec.attribute15,
        l_til_rec.created_by,
        l_til_rec.creation_date,
        l_til_rec.last_updated_by,
        l_til_rec.last_update_date,
        l_til_rec.last_update_login,
-- start: 30-Jan-07 cklee  Billing R12 project                             |
        l_til_rec.TXL_AR_LINE_NUMBER,
        l_til_rec.TXS_TRX_LINE_ID
-- end: 30-Jan-07 cklee  Billing R12 project                             |
        ,l_til_rec.TAX_LINE_ID --14-May-08 sechawla 6619311
);

    -- Set OUT values
    x_til_rec := l_til_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  ------------------------------------------
  -- insert_row for:OKL_TXL_AR_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type,
    x_okl_txl_ar_inv_lns_tl_rec    OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type := p_okl_txl_ar_inv_lns_tl_rec;
    ldefokltxlarinvlnstlrec        okl_txl_ar_inv_lns_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ar_inv_lns_tl_rec IN  okl_txl_ar_inv_lns_tl_rec_type,
      x_okl_txl_ar_inv_lns_tl_rec OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ar_inv_lns_tl_rec := p_okl_txl_ar_inv_lns_tl_rec;
      x_okl_txl_ar_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_ar_inv_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_ar_inv_lns_tl_rec,       -- IN
      l_okl_txl_ar_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_ar_inv_lns_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_AR_INV_LNS_TL(
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
          l_okl_txl_ar_inv_lns_tl_rec.id,
          l_okl_txl_ar_inv_lns_tl_rec.LANGUAGE,
          l_okl_txl_ar_inv_lns_tl_rec.source_lang,
          l_okl_txl_ar_inv_lns_tl_rec.error_message,
          l_okl_txl_ar_inv_lns_tl_rec.sfwt_flag,
          l_okl_txl_ar_inv_lns_tl_rec.description,
          l_okl_txl_ar_inv_lns_tl_rec.created_by,
          l_okl_txl_ar_inv_lns_tl_rec.creation_date,
          l_okl_txl_ar_inv_lns_tl_rec.last_updated_by,
          l_okl_txl_ar_inv_lns_tl_rec.last_update_date,
          l_okl_txl_ar_inv_lns_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_ar_inv_lns_tl_rec := l_okl_txl_ar_inv_lns_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- insert_row for:OKL_TXL_AR_INV_LNS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type,
    x_tilv_rec                     OUT NOCOPY tilv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tilv_rec                     tilv_rec_type;
    l_def_tilv_rec                 tilv_rec_type;
    l_til_rec                      til_rec_type;
    lx_til_rec                     til_rec_type;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
    lx_okl_txl_ar_inv_lns_tl_rec   okl_txl_ar_inv_lns_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tilv_rec	IN tilv_rec_type
    ) RETURN tilv_rec_type IS
      l_tilv_rec	tilv_rec_type := p_tilv_rec;
    BEGIN
      l_tilv_rec.CREATION_DATE := SYSDATE;
      l_tilv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_tilv_rec.LAST_UPDATE_DATE := l_tilv_rec.CREATION_DATE;
      l_tilv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tilv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_tilv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tilv_rec IN  tilv_rec_type,
      x_tilv_rec OUT NOCOPY tilv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tilv_rec := p_tilv_rec;
      x_tilv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tilv_rec.SFWT_FLAG := 'N';

	IF (x_tilv_rec.request_id IS NULL OR x_tilv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_tilv_rec.request_id,
	  	   x_tilv_rec.program_application_id,
	  	   x_tilv_rec.program_id,
	  	   x_tilv_rec.program_update_date
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
    l_tilv_rec := null_out_defaults(p_tilv_rec);
    -- Set primary key value
    l_tilv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tilv_rec,                        -- IN
      l_def_tilv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tilv_rec := fill_who_columns(l_def_tilv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tilv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tilv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tilv_rec, l_til_rec);
    migrate(l_def_tilv_rec, l_okl_txl_ar_inv_lns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_til_rec,
      lx_til_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_til_rec, l_def_tilv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ar_inv_lns_tl_rec,
      lx_okl_txl_ar_inv_lns_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_ar_inv_lns_tl_rec, l_def_tilv_rec);
    -- Set OUT values
    x_tilv_rec := l_def_tilv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- PL/SQL TBL insert_row for:TILV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type,
    x_tilv_tbl                     OUT NOCOPY tilv_tbl_type) IS

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
    IF (p_tilv_tbl.COUNT > 0) THEN
      i := p_tilv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tilv_rec                     => p_tilv_tbl(i),
          x_tilv_rec                     => x_tilv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tilv_tbl.LAST);
        i := p_tilv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_AR_INV_LNS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_til_rec                      IN til_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_til_rec IN til_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_AR_INV_LNS_B
     WHERE ID = p_til_rec.id
       AND OBJECT_VERSION_NUMBER = p_til_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_til_rec IN til_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_AR_INV_LNS_B
    WHERE ID = p_til_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_AR_INV_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_AR_INV_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_til_rec);
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
      OPEN lchk_csr(p_til_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_til_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_til_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  ----------------------------------------
  -- lock_row for:OKL_TXL_AR_INV_LNS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_ar_inv_lns_tl_rec IN okl_txl_ar_inv_lns_tl_rec_type) IS
    SELECT *
      FROM OKL_TXL_AR_INV_LNS_TL
     WHERE ID = p_okl_txl_ar_inv_lns_tl_rec.id
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
      OPEN lock_csr(p_okl_txl_ar_inv_lns_tl_rec);
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
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- lock_row for:OKL_TXL_AR_INV_LNS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_til_rec                      til_rec_type;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
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
    migrate(p_tilv_rec, l_til_rec);
    migrate(p_tilv_rec, l_okl_txl_ar_inv_lns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_til_rec
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
      l_okl_txl_ar_inv_lns_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- PL/SQL TBL lock_row for:TILV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type) IS

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
    IF (p_tilv_tbl.COUNT > 0) THEN
      i := p_tilv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tilv_rec                     => p_tilv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tilv_tbl.LAST);
        i := p_tilv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -----------------------------------------
  -- update_row for:OKL_TXL_AR_INV_LNS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_til_rec                      IN til_rec_type,
    x_til_rec                      OUT NOCOPY til_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_til_rec                      til_rec_type := p_til_rec;
    l_def_til_rec                  til_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_til_rec	IN til_rec_type,
      x_til_rec	OUT NOCOPY til_rec_type
    ) RETURN VARCHAR2 IS
      l_til_rec                      til_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_til_rec := p_til_rec;
      -- Get current database values
      l_til_rec := get_rec(p_til_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_til_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.id := l_til_rec.id;
      END IF;
      IF (x_til_rec.inv_receiv_line_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.inv_receiv_line_code := l_til_rec.inv_receiv_line_code;
      END IF;
      IF (x_til_rec.tai_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.tai_id := l_til_rec.tai_id;
      END IF;
      IF (x_til_rec.kle_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.kle_id := l_til_rec.kle_id;
      END IF;
      IF (x_til_rec.tpl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.tpl_id := l_til_rec.tpl_id;
      END IF;
      IF (x_til_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.sty_id := l_til_rec.sty_id;
      END IF;
      IF (x_til_rec.acn_id_cost = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.acn_id_cost := l_til_rec.acn_id_cost;
      END IF;
      IF (x_til_rec.til_id_reverses = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.til_id_reverses := l_til_rec.til_id_reverses;
      END IF;
      IF (x_til_rec.line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.line_number := l_til_rec.line_number;
      END IF;
      IF (x_til_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.object_version_number := l_til_rec.object_version_number;
      END IF;
      IF (x_til_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.amount := l_til_rec.amount;
      END IF;
      IF (x_til_rec.quantity = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.quantity := l_til_rec.quantity;
      END IF;
      IF (x_til_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.receivables_invoice_id := l_til_rec.receivables_invoice_id;
      END IF;
      IF (x_til_rec.amount_applied = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.amount_applied := l_til_rec.amount_applied;
      END IF;
      IF (x_til_rec.date_bill_period_start = Okl_Api.G_MISS_DATE)
      THEN
        x_til_rec.date_bill_period_start := l_til_rec.date_bill_period_start;
      END IF;
      IF (x_til_rec.date_bill_period_end = Okl_Api.G_MISS_DATE)
      THEN
        x_til_rec.date_bill_period_end := l_til_rec.date_bill_period_end;
      END IF;
      IF (x_til_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.request_id := l_til_rec.request_id;
      END IF;
      IF (x_til_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.program_application_id := l_til_rec.program_application_id;
      END IF;
      IF (x_til_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.program_id := l_til_rec.program_id;
      END IF;
      IF (x_til_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_til_rec.program_update_date := l_til_rec.program_update_date;
      END IF;
      IF (x_til_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.org_id := l_til_rec.org_id;
      END IF;

      IF (x_til_rec.inventory_org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.inventory_org_id := l_til_rec.inventory_org_id;
      END IF;

      IF (x_til_rec.isl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.isl_id := l_til_rec.isl_id;
      END IF;
      IF (x_til_rec.ibt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.ibt_id := l_til_rec.ibt_id;
      END IF;
      IF (x_til_rec.LATE_CHARGE_REC_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.LATE_CHARGE_REC_ID := l_til_rec.LATE_CHARGE_REC_ID;
      END IF;
      IF (x_til_rec.CLL_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.CLL_ID := l_til_rec.CLL_ID;
      END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_til_rec.inventory_item_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.inventory_item_id := l_til_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --
      IF (x_til_rec.qte_line_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.qte_line_id := l_til_rec.qte_line_id;
      END IF;
      IF (x_til_rec.txs_trx_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.txs_trx_id := l_til_rec.txs_trx_id;
      END IF;
-- Start Bug 4673593 --
      IF (x_til_rec.bank_acct_id = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.bank_acct_id := l_til_rec.bank_acct_id;
      END IF;
-- End Bug 4673593 --
      IF (x_til_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute_category := l_til_rec.attribute_category;
      END IF;
      IF (x_til_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute1 := l_til_rec.attribute1;
      END IF;
      IF (x_til_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute2 := l_til_rec.attribute2;
      END IF;
      IF (x_til_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute3 := l_til_rec.attribute3;
      END IF;
      IF (x_til_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute4 := l_til_rec.attribute4;
      END IF;
      IF (x_til_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute5 := l_til_rec.attribute5;
      END IF;
      IF (x_til_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute6 := l_til_rec.attribute6;
      END IF;
      IF (x_til_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute7 := l_til_rec.attribute7;
      END IF;
      IF (x_til_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute8 := l_til_rec.attribute8;
      END IF;
      IF (x_til_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute9 := l_til_rec.attribute9;
      END IF;
      IF (x_til_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute10 := l_til_rec.attribute10;
      END IF;
      IF (x_til_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute11 := l_til_rec.attribute11;
      END IF;
      IF (x_til_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute12 := l_til_rec.attribute12;
      END IF;
      IF (x_til_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute13 := l_til_rec.attribute13;
      END IF;
      IF (x_til_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute14 := l_til_rec.attribute14;
      END IF;
      IF (x_til_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_til_rec.attribute15 := l_til_rec.attribute15;
      END IF;
      IF (x_til_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.created_by := l_til_rec.created_by;
      END IF;
      IF (x_til_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_til_rec.creation_date := l_til_rec.creation_date;
      END IF;
      IF (x_til_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.last_updated_by := l_til_rec.last_updated_by;
      END IF;
      IF (x_til_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_til_rec.last_update_date := l_til_rec.last_update_date;
      END IF;
      IF (x_til_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.last_update_login := l_til_rec.last_update_login;
      END IF;

-- start: 30-Jan-07 cklee  Billing R12 project                             |
      IF (x_til_rec.TXL_AR_LINE_NUMBER = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.TXL_AR_LINE_NUMBER := l_til_rec.TXL_AR_LINE_NUMBER;
      END IF;

      IF (x_til_rec.TXS_TRX_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.TXS_TRX_LINE_ID := l_til_rec.TXS_TRX_LINE_ID;
      END IF;

-- end: 30-Jan-07 cklee  Billing R12 project                             |
      --14-May-08 sechawla 6619311
      IF (x_til_rec.TAX_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_til_rec.TAX_LINE_ID := l_til_rec.TAX_LINE_ID;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_til_rec IN  til_rec_type,
      x_til_rec OUT NOCOPY til_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
	  x_til_rec := p_til_rec;

/*	  x_til_rec.request_id := DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID);
	  x_til_rec.program_application_id :=DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.PROG_APPL_ID);
	  x_til_rec.program_id :=DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID);
	  x_til_rec.program_update_date :=DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE);
	*/

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
      p_til_rec,                         -- IN
      l_til_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_til_rec, l_def_til_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_AR_INV_LNS_B
    SET INV_RECEIV_LINE_CODE = l_def_til_rec.inv_receiv_line_code,
        TAI_ID = l_def_til_rec.tai_id,
        KLE_ID = l_def_til_rec.kle_id,
        TPL_ID = l_def_til_rec.tpl_id,
        STY_ID = l_def_til_rec.sty_id,
        ACN_ID_COST = l_def_til_rec.acn_id_cost,
        TIL_ID_REVERSES = l_def_til_rec.til_id_reverses,
        LINE_NUMBER = l_def_til_rec.line_number,
        OBJECT_VERSION_NUMBER = l_def_til_rec.object_version_number,
        AMOUNT = l_def_til_rec.amount,
        QUANTITY = l_def_til_rec.quantity,
        RECEIVABLES_INVOICE_ID = l_def_til_rec.receivables_invoice_id,
        AMOUNT_APPLIED = l_def_til_rec.amount_applied,
        DATE_BILL_PERIOD_START = l_def_til_rec.date_bill_period_start,
        DATE_BILL_PERIOD_END = l_def_til_rec.date_bill_period_end,
        REQUEST_ID = l_def_til_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_til_rec.program_application_id,
        PROGRAM_ID = l_def_til_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_til_rec.program_update_date,
        ORG_ID = l_def_til_rec.org_id,
        inventory_ORG_ID = l_def_til_rec.inventory_org_id,
        ISL_ID = l_def_til_rec.isl_id,
        IBT_ID = l_def_til_rec.ibt_id,
        LATE_CHARGE_REC_ID = l_def_til_rec.LATE_CHARGE_REC_ID,
        CLL_ID = l_def_til_rec.CLL_ID,
-- Start changes on remarketing by fmiao on 10/18/04 --
   		INVENTORY_ITEM_ID = l_def_til_rec.inventory_item_id,
-- End changes on remarketing by fmiao on 10/18/04 --
        QTE_LINE_ID = l_def_til_rec.qte_line_id,
        TXS_TRX_ID  = l_def_til_rec.txs_trx_id,
-- Start Bug 4673593 --
   		BANK_ACCT_ID = l_def_til_rec.bank_acct_id,
-- End Bug 4673593 --
        ATTRIBUTE_CATEGORY = l_def_til_rec.attribute_category,
        ATTRIBUTE1 = l_def_til_rec.attribute1,
        ATTRIBUTE2 = l_def_til_rec.attribute2,
        ATTRIBUTE3 = l_def_til_rec.attribute3,
        ATTRIBUTE4 = l_def_til_rec.attribute4,
        ATTRIBUTE5 = l_def_til_rec.attribute5,
        ATTRIBUTE6 = l_def_til_rec.attribute6,
        ATTRIBUTE7 = l_def_til_rec.attribute7,
        ATTRIBUTE8 = l_def_til_rec.attribute8,
        ATTRIBUTE9 = l_def_til_rec.attribute9,
        ATTRIBUTE10 = l_def_til_rec.attribute10,
        ATTRIBUTE11 = l_def_til_rec.attribute11,
        ATTRIBUTE12 = l_def_til_rec.attribute12,
        ATTRIBUTE13 = l_def_til_rec.attribute13,
        ATTRIBUTE14 = l_def_til_rec.attribute14,
        ATTRIBUTE15 = l_def_til_rec.attribute15,
        CREATED_BY = l_def_til_rec.created_by,
        CREATION_DATE = l_def_til_rec.creation_date,
        LAST_UPDATED_BY = l_def_til_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_til_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_til_rec.last_update_login,
-- start: 30-Jan-07 cklee  Billing R12 project                             |
        TXL_AR_LINE_NUMBER = l_def_til_rec.TXL_AR_LINE_NUMBER,
        TXS_TRX_LINE_ID = l_def_til_rec.TXS_TRX_LINE_ID

-- end: 30-Jan-07 cklee  Billing R12 project                             |
        ,TAX_LINE_ID = l_def_til_rec.TAX_LINE_ID --14-May-08 sechawla 6619311



    WHERE ID = l_def_til_rec.id;

    x_til_rec := l_def_til_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  ------------------------------------------
  -- update_row for:OKL_TXL_AR_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type,
    x_okl_txl_ar_inv_lns_tl_rec    OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type := p_okl_txl_ar_inv_lns_tl_rec;
    ldefokltxlarinvlnstlrec        okl_txl_ar_inv_lns_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txl_ar_inv_lns_tl_rec	IN okl_txl_ar_inv_lns_tl_rec_type,
      x_okl_txl_ar_inv_lns_tl_rec	OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ar_inv_lns_tl_rec := p_okl_txl_ar_inv_lns_tl_rec;
      -- Get current database values
      l_okl_txl_ar_inv_lns_tl_rec := get_rec(p_okl_txl_ar_inv_lns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.id := l_okl_txl_ar_inv_lns_tl_rec.id;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.LANGUAGE := l_okl_txl_ar_inv_lns_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.source_lang := l_okl_txl_ar_inv_lns_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.error_message = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.error_message := l_okl_txl_ar_inv_lns_tl_rec.error_message;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.sfwt_flag := l_okl_txl_ar_inv_lns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.description := l_okl_txl_ar_inv_lns_tl_rec.description;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.created_by := l_okl_txl_ar_inv_lns_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.creation_date := l_okl_txl_ar_inv_lns_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.last_updated_by := l_okl_txl_ar_inv_lns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.last_update_date := l_okl_txl_ar_inv_lns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_ar_inv_lns_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_ar_inv_lns_tl_rec.last_update_login := l_okl_txl_ar_inv_lns_tl_rec.last_update_login;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ar_inv_lns_tl_rec IN  okl_txl_ar_inv_lns_tl_rec_type,
      x_okl_txl_ar_inv_lns_tl_rec OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ar_inv_lns_tl_rec := p_okl_txl_ar_inv_lns_tl_rec;
      x_okl_txl_ar_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_ar_inv_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_ar_inv_lns_tl_rec,       -- IN
      l_okl_txl_ar_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_ar_inv_lns_tl_rec, ldefokltxlarinvlnstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_AR_INV_LNS_TL
    SET DESCRIPTION = ldefokltxlarinvlnstlrec.description,
        SOURCE_LANG = ldefokltxlarinvlnstlrec.source_lang,
        CREATED_BY = ldefokltxlarinvlnstlrec.created_by,
        CREATION_DATE = ldefokltxlarinvlnstlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxlarinvlnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxlarinvlnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxlarinvlnstlrec.last_update_login
    WHERE ID = ldefokltxlarinvlnstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TXL_AR_INV_LNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxlarinvlnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txl_ar_inv_lns_tl_rec := ldefokltxlarinvlnstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- update_row for:OKL_TXL_AR_INV_LNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type,
    x_tilv_rec                     OUT NOCOPY tilv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tilv_rec                     tilv_rec_type := p_tilv_rec;
    l_def_tilv_rec                 tilv_rec_type;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
    lx_okl_txl_ar_inv_lns_tl_rec   okl_txl_ar_inv_lns_tl_rec_type;
    l_til_rec                      til_rec_type;
    lx_til_rec                     til_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tilv_rec	IN tilv_rec_type
    ) RETURN tilv_rec_type IS
      l_tilv_rec	tilv_rec_type := p_tilv_rec;
    BEGIN
      l_tilv_rec.LAST_UPDATE_DATE := l_tilv_rec.CREATION_DATE;
      l_tilv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tilv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_tilv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tilv_rec	IN tilv_rec_type,
      x_tilv_rec	OUT NOCOPY tilv_rec_type
    ) RETURN VARCHAR2 IS
      l_tilv_rec                     tilv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tilv_rec := p_tilv_rec;
      -- Get current database values
      l_tilv_rec := get_rec(p_tilv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tilv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.id := l_tilv_rec.id;
      END IF;
      IF (x_tilv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.object_version_number := l_tilv_rec.object_version_number;
      END IF;
      IF (x_tilv_rec.error_message = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.error_message := l_tilv_rec.error_message;
      END IF;
      IF (x_tilv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.sfwt_flag := l_tilv_rec.sfwt_flag;
      END IF;
      IF (x_tilv_rec.kle_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.kle_id := l_tilv_rec.kle_id;
      END IF;
      IF (x_tilv_rec.tpl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.tpl_id := l_tilv_rec.tpl_id;
      END IF;
      IF (x_tilv_rec.til_id_reverses = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.til_id_reverses := l_tilv_rec.til_id_reverses;
      END IF;
      IF (x_tilv_rec.inv_receiv_line_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.inv_receiv_line_code := l_tilv_rec.inv_receiv_line_code;
      END IF;
      IF (x_tilv_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.sty_id := l_tilv_rec.sty_id;
      END IF;
      IF (x_tilv_rec.tai_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.tai_id := l_tilv_rec.tai_id;
      END IF;
      IF (x_tilv_rec.acn_id_cost = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.acn_id_cost := l_tilv_rec.acn_id_cost;
      END IF;
      IF (x_tilv_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.amount := l_tilv_rec.amount;
      END IF;
      IF (x_tilv_rec.line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.line_number := l_tilv_rec.line_number;
      END IF;
      IF (x_tilv_rec.quantity = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.quantity := l_tilv_rec.quantity;
      END IF;
      IF (x_tilv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.description := l_tilv_rec.description;
      END IF;
      IF (x_tilv_rec.receivables_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.receivables_invoice_id := l_tilv_rec.receivables_invoice_id;
      END IF;
      IF (x_tilv_rec.date_bill_period_start = Okl_Api.G_MISS_DATE)
      THEN
        x_tilv_rec.date_bill_period_start := l_tilv_rec.date_bill_period_start;
      END IF;
      IF (x_tilv_rec.amount_applied = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.amount_applied := l_tilv_rec.amount_applied;
      END IF;
      IF (x_tilv_rec.date_bill_period_end = Okl_Api.G_MISS_DATE)
      THEN
        x_tilv_rec.date_bill_period_end := l_tilv_rec.date_bill_period_end;
      END IF;
      IF (x_tilv_rec.isl_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.isl_id := l_tilv_rec.isl_id;
      END IF;
      IF (x_tilv_rec.ibt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.ibt_id := l_tilv_rec.ibt_id;
      END IF;
      IF (x_tilv_rec.LATE_CHARGE_REC_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.LATE_CHARGE_REC_ID := l_tilv_rec.LATE_CHARGE_REC_ID;
      END IF;
      IF (x_tilv_rec.CLL_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.CLL_ID := l_tilv_rec.CLL_ID;
      END IF;
-- Start changes on remarketing by fmiao on 10/18/04 --
      IF (x_tilv_rec.inventory_item_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.inventory_item_id := l_tilv_rec.inventory_item_id;
      END IF;
-- End changes on remarketing by fmiao on 10/18/04 --
      IF (x_tilv_rec.qte_line_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.qte_line_id := l_tilv_rec.qte_line_id;
      END IF;
      IF (x_tilv_rec.txs_trx_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.txs_trx_id := l_tilv_rec.txs_trx_id;
      END IF;
-- Start Bug 4673593 --
      IF (x_tilv_rec.bank_acct_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.bank_acct_id := l_tilv_rec.bank_acct_id;
      END IF;
-- End Bug 4673593 --
      IF (x_tilv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute_category := l_tilv_rec.attribute_category;
      END IF;
      IF (x_tilv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute1 := l_tilv_rec.attribute1;
      END IF;
      IF (x_tilv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute2 := l_tilv_rec.attribute2;
      END IF;
      IF (x_tilv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute3 := l_tilv_rec.attribute3;
      END IF;
      IF (x_tilv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute4 := l_tilv_rec.attribute4;
      END IF;
      IF (x_tilv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute5 := l_tilv_rec.attribute5;
      END IF;
      IF (x_tilv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute6 := l_tilv_rec.attribute6;
      END IF;
      IF (x_tilv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute7 := l_tilv_rec.attribute7;
      END IF;
      IF (x_tilv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute8 := l_tilv_rec.attribute8;
      END IF;
      IF (x_tilv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute9 := l_tilv_rec.attribute9;
      END IF;
      IF (x_tilv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute10 := l_tilv_rec.attribute10;
      END IF;
      IF (x_tilv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute11 := l_tilv_rec.attribute11;
      END IF;
      IF (x_tilv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute12 := l_tilv_rec.attribute12;
      END IF;
      IF (x_tilv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute13 := l_tilv_rec.attribute13;
      END IF;
      IF (x_tilv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute14 := l_tilv_rec.attribute14;
      END IF;
      IF (x_tilv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tilv_rec.attribute15 := l_tilv_rec.attribute15;
      END IF;
      IF (x_tilv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.request_id := l_tilv_rec.request_id;
      END IF;
      IF (x_tilv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.program_application_id := l_tilv_rec.program_application_id;
      END IF;
      IF (x_tilv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.program_id := l_tilv_rec.program_id;
      END IF;
      IF (x_tilv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tilv_rec.program_update_date := l_tilv_rec.program_update_date;
      END IF;
      IF (x_tilv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.org_id := l_tilv_rec.org_id;
      END IF;
      IF (x_tilv_rec.inventory_org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.inventory_org_id := l_tilv_rec.inventory_org_id;
      END IF;
      IF (x_tilv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.created_by := l_tilv_rec.created_by;
      END IF;
      IF (x_tilv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tilv_rec.creation_date := l_tilv_rec.creation_date;
      END IF;
      IF (x_tilv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.last_updated_by := l_tilv_rec.last_updated_by;
      END IF;
      IF (x_tilv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tilv_rec.last_update_date := l_tilv_rec.last_update_date;
      END IF;
      IF (x_tilv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.last_update_login := l_tilv_rec.last_update_login;
      END IF;

-- start: 30-Jan-07 cklee  Billing R12 project                             |
      IF (x_tilv_rec.TXL_AR_LINE_NUMBER = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.TXL_AR_LINE_NUMBER := l_tilv_rec.TXL_AR_LINE_NUMBER;
      END IF;
      IF (x_tilv_rec.TXS_TRX_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.TXS_TRX_LINE_ID := l_tilv_rec.TXS_TRX_LINE_ID;
      END IF;

-- end: 30-Jan-07 cklee  Billing R12 project                             |

      --14-May-08 sechawla 6619311
      IF (x_tilv_rec.TAX_LINE_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_tilv_rec.TAX_LINE_ID := l_tilv_rec.TAX_LINE_ID;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tilv_rec IN  tilv_rec_type,
      x_tilv_rec OUT NOCOPY tilv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tilv_rec := p_tilv_rec;
      x_tilv_rec.OBJECT_VERSION_NUMBER := NVL(x_tilv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_tilv_rec.request_id IS NULL OR x_tilv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_tilv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_tilv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_tilv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_tilv_rec.program_update_date,SYSDATE)
      INTO
        x_tilv_rec.request_id,
        x_tilv_rec.program_application_id,
        x_tilv_rec.program_id,
        x_tilv_rec.program_update_date
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
      p_tilv_rec,                        -- IN
      l_tilv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tilv_rec, l_def_tilv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tilv_rec := fill_who_columns(l_def_tilv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tilv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tilv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tilv_rec, l_okl_txl_ar_inv_lns_tl_rec);
    migrate(l_def_tilv_rec, l_til_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ar_inv_lns_tl_rec,
      lx_okl_txl_ar_inv_lns_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_ar_inv_lns_tl_rec, l_def_tilv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_til_rec,
      lx_til_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_til_rec, l_def_tilv_rec);
    x_tilv_rec := l_def_tilv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- PL/SQL TBL update_row for:TILV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type,
    x_tilv_tbl                     OUT NOCOPY tilv_tbl_type) IS

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
    IF (p_tilv_tbl.COUNT > 0) THEN
      i := p_tilv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tilv_rec                     => p_tilv_tbl(i),
          x_tilv_rec                     => x_tilv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tilv_tbl.LAST);
        i := p_tilv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -----------------------------------------
  -- delete_row for:OKL_TXL_AR_INV_LNS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_til_rec                      IN til_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_til_rec                      til_rec_type:= p_til_rec;
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
    DELETE FROM OKL_TXL_AR_INV_LNS_B
     WHERE ID = l_til_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  ------------------------------------------
  -- delete_row for:OKL_TXL_AR_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ar_inv_lns_tl_rec    IN okl_txl_ar_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type:= p_okl_txl_ar_inv_lns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AR_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ar_inv_lns_tl_rec IN  okl_txl_ar_inv_lns_tl_rec_type,
      x_okl_txl_ar_inv_lns_tl_rec OUT NOCOPY okl_txl_ar_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ar_inv_lns_tl_rec := p_okl_txl_ar_inv_lns_tl_rec;
      x_okl_txl_ar_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txl_ar_inv_lns_tl_rec,       -- IN
      l_okl_txl_ar_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_AR_INV_LNS_TL
     WHERE ID = l_okl_txl_ar_inv_lns_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- delete_row for:OKL_TXL_AR_INV_LNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_rec                     IN tilv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tilv_rec                     tilv_rec_type := p_tilv_rec;
    l_okl_txl_ar_inv_lns_tl_rec    okl_txl_ar_inv_lns_tl_rec_type;
    l_til_rec                      til_rec_type;
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
    migrate(l_tilv_rec, l_okl_txl_ar_inv_lns_tl_rec);
    migrate(l_tilv_rec, l_til_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ar_inv_lns_tl_rec
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
      l_til_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  -- PL/SQL TBL delete_row for:TILV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tilv_tbl                     IN tilv_tbl_type) IS

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
    IF (p_tilv_tbl.COUNT > 0) THEN
      i := p_tilv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tilv_rec                     => p_tilv_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_tilv_tbl.LAST);
        i := p_tilv_tbl.NEXT(i);
      END LOOP;
	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
END Okl_Til_Pvt;

/
