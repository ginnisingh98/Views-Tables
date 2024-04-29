--------------------------------------------------------
--  DDL for Package Body OKL_RCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RCA_PVT" AS
/* $Header: OKLSRCAB.pls 120.8 2007/08/24 09:38:58 nikshah noship $ */
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
    DELETE FROM OKL_TXL_RCPT_APPS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_RCPT_APPS_ALL_B  B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TXL_RCPT_APPS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXL_RCPT_APPS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_RCPT_APPS_TL SUBB, OKL_TXL_RCPT_APPS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXL_RCPT_APPS_TL (
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
        FROM OKL_TXL_RCPT_APPS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_RCPT_APPS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_RCPT_APPS_B
  ---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Txl_Rcpt_Apps_B table.
  -- Business Rules  :
  -- Parameters      : p_rca_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     stream id.
  -- End of comments
  ---------------------------------------------------------------------------

   FUNCTION get_rec (
    p_rca_rec                      IN rca_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rca_rec_type IS
    CURSOR rca_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RCT_ID_DETAILS,
            CNR_ID,
            KHR_ID,
            LLN_ID,
            LSM_ID,
            ILE_ID,
            LINE_NUMBER,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
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
            LAST_UPDATE_LOGIN,
--  sty_id is stream type id of selected stream.
    	    STY_ID,
--  ar_invoice_id column added
    	    AR_INVOICE_ID
      FROM Okl_Txl_Rcpt_Apps_B
     WHERE okl_txl_rcpt_apps_b.id = p_id;
    l_rca_pk                       rca_pk_csr%ROWTYPE;
    l_rca_rec                      rca_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rca_pk_csr (p_rca_rec.id);
    FETCH rca_pk_csr INTO
              l_rca_rec.ID,
              l_rca_rec.RCT_ID_DETAILS,
              l_rca_rec.CNR_ID,
              l_rca_rec.KHR_ID,
              l_rca_rec.LLN_ID,
              l_rca_rec.LSM_ID,
              l_rca_rec.ILE_ID,
              l_rca_rec.LINE_NUMBER,
              l_rca_rec.OBJECT_VERSION_NUMBER,
              l_rca_rec.AMOUNT,
              l_rca_rec.REQUEST_ID,
              l_rca_rec.PROGRAM_APPLICATION_ID,
              l_rca_rec.PROGRAM_ID,
              l_rca_rec.PROGRAM_UPDATE_DATE,
              l_rca_rec.ORG_ID,
              l_rca_rec.ATTRIBUTE_CATEGORY,
              l_rca_rec.ATTRIBUTE1,
              l_rca_rec.ATTRIBUTE2,
              l_rca_rec.ATTRIBUTE3,
              l_rca_rec.ATTRIBUTE4,
              l_rca_rec.ATTRIBUTE5,
              l_rca_rec.ATTRIBUTE6,
              l_rca_rec.ATTRIBUTE7,
              l_rca_rec.ATTRIBUTE8,
              l_rca_rec.ATTRIBUTE9,
              l_rca_rec.ATTRIBUTE10,
              l_rca_rec.ATTRIBUTE11,
              l_rca_rec.ATTRIBUTE12,
              l_rca_rec.ATTRIBUTE13,
              l_rca_rec.ATTRIBUTE14,
              l_rca_rec.ATTRIBUTE15,
              l_rca_rec.CREATED_BY,
              l_rca_rec.CREATION_DATE,
              l_rca_rec.LAST_UPDATED_BY,
              l_rca_rec.LAST_UPDATE_DATE,
              l_rca_rec.LAST_UPDATE_LOGIN,
--  sty_id is stream type id of selected stream.
	      l_rca_rec.STY_ID,
	      l_rca_rec.AR_INVOICE_ID;
    x_no_data_found := rca_pk_csr%NOTFOUND;
    CLOSE rca_pk_csr;
    RETURN(l_rca_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rca_rec                      IN rca_rec_type
  ) RETURN rca_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rca_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_RCPT_APPS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txl_rcpt_apps_tl_rec_type IS
    CURSOR okl_txl_rcpt_apps_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Txl_Rcpt_Apps_Tl
     WHERE okl_txl_rcpt_apps_tl.id = p_id
       AND okl_txl_rcpt_apps_tl.LANGUAGE = p_language;
    l_okl_txl_rcpt_apps_tl_pk      okl_txl_rcpt_apps_tl_pk_csr%ROWTYPE;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_rcpt_apps_tl_pk_csr (p_okl_txl_rcpt_apps_tl_rec.id,
                                      p_okl_txl_rcpt_apps_tl_rec.LANGUAGE);
    FETCH okl_txl_rcpt_apps_tl_pk_csr INTO
              l_okl_txl_rcpt_apps_tl_rec.ID,
              l_okl_txl_rcpt_apps_tl_rec.LANGUAGE,
              l_okl_txl_rcpt_apps_tl_rec.SOURCE_LANG,
              l_okl_txl_rcpt_apps_tl_rec.SFWT_FLAG,
              l_okl_txl_rcpt_apps_tl_rec.DESCRIPTION,
              l_okl_txl_rcpt_apps_tl_rec.CREATED_BY,
              l_okl_txl_rcpt_apps_tl_rec.CREATION_DATE,
              l_okl_txl_rcpt_apps_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_rcpt_apps_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_rcpt_apps_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_rcpt_apps_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_rcpt_apps_tl_pk_csr;
    RETURN(l_okl_txl_rcpt_apps_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type
  ) RETURN okl_txl_rcpt_apps_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_rcpt_apps_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_RCPT_APPS_V
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the Okl_Txl_Rcpt_Apps_B table.
  -- Business Rules  :
  -- Parameters      : p_rcav_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     stream id.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_rcav_rec                     IN rcav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rcav_rec_type IS
    CURSOR okl_rcav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CNR_ID,
            LLN_ID,
            LSM_ID,
            KHR_ID,
            ILE_ID,
            RCT_ID_DETAILS,
            LINE_NUMBER,
            DESCRIPTION,
            AMOUNT,
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
--  sty_id is stream type id of selected stream.
      	    STY_ID,
	    AR_INVOICE_ID
      FROM Okl_Txl_Rcpt_Apps_V
     WHERE okl_txl_rcpt_apps_v.id = p_id;
    l_okl_rcav_pk                  okl_rcav_pk_csr%ROWTYPE;
    l_rcav_rec                     rcav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_rcav_pk_csr (p_rcav_rec.id);
    FETCH okl_rcav_pk_csr INTO
              l_rcav_rec.ID,
              l_rcav_rec.OBJECT_VERSION_NUMBER,
              l_rcav_rec.SFWT_FLAG,
              l_rcav_rec.CNR_ID,
              l_rcav_rec.LLN_ID,
              l_rcav_rec.LSM_ID,
              l_rcav_rec.KHR_ID,
              l_rcav_rec.ILE_ID,
              l_rcav_rec.RCT_ID_DETAILS,
              l_rcav_rec.LINE_NUMBER,
              l_rcav_rec.DESCRIPTION,
              l_rcav_rec.AMOUNT,
              l_rcav_rec.ATTRIBUTE_CATEGORY,
              l_rcav_rec.ATTRIBUTE1,
              l_rcav_rec.ATTRIBUTE2,
              l_rcav_rec.ATTRIBUTE3,
              l_rcav_rec.ATTRIBUTE4,
              l_rcav_rec.ATTRIBUTE5,
              l_rcav_rec.ATTRIBUTE6,
              l_rcav_rec.ATTRIBUTE7,
              l_rcav_rec.ATTRIBUTE8,
              l_rcav_rec.ATTRIBUTE9,
              l_rcav_rec.ATTRIBUTE10,
              l_rcav_rec.ATTRIBUTE11,
              l_rcav_rec.ATTRIBUTE12,
              l_rcav_rec.ATTRIBUTE13,
              l_rcav_rec.ATTRIBUTE14,
              l_rcav_rec.ATTRIBUTE15,
              l_rcav_rec.REQUEST_ID,
              l_rcav_rec.PROGRAM_APPLICATION_ID,
              l_rcav_rec.PROGRAM_ID,
              l_rcav_rec.PROGRAM_UPDATE_DATE,
              l_rcav_rec.ORG_ID,
              l_rcav_rec.CREATED_BY,
              l_rcav_rec.CREATION_DATE,
              l_rcav_rec.LAST_UPDATED_BY,
              l_rcav_rec.LAST_UPDATE_DATE,
              l_rcav_rec.LAST_UPDATE_LOGIN,
--  sty_id is stream type id of selected stream.
              l_rcav_rec.STY_ID,
	      l_rcav_rec.AR_INVOICE_ID;
    x_no_data_found := okl_rcav_pk_csr%NOTFOUND;
    CLOSE okl_rcav_pk_csr;
    RETURN(l_rcav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rcav_rec                     IN rcav_rec_type
  ) RETURN rcav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rcav_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_RCPT_APPS_V --
  ---------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : If the field has default values then equate it to null.
  -- Business Rules  :
  -- Parameters      : p_rcav_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     stream id.
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults (
    p_rcav_rec	IN rcav_rec_type
  ) RETURN rcav_rec_type IS
    l_rcav_rec	rcav_rec_type := p_rcav_rec;
  BEGIN
    IF (l_rcav_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.object_version_number := NULL;
    END IF;
    IF (l_rcav_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.sfwt_flag := NULL;
    END IF;
    IF (l_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.cnr_id := NULL;
    END IF;
    IF (l_rcav_rec.lln_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.lln_id := NULL;
    END IF;
    IF (l_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.lsm_id := NULL;
    END IF;
    IF (l_rcav_rec.khr_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.khr_id := NULL;
    END IF;
    IF (l_rcav_rec.ile_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.ile_id := NULL;
    END IF;
    IF (l_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.rct_id_details := NULL;
    END IF;
    IF (l_rcav_rec.line_number = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.line_number := NULL;
    END IF;
    IF (l_rcav_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.description := NULL;
    END IF;
    IF (l_rcav_rec.amount = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.amount := NULL;
    END IF;
    IF (l_rcav_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute_category := NULL;
    END IF;
    IF (l_rcav_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute1 := NULL;
    END IF;
    IF (l_rcav_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute2 := NULL;
    END IF;
    IF (l_rcav_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute3 := NULL;
    END IF;
    IF (l_rcav_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute4 := NULL;
    END IF;
    IF (l_rcav_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute5 := NULL;
    END IF;
    IF (l_rcav_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute6 := NULL;
    END IF;
    IF (l_rcav_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute7 := NULL;
    END IF;
    IF (l_rcav_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute8 := NULL;
    END IF;
    IF (l_rcav_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute9 := NULL;
    END IF;
    IF (l_rcav_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute10 := NULL;
    END IF;
    IF (l_rcav_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute11 := NULL;
    END IF;
    IF (l_rcav_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute12 := NULL;
    END IF;
    IF (l_rcav_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute13 := NULL;
    END IF;
    IF (l_rcav_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute14 := NULL;
    END IF;
    IF (l_rcav_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_rcav_rec.attribute15 := NULL;
    END IF;
    IF (l_rcav_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.request_id := NULL;
    END IF;
    IF (l_rcav_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.program_application_id := NULL;
    END IF;
    IF (l_rcav_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.program_id := NULL;
    END IF;
    IF (l_rcav_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_rcav_rec.program_update_date := NULL;
    END IF;
    IF (l_rcav_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.org_id := NULL;
    END IF;
    IF (l_rcav_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.created_by := NULL;
    END IF;
    IF (l_rcav_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_rcav_rec.creation_date := NULL;
    END IF;
    IF (l_rcav_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.last_updated_by := NULL;
    END IF;
    IF (l_rcav_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_rcav_rec.last_update_date := NULL;
    END IF;
    IF (l_rcav_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.last_update_login := NULL;
    END IF;
--  sty_id is stream type id of selected stream.
    IF (l_rcav_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.sty_id := NULL;
    END IF;
    IF (l_rcav_rec.ar_invoice_id = Okl_Api.G_MISS_NUM) THEN
      l_rcav_rec.ar_invoice_id := NULL;
    END IF;
    RETURN(l_rcav_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/17/2001
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_id(p_rcav_rec 		IN 	rcav_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_rcav_rec.id IS NULL) OR (p_rcav_rec.id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_id;

-- Start of comments
-- Procedure Name  : validate_org_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_org_id (p_rcav_rec IN rcav_rec_type,

  			                 x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      x_return_status := Okl_Util.check_org_id(p_rcav_rec.org_id);

  END validate_org_id;

-- Start of comments
-- Procedure Name  : validate_rct_id_details
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_rct_id_details (p_rcav_rec 		IN 	rcav_rec_type,
                          		   x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_validate_rct_id_details_csr IS
   SELECT '1'
   FROM   okl_trx_csh_receipt_b
   WHERE  id = p_rcav_rec.rct_id_details;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
  --check not null
  IF (p_rcav_rec.rct_id_details IS NULL) OR (p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM) THEN
    x_return_status:=Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RCT_ID_DETAILS');
    -- RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_validate_rct_id_details_csr;
   FETCH l_validate_rct_id_details_csr INTO l_dummy_var;
   CLOSE l_validate_rct_id_details_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RCT_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_TRX_CSH_RECEIPTS_B');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_rct_id_details;

-- Start of comments
-- Procedure Name  : validate_ile_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_ile_id(p_rcav_rec 		IN 	rcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

 CURSOR l_ile_id_csr IS
 SELECT '1'
 FROM okx_customer_accounts_v
 WHERE id1 = p_rcav_rec.ile_id;

 l_dummy_var   VARCHAR2(1):='0';

 BEGIN

 x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
 IF p_rcav_rec.ile_id IS NOT NULL THEN

   --check FK Relation with okx_custmrs_v
   OPEN l_ile_id_csr;
   FETCH l_ile_id_csr INTO l_dummy_var;
   CLOSE l_ile_id_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ILE_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKX_CUSTOMER_ACCOUNTS_V');

  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_ile_id;

-- Start of comments
-- Procedure Name  : validate_cnr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_cnr_id(p_rcav_rec 		IN 	rcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_cnr_id_csr IS
   SELECT '1'
   FROM   okl_cnsld_ar_hdrs_b
   WHERE  id = p_rcav_rec.cnr_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_rcav_rec.cnr_id IS NOT NULL THEN

   --check FK Relation with okx_custmrs_v
   OPEN  l_cnr_id_csr;
   FETCH l_cnr_id_csr INTO l_dummy_var;
   CLOSE l_cnr_id_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'CNR_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKL_CNSLD_AR_HDRS_B');

     RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;
 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_cnr_id;

-- Start of comments
-- Procedure Name  : validate_irm_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_khr_id(p_rcav_rec 		IN 	rcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_khr_id_csr IS
   SELECT '1'
   FROM   okl_k_headers_v 					OKL_K_HEADERS_V
   WHERE  id = p_rcav_rec.khr_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_rcav_rec.khr_id IS NOT NULL THEN

   --check FK Relation with okx_receipt_methods_v
 OPEN l_khr_id_csr;
 FETCH l_khr_id_csr INTO l_dummy_var;
 CLOSE l_khr_id_csr;

   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'KHR_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKL_K_HEADERS_B');

    RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_khr_id;

-- Start of comments
-- Procedure Name  : validate_lln_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_lln_id (p_rcav_rec 		IN 	rcav_rec_type,
                           x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_lln_id_csr IS
   SELECT '1'
   FROM   okl_cnsld_ar_lines_b
   WHERE  id = p_rcav_rec.lln_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;


 IF p_rcav_rec.lln_id IS NOT NULL THEN

   --check FK Relation with fnd_currencies
   OPEN l_lln_id_csr;
   FETCH l_lln_id_csr INTO l_dummy_var;
   CLOSE l_lln_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'LLN_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKL_CNSLD_AR_LINES_B');

     RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_lln_id;

-- Start of comments
-- Procedure Name  : validate_lsm_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_lsm_id (p_rcav_rec 		IN 	rcav_rec_type,
                           x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_lsm_id_csr IS
   SELECT '1'
   FROM   okl_cnsld_ar_strms_b
   WHERE  id = p_rcav_rec.lsm_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_rcav_rec.lsm_id IS NOT NULL THEN

   --check FK Relation with fnd_currencies
   OPEN l_lsm_id_csr;
   FETCH l_lsm_id_csr INTO l_dummy_var;
   CLOSE l_lsm_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_NO_PARENT_RECORD,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'LSM_ID',
                         p_token2       => G_CHILD_TABLE_TOKEN,
                         p_token2_value => G_VIEW,
                         p_token3       => G_PARENT_TABLE_TOKEN,
                         p_token3_value => 'OKL_CNSLD_AR_STRMS_B');

    RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

 END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

 END validate_lsm_id;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/17/2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_RCPT_APPS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rcav_rec IN  rcav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Added 04/16/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

    validate_id(p_rcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_org_id(p_rcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_rct_id_details(p_rcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_ile_id(p_rcav_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_cnr_id(p_rcav_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_khr_id(p_rcav_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_lln_id(p_rcav_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_lsm_id(p_rcav_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

-- end 04/17/2001 Bruno Vaghela ---

    IF p_rcav_rec.id = Okl_Api.G_MISS_NUM OR
       p_rcav_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_rcav_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_rcav_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
          p_rcav_rec.rct_id_details IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rct_id_details');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_rcav_rec.line_number = Okl_Api.G_MISS_NUM OR
          p_rcav_rec.line_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_TXL_RCPT_APPS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_rcav_rec IN rcav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

    IF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.rct_id_details IS NULL AND
	   p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.ile_id IS NULL AND
	   p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.cnr_id IS NULL AND
	   p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.khr_id IS NULL AND
	   p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.lln_id IS NULL AND
	   p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   p_rcav_rec.lsm_id IS NULL THEN

		    l_return_status := Okl_Api.G_RET_STS_ERROR;
		  	Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'REFERENCE MISSING');
		    RAISE G_EXCEPTION_HALT_VALIDATION;

	ELSIF p_rcav_rec.rct_id_details IS NOT NULL OR
		  p_rcav_rec.rct_id_details <> Okl_Api.G_MISS_NUM AND
	      p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.ile_id IS NULL AND
	   	  p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.cnr_id IS NULL AND
	   	  p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.khr_id IS NULL AND
	   	  p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	  	  p_rcav_rec.lln_id IS NULL AND
	   	  p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lsm_id IS NULL THEN

	   		RETURN (l_return_status);

	ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	      p_rcav_rec.rct_id_details IS NULL AND
	   	  p_rcav_rec.ile_id IS NOT NULL OR
		  p_rcav_rec.ile_id <> Okl_Api.G_MISS_NUM AND
	   	  p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.cnr_id IS NULL AND
	   	  p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.khr_id IS NULL AND
	   	  p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lln_id IS NULL AND
	  	  p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lsm_id IS NULL THEN

	   		RETURN (l_return_status);

	ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.rct_id_details IS NULL AND
	   	  p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.ile_id IS NULL AND
	   	  p_rcav_rec.cnr_id IS NOT NULL OR
 		  p_rcav_rec.cnr_id <> Okl_Api.G_MISS_NUM AND
	   	  p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.khr_id IS NULL AND
	   	  p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lln_id IS NULL AND
	   	  p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lsm_id IS NULL THEN

	   	    RETURN (l_return_status);

	ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.rct_id_details IS NULL AND
	   	  p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.ile_id IS NULL AND
	   	  p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.cnr_id IS NULL AND
	   	  p_rcav_rec.khr_id IS NOT NULL OR
 		  p_rcav_rec.khr_id <> Okl_Api.G_MISS_NUM AND
     	  p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lln_id IS NULL AND
	   	  p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lsm_id IS NULL THEN

	   		RETURN (l_return_status);

	ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.rct_id_details IS NULL AND
	   	  p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.ile_id IS NULL AND
	   	  p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.cnr_id IS NULL AND
	   	  p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.khr_id IS NULL AND
	   	  p_rcav_rec.lln_id IS NOT NULL OR
  		  p_rcav_rec.lln_id <> Okl_Api.G_MISS_NUM AND
	  	  p_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lsm_id IS NULL THEN

	   		RETURN (l_return_status);

 	ELSIF p_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.rct_id_details IS NULL AND
	   	  p_rcav_rec.ile_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.ile_id IS NULL AND
	   	  p_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.cnr_id IS NULL AND
	   	  p_rcav_rec.khr_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.khr_id IS NULL AND
   	   	  p_rcav_rec.lln_id = Okl_Api.G_MISS_NUM OR
	   	  p_rcav_rec.lln_id IS NOT NULL AND
	   	  p_rcav_rec.lsm_id IS NOT NULL OR
  		  p_rcav_rec.lsm_id <> Okl_Api.G_MISS_NUM THEN

			RETURN (l_return_status);

	ELSE  -- we have more than one reference to an invoice.  trying to avoid
		  -- cross validation at this time.

		    l_return_status := Okl_Api.G_RET_STS_ERROR;
			Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'MORE THAN ONE REFERENCE');
			RAISE G_EXCEPTION_HALT_VALIDATION;

	END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
     --just come out with return status
     NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
     -- notify  UNEXPECTED error
     l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  --END Added 04/17/2001 Bruno Vaghela ---

  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     stream id.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN rcav_rec_type,
    p_to	IN OUT NOCOPY rca_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rct_id_details := p_from.rct_id_details;
    p_to.cnr_id := p_from.cnr_id;
    p_to.khr_id := p_from.khr_id;
    p_to.lln_id := p_from.lln_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.ile_id := p_from.ile_id;
    p_to.line_number := p_from.line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
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
 -- New column stream type id added.
    p_to.sty_id := p_from.sty_id;
    p_to.ar_invoice_id := p_from.ar_invoice_id;
  END migrate;
 ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the new column
  --                                     stream id.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN rca_rec_type,
    p_to	IN OUT NOCOPY rcav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rct_id_details := p_from.rct_id_details;
    p_to.cnr_id := p_from.cnr_id;
    p_to.khr_id := p_from.khr_id;
    p_to.lln_id := p_from.lln_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.ile_id := p_from.ile_id;
    p_to.line_number := p_from.line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
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
 -- New column stream type id added.
    p_to.sty_id := p_from.sty_id;
    p_to.ar_invoice_id := p_from.ar_invoice_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rcav_rec_type,
    p_to	IN OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type
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
    p_from	IN okl_txl_rcpt_apps_tl_rec_type,
    p_to	IN OUT NOCOPY rcav_rec_type
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
  ------------------------------------------
  -- validate_row for:OKL_TXL_RCPT_APPS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_rec                     IN rcav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rcav_rec                     rcav_rec_type := p_rcav_rec;
    l_rca_rec                      rca_rec_type;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_rcav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rcav_rec);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL validate_row for:RCAV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_tbl                     IN rcav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcav_tbl.COUNT > 0) THEN
      i := p_rcav_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcav_rec                     => p_rcav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rcav_tbl.LAST);
        i := p_rcav_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_TXL_RCPT_APPS_B --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : insert_row
  -- Description     : Inserts the row in the table OKL_TXL_RCPT_APPS_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rca_rec, x_rca_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include sty_id column.
  -- End of comments
  ---------------------------------------------------------------------------

 PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rca_rec                      IN rca_rec_type,
    x_rca_rec                      OUT NOCOPY rca_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rca_rec                      rca_rec_type := p_rca_rec;
    l_def_rca_rec                  rca_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_B --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_rca_rec IN  rca_rec_type,
      x_rca_rec OUT NOCOPY rca_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rca_rec := p_rca_rec;
      IF x_rca_rec.org_id IS NULL OR x_rca_rec.org_id = OKL_API.G_MISS_NUM THEN
         x_rca_rec.org_id := mo_global.get_current_org_id;
      END IF;
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
      p_rca_rec,                         -- IN
      l_rca_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_RCPT_APPS_B(
        id,
        rct_id_details,
        cnr_id,
        khr_id,
        lln_id,
        lsm_id,
        ile_id,
        line_number,
        object_version_number,
        amount,
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
        last_update_login,
 -- New column stream type id added.
       	sty_id,
	ar_invoice_id)
      VALUES (
        l_rca_rec.id,
        l_rca_rec.rct_id_details,
        l_rca_rec.cnr_id,
        l_rca_rec.khr_id,
        l_rca_rec.lln_id,
        l_rca_rec.lsm_id,
        l_rca_rec.ile_id,
        l_rca_rec.line_number,
        l_rca_rec.object_version_number,
        l_rca_rec.amount,
        l_rca_rec.request_id,
        l_rca_rec.program_application_id,
        l_rca_rec.program_id,
        l_rca_rec.program_update_date,
        l_rca_rec.org_id,
        l_rca_rec.attribute_category,
        l_rca_rec.attribute1,
        l_rca_rec.attribute2,
        l_rca_rec.attribute3,
        l_rca_rec.attribute4,
        l_rca_rec.attribute5,
        l_rca_rec.attribute6,
        l_rca_rec.attribute7,
        l_rca_rec.attribute8,
        l_rca_rec.attribute9,
        l_rca_rec.attribute10,
        l_rca_rec.attribute11,
        l_rca_rec.attribute12,
        l_rca_rec.attribute13,
        l_rca_rec.attribute14,
        l_rca_rec.attribute15,
        l_rca_rec.created_by,
        l_rca_rec.creation_date,
        l_rca_rec.last_updated_by,
        l_rca_rec.last_update_date,
        l_rca_rec.last_update_login,
 -- New column stream type id added.
       	l_rca_rec.sty_id,
	l_rca_rec.ar_invoice_id);
    -- Set OUT values
    x_rca_rec := l_rca_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_TXL_RCPT_APPS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type,
    x_okl_txl_rcpt_apps_tl_rec     OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type := p_okl_txl_rcpt_apps_tl_rec;
    ldefokltxlrcptappstlrec        okl_txl_rcpt_apps_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_rcpt_apps_tl_rec IN  okl_txl_rcpt_apps_tl_rec_type,
      x_okl_txl_rcpt_apps_tl_rec OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_rcpt_apps_tl_rec := p_okl_txl_rcpt_apps_tl_rec;
      x_okl_txl_rcpt_apps_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_rcpt_apps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_rcpt_apps_tl_rec,        -- IN
      l_okl_txl_rcpt_apps_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_rcpt_apps_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_RCPT_APPS_TL(
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
          l_okl_txl_rcpt_apps_tl_rec.id,
          l_okl_txl_rcpt_apps_tl_rec.LANGUAGE,
          l_okl_txl_rcpt_apps_tl_rec.source_lang,
          l_okl_txl_rcpt_apps_tl_rec.sfwt_flag,
          l_okl_txl_rcpt_apps_tl_rec.description,
          l_okl_txl_rcpt_apps_tl_rec.created_by,
          l_okl_txl_rcpt_apps_tl_rec.creation_date,
          l_okl_txl_rcpt_apps_tl_rec.last_updated_by,
          l_okl_txl_rcpt_apps_tl_rec.last_update_date,
          l_okl_txl_rcpt_apps_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_rcpt_apps_tl_rec := l_okl_txl_rcpt_apps_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- insert_row for:OKL_TXL_RCPT_APPS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_rec                     IN rcav_rec_type,
    x_rcav_rec                     OUT NOCOPY rcav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rcav_rec                     rcav_rec_type;
    l_def_rcav_rec                 rcav_rec_type;
    l_rca_rec                      rca_rec_type;
    lx_rca_rec                     rca_rec_type;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
    lx_okl_txl_rcpt_apps_tl_rec    okl_txl_rcpt_apps_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rcav_rec	IN rcav_rec_type
    ) RETURN rcav_rec_type IS
      l_rcav_rec	rcav_rec_type := p_rcav_rec;
    BEGIN
    l_rcav_rec.LINE_NUMBER := 1;
	   l_rcav_rec.CREATION_DATE := SYSDATE;
    l_rcav_rec.CREATED_BY := Fnd_Global.User_Id;
    l_rcav_rec.LAST_UPDATE_DATE := l_rcav_rec.CREATION_DATE;
    l_rcav_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
    l_rcav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_rcav_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_rcav_rec IN  rcav_rec_type,
      x_rcav_rec OUT NOCOPY rcav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rcav_rec := p_rcav_rec;
      x_rcav_rec.OBJECT_VERSION_NUMBER := 1;
      x_rcav_rec.SFWT_FLAG := 'N';
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

    l_rcav_rec := null_out_defaults(p_rcav_rec);
    -- Set primary key value
    l_rcav_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rcav_rec,                        -- IN
      l_def_rcav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_rcav_rec := fill_who_columns(l_def_rcav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rcav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
--    l_return_status := Validate_Record(l_def_rcav_rec);  -- PROBLEMS
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rcav_rec, l_rca_rec);
    migrate(l_def_rcav_rec, l_okl_txl_rcpt_apps_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rca_rec,
      lx_rca_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rca_rec, l_def_rcav_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_rcpt_apps_tl_rec,
      lx_okl_txl_rcpt_apps_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_rcpt_apps_tl_rec, l_def_rcav_rec);
    -- Set OUT values
    x_rcav_rec := l_def_rcav_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL insert_row for:RCAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_tbl                     IN rcav_tbl_type,
    x_rcav_tbl                     OUT NOCOPY rcav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcav_tbl.COUNT > 0) THEN
      i := p_rcav_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcav_rec                     => p_rcav_tbl(i),
          x_rcav_rec                     => x_rcav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rcav_tbl.LAST);
        i := p_rcav_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_TXL_RCPT_APPS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rca_rec                      IN rca_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rca_rec IN rca_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_RCPT_APPS_B
     WHERE ID = p_rca_rec.id
       AND OBJECT_VERSION_NUMBER = p_rca_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rca_rec IN rca_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_RCPT_APPS_B
    WHERE ID = p_rca_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_RCPT_APPS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_RCPT_APPS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rca_rec);
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
      OPEN lchk_csr(p_rca_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rca_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rca_rec.object_version_number THEN
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_TXL_RCPT_APPS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_rcpt_apps_tl_rec IN okl_txl_rcpt_apps_tl_rec_type) IS
    SELECT *
      FROM OKL_TXL_RCPT_APPS_TL
     WHERE ID = p_okl_txl_rcpt_apps_tl_rec.id
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
      OPEN lock_csr(p_okl_txl_rcpt_apps_tl_rec);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- lock_row for:OKL_TXL_RCPT_APPS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_rec                     IN rcav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rca_rec                      rca_rec_type;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
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
    migrate(p_rcav_rec, l_rca_rec);
    migrate(p_rcav_rec, l_okl_txl_rcpt_apps_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rca_rec
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
      l_okl_txl_rcpt_apps_tl_rec
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL lock_row for:RCAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_tbl                     IN rcav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcav_tbl.COUNT > 0) THEN
      i := p_rcav_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcav_rec                     => p_rcav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rcav_tbl.LAST);
        i := p_rcav_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_TXL_RCPT_APPS_B --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Updates the row in the table OKL_TXL_RCPT_APPS_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rca_rec, x_rca_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include sty_id column.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rca_rec                      IN rca_rec_type,
    x_rca_rec                      OUT NOCOPY rca_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rca_rec                      rca_rec_type := p_rca_rec;
    l_def_rca_rec                  rca_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_rca_rec	IN rca_rec_type,
      x_rca_rec	OUT NOCOPY rca_rec_type
    ) RETURN VARCHAR2 IS
      l_rca_rec                      rca_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rca_rec := p_rca_rec;
      -- Get current database values
      l_rca_rec := get_rec(p_rca_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rca_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.id := l_rca_rec.id;
      END IF;
      IF (x_rca_rec.rct_id_details = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.rct_id_details := l_rca_rec.rct_id_details;
      END IF;
      IF (x_rca_rec.cnr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.cnr_id := l_rca_rec.cnr_id;
      END IF;
      IF (x_rca_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.khr_id := l_rca_rec.khr_id;
      END IF;
      IF (x_rca_rec.lln_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.lln_id := l_rca_rec.lln_id;
      END IF;
      IF (x_rca_rec.lsm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.lsm_id := l_rca_rec.lsm_id;
      END IF;
      IF (x_rca_rec.ile_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.ile_id := l_rca_rec.ile_id;
      END IF;
      IF (x_rca_rec.line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.line_number := l_rca_rec.line_number;
      END IF;
      IF (x_rca_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.object_version_number := l_rca_rec.object_version_number;
      END IF;
      IF (x_rca_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.amount := l_rca_rec.amount;
      END IF;
      IF (x_rca_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.request_id := l_rca_rec.request_id;
      END IF;
      IF (x_rca_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.program_application_id := l_rca_rec.program_application_id;
      END IF;
      IF (x_rca_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.program_id := l_rca_rec.program_id;
      END IF;
      IF (x_rca_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rca_rec.program_update_date := l_rca_rec.program_update_date;
      END IF;
      IF (x_rca_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.org_id := l_rca_rec.org_id;
      END IF;
      IF (x_rca_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute_category := l_rca_rec.attribute_category;
      END IF;
      IF (x_rca_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute1 := l_rca_rec.attribute1;
      END IF;
      IF (x_rca_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute2 := l_rca_rec.attribute2;
      END IF;
      IF (x_rca_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute3 := l_rca_rec.attribute3;
      END IF;
      IF (x_rca_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute4 := l_rca_rec.attribute4;
      END IF;
      IF (x_rca_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute5 := l_rca_rec.attribute5;
      END IF;
      IF (x_rca_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute6 := l_rca_rec.attribute6;
      END IF;
      IF (x_rca_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute7 := l_rca_rec.attribute7;
      END IF;
      IF (x_rca_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute8 := l_rca_rec.attribute8;
      END IF;
      IF (x_rca_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute9 := l_rca_rec.attribute9;
      END IF;
      IF (x_rca_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute10 := l_rca_rec.attribute10;
      END IF;
      IF (x_rca_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute11 := l_rca_rec.attribute11;
      END IF;
      IF (x_rca_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute12 := l_rca_rec.attribute12;
      END IF;
      IF (x_rca_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute13 := l_rca_rec.attribute13;
      END IF;
      IF (x_rca_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute14 := l_rca_rec.attribute14;
      END IF;
      IF (x_rca_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rca_rec.attribute15 := l_rca_rec.attribute15;
      END IF;
      IF (x_rca_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.created_by := l_rca_rec.created_by;
      END IF;
      IF (x_rca_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rca_rec.creation_date := l_rca_rec.creation_date;
      END IF;
      IF (x_rca_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.last_updated_by := l_rca_rec.last_updated_by;
      END IF;
      IF (x_rca_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rca_rec.last_update_date := l_rca_rec.last_update_date;
      END IF;
      IF (x_rca_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.last_update_login := l_rca_rec.last_update_login;
      END IF;
 -- New column stream type id added.
      IF (x_rca_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.sty_id := l_rca_rec.sty_id;
      END IF;
      IF (x_rca_rec.ar_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rca_rec.ar_invoice_id := l_rca_rec.ar_invoice_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_B --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_rca_rec IN  rca_rec_type,
      x_rca_rec OUT NOCOPY rca_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rca_rec := p_rca_rec;
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
      p_rca_rec,                         -- IN
      l_rca_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rca_rec, l_def_rca_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_RCPT_APPS_B
    SET RCT_ID_DETAILS = l_def_rca_rec.rct_id_details,
        CNR_ID = l_def_rca_rec.cnr_id,
        KHR_ID = l_def_rca_rec.khr_id,
        LLN_ID = l_def_rca_rec.lln_id,
        LSM_ID = l_def_rca_rec.lsm_id,
        ILE_ID = l_def_rca_rec.ile_id,
        LINE_NUMBER = l_def_rca_rec.line_number,
        OBJECT_VERSION_NUMBER = l_def_rca_rec.object_version_number,
        AMOUNT = l_def_rca_rec.amount,
        REQUEST_ID = l_def_rca_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_rca_rec.program_application_id,
        PROGRAM_ID = l_def_rca_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_rca_rec.program_update_date,
        ORG_ID = l_def_rca_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_rca_rec.attribute_category,
        ATTRIBUTE1 = l_def_rca_rec.attribute1,
        ATTRIBUTE2 = l_def_rca_rec.attribute2,
        ATTRIBUTE3 = l_def_rca_rec.attribute3,
        ATTRIBUTE4 = l_def_rca_rec.attribute4,
        ATTRIBUTE5 = l_def_rca_rec.attribute5,
        ATTRIBUTE6 = l_def_rca_rec.attribute6,
        ATTRIBUTE7 = l_def_rca_rec.attribute7,
        ATTRIBUTE8 = l_def_rca_rec.attribute8,
        ATTRIBUTE9 = l_def_rca_rec.attribute9,
        ATTRIBUTE10 = l_def_rca_rec.attribute10,
        ATTRIBUTE11 = l_def_rca_rec.attribute11,
        ATTRIBUTE12 = l_def_rca_rec.attribute12,
        ATTRIBUTE13 = l_def_rca_rec.attribute13,
        ATTRIBUTE14 = l_def_rca_rec.attribute14,
        ATTRIBUTE15 = l_def_rca_rec.attribute15,
        CREATED_BY = l_def_rca_rec.created_by,
        CREATION_DATE = l_def_rca_rec.creation_date,
        LAST_UPDATED_BY = l_def_rca_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rca_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rca_rec.last_update_login,
 -- New column stream type id added.
        STY_ID = l_def_rca_rec.sty_id,
	AR_INVOICE_ID = l_def_rca_rec.ar_invoice_id
    WHERE ID = l_def_rca_rec.id;

    x_rca_rec := l_def_rca_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_TXL_RCPT_APPS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type,
    x_okl_txl_rcpt_apps_tl_rec     OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type := p_okl_txl_rcpt_apps_tl_rec;
    ldefokltxlrcptappstlrec        okl_txl_rcpt_apps_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_okl_txl_rcpt_apps_tl_rec	IN okl_txl_rcpt_apps_tl_rec_type,
      x_okl_txl_rcpt_apps_tl_rec	OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_rcpt_apps_tl_rec := p_okl_txl_rcpt_apps_tl_rec;
      -- Get current database values
      l_okl_txl_rcpt_apps_tl_rec := get_rec(p_okl_txl_rcpt_apps_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.id := l_okl_txl_rcpt_apps_tl_rec.id;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.LANGUAGE := l_okl_txl_rcpt_apps_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.source_lang := l_okl_txl_rcpt_apps_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.sfwt_flag := l_okl_txl_rcpt_apps_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.description := l_okl_txl_rcpt_apps_tl_rec.description;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.created_by := l_okl_txl_rcpt_apps_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.creation_date := l_okl_txl_rcpt_apps_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.last_updated_by := l_okl_txl_rcpt_apps_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.last_update_date := l_okl_txl_rcpt_apps_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_rcpt_apps_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_txl_rcpt_apps_tl_rec.last_update_login := l_okl_txl_rcpt_apps_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_rcpt_apps_tl_rec IN  okl_txl_rcpt_apps_tl_rec_type,
      x_okl_txl_rcpt_apps_tl_rec OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_rcpt_apps_tl_rec := p_okl_txl_rcpt_apps_tl_rec;
      x_okl_txl_rcpt_apps_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_rcpt_apps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_rcpt_apps_tl_rec,        -- IN
      l_okl_txl_rcpt_apps_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_rcpt_apps_tl_rec, ldefokltxlrcptappstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_RCPT_APPS_TL
    SET DESCRIPTION = ldefokltxlrcptappstlrec.description,
        CREATED_BY = ldefokltxlrcptappstlrec.created_by,
        CREATION_DATE = ldefokltxlrcptappstlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxlrcptappstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxlrcptappstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxlrcptappstlrec.last_update_login
    WHERE ID = ldefokltxlrcptappstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TXL_RCPT_APPS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxlrcptappstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');
    x_okl_txl_rcpt_apps_tl_rec := ldefokltxlrcptappstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- update_row for:OKL_TXL_RCPT_APPS_V --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Updates the row in the table OKL_TXL_RCPT_APPS_B.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_rcav_rec, x_rcav_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include sty_id column.
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_rec                     IN rcav_rec_type,
    x_rcav_rec                     OUT NOCOPY rcav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rcav_rec                     rcav_rec_type := p_rcav_rec;
    l_def_rcav_rec                 rcav_rec_type;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
    lx_okl_txl_rcpt_apps_tl_rec    okl_txl_rcpt_apps_tl_rec_type;
    l_rca_rec                      rca_rec_type;
    lx_rca_rec                     rca_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rcav_rec	IN rcav_rec_type
    ) RETURN rcav_rec_type IS
      l_rcav_rec	rcav_rec_type := p_rcav_rec;
    BEGIN
      l_rcav_rec.CREATION_DATE := SYSDATE;
      l_rcav_rec.CREATED_BY := Fnd_Global.User_Id;
      l_rcav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rcav_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_rcav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_rcav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_rcav_rec	IN rcav_rec_type,
      x_rcav_rec	OUT NOCOPY rcav_rec_type
    ) RETURN VARCHAR2 IS
      l_rcav_rec                     rcav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN

      x_rcav_rec := p_rcav_rec;
      -- Get current database values
      l_rcav_rec := get_rec(p_rcav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (x_rcav_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.id := l_rcav_rec.id;
      END IF;
      IF (x_rcav_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.object_version_number := l_rcav_rec.object_version_number;
      END IF;
      IF (x_rcav_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.sfwt_flag := l_rcav_rec.sfwt_flag;
      END IF;
      IF (x_rcav_rec.cnr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.cnr_id := l_rcav_rec.cnr_id;
      END IF;
      IF (x_rcav_rec.lln_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.lln_id := l_rcav_rec.lln_id;
      END IF;
      IF (x_rcav_rec.lsm_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.lsm_id := l_rcav_rec.lsm_id;
      END IF;
      IF (x_rcav_rec.khr_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.khr_id := l_rcav_rec.khr_id;
      END IF;
      IF (x_rcav_rec.ile_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.ile_id := l_rcav_rec.ile_id;
      END IF;
      IF (x_rcav_rec.rct_id_details = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.rct_id_details := l_rcav_rec.rct_id_details;
      END IF;
      IF (x_rcav_rec.line_number = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.line_number := l_rcav_rec.line_number;
      END IF;
      IF (x_rcav_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.description := l_rcav_rec.description;
      END IF;
      IF (x_rcav_rec.amount = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.amount := l_rcav_rec.amount;
      END IF;
      IF (x_rcav_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute_category := l_rcav_rec.attribute_category;
      END IF;
      IF (x_rcav_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute1 := l_rcav_rec.attribute1;
      END IF;
      IF (x_rcav_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute2 := l_rcav_rec.attribute2;
      END IF;
      IF (x_rcav_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute3 := l_rcav_rec.attribute3;
      END IF;
      IF (x_rcav_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute4 := l_rcav_rec.attribute4;
      END IF;
      IF (x_rcav_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute5 := l_rcav_rec.attribute5;
      END IF;
      IF (x_rcav_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute6 := l_rcav_rec.attribute6;
      END IF;
      IF (x_rcav_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute7 := l_rcav_rec.attribute7;
      END IF;
      IF (x_rcav_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute8 := l_rcav_rec.attribute8;
      END IF;
      IF (x_rcav_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute9 := l_rcav_rec.attribute9;
      END IF;
      IF (x_rcav_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute10 := l_rcav_rec.attribute10;
      END IF;
      IF (x_rcav_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute11 := l_rcav_rec.attribute11;
      END IF;
      IF (x_rcav_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute12 := l_rcav_rec.attribute12;
      END IF;
      IF (x_rcav_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute13 := l_rcav_rec.attribute13;
      END IF;
      IF (x_rcav_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute14 := l_rcav_rec.attribute14;
      END IF;
      IF (x_rcav_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_rcav_rec.attribute15 := l_rcav_rec.attribute15;
      END IF;
      IF (x_rcav_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.request_id := l_rcav_rec.request_id;
      END IF;
      IF (x_rcav_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.program_application_id := l_rcav_rec.program_application_id;
      END IF;
      IF (x_rcav_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.program_id := l_rcav_rec.program_id;
      END IF;
      IF (x_rcav_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rcav_rec.program_update_date := l_rcav_rec.program_update_date;
      END IF;
      IF (x_rcav_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.org_id := l_rcav_rec.org_id;
      END IF;
      IF (x_rcav_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.created_by := l_rcav_rec.created_by;
      END IF;
      IF (x_rcav_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rcav_rec.creation_date := l_rcav_rec.creation_date;
      END IF;
      IF (x_rcav_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.last_updated_by := l_rcav_rec.last_updated_by;
      END IF;
      IF (x_rcav_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_rcav_rec.last_update_date := l_rcav_rec.last_update_date;
      END IF;
      IF (x_rcav_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.last_update_login := l_rcav_rec.last_update_login;
      END IF;
 -- New column stream type id added.
      IF (x_rcav_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.sty_id := l_rcav_rec.sty_id;
      END IF;
      IF (x_rcav_rec.ar_invoice_id = Okl_Api.G_MISS_NUM)
      THEN
        x_rcav_rec.ar_invoice_id := l_rcav_rec.ar_invoice_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_rcav_rec IN  rcav_rec_type,
      x_rcav_rec OUT NOCOPY rcav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_rcav_rec := p_rcav_rec;
      x_rcav_rec.OBJECT_VERSION_NUMBER := NVL(x_rcav_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rcav_rec,                        -- IN
      l_rcav_rec);                       -- OUT
    --- If any errors happen abort API

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_rcav_rec, l_def_rcav_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_rcav_rec := fill_who_columns(l_def_rcav_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_rcav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

-- problems.
--    l_return_status := Validate_Record(l_def_rcav_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rcav_rec, l_okl_txl_rcpt_apps_tl_rec);
    migrate(l_def_rcav_rec, l_rca_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_rcpt_apps_tl_rec,
      lx_okl_txl_rcpt_apps_tl_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_rcpt_apps_tl_rec, l_def_rcav_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rca_rec,
      lx_rca_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rca_rec, l_def_rcav_rec);
    x_rcav_rec := l_def_rcav_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL update_row for:RCAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_tbl                     IN rcav_tbl_type,
    x_rcav_tbl                     OUT NOCOPY rcav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcav_tbl.COUNT > 0) THEN
      i := p_rcav_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcav_rec                     => p_rcav_tbl(i),
          x_rcav_rec                     => x_rcav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rcav_tbl.LAST);
        i := p_rcav_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_TXL_RCPT_APPS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rca_rec                      IN rca_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rca_rec                      rca_rec_type:= p_rca_rec;
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
    DELETE FROM OKL_TXL_RCPT_APPS_B
     WHERE ID = l_rca_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_TXL_RCPT_APPS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_rcpt_apps_tl_rec     IN okl_txl_rcpt_apps_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type:= p_okl_txl_rcpt_apps_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_RCPT_APPS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_rcpt_apps_tl_rec IN  okl_txl_rcpt_apps_tl_rec_type,
      x_okl_txl_rcpt_apps_tl_rec OUT NOCOPY okl_txl_rcpt_apps_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_rcpt_apps_tl_rec := p_okl_txl_rcpt_apps_tl_rec;
      x_okl_txl_rcpt_apps_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txl_rcpt_apps_tl_rec,        -- IN
      l_okl_txl_rcpt_apps_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_RCPT_APPS_TL
     WHERE ID = l_okl_txl_rcpt_apps_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- delete_row for:OKL_TXL_RCPT_APPS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_rec                     IN rcav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rcav_rec                     rcav_rec_type := p_rcav_rec;
    l_okl_txl_rcpt_apps_tl_rec     okl_txl_rcpt_apps_tl_rec_type;
    l_rca_rec                      rca_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
/*
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_rcav_rec, l_okl_txl_rcpt_apps_tl_rec);
    migrate(l_rcav_rec, l_rca_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_rcpt_apps_tl_rec
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
      l_rca_rec
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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
  -- PL/SQL TBL delete_row for:RCAV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcav_tbl                     IN rcav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcav_tbl.COUNT > 0) THEN
      i := p_rcav_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcav_rec                     => p_rcav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_rcav_tbl.LAST);
        i := p_rcav_tbl.NEXT(i);
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
        'Okl_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_API.G_RET_STS_UNEXP_ERROR',
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

       ---- Party Merge

  PROCEDURE OKL_RCA_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_RCA_PARTY_MERGE';
   l_count                      NUMBER(10)   := 0;
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKL_RCA_PVT.OKL_RCA_PARTY_MERGE');
--
   arp_message.set_line('OKL_RCA_PVT.OKL_RCA_PARTY_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TXL_RCPT_APPS_B',FALSE);
--
--
  UPDATE OKL_TXL_RCPT_APPS_B RCAB
  SET RCAB.ILE_ID = p_to_fk_id
     ,RCAB.object_version_number = RCAB.object_version_number + 1
     ,RCAB.last_update_date      = SYSDATE
     ,RCAB.last_updated_by       = arp_standard.profile.user_id
     ,RCAB.last_update_login     = arp_standard.profile.last_update_login
  WHERE RCAB.ILE_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_RCA_PARTY_MERGE ;

END Okl_Rca_Pvt;

/
