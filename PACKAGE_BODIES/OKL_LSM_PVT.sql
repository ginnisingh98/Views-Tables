--------------------------------------------------------
--  DDL for Package Body OKL_LSM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LSM_PVT" AS
/* $Header: OKLSLSMB.pls 120.2 2005/06/03 23:11:51 pjgomes noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_lsmv_rec IN lsmv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_lsmv_rec.id = Okl_Api.G_MISS_NUM OR
       p_lsmv_rec.id IS NULL
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

  PROCEDURE validate_org_id (p_lsmv_rec IN lsmv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_lsmv_rec.org_id);

  END validate_org_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_lsmv_rec IN lsmv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_lsmv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_lsmv_rec.object_version_number IS NULL
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
  -- PROCEDURE     validate_lln_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_lln_id(p_lsmv_rec IN lsmv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_lln_id_csr IS
    SELECT '1'
	FROM OKL_CNSLD_AR_LINES_V
	WHERE id = p_lsmv_rec.lln_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_lsmv_rec.lln_id = Okl_Api.G_MISS_NUM OR
       p_lsmv_rec.lln_id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'lln_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;


	   IF (p_lsmv_rec.lln_id IS NOT NULL) THEN
	   	  OPEN l_lln_id_csr;
		  FETCH l_lln_id_csr INTO l_dummy_var;
		  CLOSE l_lln_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'LLN_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_STRMS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_lln_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_sty_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_sty_id(p_lsmv_rec IN lsmv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_sty_id_csr IS
    SELECT '1'
	FROM OKL_STRM_TYPE_V
	WHERE id = p_lsmv_rec.sty_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	--Check for Null
    IF p_lsmv_rec.sty_id = Okl_Api.G_MISS_NUM OR
       p_lsmv_rec.sty_id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'sty_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;


	   IF (p_lsmv_rec.sty_id IS NOT NULL) THEN
	   	  OPEN l_sty_id_csr;
		  FETCH l_sty_id_csr INTO l_dummy_var;
		  CLOSE l_sty_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'STY_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_STRMS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_sty_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_kle_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_kle_id(p_lsmv_rec IN lsmv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_kle_id_csr IS
    SELECT '1'
	FROM OKC_K_LINES_B
	WHERE id = p_lsmv_rec.kle_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_lsmv_rec.kle_id IS NOT NULL) THEN
	   	  OPEN l_kle_id_csr;
		  FETCH l_kle_id_csr INTO l_dummy_var;
		  CLOSE l_kle_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'KLE_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_STRMS_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_kle_id;

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
    DELETE FROM OKL_CNSLD_AR_STRMS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CNSLD_AR_STRMS_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );
    /*
    WHERE (
            T.ID,
            T.LANGUAGE)
        IN (SELECT
                SUBT.ID,
                SUBT.LANGUAGE
              FROM OKL_CNSLD_AR_STRMS_TL SUBB, OKL_CNSLD_AR_STRMS_TL SUBT
             WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
  	 */

  INSERT INTO OKL_CNSLD_AR_STRMS_TL (
      ID,
      LANGUAGE,
      SOURCE_LANG,
      SFWT_FLAG,
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
          B.CREATED_BY,
          B.CREATION_DATE,
          B.LAST_UPDATED_BY,
          B.LAST_UPDATE_DATE,
          B.LAST_UPDATE_LOGIN
      FROM OKL_CNSLD_AR_STRMS_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND B.LANGUAGE = USERENV('LANG')
       AND NOT EXISTS(
                  SELECT NULL
                    FROM OKL_CNSLD_AR_STRMS_TL T
                   WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                  );

END add_language;

---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_STRMS_B
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_lsm_rec                      IN lsm_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN lsm_rec_type IS
  CURSOR okl_cnsld_ar_strms_b_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          LLN_ID,
          STY_ID,
          KLE_ID,
		  KHR_ID,
          AMOUNT,
          OBJECT_VERSION_NUMBER,
          RECEIVABLES_INVOICE_ID,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          ORG_ID,
		  TAX_AMOUNT,
		  LATE_INT_ASSESS_DATE,
		  LATE_CHARGE_ASS_YN,
		  LATE_CHARGE_ASSESS_DATE,
		  LATE_INT_ASS_YN,
		  PAY_STATUS_CODE,
      DATE_DISBURSED,
          investor_disb_status,
          investor_disb_err_mg,
          sel_id,
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
    FROM Okl_Cnsld_Ar_Strms_B
   WHERE okl_cnsld_ar_strms_b.id = p_id;
  l_okl_cnsld_ar_strms_b_pk      okl_cnsld_ar_strms_b_pk_csr%ROWTYPE;
  l_lsm_rec                      lsm_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_cnsld_ar_strms_b_pk_csr (p_lsm_rec.id);
  FETCH okl_cnsld_ar_strms_b_pk_csr INTO
            l_lsm_rec.ID,
            l_lsm_rec.LLN_ID,
            l_lsm_rec.STY_ID,
            l_lsm_rec.KLE_ID,
			l_lsm_rec.KHR_ID,
            l_lsm_rec.AMOUNT,
            l_lsm_rec.OBJECT_VERSION_NUMBER,
            l_lsm_rec.RECEIVABLES_INVOICE_ID,
            l_lsm_rec.REQUEST_ID,
            l_lsm_rec.PROGRAM_APPLICATION_ID,
            l_lsm_rec.PROGRAM_ID,
            l_lsm_rec.PROGRAM_UPDATE_DATE,
            l_lsm_rec.ORG_ID,
            l_lsm_rec.TAX_AMOUNT,
		  	l_lsm_rec.LATE_INT_ASSESS_DATE,
		  	l_lsm_rec.LATE_CHARGE_ASS_YN,
		  	l_lsm_rec.LATE_CHARGE_ASSESS_DATE,
		  	l_lsm_rec.LATE_INT_ASS_YN,
		  	l_lsm_rec.PAY_STATUS_CODE,
        l_lsm_rec.DATE_DISBURSED,
		  	l_lsm_rec.investor_disb_status,
		  	l_lsm_rec.investor_disb_err_mg,
            l_lsm_rec.sel_id,
            l_lsm_rec.ATTRIBUTE_CATEGORY,
            l_lsm_rec.ATTRIBUTE1,
            l_lsm_rec.ATTRIBUTE2,
            l_lsm_rec.ATTRIBUTE3,
            l_lsm_rec.ATTRIBUTE4,
            l_lsm_rec.ATTRIBUTE5,
            l_lsm_rec.ATTRIBUTE6,
            l_lsm_rec.ATTRIBUTE7,
            l_lsm_rec.ATTRIBUTE8,
            l_lsm_rec.ATTRIBUTE9,
            l_lsm_rec.ATTRIBUTE10,
            l_lsm_rec.ATTRIBUTE11,
            l_lsm_rec.ATTRIBUTE12,
            l_lsm_rec.ATTRIBUTE13,
            l_lsm_rec.ATTRIBUTE14,
            l_lsm_rec.ATTRIBUTE15,
            l_lsm_rec.CREATED_BY,
            l_lsm_rec.CREATION_DATE,
            l_lsm_rec.LAST_UPDATED_BY,
            l_lsm_rec.LAST_UPDATE_DATE,
            l_lsm_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_cnsld_ar_strms_b_pk_csr%NOTFOUND;
  CLOSE okl_cnsld_ar_strms_b_pk_csr;
  RETURN(l_lsm_rec);
END get_rec;

FUNCTION get_rec (
  p_lsm_rec                      IN lsm_rec_type
) RETURN lsm_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_lsm_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_STRMS_TL
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN okl_cnsld_ar_strms_tl_rec_type IS
  CURSOR okl_cnsld_ar_strms_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
  SELECT
          ID,
          LANGUAGE,
          SOURCE_LANG,
          SFWT_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
    FROM Okl_Cnsld_Ar_Strms_Tl
   WHERE okl_cnsld_ar_strms_tl.id = p_id
     AND okl_cnsld_ar_strms_tl.LANGUAGE = p_language;
  l_okl_cnsld_ar_strms_tl_pk     okl_cnsld_ar_strms_tl_pk_csr%ROWTYPE;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_cnsld_ar_strms_tl_pk_csr (p_okl_cnsld_ar_strms_tl_rec.id,
                                     p_okl_cnsld_ar_strms_tl_rec.LANGUAGE);
  FETCH okl_cnsld_ar_strms_tl_pk_csr INTO
            l_okl_cnsld_ar_strms_tl_rec.ID,
            l_okl_cnsld_ar_strms_tl_rec.LANGUAGE,
            l_okl_cnsld_ar_strms_tl_rec.SOURCE_LANG,
            l_okl_cnsld_ar_strms_tl_rec.SFWT_FLAG,
            l_okl_cnsld_ar_strms_tl_rec.CREATED_BY,
            l_okl_cnsld_ar_strms_tl_rec.CREATION_DATE,
            l_okl_cnsld_ar_strms_tl_rec.LAST_UPDATED_BY,
            l_okl_cnsld_ar_strms_tl_rec.LAST_UPDATE_DATE,
            l_okl_cnsld_ar_strms_tl_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_cnsld_ar_strms_tl_pk_csr%NOTFOUND;
  CLOSE okl_cnsld_ar_strms_tl_pk_csr;
  RETURN(l_okl_cnsld_ar_strms_tl_rec);
END get_rec;

FUNCTION get_rec (
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type
) RETURN okl_cnsld_ar_strms_tl_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_okl_cnsld_ar_strms_tl_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_STRMS_V
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_lsmv_rec                     IN lsmv_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN lsmv_rec_type IS
  CURSOR okl_lsmv_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          OBJECT_VERSION_NUMBER,
          SFWT_FLAG,
          LLN_ID,
          KLE_ID,
		  KHR_ID,
          STY_ID,
          AMOUNT,
          RECEIVABLES_INVOICE_ID,
          TAX_AMOUNT,
		  LATE_INT_ASSESS_DATE,
		  LATE_CHARGE_ASS_YN,
		  LATE_CHARGE_ASSESS_DATE,
		  LATE_INT_ASS_YN,
		  PAY_STATUS_CODE,
      DATE_DISBURSED,
          investor_disb_status,
          investor_disb_err_mg,
          sel_id,
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
          LAST_UPDATE_LOGIN
    FROM Okl_Cnsld_Ar_Strms_V
   WHERE okl_cnsld_ar_strms_v.id = p_id;
  l_okl_lsmv_pk                  okl_lsmv_pk_csr%ROWTYPE;
  l_lsmv_rec                     lsmv_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_lsmv_pk_csr (p_lsmv_rec.id);
  FETCH okl_lsmv_pk_csr INTO
            l_lsmv_rec.ID,
            l_lsmv_rec.OBJECT_VERSION_NUMBER,
            l_lsmv_rec.SFWT_FLAG,
            l_lsmv_rec.LLN_ID,
            l_lsmv_rec.KLE_ID,
			l_lsmv_rec.KHR_ID,
            l_lsmv_rec.STY_ID,
            l_lsmv_rec.AMOUNT,
            l_lsmv_rec.RECEIVABLES_INVOICE_ID,
            l_lsmv_rec.TAX_AMOUNT,
			l_lsmv_rec.LATE_INT_ASSESS_DATE,
		  	l_lsmv_rec.LATE_CHARGE_ASS_YN,
		    l_lsmv_rec.LATE_CHARGE_ASSESS_DATE,
		    l_lsmv_rec.LATE_INT_ASS_YN,
		    l_lsmv_rec.PAY_STATUS_CODE,
        l_lsmv_rec.DATE_DISBURSED,
		    l_lsmv_rec.investor_disb_status,
		    l_lsmv_rec.investor_disb_err_mg,
            l_lsmv_rec.sel_id,
            l_lsmv_rec.ATTRIBUTE_CATEGORY,
            l_lsmv_rec.ATTRIBUTE1,
            l_lsmv_rec.ATTRIBUTE2,
            l_lsmv_rec.ATTRIBUTE3,
            l_lsmv_rec.ATTRIBUTE4,
            l_lsmv_rec.ATTRIBUTE5,
            l_lsmv_rec.ATTRIBUTE6,
            l_lsmv_rec.ATTRIBUTE7,
            l_lsmv_rec.ATTRIBUTE8,
            l_lsmv_rec.ATTRIBUTE9,
            l_lsmv_rec.ATTRIBUTE10,
            l_lsmv_rec.ATTRIBUTE11,
            l_lsmv_rec.ATTRIBUTE12,
            l_lsmv_rec.ATTRIBUTE13,
            l_lsmv_rec.ATTRIBUTE14,
            l_lsmv_rec.ATTRIBUTE15,
            l_lsmv_rec.REQUEST_ID,
            l_lsmv_rec.PROGRAM_APPLICATION_ID,
            l_lsmv_rec.PROGRAM_ID,
            l_lsmv_rec.PROGRAM_UPDATE_DATE,
            l_lsmv_rec.ORG_ID,
            l_lsmv_rec.CREATED_BY,
            l_lsmv_rec.CREATION_DATE,
            l_lsmv_rec.LAST_UPDATED_BY,
            l_lsmv_rec.LAST_UPDATE_DATE,
            l_lsmv_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_lsmv_pk_csr%NOTFOUND;
  CLOSE okl_lsmv_pk_csr;
  RETURN(l_lsmv_rec);
END get_rec;

FUNCTION get_rec (
  p_lsmv_rec                     IN lsmv_rec_type
) RETURN lsmv_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_lsmv_rec, l_row_notfound));
END get_rec;

----------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_CNSLD_AR_STRMS_V --
----------------------------------------------------------
FUNCTION null_out_defaults (
  p_lsmv_rec	IN lsmv_rec_type
) RETURN lsmv_rec_type IS
  l_lsmv_rec	lsmv_rec_type := p_lsmv_rec;
BEGIN
  IF (l_lsmv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.object_version_number := NULL;
  END IF;
  IF (l_lsmv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.sfwt_flag := NULL;
  END IF;
  IF (l_lsmv_rec.lln_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.lln_id := NULL;
  END IF;
  IF (l_lsmv_rec.kle_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.kle_id := NULL;
  END IF;
  IF (l_lsmv_rec.khr_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.khr_id := NULL;
  END IF;
  IF (l_lsmv_rec.sty_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.sty_id := NULL;
  END IF;
  IF (l_lsmv_rec.amount = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.amount := NULL;
  END IF;
  IF (l_lsmv_rec.receivables_invoice_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.receivables_invoice_id := NULL;
  END IF;
  IF (l_lsmv_rec.tax_amount = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.tax_amount := NULL;
  END IF;
  -- Block Addition
  IF (l_lsmv_rec.LATE_CHARGE_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.LATE_CHARGE_ASS_YN := NULL;
  END IF;
  IF (l_lsmv_rec.LATE_INT_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.LATE_INT_ASSESS_DATE := NULL;
  END IF;
  IF (l_lsmv_rec.LATE_CHARGE_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.LATE_CHARGE_ASSESS_DATE := NULL;
  END IF;
  IF (l_lsmv_rec.LATE_INT_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.LATE_INT_ASS_YN := NULL;
  END IF;
  -- End Block Addition
  IF (l_lsmv_rec.pay_status_code = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.pay_status_code := NULL;
  END IF;

  IF (l_lsmv_rec.date_disbursed = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.date_disbursed := NULL;
  END IF;

  IF (l_lsmv_rec.investor_disb_status = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.investor_disb_status := NULL;
  END IF;
  IF (l_lsmv_rec.investor_disb_err_mg = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.investor_disb_err_mg := NULL;
  END IF;

  IF (l_lsmv_rec.sel_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.sel_id := NULL;
  END IF;

  IF (l_lsmv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute_category := NULL;
  END IF;
  IF (l_lsmv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute1 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute2 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute3 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute4 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute5 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute6 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute7 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute8 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute9 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute10 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute11 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute12 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute13 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute14 := NULL;
  END IF;
  IF (l_lsmv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
    l_lsmv_rec.attribute15 := NULL;
  END IF;
  IF (l_lsmv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.request_id := NULL;
  END IF;
  IF (l_lsmv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.program_application_id := NULL;
  END IF;
  IF (l_lsmv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.program_id := NULL;
  END IF;
  IF (l_lsmv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.program_update_date := NULL;
  END IF;
  IF (l_lsmv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.org_id := NULL;
  END IF;
  IF (l_lsmv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.created_by := NULL;
  END IF;
  IF (l_lsmv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.creation_date := NULL;
  END IF;
  IF (l_lsmv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.last_updated_by := NULL;
  END IF;
  IF (l_lsmv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
    l_lsmv_rec.last_update_date := NULL;
  END IF;
  IF (l_lsmv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
    l_lsmv_rec.last_update_login := NULL;
  END IF;
  RETURN(l_lsmv_rec);
END null_out_defaults;
---------------------------------------------------------------------------
-- PROCEDURE Validate_Attributes
---------------------------------------------------------------------------
--------------------------------------------------
-- Validate_Attributes for:OKL_CNSLD_AR_STRMS_V --
--------------------------------------------------
FUNCTION Validate_Attributes (
  p_lsmv_rec IN  lsmv_rec_type
) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	-- Added 04/19/2001 -- Sunil Mathew
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
    validate_lln_id(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sty_id(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_kle_id(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_id(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_lsmv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

  IF p_lsmv_rec.id = Okc_Api.G_MISS_NUM OR
     p_lsmv_rec.id IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_lsmv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
        p_lsmv_rec.object_version_number IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_lsmv_rec.lln_id = Okc_Api.G_MISS_NUM OR
        p_lsmv_rec.lln_id IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lln_id');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_lsmv_rec.sty_id = Okc_Api.G_MISS_NUM OR
        p_lsmv_rec.sty_id IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  END IF;
  RETURN(l_return_status);
END Validate_Attributes;

---------------------------------------------------------------------------
-- PROCEDURE Validate_Record
---------------------------------------------------------------------------
----------------------------------------------
-- Validate_Record for:OKL_CNSLD_AR_STRMS_V --
----------------------------------------------
FUNCTION Validate_Record (
  p_lsmv_rec IN lsmv_rec_type
) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
BEGIN
  RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------
-- PROCEDURE Migrate
---------------------------------------------------------------------------
PROCEDURE migrate (
  p_from	IN lsmv_rec_type,
  p_to	OUT NOCOPY lsm_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.lln_id := p_from.lln_id;
  p_to.sty_id := p_from.sty_id;
  p_to.kle_id := p_from.kle_id;
  p_to.khr_id := p_from.khr_id;
  p_to.amount := p_from.amount;
  p_to.object_version_number := p_from.object_version_number;
  p_to.receivables_invoice_id := p_from.receivables_invoice_id;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
  p_to.org_id := p_from.org_id;
  p_to.tax_amount := p_from.tax_amount;
  p_to.LATE_INT_ASSESS_DATE := p_from.LATE_INT_ASSESS_DATE;
  p_to.LATE_CHARGE_ASS_YN := p_from.LATE_CHARGE_ASS_YN;
  p_to.LATE_CHARGE_ASSESS_DATE := p_from.LATE_CHARGE_ASSESS_DATE;
  p_to.LATE_INT_ASS_YN := p_from.LATE_INT_ASS_YN;
  p_to.PAY_STATUS_CODE := p_from.PAY_STATUS_CODE;
  p_to.DATE_DISBURSED := p_from.DATE_DISBURSED;
  p_to.investor_disb_status := p_from.investor_disb_status;
  p_to.investor_disb_err_mg := p_from.investor_disb_err_mg;
  p_to.sel_id := p_from.sel_id;
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
  p_from	IN lsm_rec_type,
  p_to	OUT NOCOPY lsmv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.lln_id := p_from.lln_id;
  p_to.sty_id := p_from.sty_id;
  p_to.kle_id := p_from.kle_id;
  p_to.khr_id := p_from.khr_id;
  p_to.amount := p_from.amount;
  p_to.object_version_number := p_from.object_version_number;
  p_to.receivables_invoice_id := p_from.receivables_invoice_id;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
  p_to.org_id := p_from.org_id;
  p_to.tax_amount := p_from.tax_amount;
  p_to.LATE_INT_ASSESS_DATE := p_from.LATE_INT_ASSESS_DATE;
  p_to.LATE_CHARGE_ASS_YN := p_from.LATE_CHARGE_ASS_YN;
  p_to.LATE_CHARGE_ASSESS_DATE := p_from.LATE_CHARGE_ASSESS_DATE;
  p_to.LATE_INT_ASS_YN := p_from.LATE_INT_ASS_YN;
  p_to.PAY_STATUS_CODE := p_from.PAY_STATUS_CODE;
  p_to.DATE_DISBURSED := p_from.DATE_DISBURSED;
  p_to.investor_disb_status := p_from.investor_disb_status;
  p_to.investor_disb_err_mg := p_from.investor_disb_err_mg;
  p_to.sel_id := p_from.sel_id;
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
  p_from	IN lsmv_rec_type,
  p_to	OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sfwt_flag := p_from.sfwt_flag;
  p_to.created_by := p_from.created_by;
  p_to.creation_date := p_from.creation_date;
  p_to.last_updated_by := p_from.last_updated_by;
  p_to.last_update_date := p_from.last_update_date;
  p_to.last_update_login := p_from.last_update_login;
END migrate;
PROCEDURE migrate (
  p_from	IN okl_cnsld_ar_strms_tl_rec_type,
  p_to	OUT NOCOPY lsmv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sfwt_flag := p_from.sfwt_flag;
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
-- validate_row for:OKL_CNSLD_AR_STRMS_V --
-------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_rec                     IN lsmv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsmv_rec                     lsmv_rec_type := p_lsmv_rec;
  l_lsm_rec                      lsm_rec_type;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
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
  l_return_status := Validate_Attributes(l_lsmv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_lsmv_rec);
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
-- PL/SQL TBL validate_row for:LSMV_TBL --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_tbl                     IN lsmv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_lsmv_tbl.COUNT > 0) THEN
    i := p_lsmv_tbl.FIRST;
    LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lsmv_rec                     => p_lsmv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
      EXIT WHEN (i = p_lsmv_tbl.LAST);
      i := p_lsmv_tbl.NEXT(i);
    END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
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
-----------------------------------------
-- insert_row for:OKL_CNSLD_AR_STRMS_B --
-----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsm_rec                      IN lsm_rec_type,
  x_lsm_rec                      OUT NOCOPY lsm_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsm_rec                      lsm_rec_type := p_lsm_rec;
  l_def_lsm_rec                  lsm_rec_type;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_B --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lsm_rec IN  lsm_rec_type,
    x_lsm_rec OUT NOCOPY lsm_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsm_rec := p_lsm_rec;
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
    p_lsm_rec,                         -- IN
    l_lsm_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  INSERT INTO OKL_CNSLD_AR_STRMS_B(
      id,
      lln_id,
      sty_id,
      kle_id,
	  khr_id,
      amount,
      object_version_number,
      receivables_invoice_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      org_id,
      tax_amount,
	  LATE_INT_ASSESS_DATE,
	  LATE_CHARGE_ASS_YN,
	  LATE_CHARGE_ASSESS_DATE,
	  LATE_INT_ASS_YN,
	  PAY_STATUS_CODE,
    DATE_DISBURSED,
      investor_disb_status,
      investor_disb_err_mg,
      sel_id,
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
      l_lsm_rec.id,
      l_lsm_rec.lln_id,
      l_lsm_rec.sty_id,
      l_lsm_rec.kle_id,
	  l_lsm_rec.khr_id,
      l_lsm_rec.amount,
      l_lsm_rec.object_version_number,
      l_lsm_rec.receivables_invoice_id,
      l_lsm_rec.request_id,
      l_lsm_rec.program_application_id,
      l_lsm_rec.program_id,
      l_lsm_rec.program_update_date,
      l_lsm_rec.org_id,
      l_lsm_rec.tax_amount,
	  l_lsm_rec.LATE_INT_ASSESS_DATE,
	  l_lsm_rec.LATE_CHARGE_ASS_YN,
	  l_lsm_rec.LATE_CHARGE_ASSESS_DATE,
	  l_lsm_rec.LATE_INT_ASS_YN,
	  l_lsm_rec.PAY_STATUS_CODE,
	  l_lsm_rec.DATE_DISBURSED,
	  l_lsm_rec.investor_disb_status,
	  l_lsm_rec.investor_disb_err_mg,
      l_lsm_rec.sel_id,
      l_lsm_rec.attribute_category,
      l_lsm_rec.attribute1,
      l_lsm_rec.attribute2,
      l_lsm_rec.attribute3,
      l_lsm_rec.attribute4,
      l_lsm_rec.attribute5,
      l_lsm_rec.attribute6,
      l_lsm_rec.attribute7,
      l_lsm_rec.attribute8,
      l_lsm_rec.attribute9,
      l_lsm_rec.attribute10,
      l_lsm_rec.attribute11,
      l_lsm_rec.attribute12,
      l_lsm_rec.attribute13,
      l_lsm_rec.attribute14,
      l_lsm_rec.attribute15,
      l_lsm_rec.created_by,
      l_lsm_rec.creation_date,
      l_lsm_rec.last_updated_by,
      l_lsm_rec.last_update_date,
      l_lsm_rec.last_update_login);
  -- Set OUT values
  x_lsm_rec := l_lsm_rec;
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
------------------------------------------
-- insert_row for:OKL_CNSLD_AR_STRMS_TL --
------------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type,
  x_okl_cnsld_ar_strms_tl_rec    OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type := p_okl_cnsld_ar_strms_tl_rec;
  ldefoklcnsldarstrmstlrec       okl_cnsld_ar_strms_tl_rec_type;
  CURSOR get_languages IS
    SELECT *
      FROM FND_LANGUAGES
     WHERE INSTALLED_FLAG IN ('I', 'B');
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_strms_tl_rec IN  okl_cnsld_ar_strms_tl_rec_type,
    x_okl_cnsld_ar_strms_tl_rec OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_strms_tl_rec := p_okl_cnsld_ar_strms_tl_rec;
    x_okl_cnsld_ar_strms_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_cnsld_ar_strms_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_cnsld_ar_strms_tl_rec,       -- IN
    l_okl_cnsld_ar_strms_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  FOR l_lang_rec IN get_languages LOOP
    l_okl_cnsld_ar_strms_tl_rec.LANGUAGE := l_lang_rec.language_code;
    INSERT INTO OKL_CNSLD_AR_STRMS_TL(
        id,
        LANGUAGE,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_cnsld_ar_strms_tl_rec.id,
        l_okl_cnsld_ar_strms_tl_rec.LANGUAGE,
        l_okl_cnsld_ar_strms_tl_rec.source_lang,
        l_okl_cnsld_ar_strms_tl_rec.sfwt_flag,
        l_okl_cnsld_ar_strms_tl_rec.created_by,
        l_okl_cnsld_ar_strms_tl_rec.creation_date,
        l_okl_cnsld_ar_strms_tl_rec.last_updated_by,
        l_okl_cnsld_ar_strms_tl_rec.last_update_date,
        l_okl_cnsld_ar_strms_tl_rec.last_update_login);
  END LOOP;
  -- Set OUT values
  x_okl_cnsld_ar_strms_tl_rec := l_okl_cnsld_ar_strms_tl_rec;
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
-- insert_row for:OKL_CNSLD_AR_STRMS_V --
-----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_rec                     IN lsmv_rec_type,
  x_lsmv_rec                     OUT NOCOPY lsmv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsmv_rec                     lsmv_rec_type;
  l_def_lsmv_rec                 lsmv_rec_type;
  l_lsm_rec                      lsm_rec_type;
  lx_lsm_rec                     lsm_rec_type;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
  lx_okl_cnsld_ar_strms_tl_rec   okl_cnsld_ar_strms_tl_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_lsmv_rec	IN lsmv_rec_type
  ) RETURN lsmv_rec_type IS
    l_lsmv_rec	lsmv_rec_type := p_lsmv_rec;
  BEGIN
    l_lsmv_rec.CREATION_DATE := SYSDATE;
    l_lsmv_rec.CREATED_BY := Fnd_Global.USER_ID;
    l_lsmv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_lsmv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_lsmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_lsmv_rec);
  END fill_who_columns;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_V --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lsmv_rec IN  lsmv_rec_type,
    x_lsmv_rec OUT NOCOPY lsmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsmv_rec := p_lsmv_rec;
    x_lsmv_rec.OBJECT_VERSION_NUMBER := 1;
    x_lsmv_rec.SFWT_FLAG := 'N';

	IF (x_lsmv_rec.request_id IS NULL OR x_lsmv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_lsmv_rec.request_id,
	  	   x_lsmv_rec.program_application_id,
	  	   x_lsmv_rec.program_id,
	  	   x_lsmv_rec.program_update_date
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
  l_lsmv_rec := null_out_defaults(p_lsmv_rec);
  -- Set primary key value
  l_lsmv_rec.ID := get_seq_id;
  --- Setting item attributes
  l_return_status := Set_Attributes(
    l_lsmv_rec,                        -- IN
    l_def_lsmv_rec);                   -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_lsmv_rec := fill_who_columns(l_def_lsmv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_lsmv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_lsmv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_lsmv_rec, l_lsm_rec);
  migrate(l_def_lsmv_rec, l_okl_cnsld_ar_strms_tl_rec);
  --------------------------------------------
  -- Call the INSERT_ROW for each child record
  --------------------------------------------
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lsm_rec,
    lx_lsm_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_lsm_rec, l_def_lsmv_rec);
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_strms_tl_rec,
    lx_okl_cnsld_ar_strms_tl_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_cnsld_ar_strms_tl_rec, l_def_lsmv_rec);
  -- Set OUT values
  x_lsmv_rec := l_def_lsmv_rec;
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
-- PL/SQL TBL insert_row for:LSMV_TBL --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_tbl                     IN lsmv_tbl_type,
  x_lsmv_tbl                     OUT NOCOPY lsmv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_lsmv_tbl.COUNT > 0) THEN
    i := p_lsmv_tbl.FIRST;
    LOOP
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lsmv_rec                     => p_lsmv_tbl(i),
        x_lsmv_rec                     => x_lsmv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
      EXIT WHEN (i = p_lsmv_tbl.LAST);
      i := p_lsmv_tbl.NEXT(i);
    END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

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
---------------------------------------
-- lock_row for:OKL_CNSLD_AR_STRMS_B --
---------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsm_rec                      IN lsm_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_lsm_rec IN lsm_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CNSLD_AR_STRMS_B
   WHERE ID = p_lsm_rec.id
     AND OBJECT_VERSION_NUMBER = p_lsm_rec.object_version_number
  FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR  lchk_csr (p_lsm_rec IN lsm_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CNSLD_AR_STRMS_B
  WHERE ID = p_lsm_rec.id;
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_object_version_number       OKL_CNSLD_AR_STRMS_B.OBJECT_VERSION_NUMBER%TYPE;
  lc_object_version_number      OKL_CNSLD_AR_STRMS_B.OBJECT_VERSION_NUMBER%TYPE;
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
    OPEN lock_csr(p_lsm_rec);
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
    OPEN lchk_csr(p_lsm_rec);
    FETCH lchk_csr INTO lc_object_version_number;
    lc_row_notfound := lchk_csr%NOTFOUND;
    CLOSE lchk_csr;
  END IF;
  IF (lc_row_notfound) THEN
    Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number > p_lsm_rec.object_version_number THEN
    Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number <> p_lsm_rec.object_version_number THEN
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
----------------------------------------
-- lock_row for:OKL_CNSLD_AR_STRMS_TL --
----------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_okl_cnsld_ar_strms_tl_rec IN okl_cnsld_ar_strms_tl_rec_type) IS
  SELECT *
    FROM OKL_CNSLD_AR_STRMS_TL
   WHERE ID = p_okl_cnsld_ar_strms_tl_rec.id
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
    OPEN lock_csr(p_okl_cnsld_ar_strms_tl_rec);
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
---------------------------------------
-- lock_row for:OKL_CNSLD_AR_STRMS_V --
---------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_rec                     IN lsmv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsm_rec                      lsm_rec_type;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
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
  migrate(p_lsmv_rec, l_lsm_rec);
  migrate(p_lsmv_rec, l_okl_cnsld_ar_strms_tl_rec);
  --------------------------------------------
  -- Call the LOCK_ROW for each child record
  --------------------------------------------
  lock_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lsm_rec
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
    l_okl_cnsld_ar_strms_tl_rec
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
-- PL/SQL TBL lock_row for:LSMV_TBL --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_tbl                     IN lsmv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_lsmv_tbl.COUNT > 0) THEN
    i := p_lsmv_tbl.FIRST;
    LOOP
      lock_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lsmv_rec                     => p_lsmv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_lsmv_tbl.LAST);
      i := p_lsmv_tbl.NEXT(i);
    END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
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
-----------------------------------------
-- update_row for:OKL_CNSLD_AR_STRMS_B --
-----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsm_rec                      IN lsm_rec_type,
  x_lsm_rec                      OUT NOCOPY lsm_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsm_rec                      lsm_rec_type := p_lsm_rec;
  l_def_lsm_rec                  lsm_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_lsm_rec	IN lsm_rec_type,
    x_lsm_rec	OUT NOCOPY lsm_rec_type
  ) RETURN VARCHAR2 IS
    l_lsm_rec                      lsm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsm_rec := p_lsm_rec;
    -- Get current database values
    l_lsm_rec := get_rec(p_lsm_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_lsm_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.id := l_lsm_rec.id;
    END IF;
    IF (x_lsm_rec.lln_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.lln_id := l_lsm_rec.lln_id;
    END IF;
    IF (x_lsm_rec.sty_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.sty_id := l_lsm_rec.sty_id;
    END IF;
    IF (x_lsm_rec.kle_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.kle_id := l_lsm_rec.kle_id;
    END IF;
    IF (x_lsm_rec.khr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.khr_id := l_lsm_rec.khr_id;
    END IF;
    IF (x_lsm_rec.amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.amount := l_lsm_rec.amount;
    END IF;
    IF (x_lsm_rec.object_version_number = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.object_version_number := l_lsm_rec.object_version_number;
    END IF;
    IF (x_lsm_rec.receivables_invoice_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.receivables_invoice_id := l_lsm_rec.receivables_invoice_id;
    END IF;
    IF (x_lsm_rec.request_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.request_id := l_lsm_rec.request_id;
    END IF;
    IF (x_lsm_rec.program_application_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.program_application_id := l_lsm_rec.program_application_id;
    END IF;
    IF (x_lsm_rec.program_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.program_id := l_lsm_rec.program_id;
    END IF;
    IF (x_lsm_rec.program_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsm_rec.program_update_date := l_lsm_rec.program_update_date;
    END IF;
    IF (x_lsm_rec.org_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.org_id := l_lsm_rec.org_id;
    END IF;
    IF (x_lsm_rec.tax_amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.tax_amount := l_lsm_rec.tax_amount;
    END IF;
    -- Block Addition
    IF (x_lsm_rec.LATE_CHARGE_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
        x_lsm_rec.LATE_CHARGE_ASS_YN := NULL;
    END IF;
    IF (x_lsm_rec.LATE_INT_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
        x_lsm_rec.LATE_INT_ASSESS_DATE := NULL;
    END IF;
    IF (x_lsm_rec.LATE_CHARGE_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
        x_lsm_rec.LATE_CHARGE_ASSESS_DATE := NULL;
    END IF;
    IF (x_lsm_rec.LATE_INT_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
        x_lsm_rec.LATE_INT_ASS_YN := NULL;
    END IF;
    -- End Block Addition
    IF (x_lsm_rec.pay_status_code = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.pay_status_code := l_lsm_rec.pay_status_code;
    END IF;

    IF (x_lsm_rec.DATE_DISBURSED = Okc_Api.G_MISS_DATE) THEN
        x_lsm_rec.DATE_DISBURSED := NULL;
    END IF;

    IF (x_lsm_rec.investor_disb_status = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.investor_disb_status := l_lsm_rec.investor_disb_status;
    END IF;

    IF (x_lsm_rec.investor_disb_err_mg = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.investor_disb_err_mg := l_lsm_rec.investor_disb_err_mg;
    END IF;

    IF (x_lsm_rec.sel_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.sel_id := l_lsm_rec.sel_id;
    END IF;

    IF (x_lsm_rec.attribute_category = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute_category := l_lsm_rec.attribute_category;
    END IF;
    IF (x_lsm_rec.attribute1 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute1 := l_lsm_rec.attribute1;
    END IF;
    IF (x_lsm_rec.attribute2 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute2 := l_lsm_rec.attribute2;
    END IF;
    IF (x_lsm_rec.attribute3 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute3 := l_lsm_rec.attribute3;
    END IF;
    IF (x_lsm_rec.attribute4 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute4 := l_lsm_rec.attribute4;
    END IF;
    IF (x_lsm_rec.attribute5 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute5 := l_lsm_rec.attribute5;
    END IF;
    IF (x_lsm_rec.attribute6 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute6 := l_lsm_rec.attribute6;
    END IF;
    IF (x_lsm_rec.attribute7 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute7 := l_lsm_rec.attribute7;
    END IF;
    IF (x_lsm_rec.attribute8 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute8 := l_lsm_rec.attribute8;
    END IF;
    IF (x_lsm_rec.attribute9 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute9 := l_lsm_rec.attribute9;
    END IF;
    IF (x_lsm_rec.attribute10 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute10 := l_lsm_rec.attribute10;
    END IF;
    IF (x_lsm_rec.attribute11 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute11 := l_lsm_rec.attribute11;
    END IF;
    IF (x_lsm_rec.attribute12 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute12 := l_lsm_rec.attribute12;
    END IF;
    IF (x_lsm_rec.attribute13 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute13 := l_lsm_rec.attribute13;
    END IF;
    IF (x_lsm_rec.attribute14 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute14 := l_lsm_rec.attribute14;
    END IF;
    IF (x_lsm_rec.attribute15 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsm_rec.attribute15 := l_lsm_rec.attribute15;
    END IF;
    IF (x_lsm_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.created_by := l_lsm_rec.created_by;
    END IF;
    IF (x_lsm_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsm_rec.creation_date := l_lsm_rec.creation_date;
    END IF;
    IF (x_lsm_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.last_updated_by := l_lsm_rec.last_updated_by;
    END IF;
    IF (x_lsm_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsm_rec.last_update_date := l_lsm_rec.last_update_date;
    END IF;
    IF (x_lsm_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_lsm_rec.last_update_login := l_lsm_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_B --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lsm_rec IN  lsm_rec_type,
    x_lsm_rec OUT NOCOPY lsm_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsm_rec := p_lsm_rec;
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
    p_lsm_rec,                         -- IN
    l_lsm_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_lsm_rec, l_def_lsm_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_CNSLD_AR_STRMS_B
  SET LLN_ID = l_def_lsm_rec.lln_id,
      STY_ID = l_def_lsm_rec.sty_id,
      KLE_ID = l_def_lsm_rec.kle_id,
      KHR_ID = l_def_lsm_rec.khr_id,
      AMOUNT = l_def_lsm_rec.amount,
      OBJECT_VERSION_NUMBER = l_def_lsm_rec.object_version_number,
      RECEIVABLES_INVOICE_ID = l_def_lsm_rec.receivables_invoice_id,
      REQUEST_ID = l_def_lsm_rec.request_id,
      PROGRAM_APPLICATION_ID = l_def_lsm_rec.program_application_id,
      PROGRAM_ID = l_def_lsm_rec.program_id,
      PROGRAM_UPDATE_DATE = l_def_lsm_rec.program_update_date,
      ORG_ID = l_def_lsm_rec.org_id,
      TAX_AMOUNT = l_def_lsm_rec.tax_amount,
      LATE_INT_ASSESS_DATE = l_def_lsm_rec.LATE_INT_ASSESS_DATE,
      LATE_CHARGE_ASS_YN = l_def_lsm_rec.LATE_CHARGE_ASS_YN,
      LATE_CHARGE_ASSESS_DATE = l_def_lsm_rec.LATE_CHARGE_ASSESS_DATE,
      LATE_INT_ASS_YN = l_def_lsm_rec.LATE_INT_ASS_YN,
      PAY_STATUS_CODE = l_def_lsm_rec.PAY_STATUS_CODE,
      DATE_DISBURSED = l_def_lsm_rec.DATE_DISBURSED,
      investor_disb_status = l_def_lsm_rec.investor_disb_status,
      investor_disb_err_mg = l_def_lsm_rec.investor_disb_err_mg,
      SEL_ID = l_def_lsm_rec.sel_id,
      ATTRIBUTE_CATEGORY = l_def_lsm_rec.attribute_category,
      ATTRIBUTE1 = l_def_lsm_rec.attribute1,
      ATTRIBUTE2 = l_def_lsm_rec.attribute2,
      ATTRIBUTE3 = l_def_lsm_rec.attribute3,
      ATTRIBUTE4 = l_def_lsm_rec.attribute4,
      ATTRIBUTE5 = l_def_lsm_rec.attribute5,
      ATTRIBUTE6 = l_def_lsm_rec.attribute6,
      ATTRIBUTE7 = l_def_lsm_rec.attribute7,
      ATTRIBUTE8 = l_def_lsm_rec.attribute8,
      ATTRIBUTE9 = l_def_lsm_rec.attribute9,
      ATTRIBUTE10 = l_def_lsm_rec.attribute10,
      ATTRIBUTE11 = l_def_lsm_rec.attribute11,
      ATTRIBUTE12 = l_def_lsm_rec.attribute12,
      ATTRIBUTE13 = l_def_lsm_rec.attribute13,
      ATTRIBUTE14 = l_def_lsm_rec.attribute14,
      ATTRIBUTE15 = l_def_lsm_rec.attribute15,
      CREATED_BY = l_def_lsm_rec.created_by,
      CREATION_DATE = l_def_lsm_rec.creation_date,
      LAST_UPDATED_BY = l_def_lsm_rec.last_updated_by,
      LAST_UPDATE_DATE = l_def_lsm_rec.last_update_date,
      LAST_UPDATE_LOGIN = l_def_lsm_rec.last_update_login
  WHERE ID = l_def_lsm_rec.id;

  x_lsm_rec := l_def_lsm_rec;
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
------------------------------------------
-- update_row for:OKL_CNSLD_AR_STRMS_TL --
------------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type,
  x_okl_cnsld_ar_strms_tl_rec    OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type := p_okl_cnsld_ar_strms_tl_rec;
  ldefoklcnsldarstrmstlrec       okl_cnsld_ar_strms_tl_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_okl_cnsld_ar_strms_tl_rec	IN okl_cnsld_ar_strms_tl_rec_type,
    x_okl_cnsld_ar_strms_tl_rec	OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_strms_tl_rec := p_okl_cnsld_ar_strms_tl_rec;
    -- Get current database values
    l_okl_cnsld_ar_strms_tl_rec := get_rec(p_okl_cnsld_ar_strms_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.id := l_okl_cnsld_ar_strms_tl_rec.id;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.LANGUAGE := l_okl_cnsld_ar_strms_tl_rec.LANGUAGE;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.source_lang := l_okl_cnsld_ar_strms_tl_rec.source_lang;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.sfwt_flag := l_okl_cnsld_ar_strms_tl_rec.sfwt_flag;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.created_by := l_okl_cnsld_ar_strms_tl_rec.created_by;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.creation_date := l_okl_cnsld_ar_strms_tl_rec.creation_date;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.last_updated_by := l_okl_cnsld_ar_strms_tl_rec.last_updated_by;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.last_update_date := l_okl_cnsld_ar_strms_tl_rec.last_update_date;
    END IF;
    IF (x_okl_cnsld_ar_strms_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_strms_tl_rec.last_update_login := l_okl_cnsld_ar_strms_tl_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_strms_tl_rec IN  okl_cnsld_ar_strms_tl_rec_type,
    x_okl_cnsld_ar_strms_tl_rec OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_strms_tl_rec := p_okl_cnsld_ar_strms_tl_rec;
    x_okl_cnsld_ar_strms_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_cnsld_ar_strms_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_cnsld_ar_strms_tl_rec,       -- IN
    l_okl_cnsld_ar_strms_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_okl_cnsld_ar_strms_tl_rec, ldefoklcnsldarstrmstlrec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_CNSLD_AR_STRMS_TL
  SET CREATED_BY = ldefoklcnsldarstrmstlrec.created_by,
      CREATION_DATE = ldefoklcnsldarstrmstlrec.creation_date,
      LAST_UPDATED_BY = ldefoklcnsldarstrmstlrec.last_updated_by,
      LAST_UPDATE_DATE = ldefoklcnsldarstrmstlrec.last_update_date,
      LAST_UPDATE_LOGIN = ldefoklcnsldarstrmstlrec.last_update_login
  WHERE ID = ldefoklcnsldarstrmstlrec.id
    --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

  UPDATE  OKL_CNSLD_AR_STRMS_TL
  SET SFWT_FLAG = 'Y'
  WHERE ID = ldefoklcnsldarstrmstlrec.id
    AND SOURCE_LANG <> USERENV('LANG');

  x_okl_cnsld_ar_strms_tl_rec := ldefoklcnsldarstrmstlrec;
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
-- update_row for:OKL_CNSLD_AR_STRMS_V --
-----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_rec                     IN lsmv_rec_type,
  x_lsmv_rec                     OUT NOCOPY lsmv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsmv_rec                     lsmv_rec_type := p_lsmv_rec;
  l_def_lsmv_rec                 lsmv_rec_type;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
  lx_okl_cnsld_ar_strms_tl_rec   okl_cnsld_ar_strms_tl_rec_type;
  l_lsm_rec                      lsm_rec_type;
  lx_lsm_rec                     lsm_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_lsmv_rec	IN lsmv_rec_type
  ) RETURN lsmv_rec_type IS
    l_lsmv_rec	lsmv_rec_type := p_lsmv_rec;
  BEGIN
    l_lsmv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_lsmv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_lsmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_lsmv_rec);
  END fill_who_columns;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_lsmv_rec	IN lsmv_rec_type,
    x_lsmv_rec	OUT NOCOPY lsmv_rec_type
  ) RETURN VARCHAR2 IS
    l_lsmv_rec                     lsmv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsmv_rec := p_lsmv_rec;
    -- Get current database values
    l_lsmv_rec := get_rec(p_lsmv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_lsmv_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.id := l_lsmv_rec.id;
    END IF;
    IF (x_lsmv_rec.object_version_number = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.object_version_number := l_lsmv_rec.object_version_number;
    END IF;
    IF (x_lsmv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.sfwt_flag := l_lsmv_rec.sfwt_flag;
    END IF;
    IF (x_lsmv_rec.lln_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.lln_id := l_lsmv_rec.lln_id;
    END IF;
    IF (x_lsmv_rec.kle_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.kle_id := l_lsmv_rec.kle_id;
    END IF;
    IF (x_lsmv_rec.khr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.khr_id := l_lsmv_rec.khr_id;
    END IF;
    IF (x_lsmv_rec.sty_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.sty_id := l_lsmv_rec.sty_id;
    END IF;
    IF (x_lsmv_rec.amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.amount := l_lsmv_rec.amount;
    END IF;
    IF (x_lsmv_rec.receivables_invoice_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.receivables_invoice_id := l_lsmv_rec.receivables_invoice_id;
    END IF;
    IF (x_lsmv_rec.tax_amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.tax_amount := l_lsmv_rec.tax_amount;
    END IF;
  -- Block Addition
    IF (x_lsmv_rec.LATE_CHARGE_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
        x_lsmv_rec.LATE_CHARGE_ASS_YN := NULL;
    END IF;
    IF (x_lsmv_rec.LATE_INT_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
        x_lsmv_rec.LATE_INT_ASSESS_DATE := NULL;
    END IF;
    IF (x_lsmv_rec.LATE_CHARGE_ASSESS_DATE = Okc_Api.G_MISS_DATE) THEN
        x_lsmv_rec.LATE_CHARGE_ASSESS_DATE := NULL;
    END IF;
    IF (x_lsmv_rec.LATE_INT_ASS_YN = Okc_Api.G_MISS_CHAR) THEN
        x_lsmv_rec.LATE_INT_ASS_YN := NULL;
    END IF;
  -- End Block Addition
    IF (x_lsmv_rec.pay_status_code = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.pay_status_code := l_lsmv_rec.pay_status_code;
    END IF;

    IF (x_lsmv_rec.DATE_DISBURSED = Okc_Api.G_MISS_DATE) THEN
        x_lsmv_rec.DATE_DISBURSED := NULL;
    END IF;

    IF (x_lsmv_rec.investor_disb_status = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.investor_disb_status := l_lsmv_rec.investor_disb_status;
    END IF;

    IF (x_lsmv_rec.investor_disb_err_mg = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.investor_disb_err_mg := l_lsmv_rec.investor_disb_err_mg;
    END IF;

    IF (x_lsmv_rec.sel_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.sel_id := l_lsmv_rec.sel_id;
    END IF;

    IF (x_lsmv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute_category := l_lsmv_rec.attribute_category;
    END IF;
    IF (x_lsmv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute1 := l_lsmv_rec.attribute1;
    END IF;
    IF (x_lsmv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute2 := l_lsmv_rec.attribute2;
    END IF;
    IF (x_lsmv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute3 := l_lsmv_rec.attribute3;
    END IF;
    IF (x_lsmv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute4 := l_lsmv_rec.attribute4;
    END IF;
    IF (x_lsmv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute5 := l_lsmv_rec.attribute5;
    END IF;
    IF (x_lsmv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute6 := l_lsmv_rec.attribute6;
    END IF;
    IF (x_lsmv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute7 := l_lsmv_rec.attribute7;
    END IF;
    IF (x_lsmv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute8 := l_lsmv_rec.attribute8;
    END IF;
    IF (x_lsmv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute9 := l_lsmv_rec.attribute9;
    END IF;
    IF (x_lsmv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute10 := l_lsmv_rec.attribute10;
    END IF;
    IF (x_lsmv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute11 := l_lsmv_rec.attribute11;
    END IF;
    IF (x_lsmv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute12 := l_lsmv_rec.attribute12;
    END IF;
    IF (x_lsmv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute13 := l_lsmv_rec.attribute13;
    END IF;
    IF (x_lsmv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute14 := l_lsmv_rec.attribute14;
    END IF;
    IF (x_lsmv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lsmv_rec.attribute15 := l_lsmv_rec.attribute15;
    END IF;
    IF (x_lsmv_rec.request_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.request_id := l_lsmv_rec.request_id;
    END IF;
    IF (x_lsmv_rec.program_application_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.program_application_id := l_lsmv_rec.program_application_id;
    END IF;
    IF (x_lsmv_rec.program_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.program_id := l_lsmv_rec.program_id;
    END IF;
    IF (x_lsmv_rec.program_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsmv_rec.program_update_date := l_lsmv_rec.program_update_date;
    END IF;
    IF (x_lsmv_rec.org_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.org_id := l_lsmv_rec.org_id;
    END IF;
    IF (x_lsmv_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.created_by := l_lsmv_rec.created_by;
    END IF;
    IF (x_lsmv_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsmv_rec.creation_date := l_lsmv_rec.creation_date;
    END IF;
    IF (x_lsmv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.last_updated_by := l_lsmv_rec.last_updated_by;
    END IF;
    IF (x_lsmv_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lsmv_rec.last_update_date := l_lsmv_rec.last_update_date;
    END IF;
    IF (x_lsmv_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_lsmv_rec.last_update_login := l_lsmv_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_V --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lsmv_rec IN  lsmv_rec_type,
    x_lsmv_rec OUT NOCOPY lsmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lsmv_rec := p_lsmv_rec;
    x_lsmv_rec.OBJECT_VERSION_NUMBER := NVL(x_lsmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_lsmv_rec.request_id IS NULL OR x_lsmv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_lsmv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_lsmv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_lsmv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_lsmv_rec.program_update_date,SYSDATE)
      INTO
        x_lsmv_rec.request_id,
        x_lsmv_rec.program_application_id,
        x_lsmv_rec.program_id,
        x_lsmv_rec.program_update_date
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
    p_lsmv_rec,                        -- IN
    l_lsmv_rec);                       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_lsmv_rec, l_def_lsmv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_lsmv_rec := fill_who_columns(l_def_lsmv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_lsmv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_lsmv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;

  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_lsmv_rec, l_okl_cnsld_ar_strms_tl_rec);
  migrate(l_def_lsmv_rec, l_lsm_rec);
  --------------------------------------------
  -- Call the UPDATE_ROW for each child record
  --------------------------------------------
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_strms_tl_rec,
    lx_okl_cnsld_ar_strms_tl_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_cnsld_ar_strms_tl_rec, l_def_lsmv_rec);
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lsm_rec,
    lx_lsm_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_lsm_rec, l_def_lsmv_rec);
  x_lsmv_rec := l_def_lsmv_rec;
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
-- PL/SQL TBL update_row for:LSMV_TBL --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_tbl                     IN lsmv_tbl_type,
  x_lsmv_tbl                     OUT NOCOPY lsmv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   -- Begin Post-Generation Change
   -- overall error status
   l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   -- End Post-Generation Change

  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_lsmv_tbl.COUNT > 0) THEN
    i := p_lsmv_tbl.FIRST;
    LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lsmv_rec                     => p_lsmv_tbl(i),
        x_lsmv_rec                     => x_lsmv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_lsmv_tbl.LAST);
      i := p_lsmv_tbl.NEXT(i);
    END LOOP;
    -- Begin Post-Generation Change
    -- return overall status
    x_return_status := l_overall_status;
    -- End Post-Generation Change
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
-----------------------------------------
-- delete_row for:OKL_CNSLD_AR_STRMS_B --
-----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsm_rec                      IN lsm_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsm_rec                      lsm_rec_type:= p_lsm_rec;
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
  DELETE FROM OKL_CNSLD_AR_STRMS_B
   WHERE ID = l_lsm_rec.id;

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
------------------------------------------
-- delete_row for:OKL_CNSLD_AR_STRMS_TL --
------------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_strms_tl_rec    IN okl_cnsld_ar_strms_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type:= p_okl_cnsld_ar_strms_tl_rec;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_STRMS_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_strms_tl_rec IN  okl_cnsld_ar_strms_tl_rec_type,
    x_okl_cnsld_ar_strms_tl_rec OUT NOCOPY okl_cnsld_ar_strms_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_strms_tl_rec := p_okl_cnsld_ar_strms_tl_rec;
    x_okl_cnsld_ar_strms_tl_rec.LANGUAGE := USERENV('LANG');
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
    p_okl_cnsld_ar_strms_tl_rec,       -- IN
    l_okl_cnsld_ar_strms_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  DELETE FROM OKL_CNSLD_AR_STRMS_TL
   WHERE ID = l_okl_cnsld_ar_strms_tl_rec.id;

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
-- delete_row for:OKL_CNSLD_AR_STRMS_V --
-----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_rec                     IN lsmv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lsmv_rec                     lsmv_rec_type := p_lsmv_rec;
  l_okl_cnsld_ar_strms_tl_rec    okl_cnsld_ar_strms_tl_rec_type;
  l_lsm_rec                      lsm_rec_type;
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
  migrate(l_lsmv_rec, l_okl_cnsld_ar_strms_tl_rec);
  migrate(l_lsmv_rec, l_lsm_rec);
  --------------------------------------------
  -- Call the DELETE_ROW for each child record
  --------------------------------------------
  delete_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_strms_tl_rec
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
    l_lsm_rec
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
-- PL/SQL TBL delete_row for:LSMV_TBL --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lsmv_tbl                     IN lsmv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_lsmv_tbl.COUNT > 0) THEN
    i := p_lsmv_tbl.FIRST;
    LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_lsmv_rec                     => p_lsmv_tbl(i));
      EXIT WHEN (i = p_lsmv_tbl.LAST);
      i := p_lsmv_tbl.NEXT(i);
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
END Okl_Lsm_Pvt;

/
