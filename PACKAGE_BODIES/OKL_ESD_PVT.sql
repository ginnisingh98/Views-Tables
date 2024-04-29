--------------------------------------------------------
--  DDL for Package Body OKL_ESD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ESD_PVT" AS
/* $Header: OKLSESDB.pls 115.7 2004/05/21 21:26:53 pjgomes noship $ */

--Post Gen additions Sunil Mathew 04/18/2001
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id (p_esdv_rec IN esdv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_esdv_rec.id = Okl_Api.G_MISS_NUM OR
       p_esdv_rec.id IS NULL
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
  PROCEDURE validate_org_id (p_esdv_rec IN esdv_rec_type,
                x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := Okl_Util.check_org_id(p_esdv_rec.org_id);

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number (p_esdv_rec IN esdv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_esdv_rec.id = Okl_Api.G_MISS_NUM OR
       p_esdv_rec.id IS NULL
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
  -- PROCEDURE validate_account_class
  ---------------------------------------------------------------------------
  PROCEDURE validate_account_class (p_esdv_rec IN esdv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_esdv_rec.account_class = Okl_Api.G_MISS_CHAR OR
       p_esdv_rec.account_class IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'account_class');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_account_class;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_code_combination_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_code_combination_id (p_esdv_rec IN esdv_rec_type,
  								x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	--Check for Null
    IF p_esdv_rec.code_combination_id = Okl_Api.G_MISS_NUM OR
       p_esdv_rec.code_combination_id IS NULL
    THEN

      x_return_status := Okl_Api.G_RET_STS_ERROR;
  	  --set error message in message stack
	  Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'code_combination_id');
      RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;
  END validate_code_combination_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_xls_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_xls_id(p_esdv_rec IN esdv_rec_type,
  								   	x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_xls_id_csr IS
    SELECT '1'
	FROM OKL_XTL_SELL_INVS_V
	WHERE id = p_esdv_rec.xls_id;


  BEGIN
  	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

       IF p_esdv_rec.xls_id = Okl_Api.G_MISS_NUM OR
       	  p_esdv_rec.xls_id IS NULL
       THEN

       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   --set error message in message stack
	   Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'xls_id');

       RAISE G_EXCEPTION_HALT_VALIDATION;
	   END IF;

	   IF (p_esdv_rec.xls_id IS NOT NULL) THEN
	   	  OPEN l_xls_id_csr;
		  FETCH l_xls_id_csr INTO l_dummy_var;
		  CLOSE l_xls_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_Api.G_RET_STS_ERROR;
			 Okl_Api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'XLS_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTD_SELL_INVS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_xls_id;

  /* View Undefined
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ild_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_ild_id(p_esdv_rec IN esdv_rec_type,
  								   	x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_ild_id_csr IS
    SELECT '1'
	FROM OKX_SELL_LN_DISTS_V
	WHERE id = p_esdv_rec.ild_id;


  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;

       IF p_esdv_rec.ild_id = Okl_api.G_MISS_NUM OR
       	  p_esdv_rec.ild_id IS NULL
       THEN

       x_return_status := Okl_api.G_RET_STS_ERROR;
  	   --set error message in message stack
	   Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
        	              p_msg_name     =>  G_REQUIRED_VALUE,
          				  p_token1       => G_COL_NAME_TOKEN,
						  p_token1_value => 'ild_id');

       RAISE G_EXCEPTION_HALT_VALIDATION;
	   END IF;

	   IF (p_esdv_rec.ild_id IS NOT NULL) THEN
	   	  OPEN l_ild_id_csr;
		  FETCH l_ild_id_csr INTO l_dummy_var;
		  CLOSE l_ild_id_csr;

		  IF (l_dummy_var <> '1') THEN
		  	 x_return_status := Okl_api.G_RET_STS_ERROR;
			 Okl_api.SET_MESSAGE(p_app_name			=> G_APP_NAME,
			 					 p_msg_name			=> G_NO_PARENT_RECORD,
								 p_token1			=> G_COL_NAME_TOKEN,
								 p_token1_value		=> 'ILD_ID_FOR',
								 p_token2			=> G_CHILD_TABLE_TOKEN,
								 p_token2_value		=> G_VIEW,
								 p_token3			=> G_PARENT_TABLE_TOKEN,
								 p_token3_value		=> 'OKL_XTD_SELL_INVS_V');

			 RAISE G_EXCEPTION_HALT_VALIDATION;
		  END IF;
	   END IF;

  END validate_ild_id;
*/
--End post gen additions 04/18/2001 Sunil Mathew


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
    DELETE FROM OKL_XTD_SELL_INVS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_XTD_SELL_INVS_B B   --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
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
              FROM OKL_XTD_SELL_INVS_TL SUBB, OKL_XTD_SELL_INVS_TL SUBT
             WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG

  */

  INSERT INTO OKL_XTD_SELL_INVS_TL (
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
      FROM OKL_XTD_SELL_INVS_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND B.LANGUAGE = USERENV('LANG')
       AND NOT EXISTS(
                  SELECT NULL
                    FROM OKL_XTD_SELL_INVS_TL T
                   WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                  );

END add_language;

---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTD_SELL_INVS_B
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_esd_rec                      IN esd_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN esd_rec_type IS
  CURSOR okl_xtd_sell_invs_b_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          XLS_ID,
          ILD_ID,
          ACCOUNT_CLASS,
          CODE_COMBINATION_ID,
          OBJECT_VERSION_NUMBER,
          AMOUNT,
          PERCENT,
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
          LAST_UPDATE_LOGIN
    FROM Okl_Xtd_Sell_Invs_B
   WHERE okl_xtd_sell_invs_b.id = p_id;
  l_okl_xtd_sell_invs_b_pk       okl_xtd_sell_invs_b_pk_csr%ROWTYPE;
  l_esd_rec                      esd_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_xtd_sell_invs_b_pk_csr (p_esd_rec.id);
  FETCH okl_xtd_sell_invs_b_pk_csr INTO
            l_esd_rec.ID,
            l_esd_rec.XLS_ID,
            l_esd_rec.ILD_ID,
            l_esd_rec.ACCOUNT_CLASS,
            l_esd_rec.CODE_COMBINATION_ID,
            l_esd_rec.OBJECT_VERSION_NUMBER,
            l_esd_rec.AMOUNT,
            l_esd_rec.PERCENT,
            l_esd_rec.REQUEST_ID,
            l_esd_rec.PROGRAM_APPLICATION_ID,
            l_esd_rec.PROGRAM_ID,
            l_esd_rec.PROGRAM_UPDATE_DATE,
            l_esd_rec.ORG_ID,
            l_esd_rec.ATTRIBUTE_CATEGORY,
            l_esd_rec.ATTRIBUTE1,
            l_esd_rec.ATTRIBUTE2,
            l_esd_rec.ATTRIBUTE3,
            l_esd_rec.ATTRIBUTE4,
            l_esd_rec.ATTRIBUTE5,
            l_esd_rec.ATTRIBUTE6,
            l_esd_rec.ATTRIBUTE7,
            l_esd_rec.ATTRIBUTE8,
            l_esd_rec.ATTRIBUTE9,
            l_esd_rec.ATTRIBUTE10,
            l_esd_rec.ATTRIBUTE11,
            l_esd_rec.ATTRIBUTE12,
            l_esd_rec.ATTRIBUTE13,
            l_esd_rec.ATTRIBUTE14,
            l_esd_rec.ATTRIBUTE15,
            l_esd_rec.CREATED_BY,
            l_esd_rec.CREATION_DATE,
            l_esd_rec.LAST_UPDATED_BY,
            l_esd_rec.LAST_UPDATE_DATE,
            l_esd_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_xtd_sell_invs_b_pk_csr%NOTFOUND;
  CLOSE okl_xtd_sell_invs_b_pk_csr;
  RETURN(l_esd_rec);
END get_rec;

FUNCTION get_rec (
  p_esd_rec                      IN esd_rec_type
) RETURN esd_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_esd_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTD_SELL_INVS_TL
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN okl_xtd_sell_invs_tl_rec_type IS
  CURSOR okl_xtd_sell_invs_tl_pk_csr (p_id                 IN NUMBER,
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
    FROM Okl_Xtd_Sell_Invs_Tl
   WHERE okl_xtd_sell_invs_tl.id = p_id
     AND okl_xtd_sell_invs_tl.LANGUAGE = p_language;
  l_okl_xtd_sell_invs_tl_pk      okl_xtd_sell_invs_tl_pk_csr%ROWTYPE;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_xtd_sell_invs_tl_pk_csr (p_okl_xtd_sell_invs_tl_rec.id,
                                    p_okl_xtd_sell_invs_tl_rec.LANGUAGE);
  FETCH okl_xtd_sell_invs_tl_pk_csr INTO
            l_okl_xtd_sell_invs_tl_rec.ID,
            l_okl_xtd_sell_invs_tl_rec.LANGUAGE,
            l_okl_xtd_sell_invs_tl_rec.SOURCE_LANG,
            l_okl_xtd_sell_invs_tl_rec.SFWT_FLAG,
            l_okl_xtd_sell_invs_tl_rec.CREATED_BY,
            l_okl_xtd_sell_invs_tl_rec.CREATION_DATE,
            l_okl_xtd_sell_invs_tl_rec.LAST_UPDATED_BY,
            l_okl_xtd_sell_invs_tl_rec.LAST_UPDATE_DATE,
            l_okl_xtd_sell_invs_tl_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_xtd_sell_invs_tl_pk_csr%NOTFOUND;
  CLOSE okl_xtd_sell_invs_tl_pk_csr;
  RETURN(l_okl_xtd_sell_invs_tl_rec);
END get_rec;

FUNCTION get_rec (
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type
) RETURN okl_xtd_sell_invs_tl_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_okl_xtd_sell_invs_tl_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTD_SELL_INVS_V
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_esdv_rec                     IN esdv_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN esdv_rec_type IS
  CURSOR okl_esdv_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          OBJECT_VERSION_NUMBER,
          SFWT_FLAG,
          XLS_ID,
          ILD_ID,
          ACCOUNT_CLASS,
          CODE_COMBINATION_ID,
          AMOUNT,
          PERCENT,
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
    FROM Okl_Xtd_Sell_Invs_V
   WHERE okl_xtd_sell_invs_v.id = p_id;
  l_okl_esdv_pk                  okl_esdv_pk_csr%ROWTYPE;
  l_esdv_rec                     esdv_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_esdv_pk_csr (p_esdv_rec.id);
  FETCH okl_esdv_pk_csr INTO
            l_esdv_rec.ID,
            l_esdv_rec.OBJECT_VERSION_NUMBER,
            l_esdv_rec.SFWT_FLAG,
            l_esdv_rec.XLS_ID,
            l_esdv_rec.ILD_ID,
            l_esdv_rec.ACCOUNT_CLASS,
            l_esdv_rec.CODE_COMBINATION_ID,
            l_esdv_rec.AMOUNT,
            l_esdv_rec.PERCENT,
            l_esdv_rec.ATTRIBUTE_CATEGORY,
            l_esdv_rec.ATTRIBUTE1,
            l_esdv_rec.ATTRIBUTE2,
            l_esdv_rec.ATTRIBUTE3,
            l_esdv_rec.ATTRIBUTE4,
            l_esdv_rec.ATTRIBUTE5,
            l_esdv_rec.ATTRIBUTE6,
            l_esdv_rec.ATTRIBUTE7,
            l_esdv_rec.ATTRIBUTE8,
            l_esdv_rec.ATTRIBUTE9,
            l_esdv_rec.ATTRIBUTE10,
            l_esdv_rec.ATTRIBUTE11,
            l_esdv_rec.ATTRIBUTE12,
            l_esdv_rec.ATTRIBUTE13,
            l_esdv_rec.ATTRIBUTE14,
            l_esdv_rec.ATTRIBUTE15,
            l_esdv_rec.REQUEST_ID,
            l_esdv_rec.PROGRAM_APPLICATION_ID,
            l_esdv_rec.PROGRAM_ID,
            l_esdv_rec.PROGRAM_UPDATE_DATE,
            l_esdv_rec.ORG_ID,
            l_esdv_rec.CREATED_BY,
            l_esdv_rec.CREATION_DATE,
            l_esdv_rec.LAST_UPDATED_BY,
            l_esdv_rec.LAST_UPDATE_DATE,
            l_esdv_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_esdv_pk_csr%NOTFOUND;
  CLOSE okl_esdv_pk_csr;
  RETURN(l_esdv_rec);
END get_rec;

FUNCTION get_rec (
  p_esdv_rec                     IN esdv_rec_type
) RETURN esdv_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_esdv_rec, l_row_notfound));
END get_rec;

---------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_XTD_SELL_INVS_V --
---------------------------------------------------------
FUNCTION null_out_defaults (
  p_esdv_rec	IN esdv_rec_type
) RETURN esdv_rec_type IS
  l_esdv_rec	esdv_rec_type := p_esdv_rec;
BEGIN
  IF (l_esdv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.object_version_number := NULL;
  END IF;
  IF (l_esdv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.sfwt_flag := NULL;
  END IF;
  IF (l_esdv_rec.xls_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.xls_id := NULL;
  END IF;
  IF (l_esdv_rec.ild_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.ild_id := NULL;
  END IF;
  IF (l_esdv_rec.account_class = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.account_class := NULL;
  END IF;
  IF (l_esdv_rec.code_combination_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.code_combination_id := NULL;
  END IF;
  IF (l_esdv_rec.amount = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.amount := NULL;
  END IF;
  IF (l_esdv_rec.percent = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.percent := NULL;
  END IF;
  IF (l_esdv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute_category := NULL;
  END IF;
  IF (l_esdv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute1 := NULL;
  END IF;
  IF (l_esdv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute2 := NULL;
  END IF;
  IF (l_esdv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute3 := NULL;
  END IF;
  IF (l_esdv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute4 := NULL;
  END IF;
  IF (l_esdv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute5 := NULL;
  END IF;
  IF (l_esdv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute6 := NULL;
  END IF;
  IF (l_esdv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute7 := NULL;
  END IF;
  IF (l_esdv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute8 := NULL;
  END IF;
  IF (l_esdv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute9 := NULL;
  END IF;
  IF (l_esdv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute10 := NULL;
  END IF;
  IF (l_esdv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute11 := NULL;
  END IF;
  IF (l_esdv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute12 := NULL;
  END IF;
  IF (l_esdv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute13 := NULL;
  END IF;
  IF (l_esdv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute14 := NULL;
  END IF;
  IF (l_esdv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
    l_esdv_rec.attribute15 := NULL;
  END IF;
  IF (l_esdv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.request_id := NULL;
  END IF;
  IF (l_esdv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.program_application_id := NULL;
  END IF;
  IF (l_esdv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.program_id := NULL;
  END IF;
  IF (l_esdv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
    l_esdv_rec.program_update_date := NULL;
  END IF;
  IF (l_esdv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.org_id := NULL;
  END IF;
  IF (l_esdv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.created_by := NULL;
  END IF;
  IF (l_esdv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
    l_esdv_rec.creation_date := NULL;
  END IF;
  IF (l_esdv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.last_updated_by := NULL;
  END IF;
  IF (l_esdv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
    l_esdv_rec.last_update_date := NULL;
  END IF;
  IF (l_esdv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
    l_esdv_rec.last_update_login := NULL;
  END IF;
  RETURN(l_esdv_rec);
END null_out_defaults;
---------------------------------------------------------------------------
-- PROCEDURE Validate_Attributes
---------------------------------------------------------------------------
-------------------------------------------------
-- Validate_Attributes for:OKL_XTD_SELL_INVS_V --
-------------------------------------------------
FUNCTION Validate_Attributes (
  p_esdv_rec IN  esdv_rec_type
) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  -- Added 04/17/2001 -- Sunil Mathew
  x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
 -- Added 04/18/2001 Sunil Mathew
    validate_xls_id(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

--    validate_ild_id(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_id(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_object_version_number(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_account_class(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_code_combination_id(p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id (p_esdv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

 -- Added 04/18/2001 Sunil Mathew
  RETURN(l_return_status);
END Validate_Attributes;

---------------------------------------------------------------------------
-- PROCEDURE Validate_Record
---------------------------------------------------------------------------
---------------------------------------------
-- Validate_Record for:OKL_XTD_SELL_INVS_V --
---------------------------------------------
FUNCTION Validate_Record (
  p_esdv_rec IN esdv_rec_type
) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
  RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------
-- PROCEDURE Migrate
---------------------------------------------------------------------------
PROCEDURE migrate (
  p_from	IN esdv_rec_type,
  p_to	IN OUT NOCOPY esd_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.xls_id := p_from.xls_id;
  p_to.ild_id := p_from.ild_id;
  p_to.account_class := p_from.account_class;
  p_to.code_combination_id := p_from.code_combination_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.amount := p_from.amount;
  p_to.percent := p_from.percent;
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
END migrate;
PROCEDURE migrate (
  p_from	IN esd_rec_type,
  p_to	IN OUT NOCOPY esdv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.xls_id := p_from.xls_id;
  p_to.ild_id := p_from.ild_id;
  p_to.account_class := p_from.account_class;
  p_to.code_combination_id := p_from.code_combination_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.amount := p_from.amount;
  p_to.percent := p_from.percent;
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
END migrate;
PROCEDURE migrate (
  p_from	IN esdv_rec_type,
  p_to	IN OUT NOCOPY okl_xtd_sell_invs_tl_rec_type
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
  p_from	IN okl_xtd_sell_invs_tl_rec_type,
  p_to	IN OUT NOCOPY esdv_rec_type
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
------------------------------------------
-- validate_row for:OKL_XTD_SELL_INVS_V --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_rec                     IN esdv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esdv_rec                     esdv_rec_type := p_esdv_rec;
  l_esd_rec                      esd_rec_type;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
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
  l_return_status := Validate_Attributes(l_esdv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_esdv_rec);
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
-- PL/SQL TBL validate_row for:ESDV_TBL --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_tbl                     IN esdv_tbl_type) IS

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
  IF (p_esdv_tbl.COUNT > 0) THEN
    i := p_esdv_tbl.FIRST;
    LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_esdv_rec                     => p_esdv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_esdv_tbl.LAST);
      i := p_esdv_tbl.NEXT(i);
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
-- insert_row for:OKL_XTD_SELL_INVS_B --
----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esd_rec                      IN esd_rec_type,
  x_esd_rec                      OUT NOCOPY esd_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esd_rec                      esd_rec_type := p_esd_rec;
  l_def_esd_rec                  esd_rec_type;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_B --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_esd_rec IN  esd_rec_type,
    x_esd_rec OUT NOCOPY esd_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esd_rec := p_esd_rec;
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
    p_esd_rec,                         -- IN
    l_esd_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  INSERT INTO OKL_XTD_SELL_INVS_B(
      id,
      xls_id,
      ild_id,
      account_class,
      code_combination_id,
      object_version_number,
      amount,
      percent,
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
      last_update_login)
    VALUES (
      l_esd_rec.id,
      l_esd_rec.xls_id,
      l_esd_rec.ild_id,
      l_esd_rec.account_class,
      l_esd_rec.code_combination_id,
      l_esd_rec.object_version_number,
      l_esd_rec.amount,
      l_esd_rec.percent,
      l_esd_rec.request_id,
      l_esd_rec.program_application_id,
      l_esd_rec.program_id,
      l_esd_rec.program_update_date,
      l_esd_rec.org_id,
      l_esd_rec.attribute_category,
      l_esd_rec.attribute1,
      l_esd_rec.attribute2,
      l_esd_rec.attribute3,
      l_esd_rec.attribute4,
      l_esd_rec.attribute5,
      l_esd_rec.attribute6,
      l_esd_rec.attribute7,
      l_esd_rec.attribute8,
      l_esd_rec.attribute9,
      l_esd_rec.attribute10,
      l_esd_rec.attribute11,
      l_esd_rec.attribute12,
      l_esd_rec.attribute13,
      l_esd_rec.attribute14,
      l_esd_rec.attribute15,
      l_esd_rec.created_by,
      l_esd_rec.creation_date,
      l_esd_rec.last_updated_by,
      l_esd_rec.last_update_date,
      l_esd_rec.last_update_login);
  -- Set OUT values
  x_esd_rec := l_esd_rec;
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
-- insert_row for:OKL_XTD_SELL_INVS_TL --
-----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type,
  x_okl_xtd_sell_invs_tl_rec     OUT NOCOPY okl_xtd_sell_invs_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type := p_okl_xtd_sell_invs_tl_rec;
  ldefoklxtdsellinvstlrec        okl_xtd_sell_invs_tl_rec_type;
  CURSOR get_languages IS
    SELECT *
      FROM FND_LANGUAGES
     WHERE INSTALLED_FLAG IN ('I', 'B');
  ---------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtd_sell_invs_tl_rec IN  okl_xtd_sell_invs_tl_rec_type,
    x_okl_xtd_sell_invs_tl_rec OUT NOCOPY okl_xtd_sell_invs_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtd_sell_invs_tl_rec := p_okl_xtd_sell_invs_tl_rec;
    x_okl_xtd_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_xtd_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_xtd_sell_invs_tl_rec,        -- IN
    l_okl_xtd_sell_invs_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  FOR l_lang_rec IN get_languages LOOP
    l_okl_xtd_sell_invs_tl_rec.LANGUAGE := l_lang_rec.language_code;
    INSERT INTO OKL_XTD_SELL_INVS_TL(
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
        l_okl_xtd_sell_invs_tl_rec.id,
        l_okl_xtd_sell_invs_tl_rec.LANGUAGE,
        l_okl_xtd_sell_invs_tl_rec.source_lang,
        l_okl_xtd_sell_invs_tl_rec.sfwt_flag,
        l_okl_xtd_sell_invs_tl_rec.created_by,
        l_okl_xtd_sell_invs_tl_rec.creation_date,
        l_okl_xtd_sell_invs_tl_rec.last_updated_by,
        l_okl_xtd_sell_invs_tl_rec.last_update_date,
        l_okl_xtd_sell_invs_tl_rec.last_update_login);
  END LOOP;
  -- Set OUT values
  x_okl_xtd_sell_invs_tl_rec := l_okl_xtd_sell_invs_tl_rec;
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
-- insert_row for:OKL_XTD_SELL_INVS_V --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_rec                     IN esdv_rec_type,
  x_esdv_rec                     OUT NOCOPY esdv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esdv_rec                     esdv_rec_type;
  l_def_esdv_rec                 esdv_rec_type;
  l_esd_rec                      esd_rec_type;
  lx_esd_rec                     esd_rec_type;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
  lx_okl_xtd_sell_invs_tl_rec    okl_xtd_sell_invs_tl_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_esdv_rec	IN esdv_rec_type
  ) RETURN esdv_rec_type IS
    l_esdv_rec	esdv_rec_type := p_esdv_rec;
  BEGIN
    l_esdv_rec.CREATION_DATE := SYSDATE;
    l_esdv_rec.CREATED_BY := Fnd_Global.USER_ID;
    l_esdv_rec.LAST_UPDATE_DATE := l_esdv_rec.CREATION_DATE;
    l_esdv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_esdv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_esdv_rec);
  END fill_who_columns;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_V --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_esdv_rec IN  esdv_rec_type,
    x_esdv_rec OUT NOCOPY esdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esdv_rec := p_esdv_rec;
    x_esdv_rec.OBJECT_VERSION_NUMBER := 1;
    x_esdv_rec.SFWT_FLAG := 'N';

	IF (x_esdv_rec.request_id IS NULL OR x_esdv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_esdv_rec.request_id,
	  	   x_esdv_rec.program_application_id,
	  	   x_esdv_rec.program_id,
	  	   x_esdv_rec.program_update_date
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
  l_esdv_rec := null_out_defaults(p_esdv_rec);
  -- Set primary key value
  l_esdv_rec.ID := get_seq_id;
  --- Setting item attributes
  l_return_status := Set_Attributes(
    l_esdv_rec,                        -- IN
    l_def_esdv_rec);                   -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_esdv_rec := fill_who_columns(l_def_esdv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_esdv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_esdv_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_esdv_rec, l_esd_rec);
  migrate(l_def_esdv_rec, l_okl_xtd_sell_invs_tl_rec);
  --------------------------------------------
  -- Call the INSERT_ROW for each child record
  --------------------------------------------
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_esd_rec,
    lx_esd_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_esd_rec, l_def_esdv_rec);
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtd_sell_invs_tl_rec,
    lx_okl_xtd_sell_invs_tl_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_xtd_sell_invs_tl_rec, l_def_esdv_rec);
  -- Set OUT values
  x_esdv_rec := l_def_esdv_rec;
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
-- PL/SQL TBL insert_row for:ESDV_TBL --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_tbl                     IN esdv_tbl_type,
  x_esdv_tbl                     OUT NOCOPY esdv_tbl_type) IS

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
  IF (p_esdv_tbl.COUNT > 0) THEN
    i := p_esdv_tbl.FIRST;
    LOOP
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_esdv_rec                     => p_esdv_tbl(i),
        x_esdv_rec                     => x_esdv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_esdv_tbl.LAST);
      i := p_esdv_tbl.NEXT(i);
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
-- lock_row for:OKL_XTD_SELL_INVS_B --
--------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esd_rec                      IN esd_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_esd_rec IN esd_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_XTD_SELL_INVS_B
   WHERE ID = p_esd_rec.id
     AND OBJECT_VERSION_NUMBER = p_esd_rec.object_version_number
  FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR  lchk_csr (p_esd_rec IN esd_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_XTD_SELL_INVS_B
  WHERE ID = p_esd_rec.id;
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_object_version_number       OKL_XTD_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
  lc_object_version_number      OKL_XTD_SELL_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
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
    OPEN lock_csr(p_esd_rec);
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
    OPEN lchk_csr(p_esd_rec);
    FETCH lchk_csr INTO lc_object_version_number;
    lc_row_notfound := lchk_csr%NOTFOUND;
    CLOSE lchk_csr;
  END IF;
  IF (lc_row_notfound) THEN
    Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number > p_esd_rec.object_version_number THEN
    Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number <> p_esd_rec.object_version_number THEN
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
-- lock_row for:OKL_XTD_SELL_INVS_TL --
---------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_okl_xtd_sell_invs_tl_rec IN okl_xtd_sell_invs_tl_rec_type) IS
  SELECT *
    FROM OKL_XTD_SELL_INVS_TL
   WHERE ID = p_okl_xtd_sell_invs_tl_rec.id
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
    OPEN lock_csr(p_okl_xtd_sell_invs_tl_rec);
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
-- lock_row for:OKL_XTD_SELL_INVS_V --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_rec                     IN esdv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esd_rec                      esd_rec_type;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
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
  migrate(p_esdv_rec, l_esd_rec);
  migrate(p_esdv_rec, l_okl_xtd_sell_invs_tl_rec);
  --------------------------------------------
  -- Call the LOCK_ROW for each child record
  --------------------------------------------
  lock_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_esd_rec
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
    l_okl_xtd_sell_invs_tl_rec
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
-- PL/SQL TBL lock_row for:ESDV_TBL --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_tbl                     IN esdv_tbl_type) IS

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
  IF (p_esdv_tbl.COUNT > 0) THEN
    i := p_esdv_tbl.FIRST;
    LOOP
      lock_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_esdv_rec                     => p_esdv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_esdv_tbl.LAST);
      i := p_esdv_tbl.NEXT(i);
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
-- update_row for:OKL_XTD_SELL_INVS_B --
----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esd_rec                      IN esd_rec_type,
  x_esd_rec                      OUT NOCOPY esd_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esd_rec                      esd_rec_type := p_esd_rec;
  l_def_esd_rec                  esd_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_esd_rec	IN esd_rec_type,
    x_esd_rec	OUT NOCOPY esd_rec_type
  ) RETURN VARCHAR2 IS
    l_esd_rec                      esd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esd_rec := p_esd_rec;
    -- Get current database values
    l_esd_rec := get_rec(p_esd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_esd_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.id := l_esd_rec.id;
    END IF;
    IF (x_esd_rec.xls_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.xls_id := l_esd_rec.xls_id;
    END IF;
    IF (x_esd_rec.ild_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.ild_id := l_esd_rec.ild_id;
    END IF;
    IF (x_esd_rec.account_class = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.account_class := l_esd_rec.account_class;
    END IF;
    IF (x_esd_rec.code_combination_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.code_combination_id := l_esd_rec.code_combination_id;
    END IF;
    IF (x_esd_rec.object_version_number = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.object_version_number := l_esd_rec.object_version_number;
    END IF;
    IF (x_esd_rec.amount = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.amount := l_esd_rec.amount;
    END IF;
    IF (x_esd_rec.percent = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.percent := l_esd_rec.percent;
    END IF;
    IF (x_esd_rec.request_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.request_id := l_esd_rec.request_id;
    END IF;
    IF (x_esd_rec.program_application_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.program_application_id := l_esd_rec.program_application_id;
    END IF;
    IF (x_esd_rec.program_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.program_id := l_esd_rec.program_id;
    END IF;
    IF (x_esd_rec.program_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esd_rec.program_update_date := l_esd_rec.program_update_date;
    END IF;
    IF (x_esd_rec.org_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.org_id := l_esd_rec.org_id;
    END IF;
    IF (x_esd_rec.attribute_category = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute_category := l_esd_rec.attribute_category;
    END IF;
    IF (x_esd_rec.attribute1 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute1 := l_esd_rec.attribute1;
    END IF;
    IF (x_esd_rec.attribute2 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute2 := l_esd_rec.attribute2;
    END IF;
    IF (x_esd_rec.attribute3 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute3 := l_esd_rec.attribute3;
    END IF;
    IF (x_esd_rec.attribute4 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute4 := l_esd_rec.attribute4;
    END IF;
    IF (x_esd_rec.attribute5 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute5 := l_esd_rec.attribute5;
    END IF;
    IF (x_esd_rec.attribute6 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute6 := l_esd_rec.attribute6;
    END IF;
    IF (x_esd_rec.attribute7 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute7 := l_esd_rec.attribute7;
    END IF;
    IF (x_esd_rec.attribute8 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute8 := l_esd_rec.attribute8;
    END IF;
    IF (x_esd_rec.attribute9 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute9 := l_esd_rec.attribute9;
    END IF;
    IF (x_esd_rec.attribute10 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute10 := l_esd_rec.attribute10;
    END IF;
    IF (x_esd_rec.attribute11 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute11 := l_esd_rec.attribute11;
    END IF;
    IF (x_esd_rec.attribute12 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute12 := l_esd_rec.attribute12;
    END IF;
    IF (x_esd_rec.attribute13 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute13 := l_esd_rec.attribute13;
    END IF;
    IF (x_esd_rec.attribute14 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute14 := l_esd_rec.attribute14;
    END IF;
    IF (x_esd_rec.attribute15 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esd_rec.attribute15 := l_esd_rec.attribute15;
    END IF;
    IF (x_esd_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.created_by := l_esd_rec.created_by;
    END IF;
    IF (x_esd_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esd_rec.creation_date := l_esd_rec.creation_date;
    END IF;
    IF (x_esd_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.last_updated_by := l_esd_rec.last_updated_by;
    END IF;
    IF (x_esd_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esd_rec.last_update_date := l_esd_rec.last_update_date;
    END IF;
    IF (x_esd_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_esd_rec.last_update_login := l_esd_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_B --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_esd_rec IN  esd_rec_type,
    x_esd_rec OUT NOCOPY esd_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esd_rec := p_esd_rec;
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
    p_esd_rec,                         -- IN
    l_esd_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_esd_rec, l_def_esd_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_XTD_SELL_INVS_B
  SET XLS_ID = l_def_esd_rec.xls_id,
      ILD_ID = l_def_esd_rec.ild_id,
      ACCOUNT_CLASS = l_def_esd_rec.account_class,
      CODE_COMBINATION_ID = l_def_esd_rec.code_combination_id,
      OBJECT_VERSION_NUMBER = l_def_esd_rec.object_version_number,
      AMOUNT = l_def_esd_rec.amount,
      PERCENT = l_def_esd_rec.percent,
      REQUEST_ID = l_def_esd_rec.request_id,
      PROGRAM_APPLICATION_ID = l_def_esd_rec.program_application_id,
      PROGRAM_ID = l_def_esd_rec.program_id,
      PROGRAM_UPDATE_DATE = l_def_esd_rec.program_update_date,
      ORG_ID = l_def_esd_rec.org_id,
      ATTRIBUTE_CATEGORY = l_def_esd_rec.attribute_category,
      ATTRIBUTE1 = l_def_esd_rec.attribute1,
      ATTRIBUTE2 = l_def_esd_rec.attribute2,
      ATTRIBUTE3 = l_def_esd_rec.attribute3,
      ATTRIBUTE4 = l_def_esd_rec.attribute4,
      ATTRIBUTE5 = l_def_esd_rec.attribute5,
      ATTRIBUTE6 = l_def_esd_rec.attribute6,
      ATTRIBUTE7 = l_def_esd_rec.attribute7,
      ATTRIBUTE8 = l_def_esd_rec.attribute8,
      ATTRIBUTE9 = l_def_esd_rec.attribute9,
      ATTRIBUTE10 = l_def_esd_rec.attribute10,
      ATTRIBUTE11 = l_def_esd_rec.attribute11,
      ATTRIBUTE12 = l_def_esd_rec.attribute12,
      ATTRIBUTE13 = l_def_esd_rec.attribute13,
      ATTRIBUTE14 = l_def_esd_rec.attribute14,
      ATTRIBUTE15 = l_def_esd_rec.attribute15,
      CREATED_BY = l_def_esd_rec.created_by,
      CREATION_DATE = l_def_esd_rec.creation_date,
      LAST_UPDATED_BY = l_def_esd_rec.last_updated_by,
      LAST_UPDATE_DATE = l_def_esd_rec.last_update_date,
      LAST_UPDATE_LOGIN = l_def_esd_rec.last_update_login
  WHERE ID = l_def_esd_rec.id;

  x_esd_rec := l_def_esd_rec;
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
-- update_row for:OKL_XTD_SELL_INVS_TL --
-----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type,
  x_okl_xtd_sell_invs_tl_rec     OUT NOCOPY okl_xtd_sell_invs_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type := p_okl_xtd_sell_invs_tl_rec;
  ldefoklxtdsellinvstlrec        okl_xtd_sell_invs_tl_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_okl_xtd_sell_invs_tl_rec	IN okl_xtd_sell_invs_tl_rec_type,
    x_okl_xtd_sell_invs_tl_rec	OUT NOCOPY okl_xtd_sell_invs_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtd_sell_invs_tl_rec := p_okl_xtd_sell_invs_tl_rec;
    -- Get current database values
    l_okl_xtd_sell_invs_tl_rec := get_rec(p_okl_xtd_sell_invs_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtd_sell_invs_tl_rec.id := l_okl_xtd_sell_invs_tl_rec.id;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtd_sell_invs_tl_rec.LANGUAGE := l_okl_xtd_sell_invs_tl_rec.LANGUAGE;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtd_sell_invs_tl_rec.source_lang := l_okl_xtd_sell_invs_tl_rec.source_lang;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtd_sell_invs_tl_rec.sfwt_flag := l_okl_xtd_sell_invs_tl_rec.sfwt_flag;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtd_sell_invs_tl_rec.created_by := l_okl_xtd_sell_invs_tl_rec.created_by;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_okl_xtd_sell_invs_tl_rec.creation_date := l_okl_xtd_sell_invs_tl_rec.creation_date;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtd_sell_invs_tl_rec.last_updated_by := l_okl_xtd_sell_invs_tl_rec.last_updated_by;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_okl_xtd_sell_invs_tl_rec.last_update_date := l_okl_xtd_sell_invs_tl_rec.last_update_date;
    END IF;
    IF (x_okl_xtd_sell_invs_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtd_sell_invs_tl_rec.last_update_login := l_okl_xtd_sell_invs_tl_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtd_sell_invs_tl_rec IN  okl_xtd_sell_invs_tl_rec_type,
    x_okl_xtd_sell_invs_tl_rec OUT NOCOPY okl_xtd_sell_invs_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtd_sell_invs_tl_rec := p_okl_xtd_sell_invs_tl_rec;
    x_okl_xtd_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_xtd_sell_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_xtd_sell_invs_tl_rec,        -- IN
    l_okl_xtd_sell_invs_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_okl_xtd_sell_invs_tl_rec, ldefoklxtdsellinvstlrec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_XTD_SELL_INVS_TL
  SET CREATED_BY = ldefoklxtdsellinvstlrec.created_by,
      CREATION_DATE = ldefoklxtdsellinvstlrec.creation_date,
      LAST_UPDATED_BY = ldefoklxtdsellinvstlrec.last_updated_by,
      LAST_UPDATE_DATE = ldefoklxtdsellinvstlrec.last_update_date,
      LAST_UPDATE_LOGIN = ldefoklxtdsellinvstlrec.last_update_login
  WHERE ID = ldefoklxtdsellinvstlrec.id
    --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

  UPDATE  OKL_XTD_SELL_INVS_TL
  SET SFWT_FLAG = 'Y'
  WHERE ID = ldefoklxtdsellinvstlrec.id
    AND SOURCE_LANG <> USERENV('LANG');

  x_okl_xtd_sell_invs_tl_rec := ldefoklxtdsellinvstlrec;
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
-- update_row for:OKL_XTD_SELL_INVS_V --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_rec                     IN esdv_rec_type,
  x_esdv_rec                     OUT NOCOPY esdv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esdv_rec                     esdv_rec_type := p_esdv_rec;
  l_def_esdv_rec                 esdv_rec_type;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
  lx_okl_xtd_sell_invs_tl_rec    okl_xtd_sell_invs_tl_rec_type;
  l_esd_rec                      esd_rec_type;
  lx_esd_rec                     esd_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_esdv_rec	IN esdv_rec_type
  ) RETURN esdv_rec_type IS
    l_esdv_rec	esdv_rec_type := p_esdv_rec;
  BEGIN
    l_esdv_rec.LAST_UPDATE_DATE := l_esdv_rec.CREATION_DATE;
    l_esdv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_esdv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_esdv_rec);
  END fill_who_columns;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_esdv_rec	IN esdv_rec_type,
    x_esdv_rec	OUT NOCOPY esdv_rec_type
  ) RETURN VARCHAR2 IS
    l_esdv_rec                     esdv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esdv_rec := p_esdv_rec;
    -- Get current database values
    l_esdv_rec := get_rec(p_esdv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_esdv_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.id := l_esdv_rec.id;
    END IF;
    IF (x_esdv_rec.object_version_number = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.object_version_number := l_esdv_rec.object_version_number;
    END IF;
    IF (x_esdv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.sfwt_flag := l_esdv_rec.sfwt_flag;
    END IF;
    IF (x_esdv_rec.xls_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.xls_id := l_esdv_rec.xls_id;
    END IF;
    IF (x_esdv_rec.ild_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.ild_id := l_esdv_rec.ild_id;
    END IF;
    IF (x_esdv_rec.account_class = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.account_class := l_esdv_rec.account_class;
    END IF;
    IF (x_esdv_rec.code_combination_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.code_combination_id := l_esdv_rec.code_combination_id;
    END IF;
    IF (x_esdv_rec.amount = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.amount := l_esdv_rec.amount;
    END IF;
    IF (x_esdv_rec.percent = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.percent := l_esdv_rec.percent;
    END IF;
    IF (x_esdv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute_category := l_esdv_rec.attribute_category;
    END IF;
    IF (x_esdv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute1 := l_esdv_rec.attribute1;
    END IF;
    IF (x_esdv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute2 := l_esdv_rec.attribute2;
    END IF;
    IF (x_esdv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute3 := l_esdv_rec.attribute3;
    END IF;
    IF (x_esdv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute4 := l_esdv_rec.attribute4;
    END IF;
    IF (x_esdv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute5 := l_esdv_rec.attribute5;
    END IF;
    IF (x_esdv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute6 := l_esdv_rec.attribute6;
    END IF;
    IF (x_esdv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute7 := l_esdv_rec.attribute7;
    END IF;
    IF (x_esdv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute8 := l_esdv_rec.attribute8;
    END IF;
    IF (x_esdv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute9 := l_esdv_rec.attribute9;
    END IF;
    IF (x_esdv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute10 := l_esdv_rec.attribute10;
    END IF;
    IF (x_esdv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute11 := l_esdv_rec.attribute11;
    END IF;
    IF (x_esdv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute12 := l_esdv_rec.attribute12;
    END IF;
    IF (x_esdv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute13 := l_esdv_rec.attribute13;
    END IF;
    IF (x_esdv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute14 := l_esdv_rec.attribute14;
    END IF;
    IF (x_esdv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
    THEN
      x_esdv_rec.attribute15 := l_esdv_rec.attribute15;
    END IF;
    IF (x_esdv_rec.request_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.request_id := l_esdv_rec.request_id;
    END IF;
    IF (x_esdv_rec.program_application_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.program_application_id := l_esdv_rec.program_application_id;
    END IF;
    IF (x_esdv_rec.program_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.program_id := l_esdv_rec.program_id;
    END IF;
    IF (x_esdv_rec.program_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esdv_rec.program_update_date := l_esdv_rec.program_update_date;
    END IF;
    IF (x_esdv_rec.org_id = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.org_id := l_esdv_rec.org_id;
    END IF;
    IF (x_esdv_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.created_by := l_esdv_rec.created_by;
    END IF;
    IF (x_esdv_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esdv_rec.creation_date := l_esdv_rec.creation_date;
    END IF;
    IF (x_esdv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.last_updated_by := l_esdv_rec.last_updated_by;
    END IF;
    IF (x_esdv_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_esdv_rec.last_update_date := l_esdv_rec.last_update_date;
    END IF;
    IF (x_esdv_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_esdv_rec.last_update_login := l_esdv_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_V --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_esdv_rec IN  esdv_rec_type,
    x_esdv_rec OUT NOCOPY esdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_esdv_rec := p_esdv_rec;
    x_esdv_rec.OBJECT_VERSION_NUMBER := NVL(x_esdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

	IF (x_esdv_rec.request_id IS NULL OR x_esdv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_esdv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_esdv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_esdv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_esdv_rec.program_update_date,SYSDATE)
      INTO
        x_esdv_rec.request_id,
        x_esdv_rec.program_application_id,
        x_esdv_rec.program_id,
        x_esdv_rec.program_update_date
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
    p_esdv_rec,                        -- IN
    l_esdv_rec);                       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_esdv_rec, l_def_esdv_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_esdv_rec := fill_who_columns(l_def_esdv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_esdv_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_esdv_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_esdv_rec, l_okl_xtd_sell_invs_tl_rec);
  migrate(l_def_esdv_rec, l_esd_rec);
  --------------------------------------------
  -- Call the UPDATE_ROW for each child record
  --------------------------------------------
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtd_sell_invs_tl_rec,
    lx_okl_xtd_sell_invs_tl_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_xtd_sell_invs_tl_rec, l_def_esdv_rec);
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_esd_rec,
    lx_esd_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_esd_rec, l_def_esdv_rec);
  x_esdv_rec := l_def_esdv_rec;
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
-- PL/SQL TBL update_row for:ESDV_TBL --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_tbl                     IN esdv_tbl_type,
  x_esdv_tbl                     OUT NOCOPY esdv_tbl_type) IS

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
  IF (p_esdv_tbl.COUNT > 0) THEN
    i := p_esdv_tbl.FIRST;
    LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_esdv_rec                     => p_esdv_tbl(i),
        x_esdv_rec                     => x_esdv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_esdv_tbl.LAST);
      i := p_esdv_tbl.NEXT(i);
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
-- delete_row for:OKL_XTD_SELL_INVS_B --
----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esd_rec                      IN esd_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esd_rec                      esd_rec_type:= p_esd_rec;
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
  DELETE FROM OKL_XTD_SELL_INVS_B
   WHERE ID = l_esd_rec.id;

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
-- delete_row for:OKL_XTD_SELL_INVS_TL --
-----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtd_sell_invs_tl_rec     IN okl_xtd_sell_invs_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type:= p_okl_xtd_sell_invs_tl_rec;
  l_row_notfound                 BOOLEAN := TRUE;
  ---------------------------------------------
  -- Set_Attributes for:OKL_XTD_SELL_INVS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtd_sell_invs_tl_rec IN  okl_xtd_sell_invs_tl_rec_type,
    x_okl_xtd_sell_invs_tl_rec OUT NOCOPY okl_xtd_sell_invs_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtd_sell_invs_tl_rec := p_okl_xtd_sell_invs_tl_rec;
    x_okl_xtd_sell_invs_tl_rec.LANGUAGE := USERENV('LANG');
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
    p_okl_xtd_sell_invs_tl_rec,        -- IN
    l_okl_xtd_sell_invs_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  DELETE FROM OKL_XTD_SELL_INVS_TL
   WHERE ID = l_okl_xtd_sell_invs_tl_rec.id;

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
-- delete_row for:OKL_XTD_SELL_INVS_V --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_rec                     IN esdv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_esdv_rec                     esdv_rec_type := p_esdv_rec;
  l_okl_xtd_sell_invs_tl_rec     okl_xtd_sell_invs_tl_rec_type;
  l_esd_rec                      esd_rec_type;
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
  migrate(l_esdv_rec, l_okl_xtd_sell_invs_tl_rec);
  migrate(l_esdv_rec, l_esd_rec);
  --------------------------------------------
  -- Call the DELETE_ROW for each child record
  --------------------------------------------
  delete_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtd_sell_invs_tl_rec
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
    l_esd_rec
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
-- PL/SQL TBL delete_row for:ESDV_TBL --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_esdv_tbl                     IN esdv_tbl_type) IS

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
  IF (p_esdv_tbl.COUNT > 0) THEN
    i := p_esdv_tbl.FIRST;
    LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_esdv_rec                     => p_esdv_tbl(i));

        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_esdv_tbl.LAST);
      i := p_esdv_tbl.NEXT(i);
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
END Okl_Esd_Pvt;

/
