--------------------------------------------------------
--  DDL for Package Body OKL_TAO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAO_PVT" AS
/* $Header: OKLSTAOB.pls 120.3 2006/07/13 13:05:17 adagur noship $ */

    G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;
    G_ITEM_NOT_FOUND_ERROR		EXCEPTION;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_try_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_try_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_taov_rec IN  taov_rec_type
    ) IS

      CURSOR okl_taov_tryid_pk_csr (p_id IN NUMBER) IS
      SELECT  '1'
      FROM okl_trx_types_b
      WHERE id = p_id;

      l_try_id         		VARCHAR2(1);
      l_row_notfound   		BOOLEAN := TRUE;

    BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_taov_rec.try_id IS NULL) OR (p_taov_rec.try_id = Okc_Api.G_MISS_NUM) THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'TRY_ID');

          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_taov_tryid_pk_csr(p_taov_rec.TRY_ID);
    FETCH okl_taov_tryid_pk_csr INTO l_try_id;
    l_row_notfound := okl_taov_tryid_pk_csr%NOTFOUND;
    CLOSE okl_taov_tryid_pk_csr;
    IF (l_row_notfound) THEN
        Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TRY_ID');
        RAISE g_item_not_found_error;
    END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN g_item_not_found_error THEN
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       WHEN OTHERS THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_try_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_all_ccid
  ---------------------------------------------------------------------------

  PROCEDURE validate_all_ccid(x_return_status OUT NOCOPY VARCHAR2,
      p_taov_rec IN  taov_rec_type
    ) IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

      x_return_Status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_taov_rec.REV_CCID IS NOT NULL) AND (p_taov_rec.REV_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.REV_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REV_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.FREIGHT_CCID IS NOT NULL) AND
         (p_taov_rec.FREIGHT_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.FREIGHT_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FREIGHT_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.REC_CCID IS NOT NULL) AND (p_taov_rec.REC_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.REC_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REC_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.CLEARING_CCID IS NOT NULL) AND
         (p_taov_rec.CLEARING_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.CLEARING_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLEARING_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.TAX_CCID IS NOT NULL) AND
         (p_taov_rec.TAX_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.TAX_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.UNBILLED_CCID IS NOT NULL) AND
         (p_taov_rec.UNBILLED_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.UNBILLED_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'UNBILLED_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (p_taov_rec.UNEARNED_CCID IS NOT NULL) AND
         (p_taov_rec.UNEARNED_CCID <> OKC_API.G_MISS_NUM) THEN
          l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_taov_rec.UNEARNED_CCID);
          IF (l_dummy = OKC_API.G_FALSE) THEN
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'UNEARNED_CCID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      IF (x_return_Status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
  END VALIDATE_ALL_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_post_to_gl_yn
  ---------------------------------------------------------------------------
    PROCEDURE validate_post_to_gl_yn(
      x_return_status OUT NOCOPY VARCHAR2,
      p_taov_rec IN  taov_rec_type
    ) IS

      l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
      l_app_id NUMBER := 0;
      l_view_app_id NUMBER := 0;


    BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_taov_rec.post_to_gl_yn IS NOT NULL) OR
       (p_taov_rec.post_to_gl_yn <> Okc_Api.G_MISS_CHAR) THEN
        l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                     (p_lookup_type => 'YES_NO',
                      p_lookup_code => p_taov_rec.post_to_gl_yn,
                      p_app_id      => l_app_id,
                      p_view_app_id => l_view_app_id);

        IF (l_dummy = OKC_API.G_FALSE) THEN

            Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'POST_TO_GL_YN');
          x_return_status := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         Okc_Api.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_post_to_gl_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_all_ccid

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
  -- FUNCTION get_rec for: OKL_TRX_ACCT_OPTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tao_rec                      IN tao_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tao_rec_type IS
    CURSOR okl_trx_acct_opts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TRY_ID,
            REV_CCID,
            FREIGHT_CCID,
            REC_CCID,
            CLEARING_CCID,
            TAX_CCID,
            UNBILLED_CCID,
            UNEARNED_CCID,
            OBJECT_VERSION_NUMBER,
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
/* Changes made by Kanti on 06.27.2001. This field is present in table but was missing from here */
            POST_TO_GL_YN
/* Changes End  */
      FROM Okl_Trx_Acct_Opts
     WHERE okl_trx_acct_opts.id = p_id;
    l_okl_trx_acct_opts_pk         okl_trx_acct_opts_pk_csr%ROWTYPE;
    l_tao_rec                      tao_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_acct_opts_pk_csr (p_tao_rec.id);
    FETCH okl_trx_acct_opts_pk_csr INTO
              l_tao_rec.ID,
              l_tao_rec.TRY_ID,
              l_tao_rec.REV_CCID,
              l_tao_rec.freight_ccid,
              l_tao_rec.rec_ccid,
              l_tao_rec.clearing_ccid,
              l_tao_rec.tax_ccid,
              l_tao_rec.unbilled_ccid,
              l_tao_rec.unearned_ccid,
              l_tao_rec.OBJECT_VERSION_NUMBER,
              l_tao_rec.ORG_ID,
              l_tao_rec.ATTRIBUTE_CATEGORY,
              l_tao_rec.ATTRIBUTE1,
              l_tao_rec.ATTRIBUTE2,
              l_tao_rec.ATTRIBUTE3,
              l_tao_rec.ATTRIBUTE4,
              l_tao_rec.ATTRIBUTE5,
              l_tao_rec.ATTRIBUTE6,
              l_tao_rec.ATTRIBUTE7,
              l_tao_rec.ATTRIBUTE8,
              l_tao_rec.ATTRIBUTE9,
              l_tao_rec.ATTRIBUTE10,
              l_tao_rec.ATTRIBUTE11,
              l_tao_rec.ATTRIBUTE12,
              l_tao_rec.ATTRIBUTE13,
              l_tao_rec.ATTRIBUTE14,
              l_tao_rec.ATTRIBUTE15,
              l_tao_rec.CREATED_BY,
              l_tao_rec.CREATION_DATE,
              l_tao_rec.LAST_UPDATED_BY,
              l_tao_rec.LAST_UPDATE_DATE,
              l_tao_rec.LAST_UPDATE_LOGIN,
/* Changes made by Kanti on 06.27.2001. This field is present in table but was missing from here */
              l_tao_rec.POST_TO_GL_YN;
/* Changes End */
    x_no_data_found := okl_trx_acct_opts_pk_csr%NOTFOUND;
    CLOSE okl_trx_acct_opts_pk_csr;
    RETURN(l_tao_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tao_rec                      IN tao_rec_type
  ) RETURN tao_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tao_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_ACCT_OPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_taov_rec                     IN taov_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN taov_rec_type IS
    CURSOR okl_taov_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TRY_ID,
             UNEARNED_CCID,
            REV_CCID,
            FREIGHT_CCID,
            REC_CCID,
            CLEARING_CCID,
            TAX_CCID,
            UNBILLED_CCID,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
/* Changes made by Kanti on 06.27.2001. This field is present in table but was missing from here */
            POST_TO_GL_YN
/* Changes End  */
      FROM OKL_TRX_ACCT_OPTS
     WHERE OKL_TRX_ACCT_OPTS.id = p_id;
    l_okl_taov_pk                  okl_taov_pk_csr%ROWTYPE;
    l_taov_rec                     taov_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_taov_pk_csr (p_taov_rec.id);
    FETCH okl_taov_pk_csr INTO
              l_taov_rec.ID,
              l_taov_rec.OBJECT_VERSION_NUMBER,
              l_taov_rec.TRY_ID,
              l_taov_rec.unearned_ccid,
              l_taov_rec.REV_CCID,
              l_taov_rec.freight_ccid,
              l_taov_rec.rec_ccid,
              l_taov_rec.clearing_ccid,
              l_taov_rec.tax_ccid,
              l_taov_rec.unbilled_ccid,
              l_taov_rec.ATTRIBUTE_CATEGORY,
              l_taov_rec.ATTRIBUTE1,
              l_taov_rec.ATTRIBUTE2,
              l_taov_rec.ATTRIBUTE3,
              l_taov_rec.ATTRIBUTE4,
              l_taov_rec.ATTRIBUTE5,
              l_taov_rec.ATTRIBUTE6,
              l_taov_rec.ATTRIBUTE7,
              l_taov_rec.ATTRIBUTE8,
              l_taov_rec.ATTRIBUTE9,
              l_taov_rec.ATTRIBUTE10,
              l_taov_rec.ATTRIBUTE11,
              l_taov_rec.ATTRIBUTE12,
              l_taov_rec.ATTRIBUTE13,
              l_taov_rec.ATTRIBUTE14,
              l_taov_rec.ATTRIBUTE15,
              l_taov_rec.ORG_ID,
              l_taov_rec.CREATED_BY,
              l_taov_rec.CREATION_DATE,
              l_taov_rec.LAST_UPDATED_BY,
              l_taov_rec.LAST_UPDATE_DATE,
              l_taov_rec.LAST_UPDATE_LOGIN,
/* Changes made by Kanti on 06.27.2001. This field is present in table but was missing from here */
              l_taov_rec.POST_TO_GL_YN;
/* Changes End */
    x_no_data_found := okl_taov_pk_csr%NOTFOUND;
    CLOSE okl_taov_pk_csr;
    RETURN(l_taov_rec);
  END get_rec;

  FUNCTION get_rec (
    p_taov_rec                     IN taov_rec_type
  ) RETURN taov_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_taov_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_ACCT_OPTS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_taov_rec	IN taov_rec_type
  ) RETURN taov_rec_type IS
    l_taov_rec	taov_rec_type := p_taov_rec;
  BEGIN
    IF (l_taov_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.object_version_number := NULL;
    END IF;
    IF (l_taov_rec.try_id = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.try_id := NULL;
    END IF;
    IF (l_taov_rec.unearned_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.unearned_ccid := NULL;
    END IF;
    IF (l_taov_rec.REV_CCID = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.REV_CCID := NULL;
    END IF;
    IF (l_taov_rec.freight_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.freight_ccid := NULL;
    END IF;
    IF (l_taov_rec.rec_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.rec_ccid := NULL;
    END IF;
    IF (l_taov_rec.clearing_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.clearing_ccid := NULL;
    END IF;
    IF (l_taov_rec.tax_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.tax_ccid := NULL;
    END IF;
    IF (l_taov_rec.unbilled_ccid = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.unbilled_ccid := NULL;
    END IF;
    IF (l_taov_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute_category := NULL;
    END IF;
    IF (l_taov_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute1 := NULL;
    END IF;
    IF (l_taov_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute2 := NULL;
    END IF;
    IF (l_taov_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute3 := NULL;
    END IF;
    IF (l_taov_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute4 := NULL;
    END IF;
    IF (l_taov_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute5 := NULL;
    END IF;
    IF (l_taov_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute6 := NULL;
    END IF;
    IF (l_taov_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute7 := NULL;
    END IF;
    IF (l_taov_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute8 := NULL;
    END IF;
    IF (l_taov_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute9 := NULL;
    END IF;
    IF (l_taov_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute10 := NULL;
    END IF;
    IF (l_taov_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute11 := NULL;
    END IF;
    IF (l_taov_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute12 := NULL;
    END IF;
    IF (l_taov_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute13 := NULL;
    END IF;
    IF (l_taov_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute14 := NULL;
    END IF;
    IF (l_taov_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.attribute15 := NULL;
    END IF;
    IF (l_taov_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.org_id := NULL;
    END IF;
    IF (l_taov_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.created_by := NULL;
    END IF;
    IF (l_taov_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_taov_rec.creation_date := NULL;
    END IF;
    IF (l_taov_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.last_updated_by := NULL;
    END IF;
    IF (l_taov_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_taov_rec.last_update_date := NULL;
    END IF;
    IF (l_taov_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_taov_rec.last_update_login := NULL;
    END IF;
    /* changes Made by Kanti on 06.27.2001. This field was missing from TAPI   */
    IF (l_taov_rec.post_to_gl_yn = Okc_Api.G_MISS_CHAR) THEN
      l_taov_rec.post_to_gl_yn := NULL;
    END IF;
   /* Changes End  */
    RETURN(l_taov_rec);
  END null_out_defaults;

  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_ACCT_OPTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (p_taov_rec IN  taov_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_Status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_try_id(x_return_status => l_return_status, p_taov_rec => p_taov_rec);

    IF(l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    validate_post_to_gl_yn(x_return_Status => l_return_status, p_taov_rec => p_taov_rec);

    IF(l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    validate_all_ccid(x_return_Status => l_return_status, p_taov_rec => p_taov_rec);

    IF(l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.SET_MESSAGE(p_app_name    => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => SQLCODE,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => SQLERRM);

        x_return_status  := Okc_Api.G_RET_STS_UNEXP_ERROR;
        RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_TRX_ACCT_OPTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_taov_rec IN taov_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN taov_rec_type,
    p_to	IN OUT NOCOPY tao_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.try_id := p_from.try_id;
    p_to.REV_CCID := p_from.REV_CCID;
    p_to.freight_ccid := p_from.freight_ccid;
    p_to.rec_ccid := p_from.rec_ccid;
    p_to.clearing_ccid := p_from.clearing_ccid;
    p_to.tax_ccid := p_from.tax_ccid;
    p_to.unbilled_ccid := p_from.unbilled_ccid;
    p_to.unearned_ccid := p_from.unearned_ccid;
    p_to.object_version_number := p_from.object_version_number;
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
/* Changes made by kanti on 06.27.2001. This field was missing from TAPI */
    p_to.post_to_gl_yn     := p_from.post_to_gl_yn;
/* Changes End  */

  END migrate;
  PROCEDURE migrate (
    p_from	IN tao_rec_type,
    p_to	OUT NOCOPY taov_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.try_id := p_from.try_id;
    p_to.REV_CCID := p_from.REV_CCID;
    p_to.freight_ccid := p_from.freight_ccid;
    p_to.rec_ccid := p_from.rec_ccid;
    p_to.clearing_ccid := p_from.clearing_ccid;
    p_to.tax_ccid := p_from.tax_ccid;
    p_to.unbilled_ccid := p_from.unbilled_ccid;
    p_to.unearned_ccid := p_from.unearned_ccid;
    p_to.object_version_number := p_from.object_version_number;
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
/* Changes made by kanti on 06.27.2001. This field was missing from TAPI */
    p_to.post_to_gl_yn     := p_from.post_to_gl_yn;
/* Changes End  */
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_TRX_ACCT_OPTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_taov_rec                     taov_rec_type := p_taov_rec;
    l_tao_rec                      tao_rec_type;
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
    l_return_status := Validate_Attributes(l_taov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_taov_rec);
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
  -- PL/SQL TBL validate_row for:TAOV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taov_tbl.COUNT > 0) THEN
      i := p_taov_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taov_rec                     => p_taov_tbl(i));
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_taov_tbl.LAST);
        i := p_taov_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
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
  --------------------------------------
  -- insert_row for:OKL_TRX_ACCT_OPTS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tao_rec                      IN tao_rec_type,
    x_tao_rec                      OUT NOCOPY tao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tao_rec                      tao_rec_type := p_tao_rec;
    l_def_tao_rec                  tao_rec_type;

    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_ACCT_OPTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_tao_rec IN  tao_rec_type,
      x_tao_rec OUT NOCOPY tao_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tao_rec := p_tao_rec;
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
      p_tao_rec,                         -- IN
      l_tao_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_ACCT_OPTS(
        id,
        try_id,
        rev_CCID,
        freight_CCID,
        rec_CCID,
        clearing_CCID,
        tax_CCID,
        unbilled_CCID,
        unearned_CCID,
        object_version_number,
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
/* changes made by Kanti on 06/27/2001. this field was missing from TAPI  */
        post_to_gl_yn)
/* Changes End */
      VALUES (
        l_tao_rec.id,
        l_tao_rec.try_id,
        l_tao_rec.REV_CCID,
        l_tao_rec.freight_ccid,
        l_tao_rec.rec_ccid,
        l_tao_rec.clearing_ccid,
        l_tao_rec.tax_ccid,
        l_tao_rec.unbilled_ccid,
        l_tao_rec.unearned_ccid,
        l_tao_rec.object_version_number,
        l_tao_rec.org_id,
        l_tao_rec.attribute_category,
        l_tao_rec.attribute1,
        l_tao_rec.attribute2,
        l_tao_rec.attribute3,
        l_tao_rec.attribute4,
        l_tao_rec.attribute5,
        l_tao_rec.attribute6,
        l_tao_rec.attribute7,
        l_tao_rec.attribute8,
        l_tao_rec.attribute9,
        l_tao_rec.attribute10,
        l_tao_rec.attribute11,
        l_tao_rec.attribute12,
        l_tao_rec.attribute13,
        l_tao_rec.attribute14,
        l_tao_rec.attribute15,
        l_tao_rec.created_by,
        l_tao_rec.creation_date,
        l_tao_rec.last_updated_by,
        l_tao_rec.last_update_date,
        l_tao_rec.last_update_login,
/* changes made by Kanti on 06/27/2001. this field was missing from TAPI  */
        l_tao_rec.post_to_gl_yn
/* Changes End */
);
    -- Set OUT values
    x_tao_rec := l_tao_rec;
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
  -- insert_row for:OKL_TRX_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type,
    x_taov_rec                     OUT NOCOPY taov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_taov_rec                     taov_rec_type;
    l_def_taov_rec                 taov_rec_type;
    l_tao_rec                      tao_rec_type;
    lx_tao_rec                     tao_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taov_rec	IN taov_rec_type
    ) RETURN taov_rec_type IS
      l_taov_rec	taov_rec_type := p_taov_rec;
    BEGIN
      l_taov_rec.CREATION_DATE := SYSDATE;
      l_taov_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_taov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_taov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_taov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_taov_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_ACCT_OPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_taov_rec IN  taov_rec_type,
      x_taov_rec OUT NOCOPY taov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taov_rec := p_taov_rec;
      x_taov_rec.OBJECT_VERSION_NUMBER := 1;
      x_taov_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
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
    l_taov_rec := null_out_defaults(p_taov_rec);
    -- Set primary key value
    l_taov_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_taov_rec,                        -- IN
      l_def_taov_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_taov_rec := fill_who_columns(l_def_taov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_taov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_taov_rec, l_tao_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tao_rec,
      lx_tao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tao_rec, l_def_taov_rec);
    -- Set OUT values
    x_taov_rec := l_def_taov_rec;
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
  -- PL/SQL TBL insert_row for:TAOV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type,
    x_taov_tbl                     OUT NOCOPY taov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taov_tbl.COUNT > 0) THEN
      i := p_taov_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taov_rec                     => p_taov_tbl(i),
          x_taov_rec                     => x_taov_tbl(i));
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_taov_tbl.LAST);
        i := p_taov_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
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
  ------------------------------------
  -- lock_row for:OKL_TRX_ACCT_OPTS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tao_rec                      IN tao_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tao_rec IN tao_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_ACCT_OPTS
     WHERE ID = p_tao_rec.id
       AND OBJECT_VERSION_NUMBER = p_tao_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tao_rec IN tao_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_ACCT_OPTS
    WHERE ID = p_tao_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_ACCT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_ACCT_OPTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tao_rec);
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
      OPEN lchk_csr(p_tao_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tao_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tao_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKL_TRX_ACCT_OPTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tao_rec                      tao_rec_type;
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
    migrate(p_taov_rec, l_tao_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tao_rec
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
  -- PL/SQL TBL lock_row for:TAOV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taov_tbl.COUNT > 0) THEN
      i := p_taov_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taov_rec                     => p_taov_tbl(i));
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_taov_tbl.LAST);
        i := p_taov_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
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
  --------------------------------------
  -- update_row for:OKL_TRX_ACCT_OPTS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tao_rec                      IN tao_rec_type,
    x_tao_rec                      OUT NOCOPY tao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tao_rec                      tao_rec_type := p_tao_rec;
    l_def_tao_rec                  tao_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tao_rec	IN tao_rec_type,
      x_tao_rec	OUT NOCOPY tao_rec_type
    ) RETURN VARCHAR2 IS
      l_tao_rec                      tao_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tao_rec := p_tao_rec;
      -- Get current database values
      l_tao_rec := get_rec(p_tao_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tao_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.id := l_tao_rec.id;
      END IF;
      IF (x_tao_rec.try_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.try_id := l_tao_rec.try_id;
      END IF;
      IF (x_tao_rec.REV_CCID = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.REV_CCID := l_tao_rec.REV_CCID;
      END IF;
      IF (x_tao_rec.freight_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.freight_ccid := l_tao_rec.freight_ccid;
      END IF;
      IF (x_tao_rec.rec_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.rec_ccid := l_tao_rec.rec_ccid;
      END IF;
      IF (x_tao_rec.clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.clearing_ccid := l_tao_rec.clearing_ccid;
      END IF;
      IF (x_tao_rec.tax_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.tax_ccid := l_tao_rec.tax_ccid;
      END IF;
      IF (x_tao_rec.unbilled_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.unbilled_ccid := l_tao_rec.unbilled_ccid;
      END IF;
      IF (x_tao_rec.unearned_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.unearned_ccid := l_tao_rec.unearned_ccid;
      END IF;
      IF (x_tao_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.object_version_number := l_tao_rec.object_version_number;
      END IF;
      IF (x_tao_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.org_id := l_tao_rec.org_id;
      END IF;
      IF (x_tao_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute_category := l_tao_rec.attribute_category;
      END IF;
      IF (x_tao_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute1 := l_tao_rec.attribute1;
      END IF;
      IF (x_tao_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute2 := l_tao_rec.attribute2;
      END IF;
      IF (x_tao_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute3 := l_tao_rec.attribute3;
      END IF;
      IF (x_tao_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute4 := l_tao_rec.attribute4;
      END IF;
      IF (x_tao_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute5 := l_tao_rec.attribute5;
      END IF;
      IF (x_tao_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute6 := l_tao_rec.attribute6;
      END IF;
      IF (x_tao_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute7 := l_tao_rec.attribute7;
      END IF;
      IF (x_tao_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute8 := l_tao_rec.attribute8;
      END IF;
      IF (x_tao_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute9 := l_tao_rec.attribute9;
      END IF;
      IF (x_tao_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute10 := l_tao_rec.attribute10;
      END IF;
      IF (x_tao_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute11 := l_tao_rec.attribute11;
      END IF;
      IF (x_tao_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute12 := l_tao_rec.attribute12;
      END IF;
      IF (x_tao_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute13 := l_tao_rec.attribute13;
      END IF;
      IF (x_tao_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute14 := l_tao_rec.attribute14;
      END IF;
      IF (x_tao_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.attribute15 := l_tao_rec.attribute15;
      END IF;
      IF (x_tao_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.created_by := l_tao_rec.created_by;
      END IF;
      IF (x_tao_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tao_rec.creation_date := l_tao_rec.creation_date;
      END IF;
      IF (x_tao_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.last_updated_by := l_tao_rec.last_updated_by;
      END IF;
      IF (x_tao_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tao_rec.last_update_date := l_tao_rec.last_update_date;
      END IF;
      IF (x_tao_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_tao_rec.last_update_login := l_tao_rec.last_update_login;
      END IF;
/* changes made by Kanti on 06/27/2001. this field was missing from TAPI  */
      IF (x_tao_rec.post_to_gl_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tao_rec.post_to_gl_yn := l_tao_rec.post_to_gl_yn;
      END IF;
/* Changes End  */
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_ACCT_OPTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_tao_rec IN  tao_rec_type,
      x_tao_rec OUT NOCOPY tao_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tao_rec := p_tao_rec;
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
      p_tao_rec,                         -- IN
      l_tao_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tao_rec, l_def_tao_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_ACCT_OPTS
    SET TRY_ID = l_def_tao_rec.try_id,
        REV_CCID = l_def_tao_rec.REV_CCID,
        FREIGHT_CCID = l_def_tao_rec.freight_ccid,
        REC_CCID = l_def_tao_rec.rec_ccid,
        CLEARING_CCID = l_def_tao_rec.clearing_ccid,
        TAX_CCID = l_def_tao_rec.tax_ccid,
        UNBILLED_CCID = l_def_tao_rec.unbilled_ccid,
        UNEARNED_CCID = l_def_tao_rec.unearned_ccid,
        OBJECT_VERSION_NUMBER = l_def_tao_rec.object_version_number,
        ORG_ID = l_def_tao_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_tao_rec.attribute_category,
        ATTRIBUTE1 = l_def_tao_rec.attribute1,
        ATTRIBUTE2 = l_def_tao_rec.attribute2,
        ATTRIBUTE3 = l_def_tao_rec.attribute3,
        ATTRIBUTE4 = l_def_tao_rec.attribute4,
        ATTRIBUTE5 = l_def_tao_rec.attribute5,
        ATTRIBUTE6 = l_def_tao_rec.attribute6,
        ATTRIBUTE7 = l_def_tao_rec.attribute7,
        ATTRIBUTE8 = l_def_tao_rec.attribute8,
        ATTRIBUTE9 = l_def_tao_rec.attribute9,
        ATTRIBUTE10 = l_def_tao_rec.attribute10,
        ATTRIBUTE11 = l_def_tao_rec.attribute11,
        ATTRIBUTE12 = l_def_tao_rec.attribute12,
        ATTRIBUTE13 = l_def_tao_rec.attribute13,
        ATTRIBUTE14 = l_def_tao_rec.attribute14,
        ATTRIBUTE15 = l_def_tao_rec.attribute15,
        CREATED_BY = l_def_tao_rec.created_by,
        CREATION_DATE = l_def_tao_rec.creation_date,
        LAST_UPDATED_BY = l_def_tao_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tao_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tao_rec.last_update_login,
/* changes made by Kanti on 06/27/2001. this field was missing from TAPI  */
        POST_TO_GL_YN     = l_def_tao_rec.post_to_gl_yn
/* Changes End */
    WHERE ID = l_def_tao_rec.id;

    x_tao_rec := l_def_tao_rec;
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
  -- update_row for:OKL_TRX_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type,
    x_taov_rec                     OUT NOCOPY taov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_taov_rec                     taov_rec_type := p_taov_rec;
    l_def_taov_rec                 taov_rec_type;
    l_tao_rec                      tao_rec_type;
    lx_tao_rec                     tao_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_taov_rec	IN taov_rec_type
    ) RETURN taov_rec_type IS
      l_taov_rec	taov_rec_type := p_taov_rec;
    BEGIN
      l_taov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_taov_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_taov_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_taov_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_taov_rec	IN taov_rec_type,
      x_taov_rec	OUT NOCOPY taov_rec_type
    ) RETURN VARCHAR2 IS
      l_taov_rec                     taov_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taov_rec := p_taov_rec;
      -- Get current database values
      l_taov_rec := get_rec(p_taov_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_taov_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.id := l_taov_rec.id;
      END IF;
      IF (x_taov_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.object_version_number := l_taov_rec.object_version_number;
      END IF;
      IF (x_taov_rec.try_id = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.try_id := l_taov_rec.try_id;
      END IF;
      IF (x_taov_rec.unearned_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.unearned_ccid := l_taov_rec.unearned_ccid;
      END IF;
      IF (x_taov_rec.REV_CCID = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.REV_CCID := l_taov_rec.REV_CCID;
      END IF;
      IF (x_taov_rec.freight_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.freight_ccid := l_taov_rec.freight_ccid;
      END IF;
      IF (x_taov_rec.rec_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.rec_ccid := l_taov_rec.rec_ccid;
      END IF;
      IF (x_taov_rec.clearing_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.clearing_ccid := l_taov_rec.clearing_ccid;
      END IF;
      IF (x_taov_rec.tax_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.tax_ccid := l_taov_rec.tax_ccid;
      END IF;
      IF (x_taov_rec.unbilled_ccid = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.unbilled_ccid := l_taov_rec.unbilled_ccid;
      END IF;
      IF (x_taov_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute_category := l_taov_rec.attribute_category;
      END IF;
      IF (x_taov_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute1 := l_taov_rec.attribute1;
      END IF;
      IF (x_taov_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute2 := l_taov_rec.attribute2;
      END IF;
      IF (x_taov_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute3 := l_taov_rec.attribute3;
      END IF;
      IF (x_taov_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute4 := l_taov_rec.attribute4;
      END IF;
      IF (x_taov_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute5 := l_taov_rec.attribute5;
      END IF;
      IF (x_taov_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute6 := l_taov_rec.attribute6;
      END IF;
      IF (x_taov_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute7 := l_taov_rec.attribute7;
      END IF;
      IF (x_taov_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute8 := l_taov_rec.attribute8;
      END IF;
      IF (x_taov_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute9 := l_taov_rec.attribute9;
      END IF;
      IF (x_taov_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute10 := l_taov_rec.attribute10;
      END IF;
      IF (x_taov_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute11 := l_taov_rec.attribute11;
      END IF;
      IF (x_taov_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute12 := l_taov_rec.attribute12;
      END IF;
      IF (x_taov_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute13 := l_taov_rec.attribute13;
      END IF;
      IF (x_taov_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute14 := l_taov_rec.attribute14;
      END IF;
      IF (x_taov_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.attribute15 := l_taov_rec.attribute15;
      END IF;
      IF (x_taov_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.org_id := l_taov_rec.org_id;
      END IF;
      IF (x_taov_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.created_by := l_taov_rec.created_by;
      END IF;
      IF (x_taov_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_taov_rec.creation_date := l_taov_rec.creation_date;
      END IF;
      IF (x_taov_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.last_updated_by := l_taov_rec.last_updated_by;
      END IF;
      IF (x_taov_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_taov_rec.last_update_date := l_taov_rec.last_update_date;
      END IF;
      IF (x_taov_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_taov_rec.last_update_login := l_taov_rec.last_update_login;
      END IF;
/* changes made by Kanti on 06/27/2001. this field was missing from TAPI  */
      IF (x_taov_rec.post_to_gl_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_taov_rec.post_to_gl_yn := l_taov_rec.post_to_gl_yn;
      END IF;
/* Changes end */
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_ACCT_OPTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_taov_rec IN  taov_rec_type,
      x_taov_rec OUT NOCOPY taov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_taov_rec := p_taov_rec;
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
      p_taov_rec,                        -- IN
      l_taov_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_taov_rec, l_def_taov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_taov_rec := fill_who_columns(l_def_taov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_taov_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_taov_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_taov_rec, l_tao_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tao_rec,
      lx_tao_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tao_rec, l_def_taov_rec);
    x_taov_rec := l_def_taov_rec;
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
  -- PL/SQL TBL update_row for:TAOV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type,
    x_taov_tbl                     OUT NOCOPY taov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taov_tbl.COUNT > 0) THEN
      i := p_taov_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taov_rec                     => p_taov_tbl(i),
          x_taov_rec                     => x_taov_tbl(i));
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_taov_tbl.LAST);
        i := p_taov_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
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
  --------------------------------------
  -- delete_row for:OKL_TRX_ACCT_OPTS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tao_rec                      IN tao_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tao_rec                      tao_rec_type:= p_tao_rec;
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
    DELETE FROM OKL_TRX_ACCT_OPTS
     WHERE ID = l_tao_rec.id;

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
  -- delete_row for:OKL_TRX_ACCT_OPTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_taov_rec                     taov_rec_type := p_taov_rec;
    l_tao_rec                      tao_rec_type;
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
    migrate(l_taov_rec, l_tao_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tao_rec
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
  -- PL/SQL TBL delete_row for:TAOV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_taov_tbl.COUNT > 0) THEN
      i := p_taov_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_taov_rec                     => p_taov_tbl(i));
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_taov_tbl.LAST);
        i := p_taov_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
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
END Okl_Tao_Pvt;

/
