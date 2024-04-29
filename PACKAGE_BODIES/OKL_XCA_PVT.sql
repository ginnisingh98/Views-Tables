--------------------------------------------------------
--  DDL for Package Body OKL_XCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XCA_PVT" AS
/* $Header: OKLSXCAB.pls 120.3 2007/08/08 12:55:26 arajagop ship $ */
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
    DELETE FROM OKL_XTL_CSH_APPS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_XTL_CSH_APPS_ALL_B B    --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );
/*
    WHERE (
            T.ID,
            T.LANGUAGE)
        IN (SELECT
                SUBT.ID,
                SUBT.LANGUAGE
              FROM OKL_XTL_CSH_APPS_TL SUBB, OKL_XTL_CSH_APPS_TL SUBT
             WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
*/
	 -- TAPI code generated code that doesn't compile.  Reason - no columns defined
	 -- in translation table.

  INSERT INTO OKL_XTL_CSH_APPS_TL (
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
      FROM OKL_XTL_CSH_APPS_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND B.LANGUAGE = USERENV('LANG')
       AND NOT EXISTS(
                  SELECT NULL
                    FROM OKL_XTL_CSH_APPS_TL T
                   WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                  );

END add_language;

---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTL_CSH_APPS_B
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_xca_rec                      IN xca_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN xca_rec_type IS
  CURSOR xca_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          XCR_ID_DETAILS,
          IRP_ID,
          LSM_ID,
          RCA_ID,
          CAT_ID,
          OBJECT_VERSION_NUMBER,
          INVOICE_NUMBER,
          AMOUNT_APPLIED,
          INVOICE_INSTALLMENT,
          AMOUNT_APPLIED_FROM,
          INVOICE_CURRENCY_CODE,
          TRANS_TO_RECEIPT_RATE,
          TRX_DATE,
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
    FROM Okl_Xtl_Csh_Apps_B
   WHERE okl_xtl_csh_apps_b.id = p_id;
  l_xca_pk                       xca_pk_csr%ROWTYPE;
  l_xca_rec                      xca_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN xca_pk_csr (p_xca_rec.id);
  FETCH xca_pk_csr INTO
            l_xca_rec.ID,
            l_xca_rec.XCR_ID_DETAILS,
            l_xca_rec.IRP_ID,
            l_xca_rec.LSM_ID,
            l_xca_rec.RCA_ID,
            l_xca_rec.CAT_ID,
            l_xca_rec.OBJECT_VERSION_NUMBER,
            l_xca_rec.INVOICE_NUMBER,
            l_xca_rec.AMOUNT_APPLIED,
            l_xca_rec.INVOICE_INSTALLMENT,
            l_xca_rec.AMOUNT_APPLIED_FROM,
            l_xca_rec.INVOICE_CURRENCY_CODE,
            l_xca_rec.TRANS_TO_RECEIPT_RATE,
            l_xca_rec.TRX_DATE,
            l_xca_rec.REQUEST_ID,
            l_xca_rec.PROGRAM_APPLICATION_ID,
            l_xca_rec.PROGRAM_ID,
            l_xca_rec.PROGRAM_UPDATE_DATE,
            l_xca_rec.ORG_ID,
            l_xca_rec.ATTRIBUTE_CATEGORY,
            l_xca_rec.ATTRIBUTE1,
            l_xca_rec.ATTRIBUTE2,
            l_xca_rec.ATTRIBUTE3,
            l_xca_rec.ATTRIBUTE4,
            l_xca_rec.ATTRIBUTE5,
            l_xca_rec.ATTRIBUTE6,
            l_xca_rec.ATTRIBUTE7,
            l_xca_rec.ATTRIBUTE8,
            l_xca_rec.ATTRIBUTE9,
            l_xca_rec.ATTRIBUTE10,
            l_xca_rec.ATTRIBUTE11,
            l_xca_rec.ATTRIBUTE12,
            l_xca_rec.ATTRIBUTE13,
            l_xca_rec.ATTRIBUTE14,
            l_xca_rec.ATTRIBUTE15,
            l_xca_rec.CREATED_BY,
            l_xca_rec.CREATION_DATE,
            l_xca_rec.LAST_UPDATED_BY,
            l_xca_rec.LAST_UPDATE_DATE,
            l_xca_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := xca_pk_csr%NOTFOUND;
  CLOSE xca_pk_csr;
  RETURN(l_xca_rec);
END get_rec;

FUNCTION get_rec (
  p_xca_rec                      IN xca_rec_type
) RETURN xca_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_xca_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTL_CSH_APPS_TL
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN okl_xtl_csh_apps_tl_rec_type IS
  CURSOR okl_xtl_csh_apps_tl_pk_csr (p_id                 IN NUMBER,
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
    FROM Okl_Xtl_Csh_Apps_Tl
   WHERE okl_xtl_csh_apps_tl.id = p_id
     AND okl_xtl_csh_apps_tl.LANGUAGE = p_language;
  l_okl_xtl_csh_apps_tl_pk       okl_xtl_csh_apps_tl_pk_csr%ROWTYPE;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_xtl_csh_apps_tl_pk_csr (p_okl_xtl_csh_apps_tl_rec.id,
                                   p_okl_xtl_csh_apps_tl_rec.LANGUAGE);
  FETCH okl_xtl_csh_apps_tl_pk_csr INTO
            l_okl_xtl_csh_apps_tl_rec.ID,
            l_okl_xtl_csh_apps_tl_rec.LANGUAGE,
            l_okl_xtl_csh_apps_tl_rec.SOURCE_LANG,
            l_okl_xtl_csh_apps_tl_rec.SFWT_FLAG,
            l_okl_xtl_csh_apps_tl_rec.CREATED_BY,
            l_okl_xtl_csh_apps_tl_rec.CREATION_DATE,
            l_okl_xtl_csh_apps_tl_rec.LAST_UPDATED_BY,
            l_okl_xtl_csh_apps_tl_rec.LAST_UPDATE_DATE,
            l_okl_xtl_csh_apps_tl_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_xtl_csh_apps_tl_pk_csr%NOTFOUND;
  CLOSE okl_xtl_csh_apps_tl_pk_csr;
  RETURN(l_okl_xtl_csh_apps_tl_rec);
END get_rec;

FUNCTION get_rec (
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type
) RETURN okl_xtl_csh_apps_tl_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_okl_xtl_csh_apps_tl_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_XTL_CSH_APPS_V
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_xcav_rec                     IN xcav_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN xcav_rec_type IS
  CURSOR okl_xcav_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          OBJECT_VERSION_NUMBER,
          SFWT_FLAG,
          LSM_ID,
          RCA_ID,
          CAT_ID,
          IRP_ID,
          XCR_ID_DETAILS,
          INVOICE_NUMBER,
          AMOUNT_APPLIED,
          INVOICE_INSTALLMENT,
          AMOUNT_APPLIED_FROM,
          INVOICE_CURRENCY_CODE,
          TRANS_TO_RECEIPT_RATE,
          TRX_DATE,
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
    FROM Okl_Xtl_Csh_Apps_V
   WHERE okl_xtl_csh_apps_v.id = p_id;
  l_okl_xcav_pk                  okl_xcav_pk_csr%ROWTYPE;
  l_xcav_rec                     xcav_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_xcav_pk_csr (p_xcav_rec.id);
  FETCH okl_xcav_pk_csr INTO
            l_xcav_rec.ID,
            l_xcav_rec.OBJECT_VERSION_NUMBER,
            l_xcav_rec.SFWT_FLAG,
            l_xcav_rec.LSM_ID,
            l_xcav_rec.RCA_ID,
            l_xcav_rec.CAT_ID,
            l_xcav_rec.IRP_ID,
            l_xcav_rec.XCR_ID_DETAILS,
            l_xcav_rec.INVOICE_NUMBER,
            l_xcav_rec.AMOUNT_APPLIED,
            l_xcav_rec.INVOICE_INSTALLMENT,
            l_xcav_rec.AMOUNT_APPLIED_FROM,
            l_xcav_rec.INVOICE_CURRENCY_CODE,
            l_xcav_rec.TRANS_TO_RECEIPT_RATE,
            l_xcav_rec.TRX_DATE,
            l_xcav_rec.ATTRIBUTE_CATEGORY,
            l_xcav_rec.ATTRIBUTE1,
            l_xcav_rec.ATTRIBUTE2,
            l_xcav_rec.ATTRIBUTE3,
            l_xcav_rec.ATTRIBUTE4,
            l_xcav_rec.ATTRIBUTE5,
            l_xcav_rec.ATTRIBUTE6,
            l_xcav_rec.ATTRIBUTE7,
            l_xcav_rec.ATTRIBUTE8,
            l_xcav_rec.ATTRIBUTE9,
            l_xcav_rec.ATTRIBUTE10,
            l_xcav_rec.ATTRIBUTE11,
            l_xcav_rec.ATTRIBUTE12,
            l_xcav_rec.ATTRIBUTE13,
            l_xcav_rec.ATTRIBUTE14,
            l_xcav_rec.ATTRIBUTE15,
            l_xcav_rec.REQUEST_ID,
            l_xcav_rec.PROGRAM_APPLICATION_ID,
            l_xcav_rec.PROGRAM_ID,
            l_xcav_rec.PROGRAM_UPDATE_DATE,
            l_xcav_rec.ORG_ID,
            l_xcav_rec.CREATED_BY,
            l_xcav_rec.CREATION_DATE,
            l_xcav_rec.LAST_UPDATED_BY,
            l_xcav_rec.LAST_UPDATE_DATE,
            l_xcav_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_xcav_pk_csr%NOTFOUND;
  CLOSE okl_xcav_pk_csr;
  RETURN(l_xcav_rec);
END get_rec;

FUNCTION get_rec (
  p_xcav_rec                     IN xcav_rec_type
) RETURN xcav_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_xcav_rec, l_row_notfound));
END get_rec;

--------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_XTL_CSH_APPS_V --
--------------------------------------------------------
FUNCTION null_out_defaults (
  p_xcav_rec	IN xcav_rec_type
) RETURN xcav_rec_type IS
  l_xcav_rec	xcav_rec_type := p_xcav_rec;
BEGIN
  IF (l_xcav_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.object_version_number := NULL;
  END IF;
  IF (l_xcav_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.sfwt_flag := NULL;
  END IF;
  IF (l_xcav_rec.lsm_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.lsm_id := NULL;
  END IF;
  IF (l_xcav_rec.rca_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.rca_id := NULL;
  END IF;
  IF (l_xcav_rec.cat_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.cat_id := NULL;
  END IF;
  IF (l_xcav_rec.irp_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.irp_id := NULL;
  END IF;
  IF (l_xcav_rec.xcr_id_details = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.xcr_id_details := NULL;
  END IF;
  IF (l_xcav_rec.invoice_number = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.invoice_number := NULL;
  END IF;
  IF (l_xcav_rec.amount_applied = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.amount_applied := NULL;
  END IF;
  IF (l_xcav_rec.invoice_installment = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.invoice_installment := NULL;
  END IF;
  IF (l_xcav_rec.amount_applied_from = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.amount_applied_from := NULL;
  END IF;
  IF (l_xcav_rec.invoice_currency_code = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.invoice_currency_code := NULL;
  END IF;
  IF (l_xcav_rec.TRANS_TO_RECEIPT_RATE = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.TRANS_TO_RECEIPT_RATE := NULL;
  END IF;
  IF (l_xcav_rec.TRX_DATE = Okl_Api.G_MISS_DATE) THEN
    l_xcav_rec.TRX_DATE := NULL;
  END IF;
  IF (l_xcav_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute_category := NULL;
  END IF;
  IF (l_xcav_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute1 := NULL;
  END IF;
  IF (l_xcav_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute2 := NULL;
  END IF;
  IF (l_xcav_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute3 := NULL;
  END IF;
  IF (l_xcav_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute4 := NULL;
  END IF;
  IF (l_xcav_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute5 := NULL;
  END IF;
  IF (l_xcav_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute6 := NULL;
  END IF;
  IF (l_xcav_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute7 := NULL;
  END IF;
  IF (l_xcav_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute8 := NULL;
  END IF;
  IF (l_xcav_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute9 := NULL;
  END IF;
  IF (l_xcav_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute10 := NULL;
  END IF;
  IF (l_xcav_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute11 := NULL;
  END IF;
  IF (l_xcav_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute12 := NULL;
  END IF;
  IF (l_xcav_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute13 := NULL;
  END IF;
  IF (l_xcav_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute14 := NULL;
  END IF;
  IF (l_xcav_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
    l_xcav_rec.attribute15 := NULL;
  END IF;
  IF (l_xcav_rec.request_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.request_id := NULL;
  END IF;
  IF (l_xcav_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.program_application_id := NULL;
  END IF;
  IF (l_xcav_rec.program_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.program_id := NULL;
  END IF;
  IF (l_xcav_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
    l_xcav_rec.program_update_date := NULL;
  END IF;
  IF (l_xcav_rec.org_id = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.org_id := NULL;
  END IF;
  IF (l_xcav_rec.created_by = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.created_by := NULL;
  END IF;
  IF (l_xcav_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
    l_xcav_rec.creation_date := NULL;
  END IF;
  IF (l_xcav_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.last_updated_by := NULL;
  END IF;
  IF (l_xcav_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
    l_xcav_rec.last_update_date := NULL;
  END IF;
  IF (l_xcav_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
    l_xcav_rec.last_update_login := NULL;
  END IF;
  RETURN(l_xcav_rec);
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

PROCEDURE validate_id(p_xcav_rec 		IN 	xcav_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_xcav_rec.id IS NULL) OR (p_xcav_rec.id = Okl_Api.G_MISS_NUM) THEN
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

  PROCEDURE validate_org_id (p_xcav_rec IN xcav_rec_type,

  			                 x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      x_return_status := Okl_Util.check_org_id(p_xcav_rec.org_id);

  END validate_org_id;

-- Start of comments
-- Procedure Name  : validate_lsm_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_lsm_id(p_xcav_rec 		IN 	xcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_lsm_id_csr IS
   SELECT '1'
   FROM   okl_cnsld_ar_strms_b
   WHERE  id = p_xcav_rec.lsm_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_xcav_rec.lsm_id IS NOT NULL THEN

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_lsm_id_csr;
   FETCH l_lsm_id_csr INTO l_dummy_var;
   CLOSE l_lsm_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
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

-- Start of comments
-- Procedure Name  : validate_rca_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_rca_id(p_xcav_rec 		IN 	xcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_rca_id_csr IS
   SELECT '1'
   FROM   okl_txl_rcpt_apps_b
   WHERE  id = p_xcav_rec.rca_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;

 IF p_xcav_rec.rca_id IS NOT NULL THEN

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_rca_id_csr;
   FETCH l_rca_id_csr INTO l_dummy_var;
   CLOSE l_rca_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RCA_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_TXL_RCPT_APPS_B');
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

END validate_rca_id;

-- Start of comments
-- Procedure Name  : validate_xcr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_xcr_id(p_xcav_rec 		IN 	xcav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_xcr_id_csr IS
   SELECT '1'
   FROM   okl_ext_csh_rcpts_b
   WHERE  id = p_xcav_rec.xcr_id_details;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
  --check not null
  IF (p_xcav_rec.xcr_id_details IS NULL) OR (p_xcav_rec.xcr_id_details = Okl_Api.G_MISS_NUM) THEN
    x_return_status:=Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'XCR_ID_DETAILS');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_xcr_id_csr;
   FETCH l_xcr_id_csr INTO l_dummy_var;
   CLOSE l_xcr_id_csr;
   IF (l_dummy_var<>'1') THEN
	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'XCR_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_EXT_CSH_RCPTS_B');
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

END validate_xcr_id;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/17/2001
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- PROCEDURE Validate_Attributes
---------------------------------------------------------------------------
------------------------------------------------
-- Validate_Attributes for:OKL_XTL_CSH_APPS_V --
------------------------------------------------
FUNCTION Validate_Attributes (
  p_xcav_rec IN  xcav_rec_type
) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     -- Added 04/16/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/17/2001 Bruno Vaghela ---

   validate_id(p_xcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


	validate_org_id(p_xcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


    validate_lsm_id(p_xcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_rca_id(p_xcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_xcr_id(p_xcav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

-- end 04/17/2001 Bruno Vaghela ---

  IF p_xcav_rec.id = Okl_Api.G_MISS_NUM OR
     p_xcav_rec.id IS NULL
  THEN
    Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
    l_return_status := Okl_Api.G_RET_STS_ERROR;
  ELSIF p_xcav_rec.object_version_number = Okl_Api.G_MISS_NUM OR
        p_xcav_rec.object_version_number IS NULL
  THEN
    Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
    l_return_status := Okl_Api.G_RET_STS_ERROR;
  ELSIF p_xcav_rec.xcr_id_details = Okl_Api.G_MISS_NUM OR
        p_xcav_rec.xcr_id_details IS NULL
  THEN
    Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'xcr_id_details');
    l_return_status := Okl_Api.G_RET_STS_ERROR;
  END IF;
  RETURN(l_return_status);
END Validate_Attributes;

---------------------------------------------------------------------------
-- PROCEDURE Validate_Record
---------------------------------------------------------------------------
--------------------------------------------
-- Validate_Record for:OKL_XTL_CSH_APPS_V --
--------------------------------------------
FUNCTION Validate_Record (
  p_xcav_rec IN xcav_rec_type
) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
  RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------
-- PROCEDURE Migrate
---------------------------------------------------------------------------
PROCEDURE migrate (
  p_from	IN xcav_rec_type,
  p_to	IN OUT NOCOPY xca_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.xcr_id_details := p_from.xcr_id_details;
  p_to.irp_id := p_from.irp_id;
  p_to.lsm_id := p_from.lsm_id;
  p_to.rca_id := p_from.rca_id;
  p_to.cat_id := p_from.cat_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.invoice_number := p_from.invoice_number;
  p_to.amount_applied := p_from.amount_applied;
  p_to.invoice_installment := p_from.invoice_installment;
  p_to.amount_applied_from := p_from.amount_applied_from;
  p_to.invoice_currency_code := p_from.invoice_currency_code;
  p_to.TRANS_TO_RECEIPT_RATE := p_from.TRANS_TO_RECEIPT_RATE;
  p_to.TRX_DATE := p_from.TRX_DATE;
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
  p_from	IN xca_rec_type,
  p_to	IN OUT NOCOPY xcav_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.xcr_id_details := p_from.xcr_id_details;
  p_to.irp_id := p_from.irp_id;
  p_to.lsm_id := p_from.lsm_id;
  p_to.rca_id := p_from.rca_id;
  p_to.cat_id := p_from.cat_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.invoice_number := p_from.invoice_number;
  p_to.amount_applied := p_from.amount_applied;
  p_to.invoice_installment := p_from.invoice_installment;
  p_to.amount_applied_from := p_from.amount_applied_from;
  p_to.invoice_currency_code := p_from.invoice_currency_code;
  p_to.TRANS_TO_RECEIPT_RATE := p_from.TRANS_TO_RECEIPT_RATE;
  p_to.TRX_DATE := p_from.TRX_DATE;
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
  p_from	IN xcav_rec_type,
  p_to	IN OUT NOCOPY okl_xtl_csh_apps_tl_rec_type
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
  p_from	IN okl_xtl_csh_apps_tl_rec_type,
  p_to	IN OUT NOCOPY xcav_rec_type
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
-----------------------------------------
-- validate_row for:OKL_XTL_CSH_APPS_V --
-----------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_rec                     IN xcav_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xcav_rec                     xcav_rec_type := p_xcav_rec;
  l_xca_rec                      xca_rec_type;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
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
  l_return_status := Validate_Attributes(l_xcav_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_xcav_rec);
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
-- PL/SQL TBL validate_row for:XCAV_TBL --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_tbl                     IN xcav_tbl_type) IS

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
  IF (p_xcav_tbl.COUNT > 0) THEN
    i := p_xcav_tbl.FIRST;
    LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xcav_rec                     => p_xcav_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_xcav_tbl.LAST);
      i := p_xcav_tbl.NEXT(i);
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
---------------------------------------
-- insert_row for:OKL_XTL_CSH_APPS_B --
---------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xca_rec                      IN xca_rec_type,
  x_xca_rec                      OUT NOCOPY xca_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xca_rec                      xca_rec_type := p_xca_rec;
  l_def_xca_rec                  xca_rec_type;
  -------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_B --
  -------------------------------------------
  FUNCTION Set_Attributes (
    p_xca_rec IN  xca_rec_type,
    x_xca_rec OUT NOCOPY xca_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xca_rec := p_xca_rec;
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
    p_xca_rec,                         -- IN
    l_xca_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  INSERT INTO OKL_XTL_CSH_APPS_B(
      id,
      xcr_id_details,
      irp_id,
      lsm_id,
      rca_id,
      cat_id,
      object_version_number,
      invoice_number,
      amount_applied,
      invoice_installment,
      amount_applied_from,
      invoice_currency_code,
      trans_to_receipt_rate,
      trx_date,
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
      l_xca_rec.id,
      l_xca_rec.xcr_id_details,
      l_xca_rec.irp_id,
      l_xca_rec.lsm_id,
      l_xca_rec.rca_id,
      l_xca_rec.cat_id,
      l_xca_rec.object_version_number,
      l_xca_rec.invoice_number,
      l_xca_rec.amount_applied,
      l_xca_rec.invoice_installment,
      l_xca_rec.amount_applied_from,
      l_xca_rec.invoice_currency_code,
      l_xca_rec.TRANS_TO_RECEIPT_RATE,
      l_xca_rec.TRX_DATE,
      l_xca_rec.request_id,
      l_xca_rec.program_application_id,
      l_xca_rec.program_id,
      l_xca_rec.program_update_date,
      l_xca_rec.org_id,
      l_xca_rec.attribute_category,
      l_xca_rec.attribute1,
      l_xca_rec.attribute2,
      l_xca_rec.attribute3,
      l_xca_rec.attribute4,
      l_xca_rec.attribute5,
      l_xca_rec.attribute6,
      l_xca_rec.attribute7,
      l_xca_rec.attribute8,
      l_xca_rec.attribute9,
      l_xca_rec.attribute10,
      l_xca_rec.attribute11,
      l_xca_rec.attribute12,
      l_xca_rec.attribute13,
      l_xca_rec.attribute14,
      l_xca_rec.attribute15,
      l_xca_rec.created_by,
      l_xca_rec.creation_date,
      l_xca_rec.last_updated_by,
      l_xca_rec.last_update_date,
      l_xca_rec.last_update_login);
  -- Set OUT values
  x_xca_rec := l_xca_rec;
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
-- insert_row for:OKL_XTL_CSH_APPS_TL --
----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type,
  x_okl_xtl_csh_apps_tl_rec      OUT NOCOPY okl_xtl_csh_apps_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type := p_okl_xtl_csh_apps_tl_rec;
  ldefoklxtlcshappstlrec         okl_xtl_csh_apps_tl_rec_type;
  CURSOR get_languages IS
    SELECT *
      FROM FND_LANGUAGES
     WHERE INSTALLED_FLAG IN ('I', 'B');
  --------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_TL --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtl_csh_apps_tl_rec IN  okl_xtl_csh_apps_tl_rec_type,
    x_okl_xtl_csh_apps_tl_rec OUT NOCOPY okl_xtl_csh_apps_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtl_csh_apps_tl_rec := p_okl_xtl_csh_apps_tl_rec;
    x_okl_xtl_csh_apps_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_xtl_csh_apps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_xtl_csh_apps_tl_rec,         -- IN
    l_okl_xtl_csh_apps_tl_rec);        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  FOR l_lang_rec IN get_languages LOOP
    l_okl_xtl_csh_apps_tl_rec.LANGUAGE := l_lang_rec.language_code;
    INSERT INTO OKL_XTL_CSH_APPS_TL(
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
        l_okl_xtl_csh_apps_tl_rec.id,
        l_okl_xtl_csh_apps_tl_rec.LANGUAGE,
        l_okl_xtl_csh_apps_tl_rec.source_lang,
        l_okl_xtl_csh_apps_tl_rec.sfwt_flag,
        l_okl_xtl_csh_apps_tl_rec.created_by,
        l_okl_xtl_csh_apps_tl_rec.creation_date,
        l_okl_xtl_csh_apps_tl_rec.last_updated_by,
        l_okl_xtl_csh_apps_tl_rec.last_update_date,
        l_okl_xtl_csh_apps_tl_rec.last_update_login);
  END LOOP;
  -- Set OUT values
  x_okl_xtl_csh_apps_tl_rec := l_okl_xtl_csh_apps_tl_rec;
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
---------------------------------------
-- insert_row for:OKL_XTL_CSH_APPS_V --
---------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_rec                     IN xcav_rec_type,
  x_xcav_rec                     OUT NOCOPY xcav_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xcav_rec                     xcav_rec_type;
  l_def_xcav_rec                 xcav_rec_type;
  l_xca_rec                      xca_rec_type;
  lx_xca_rec                     xca_rec_type;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
  lx_okl_xtl_csh_apps_tl_rec     okl_xtl_csh_apps_tl_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_xcav_rec	IN xcav_rec_type
  ) RETURN xcav_rec_type IS
    l_xcav_rec	xcav_rec_type := p_xcav_rec;
  BEGIN
    l_xcav_rec.CREATION_DATE := SYSDATE;
    l_xcav_rec.CREATED_BY := Fnd_Global.USER_ID;
    l_xcav_rec.LAST_UPDATE_DATE := l_xcav_rec.CREATION_DATE;
    l_xcav_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_xcav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_xcav_rec);
  END fill_who_columns;
  -------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_V --
  -------------------------------------------
  FUNCTION Set_Attributes (
    p_xcav_rec IN  xcav_rec_type,
    x_xcav_rec OUT NOCOPY xcav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xcav_rec := p_xcav_rec;
    x_xcav_rec.OBJECT_VERSION_NUMBER := 1;
    x_xcav_rec.SFWT_FLAG := 'N';
    RETURN(l_return_status);

	-- POST TAPI GENERATED CODE BEGINS  04/25/2001  Bruno.

	  IF (x_xcav_rec.request_id IS NULL OR x_xcav_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	     SELECT DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
    	 		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.PROG_APPL_ID),
				DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
     			DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
   		 INTO
       	 	 	x_xcav_rec.request_id,
                x_xcav_rec.program_application_id,
                x_xcav_rec.program_id,
                x_xcav_rec.program_update_date
   		 FROM dual;
 	  END IF;

   -- POST TAPI GENERATED CODE ENDS  04/25/2001  Bruno.

  END Set_Attributes;
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

  l_xcav_rec := null_out_defaults(p_xcav_rec);
  -- Set primary key value
  l_xcav_rec.ID := get_seq_id;
  --- Setting item attributes
  l_return_status := Set_Attributes(
    l_xcav_rec,                        -- IN
    l_def_xcav_rec);                   -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_xcav_rec := fill_who_columns(l_def_xcav_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_xcav_rec); -- causing probs.
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_xcav_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_xcav_rec, l_xca_rec);
  migrate(l_def_xcav_rec, l_okl_xtl_csh_apps_tl_rec);
  --------------------------------------------
  -- Call the INSERT_ROW for each child record
  --------------------------------------------
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xca_rec,
    lx_xca_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_xca_rec, l_def_xcav_rec);
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtl_csh_apps_tl_rec,
    lx_okl_xtl_csh_apps_tl_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_xtl_csh_apps_tl_rec, l_def_xcav_rec);
  -- Set OUT values
  x_xcav_rec := l_def_xcav_rec;
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
-- PL/SQL TBL insert_row for:XCAV_TBL --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_tbl                     IN xcav_tbl_type,
  x_xcav_tbl                     OUT NOCOPY xcav_tbl_type) IS

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
  IF (p_xcav_tbl.COUNT > 0) THEN
    i := p_xcav_tbl.FIRST;
    LOOP
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xcav_rec                     => p_xcav_tbl(i),
        x_xcav_rec                     => x_xcav_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_xcav_tbl.LAST);
      i := p_xcav_tbl.NEXT(i);
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
-------------------------------------
-- lock_row for:OKL_XTL_CSH_APPS_B --
-------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xca_rec                      IN xca_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_xca_rec IN xca_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_XTL_CSH_APPS_B
   WHERE ID = p_xca_rec.id
     AND OBJECT_VERSION_NUMBER = p_xca_rec.object_version_number
  FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR  lchk_csr (p_xca_rec IN xca_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_XTL_CSH_APPS_B
  WHERE ID = p_xca_rec.id;
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_object_version_number       OKL_XTL_CSH_APPS_B.OBJECT_VERSION_NUMBER%TYPE;
  lc_object_version_number      OKL_XTL_CSH_APPS_B.OBJECT_VERSION_NUMBER%TYPE;
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
    OPEN lock_csr(p_xca_rec);
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
    OPEN lchk_csr(p_xca_rec);
    FETCH lchk_csr INTO lc_object_version_number;
    lc_row_notfound := lchk_csr%NOTFOUND;
    CLOSE lchk_csr;
  END IF;
  IF (lc_row_notfound) THEN
    Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number > p_xca_rec.object_version_number THEN
    Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number <> p_xca_rec.object_version_number THEN
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
--------------------------------------
-- lock_row for:OKL_XTL_CSH_APPS_TL --
--------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_okl_xtl_csh_apps_tl_rec IN okl_xtl_csh_apps_tl_rec_type) IS
  SELECT *
    FROM OKL_XTL_CSH_APPS_TL
   WHERE ID = p_okl_xtl_csh_apps_tl_rec.id
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
    OPEN lock_csr(p_okl_xtl_csh_apps_tl_rec);
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
-------------------------------------
-- lock_row for:OKL_XTL_CSH_APPS_V --
-------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_rec                     IN xcav_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xca_rec                      xca_rec_type;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
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
  migrate(p_xcav_rec, l_xca_rec);
  migrate(p_xcav_rec, l_okl_xtl_csh_apps_tl_rec);
  --------------------------------------------
  -- Call the LOCK_ROW for each child record
  --------------------------------------------
  lock_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xca_rec
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
    l_okl_xtl_csh_apps_tl_rec
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
-- PL/SQL TBL lock_row for:XCAV_TBL --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_tbl                     IN xcav_tbl_type) IS

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
  IF (p_xcav_tbl.COUNT > 0) THEN
    i := p_xcav_tbl.FIRST;
    LOOP
      lock_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xcav_rec                     => p_xcav_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_xcav_tbl.LAST);
      i := p_xcav_tbl.NEXT(i);
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
---------------------------------------
-- update_row for:OKL_XTL_CSH_APPS_B --
---------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xca_rec                      IN xca_rec_type,
  x_xca_rec                      OUT NOCOPY xca_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xca_rec                      xca_rec_type := p_xca_rec;
  l_def_xca_rec                  xca_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_xca_rec	IN xca_rec_type,
    x_xca_rec	OUT NOCOPY xca_rec_type
  ) RETURN VARCHAR2 IS
    l_xca_rec                      xca_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xca_rec := p_xca_rec;
    -- Get current database values
    l_xca_rec := get_rec(p_xca_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_xca_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.id := l_xca_rec.id;
    END IF;
    IF (x_xca_rec.xcr_id_details = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.xcr_id_details := l_xca_rec.xcr_id_details;
    END IF;
    IF (x_xca_rec.irp_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.irp_id := l_xca_rec.irp_id;
    END IF;
    IF (x_xca_rec.lsm_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.lsm_id := l_xca_rec.lsm_id;
    END IF;
    IF (x_xca_rec.rca_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.rca_id := l_xca_rec.rca_id;
    END IF;
    IF (x_xca_rec.cat_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.cat_id := l_xca_rec.cat_id;
    END IF;
    IF (x_xca_rec.object_version_number = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.object_version_number := l_xca_rec.object_version_number;
    END IF;
    IF (x_xca_rec.invoice_number = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.invoice_number := l_xca_rec.invoice_number;
    END IF;
    IF (x_xca_rec.amount_applied = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.amount_applied := l_xca_rec.amount_applied;
    END IF;
    IF (x_xca_rec.invoice_installment = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.invoice_installment := l_xca_rec.invoice_installment;
    END IF;
    IF (x_xca_rec.amount_applied_from = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.amount_applied_from := l_xca_rec.amount_applied_from;
    END IF;
    IF (x_xca_rec.invoice_currency_code = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.invoice_currency_code := l_xca_rec.invoice_currency_code;
    END IF;
    IF (x_xca_rec.TRANS_TO_RECEIPT_RATE = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.TRANS_TO_RECEIPT_RATE := l_xca_rec.TRANS_TO_RECEIPT_RATE;
    END IF;
    IF (x_xca_rec.TRX_DATE = Okl_Api.G_MISS_DATE)
    THEN
      x_xca_rec.TRX_DATE := l_xca_rec.TRX_DATE;
    END IF;
    IF (x_xca_rec.request_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.request_id := l_xca_rec.request_id;
    END IF;
    IF (x_xca_rec.program_application_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.program_application_id := l_xca_rec.program_application_id;
    END IF;
    IF (x_xca_rec.program_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.program_id := l_xca_rec.program_id;
    END IF;
    IF (x_xca_rec.program_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xca_rec.program_update_date := l_xca_rec.program_update_date;
    END IF;
    IF (x_xca_rec.org_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.org_id := l_xca_rec.org_id;
    END IF;
    IF (x_xca_rec.attribute_category = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute_category := l_xca_rec.attribute_category;
    END IF;
    IF (x_xca_rec.attribute1 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute1 := l_xca_rec.attribute1;
    END IF;
    IF (x_xca_rec.attribute2 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute2 := l_xca_rec.attribute2;
    END IF;
    IF (x_xca_rec.attribute3 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute3 := l_xca_rec.attribute3;
    END IF;
    IF (x_xca_rec.attribute4 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute4 := l_xca_rec.attribute4;
    END IF;
    IF (x_xca_rec.attribute5 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute5 := l_xca_rec.attribute5;
    END IF;
    IF (x_xca_rec.attribute6 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute6 := l_xca_rec.attribute6;
    END IF;
    IF (x_xca_rec.attribute7 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute7 := l_xca_rec.attribute7;
    END IF;
    IF (x_xca_rec.attribute8 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute8 := l_xca_rec.attribute8;
    END IF;
    IF (x_xca_rec.attribute9 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute9 := l_xca_rec.attribute9;
    END IF;
    IF (x_xca_rec.attribute10 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute10 := l_xca_rec.attribute10;
    END IF;
    IF (x_xca_rec.attribute11 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute11 := l_xca_rec.attribute11;
    END IF;
    IF (x_xca_rec.attribute12 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute12 := l_xca_rec.attribute12;
    END IF;
    IF (x_xca_rec.attribute13 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute13 := l_xca_rec.attribute13;
    END IF;
    IF (x_xca_rec.attribute14 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute14 := l_xca_rec.attribute14;
    END IF;
    IF (x_xca_rec.attribute15 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xca_rec.attribute15 := l_xca_rec.attribute15;
    END IF;
    IF (x_xca_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.created_by := l_xca_rec.created_by;
    END IF;
    IF (x_xca_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xca_rec.creation_date := l_xca_rec.creation_date;
    END IF;
    IF (x_xca_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.last_updated_by := l_xca_rec.last_updated_by;
    END IF;
    IF (x_xca_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xca_rec.last_update_date := l_xca_rec.last_update_date;
    END IF;
    IF (x_xca_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_xca_rec.last_update_login := l_xca_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  -------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_B --
  -------------------------------------------
  FUNCTION Set_Attributes (
    p_xca_rec IN  xca_rec_type,
    x_xca_rec OUT NOCOPY xca_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xca_rec := p_xca_rec;
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
    p_xca_rec,                         -- IN
    l_xca_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_xca_rec, l_def_xca_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_XTL_CSH_APPS_B
  SET XCR_ID_DETAILS = l_def_xca_rec.xcr_id_details,
      IRP_ID = l_def_xca_rec.irp_id,
      LSM_ID = l_def_xca_rec.lsm_id,
      RCA_ID = l_def_xca_rec.rca_id,
      CAT_ID = l_def_xca_rec.cat_id,
      OBJECT_VERSION_NUMBER = l_def_xca_rec.object_version_number,
      INVOICE_NUMBER = l_def_xca_rec.invoice_number,
      AMOUNT_APPLIED = l_def_xca_rec.amount_applied,
      INVOICE_INSTALLMENT = l_def_xca_rec.invoice_installment,
      AMOUNT_APPLIED_FROM = l_def_xca_rec.amount_applied_from,
      INVOICE_CURRENCY_CODE = l_def_xca_rec.invoice_currency_code,
      TRANS_TO_RECEIPT_RATE = l_def_xca_rec.TRANS_TO_RECEIPT_RATE,
      TRX_DATE = l_def_xca_rec.TRX_DATE,
      REQUEST_ID = l_def_xca_rec.request_id,
      PROGRAM_APPLICATION_ID = l_def_xca_rec.program_application_id,
      PROGRAM_ID = l_def_xca_rec.program_id,
      PROGRAM_UPDATE_DATE = l_def_xca_rec.program_update_date,
      ORG_ID = l_def_xca_rec.org_id,
      ATTRIBUTE_CATEGORY = l_def_xca_rec.attribute_category,
      ATTRIBUTE1 = l_def_xca_rec.attribute1,
      ATTRIBUTE2 = l_def_xca_rec.attribute2,
      ATTRIBUTE3 = l_def_xca_rec.attribute3,
      ATTRIBUTE4 = l_def_xca_rec.attribute4,
      ATTRIBUTE5 = l_def_xca_rec.attribute5,
      ATTRIBUTE6 = l_def_xca_rec.attribute6,
      ATTRIBUTE7 = l_def_xca_rec.attribute7,
      ATTRIBUTE8 = l_def_xca_rec.attribute8,
      ATTRIBUTE9 = l_def_xca_rec.attribute9,
      ATTRIBUTE10 = l_def_xca_rec.attribute10,
      ATTRIBUTE11 = l_def_xca_rec.attribute11,
      ATTRIBUTE12 = l_def_xca_rec.attribute12,
      ATTRIBUTE13 = l_def_xca_rec.attribute13,
      ATTRIBUTE14 = l_def_xca_rec.attribute14,
      ATTRIBUTE15 = l_def_xca_rec.attribute15,
      CREATED_BY = l_def_xca_rec.created_by,
      CREATION_DATE = l_def_xca_rec.creation_date,
      LAST_UPDATED_BY = l_def_xca_rec.last_updated_by,
      LAST_UPDATE_DATE = l_def_xca_rec.last_update_date,
      LAST_UPDATE_LOGIN = l_def_xca_rec.last_update_login
  WHERE ID = l_def_xca_rec.id;

  x_xca_rec := l_def_xca_rec;
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
-- update_row for:OKL_XTL_CSH_APPS_TL --
----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type,
  x_okl_xtl_csh_apps_tl_rec      OUT NOCOPY okl_xtl_csh_apps_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type := p_okl_xtl_csh_apps_tl_rec;
  ldefoklxtlcshappstlrec         okl_xtl_csh_apps_tl_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_okl_xtl_csh_apps_tl_rec	IN okl_xtl_csh_apps_tl_rec_type,
    x_okl_xtl_csh_apps_tl_rec	OUT NOCOPY okl_xtl_csh_apps_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtl_csh_apps_tl_rec := p_okl_xtl_csh_apps_tl_rec;
    -- Get current database values
    l_okl_xtl_csh_apps_tl_rec := get_rec(p_okl_xtl_csh_apps_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtl_csh_apps_tl_rec.id := l_okl_xtl_csh_apps_tl_rec.id;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtl_csh_apps_tl_rec.LANGUAGE := l_okl_xtl_csh_apps_tl_rec.LANGUAGE;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtl_csh_apps_tl_rec.source_lang := l_okl_xtl_csh_apps_tl_rec.source_lang;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
    THEN
      x_okl_xtl_csh_apps_tl_rec.sfwt_flag := l_okl_xtl_csh_apps_tl_rec.sfwt_flag;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtl_csh_apps_tl_rec.created_by := l_okl_xtl_csh_apps_tl_rec.created_by;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_okl_xtl_csh_apps_tl_rec.creation_date := l_okl_xtl_csh_apps_tl_rec.creation_date;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtl_csh_apps_tl_rec.last_updated_by := l_okl_xtl_csh_apps_tl_rec.last_updated_by;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_okl_xtl_csh_apps_tl_rec.last_update_date := l_okl_xtl_csh_apps_tl_rec.last_update_date;
    END IF;
    IF (x_okl_xtl_csh_apps_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_okl_xtl_csh_apps_tl_rec.last_update_login := l_okl_xtl_csh_apps_tl_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_TL --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtl_csh_apps_tl_rec IN  okl_xtl_csh_apps_tl_rec_type,
    x_okl_xtl_csh_apps_tl_rec OUT NOCOPY okl_xtl_csh_apps_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtl_csh_apps_tl_rec := p_okl_xtl_csh_apps_tl_rec;
    x_okl_xtl_csh_apps_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_xtl_csh_apps_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_xtl_csh_apps_tl_rec,         -- IN
    l_okl_xtl_csh_apps_tl_rec);        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_okl_xtl_csh_apps_tl_rec, ldefoklxtlcshappstlrec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_XTL_CSH_APPS_TL
  SET SOURCE_LANG = ldefoklxtlcshappstlrec.source_lang,
      CREATED_BY = ldefoklxtlcshappstlrec.created_by,
      CREATION_DATE = ldefoklxtlcshappstlrec.creation_date,
      LAST_UPDATED_BY = ldefoklxtlcshappstlrec.last_updated_by,
      LAST_UPDATE_DATE = ldefoklxtlcshappstlrec.last_update_date,
      LAST_UPDATE_LOGIN = ldefoklxtlcshappstlrec.last_update_login
  WHERE ID = ldefoklxtlcshappstlrec.id
  AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

  UPDATE  OKL_XTL_CSH_APPS_TL
  SET SFWT_FLAG = 'Y'
  WHERE ID = ldefoklxtlcshappstlrec.id
    AND SOURCE_LANG <> USERENV('LANG');

  x_okl_xtl_csh_apps_tl_rec := ldefoklxtlcshappstlrec;
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
---------------------------------------
-- update_row for:OKL_XTL_CSH_APPS_V --
---------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_rec                     IN xcav_rec_type,
  x_xcav_rec                     OUT NOCOPY xcav_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xcav_rec                     xcav_rec_type := p_xcav_rec;
  l_def_xcav_rec                 xcav_rec_type;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
  lx_okl_xtl_csh_apps_tl_rec     okl_xtl_csh_apps_tl_rec_type;
  l_xca_rec                      xca_rec_type;
  lx_xca_rec                     xca_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_xcav_rec	IN xcav_rec_type
  ) RETURN xcav_rec_type IS
    l_xcav_rec	xcav_rec_type := p_xcav_rec;
  BEGIN
    l_xcav_rec.LAST_UPDATE_DATE := SYSDATE;
    l_xcav_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
    l_xcav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
    RETURN(l_xcav_rec);
  END fill_who_columns;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_xcav_rec	IN xcav_rec_type,
    x_xcav_rec	OUT NOCOPY xcav_rec_type
  ) RETURN VARCHAR2 IS
    l_xcav_rec                     xcav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xcav_rec := p_xcav_rec;
    -- Get current database values
    l_xcav_rec := get_rec(p_xcav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_xcav_rec.id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.id := l_xcav_rec.id;
    END IF;
    IF (x_xcav_rec.object_version_number = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.object_version_number := l_xcav_rec.object_version_number;
    END IF;
    IF (x_xcav_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.sfwt_flag := l_xcav_rec.sfwt_flag;
    END IF;
    IF (x_xcav_rec.lsm_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.lsm_id := l_xcav_rec.lsm_id;
    END IF;
    IF (x_xcav_rec.rca_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.rca_id := l_xcav_rec.rca_id;
    END IF;
    IF (x_xcav_rec.cat_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.cat_id := l_xcav_rec.cat_id;
    END IF;
    IF (x_xcav_rec.irp_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.irp_id := l_xcav_rec.irp_id;
    END IF;
    IF (x_xcav_rec.xcr_id_details = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.xcr_id_details := l_xcav_rec.xcr_id_details;
    END IF;
    IF (x_xcav_rec.invoice_number = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.invoice_number := l_xcav_rec.invoice_number;
    END IF;
    IF (x_xcav_rec.amount_applied = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.amount_applied := l_xcav_rec.amount_applied;
    END IF;
    IF (x_xcav_rec.invoice_installment = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.invoice_installment := l_xcav_rec.invoice_installment;
    END IF;
    IF (x_xcav_rec.amount_applied_from = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.amount_applied_from := l_xcav_rec.amount_applied_from;
    END IF;
    IF (x_xcav_rec.invoice_currency_code = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.invoice_currency_code := l_xcav_rec.invoice_currency_code;
    END IF;
    IF (x_xcav_rec.TRANS_TO_RECEIPT_RATE = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.TRANS_TO_RECEIPT_RATE := l_xcav_rec.TRANS_TO_RECEIPT_RATE;
    END IF;
    IF (x_xcav_rec.TRX_DATE = Okl_Api.G_MISS_DATE)
    THEN
      x_xcav_rec.TRX_DATE := l_xcav_rec.TRX_DATE;
    END IF;
    IF (x_xcav_rec.attribute_category = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute_category := l_xcav_rec.attribute_category;
    END IF;
    IF (x_xcav_rec.attribute1 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute1 := l_xcav_rec.attribute1;
    END IF;
    IF (x_xcav_rec.attribute2 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute2 := l_xcav_rec.attribute2;
    END IF;
    IF (x_xcav_rec.attribute3 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute3 := l_xcav_rec.attribute3;
    END IF;
    IF (x_xcav_rec.attribute4 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute4 := l_xcav_rec.attribute4;
    END IF;
    IF (x_xcav_rec.attribute5 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute5 := l_xcav_rec.attribute5;
    END IF;
    IF (x_xcav_rec.attribute6 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute6 := l_xcav_rec.attribute6;
    END IF;
    IF (x_xcav_rec.attribute7 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute7 := l_xcav_rec.attribute7;
    END IF;
    IF (x_xcav_rec.attribute8 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute8 := l_xcav_rec.attribute8;
    END IF;
    IF (x_xcav_rec.attribute9 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute9 := l_xcav_rec.attribute9;
    END IF;
    IF (x_xcav_rec.attribute10 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute10 := l_xcav_rec.attribute10;
    END IF;
    IF (x_xcav_rec.attribute11 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute11 := l_xcav_rec.attribute11;
    END IF;
    IF (x_xcav_rec.attribute12 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute12 := l_xcav_rec.attribute12;
    END IF;
    IF (x_xcav_rec.attribute13 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute13 := l_xcav_rec.attribute13;
    END IF;
    IF (x_xcav_rec.attribute14 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute14 := l_xcav_rec.attribute14;
    END IF;
    IF (x_xcav_rec.attribute15 = Okl_Api.G_MISS_CHAR)
    THEN
      x_xcav_rec.attribute15 := l_xcav_rec.attribute15;
    END IF;
    IF (x_xcav_rec.request_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.request_id := l_xcav_rec.request_id;
    END IF;
    IF (x_xcav_rec.program_application_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.program_application_id := l_xcav_rec.program_application_id;
    END IF;
    IF (x_xcav_rec.program_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.program_id := l_xcav_rec.program_id;
    END IF;
    IF (x_xcav_rec.program_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xcav_rec.program_update_date := l_xcav_rec.program_update_date;
    END IF;
    IF (x_xcav_rec.org_id = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.org_id := l_xcav_rec.org_id;
    END IF;
    IF (x_xcav_rec.created_by = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.created_by := l_xcav_rec.created_by;
    END IF;
    IF (x_xcav_rec.creation_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xcav_rec.creation_date := l_xcav_rec.creation_date;
    END IF;
    IF (x_xcav_rec.last_updated_by = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.last_updated_by := l_xcav_rec.last_updated_by;
    END IF;
    IF (x_xcav_rec.last_update_date = Okl_Api.G_MISS_DATE)
    THEN
      x_xcav_rec.last_update_date := l_xcav_rec.last_update_date;
    END IF;
    IF (x_xcav_rec.last_update_login = Okl_Api.G_MISS_NUM)
    THEN
      x_xcav_rec.last_update_login := l_xcav_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  -------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_V --
  -------------------------------------------
  FUNCTION Set_Attributes (
    p_xcav_rec IN  xcav_rec_type,
    x_xcav_rec OUT NOCOPY xcav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_xcav_rec := p_xcav_rec;
    x_xcav_rec.OBJECT_VERSION_NUMBER := NVL(x_xcav_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);

	-- POST TAPI GENERATED CODE BEGINS  04/25/2001  Bruno.

	  SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xcav_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xcav_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xcav_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xcav_rec.program_update_date,SYSDATE)
      INTO
        x_xcav_rec.request_id,
        x_xcav_rec.program_application_id,
        x_xcav_rec.program_id,
        x_xcav_rec.program_update_date
      FROM   dual;

   -- POST TAPI GENERATED CODE ENDS  04/25/2001  Bruno.

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
    p_xcav_rec,                        -- IN
    l_xcav_rec);                       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_xcav_rec, l_def_xcav_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_def_xcav_rec := fill_who_columns(l_def_xcav_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_xcav_rec);
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_xcav_rec);
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_xcav_rec, l_okl_xtl_csh_apps_tl_rec);
  migrate(l_def_xcav_rec, l_xca_rec);
  --------------------------------------------
  -- Call the UPDATE_ROW for each child record
  --------------------------------------------
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtl_csh_apps_tl_rec,
    lx_okl_xtl_csh_apps_tl_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_xtl_csh_apps_tl_rec, l_def_xcav_rec);
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xca_rec,
    lx_xca_rec
  );
  IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_xca_rec, l_def_xcav_rec);
  x_xcav_rec := l_def_xcav_rec;
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
-- PL/SQL TBL update_row for:XCAV_TBL --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_tbl                     IN xcav_tbl_type,
  x_xcav_tbl                     OUT NOCOPY xcav_tbl_type) IS

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
  IF (p_xcav_tbl.COUNT > 0) THEN
    i := p_xcav_tbl.FIRST;
    LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xcav_rec                     => p_xcav_tbl(i),
        x_xcav_rec                     => x_xcav_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_xcav_tbl.LAST);
      i := p_xcav_tbl.NEXT(i);
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
---------------------------------------
-- delete_row for:OKL_XTL_CSH_APPS_B --
---------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xca_rec                      IN xca_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xca_rec                      xca_rec_type:= p_xca_rec;
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
  DELETE FROM OKL_XTL_CSH_APPS_B
   WHERE ID = l_xca_rec.id;

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
-- delete_row for:OKL_XTL_CSH_APPS_TL --
----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_xtl_csh_apps_tl_rec      IN okl_xtl_csh_apps_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type:= p_okl_xtl_csh_apps_tl_rec;
  l_row_notfound                 BOOLEAN := TRUE;
  --------------------------------------------
  -- Set_Attributes for:OKL_XTL_CSH_APPS_TL --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_xtl_csh_apps_tl_rec IN  okl_xtl_csh_apps_tl_rec_type,
    x_okl_xtl_csh_apps_tl_rec OUT NOCOPY okl_xtl_csh_apps_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_xtl_csh_apps_tl_rec := p_okl_xtl_csh_apps_tl_rec;
    x_okl_xtl_csh_apps_tl_rec.LANGUAGE := USERENV('LANG');
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
    p_okl_xtl_csh_apps_tl_rec,         -- IN
    l_okl_xtl_csh_apps_tl_rec);        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;
  DELETE FROM OKL_XTL_CSH_APPS_TL
   WHERE ID = l_okl_xtl_csh_apps_tl_rec.id;

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
---------------------------------------
-- delete_row for:OKL_XTL_CSH_APPS_V --
---------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_rec                     IN xcav_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
  l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_xcav_rec                     xcav_rec_type := p_xcav_rec;
  l_okl_xtl_csh_apps_tl_rec      okl_xtl_csh_apps_tl_rec_type;
  l_xca_rec                      xca_rec_type;
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
  migrate(l_xcav_rec, l_okl_xtl_csh_apps_tl_rec);
  migrate(l_xcav_rec, l_xca_rec);
  --------------------------------------------
  -- Call the DELETE_ROW for each child record
  --------------------------------------------
  delete_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_xtl_csh_apps_tl_rec
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
    l_xca_rec
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
-- PL/SQL TBL delete_row for:XCAV_TBL --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xcav_tbl                     IN xcav_tbl_type) IS

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
  IF (p_xcav_tbl.COUNT > 0) THEN
    i := p_xcav_tbl.FIRST;
    LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okl_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xcav_rec                     => p_xcav_tbl(i));

		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change

      EXIT WHEN (i = p_xcav_tbl.LAST);
      i := p_xcav_tbl.NEXT(i);
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
END Okl_Xca_Pvt;

/
