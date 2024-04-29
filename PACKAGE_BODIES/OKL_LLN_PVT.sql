--------------------------------------------------------
--  DDL for Package Body OKL_LLN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LLN_PVT" AS
/* $Header: OKLSLLNB.pls 115.11 2004/05/21 21:27:11 pjgomes noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_llnv_rec IN llnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_llnv_rec.id = Okl_Api.G_MISS_NUM OR
       p_llnv_rec.id IS NULL
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

  PROCEDURE validate_org_id (p_llnv_rec IN llnv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_llnv_rec.org_id);

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_llnv_rec IN llnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_llnv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_llnv_rec.object_version_number IS NULL
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
  -- PROCEDURE validate_sequence_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_sequence_number (p_llnv_rec IN llnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_llnv_rec.sequence_number = Okl_Api.G_MISS_NUM OR
       p_llnv_rec.sequence_number IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'sequence_number');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_sequence_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_line_type
  ---------------------------------------------------------------------------
  PROCEDURE validate_line_type (p_llnv_rec IN llnv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_llnv_rec.line_type = Okl_Api.G_MISS_CHAR OR
       p_llnv_rec.line_type IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'line_type');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_line_type;


  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_lln_id_parent
  ---------------------------------------------------------------------------
  PROCEDURE     validate_lln_id_parent(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_lln_id_parent_csr IS
    SELECT '1'
	FROM OKL_CNSLD_AR_LINES_V
	WHERE id = p_llnv_rec.lln_id_parent;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.lln_id_parent IS NOT NULL) THEN
	   	  OPEN l_lln_id_parent_csr;
		  FETCH l_lln_id_parent_csr INTO l_dummy_var;
		  CLOSE l_lln_id_parent_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'LLN_ID_PARENT_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_lln_id_parent;

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_kle_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_kle_id(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_kle_id_csr IS
    SELECT '1'
	FROM OKC_K_LINES_B
	WHERE id = p_llnv_rec.kle_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.kle_id IS NOT NULL) THEN
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
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_kle_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_khr_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_khr_id(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_khr_id_csr IS
    SELECT '1'
	FROM OKL_K_HEADERS_V
	WHERE id = p_llnv_rec.khr_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.khr_id IS NOT NULL) THEN
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
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_khr_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_cnr_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_cnr_id(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_cnr_id_csr IS
    SELECT '1'
	FROM OKL_CNSLD_AR_HDRS_V
	WHERE id = p_llnv_rec.cnr_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.cnr_id IS NOT NULL) THEN
	   	  OPEN l_cnr_id_csr;
		  FETCH l_cnr_id_csr INTO l_dummy_var;
		  CLOSE l_cnr_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'CNR_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_cnr_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_ilt_id
  ---------------------------------------------------------------------------
  PROCEDURE     validate_ilt_id(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ilt_id_csr IS
    SELECT '1'
	FROM OKL_INVC_LINE_TYPES_V
	WHERE id = p_llnv_rec.ilt_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.ilt_id IS NOT NULL) THEN
	   	  OPEN l_ilt_id_csr;
		  FETCH l_ilt_id_csr INTO l_dummy_var;
		  CLOSE l_ilt_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'ILT_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ilt_id;

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE     validate_currency_code
  ---------------------------------------------------------------------------
  PROCEDURE     validate_currency_code(p_llnv_rec IN llnv_rec_type,
  									x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_currency_code_csr IS
    SELECT '1'
	FROM fnd_currencies_vl
	WHERE currency_code = p_llnv_rec.currency_code;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	   IF (p_llnv_rec.currency_code IS NOT NULL) THEN
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
								 p_token3_value		=> 'OKL_CNSLD_AR_LINES_V'	);

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_currency_code;
*/

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
    DELETE FROM OKL_CNSLD_AR_LINES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CNSLD_AR_LINES_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

  /*

     Post-Generation Change
     By RDRAGUIL on 20-Apr-2001

     Since the table does not have any meaningful columns,
       UPDATE statement is not complete.
     Please comment out WHERE condition if
       UPDATE statement is not present
     If new release has some columns in the table,
       this modification is not needed

    WHERE (
            T.ID,
            T.LANGUAGE)
        IN (SELECT
                SUBT.ID,
                SUBT.LANGUAGE
              FROM OKL_CNSLD_AR_LINES_TL SUBB, OKL_CNSLD_AR_LINES_TL SUBT
             WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
  */

  INSERT INTO OKL_CNSLD_AR_LINES_TL (
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
      FROM OKL_CNSLD_AR_LINES_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND B.LANGUAGE = USERENV('LANG')
       AND NOT EXISTS(
                  SELECT NULL
                    FROM OKL_CNSLD_AR_LINES_TL T
                   WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                  );

END add_language;

---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_LINES_B
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_lln_rec                      IN lln_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN lln_rec_type IS
  CURSOR okl_cnsld_ar_lines_b_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          SEQUENCE_NUMBER,
          LLN_ID_PARENT,
          KLE_ID,
          KHR_ID,
          CNR_ID,
          ILT_ID,
          LINE_TYPE,
          AMOUNT,
          OBJECT_VERSION_NUMBER,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          ORG_ID,
		  TAX_AMOUNT,
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
    FROM Okl_Cnsld_Ar_Lines_B
   WHERE okl_cnsld_ar_lines_b.id = p_id;
  l_okl_cnsld_ar_lines_b_pk      okl_cnsld_ar_lines_b_pk_csr%ROWTYPE;
  l_lln_rec                      lln_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_cnsld_ar_lines_b_pk_csr (p_lln_rec.id);
  FETCH okl_cnsld_ar_lines_b_pk_csr INTO
            l_lln_rec.ID,
            l_lln_rec.SEQUENCE_NUMBER,
            l_lln_rec.LLN_ID_PARENT,
            l_lln_rec.KLE_ID,
            l_lln_rec.KHR_ID,
            l_lln_rec.CNR_ID,
            l_lln_rec.ILT_ID,
            l_lln_rec.LINE_TYPE,
            l_lln_rec.AMOUNT,
            l_lln_rec.OBJECT_VERSION_NUMBER,
            l_lln_rec.REQUEST_ID,
            l_lln_rec.PROGRAM_APPLICATION_ID,
            l_lln_rec.PROGRAM_ID,
            l_lln_rec.PROGRAM_UPDATE_DATE,
            l_lln_rec.ORG_ID,
            l_lln_rec.TAX_AMOUNT,
            l_lln_rec.ATTRIBUTE_CATEGORY,
            l_lln_rec.ATTRIBUTE1,
            l_lln_rec.ATTRIBUTE2,
            l_lln_rec.ATTRIBUTE3,
            l_lln_rec.ATTRIBUTE4,
            l_lln_rec.ATTRIBUTE5,
            l_lln_rec.ATTRIBUTE6,
            l_lln_rec.ATTRIBUTE7,
            l_lln_rec.ATTRIBUTE8,
            l_lln_rec.ATTRIBUTE9,
            l_lln_rec.ATTRIBUTE10,
            l_lln_rec.ATTRIBUTE11,
            l_lln_rec.ATTRIBUTE12,
            l_lln_rec.ATTRIBUTE13,
            l_lln_rec.ATTRIBUTE14,
            l_lln_rec.ATTRIBUTE15,
            l_lln_rec.CREATED_BY,
            l_lln_rec.CREATION_DATE,
            l_lln_rec.LAST_UPDATED_BY,
            l_lln_rec.LAST_UPDATE_DATE,
            l_lln_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_cnsld_ar_lines_b_pk_csr%NOTFOUND;
  CLOSE okl_cnsld_ar_lines_b_pk_csr;
  RETURN(l_lln_rec);
END get_rec;

FUNCTION get_rec (
  p_lln_rec                      IN lln_rec_type
) RETURN lln_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_lln_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_LINES_TL
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN okl_cnsld_ar_lines_tl_rec_type IS
  CURSOR okl_cnsld_ar_lines_tl_pk_csr (p_id                 IN NUMBER,
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
    FROM Okl_Cnsld_Ar_Lines_Tl
   WHERE okl_cnsld_ar_lines_tl.id = p_id
     AND okl_cnsld_ar_lines_tl.LANGUAGE = p_language;
  l_okl_cnsld_ar_lines_tl_pk     okl_cnsld_ar_lines_tl_pk_csr%ROWTYPE;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_cnsld_ar_lines_tl_pk_csr (p_okl_cnsld_ar_lines_tl_rec.id,
                                     p_okl_cnsld_ar_lines_tl_rec.LANGUAGE);
  FETCH okl_cnsld_ar_lines_tl_pk_csr INTO
            l_okl_cnsld_ar_lines_tl_rec.ID,
            l_okl_cnsld_ar_lines_tl_rec.LANGUAGE,
            l_okl_cnsld_ar_lines_tl_rec.SOURCE_LANG,
            l_okl_cnsld_ar_lines_tl_rec.SFWT_FLAG,
            l_okl_cnsld_ar_lines_tl_rec.CREATED_BY,
            l_okl_cnsld_ar_lines_tl_rec.CREATION_DATE,
            l_okl_cnsld_ar_lines_tl_rec.LAST_UPDATED_BY,
            l_okl_cnsld_ar_lines_tl_rec.LAST_UPDATE_DATE,
            l_okl_cnsld_ar_lines_tl_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_cnsld_ar_lines_tl_pk_csr%NOTFOUND;
  CLOSE okl_cnsld_ar_lines_tl_pk_csr;
  RETURN(l_okl_cnsld_ar_lines_tl_rec);
END get_rec;

FUNCTION get_rec (
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type
) RETURN okl_cnsld_ar_lines_tl_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_okl_cnsld_ar_lines_tl_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_CNSLD_AR_LINES_V
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_llnv_rec                     IN llnv_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN llnv_rec_type IS
  CURSOR okl_llnv_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          OBJECT_VERSION_NUMBER,
          SFWT_FLAG,
          KHR_ID,
          CNR_ID,
          KLE_ID,
          LLN_ID_PARENT,
          ILT_ID,
          SEQUENCE_NUMBER,
          AMOUNT,
          TAX_AMOUNT,
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
          LINE_TYPE,
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
    FROM Okl_Cnsld_Ar_Lines_V
   WHERE okl_cnsld_ar_lines_v.id = p_id;
  l_okl_llnv_pk                  okl_llnv_pk_csr%ROWTYPE;
  l_llnv_rec                     llnv_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_llnv_pk_csr (p_llnv_rec.id);
  FETCH okl_llnv_pk_csr INTO
            l_llnv_rec.ID,
            l_llnv_rec.OBJECT_VERSION_NUMBER,
            l_llnv_rec.SFWT_FLAG,
            l_llnv_rec.KHR_ID,
            l_llnv_rec.CNR_ID,
            l_llnv_rec.KLE_ID,
            l_llnv_rec.LLN_ID_PARENT,
            l_llnv_rec.ILT_ID,
            l_llnv_rec.SEQUENCE_NUMBER,
            l_llnv_rec.AMOUNT,
            l_llnv_rec.TAX_AMOUNT,
            l_llnv_rec.ATTRIBUTE_CATEGORY,
            l_llnv_rec.ATTRIBUTE1,
            l_llnv_rec.ATTRIBUTE2,
            l_llnv_rec.ATTRIBUTE3,
            l_llnv_rec.ATTRIBUTE4,
            l_llnv_rec.ATTRIBUTE5,
            l_llnv_rec.ATTRIBUTE6,
            l_llnv_rec.ATTRIBUTE7,
            l_llnv_rec.ATTRIBUTE8,
            l_llnv_rec.ATTRIBUTE9,
            l_llnv_rec.ATTRIBUTE10,
            l_llnv_rec.ATTRIBUTE11,
            l_llnv_rec.ATTRIBUTE12,
            l_llnv_rec.ATTRIBUTE13,
            l_llnv_rec.ATTRIBUTE14,
            l_llnv_rec.ATTRIBUTE15,
            l_llnv_rec.LINE_TYPE,
            l_llnv_rec.REQUEST_ID,
            l_llnv_rec.PROGRAM_APPLICATION_ID,
            l_llnv_rec.PROGRAM_ID,
            l_llnv_rec.PROGRAM_UPDATE_DATE,
            l_llnv_rec.ORG_ID,
            l_llnv_rec.CREATED_BY,
            l_llnv_rec.CREATION_DATE,
            l_llnv_rec.LAST_UPDATED_BY,
            l_llnv_rec.LAST_UPDATE_DATE,
            l_llnv_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_llnv_pk_csr%NOTFOUND;
  CLOSE okl_llnv_pk_csr;
  RETURN(l_llnv_rec);
END get_rec;

FUNCTION get_rec (
  p_llnv_rec                     IN llnv_rec_type
) RETURN llnv_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_llnv_rec, l_row_notfound));
END get_rec;

----------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_CNSLD_AR_LINES_V --
----------------------------------------------------------
FUNCTION null_out_defaults (
  p_llnv_rec	IN llnv_rec_type
) RETURN llnv_rec_type IS
  l_llnv_rec	llnv_rec_type := p_llnv_rec;
BEGIN
  IF (l_llnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.object_version_number := NULL;
  END IF;
  IF (l_llnv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.sfwt_flag := NULL;
  END IF;
  IF (l_llnv_rec.khr_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.khr_id := NULL;
  END IF;
  IF (l_llnv_rec.cnr_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.cnr_id := NULL;
  END IF;
  IF (l_llnv_rec.kle_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.kle_id := NULL;
  END IF;
  IF (l_llnv_rec.lln_id_parent = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.lln_id_parent := NULL;
  END IF;
  IF (l_llnv_rec.ilt_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.ilt_id := NULL;
  END IF;
  IF (l_llnv_rec.sequence_number = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.sequence_number := NULL;
  END IF;
  IF (l_llnv_rec.amount = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.amount := NULL;
  END IF;
  IF (l_llnv_rec.tax_amount = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.tax_amount := NULL;
  END IF;
  IF (l_llnv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute_category := NULL;
  END IF;
  IF (l_llnv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute1 := NULL;
  END IF;
  IF (l_llnv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute2 := NULL;
  END IF;
  IF (l_llnv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute3 := NULL;
  END IF;
  IF (l_llnv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute4 := NULL;
  END IF;
  IF (l_llnv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute5 := NULL;
  END IF;
  IF (l_llnv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute6 := NULL;
  END IF;
  IF (l_llnv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute7 := NULL;
  END IF;
  IF (l_llnv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute8 := NULL;
  END IF;
  IF (l_llnv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute9 := NULL;
  END IF;
  IF (l_llnv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute10 := NULL;
  END IF;
  IF (l_llnv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute11 := NULL;
  END IF;
  IF (l_llnv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute12 := NULL;
  END IF;
  IF (l_llnv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute13 := NULL;
  END IF;
  IF (l_llnv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute14 := NULL;
  END IF;
  IF (l_llnv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.attribute15 := NULL;
  END IF;
  IF (l_llnv_rec.line_type = Okc_Api.G_MISS_CHAR) THEN
    l_llnv_rec.line_type := NULL;
  END IF;
  IF (l_llnv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.request_id := NULL;
  END IF;
  IF (l_llnv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.program_application_id := NULL;
  END IF;
  IF (l_llnv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.program_id := NULL;
  END IF;
  IF (l_llnv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
    l_llnv_rec.program_update_date := NULL;
  END IF;
  IF (l_llnv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.org_id := NULL;
  END IF;
  IF (l_llnv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.created_by := NULL;
  END IF;
  IF (l_llnv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
    l_llnv_rec.creation_date := NULL;
  END IF;
  IF (l_llnv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.last_updated_by := NULL;
  END IF;
  IF (l_llnv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
    l_llnv_rec.last_update_date := NULL;
  END IF;
  IF (l_llnv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
    l_llnv_rec.last_update_login := NULL;
  END IF;
  RETURN(l_llnv_rec);
END null_out_defaults;
---------------------------------------------------------------------------
-- PROCEDURE Validate_Attributes
---------------------------------------------------------------------------
--------------------------------------------------
-- Validate_Attributes for:OKL_CNSLD_AR_LINES_V --
--------------------------------------------------
FUNCTION Validate_Attributes (
  p_llnv_rec IN  llnv_rec_type
) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  -- Added 04/19/2001 -- Sunil Mathew
  x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
-- Added 04/19/2001 Sunil Mathew
    validate_lln_id_parent(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_kle_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_khr_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_cnr_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_ilt_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_object_version_number(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_sequence_number(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_line_type(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--	validate_currency_code(p_llnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

-- End Addition 04/19/2001 Sunil Mathew

  IF p_llnv_rec.id = Okc_Api.G_MISS_NUM OR
     p_llnv_rec.id IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_llnv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
        p_llnv_rec.object_version_number IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_llnv_rec.sequence_number = Okc_Api.G_MISS_NUM OR
        p_llnv_rec.sequence_number IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sequence_number');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  ELSIF p_llnv_rec.line_type = Okc_Api.G_MISS_CHAR OR
        p_llnv_rec.line_type IS NULL
  THEN
    Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_type');
    l_return_status := Okc_Api.G_RET_STS_ERROR;
  END IF;
  RETURN(l_return_status);
END Validate_Attributes;

---------------------------------------------------------------------------
-- PROCEDURE Validate_Record
---------------------------------------------------------------------------
----------------------------------------------
-- Validate_Record for:OKL_CNSLD_AR_LINES_V --
----------------------------------------------
FUNCTION Validate_Record (
  p_llnv_rec IN llnv_rec_type
) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
BEGIN
  RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------
-- PROCEDURE Migrate
---------------------------------------------------------------------------
PROCEDURE migrate (
  p_from	IN llnv_rec_type,
  p_to	OUT NOCOPY lln_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sequence_number := p_from.sequence_number;
  p_to.lln_id_parent := p_from.lln_id_parent;
  p_to.kle_id := p_from.kle_id;
  p_to.khr_id := p_from.khr_id;
  p_to.cnr_id := p_from.cnr_id;
  p_to.ilt_id := p_from.ilt_id;
  p_to.line_type := p_from.line_type;
  p_to.amount := p_from.amount;
  p_to.object_version_number := p_from.object_version_number;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
  p_to.org_id := p_from.org_id;
  p_to.tax_amount := p_from.tax_amount;
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
  p_from	IN lln_rec_type,
  p_to	OUT NOCOPY llnv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sequence_number := p_from.sequence_number;
  p_to.lln_id_parent := p_from.lln_id_parent;
  p_to.kle_id := p_from.kle_id;
  p_to.khr_id := p_from.khr_id;
  p_to.cnr_id := p_from.cnr_id;
  p_to.ilt_id := p_from.ilt_id;
  p_to.line_type := p_from.line_type;
  p_to.amount := p_from.amount;
  p_to.object_version_number := p_from.object_version_number;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
  p_to.org_id := p_from.org_id;
  p_to.tax_amount := p_from.tax_amount;
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
  p_from	IN llnv_rec_type,
  p_to	OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type
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
  p_from	IN okl_cnsld_ar_lines_tl_rec_type,
  p_to	OUT NOCOPY llnv_rec_type
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
-- validate_row for:OKL_CNSLD_AR_LINES_V --
-------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_rec                     IN llnv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_llnv_rec                     llnv_rec_type := p_llnv_rec;
  l_lln_rec                      lln_rec_type;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
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
  l_return_status := Validate_Attributes(l_llnv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_llnv_rec);
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
-- PL/SQL TBL validate_row for:LLNV_TBL --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_tbl                     IN llnv_tbl_type) IS

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
  IF (p_llnv_tbl.COUNT > 0) THEN
    i := p_llnv_tbl.FIRST;
    LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_llnv_rec                     => p_llnv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_llnv_tbl.LAST);
      i := p_llnv_tbl.NEXT(i);
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
-- insert_row for:OKL_CNSLD_AR_LINES_B --
-----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lln_rec                      IN lln_rec_type,
  x_lln_rec                      OUT NOCOPY lln_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lln_rec                      lln_rec_type := p_lln_rec;
  l_def_lln_rec                  lln_rec_type;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_B --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lln_rec IN  lln_rec_type,
    x_lln_rec OUT NOCOPY lln_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lln_rec := p_lln_rec;
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
    p_lln_rec,                         -- IN
    l_lln_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  INSERT INTO OKL_CNSLD_AR_LINES_B(
      id,
      sequence_number,
      lln_id_parent,
      kle_id,
      khr_id,
      cnr_id,
      ilt_id,
      line_type,
      amount,
      object_version_number,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      org_id,
      tax_amount,
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
      l_lln_rec.id,
      l_lln_rec.sequence_number,
      l_lln_rec.lln_id_parent,
      l_lln_rec.kle_id,
      l_lln_rec.khr_id,
      l_lln_rec.cnr_id,
      l_lln_rec.ilt_id,
      l_lln_rec.line_type,
      l_lln_rec.amount,
      l_lln_rec.object_version_number,
      l_lln_rec.request_id,
      l_lln_rec.program_application_id,
      l_lln_rec.program_id,
      l_lln_rec.program_update_date,
      l_lln_rec.org_id,
      l_lln_rec.tax_amount,
      l_lln_rec.attribute_category,
      l_lln_rec.attribute1,
      l_lln_rec.attribute2,
      l_lln_rec.attribute3,
      l_lln_rec.attribute4,
      l_lln_rec.attribute5,
      l_lln_rec.attribute6,
      l_lln_rec.attribute7,
      l_lln_rec.attribute8,
      l_lln_rec.attribute9,
      l_lln_rec.attribute10,
      l_lln_rec.attribute11,
      l_lln_rec.attribute12,
      l_lln_rec.attribute13,
      l_lln_rec.attribute14,
      l_lln_rec.attribute15,
      l_lln_rec.created_by,
      l_lln_rec.creation_date,
      l_lln_rec.last_updated_by,
      l_lln_rec.last_update_date,
      l_lln_rec.last_update_login);
  -- Set OUT values
  x_lln_rec := l_lln_rec;
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
-- insert_row for:OKL_CNSLD_AR_LINES_TL --
------------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type,
  x_okl_cnsld_ar_lines_tl_rec    OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type := p_okl_cnsld_ar_lines_tl_rec;
  ldefoklcnsldarlinestlrec       okl_cnsld_ar_lines_tl_rec_type;
  CURSOR get_languages IS
    SELECT *
      FROM FND_LANGUAGES
     WHERE INSTALLED_FLAG IN ('I', 'B');
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_lines_tl_rec IN  okl_cnsld_ar_lines_tl_rec_type,
    x_okl_cnsld_ar_lines_tl_rec OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_lines_tl_rec := p_okl_cnsld_ar_lines_tl_rec;
    x_okl_cnsld_ar_lines_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_cnsld_ar_lines_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_cnsld_ar_lines_tl_rec,       -- IN
    l_okl_cnsld_ar_lines_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  FOR l_lang_rec IN get_languages LOOP
    l_okl_cnsld_ar_lines_tl_rec.LANGUAGE := l_lang_rec.language_code;
    INSERT INTO OKL_CNSLD_AR_LINES_TL(
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
        l_okl_cnsld_ar_lines_tl_rec.id,
        l_okl_cnsld_ar_lines_tl_rec.LANGUAGE,
        l_okl_cnsld_ar_lines_tl_rec.source_lang,
        l_okl_cnsld_ar_lines_tl_rec.sfwt_flag,
        l_okl_cnsld_ar_lines_tl_rec.created_by,
        l_okl_cnsld_ar_lines_tl_rec.creation_date,
        l_okl_cnsld_ar_lines_tl_rec.last_updated_by,
        l_okl_cnsld_ar_lines_tl_rec.last_update_date,
        l_okl_cnsld_ar_lines_tl_rec.last_update_login);
  END LOOP;
  -- Set OUT values
  x_okl_cnsld_ar_lines_tl_rec := l_okl_cnsld_ar_lines_tl_rec;
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
-- insert_row for:OKL_CNSLD_AR_LINES_V --
-----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_rec                     IN llnv_rec_type,
  x_llnv_rec                     OUT NOCOPY llnv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_llnv_rec                     llnv_rec_type;
  l_def_llnv_rec                 llnv_rec_type;
  l_lln_rec                      lln_rec_type;
  lx_lln_rec                     lln_rec_type;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
  lx_okl_cnsld_ar_lines_tl_rec   okl_cnsld_ar_lines_tl_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_llnv_rec	IN llnv_rec_type
  ) RETURN llnv_rec_type IS
    l_llnv_rec	llnv_rec_type := p_llnv_rec;
  BEGIN
    l_llnv_rec.CREATION_DATE := SYSDATE;
    l_llnv_rec.CREATED_BY := Fnd_Global.USER_ID;
    l_llnv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_llnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_llnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_llnv_rec);
  END fill_who_columns;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_V --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_llnv_rec IN  llnv_rec_type,
    x_llnv_rec OUT NOCOPY llnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_llnv_rec := p_llnv_rec;
    x_llnv_rec.OBJECT_VERSION_NUMBER := 1;
    x_llnv_rec.SFWT_FLAG := 'N';

	IF (x_llnv_rec.request_id IS NULL OR x_llnv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_llnv_rec.request_id,
	  	   x_llnv_rec.program_application_id,
	  	   x_llnv_rec.program_id,
	  	   x_llnv_rec.program_update_date
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
  l_llnv_rec := null_out_defaults(p_llnv_rec);
  -- Set primary key value
  l_llnv_rec.ID := get_seq_id;
  --- Setting item attributes
  l_return_status := Set_Attributes(
    l_llnv_rec,                        -- IN
    l_def_llnv_rec);                   -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_llnv_rec := fill_who_columns(l_def_llnv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_llnv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_llnv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_llnv_rec, l_lln_rec);
  migrate(l_def_llnv_rec, l_okl_cnsld_ar_lines_tl_rec);
  --------------------------------------------
  -- Call the INSERT_ROW for each child record
  --------------------------------------------
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lln_rec,
    lx_lln_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_lln_rec, l_def_llnv_rec);
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_lines_tl_rec,
    lx_okl_cnsld_ar_lines_tl_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_cnsld_ar_lines_tl_rec, l_def_llnv_rec);
  -- Set OUT values
  x_llnv_rec := l_def_llnv_rec;
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
-- PL/SQL TBL insert_row for:LLNV_TBL --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_tbl                     IN llnv_tbl_type,
  x_llnv_tbl                     OUT NOCOPY llnv_tbl_type) IS

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
  IF (p_llnv_tbl.COUNT > 0) THEN
    i := p_llnv_tbl.FIRST;
    LOOP
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_llnv_rec                     => p_llnv_tbl(i),
        x_llnv_rec                     => x_llnv_tbl(i));
      EXIT WHEN (i = p_llnv_tbl.LAST);
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
      i := p_llnv_tbl.NEXT(i);
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
-- lock_row for:OKL_CNSLD_AR_LINES_B --
---------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lln_rec                      IN lln_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_lln_rec IN lln_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CNSLD_AR_LINES_B
   WHERE ID = p_lln_rec.id
     AND OBJECT_VERSION_NUMBER = p_lln_rec.object_version_number
  FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR  lchk_csr (p_lln_rec IN lln_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CNSLD_AR_LINES_B
  WHERE ID = p_lln_rec.id;
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_object_version_number       OKL_CNSLD_AR_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
  lc_object_version_number      OKL_CNSLD_AR_LINES_B.OBJECT_VERSION_NUMBER%TYPE;
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
    OPEN lock_csr(p_lln_rec);
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
    OPEN lchk_csr(p_lln_rec);
    FETCH lchk_csr INTO lc_object_version_number;
    lc_row_notfound := lchk_csr%NOTFOUND;
    CLOSE lchk_csr;
  END IF;
  IF (lc_row_notfound) THEN
    Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number > p_lln_rec.object_version_number THEN
    Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number <> p_lln_rec.object_version_number THEN
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
-- lock_row for:OKL_CNSLD_AR_LINES_TL --
----------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_okl_cnsld_ar_lines_tl_rec IN okl_cnsld_ar_lines_tl_rec_type) IS
  SELECT *
    FROM OKL_CNSLD_AR_LINES_TL
   WHERE ID = p_okl_cnsld_ar_lines_tl_rec.id
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
    OPEN lock_csr(p_okl_cnsld_ar_lines_tl_rec);
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
-- lock_row for:OKL_CNSLD_AR_LINES_V --
---------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_rec                     IN llnv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lln_rec                      lln_rec_type;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
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
  migrate(p_llnv_rec, l_lln_rec);
  migrate(p_llnv_rec, l_okl_cnsld_ar_lines_tl_rec);
  --------------------------------------------
  -- Call the LOCK_ROW for each child record
  --------------------------------------------
  lock_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lln_rec
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
    l_okl_cnsld_ar_lines_tl_rec
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
-- PL/SQL TBL lock_row for:LLNV_TBL --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_tbl                     IN llnv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_llnv_tbl.COUNT > 0) THEN
    i := p_llnv_tbl.FIRST;
    LOOP
      lock_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_llnv_rec                     => p_llnv_tbl(i));
      EXIT WHEN (i = p_llnv_tbl.LAST);
      i := p_llnv_tbl.NEXT(i);
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
-----------------------------------------
-- update_row for:OKL_CNSLD_AR_LINES_B --
-----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lln_rec                      IN lln_rec_type,
  x_lln_rec                      OUT NOCOPY lln_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lln_rec                      lln_rec_type := p_lln_rec;
  l_def_lln_rec                  lln_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_lln_rec	IN lln_rec_type,
    x_lln_rec	OUT NOCOPY lln_rec_type
  ) RETURN VARCHAR2 IS
    l_lln_rec                      lln_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lln_rec := p_lln_rec;
    -- Get current database values
    l_lln_rec := get_rec(p_lln_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_lln_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.id := l_lln_rec.id;
    END IF;
    IF (x_lln_rec.sequence_number = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.sequence_number := l_lln_rec.sequence_number;
    END IF;
    IF (x_lln_rec.lln_id_parent = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.lln_id_parent := l_lln_rec.lln_id_parent;
    END IF;
    IF (x_lln_rec.kle_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.kle_id := l_lln_rec.kle_id;
    END IF;
    IF (x_lln_rec.khr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.khr_id := l_lln_rec.khr_id;
    END IF;
    IF (x_lln_rec.cnr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.cnr_id := l_lln_rec.cnr_id;
    END IF;
    IF (x_lln_rec.ilt_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.ilt_id := l_lln_rec.ilt_id;
    END IF;
    IF (x_lln_rec.line_type = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.line_type := l_lln_rec.line_type;
    END IF;
    IF (x_lln_rec.amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.amount := l_lln_rec.amount;
    END IF;
    IF (x_lln_rec.object_version_number = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.object_version_number := l_lln_rec.object_version_number;
    END IF;
    IF (x_lln_rec.request_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.request_id := l_lln_rec.request_id;
    END IF;
    IF (x_lln_rec.program_application_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.program_application_id := l_lln_rec.program_application_id;
    END IF;
    IF (x_lln_rec.program_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.program_id := l_lln_rec.program_id;
    END IF;
    IF (x_lln_rec.program_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lln_rec.program_update_date := l_lln_rec.program_update_date;
    END IF;
    IF (x_lln_rec.org_id = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.org_id := l_lln_rec.org_id;
    END IF;
    IF (x_lln_rec.tax_amount = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.tax_amount := l_lln_rec.tax_amount;
    END IF;
    IF (x_lln_rec.attribute_category = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute_category := l_lln_rec.attribute_category;
    END IF;
    IF (x_lln_rec.attribute1 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute1 := l_lln_rec.attribute1;
    END IF;
    IF (x_lln_rec.attribute2 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute2 := l_lln_rec.attribute2;
    END IF;
    IF (x_lln_rec.attribute3 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute3 := l_lln_rec.attribute3;
    END IF;
    IF (x_lln_rec.attribute4 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute4 := l_lln_rec.attribute4;
    END IF;
    IF (x_lln_rec.attribute5 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute5 := l_lln_rec.attribute5;
    END IF;
    IF (x_lln_rec.attribute6 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute6 := l_lln_rec.attribute6;
    END IF;
    IF (x_lln_rec.attribute7 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute7 := l_lln_rec.attribute7;
    END IF;
    IF (x_lln_rec.attribute8 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute8 := l_lln_rec.attribute8;
    END IF;
    IF (x_lln_rec.attribute9 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute9 := l_lln_rec.attribute9;
    END IF;
    IF (x_lln_rec.attribute10 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute10 := l_lln_rec.attribute10;
    END IF;
    IF (x_lln_rec.attribute11 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute11 := l_lln_rec.attribute11;
    END IF;
    IF (x_lln_rec.attribute12 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute12 := l_lln_rec.attribute12;
    END IF;
    IF (x_lln_rec.attribute13 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute13 := l_lln_rec.attribute13;
    END IF;
    IF (x_lln_rec.attribute14 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute14 := l_lln_rec.attribute14;
    END IF;
    IF (x_lln_rec.attribute15 = Okc_Api.G_MISS_CHAR)
    THEN
      x_lln_rec.attribute15 := l_lln_rec.attribute15;
    END IF;
    IF (x_lln_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.created_by := l_lln_rec.created_by;
    END IF;
    IF (x_lln_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lln_rec.creation_date := l_lln_rec.creation_date;
    END IF;
    IF (x_lln_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.last_updated_by := l_lln_rec.last_updated_by;
    END IF;
    IF (x_lln_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_lln_rec.last_update_date := l_lln_rec.last_update_date;
    END IF;
    IF (x_lln_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_lln_rec.last_update_login := l_lln_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_B --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_lln_rec IN  lln_rec_type,
    x_lln_rec OUT NOCOPY lln_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_lln_rec := p_lln_rec;
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
    p_lln_rec,                         -- IN
    l_lln_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_lln_rec, l_def_lln_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_CNSLD_AR_LINES_B
  SET SEQUENCE_NUMBER = l_def_lln_rec.sequence_number,
      LLN_ID_PARENT = l_def_lln_rec.lln_id_parent,
      KLE_ID = l_def_lln_rec.kle_id,
      KHR_ID = l_def_lln_rec.khr_id,
      CNR_ID = l_def_lln_rec.cnr_id,
      ILT_ID = l_def_lln_rec.ilt_id,
      LINE_TYPE = l_def_lln_rec.line_type,
      AMOUNT = l_def_lln_rec.amount,
      OBJECT_VERSION_NUMBER = l_def_lln_rec.object_version_number,
      REQUEST_ID = l_def_lln_rec.request_id,
      PROGRAM_APPLICATION_ID = l_def_lln_rec.program_application_id,
      PROGRAM_ID = l_def_lln_rec.program_id,
      PROGRAM_UPDATE_DATE = l_def_lln_rec.program_update_date,
      ORG_ID = l_def_lln_rec.org_id,
      TAX_AMOUNT = l_def_lln_rec.tax_amount,
      ATTRIBUTE_CATEGORY = l_def_lln_rec.attribute_category,
      ATTRIBUTE1 = l_def_lln_rec.attribute1,
      ATTRIBUTE2 = l_def_lln_rec.attribute2,
      ATTRIBUTE3 = l_def_lln_rec.attribute3,
      ATTRIBUTE4 = l_def_lln_rec.attribute4,
      ATTRIBUTE5 = l_def_lln_rec.attribute5,
      ATTRIBUTE6 = l_def_lln_rec.attribute6,
      ATTRIBUTE7 = l_def_lln_rec.attribute7,
      ATTRIBUTE8 = l_def_lln_rec.attribute8,
      ATTRIBUTE9 = l_def_lln_rec.attribute9,
      ATTRIBUTE10 = l_def_lln_rec.attribute10,
      ATTRIBUTE11 = l_def_lln_rec.attribute11,
      ATTRIBUTE12 = l_def_lln_rec.attribute12,
      ATTRIBUTE13 = l_def_lln_rec.attribute13,
      ATTRIBUTE14 = l_def_lln_rec.attribute14,
      ATTRIBUTE15 = l_def_lln_rec.attribute15,
      CREATED_BY = l_def_lln_rec.created_by,
      CREATION_DATE = l_def_lln_rec.creation_date,
      LAST_UPDATED_BY = l_def_lln_rec.last_updated_by,
      LAST_UPDATE_DATE = l_def_lln_rec.last_update_date,
      LAST_UPDATE_LOGIN = l_def_lln_rec.last_update_login
  WHERE ID = l_def_lln_rec.id;

  x_lln_rec := l_def_lln_rec;
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
-- update_row for:OKL_CNSLD_AR_LINES_TL --
------------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type,
  x_okl_cnsld_ar_lines_tl_rec    OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type := p_okl_cnsld_ar_lines_tl_rec;
  ldefoklcnsldarlinestlrec       okl_cnsld_ar_lines_tl_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_okl_cnsld_ar_lines_tl_rec	IN okl_cnsld_ar_lines_tl_rec_type,
    x_okl_cnsld_ar_lines_tl_rec	OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_lines_tl_rec := p_okl_cnsld_ar_lines_tl_rec;
    -- Get current database values
    l_okl_cnsld_ar_lines_tl_rec := get_rec(p_okl_cnsld_ar_lines_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.id := l_okl_cnsld_ar_lines_tl_rec.id;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.LANGUAGE := l_okl_cnsld_ar_lines_tl_rec.LANGUAGE;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.source_lang := l_okl_cnsld_ar_lines_tl_rec.source_lang;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.sfwt_flag := l_okl_cnsld_ar_lines_tl_rec.sfwt_flag;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.created_by := l_okl_cnsld_ar_lines_tl_rec.created_by;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.creation_date := l_okl_cnsld_ar_lines_tl_rec.creation_date;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.last_updated_by := l_okl_cnsld_ar_lines_tl_rec.last_updated_by;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.last_update_date := l_okl_cnsld_ar_lines_tl_rec.last_update_date;
    END IF;
    IF (x_okl_cnsld_ar_lines_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_okl_cnsld_ar_lines_tl_rec.last_update_login := l_okl_cnsld_ar_lines_tl_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_lines_tl_rec IN  okl_cnsld_ar_lines_tl_rec_type,
    x_okl_cnsld_ar_lines_tl_rec OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_lines_tl_rec := p_okl_cnsld_ar_lines_tl_rec;
    x_okl_cnsld_ar_lines_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_cnsld_ar_lines_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_cnsld_ar_lines_tl_rec,       -- IN
    l_okl_cnsld_ar_lines_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_okl_cnsld_ar_lines_tl_rec, ldefoklcnsldarlinestlrec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_CNSLD_AR_LINES_TL
  SET CREATED_BY = ldefoklcnsldarlinestlrec.created_by,
      CREATION_DATE = ldefoklcnsldarlinestlrec.creation_date,
      LAST_UPDATED_BY = ldefoklcnsldarlinestlrec.last_updated_by,
      LAST_UPDATE_DATE = ldefoklcnsldarlinestlrec.last_update_date,
      LAST_UPDATE_LOGIN = ldefoklcnsldarlinestlrec.last_update_login
  WHERE ID = ldefoklcnsldarlinestlrec.id
    --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

  UPDATE  OKL_CNSLD_AR_LINES_TL
  SET SFWT_FLAG = 'Y'
  WHERE ID = ldefoklcnsldarlinestlrec.id
    AND SOURCE_LANG <> USERENV('LANG');

  x_okl_cnsld_ar_lines_tl_rec := ldefoklcnsldarlinestlrec;
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
-- update_row for:OKL_CNSLD_AR_LINES_V --
-----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_rec                     IN llnv_rec_type,
  x_llnv_rec                     OUT NOCOPY llnv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_llnv_rec                     llnv_rec_type := p_llnv_rec;
  l_def_llnv_rec                 llnv_rec_type;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
  lx_okl_cnsld_ar_lines_tl_rec   okl_cnsld_ar_lines_tl_rec_type;
  l_lln_rec                      lln_rec_type;
  lx_lln_rec                     lln_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_llnv_rec	IN llnv_rec_type
  ) RETURN llnv_rec_type IS
    l_llnv_rec	llnv_rec_type := p_llnv_rec;
  BEGIN
    l_llnv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_llnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_llnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_llnv_rec);
  END fill_who_columns;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_llnv_rec	IN llnv_rec_type,
    x_llnv_rec	OUT NOCOPY llnv_rec_type
  ) RETURN VARCHAR2 IS
    l_llnv_rec                     llnv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_llnv_rec := p_llnv_rec;
    -- Get current database values
    l_llnv_rec := get_rec(p_llnv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_llnv_rec.id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.id := l_llnv_rec.id;
    END IF;
    IF (x_llnv_rec.object_version_number = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.object_version_number := l_llnv_rec.object_version_number;
    END IF;
    IF (x_llnv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.sfwt_flag := l_llnv_rec.sfwt_flag;
    END IF;
    IF (x_llnv_rec.khr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.khr_id := l_llnv_rec.khr_id;
    END IF;
    IF (x_llnv_rec.cnr_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.cnr_id := l_llnv_rec.cnr_id;
    END IF;
    IF (x_llnv_rec.kle_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.kle_id := l_llnv_rec.kle_id;
    END IF;
    IF (x_llnv_rec.lln_id_parent = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.lln_id_parent := l_llnv_rec.lln_id_parent;
    END IF;
    IF (x_llnv_rec.ilt_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.ilt_id := l_llnv_rec.ilt_id;
    END IF;
    IF (x_llnv_rec.sequence_number = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.sequence_number := l_llnv_rec.sequence_number;
    END IF;
    IF (x_llnv_rec.amount = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.amount := l_llnv_rec.amount;
    END IF;
    IF (x_llnv_rec.tax_amount = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.tax_amount := l_llnv_rec.tax_amount;
    END IF;
    IF (x_llnv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute_category := l_llnv_rec.attribute_category;
    END IF;
    IF (x_llnv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute1 := l_llnv_rec.attribute1;
    END IF;
    IF (x_llnv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute2 := l_llnv_rec.attribute2;
    END IF;
    IF (x_llnv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute3 := l_llnv_rec.attribute3;
    END IF;
    IF (x_llnv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute4 := l_llnv_rec.attribute4;
    END IF;
    IF (x_llnv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute5 := l_llnv_rec.attribute5;
    END IF;
    IF (x_llnv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute6 := l_llnv_rec.attribute6;
    END IF;
    IF (x_llnv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute7 := l_llnv_rec.attribute7;
    END IF;
    IF (x_llnv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute8 := l_llnv_rec.attribute8;
    END IF;
    IF (x_llnv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute9 := l_llnv_rec.attribute9;
    END IF;
    IF (x_llnv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute10 := l_llnv_rec.attribute10;
    END IF;
    IF (x_llnv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute11 := l_llnv_rec.attribute11;
    END IF;
    IF (x_llnv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute12 := l_llnv_rec.attribute12;
    END IF;
    IF (x_llnv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute13 := l_llnv_rec.attribute13;
    END IF;
    IF (x_llnv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute14 := l_llnv_rec.attribute14;
    END IF;
    IF (x_llnv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.attribute15 := l_llnv_rec.attribute15;
    END IF;
    IF (x_llnv_rec.line_type = Okc_Api.G_MISS_CHAR)
    THEN
      x_llnv_rec.line_type := l_llnv_rec.line_type;
    END IF;
    IF (x_llnv_rec.request_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.request_id := l_llnv_rec.request_id;
    END IF;
    IF (x_llnv_rec.program_application_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.program_application_id := l_llnv_rec.program_application_id;
    END IF;
    IF (x_llnv_rec.program_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.program_id := l_llnv_rec.program_id;
    END IF;
    IF (x_llnv_rec.program_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_llnv_rec.program_update_date := l_llnv_rec.program_update_date;
    END IF;
    IF (x_llnv_rec.org_id = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.org_id := l_llnv_rec.org_id;
    END IF;
    IF (x_llnv_rec.created_by = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.created_by := l_llnv_rec.created_by;
    END IF;
    IF (x_llnv_rec.creation_date = Okc_Api.G_MISS_DATE)
    THEN
      x_llnv_rec.creation_date := l_llnv_rec.creation_date;
    END IF;
    IF (x_llnv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.last_updated_by := l_llnv_rec.last_updated_by;
    END IF;
    IF (x_llnv_rec.last_update_date = Okc_Api.G_MISS_DATE)
    THEN
      x_llnv_rec.last_update_date := l_llnv_rec.last_update_date;
    END IF;
    IF (x_llnv_rec.last_update_login = Okc_Api.G_MISS_NUM)
    THEN
      x_llnv_rec.last_update_login := l_llnv_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_V --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_llnv_rec IN  llnv_rec_type,
    x_llnv_rec OUT NOCOPY llnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_llnv_rec := p_llnv_rec;
    x_llnv_rec.OBJECT_VERSION_NUMBER := NVL(x_llnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_llnv_rec.request_id IS NULL OR x_llnv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_llnv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_llnv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_llnv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_llnv_rec.program_update_date,SYSDATE)
      INTO
        x_llnv_rec.request_id,
        x_llnv_rec.program_application_id,
        x_llnv_rec.program_id,
        x_llnv_rec.program_update_date
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
    p_llnv_rec,                        -- IN
    l_llnv_rec);                       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_llnv_rec, l_def_llnv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_llnv_rec := fill_who_columns(l_def_llnv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_llnv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_llnv_rec);
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;

  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_llnv_rec, l_okl_cnsld_ar_lines_tl_rec);
  migrate(l_def_llnv_rec, l_lln_rec);
  --------------------------------------------
  -- Call the UPDATE_ROW for each child record
  --------------------------------------------
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_lines_tl_rec,
    lx_okl_cnsld_ar_lines_tl_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_cnsld_ar_lines_tl_rec, l_def_llnv_rec);
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_lln_rec,
    lx_lln_rec
  );
  IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_lln_rec, l_def_llnv_rec);
  x_llnv_rec := l_def_llnv_rec;
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
-- PL/SQL TBL update_row for:LLNV_TBL --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_tbl                     IN llnv_tbl_type,
  x_llnv_tbl                     OUT NOCOPY llnv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_llnv_tbl.COUNT > 0) THEN
    i := p_llnv_tbl.FIRST;
    LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_llnv_rec                     => p_llnv_tbl(i),
        x_llnv_rec                     => x_llnv_tbl(i));
      EXIT WHEN (i = p_llnv_tbl.LAST);
      i := p_llnv_tbl.NEXT(i);
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
-----------------------------------------
-- delete_row for:OKL_CNSLD_AR_LINES_B --
-----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_lln_rec                      IN lln_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_lln_rec                      lln_rec_type:= p_lln_rec;
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
  DELETE FROM OKL_CNSLD_AR_LINES_B
   WHERE ID = l_lln_rec.id;

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
-- delete_row for:OKL_CNSLD_AR_LINES_TL --
------------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_cnsld_ar_lines_tl_rec    IN okl_cnsld_ar_lines_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type:= p_okl_cnsld_ar_lines_tl_rec;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------------------
  -- Set_Attributes for:OKL_CNSLD_AR_LINES_TL --
  ----------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_cnsld_ar_lines_tl_rec IN  okl_cnsld_ar_lines_tl_rec_type,
    x_okl_cnsld_ar_lines_tl_rec OUT NOCOPY okl_cnsld_ar_lines_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_cnsld_ar_lines_tl_rec := p_okl_cnsld_ar_lines_tl_rec;
    x_okl_cnsld_ar_lines_tl_rec.LANGUAGE := USERENV('LANG');
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
    p_okl_cnsld_ar_lines_tl_rec,       -- IN
    l_okl_cnsld_ar_lines_tl_rec);      -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    RAISE Okc_Api.G_EXCEPTION_ERROR;
  END IF;
  DELETE FROM OKL_CNSLD_AR_LINES_TL
   WHERE ID = l_okl_cnsld_ar_lines_tl_rec.id;

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
-- delete_row for:OKL_CNSLD_AR_LINES_V --
-----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_rec                     IN llnv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  l_llnv_rec                     llnv_rec_type := p_llnv_rec;
  l_okl_cnsld_ar_lines_tl_rec    okl_cnsld_ar_lines_tl_rec_type;
  l_lln_rec                      lln_rec_type;
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
  migrate(l_llnv_rec, l_okl_cnsld_ar_lines_tl_rec);
  migrate(l_llnv_rec, l_lln_rec);
  --------------------------------------------
  -- Call the DELETE_ROW for each child record
  --------------------------------------------
  delete_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_cnsld_ar_lines_tl_rec
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
    l_lln_rec
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
-- PL/SQL TBL delete_row for:LLNV_TBL --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_llnv_tbl                     IN llnv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
  l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  Okc_Api.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_llnv_tbl.COUNT > 0) THEN
    i := p_llnv_tbl.FIRST;
    LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_llnv_rec                     => p_llnv_tbl(i));
      EXIT WHEN (i = p_llnv_tbl.LAST);
      i := p_llnv_tbl.NEXT(i);
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
END Okl_Lln_Pvt;

/
