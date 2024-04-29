--------------------------------------------------------
--  DDL for Package Body OKL_TAI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAI_PVT" AS
/* $Header: OKLSTAIB.pls 120.16 2008/05/21 00:45:26 sechawla noship $ */

-----------Start addition, Sunil T. Mathew (04/16/2001)
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
   PROCEDURE validate_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.id = Okl_Api.G_MISS_NUM OR
       p_taiv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
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
  PROCEDURE validate_org_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_taiv_rec.org_id IS NOT NULL) THEN
		x_return_status := Okl_Util.check_org_id(p_taiv_rec.org_id);
	END IF;
  END validate_org_id;

  -- for LE Uptake project 08-11-2006
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_legal_entity_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_legal_entity_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_exists                NUMBER(1);
   item_not_found_error    EXCEPTION;
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_taiv_rec.legal_entity_id IS NOT NULL) THEN
		l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_taiv_rec.legal_entity_id);
	   IF(l_exists <> 1) THEN
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

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_amount
  ---------------------------------------------------------------------------
  PROCEDURE validate_amount (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.amount = Okl_Api.G_MISS_NUM OR
       p_taiv_rec.amount IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => 'OKC',
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'Amount');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

  END validate_amount;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_date_invoiced
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_invoiced (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.date_invoiced = Okl_Api.G_MISS_DATE OR
       p_taiv_rec.date_invoiced IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => 'OKC',
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'Invoice Date');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

  END validate_date_invoiced;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_date_entered
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_entered (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.date_entered = Okl_Api.G_MISS_DATE OR
       p_taiv_rec.date_entered IS NULL
    THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;

  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'date_entered');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

  END validate_date_entered;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_taiv_rec.object_version_number IS NULL
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
  -- PROCEDURE validate_currency_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_currency_code (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_currency_code_csr IS
    SELECT '1'
	FROM fnd_currencies
	WHERE currency_code = p_taiv_rec.currency_code;

  BEGIN
  	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check Not Null
	/* 10-SEP-2001 R.Draguilev
	   The field can be null (bug 1980827)
	   The value can be determined using contract id (khr_id) and contract rules)

	IF (p_taiv_rec.currency_code IS NULL) OR (p_taiv_rec.currency_code=Okl_Api.G_MISS_NUM) THEN
		x_return_status:=Okl_Api.G_RET_STS_ERROR;
		--set error message in message stack
		Okl_Api.SET_MESSAGE (
				p_app_name     => G_APP_NAME,
				p_msg_name     =>  G_REQUIRED_VALUE,
				p_token1       => G_COL_NAME_TOKEN,
				p_token1_value => 'CURRENCY_CODE_ID');
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
	*/

       --Check FK column
	IF (p_taiv_rec.currency_code IS NOT NULL) THEN

	   	  OPEN l_currency_code_csr;
		  FETCH l_currency_code_csr INTO l_dummy_var;
		  CLOSE l_currency_code_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(
				p_app_name	=> G_APP_NAME,
			 	p_msg_name	=> G_NO_PARENT_RECORD,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'CURRENCY_CODE_FOR',
				p_token2	=> G_CHILD_TABLE_TOKEN,
				p_token2_value	=> G_VIEW,
				p_token3	=> G_PARENT_TABLE_TOKEN,
				p_token3_value	=> 'OKL_TRX_AR_INVOICES_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;

	END IF;

  END validate_currency_code;

  --pjgome 11/18/2002 added procedure validate_curr_conv_type
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_curr_conv_type
  ---------------------------------------------------------------------------
  PROCEDURE validate_curr_conv_type (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
        --Check FK column
	IF (p_taiv_rec.currency_conversion_type IS NOT NULL) THEN
	          --uncomment out the below line of code when currency conversion lookup type is finalized
                  --l_return_status := Okl_Util.CHECK_LOOKUP_CODE(--insert the lookup type ,p_taiv_rec.currency_conversion_type);

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
  -- PROCEDURE validate_ibt_id
  ---------------------------------------------------------------------------
  /*****************************************comment out because the okx_bill_tos_v does not exist **
  PROCEDURE validate_ibt_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ibt_id_csr IS
    SELECT '1'
	FROM OKX_BILL_TOS_V
	WHERE id = p_taiv_rec.ibt_id;

  BEGIN
	x_return_status := Okl_api.G_RET_STS_SUCCESS;

	--Check not null
  */
	/* 10-SEP-2001 R.Draguilev
	   The field can be null (bug 1980827)
	   The value can be determined using contract id (khr_id) and contract rules)

	IF (p_taiv_rec.ibt_id IS NULL) OR (p_taiv_rec.ibt_id=Okl_api.G_MISS_NUM) THEN
		x_return_status:=Okl_api.G_RET_STS_ERROR;
		--set error message in message stack
		Okl_api.SET_MESSAGE (
				p_app_name     => G_APP_NAME,
				p_msg_name     =>  G_REQUIRED_VALUE,
				p_token1       => G_COL_NAME_TOKEN,
				p_token1_value => 'IBT_ID');
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
	*/
  /*
	--Check FK
	IF (p_taiv_rec.ibt_id IS NOT NULL) THEN

	   	  OPEN l_ibt_id_csr;
		  FETCH l_ibt_id_csr INTO l_dummy_var;
		  CLOSE l_ibt_id_csr;

		  IF (l_dummy_var <> '1') then
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(
				p_app_name	=> G_APP_NAME,
			 	p_msg_name	=> G_NO_PARENT_RECORD,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'IBT_ID_FOR',
				p_token2	=> G_CHILD_TABLE_TOKEN,
				p_token2_value	=> G_VIEW,
				p_token3	=> G_PARENT_TABLE_TOKEN,
				p_token3_value	=> 'OKL_TRX_AR_INVOICES_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;

	END IF;

  END validate_ibt_id;
  *********************** End Commented code *********/

 /*****************************************comment out because the okx_cstr_accts_v does not exist **
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ixx_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_ixx_id (p_taiv_rec IN taiv_rec_type,
  								   		   x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ixx_id_csr IS
    SELECT '1'
	FROM okx_cstr_accts_v
	WHERE id = p_taiv_rec.ixx_id;

  BEGIN
	x_return_status := Okl_api.G_RET_STS_SUCCESS;

	--Check not null
  */
	/* 10-SEP-2001 R.Draguilev
	   The field can be null (bug 1980827)
	   The value can be determined using contract id (khr_id) and contract rules)

	   IF (p_taiv_rec.ixx_id IS NULL) OR (p_taiv_rec.ixx_id=Okl_api.G_MISS_NUM) THEN
		x_return_status:=Okl_api.G_RET_STS_ERROR;
		--set error message in message stack
		Okl_api.SET_MESSAGE (
				p_app_name     => G_APP_NAME,
				p_msg_name     =>  G_REQUIRED_VALUE,
				p_token1       => G_COL_NAME_TOKEN,
				p_token1_value => 'IXX_ID');
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
	*/
  /*
	--Check FK
	IF (p_taiv_rec.ixx_id IS NOT NULL) THEN

	   	  OPEN l_ixx_id_csr;
		  FETCH l_ixx_id_csr INTO l_dummy_var;
		  CLOSE l_ixx_id_csr;

		  IF (l_dummy_var <> '1') then
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(
				p_app_name	=> G_APP_NAME,
			 	p_msg_name	=> G_NO_PARENT_RECORD,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'IXX_ID_FOR',
				p_token2	=> G_CHILD_TABLE_TOKEN,
				p_token2_value	=> G_VIEW,
				p_token3	=> G_PARENT_TABLE_TOKEN,
				p_token3_value	=> 'OKL_TRX_AR_INVOICES_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;

	END IF;

  END validate_ixx_id;
  *********************** End Commented code *********/

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_khr_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_khr_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_khr_id_csr IS
    SELECT '1'
	FROM OKL_K_HEADERS_V
	WHERE id = p_taiv_rec.khr_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.khr_id IS NOT NULL) THEN
	   	  OPEN l_khr_id_csr;
		  FETCH l_khr_id_csr INTO l_dummy_var;
		  CLOSE l_khr_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'KHR_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_khr_id;

  /*****************************************comment out because the okx_receipt_methods_v does not exist **
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_irm_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_irm_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_irm_id_csr IS
    SELECT '1'
	FROM okx_receipt_methods_v
	WHERE id = p_taiv_rec.irm_id;

  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.irm_id is not null) then
	   	  OPEN l_irm_id_csr;
		  FETCH l_irm_id_csr INTO l_dummy_var;
		  CLOSE l_irm_id_csr;

		  IF (l_dummy_var <> '1') then
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IRM_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_irm_id;
  *********************** End Commented code *********/

  /*****************************************comment out because the okx_receipt_methods_v does not exist **
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_irt_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_irt_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_irt_id_csr IS
    SELECT '1'
	FROM okx_ra_termses_v
	WHERE id = p_taiv_rec.irt_id;

  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.irt_id is not null) then
	   	  OPEN l_irt_id_csr;
		  FETCH l_irt_id_csr INTO l_dummy_var;
		  CLOSE l_irt_id_csr;

		  IF (l_dummy_var <> '1') then
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IRT_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_irt_id;
  *********************** End Commented code *********/

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_cra_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_cra_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_cra_id_csr IS
    SELECT '1'
	FROM dual;
       -- OKL_CURE_REP_AMTS_B
       -- WHERE id = p_taiv_rec.cra_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.cra_id IS NOT NULL) THEN
	   	  OPEN l_cra_id_csr;
		  FETCH l_cra_id_csr INTO l_dummy_var;
		  CLOSE l_cra_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'CRA_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_cra_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_svf_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_svf_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_svf_id_csr IS
    SELECT '1'
	FROM OKL_SERVICE_FEES_B
	WHERE id = p_taiv_rec.svf_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   --Check FK
	   IF (p_taiv_rec.svf_id IS NOT NULL) THEN

	   	  OPEN l_svf_id_csr;
		  FETCH l_svf_id_csr INTO l_dummy_var;
		  CLOSE l_svf_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(
				p_app_name	=> G_APP_NAME,
			 	p_msg_name	=> G_NO_PARENT_RECORD,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'SVF_ID_FOR',
				p_token2	=> G_CHILD_TABLE_TOKEN,
				p_token2_value	=> G_VIEW,
				p_token3	=> G_PARENT_TABLE_TOKEN,
				p_token3_value	=> 'OKL_TRX_AR_INVOICES_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;

	   END IF;

  END validate_svf_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tap_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_tap_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tap_id_csr IS
    SELECT '1'
	FROM OKL_TRX_AP_INVOICES_B
	WHERE id = p_taiv_rec.tap_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.tap_id IS NOT NULL) THEN
	   	  OPEN l_tap_id_csr;
		  FETCH l_tap_id_csr INTO l_dummy_var;
		  CLOSE l_tap_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TAP_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tap_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_qte_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_qte_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_qte_id_csr IS
    SELECT '1'
	FROM OKL_TRX_QUOTES_B
	WHERE id = p_taiv_rec.qte_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.qte_id IS NOT NULL) THEN
	   	  OPEN l_qte_id_csr;
		  FETCH l_qte_id_csr INTO l_dummy_var;
		  CLOSE l_qte_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'QTE_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_qte_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tcn_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_tcn_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tcn_id_csr IS
    SELECT '1'
	FROM OKL_TRX_CONTRACTS
	WHERE id = p_taiv_rec.tcn_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.tcn_id IS NOT NULL) THEN
	   	  OPEN l_tcn_id_csr;
		  FETCH l_tcn_id_csr INTO l_dummy_var;
		  CLOSE l_tcn_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TCN_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tcn_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tai_id_reverses
  ---------------------------------------------------------------------------
  PROCEDURE validate_tai_id_reverses (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_tai_id_reverses_csr IS
    SELECT '1'
	FROM OKL_TRX_AR_INVOICES_B
	WHERE id = p_taiv_rec.tai_id_reverses;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.tai_id_reverses IS NOT NULL) THEN
	   	  OPEN l_tai_id_reverses_csr;
		  FETCH l_tai_id_reverses_csr INTO l_dummy_var;
		  CLOSE l_tai_id_reverses_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TAI_ID_REVERSES_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_tai_id_reverses;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ipy_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_ipy_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ipy_id_csr IS
    SELECT '1'
	FROM OKL_INS_POLICIES_V
	WHERE id = p_taiv_rec.ipy_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.ipy_id IS NOT NULL) THEN
	   	  OPEN l_ipy_id_csr;
		  FETCH l_ipy_id_csr INTO l_dummy_var;
		  CLOSE l_ipy_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'IPY_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ipy_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_trx_status_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_trx_status_code (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	IF p_taiv_rec.trx_status_code = Okl_Api.G_MISS_CHAR OR
	   p_taiv_rec.trx_status_code IS NULL
	THEN
		x_return_status := Okl_Api.G_RET_STS_ERROR;
		--set error message in message stack
		Okl_Api.SET_MESSAGE(
			p_app_name     => G_APP_NAME,
			p_msg_name     =>  G_REQUIRED_VALUE,
			p_token1       => G_COL_NAME_TOKEN,
			p_token1_value => 'trx_status_code');
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

	x_return_status := Okl_Util.CHECK_LOOKUP_CODE('OKL_TRANSACTION_STATUS',p_taiv_rec.trx_status_code);

  END validate_trx_status_code;

  -- sjalasut: added new procedure validate_trx_number to validate that the transaction number
  -- entered on the manual bills page is unique for the operating unit
  -- sjalasut: start of code changes
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_trx_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_trx_number (p_taiv_rec IN taiv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2) IS
    -- this cursor is performant. but the requirement here is to check for a transaction number
    -- without any context. i.e. for the current operating unit
    CURSOR l_trx_number_uniq_csr is
    SELECT '1'
      FROM OKL_TRX_AR_INVOICES_V INV
     WHERE ID <> p_taiv_rec.id
       AND TRX_NUMBER IS NOT NULL
       AND TRX_NUMBER = p_taiv_rec.trx_number;

    lv_dummy_var VARCHAR2(1) DEFAULT '0';

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    IF(p_taiv_rec.trx_number IS NOT NULL )THEN
      OPEN l_trx_number_uniq_csr;
      FETCH l_trx_number_uniq_csr INTO lv_dummy_var;
      CLOSE l_trx_number_uniq_csr;
      IF(lv_dummy_var = '1')THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        --set error message in message stack
        Okl_Api.SET_MESSAGE(
          p_app_name => G_APP_NAME,
          p_msg_name => 'OKL_SIR_NOT_UNIQUE'
        );
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  END validate_trx_number;
  -- sjalasut: end of code changes


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_set_of_books_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_set_of_books_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_set_of_books_id_csr IS
    SELECT '1'
	FROM GL_LEDGERS_PUBLIC_V
	WHERE ledger_id = p_taiv_rec.set_of_books_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_taiv_rec.set_of_books_id IS NOT NULL) THEN
	   	  OPEN l_set_of_books_id_csr;
		  FETCH l_set_of_books_id_csr INTO l_dummy_var;
		  CLOSE l_set_of_books_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'SET_OF_BOOKS_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_set_of_books_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_try_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_try_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_try_id_csr IS
    SELECT '1'
	FROM OKL_TRX_TYPES_V
	WHERE id = p_taiv_rec.try_id;

  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.try_id = Okl_Api.G_MISS_NUM OR
       p_taiv_rec.try_id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'try_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;


	   IF (p_taiv_rec.try_id IS NOT NULL) THEN
	   	  OPEN l_try_id_csr;
		  FETCH l_try_id_csr INTO l_dummy_var;
		  CLOSE l_try_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'TRY_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_TRX_AR_INVOICES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_try_id;

-----------End addition, Sunil T. Mathew (04/16/2001)

  --Start code added by pgomes on 19-NOV-2002
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_pox_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_pox_id (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_pox_id_csr IS
    SELECT '1'
	FROM OKL_POOL_TRANSACTIONS
	WHERE id = p_taiv_rec.pox_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_taiv_rec.pox_id IS NOT NULL) THEN
      OPEN l_pox_id_csr;
      FETCH l_pox_id_csr INTO l_dummy_var;
      CLOSE l_pox_id_csr;

      IF (l_dummy_var <> '1') THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_PARENT_RECORD,
	                    p_token1 => G_COL_NAME_TOKEN,
                            p_token1_value => 'POX_ID_FOR',
                            p_token2 => G_CHILD_TABLE_TOKEN,
                            p_token2_value => G_VIEW,
                            p_token3 => G_PARENT_TABLE_TOKEN,
                            p_token3_value => 'OKL_POOL_TRANSACTIONS');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  END validate_pox_id;

  --End code added by pgomes on 19-NOV-2002

  --Start code added by cklee on 13-Feb-2007
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_OKL_Src_BILLING_TRX
  ---------------------------------------------------------------------------
  PROCEDURE validate_OKL_Src_BILLING_TRX (p_taiv_rec IN taiv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_OKL_SOURCE_BILLING_TRX_csr IS
    SELECT '1'
	FROM FND_LOOKUPS
	WHERE lookup_type = 'OKL_SOURCE_BILLING_TRX'
      AND lookup_code = p_taiv_rec.OKL_SOURCE_BILLING_TRX;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF p_taiv_rec.OKL_SOURCE_BILLING_TRX = Okl_Api.G_MISS_CHAR OR
       p_taiv_rec.OKL_SOURCE_BILLING_TRX IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OKL_SOURCE_BILLING_TRX');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
           	              p_msg_name     =>  G_REQUIRED_VALUE,
     				  p_token1       => G_COL_NAME_TOKEN,
	      		  p_token1_value => 'OKL_SOURCE_BILLING_TRX');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF (p_taiv_rec.OKL_SOURCE_BILLING_TRX IS NOT NULL) THEN
      OPEN l_OKL_SOURCE_BILLING_TRX_csr;
      FETCH l_OKL_SOURCE_BILLING_TRX_csr INTO l_dummy_var;
      CLOSE l_OKL_SOURCE_BILLING_TRX_csr;

      IF (l_dummy_var <> '1') THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_PARENT_RECORD,
	                    p_token1 => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKL_SOURCE_BILLING_TRX_FOR',
                            p_token2 => G_CHILD_TABLE_TOKEN,
                            p_token2_value => G_VIEW,
                            p_token3 => G_PARENT_TABLE_TOKEN,
                            p_token3_value => 'FND_LOOKUPS');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  END validate_OKL_Src_BILLING_TRX;

  --End code added by cklee on 13-Feb-2007


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
    DELETE FROM OKL_TRX_AR_INVOICES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_AR_INVOICES_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_TRX_AR_INVOICES_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TRX_AR_INVOICES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_AR_INVOICES_TL SUBB, OKL_TRX_AR_INVOICES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                      AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TRX_AR_INVOICES_TL (
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
        FROM OKL_TRX_AR_INVOICES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_AR_INVOICES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_INVOICES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tai_rec                      IN tai_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tai_rec_type IS
    CURSOR tai_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CODE,
    --Start change by pgomes on 15-NOV-2002
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 15-NOV-2002
            IBT_ID,
            IXX_ID,
            KHR_ID,
            IRM_ID,
            IRT_ID,
            CRA_ID,
            SVF_ID,
            TAP_ID,
            QTE_ID,
            TCN_ID,
            TAI_ID_REVERSES,
            DATE_ENTERED,
            DATE_INVOICED,
            AMOUNT,
            OBJECT_VERSION_NUMBER,
            AMOUNT_APPLIED,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            IPY_ID,
            SET_OF_BOOKS_ID,
            TRX_STATUS_CODE,
            TRY_ID,
			TRX_NUMBER,
			CLG_ID,
			POX_ID,
			CPY_ID,
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
            LEGAL_ENTITY_ID, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    Investor_Agreement_Number,
    Investor_Name,
    OKL_SOURCE_BILLING_TRX,
    INF_ID,
    INVOICE_PULL_YN,
    CONSOLIDATED_INVOICE_NUMBER,
    DUE_DATE,
    ISI_ID,
    RECEIVABLES_INVOICE_ID,
    CUST_TRX_TYPE_ID,
    CUSTOMER_BANK_ACCOUNT_ID,
    TAX_EXEMPT_FLAG,
    TAX_EXEMPT_REASON_CODE,
    REFERENCE_LINE_ID,
    PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
    --gkhuntet start 02-Nov-07
    TRANSACTION_DATE
     --gkhuntet end 02-Nov-07

      FROM Okl_Trx_Ar_Invoices_B
     WHERE okl_trx_ar_invoices_b.id = p_id;
    l_tai_pk                       tai_pk_csr%ROWTYPE;
    l_tai_rec                      tai_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tai_pk_csr (p_tai_rec.id);
    FETCH tai_pk_csr INTO
              l_tai_rec.ID,
              l_tai_rec.CURRENCY_CODE,
    --Start change by pgomes on 15-NOV-2002
              l_tai_rec.CURRENCY_CONVERSION_TYPE,
              l_tai_rec.CURRENCY_CONVERSION_RATE,
              l_tai_rec.CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 15-NOV-2002
              l_tai_rec.IBT_ID,
              l_tai_rec.IXX_ID,
              l_tai_rec.KHR_ID,
              l_tai_rec.IRM_ID,
              l_tai_rec.IRT_ID,
              l_tai_rec.CRA_ID,
              l_tai_rec.SVF_ID,
              l_tai_rec.TAP_ID,
              l_tai_rec.QTE_ID,
              l_tai_rec.TCN_ID,
              l_tai_rec.TAI_ID_REVERSES,
              l_tai_rec.DATE_ENTERED,
              l_tai_rec.DATE_INVOICED,
              l_tai_rec.AMOUNT,
              l_tai_rec.OBJECT_VERSION_NUMBER,
              l_tai_rec.AMOUNT_APPLIED,
              l_tai_rec.REQUEST_ID,
              l_tai_rec.PROGRAM_APPLICATION_ID,
              l_tai_rec.PROGRAM_ID,
              l_tai_rec.PROGRAM_UPDATE_DATE,
              l_tai_rec.ORG_ID,
              l_tai_rec.IPY_ID,
              l_tai_rec.SET_OF_BOOKS_ID,
              l_tai_rec.TRX_STATUS_CODE,
              l_tai_rec.TRY_ID,
			  l_tai_rec.TRX_NUMBER,
			  l_tai_rec.CLG_ID,
			  l_tai_rec.POX_ID,
			  l_tai_rec.CPY_ID,
              l_tai_rec.ATTRIBUTE_CATEGORY,
              l_tai_rec.ATTRIBUTE1,
              l_tai_rec.ATTRIBUTE2,
              l_tai_rec.ATTRIBUTE3,
              l_tai_rec.ATTRIBUTE4,
              l_tai_rec.ATTRIBUTE5,
              l_tai_rec.ATTRIBUTE6,
              l_tai_rec.ATTRIBUTE7,
              l_tai_rec.ATTRIBUTE8,
              l_tai_rec.ATTRIBUTE9,
              l_tai_rec.ATTRIBUTE10,
              l_tai_rec.ATTRIBUTE11,
              l_tai_rec.ATTRIBUTE12,
              l_tai_rec.ATTRIBUTE13,
              l_tai_rec.ATTRIBUTE14,
              l_tai_rec.ATTRIBUTE15,
              l_tai_rec.CREATED_BY,
              l_tai_rec.CREATION_DATE,
              l_tai_rec.LAST_UPDATED_BY,
              l_tai_rec.LAST_UPDATE_DATE,
              l_tai_rec.LAST_UPDATE_LOGIN,
              l_tai_rec.LEGAL_ENTITY_ID, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    l_tai_rec.Investor_Agreement_Number,
    l_tai_rec.Investor_Name,
    l_tai_rec.OKL_SOURCE_BILLING_TRX,
    l_tai_rec.INF_ID,
    l_tai_rec.INVOICE_PULL_YN,
    l_tai_rec.CONSOLIDATED_INVOICE_NUMBER,
    l_tai_rec.DUE_DATE,
    l_tai_rec.ISI_ID,
    l_tai_rec.RECEIVABLES_INVOICE_ID,
    l_tai_rec.CUST_TRX_TYPE_ID,
    l_tai_rec.CUSTOMER_BANK_ACCOUNT_ID,
    l_tai_rec.TAX_EXEMPT_FLAG,
    l_tai_rec.TAX_EXEMPT_REASON_CODE,
    l_tai_rec.REFERENCE_LINE_ID,
    l_tai_rec.PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
 --gkhuntet start 02-Nov-07
    l_tai_rec.TRANSACTION_DATE;
 --gkhuntet end 02-Nov-07
    x_no_data_found := tai_pk_csr%NOTFOUND;
    CLOSE tai_pk_csr;
    RETURN(l_tai_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tai_rec                      IN tai_rec_type
  ) RETURN tai_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tai_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_INVOICES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklTrxArInvoicesTlRecType IS
    CURSOR okl_trx_ar_invoices_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Trx_Ar_Invoices_Tl
     WHERE okl_trx_ar_invoices_tl.id = p_id
       AND okl_trx_ar_invoices_tl.LANGUAGE = p_language;
    l_okl_trx_ar_invoices_tl_pk    okl_trx_ar_invoices_tl_pk_csr%ROWTYPE;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_ar_invoices_tl_pk_csr (p_okl_trx_ar_invoices_tl_rec.id,
                                        p_okl_trx_ar_invoices_tl_rec.LANGUAGE);
    FETCH okl_trx_ar_invoices_tl_pk_csr INTO
              l_okl_trx_ar_invoices_tl_rec.ID,
              l_okl_trx_ar_invoices_tl_rec.LANGUAGE,
              l_okl_trx_ar_invoices_tl_rec.SOURCE_LANG,
              l_okl_trx_ar_invoices_tl_rec.SFWT_FLAG,
              l_okl_trx_ar_invoices_tl_rec.DESCRIPTION,
              l_okl_trx_ar_invoices_tl_rec.CREATED_BY,
              l_okl_trx_ar_invoices_tl_rec.CREATION_DATE,
              l_okl_trx_ar_invoices_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_ar_invoices_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_ar_invoices_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_ar_invoices_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_ar_invoices_tl_pk_csr;
    RETURN(l_okl_trx_ar_invoices_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType
  ) RETURN OklTrxArInvoicesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_ar_invoices_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_INVOICES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_taiv_rec                     IN taiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN taiv_rec_type IS
    CURSOR okl_taiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CURRENCY_CODE,
    --Start change by pgomes on 15-NOV-2002
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 15-NOV-2002
            KHR_ID,
            CRA_ID,
            TAP_ID,
            QTE_ID,
            TCN_ID,
            TAI_ID_REVERSES,
            IBT_ID,
            IXX_ID,
            IRM_ID,
            IRT_ID,
            SVF_ID,
            AMOUNT,
            DATE_INVOICED,
            AMOUNT_APPLIED,
            DESCRIPTION,
            IPY_ID,
            SET_OF_BOOKS_ID,
            TRX_STATUS_CODE,
            TRY_ID,
			TRX_NUMBER,
			CLG_ID,
			POX_ID,
			CPY_ID,
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
            DATE_ENTERED,
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
            LEGAL_ENTITY_ID, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    Investor_Agreement_Number,
    Investor_Name,
    OKL_SOURCE_BILLING_TRX,
    INF_ID,
    INVOICE_PULL_YN,
    CONSOLIDATED_INVOICE_NUMBER,
    DUE_DATE,
    ISI_ID,
    RECEIVABLES_INVOICE_ID,
    CUST_TRX_TYPE_ID,
    CUSTOMER_BANK_ACCOUNT_ID,
    TAX_EXEMPT_FLAG,
    TAX_EXEMPT_REASON_CODE,
    REFERENCE_LINE_ID,
    PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
 --gkhuntet start 02-Nov-07
    TRANSACTION_DATE
 --gkhuntet end 02-Nov-07
      FROM Okl_Trx_Ar_Invoices_V
     WHERE okl_trx_ar_invoices_v.id = p_id;
    l_okl_taiv_pk                  okl_taiv_pk_csr%ROWTYPE;
    l_taiv_rec                     taiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_taiv_pk_csr (p_taiv_rec.id);
    FETCH okl_taiv_pk_csr INTO
              l_taiv_rec.ID,
              l_taiv_rec.OBJECT_VERSION_NUMBER,
              l_taiv_rec.SFWT_FLAG,
              l_taiv_rec.CURRENCY_CODE,
    --Start change by pgomes on 15-NOV-2002
              l_taiv_rec.CURRENCY_CONVERSION_TYPE,
              l_taiv_rec.CURRENCY_CONVERSION_RATE,
              l_taiv_rec.CURRENCY_CONVERSION_DATE,
    --End change by pgomes on 15-NOV-2002
              l_taiv_rec.KHR_ID,
              l_taiv_rec.CRA_ID,
              l_taiv_rec.TAP_ID,
              l_taiv_rec.QTE_ID,
              l_taiv_rec.TCN_ID,
              l_taiv_rec.TAI_ID_REVERSES,
              l_taiv_rec.IBT_ID,
              l_taiv_rec.IXX_ID,
              l_taiv_rec.IRM_ID,
              l_taiv_rec.IRT_ID,
              l_taiv_rec.SVF_ID,
              l_taiv_rec.AMOUNT,
              l_taiv_rec.DATE_INVOICED,
              l_taiv_rec.AMOUNT_APPLIED,
              l_taiv_rec.DESCRIPTION,
              l_taiv_rec.IPY_ID,
              l_taiv_rec.SET_OF_BOOKS_ID,
              l_taiv_rec.TRX_STATUS_CODE,
              l_taiv_rec.TRY_ID,
			  l_taiv_rec.TRX_NUMBER,
			  l_taiv_rec.CLG_ID,
			  l_taiv_rec.POX_ID,
			  l_taiv_rec.CPY_ID,
              l_taiv_rec.ATTRIBUTE_CATEGORY,
              l_taiv_rec.ATTRIBUTE1,
              l_taiv_rec.ATTRIBUTE2,
              l_taiv_rec.ATTRIBUTE3,
              l_taiv_rec.ATTRIBUTE4,
              l_taiv_rec.ATTRIBUTE5,
              l_taiv_rec.ATTRIBUTE6,
              l_taiv_rec.ATTRIBUTE7,
              l_taiv_rec.ATTRIBUTE8,
              l_taiv_rec.ATTRIBUTE9,
              l_taiv_rec.ATTRIBUTE10,
              l_taiv_rec.ATTRIBUTE11,
              l_taiv_rec.ATTRIBUTE12,
              l_taiv_rec.ATTRIBUTE13,
              l_taiv_rec.ATTRIBUTE14,
              l_taiv_rec.ATTRIBUTE15,
              l_taiv_rec.DATE_ENTERED,
              l_taiv_rec.REQUEST_ID,
              l_taiv_rec.PROGRAM_APPLICATION_ID,
              l_taiv_rec.PROGRAM_ID,
              l_taiv_rec.PROGRAM_UPDATE_DATE,
              l_taiv_rec.ORG_ID,
              l_taiv_rec.CREATED_BY,
              l_taiv_rec.CREATION_DATE,
              l_taiv_rec.LAST_UPDATED_BY,
              l_taiv_rec.LAST_UPDATE_DATE,
              l_taiv_rec.LAST_UPDATE_LOGIN,
              l_taiv_rec.LEGAL_ENTITY_ID, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    l_taiv_rec.Investor_Agreement_Number,
    l_taiv_rec.Investor_Name,
    l_taiv_rec.OKL_SOURCE_BILLING_TRX,
    l_taiv_rec.INF_ID,
    l_taiv_rec.INVOICE_PULL_YN,
    l_taiv_rec.CONSOLIDATED_INVOICE_NUMBER,
    l_taiv_rec.DUE_DATE,
    l_taiv_rec.ISI_ID,
    l_taiv_rec.RECEIVABLES_INVOICE_ID,
    l_taiv_rec.CUST_TRX_TYPE_ID,
    l_taiv_rec.CUSTOMER_BANK_ACCOUNT_ID,
    l_taiv_rec.TAX_EXEMPT_FLAG,
    l_taiv_rec.TAX_EXEMPT_REASON_CODE,
    l_taiv_rec.REFERENCE_LINE_ID,
    l_taiv_rec.PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
 --gkhuntet start 02-Nov-07
    l_taiv_rec.TRANSACTION_DATE;
 --gkhuntet end 02-Nov-07;

    x_no_data_found := okl_taiv_pk_csr%NOTFOUND;
    CLOSE okl_taiv_pk_csr;
    RETURN(l_taiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_taiv_rec                     IN taiv_rec_type
  ) RETURN taiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_taiv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_AR_INVOICES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_taiv_rec	IN taiv_rec_type
  ) RETURN taiv_rec_type IS
    l_taiv_rec	taiv_rec_type := p_taiv_rec;
  BEGIN
    IF (l_taiv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.object_version_number := NULL;
    END IF;
    IF (l_taiv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_taiv_rec.currency_code = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.currency_code := NULL;
    END IF;

    --Start change by pgomes on 15-NOV-2002
    IF (l_taiv_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.currency_conversion_type := NULL;
    END IF;

    IF (l_taiv_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.currency_conversion_rate := NULL;
    END IF;

    IF (l_taiv_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.currency_conversion_date := NULL;
    END IF;
    --End change by pgomes on 15-NOV-2002

    IF (l_taiv_rec.khr_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.khr_id := NULL;
    END IF;
    IF (l_taiv_rec.cra_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.cra_id := NULL;
    END IF;
    IF (l_taiv_rec.tap_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.tap_id := NULL;
    END IF;
    IF (l_taiv_rec.qte_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.qte_id := NULL;
    END IF;
    IF (l_taiv_rec.tcn_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.tcn_id := NULL;
    END IF;
    IF (l_taiv_rec.tai_id_reverses = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.tai_id_reverses := NULL;
    END IF;
    IF (l_taiv_rec.ibt_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.ibt_id := NULL;
    END IF;
    IF (l_taiv_rec.ixx_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.ixx_id := NULL;
    END IF;
    IF (l_taiv_rec.irm_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.irm_id := NULL;
    END IF;
    IF (l_taiv_rec.irt_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.irt_id := NULL;
    END IF;
    IF (l_taiv_rec.svf_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.svf_id := NULL;
    END IF;
    IF (l_taiv_rec.amount = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.amount := NULL;
    END IF;
    IF (l_taiv_rec.date_invoiced = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.date_invoiced := NULL;
    END IF;
    IF (l_taiv_rec.amount_applied = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.amount_applied := NULL;
    END IF;
    IF (l_taiv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.description := NULL;
    END IF;

    IF (l_taiv_rec.trx_number = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.trx_number := NULL;
    END IF;
    IF (l_taiv_rec.clg_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.clg_id := NULL;
    END IF;

    --Start code added by pgomes on 19-NOV-2002
    IF (l_taiv_rec.pox_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.pox_id := NULL;
    END IF;
    --End code added by pgomes on 19-NOV-2002

    IF (l_taiv_rec.cpy_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.cpy_id := NULL;
    END IF;
    IF (l_taiv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute_category := NULL;
    END IF;
    IF (l_taiv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute1 := NULL;
    END IF;
    IF (l_taiv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute2 := NULL;
    END IF;
    IF (l_taiv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute3 := NULL;
    END IF;
    IF (l_taiv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute4 := NULL;
    END IF;
    IF (l_taiv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute5 := NULL;
    END IF;
    IF (l_taiv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute6 := NULL;
    END IF;
    IF (l_taiv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute7 := NULL;
    END IF;
    IF (l_taiv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute8 := NULL;
    END IF;
    IF (l_taiv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute9 := NULL;
    END IF;
    IF (l_taiv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute10 := NULL;
    END IF;
    IF (l_taiv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute11 := NULL;
    END IF;
    IF (l_taiv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute12 := NULL;
    END IF;
    IF (l_taiv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute13 := NULL;
    END IF;
    IF (l_taiv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute14 := NULL;
    END IF;
    IF (l_taiv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.attribute15 := NULL;
    END IF;
    IF (l_taiv_rec.date_entered = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.date_entered := NULL;
    END IF;
    IF (l_taiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.request_id := NULL;
    END IF;
    IF (l_taiv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.program_application_id := NULL;
    END IF;
    IF (l_taiv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.program_id := NULL;
    END IF;
    IF (l_taiv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.program_update_date := NULL;
    END IF;
    IF (l_taiv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.org_id := NULL;
    END IF;
    IF (l_taiv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.created_by := NULL;
    END IF;
    IF (l_taiv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.creation_date := NULL;
    END IF;
    IF (l_taiv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_taiv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.last_update_date := NULL;
    END IF;
    IF (l_taiv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.last_update_login := NULL;
    END IF;
    IF (l_taiv_rec.TRX_STATUS_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.TRX_STATUS_CODE := NULL;
    END IF;
    IF (l_taiv_rec.IPY_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.IPY_ID := NULL;
    END IF;
    IF (l_taiv_rec.SET_OF_BOOKS_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.SET_OF_BOOKS_ID := NULL;
    END IF;
    IF (l_taiv_rec.TRY_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.TRY_ID := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006
    IF (l_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.legal_entity_id := NULL;
    END IF;
    -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
--    Investor_Agreement_Number,
    IF (l_taiv_rec.Investor_Agreement_Number = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.Investor_Agreement_Number := NULL;
    END IF;
--    Investor_Name,
    IF (l_taiv_rec.Investor_Name = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.Investor_Name := NULL;
    END IF;

--    OKL_SOURCE_BILLING_TRX,
    IF (l_taiv_rec.OKL_SOURCE_BILLING_TRX = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.OKL_SOURCE_BILLING_TRX := NULL;
    END IF;

--    INF_ID,
    IF (l_taiv_rec.INF_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.INF_ID := NULL;
    END IF;

--    INVOICE_PULL_YN,
    IF (l_taiv_rec.INVOICE_PULL_YN = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.INVOICE_PULL_YN := NULL;
    END IF;

--    CONSOLIDATED_INVOICE_NUMBER,
    IF (l_taiv_rec.CONSOLIDATED_INVOICE_NUMBER = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.CONSOLIDATED_INVOICE_NUMBER := NULL;
    END IF;

--    DUE_DATE,
    IF (l_taiv_rec.DUE_DATE = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec.DUE_DATE := NULL;
    END IF;

--    ISI_ID,
    IF (l_taiv_rec.ISI_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.ISI_ID := NULL;
    END IF;

--    RECEIVABLES_INVOICE_ID,
    IF (l_taiv_rec.RECEIVABLES_INVOICE_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.RECEIVABLES_INVOICE_ID := NULL;
    END IF;

--    CUST_TRX_TYPE_ID,
    IF (l_taiv_rec.CUST_TRX_TYPE_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.CUST_TRX_TYPE_ID := NULL;
    END IF;

--    CUSTOMER_BANK_ACCOUNT_ID,
    IF (l_taiv_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.CUSTOMER_BANK_ACCOUNT_ID := NULL;
    END IF;

--    TAX_EXEMPT_FLAG,
    IF (l_taiv_rec.TAX_EXEMPT_FLAG = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.TAX_EXEMPT_FLAG := NULL;
    END IF;

--    TAX_EXEMPT_REASON_CODE,
    IF (l_taiv_rec.TAX_EXEMPT_REASON_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.TAX_EXEMPT_REASON_CODE := NULL;
    END IF;

--  REFERENCE_LINE_ID
    IF (l_taiv_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      l_taiv_rec.REFERENCE_LINE_ID := NULL;
    END IF;

--  PRIVATE_LABEL
    IF (l_taiv_rec.PRIVATE_LABEL = Okl_Api.G_MISS_CHAR) THEN
      l_taiv_rec.PRIVATE_LABEL := NULL;
    END IF;

-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
IF (l_taiv_rec. TRANSACTION_DATE  = Okl_Api.G_MISS_DATE) THEN
      l_taiv_rec. TRANSACTION_DATE  := NULL;
    END IF;
--gkhuntet end 02-Nov-07
    RETURN(l_taiv_rec);
  END null_out_defaults;

-- 4916724
------------------------------------
--  FUNCTION get_unique_trx_number
--------------------------------------

  FUNCTION get_unique_trx_number (
    p_rec_id IN NUMBER
  ) RETURN VARCHAR2 IS
   l_counter         NUMBER :=0;
   l_new_trx_number VARCHAR2(240);
   l_rec_exist VARCHAR2(1) DEFAULT '0';

   CURSOR l_trx_number_uniq_csr(p_trx_number varchar2) is
    SELECT '1'
      FROM OKL_TRX_AR_INVOICES_B INV
     WHERE ID <> p_rec_id
       AND TRX_NUMBER IS NOT NULL
       AND TRX_NUMBER = p_trx_number;

  BEGIN
    IF  p_rec_id IS NOT NULL THEN
     --Counter to get minimum of last six character
      l_counter:=6;
      LOOP
        -- if the length are same then assign the rec id in the transaction number
        if  l_counter>=length(to_char(p_rec_id)) then
            l_new_trx_number:=p_rec_id;
            EXIT;
        end if;

       l_new_trx_number := SUBSTR(TO_CHAR(p_rec_id),-l_counter);
       --check whether the transaction number exisit
       OPEN l_trx_number_uniq_csr(l_new_trx_number);
       FETCH l_trx_number_uniq_csr INTO l_rec_exist;
       CLOSE l_trx_number_uniq_csr;
       IF(l_rec_exist = '1')THEN
          --increment the counter to fetch one more character from the last
          l_counter:=l_counter+1;
          --reset the variable
          l_rec_exist:='0';
       ELSE
           --found the unique transaction number so exit from the loop
           EXIT;
       END IF;
      END LOOP;
    END IF;
   RETURN (l_new_trx_number);

  END get_unique_trx_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_AR_INVOICES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_taiv_rec IN  taiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Added 04/16/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
      -- Start Code , Sunil T. Mathew (04/16/2001)

	validate_currency_code(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    --Start code added by pgomes on 15-NOV-2002
    validate_curr_conv_type(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    --End code added by pgomes on 15-NOV-2002

    --validate_ibt_id(p_taiv_rec, x_return_status);
    --IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
     -- IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
       -- l_return_status := x_return_status;
       -- RAISE G_EXCEPTION_HALT_VALIDATION;
      --ELSE
        --l_return_status := x_return_status;   -- record that there was an error
      --END IF;
    --END IF;

    --validate_ixx_id(p_taiv_rec, x_return_status);
    --IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
      --IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        --l_return_status := x_return_status;
        --RAISE G_EXCEPTION_HALT_VALIDATION;
      --ELSE
        --l_return_status := x_return_status;   -- record that there was an error
      --END IF;
    --END IF;


    validate_khr_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


--    validate_irm_id(p_taiv_rec, x_return_status);
--    IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
--      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
--        l_return_status := x_return_status;
--        RAISE G_EXCEPTION_HALT_VALIDATION;
--      ELSE
--        l_return_status := x_return_status;   -- record that there was an error
--      END IF;
--    END IF;

--    validate_irt_id(p_taiv_rec, x_return_status);
--    IF (x_return_status <> Okl_api.G_RET_STS_SUCCESS) THEN
--      IF (x_return_status = Okl_api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
--        l_return_status := x_return_status;
--        RAISE G_EXCEPTION_HALT_VALIDATION;
--      ELSE
--        l_return_status := x_return_status;   -- record that there was an error
--      END IF;
--    END IF;

    validate_cra_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_svf_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_tap_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_qte_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_tcn_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_tai_id_reverses(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_ipy_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_trx_status_code(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_set_of_books_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_try_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    --Start code added by pgomes on 19-NOV-2002
    validate_pox_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    --End code added by pgomes on 19-NOV-2002

    --Start code added by cklee on 13-FEB-2007
    validate_OKL_Src_BILLING_TRX(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    --End code added by cklee on 13-FEB-2007

    validate_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_amount(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_date_invoiced(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_date_entered(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

-- for LE Uptake project 08-11-2006
IF (p_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM OR (p_taiv_rec.legal_entity_id IS NULL))
THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
-- Raise error

ELSE
    	validate_legal_entity_id(p_taiv_rec, x_return_status);
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

    -- End Code , Sunil T. Mathew (04/16/2001)

    -- sjalasut: added new procedure validate_trx_number to ensure that the trx_number is uniq in the
    -- current operating unit. per bug 4057822
    -- sjalasut: start of code changes
    validate_trx_number(p_taiv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
    -- sjalasut: end of code changes

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_TRX_AR_INVOICES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_taiv_rec IN taiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN taiv_rec_type,
    p_to	IN OUT NOCOPY tai_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;

    --Start change by pgomes on 15-NOV-2002
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    --End change by pgomes on 15-NOV-2002

    p_to.ibt_id := p_from.ibt_id;
    p_to.ixx_id := p_from.ixx_id;
    p_to.khr_id := p_from.khr_id;
    p_to.irm_id := p_from.irm_id;
    p_to.irt_id := p_from.irt_id;
    p_to.cra_id := p_from.cra_id;
    p_to.svf_id := p_from.svf_id;
    p_to.tap_id := p_from.tap_id;
    p_to.qte_id := p_from.qte_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.tai_id_reverses := p_from.tai_id_reverses;
    p_to.date_entered := p_from.date_entered;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount_applied := p_from.amount_applied;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.IPY_ID := p_from.IPY_ID;
    p_to.SET_OF_BOOKS_ID := p_from.SET_OF_BOOKS_ID;
    p_to.TRX_STATUS_CODE := p_from.TRX_STATUS_CODE;
    p_to.TRY_ID := p_from.TRY_ID;
    p_to.TRX_NUMBER := p_from.TRX_NUMBER;
    p_to.CLG_ID := p_from.CLG_ID;
    p_to.POX_ID := p_from.POX_ID;
    p_to.CPY_ID := p_from.CPY_ID;
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

-- start:30-Jan-07 cklee  Billing R12 project
p_to.Investor_Agreement_Number := p_from.Investor_Agreement_Number;
p_to.Investor_Name := p_from.Investor_Name;
p_to.OKL_SOURCE_BILLING_TRX := p_from.OKL_SOURCE_BILLING_TRX;
p_to.INF_ID := p_from.INF_ID;
p_to.INVOICE_PULL_YN := p_from.INVOICE_PULL_YN;
p_to.CONSOLIDATED_INVOICE_NUMBER := p_from.CONSOLIDATED_INVOICE_NUMBER;
p_to.DUE_DATE := p_from.DUE_DATE;
p_to.ISI_ID := p_from.ISI_ID;
p_to.RECEIVABLES_INVOICE_ID := p_from.RECEIVABLES_INVOICE_ID;
p_to.CUST_TRX_TYPE_ID := p_from.CUST_TRX_TYPE_ID;
p_to.CUSTOMER_BANK_ACCOUNT_ID := p_from.CUSTOMER_BANK_ACCOUNT_ID;
p_to.TAX_EXEMPT_FLAG := p_from.TAX_EXEMPT_FLAG;
p_to.TAX_EXEMPT_REASON_CODE := p_from.TAX_EXEMPT_REASON_CODE;
p_to.REFERENCE_LINE_ID := p_from.REFERENCE_LINE_ID;
p_to.PRIVATE_LABEL := p_from.PRIVATE_LABEL;

-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
p_to.TRANSACTION_DATE  := p_from.TRANSACTION_DATE ;
--gkhuntet end 02-Nov-07
  END migrate;

  PROCEDURE migrate (
    p_from	IN tai_rec_type,
    p_to	IN OUT NOCOPY taiv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;

    --Start change by pgomes on 15-NOV-2002
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    --End change by pgomes on 15-NOV-2002

    p_to.ibt_id := p_from.ibt_id;
    p_to.ixx_id := p_from.ixx_id;
    p_to.khr_id := p_from.khr_id;
    p_to.irm_id := p_from.irm_id;
    p_to.irt_id := p_from.irt_id;
    p_to.cra_id := p_from.cra_id;
    p_to.svf_id := p_from.svf_id;
    p_to.tap_id := p_from.tap_id;
    p_to.qte_id := p_from.qte_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.tai_id_reverses := p_from.tai_id_reverses;
    p_to.date_entered := p_from.date_entered;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount_applied := p_from.amount_applied;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.IPY_ID := p_from.IPY_ID;
    p_to.SET_OF_BOOKS_ID := p_from.SET_OF_BOOKS_ID;
    p_to.TRX_STATUS_CODE := p_from.TRX_STATUS_CODE;
    p_to.TRY_ID := p_from.TRY_ID;
    p_to.TRX_NUMBER := p_from.TRX_NUMBER;
    p_to.CLG_ID := p_from.CLG_ID;
    p_to.POX_ID := p_from.POX_ID;
    p_to.CPY_ID := p_from.CPY_ID;
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

-- start:30-Jan-07 cklee  Billing R12 project
p_to.Investor_Agreement_Number := p_from.Investor_Agreement_Number;
p_to.Investor_Name := p_from.Investor_Name;
p_to.OKL_SOURCE_BILLING_TRX := p_from.OKL_SOURCE_BILLING_TRX;
p_to.INF_ID := p_from.INF_ID;
p_to.INVOICE_PULL_YN := p_from.INVOICE_PULL_YN;
p_to.CONSOLIDATED_INVOICE_NUMBER := p_from.CONSOLIDATED_INVOICE_NUMBER;
p_to.DUE_DATE := p_from.DUE_DATE;
p_to.ISI_ID := p_from.ISI_ID;
p_to.RECEIVABLES_INVOICE_ID := p_from.RECEIVABLES_INVOICE_ID;
p_to.CUST_TRX_TYPE_ID := p_from.CUST_TRX_TYPE_ID;
p_to.CUSTOMER_BANK_ACCOUNT_ID := p_from.CUSTOMER_BANK_ACCOUNT_ID;
p_to.TAX_EXEMPT_FLAG := p_from.TAX_EXEMPT_FLAG;
p_to.TAX_EXEMPT_REASON_CODE := p_from.TAX_EXEMPT_REASON_CODE;
p_to.REFERENCE_LINE_ID := p_from.REFERENCE_LINE_ID;
p_to.PRIVATE_LABEL := p_from.PRIVATE_LABEL;

-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
p_to.TRANSACTION_DATE  := p_from.TRANSACTION_DATE ;
--gkhuntet end 02-Nov-07
  END migrate;

  PROCEDURE migrate (
    p_from	IN taiv_rec_type,
    p_to	IN OUT NOCOPY OklTrxArInvoicesTlRecType
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
    p_from	IN OklTrxArInvoicesTlRecType,
    p_to	IN OUT NOCOPY taiv_rec_type
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
  -- validate_row for:OKL_TRX_AR_INVOICES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_taiv_rec                     taiv_rec_type := p_taiv_rec;
    l_tai_rec                      tai_rec_type;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
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
    l_return_status := Validate_Attributes(l_taiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_taiv_rec);
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
  -- PL/SQL TBL validate_row for:TAIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type) IS

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
    IF (p_taiv_tbl.COUNT > 0) THEN
      i := p_taiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taiv_rec                     => p_taiv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_taiv_tbl.LAST);
        i := p_taiv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_AR_INVOICES_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tai_rec                      IN tai_rec_type,
    x_tai_rec                      OUT NOCOPY tai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tai_rec                      tai_rec_type := p_tai_rec;
    l_def_tai_rec                  tai_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tai_rec IN  tai_rec_type,
      x_tai_rec OUT NOCOPY tai_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tai_rec := p_tai_rec;
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

    --gkhuntet start 02-Nov-07
    IF(l_tai_rec.TRANSACTION_DATE IS NULL OR  l_tai_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE)
    THEN
        l_tai_rec.TRANSACTION_DATE := SYSDATE;
    END IF;
    --gkhuntet end 02-Nov-07

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tai_rec,                         -- IN
      l_tai_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_TRX_AR_INVOICES_B(
        id,
        currency_code,
    --Start change by pgomes on 15-NOV-2002
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
    --End change by pgomes on 15-NOV-2002
        ibt_id,
        ixx_id,
        khr_id,
        irm_id,
        irt_id,
        cra_id,
        svf_id,
        tap_id,
        qte_id,
        tcn_id,
        tai_id_reverses,
	ipy_id,          -- Added after postgen trx_type removal
	trx_status_code, -- Added after postgen trx_type removal
	set_of_books_id, -- Added after postgen trx_type removal
	try_id,          -- Added after postgen trx_type removal
        date_entered,
        date_invoiced,
        amount,
        object_version_number,
        amount_applied,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
	TRX_NUMBER,
	CLG_ID,
	POX_ID,
	CPY_ID,
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
        legal_entity_id,-- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
Investor_Agreement_Number,
Investor_Name,
OKL_SOURCE_BILLING_TRX,
INF_ID,
INVOICE_PULL_YN,
CONSOLIDATED_INVOICE_NUMBER,
DUE_DATE,
ISI_ID,
RECEIVABLES_INVOICE_ID,
CUST_TRX_TYPE_ID,
CUSTOMER_BANK_ACCOUNT_ID,
TAX_EXEMPT_FLAG,
TAX_EXEMPT_REASON_CODE,
REFERENCE_LINE_ID,
PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
  --gkhuntet start 02-Nov-07
	TRANSACTION_DATE
   --gkhuntet end 02-Nov-07
)

      VALUES (
        l_tai_rec.id,
        l_tai_rec.currency_code,
    --Start change by pgomes on 15-NOV-2002
        l_tai_rec.currency_conversion_type,
        l_tai_rec.currency_conversion_rate,
        l_tai_rec.currency_conversion_date,
    --End change by pgomes on 15-NOV-2002
        l_tai_rec.ibt_id,
        l_tai_rec.ixx_id,
        l_tai_rec.khr_id,
        l_tai_rec.irm_id,
        l_tai_rec.irt_id,
        l_tai_rec.cra_id,
        l_tai_rec.svf_id,
        l_tai_rec.tap_id,
        l_tai_rec.qte_id,
        l_tai_rec.tcn_id,
        l_tai_rec.tai_id_reverses,
	l_tai_rec.ipy_id,          -- Added after postgen trx_type removal
	l_tai_rec.trx_status_code, -- Added after postgen trx_type removal
	l_tai_rec.set_of_books_id, -- Added after postgen trx_type removal
	l_tai_rec.try_id,          -- Added after postgen trx_type removal
        l_tai_rec.date_entered,
        l_tai_rec.date_invoiced,
        l_tai_rec.amount,
        l_tai_rec.object_version_number,
        l_tai_rec.amount_applied,
        l_tai_rec.request_id,
        l_tai_rec.program_application_id,
        l_tai_rec.program_id,
        l_tai_rec.program_update_date,
        l_tai_rec.org_id,
	l_tai_rec.TRX_NUMBER,
	l_tai_rec.CLG_ID,
	l_tai_rec.POX_ID,
	l_tai_rec.CPY_ID,
        l_tai_rec.attribute_category,
        l_tai_rec.attribute1,
        l_tai_rec.attribute2,
        l_tai_rec.attribute3,
        l_tai_rec.attribute4,
        l_tai_rec.attribute5,
        l_tai_rec.attribute6,
        l_tai_rec.attribute7,
        l_tai_rec.attribute8,
        l_tai_rec.attribute9,
        l_tai_rec.attribute10,
        l_tai_rec.attribute11,
        l_tai_rec.attribute12,
        l_tai_rec.attribute13,
        l_tai_rec.attribute14,
        l_tai_rec.attribute15,
        l_tai_rec.created_by,
        l_tai_rec.creation_date,
        l_tai_rec.last_updated_by,
        l_tai_rec.last_update_date,
        l_tai_rec.last_update_login,
        l_tai_rec.legal_entity_id, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    l_tai_rec.Investor_Agreement_Number,
    l_tai_rec.Investor_Name,
    l_tai_rec.OKL_SOURCE_BILLING_TRX,
    l_tai_rec.INF_ID,
    l_tai_rec.INVOICE_PULL_YN,
    l_tai_rec.CONSOLIDATED_INVOICE_NUMBER,
    l_tai_rec.DUE_DATE,
    l_tai_rec.ISI_ID,
    l_tai_rec.RECEIVABLES_INVOICE_ID,
    l_tai_rec.CUST_TRX_TYPE_ID,
    l_tai_rec.CUSTOMER_BANK_ACCOUNT_ID,
    l_tai_rec.TAX_EXEMPT_FLAG,
    l_tai_rec.TAX_EXEMPT_REASON_CODE,
    l_tai_rec.REFERENCE_LINE_ID,
    l_tai_rec.PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
    l_tai_rec.TRANSACTION_DATE
   --gkhuntet end 02-Nov-07
);


    -- Set OUT values
    x_tai_rec := l_tai_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
		 x_return_status := 'E';
	  /*
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
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
		 x_return_status := 'U';
	  /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
		 x_return_status := 'U';
	/*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -------------------------------------------
  -- insert_row for:OKL_TRX_AR_INVOICES_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType,
    x_okl_trx_ar_invoices_tl_rec   OUT NOCOPY OklTrxArInvoicesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType := p_okl_trx_ar_invoices_tl_rec;
    ldefokltrxarinvoicestlrec      OklTrxArInvoicesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_invoices_tl_rec IN  OklTrxArInvoicesTlRecType,
      x_okl_trx_ar_invoices_tl_rec OUT NOCOPY OklTrxArInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_invoices_tl_rec := p_okl_trx_ar_invoices_tl_rec;
      x_okl_trx_ar_invoices_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ar_invoices_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_ar_invoices_tl_rec,      -- IN
      l_okl_trx_ar_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_ar_invoices_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_AR_INVOICES_TL(
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
          l_okl_trx_ar_invoices_tl_rec.id,
          l_okl_trx_ar_invoices_tl_rec.LANGUAGE,
          l_okl_trx_ar_invoices_tl_rec.source_lang,
          l_okl_trx_ar_invoices_tl_rec.sfwt_flag,
          l_okl_trx_ar_invoices_tl_rec.description,
          l_okl_trx_ar_invoices_tl_rec.created_by,
          l_okl_trx_ar_invoices_tl_rec.creation_date,
          l_okl_trx_ar_invoices_tl_rec.last_updated_by,
          l_okl_trx_ar_invoices_tl_rec.last_update_date,
          l_okl_trx_ar_invoices_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_ar_invoices_tl_rec := l_okl_trx_ar_invoices_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_AR_INVOICES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type,
    x_taiv_rec                     OUT NOCOPY taiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_taiv_rec                     taiv_rec_type;
    l_def_taiv_rec                 taiv_rec_type;
    l_tai_rec                      tai_rec_type;
    lx_tai_rec                     tai_rec_type;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
    lx_okl_trx_ar_invoices_tl_rec  OklTrxArInvoicesTlRecType;
    l_legal_entity_id              OKL_TRX_AR_INVOICES_V.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taiv_rec	IN taiv_rec_type
    ) RETURN taiv_rec_type IS
      l_taiv_rec	taiv_rec_type := p_taiv_rec;
    BEGIN
      l_taiv_rec.CREATION_DATE := SYSDATE;
      l_taiv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_taiv_rec.LAST_UPDATE_DATE := l_taiv_rec.CREATION_DATE;
      l_taiv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_taiv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_taiv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_taiv_rec IN  taiv_rec_type,
      x_taiv_rec OUT NOCOPY taiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taiv_rec := p_taiv_rec;
      x_taiv_rec.OBJECT_VERSION_NUMBER := 1;
      x_taiv_rec.SFWT_FLAG := 'N';

	IF (x_taiv_rec.request_id IS NULL OR x_taiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_taiv_rec.request_id,
	  	   x_taiv_rec.program_application_id,
	  	   x_taiv_rec.program_id,
	  	   x_taiv_rec.program_update_date
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
    l_taiv_rec := null_out_defaults(p_taiv_rec);
    -- Set primary key value
    l_taiv_rec.ID := get_seq_id;

	-- This is to support the screen
	IF l_taiv_rec.TRX_NUMBER IS NULL THEN
	    --Bug: 4916724 :call function to get unique trx numbe
	    --l_taiv_rec.TRX_NUMBER := SUBSTR(TO_CHAR(l_taiv_rec.ID),-6);
	     l_taiv_rec.TRX_NUMBER := get_unique_trx_number(l_taiv_rec.ID);
	END IF;
    -- for LE Uptake project 08-11-2006
    IF ( l_taiv_rec.legal_entity_id IS NULL OR (l_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM))
      THEN
         l_legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_taiv_rec.khr_id);
	 IF  l_legal_entity_id IS NULL THEN
	 Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1       =>  'CONTRACT_ID',
			     p_token1_value =>  l_taiv_rec.khr_id);
         RAISE OKL_API.G_EXCEPTION_ERROR;
	 ELSE
         l_taiv_rec.legal_entity_id := l_legal_entity_id;
	 END IF;
    END IF;

 --gkhuntet start 02-Nov-07
    IF(l_taiv_rec.TRANSACTION_DATE IS NULL OR  l_taiv_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE)
    THEN
        l_taiv_rec.TRANSACTION_DATE := SYSDATE;
    END IF;
 --gkhuntet end 02-Nov-07

    -- for LE Uptake project 08-11-2006

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_taiv_rec,                        -- IN
      l_def_taiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_taiv_rec := fill_who_columns(l_def_taiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_taiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_taiv_rec, l_tai_rec);
    migrate(l_def_taiv_rec, l_okl_trx_ar_invoices_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tai_rec,
      lx_tai_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tai_rec, l_def_taiv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_invoices_tl_rec,
      lx_okl_trx_ar_invoices_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ar_invoices_tl_rec, l_def_taiv_rec);
    -- Set OUT values
    x_taiv_rec := l_def_taiv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
	/*
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
	  */
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
	  /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
	  */
    WHEN OTHERS THEN
      x_return_status := 'U';
	  /*
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TAIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type,
    x_taiv_tbl                     OUT NOCOPY taiv_tbl_type) IS

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
    IF (p_taiv_tbl.COUNT > 0) THEN
      i := p_taiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taiv_rec                     => p_taiv_tbl(i),
          x_taiv_rec                     => x_taiv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_taiv_tbl.LAST);
        i := p_taiv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_AR_INVOICES_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tai_rec                      IN tai_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tai_rec IN tai_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AR_INVOICES_B
     WHERE ID = p_tai_rec.id
       AND OBJECT_VERSION_NUMBER = p_tai_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tai_rec IN tai_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AR_INVOICES_B
    WHERE ID = p_tai_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_AR_INVOICES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_AR_INVOICES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tai_rec);
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
      OPEN lchk_csr(p_tai_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tai_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tai_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_TRX_AR_INVOICES_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_ar_invoices_tl_rec IN OklTrxArInvoicesTlRecType) IS
    SELECT *
      FROM OKL_TRX_AR_INVOICES_TL
     WHERE ID = p_okl_trx_ar_invoices_tl_rec.id
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
      OPEN lock_csr(p_okl_trx_ar_invoices_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_AR_INVOICES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tai_rec                      tai_rec_type;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
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
    migrate(p_taiv_rec, l_tai_rec);
    migrate(p_taiv_rec, l_okl_trx_ar_invoices_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tai_rec
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
      l_okl_trx_ar_invoices_tl_rec
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
  -- PL/SQL TBL lock_row for:TAIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type) IS

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
    IF (p_taiv_tbl.COUNT > 0) THEN
      i := p_taiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taiv_rec                     => p_taiv_tbl(i));

	    -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_taiv_tbl.LAST);
        i := p_taiv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKL_TRX_AR_INVOICES_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tai_rec                      IN tai_rec_type,
    x_tai_rec                      OUT NOCOPY tai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tai_rec                      tai_rec_type := p_tai_rec;
    l_def_tai_rec                  tai_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_legal_entity_id              OKL_TRX_AR_INVOICES_B.LEGAL_ENTITY_ID%TYPE;  -- for LE Uptake project 08-11-2006
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tai_rec	IN tai_rec_type,
      x_tai_rec	OUT NOCOPY tai_rec_type
    ) RETURN VARCHAR2 IS
      l_tai_rec                      tai_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tai_rec := p_tai_rec;
      -- Get current database values
      l_tai_rec := get_rec(p_tai_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tai_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.id := l_tai_rec.id;
      END IF;

      IF (x_tai_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.currency_code := l_tai_rec.currency_code;
      END IF;

      --Start change by pgomes on 15-NOV-2002
      IF (x_tai_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
        x_tai_rec.currency_conversion_type := l_tai_rec.currency_conversion_type;
      END IF;

      IF (x_tai_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
        x_tai_rec.currency_conversion_rate := l_tai_rec.currency_conversion_rate;
      END IF;

      IF (x_tai_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
        x_tai_rec.currency_conversion_date := l_tai_rec.currency_conversion_date;
      END IF;
      --End change by pgomes on 15-NOV-2002

      IF (x_tai_rec.ibt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.ibt_id := l_tai_rec.ibt_id;
      END IF;
      IF (x_tai_rec.ixx_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.ixx_id := l_tai_rec.ixx_id;
      END IF;
      IF (x_tai_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.khr_id := l_tai_rec.khr_id;
      END IF;
      IF (x_tai_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.irm_id := l_tai_rec.irm_id;
      END IF;
      IF (x_tai_rec.irt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.irt_id := l_tai_rec.irt_id;
      END IF;
      IF (x_tai_rec.cra_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.cra_id := l_tai_rec.cra_id;
      END IF;
      IF (x_tai_rec.svf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.svf_id := l_tai_rec.svf_id;
      END IF;
      IF (x_tai_rec.tap_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.tap_id := l_tai_rec.tap_id;
      END IF;
      IF (x_tai_rec.qte_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.qte_id := l_tai_rec.qte_id;
      END IF;
      IF (x_tai_rec.tcn_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.tcn_id := l_tai_rec.tcn_id;
      END IF;
      IF (x_tai_rec.tai_id_reverses = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.tai_id_reverses := l_tai_rec.tai_id_reverses;
      END IF;
	  -- Added after postgen changes
      IF (x_tai_rec.ipy_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.ipy_id := l_tai_rec.ipy_id;
      END IF;
      IF (x_tai_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.trx_status_code := l_tai_rec.trx_status_code;
      END IF;
      IF (x_tai_rec.set_of_books_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.set_of_books_id := l_tai_rec.set_of_books_id;
      END IF;
      IF (x_tai_rec.try_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.try_id := l_tai_rec.try_id;
      END IF;
	  -- End Addition after postgen changes

      IF (x_tai_rec.date_entered = Okl_Api.G_MISS_DATE)
      THEN
        x_tai_rec.date_entered := l_tai_rec.date_entered;
      END IF;
      IF (x_tai_rec.date_invoiced = Okl_Api.G_MISS_DATE)
      THEN
        x_tai_rec.date_invoiced := l_tai_rec.date_invoiced;
      END IF;
      IF (x_tai_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.amount := l_tai_rec.amount;
      END IF;
      IF (x_tai_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.object_version_number := l_tai_rec.object_version_number;
      END IF;
      IF (x_tai_rec.amount_applied = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.amount_applied := l_tai_rec.amount_applied;
      END IF;
      IF (x_tai_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.request_id := l_tai_rec.request_id;
      END IF;
      IF (x_tai_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.program_application_id := l_tai_rec.program_application_id;
      END IF;
      IF (x_tai_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.program_id := l_tai_rec.program_id;
      END IF;
      IF (x_tai_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tai_rec.program_update_date := l_tai_rec.program_update_date;
      END IF;
      IF (x_tai_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.org_id := l_tai_rec.org_id;
      END IF;
      IF (x_tai_rec.TRX_NUMBER = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.TRX_NUMBER := l_tai_rec.TRX_NUMBER;
      END IF;
      IF (x_tai_rec.clg_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.clg_id := l_tai_rec.clg_id;
      END IF;

    --Start code added by pgomes on 19-NOV-2002
      IF (x_tai_rec.pox_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.pox_id := l_tai_rec.pox_id;
      END IF;
    --End code added by pgomes on 19-NOV-2002

      IF (x_tai_rec.cpy_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.cpy_id := l_tai_rec.cpy_id;
      END IF;
      IF (x_tai_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute_category := l_tai_rec.attribute_category;
      END IF;
      IF (x_tai_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute1 := l_tai_rec.attribute1;
      END IF;
      IF (x_tai_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute2 := l_tai_rec.attribute2;
      END IF;
      IF (x_tai_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute3 := l_tai_rec.attribute3;
      END IF;
      IF (x_tai_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute4 := l_tai_rec.attribute4;
      END IF;
      IF (x_tai_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute5 := l_tai_rec.attribute5;
      END IF;
      IF (x_tai_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute6 := l_tai_rec.attribute6;
      END IF;
      IF (x_tai_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute7 := l_tai_rec.attribute7;
      END IF;
      IF (x_tai_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute8 := l_tai_rec.attribute8;
      END IF;
      IF (x_tai_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute9 := l_tai_rec.attribute9;
      END IF;
      IF (x_tai_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute10 := l_tai_rec.attribute10;
      END IF;
      IF (x_tai_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute11 := l_tai_rec.attribute11;
      END IF;
      IF (x_tai_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute12 := l_tai_rec.attribute12;
      END IF;
      IF (x_tai_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute13 := l_tai_rec.attribute13;
      END IF;
      IF (x_tai_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute14 := l_tai_rec.attribute14;
      END IF;
      IF (x_tai_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_tai_rec.attribute15 := l_tai_rec.attribute15;
      END IF;
      IF (x_tai_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.created_by := l_tai_rec.created_by;
      END IF;
      IF (x_tai_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tai_rec.creation_date := l_tai_rec.creation_date;
      END IF;
      IF (x_tai_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.last_updated_by := l_tai_rec.last_updated_by;
      END IF;
      IF (x_tai_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tai_rec.last_update_date := l_tai_rec.last_update_date;
      END IF;
      IF (x_tai_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.last_update_login := l_tai_rec.last_update_login;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_tai_rec.legal_entity_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tai_rec.legal_entity_id := l_tai_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
--gkhuntet 10-JUL-07 Start
--    Investor_Agreement_Number,
    IF (x_tai_rec.Investor_Agreement_Number IS NULL OR x_tai_rec.Investor_Agreement_Number = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.Investor_Agreement_Number := l_tai_rec.Investor_Agreement_Number;
    END IF;

--    Investor_Name,
    IF (x_tai_rec.Investor_Name IS NULL OR x_tai_rec.Investor_Name = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.Investor_Name := l_tai_rec.Investor_Name;
    END IF;

--    OKL_SOURCE_BILLING_TRX,
    IF (x_tai_rec.OKL_SOURCE_BILLING_TRX IS NULL OR x_tai_rec.OKL_SOURCE_BILLING_TRX = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.OKL_SOURCE_BILLING_TRX := l_tai_rec.OKL_SOURCE_BILLING_TRX;
    END IF;

--    INF_ID,
    IF (x_tai_rec.INF_ID IS NULL OR x_tai_rec.INF_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.INF_ID := l_tai_rec.INF_ID;
    END IF;

--    INVOICE_PULL_YN,
    IF (x_tai_rec.INVOICE_PULL_YN IS NULL OR
      x_tai_rec.INVOICE_PULL_YN = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.INVOICE_PULL_YN := l_tai_rec.INVOICE_PULL_YN;
    END IF;

--    CONSOLIDATED_INVOICE_NUMBER,
    IF (x_tai_rec.CONSOLIDATED_INVOICE_NUMBER IS NULL OR x_tai_rec.CONSOLIDATED_INVOICE_NUMBER = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.CONSOLIDATED_INVOICE_NUMBER := l_tai_rec.CONSOLIDATED_INVOICE_NUMBER;
    END IF;

--    DUE_DATE,
    IF (x_tai_rec.DUE_DATE IS NULL OR x_tai_rec.DUE_DATE = Okl_Api.G_MISS_DATE) THEN
      x_tai_rec.DUE_DATE := l_tai_rec.DUE_DATE;
    END IF;

--    ISI_ID,
    IF (x_tai_rec.ISI_ID  IS NULL OR x_tai_rec.ISI_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.ISI_ID := l_tai_rec.ISI_ID;
    END IF;

--    RECEIVABLES_INVOICE_ID,
    IF (x_tai_rec.RECEIVABLES_INVOICE_ID  IS NULL OR x_tai_rec.RECEIVABLES_INVOICE_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.RECEIVABLES_INVOICE_ID := l_tai_rec.RECEIVABLES_INVOICE_ID;
    END IF;

--    CUST_TRX_TYPE_ID,
    IF (x_tai_rec.CUST_TRX_TYPE_ID IS NULL OR
       x_tai_rec.CUST_TRX_TYPE_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.CUST_TRX_TYPE_ID := l_tai_rec.CUST_TRX_TYPE_ID;
    END IF;

--    CUSTOMER_BANK_ACCOUNT_ID,
    IF (x_tai_rec.CUSTOMER_BANK_ACCOUNT_ID IS NULL OR x_tai_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.CUSTOMER_BANK_ACCOUNT_ID := l_tai_rec.CUSTOMER_BANK_ACCOUNT_ID;
    END IF;

--    TAX_EXEMPT_FLAG,
    IF (x_tai_rec.TAX_EXEMPT_FLAG IS NULL OR
        x_tai_rec.TAX_EXEMPT_FLAG = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.TAX_EXEMPT_FLAG := l_tai_rec.TAX_EXEMPT_FLAG;
    END IF;

--    TAX_EXEMPT_REASON_CODE,
    IF (x_tai_rec.TAX_EXEMPT_REASON_CODE IS NULL OR x_tai_rec.TAX_EXEMPT_REASON_CODE = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.TAX_EXEMPT_REASON_CODE := l_tai_rec.TAX_EXEMPT_REASON_CODE;
    END IF;

--  REFERENCE_LINE_ID
    IF (x_tai_rec.REFERENCE_LINE_ID IS NULL OR x_tai_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      x_tai_rec.REFERENCE_LINE_ID := l_tai_rec.REFERENCE_LINE_ID;
    END IF;

--  PRIVATE_LABEL
    IF (x_tai_rec.PRIVATE_LABEL IS NULL OR x_tai_rec.PRIVATE_LABEL = Okl_Api.G_MISS_CHAR) THEN
      x_tai_rec.PRIVATE_LABEL := l_tai_rec.PRIVATE_LABEL;
    END IF;
--gkhuntet 10-JUL-07 End
-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
   IF (x_tai_rec.TRANSACTION_DATE  = Okl_Api.G_MISS_DATE) THEN
      x_tai_rec.TRANSACTION_DATE  := SYSDATE ;
    END IF;
--gkhuntet end 02-Nov-07



      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tai_rec IN  tai_rec_type,
      x_tai_rec OUT NOCOPY tai_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tai_rec := p_tai_rec;
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
      p_tai_rec,                         -- IN
      l_tai_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tai_rec, l_def_tai_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_TRX_AR_INVOICES_B
    SET CURRENCY_CODE = l_def_tai_rec.currency_code,
    --Start change by pgomes on 15-NOV-2002
        currency_conversion_type = l_def_tai_rec.currency_conversion_type,
        currency_conversion_rate = l_def_tai_rec.currency_conversion_rate,
        currency_conversion_date = l_def_tai_rec.currency_conversion_date,
    --End change by pgomes on 15-NOV-2002
        IBT_ID = l_def_tai_rec.ibt_id,
        IXX_ID = l_def_tai_rec.ixx_id,
        KHR_ID = l_def_tai_rec.khr_id,
        IRM_ID = l_def_tai_rec.irm_id,
        IRT_ID = l_def_tai_rec.irt_id,
        CRA_ID = l_def_tai_rec.cra_id,
        SVF_ID = l_def_tai_rec.svf_id,
        TAP_ID = l_def_tai_rec.tap_id,
        QTE_ID = l_def_tai_rec.qte_id,
        TCN_ID = l_def_tai_rec.tcn_id,
        TAI_ID_REVERSES = l_def_tai_rec.tai_id_reverses,
        IPY_ID = l_def_tai_rec.ipy_id,		-- Added after postgen changes
        TRX_STATUS_CODE = l_def_tai_rec.trx_status_code,		-- Added after postgen changes
        SET_OF_BOOKS_ID = l_def_tai_rec.set_of_books_id,		-- Added after postgen changes
        TRY_ID = l_def_tai_rec.try_id,		-- Added after postgen changes
        DATE_ENTERED = l_def_tai_rec.date_entered,
        DATE_INVOICED = l_def_tai_rec.date_invoiced,
        AMOUNT = l_def_tai_rec.amount,
        OBJECT_VERSION_NUMBER = l_def_tai_rec.object_version_number,
        AMOUNT_APPLIED = l_def_tai_rec.amount_applied,
        REQUEST_ID = l_def_tai_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tai_rec.program_application_id,
        PROGRAM_ID = l_def_tai_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_tai_rec.program_update_date,
        ORG_ID = l_def_tai_rec.org_id,
		TRX_NUMBER = l_def_tai_rec.trx_number,
		CLG_ID = l_def_tai_rec.clg_id,
		POX_ID = l_def_tai_rec.pox_id,
		CPY_ID = l_def_tai_rec.cpy_id,
        ATTRIBUTE_CATEGORY = l_def_tai_rec.attribute_category,
        ATTRIBUTE1 = l_def_tai_rec.attribute1,
        ATTRIBUTE2 = l_def_tai_rec.attribute2,
        ATTRIBUTE3 = l_def_tai_rec.attribute3,
        ATTRIBUTE4 = l_def_tai_rec.attribute4,
        ATTRIBUTE5 = l_def_tai_rec.attribute5,
        ATTRIBUTE6 = l_def_tai_rec.attribute6,
        ATTRIBUTE7 = l_def_tai_rec.attribute7,
        ATTRIBUTE8 = l_def_tai_rec.attribute8,
        ATTRIBUTE9 = l_def_tai_rec.attribute9,
        ATTRIBUTE10 = l_def_tai_rec.attribute10,
        ATTRIBUTE11 = l_def_tai_rec.attribute11,
        ATTRIBUTE12 = l_def_tai_rec.attribute12,
        ATTRIBUTE13 = l_def_tai_rec.attribute13,
        ATTRIBUTE14 = l_def_tai_rec.attribute14,
        ATTRIBUTE15 = l_def_tai_rec.attribute15,
        CREATED_BY = l_def_tai_rec.created_by,
        CREATION_DATE = l_def_tai_rec.creation_date,
        LAST_UPDATED_BY = l_def_tai_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tai_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tai_rec.last_update_login,
        LEGAL_ENTITY_ID = l_def_tai_rec.legal_entity_id, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
Investor_Agreement_Number = l_def_tai_rec.Investor_Agreement_Number,
Investor_Name = l_def_tai_rec.Investor_Name,
OKL_SOURCE_BILLING_TRX = l_def_tai_rec.OKL_SOURCE_BILLING_TRX,
INF_ID = l_def_tai_rec.INF_ID,
INVOICE_PULL_YN = l_def_tai_rec.INVOICE_PULL_YN,
CONSOLIDATED_INVOICE_NUMBER = l_def_tai_rec.CONSOLIDATED_INVOICE_NUMBER,
DUE_DATE = l_def_tai_rec.DUE_DATE,
ISI_ID = l_def_tai_rec.ISI_ID,
RECEIVABLES_INVOICE_ID = l_def_tai_rec.RECEIVABLES_INVOICE_ID,
CUST_TRX_TYPE_ID = l_def_tai_rec.CUST_TRX_TYPE_ID,
CUSTOMER_BANK_ACCOUNT_ID = l_def_tai_rec.CUSTOMER_BANK_ACCOUNT_ID,
TAX_EXEMPT_FLAG = l_def_tai_rec.TAX_EXEMPT_FLAG,
TAX_EXEMPT_REASON_CODE = l_def_tai_rec.TAX_EXEMPT_REASON_CODE,
REFERENCE_LINE_ID = l_def_tai_rec.REFERENCE_LINE_ID,
PRIVATE_LABEL = l_def_tai_rec.PRIVATE_LABEL,
-- end:30-Jan-07 cklee  Billing R12 project
--gkhuntet start 02-Nov-07
TRANSACTION_DATE = l_def_tai_rec.transaction_date
--gkhuntet  end 02-Nov-07



    WHERE ID = l_def_tai_rec.id;

    x_tai_rec := l_def_tai_rec;
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
  -------------------------------------------
  -- update_row for:OKL_TRX_AR_INVOICES_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType,
    x_okl_trx_ar_invoices_tl_rec   OUT NOCOPY OklTrxArInvoicesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType := p_okl_trx_ar_invoices_tl_rec;
    ldefokltrxarinvoicestlrec      OklTrxArInvoicesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_ar_invoices_tl_rec	IN OklTrxArInvoicesTlRecType,
      x_okl_trx_ar_invoices_tl_rec	OUT NOCOPY OklTrxArInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_invoices_tl_rec := p_okl_trx_ar_invoices_tl_rec;
      -- Get current database values
      l_okl_trx_ar_invoices_tl_rec := get_rec(p_okl_trx_ar_invoices_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_ar_invoices_tl_rec.id := l_okl_trx_ar_invoices_tl_rec.id;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_invoices_tl_rec.LANGUAGE := l_okl_trx_ar_invoices_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_invoices_tl_rec.source_lang := l_okl_trx_ar_invoices_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_invoices_tl_rec.sfwt_flag := l_okl_trx_ar_invoices_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_invoices_tl_rec.description := l_okl_trx_ar_invoices_tl_rec.description;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_ar_invoices_tl_rec.created_by := l_okl_trx_ar_invoices_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_ar_invoices_tl_rec.creation_date := l_okl_trx_ar_invoices_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_ar_invoices_tl_rec.last_updated_by := l_okl_trx_ar_invoices_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_trx_ar_invoices_tl_rec.last_update_date := l_okl_trx_ar_invoices_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_ar_invoices_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_trx_ar_invoices_tl_rec.last_update_login := l_okl_trx_ar_invoices_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_invoices_tl_rec IN  OklTrxArInvoicesTlRecType,
      x_okl_trx_ar_invoices_tl_rec OUT NOCOPY OklTrxArInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_invoices_tl_rec := p_okl_trx_ar_invoices_tl_rec;
      x_okl_trx_ar_invoices_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ar_invoices_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_ar_invoices_tl_rec,      -- IN
      l_okl_trx_ar_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_ar_invoices_tl_rec, ldefokltrxarinvoicestlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_AR_INVOICES_TL
    SET DESCRIPTION = ldefokltrxarinvoicestlrec.description,
        SOURCE_LANG = ldefokltrxarinvoicestlrec.source_lang,
        CREATED_BY = ldefokltrxarinvoicestlrec.created_by,
        CREATION_DATE = ldefokltrxarinvoicestlrec.creation_date,
        LAST_UPDATED_BY = ldefokltrxarinvoicestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltrxarinvoicestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltrxarinvoicestlrec.last_update_login
    WHERE ID = ldefokltrxarinvoicestlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TRX_AR_INVOICES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltrxarinvoicestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_ar_invoices_tl_rec := ldefokltrxarinvoicestlrec;
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
  ------------------------------------------
  -- update_row for:OKL_TRX_AR_INVOICES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type,
    x_taiv_rec                     OUT NOCOPY taiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_taiv_rec                     taiv_rec_type := p_taiv_rec;
    l_def_taiv_rec                 taiv_rec_type;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
    lx_okl_trx_ar_invoices_tl_rec  OklTrxArInvoicesTlRecType;
    l_tai_rec                      tai_rec_type;
    lx_tai_rec                     tai_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taiv_rec	IN taiv_rec_type
    ) RETURN taiv_rec_type IS
      l_taiv_rec	taiv_rec_type := p_taiv_rec;
    BEGIN
      l_taiv_rec.LAST_UPDATE_DATE := l_taiv_rec.CREATION_DATE;
      l_taiv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_taiv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_taiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_taiv_rec	IN taiv_rec_type,
      x_taiv_rec	OUT NOCOPY taiv_rec_type
    ) RETURN VARCHAR2 IS
      l_taiv_rec                     taiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taiv_rec := p_taiv_rec;
      -- Get current database values
      l_taiv_rec := get_rec(p_taiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_taiv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.id := l_taiv_rec.id;
      END IF;
      IF (x_taiv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.object_version_number := l_taiv_rec.object_version_number;
      END IF;
      IF (x_taiv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.sfwt_flag := l_taiv_rec.sfwt_flag;
      END IF;

      IF (x_taiv_rec.currency_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.currency_code := l_taiv_rec.currency_code;
      END IF;

      --Start change by pgomes on 15-NOV-2002
      IF (x_taiv_rec.currency_conversion_type = Okl_Api.G_MISS_CHAR) THEN
        x_taiv_rec.currency_conversion_type := l_taiv_rec.currency_conversion_type;
      END IF;

      IF (x_taiv_rec.currency_conversion_rate = Okl_Api.G_MISS_NUM) THEN
        x_taiv_rec.currency_conversion_rate := l_taiv_rec.currency_conversion_rate;
      END IF;

      IF (x_taiv_rec.currency_conversion_date = Okl_Api.G_MISS_DATE) THEN
        x_taiv_rec.currency_conversion_date := l_taiv_rec.currency_conversion_date;
      END IF;
      --End change by pgomes on 15-NOV-2002


      IF (x_taiv_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.khr_id := l_taiv_rec.khr_id;
      END IF;
      IF (x_taiv_rec.cra_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.cra_id := l_taiv_rec.cra_id;
      END IF;
      IF (x_taiv_rec.tap_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.tap_id := l_taiv_rec.tap_id;
      END IF;
      IF (x_taiv_rec.qte_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.qte_id := l_taiv_rec.qte_id;
      END IF;
      IF (x_taiv_rec.tcn_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.tcn_id := l_taiv_rec.tcn_id;
      END IF;
      IF (x_taiv_rec.tai_id_reverses = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.tai_id_reverses := l_taiv_rec.tai_id_reverses;
      END IF;
	  --Added after postgen changes
      IF (x_taiv_rec.ipy_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.ipy_id := l_taiv_rec.ipy_id;
      END IF;
      IF (x_taiv_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.trx_status_code := l_taiv_rec.trx_status_code;
      END IF;
      IF (x_taiv_rec.set_of_books_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.set_of_books_id := l_taiv_rec.set_of_books_id;
      END IF;
      IF (x_taiv_rec.try_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.try_id := l_taiv_rec.try_id;
      END IF;
	  --End Addition after postgen changes
      IF (x_taiv_rec.ibt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.ibt_id := l_taiv_rec.ibt_id;
      END IF;
      IF (x_taiv_rec.ixx_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.ixx_id := l_taiv_rec.ixx_id;
      END IF;
      IF (x_taiv_rec.irm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.irm_id := l_taiv_rec.irm_id;
      END IF;
      IF (x_taiv_rec.irt_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.irt_id := l_taiv_rec.irt_id;
      END IF;
      IF (x_taiv_rec.svf_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.svf_id := l_taiv_rec.svf_id;
      END IF;
      IF (x_taiv_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.amount := l_taiv_rec.amount;
      END IF;
      IF (x_taiv_rec.date_invoiced = Okl_Api.G_MISS_DATE)
      THEN
        x_taiv_rec.date_invoiced := l_taiv_rec.date_invoiced;
      END IF;
      IF (x_taiv_rec.amount_applied = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.amount_applied := l_taiv_rec.amount_applied;
      END IF;
      IF (x_taiv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.description := l_taiv_rec.description;
      END IF;

      IF (x_taiv_rec.trx_number = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.trx_number := l_taiv_rec.trx_number;
      END IF;
      IF (x_taiv_rec.clg_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.clg_id := l_taiv_rec.clg_id;
      END IF;

    --Start code added by pgomes on 19-NOV-2002
      IF (x_taiv_rec.pox_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.pox_id := l_taiv_rec.pox_id;
      END IF;
    --End code added by pgomes on 19-NOV-2002

      IF (x_taiv_rec.cpy_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.cpy_id := l_taiv_rec.cpy_id;
      END IF;
      IF (x_taiv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute_category := l_taiv_rec.attribute_category;
      END IF;
      IF (x_taiv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute1 := l_taiv_rec.attribute1;
      END IF;
      IF (x_taiv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute2 := l_taiv_rec.attribute2;
      END IF;
      IF (x_taiv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute3 := l_taiv_rec.attribute3;
      END IF;
      IF (x_taiv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute4 := l_taiv_rec.attribute4;
      END IF;
      IF (x_taiv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute5 := l_taiv_rec.attribute5;
      END IF;
      IF (x_taiv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute6 := l_taiv_rec.attribute6;
      END IF;
      IF (x_taiv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute7 := l_taiv_rec.attribute7;
      END IF;
      IF (x_taiv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute8 := l_taiv_rec.attribute8;
      END IF;
      IF (x_taiv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute9 := l_taiv_rec.attribute9;
      END IF;
      IF (x_taiv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute10 := l_taiv_rec.attribute10;
      END IF;
      IF (x_taiv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute11 := l_taiv_rec.attribute11;
      END IF;
      IF (x_taiv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute12 := l_taiv_rec.attribute12;
      END IF;
      IF (x_taiv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute13 := l_taiv_rec.attribute13;
      END IF;
      IF (x_taiv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute14 := l_taiv_rec.attribute14;
      END IF;
      IF (x_taiv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_taiv_rec.attribute15 := l_taiv_rec.attribute15;
      END IF;
      IF (x_taiv_rec.date_entered = Okl_Api.G_MISS_DATE)
      THEN
        x_taiv_rec.date_entered := l_taiv_rec.date_entered;
      END IF;
      IF (x_taiv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.request_id := l_taiv_rec.request_id;
      END IF;
      IF (x_taiv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.program_application_id := l_taiv_rec.program_application_id;
      END IF;
      IF (x_taiv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.program_id := l_taiv_rec.program_id;
      END IF;
      IF (x_taiv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_taiv_rec.program_update_date := l_taiv_rec.program_update_date;
      END IF;
      IF (x_taiv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.org_id := l_taiv_rec.org_id;
      END IF;
      IF (x_taiv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.created_by := l_taiv_rec.created_by;
      END IF;
      IF (x_taiv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_taiv_rec.creation_date := l_taiv_rec.creation_date;
      END IF;
      IF (x_taiv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.last_updated_by := l_taiv_rec.last_updated_by;
      END IF;
      IF (x_taiv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_taiv_rec.last_update_date := l_taiv_rec.last_update_date;
      END IF;
      IF (x_taiv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.last_update_login := l_taiv_rec.last_update_login;
      END IF;
      -- for LE Uptake project 08-11-2006
      IF (x_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM)
      THEN
        x_taiv_rec.legal_entity_id := l_taiv_rec.legal_entity_id;
      END IF;
      -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
--gkhuntet 10-JUL-07  Start
--    Investor_Agreement_Number,
   IF (x_taiv_rec.Investor_Name = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.Investor_Name := l_tai_rec.Investor_Name;
    END IF;

--    OKL_SOURCE_BILLING_TRX,
    IF (x_taiv_rec.OKL_SOURCE_BILLING_TRX = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.OKL_SOURCE_BILLING_TRX := l_tai_rec.OKL_SOURCE_BILLING_TRX;
    END IF;

--    INF_ID,
    IF (x_taiv_rec.INF_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.INF_ID := l_tai_rec.INF_ID;
    END IF;

--    INVOICE_PULL_YN,
    IF (x_taiv_rec.INVOICE_PULL_YN = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.INVOICE_PULL_YN := l_tai_rec.INVOICE_PULL_YN;
    END IF;

--    CONSOLIDATED_INVOICE_NUMBER,
    IF (x_taiv_rec.CONSOLIDATED_INVOICE_NUMBER = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.CONSOLIDATED_INVOICE_NUMBER := l_tai_rec.CONSOLIDATED_INVOICE_NUMBER;
    END IF;

--    DUE_DATE,
    IF (x_taiv_rec.DUE_DATE = Okl_Api.G_MISS_DATE) THEN
      x_taiv_rec.DUE_DATE := l_tai_rec.DUE_DATE;
    END IF;

--    ISI_ID,
    IF (x_taiv_rec.ISI_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.ISI_ID := l_tai_rec.ISI_ID;
    END IF;

--    RECEIVABLES_INVOICE_ID,
    IF (x_taiv_rec.RECEIVABLES_INVOICE_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.RECEIVABLES_INVOICE_ID := l_tai_rec.RECEIVABLES_INVOICE_ID;
    END IF;

--    CUST_TRX_TYPE_ID,
    IF (x_taiv_rec.CUST_TRX_TYPE_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.CUST_TRX_TYPE_ID := l_tai_rec.CUST_TRX_TYPE_ID;
    END IF;

--    CUSTOMER_BANK_ACCOUNT_ID,
    IF (x_taiv_rec.CUSTOMER_BANK_ACCOUNT_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.CUSTOMER_BANK_ACCOUNT_ID := l_tai_rec.CUSTOMER_BANK_ACCOUNT_ID;
    END IF;

--    TAX_EXEMPT_FLAG,
    IF (x_taiv_rec.TAX_EXEMPT_FLAG = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.TAX_EXEMPT_FLAG := l_tai_rec.TAX_EXEMPT_FLAG;
    END IF;

--    TAX_EXEMPT_REASON_CODE,
    IF (x_taiv_rec.TAX_EXEMPT_REASON_CODE = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.TAX_EXEMPT_REASON_CODE := l_tai_rec.TAX_EXEMPT_REASON_CODE;
    END IF;

--  REFERENCE_LINE_ID
    IF (x_taiv_rec.REFERENCE_LINE_ID = Okl_Api.G_MISS_NUM) THEN
      x_taiv_rec.REFERENCE_LINE_ID := l_tai_rec.REFERENCE_LINE_ID;
    END IF;

--  PRIVATE_LABEL
    IF (x_taiv_rec.PRIVATE_LABEL = Okl_Api.G_MISS_CHAR) THEN
      x_taiv_rec.PRIVATE_LABEL := l_tai_rec.PRIVATE_LABEL;
    END IF;
--gkhuntet 10-JUL-07  END
-- end:30-Jan-07 cklee  Billing R12 project

--gkhuntet start 02-Nov-07
   IF (x_taiv_rec.TRANSACTION_DATE  = Okl_Api.G_MISS_DATE OR x_taiv_rec.TRANSACTION_DATE IS NULL) THEN
      x_taiv_rec.TRANSACTION_DATE  := l_tai_rec.TRANSACTION_DATE ;
    END IF;
--gkhuntet end 02-Nov-07

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_taiv_rec IN  taiv_rec_type,
      x_taiv_rec OUT NOCOPY taiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taiv_rec := p_taiv_rec;
      x_taiv_rec.OBJECT_VERSION_NUMBER := NVL(x_taiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_taiv_rec.request_id IS NULL OR x_taiv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_taiv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_taiv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_taiv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_taiv_rec.program_update_date,SYSDATE)
      INTO
        x_taiv_rec.request_id,
        x_taiv_rec.program_application_id,
        x_taiv_rec.program_id,
        x_taiv_rec.program_update_date
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
      p_taiv_rec,                        -- IN
      l_taiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_taiv_rec, l_def_taiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_taiv_rec := fill_who_columns(l_def_taiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    --l_return_status := Validate_Attributes(l_def_taiv_rec); --20-May-08 sechawla 6619311
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taiv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_taiv_rec, l_okl_trx_ar_invoices_tl_rec);
    migrate(l_def_taiv_rec, l_tai_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_invoices_tl_rec,
      lx_okl_trx_ar_invoices_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ar_invoices_tl_rec, l_def_taiv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tai_rec,
      lx_tai_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tai_rec, l_def_taiv_rec);
    x_taiv_rec := l_def_taiv_rec;
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
  -- PL/SQL TBL update_row for:TAIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type,
    x_taiv_tbl                     OUT NOCOPY taiv_tbl_type) IS

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
    IF (p_taiv_tbl.COUNT > 0) THEN
      i := p_taiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taiv_rec                     => p_taiv_tbl(i),
          x_taiv_rec                     => x_taiv_tbl(i));

	    -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

        EXIT WHEN (i = p_taiv_tbl.LAST);
        i := p_taiv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKL_TRX_AR_INVOICES_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tai_rec                      IN tai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tai_rec                      tai_rec_type:= p_tai_rec;
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
    DELETE FROM OKL_TRX_AR_INVOICES_B
     WHERE ID = l_tai_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_TRX_AR_INVOICES_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_invoices_tl_rec   IN OklTrxArInvoicesTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType:= p_okl_trx_ar_invoices_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_invoices_tl_rec IN  OklTrxArInvoicesTlRecType,
      x_okl_trx_ar_invoices_tl_rec OUT NOCOPY OklTrxArInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_invoices_tl_rec := p_okl_trx_ar_invoices_tl_rec;
      x_okl_trx_ar_invoices_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_trx_ar_invoices_tl_rec,      -- IN
      l_okl_trx_ar_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_AR_INVOICES_TL
     WHERE ID = l_okl_trx_ar_invoices_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_TRX_AR_INVOICES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_taiv_rec                     taiv_rec_type := p_taiv_rec;
    l_okl_trx_ar_invoices_tl_rec   OklTrxArInvoicesTlRecType;
    l_tai_rec                      tai_rec_type;
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
    migrate(l_taiv_rec, l_okl_trx_ar_invoices_tl_rec);
    migrate(l_taiv_rec, l_tai_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_invoices_tl_rec
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
      l_tai_rec
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
  -- PL/SQL TBL delete_row for:TAIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type) IS

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
    IF (p_taiv_tbl.COUNT > 0) THEN
      i := p_taiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taiv_rec                     => p_taiv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_taiv_tbl.LAST);
        i := p_taiv_tbl.NEXT(i);
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

END Okl_Tai_Pvt;

/
