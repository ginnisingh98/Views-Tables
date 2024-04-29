--------------------------------------------------------
--  DDL for Package Body OKL_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ADJ_PVT" AS
/* $Header: OKLSADJB.pls 120.7 2008/01/17 10:08:21 veramach noship $ */

  ---------------------------------------------------------------------------
  -- Global Variables
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------
  --GLOBAL MESSAGES
     G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
     G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
     G_SQLERRM_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
     G_SQLCODE_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
     G_NOT_SAME         CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';

  --GLOBAL VARIABLES
    G_VIEW              CONSTANT   VARCHAR2(30)  := 'OKL_TRX_AR_ADJSTS_V';
    G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_TRX_AR_ADJSTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_AR_ADJSTS_ALL_B B   --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TRX_AR_ADJSTS_TL T SET (
        COMMENTS,
        CREATED_BY,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN) = (SELECT
                                  B.COMMENTS,
                                  B.CREATED_BY,
                                  B.LAST_UPDATED_BY,
                                  B.LAST_UPDATE_LOGIN
                                FROM OKL_TRX_AR_ADJSTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_AR_ADJSTS_TL SUBB, OKL_TRX_AR_ADJSTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.CREATED_BY <> SUBT.CREATED_BY
                      OR SUBB.LAST_UPDATED_BY <> SUBT.LAST_UPDATED_BY
                      OR SUBB.LAST_UPDATE_LOGIN <> SUBT.LAST_UPDATE_LOGIN
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.LAST_UPDATE_LOGIN IS NULL AND SUBT.LAST_UPDATE_LOGIN IS NOT NULL)
                      OR (SUBB.LAST_UPDATE_LOGIN IS NOT NULL AND SUBT.LAST_UPDATE_LOGIN IS NULL)
              ));

    INSERT INTO OKL_TRX_AR_ADJSTS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
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
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TRX_AR_ADJSTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_AR_ADJSTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_ADJSTS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_adj_rec                      IN adj_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN adj_rec_type IS
    CURSOR okl_trx_ar_adjsts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CCW_ID,
            TCN_ID,
            TRY_ID,
            ADJUSTMENT_REASON_CODE,
            APPLY_DATE,
            OBJECT_VERSION_NUMBER,
            GL_DATE,
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
            TRX_STATUS_CODE,
	      --gkhuntet start 02-Nov-07
            TRANSACTION_DATE
	    --gkhuntet end 02-Nov-07
      FROM Okl_Trx_Ar_Adjsts_B
     WHERE okl_trx_ar_adjsts_b.id = p_id;
    l_okl_trx_ar_adjsts_pk         okl_trx_ar_adjsts_pk_csr%ROWTYPE;
    l_adj_rec                      adj_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_ar_adjsts_pk_csr (p_adj_rec.id);
    FETCH okl_trx_ar_adjsts_pk_csr INTO
              l_adj_rec.ID,
              l_adj_rec.CCW_ID,
              l_adj_rec.TCN_ID,
              l_adj_rec.TRY_ID,
              l_adj_rec.ADJUSTMENT_REASON_CODE,
              l_adj_rec.APPLY_DATE,
              l_adj_rec.OBJECT_VERSION_NUMBER,
              l_adj_rec.GL_DATE,
              l_adj_rec.REQUEST_ID,
              l_adj_rec.PROGRAM_APPLICATION_ID,
              l_adj_rec.PROGRAM_ID,
              l_adj_rec.PROGRAM_UPDATE_DATE,
              l_adj_rec.ORG_ID,
              l_adj_rec.ATTRIBUTE_CATEGORY,
              l_adj_rec.ATTRIBUTE1,
              l_adj_rec.ATTRIBUTE2,
              l_adj_rec.ATTRIBUTE3,
              l_adj_rec.ATTRIBUTE4,
              l_adj_rec.ATTRIBUTE5,
              l_adj_rec.ATTRIBUTE6,
              l_adj_rec.ATTRIBUTE7,
              l_adj_rec.ATTRIBUTE8,
              l_adj_rec.ATTRIBUTE9,
              l_adj_rec.ATTRIBUTE10,
              l_adj_rec.ATTRIBUTE11,
              l_adj_rec.ATTRIBUTE12,
              l_adj_rec.ATTRIBUTE13,
              l_adj_rec.ATTRIBUTE14,
              l_adj_rec.ATTRIBUTE15,
              l_adj_rec.CREATED_BY,
              l_adj_rec.CREATION_DATE,
              l_adj_rec.LAST_UPDATED_BY,
              l_adj_rec.LAST_UPDATE_DATE,
              l_adj_rec.LAST_UPDATE_LOGIN,
              l_adj_rec.TRX_STATUS_CODE,
	        --gkhuntet1
              l_adj_rec.TRANSACTION_DATE;
    x_no_data_found := okl_trx_ar_adjsts_pk_csr%NOTFOUND;
    CLOSE okl_trx_ar_adjsts_pk_csr;
    RETURN(l_adj_rec);
  END get_rec;

  FUNCTION get_rec (
    p_adj_rec                      IN adj_rec_type
  ) RETURN adj_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_adj_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_ADJSTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_trx_ar_adjsts_tl_rec_type IS
    CURSOR okl_trx_ar_adjsts_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Trx_Ar_Adjsts_Tl
     WHERE okl_trx_ar_adjsts_tl.id = p_id
       AND okl_trx_ar_adjsts_tl.language = p_language;
    l_okl_trx_ar_adjsts_tl_pk      okl_trx_ar_adjsts_tl_pk_csr%ROWTYPE;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_ar_adjsts_tl_pk_csr (p_okl_trx_ar_adjsts_tl_rec.id,
                                      p_okl_trx_ar_adjsts_tl_rec.language);
    FETCH okl_trx_ar_adjsts_tl_pk_csr INTO
              l_okl_trx_ar_adjsts_tl_rec.ID,
              l_okl_trx_ar_adjsts_tl_rec.LANGUAGE,
              l_okl_trx_ar_adjsts_tl_rec.SOURCE_LANG,
              l_okl_trx_ar_adjsts_tl_rec.SFWT_FLAG,
              l_okl_trx_ar_adjsts_tl_rec.COMMENTS,
              l_okl_trx_ar_adjsts_tl_rec.CREATED_BY,
              l_okl_trx_ar_adjsts_tl_rec.CREATION_DATE,
              l_okl_trx_ar_adjsts_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_ar_adjsts_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_ar_adjsts_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_ar_adjsts_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_ar_adjsts_tl_pk_csr;
    RETURN(l_okl_trx_ar_adjsts_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type
  ) RETURN okl_trx_ar_adjsts_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_ar_adjsts_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AR_ADJSTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_adjv_rec                     IN adjv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN adjv_rec_type IS
    CURSOR okl_adjv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            TRX_STATUS_CODE,
            CCW_ID,
            TCN_ID,
            TRY_ID,
            ADJUSTMENT_REASON_CODE,
            APPLY_DATE,
            GL_DATE,
            COMMENTS,
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
	     --gkhuntet start 02-Nov-07
           TRANSACTION_DATE
  	     --gkhuntet end 02-Nov-07
      FROM Okl_Trx_Ar_Adjsts_V
     WHERE okl_trx_ar_adjsts_v.id = p_id;
    l_okl_adjv_pk                  okl_adjv_pk_csr%ROWTYPE;
    l_adjv_rec                     adjv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_adjv_pk_csr (p_adjv_rec.id);
    FETCH okl_adjv_pk_csr INTO
              l_adjv_rec.ID,
              l_adjv_rec.OBJECT_VERSION_NUMBER,
              l_adjv_rec.SFWT_FLAG,
              l_adjv_rec.TRX_STATUS_CODE,
              l_adjv_rec.CCW_ID,
              l_adjv_rec.TCN_ID,
              l_adjv_rec.TRY_ID,
              l_adjv_rec.ADJUSTMENT_REASON_CODE,
              l_adjv_rec.APPLY_DATE,
              l_adjv_rec.GL_DATE,
              l_adjv_rec.COMMENTS,
              l_adjv_rec.ATTRIBUTE_CATEGORY,
              l_adjv_rec.ATTRIBUTE1,
              l_adjv_rec.ATTRIBUTE2,
              l_adjv_rec.ATTRIBUTE3,
              l_adjv_rec.ATTRIBUTE4,
              l_adjv_rec.ATTRIBUTE5,
              l_adjv_rec.ATTRIBUTE6,
              l_adjv_rec.ATTRIBUTE7,
              l_adjv_rec.ATTRIBUTE8,
              l_adjv_rec.ATTRIBUTE9,
              l_adjv_rec.ATTRIBUTE10,
              l_adjv_rec.ATTRIBUTE11,
              l_adjv_rec.ATTRIBUTE12,
              l_adjv_rec.ATTRIBUTE13,
              l_adjv_rec.ATTRIBUTE14,
              l_adjv_rec.ATTRIBUTE15,
              l_adjv_rec.REQUEST_ID,
              l_adjv_rec.PROGRAM_APPLICATION_ID,
              l_adjv_rec.PROGRAM_ID,
              l_adjv_rec.PROGRAM_UPDATE_DATE,
              l_adjv_rec.ORG_ID,
              l_adjv_rec.CREATED_BY,
              l_adjv_rec.CREATION_DATE,
              l_adjv_rec.LAST_UPDATED_BY,
              l_adjv_rec.LAST_UPDATE_DATE,
              l_adjv_rec.LAST_UPDATE_LOGIN,
	        --gkhuntet start 02-Nov-07
              l_adjv_rec.TRANSACTION_DATE;
     	        --gkhuntet end 02-Nov-07
    x_no_data_found := okl_adjv_pk_csr%NOTFOUND;
    CLOSE okl_adjv_pk_csr;
    RETURN(l_adjv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_adjv_rec                     IN adjv_rec_type
  ) RETURN adjv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_adjv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_AR_ADJSTS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_adjv_rec	IN adjv_rec_type
  ) RETURN adjv_rec_type IS
    l_adjv_rec	adjv_rec_type := p_adjv_rec;
  BEGIN
    IF (l_adjv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.object_version_number := NULL;
    END IF;
    IF (l_adjv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_adjv_rec.trx_status_code = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.trx_status_code := NULL;
    END IF;
    IF (l_adjv_rec.ccw_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.ccw_id := NULL;
    END IF;
    IF (l_adjv_rec.tcn_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.tcn_id := NULL;
    END IF;
    IF (l_adjv_rec.try_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.try_id := NULL;
    END IF;
    IF (l_adjv_rec.adjustment_reason_code = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.adjustment_reason_code := NULL;
    END IF;
    IF (l_adjv_rec.apply_date = OKL_API.G_MISS_DATE) THEN
      l_adjv_rec.apply_date := NULL;
    END IF;
    IF (l_adjv_rec.gl_date = OKL_API.G_MISS_DATE) THEN
      l_adjv_rec.gl_date := NULL;
    END IF;
    IF (l_adjv_rec.comments = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.comments := NULL;
    END IF;
    IF (l_adjv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute_category := NULL;
    END IF;
    IF (l_adjv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute1 := NULL;
    END IF;
    IF (l_adjv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute2 := NULL;
    END IF;
    IF (l_adjv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute3 := NULL;
    END IF;
    IF (l_adjv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute4 := NULL;
    END IF;
    IF (l_adjv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute5 := NULL;
    END IF;
    IF (l_adjv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute6 := NULL;
    END IF;
    IF (l_adjv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute7 := NULL;
    END IF;
    IF (l_adjv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute8 := NULL;
    END IF;
    IF (l_adjv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute9 := NULL;
    END IF;
    IF (l_adjv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute10 := NULL;
    END IF;
    IF (l_adjv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute11 := NULL;
    END IF;
    IF (l_adjv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute12 := NULL;
    END IF;
    IF (l_adjv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute13 := NULL;
    END IF;
    IF (l_adjv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute14 := NULL;
    END IF;
    IF (l_adjv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_adjv_rec.attribute15 := NULL;
    END IF;
    IF (l_adjv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.request_id := NULL;
    END IF;
    IF (l_adjv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.program_application_id := NULL;
    END IF;
    IF (l_adjv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.program_id := NULL;
    END IF;
    IF (l_adjv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_adjv_rec.program_update_date := NULL;
    END IF;
    IF (l_adjv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.org_id := NULL;
    END IF;
    IF (l_adjv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.created_by := NULL;
    END IF;
    IF (l_adjv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_adjv_rec.creation_date := NULL;
    END IF;
    IF (l_adjv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.last_updated_by := NULL;
    END IF;
    IF (l_adjv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_adjv_rec.last_update_date := NULL;
    END IF;
    IF (l_adjv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_adjv_rec.last_update_login := NULL;
    END IF;
    --gkhuntet start 02-Nov-07
    IF (l_adjv_rec. TRANSACTION_DATE  = Okl_Api.G_MISS_DATE) THEN
      l_adjv_rec. TRANSACTION_DATE  := NULL;
    END IF;
--gkhuntet end 02-Nov-07
    RETURN(l_adjv_rec);
  END null_out_defaults;

--Bug 6316320 dpsingh start
 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Try_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_TRY_ID
  -- Description      : Although in table it is NULLABLE, we are still making it
  --                    sure that TRY_ID must be given and should be valid.
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_TRY_Id (p_adjv_rec  IN  adjv_rec_type
                                                 ,x_return_status OUT NOCOPY VARCHAR2)

  IS
  l_dummy                   VARCHAR2(1)    ;

  CURSOR try_csr(v_try_id NUMBER) IS
  SELECT '1'
  FROM OKL_TRX_TYPES_B
  WHERE ID = v_try_id;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_adjv_rec.Try_id IS NULL) OR
       (p_adjv_rec.TRY_id = OkL_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'TRY_ID');
       x_return_status     := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN try_csr(p_adjv_rec.TRY_ID);
    FETCH try_csr INTO l_dummy;
    IF (try_csr%NOTFOUND) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'TRY_ID');
       x_return_status     := Okl_Api.G_RET_STS_ERROR;
       CLOSE try_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE try_csr;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_TRY_Id;
--Bug 6316320 dpsingh end
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_adjv_rec.id = OKL_API.G_MISS_NUM
    OR p_adjv_rec.id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_Version_Number (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_adjv_rec.object_version_number = OKL_API.G_MISS_NUM
    OR p_adjv_rec.object_version_number IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'object_version_number');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Apply_Date
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Apply_Date (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_adjv_rec.apply_date = OKL_API.G_MISS_DATE
    OR p_adjv_rec.apply_date IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'apply_date');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Apply_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Org_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Org_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- check value
    IF  p_adjv_rec.org_id <> OKL_API.G_MISS_NUM
    AND p_adjv_rec.org_id IS NOT NULL
    THEN
      x_return_status := okl_util.check_org_id (p_adjv_rec.org_id);
    END IF;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Org_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Adj_Reason_Code
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Adj_Reason_Code (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

    l_dummy_var         VARCHAR2(1) := '?';

    CURSOR l_lookup_code_csr (cp_lookup_code IN VARCHAR2) IS
          SELECT 'X'
          FROM   ar_lookups fndlup
          WHERE  fndlup.lookup_type = 'ADJUST_REASON'
          AND    fndlup.lookup_code = cp_lookup_code
          AND    sysdate BETWEEN
                         NVL(fndlup.start_date_active,sysdate)
                         AND NVL(fndlup.end_date_active,sysdate);

  BEGIN

   -- initialize return status
   x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

   IF p_adjv_rec.adjustment_reason_code IS NOT NULL THEN

        OPEN l_lookup_code_csr(p_adjv_rec.adjustment_reason_code);
        FETCH l_lookup_code_csr INTO l_dummy_var;
        CLOSE l_lookup_code_csr;
        -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
            -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

    END IF;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Adj_Reason_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Trx_Status_Code
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE  Validate_Trx_Status_Code (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec		  IN  adjv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- check value
    x_return_status := okl_util.check_lookup_code
	('OKL_TRANSACTION_STATUS', p_adjv_rec.trx_status_code);

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Trx_Status_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ccw_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------
/*
  PROCEDURE Validate_Ccw_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec	    IN  adjv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_ccwv_csr IS
		  SELECT 'x'
		  FROM   okl_cse_k_writeoffs_v
		  WHERE  id = p_adjv_rec.ccw_id;

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

  IF p_adjv_rec.ccw_id <> NULL THEN

    -- enforce foreign key
    OPEN l_ccwv_csr;
      FETCH l_ccwv_csr INTO l_dummy_var;
    CLOSE l_ccwv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'ccw_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TRX_AR_ADJSTS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_CSE_K_WRITEOFFS_V');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

  END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_ccwv_csr%ISOPEN THEN
         CLOSE l_ccwv_csr;
      END IF;

  END Validate_Ccw_Id;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tcn_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Tcn_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_adjv_rec	    IN  adjv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_tcnv_csr IS
		  SELECT 'x'
		  FROM   OKL_TRX_CONTRACTS
		  WHERE  id = p_adjv_rec.tcn_id;

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

  IF p_adjv_rec.tcn_id <> NULL THEN

    -- enforce foreign key
    OPEN l_tcnv_csr;
      FETCH l_tcnv_csr INTO l_dummy_var;
    CLOSE l_tcnv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'tcn_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TRX_AR_ADJSTS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_TRX_CONTRACTS');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

  END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_tcnv_csr%ISOPEN THEN
         CLOSE l_tcnv_csr;
      END IF;

  END Validate_Tcn_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_AR_ADJSTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_adjv_rec IN  adjv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call each column-level validation

    validate_id (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

 --Bug 6316320 dpsingh
    Validate_TRY_ID (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_apply_date (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;


    validate_org_id (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

/*
    validate_ccw_id (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
*/

    validate_tcn_id (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;


    validate_adj_reason_code (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;


    validate_trx_status_code (
      x_return_status => l_return_status,
      p_adjv_rec      => p_adjv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_TRX_AR_ADJSTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_adjv_rec IN adjv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN adjv_rec_type,
    p_to	IN OUT NOCOPY adj_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ccw_id := p_from.ccw_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.try_id := p_from.try_id;
    p_to.adjustment_reason_code := p_from.adjustment_reason_code;
    p_to.apply_date := p_from.apply_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gl_date := p_from.gl_date;
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
    p_to.trx_status_code := p_from.trx_status_code;
     --gkhuntet start 02-Nov-07
    p_to.TRANSACTION_DATE  := p_from.TRANSACTION_DATE ;
    --gkhuntet end 02-Nov-07
  END migrate;

  PROCEDURE migrate (
    p_from	IN adj_rec_type,
    p_to	IN OUT NOCOPY adjv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ccw_id := p_from.ccw_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.try_id := p_from.try_id;
    p_to.adjustment_reason_code := p_from.adjustment_reason_code;
    p_to.apply_date := p_from.apply_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.gl_date := p_from.gl_date;
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
    p_to.trx_status_code := p_from.trx_status_code;
      --gkhuntet start 02-Nov-07
    p_to.TRANSACTION_DATE  := p_from.TRANSACTION_DATE ;
    --gkhuntet end 02-Nov-07
  END migrate;
  PROCEDURE migrate (
    p_from	IN adjv_rec_type,
    p_to	IN OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_trx_ar_adjsts_tl_rec_type,
    p_to	IN OUT NOCOPY adjv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
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
  -- validate_row for:OKL_TRX_AR_ADJSTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adjv_rec                     adjv_rec_type := p_adjv_rec;
    l_adj_rec                      adj_rec_type;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_adjv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_adjv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:ADJV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_adjv_tbl.COUNT > 0) THEN
      i := p_adjv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_adjv_rec                     => p_adjv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_adjv_tbl.LAST);
        i := p_adjv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_AR_ADJSTS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adj_rec                      IN adj_rec_type,
    x_adj_rec                      OUT NOCOPY adj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adj_rec                      adj_rec_type := p_adj_rec;
    l_def_adj_rec                  adj_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_adj_rec IN  adj_rec_type,
      x_adj_rec OUT NOCOPY adj_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adj_rec := p_adj_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_adj_rec,                         -- IN
      l_adj_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--gkhuntet  start 02-Nov-07
    IF(l_adj_rec.TRANSACTION_DATE IS NULL OR  l_adj_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE)
    THEN
        l_adj_rec.TRANSACTION_DATE := SYSDATE;
    END IF;
--gkhuntet  end 02-Nov-07

    INSERT INTO OKL_TRX_AR_ADJSTS_B(
        id,
        ccw_id,
        tcn_id,
        try_id,
        adjustment_reason_code,
        apply_date,
        object_version_number,
        gl_date,
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
        trx_status_code,
	--gkhuntet  start 02-Nov-07
       TRANSACTION_DATE)
      --gkhuntet  end 02-Nov-07
      VALUES (
        l_adj_rec.id,
        l_adj_rec.ccw_id,
        l_adj_rec.tcn_id,
        l_adj_rec.try_id,
        l_adj_rec.adjustment_reason_code,
        l_adj_rec.apply_date,
        l_adj_rec.object_version_number,
        l_adj_rec.gl_date,
        l_adj_rec.request_id,
        l_adj_rec.program_application_id,
        l_adj_rec.program_id,
        l_adj_rec.program_update_date,
        l_adj_rec.org_id,
        l_adj_rec.attribute_category,
        l_adj_rec.attribute1,
        l_adj_rec.attribute2,
        l_adj_rec.attribute3,
        l_adj_rec.attribute4,
        l_adj_rec.attribute5,
        l_adj_rec.attribute6,
        l_adj_rec.attribute7,
        l_adj_rec.attribute8,
        l_adj_rec.attribute9,
        l_adj_rec.attribute10,
        l_adj_rec.attribute11,
        l_adj_rec.attribute12,
        l_adj_rec.attribute13,
        l_adj_rec.attribute14,
        l_adj_rec.attribute15,
        l_adj_rec.created_by,
        l_adj_rec.creation_date,
        l_adj_rec.last_updated_by,
        l_adj_rec.last_update_date,
        l_adj_rec.last_update_login,
        l_adj_rec.trx_status_code,
	--gkhuntet  start 02-Nov-07
        l_adj_rec.TRANSACTION_DATE);
      --gkhuntet  end 02-Nov-07
    -- Set OUT values
    x_adj_rec := l_adj_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_AR_ADJSTS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type,
    x_okl_trx_ar_adjsts_tl_rec     OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type := p_okl_trx_ar_adjsts_tl_rec;
    ldefokltrxaradjststlrec        okl_trx_ar_adjsts_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_adjsts_tl_rec IN  okl_trx_ar_adjsts_tl_rec_type,
      x_okl_trx_ar_adjsts_tl_rec OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_adjsts_tl_rec := p_okl_trx_ar_adjsts_tl_rec;
      x_okl_trx_ar_adjsts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ar_adjsts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_ar_adjsts_tl_rec,        -- IN
      l_okl_trx_ar_adjsts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_ar_adjsts_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_AR_ADJSTS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_trx_ar_adjsts_tl_rec.id,
          l_okl_trx_ar_adjsts_tl_rec.language,
          l_okl_trx_ar_adjsts_tl_rec.source_lang,
          l_okl_trx_ar_adjsts_tl_rec.sfwt_flag,
          l_okl_trx_ar_adjsts_tl_rec.comments,
          l_okl_trx_ar_adjsts_tl_rec.created_by,
          l_okl_trx_ar_adjsts_tl_rec.creation_date,
          l_okl_trx_ar_adjsts_tl_rec.last_updated_by,
          l_okl_trx_ar_adjsts_tl_rec.last_update_date,
          l_okl_trx_ar_adjsts_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_ar_adjsts_tl_rec := l_okl_trx_ar_adjsts_tl_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_AR_ADJSTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type,
    x_adjv_rec                     OUT NOCOPY adjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adjv_rec                     adjv_rec_type;
    l_def_adjv_rec                 adjv_rec_type;
    l_adj_rec                      adj_rec_type;
    lx_adj_rec                     adj_rec_type;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
    lx_okl_trx_ar_adjsts_tl_rec    okl_trx_ar_adjsts_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_adjv_rec	IN adjv_rec_type
    ) RETURN adjv_rec_type IS
      l_adjv_rec	adjv_rec_type := p_adjv_rec;
    BEGIN
      l_adjv_rec.CREATION_DATE := SYSDATE;
      l_adjv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_adjv_rec.LAST_UPDATE_DATE := l_adjv_rec.CREATION_DATE;
      l_adjv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_adjv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_adjv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_adjv_rec IN  adjv_rec_type,
      x_adjv_rec OUT NOCOPY adjv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adjv_rec := p_adjv_rec;
      x_adjv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Begin Post-Generation Change
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_adjv_rec.request_id,
        x_adjv_rec.program_application_id,
        x_adjv_rec.program_id,
        x_adjv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
      x_adjv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_adjv_rec := null_out_defaults(p_adjv_rec);
    -- Set primary key value
    l_adjv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_adjv_rec,                        -- IN
      l_def_adjv_rec);                   -- OUT

  --gkhuntet start 02-Nov-07
    IF(l_adjv_rec.TRANSACTION_DATE IS NULL OR  l_adjv_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE)
    THEN
        l_adjv_rec.TRANSACTION_DATE := SYSDATE;
    END IF;
   --gkhuntet end 02-Nov-07

    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_adjv_rec := fill_who_columns(l_def_adjv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_adjv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_adjv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_adjv_rec, l_adj_rec);
    migrate(l_def_adjv_rec, l_okl_trx_ar_adjsts_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_adj_rec,
      lx_adj_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_adj_rec, l_def_adjv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_adjsts_tl_rec,
      lx_okl_trx_ar_adjsts_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ar_adjsts_tl_rec, l_def_adjv_rec);
    -- Set OUT values
    x_adjv_rec := l_def_adjv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:ADJV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type,
    x_adjv_tbl                     OUT NOCOPY adjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_adjv_tbl.COUNT > 0) THEN
      i := p_adjv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_adjv_rec                     => p_adjv_tbl(i),
          x_adjv_rec                     => x_adjv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_adjv_tbl.LAST);
        i := p_adjv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_AR_ADJSTS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adj_rec                      IN adj_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_adj_rec IN adj_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AR_ADJSTS_B
     WHERE ID = p_adj_rec.id
       AND OBJECT_VERSION_NUMBER = p_adj_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_adj_rec IN adj_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AR_ADJSTS_B
    WHERE ID = p_adj_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_AR_ADJSTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_AR_ADJSTS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_adj_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_adj_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_adj_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_adj_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_AR_ADJSTS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_ar_adjsts_tl_rec IN okl_trx_ar_adjsts_tl_rec_type) IS
    SELECT *
      FROM OKL_TRX_AR_ADJSTS_TL
     WHERE ID = p_okl_trx_ar_adjsts_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_trx_ar_adjsts_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_AR_ADJSTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adj_rec                      adj_rec_type;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_adjv_rec, l_adj_rec);
    migrate(p_adjv_rec, l_okl_trx_ar_adjsts_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_adj_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_adjsts_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:ADJV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_adjv_tbl.COUNT > 0) THEN
      i := p_adjv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_adjv_rec                     => p_adjv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_adjv_tbl.LAST);
        i := p_adjv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_AR_ADJSTS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adj_rec                      IN adj_rec_type,
    x_adj_rec                      OUT NOCOPY adj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adj_rec                      adj_rec_type := p_adj_rec;
    l_def_adj_rec                  adj_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_adj_rec	IN adj_rec_type,
      x_adj_rec	OUT NOCOPY adj_rec_type
    ) RETURN VARCHAR2 IS
      l_adj_rec                      adj_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adj_rec := p_adj_rec;
      -- Get current database values
      l_adj_rec := get_rec(p_adj_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_adj_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.id := l_adj_rec.id;
      END IF;
      IF (x_adj_rec.ccw_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.ccw_id := l_adj_rec.ccw_id;
      END IF;
      IF (x_adj_rec.tcn_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.tcn_id := l_adj_rec.tcn_id;
      END IF;
       IF (x_adj_rec.try_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.try_id := l_adj_rec.try_id;
      END IF;
      IF (x_adj_rec.adjustment_reason_code = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.adjustment_reason_code := l_adj_rec.adjustment_reason_code;
      END IF;
      IF (x_adj_rec.apply_date = OKL_API.G_MISS_DATE)
      THEN
        x_adj_rec.apply_date := l_adj_rec.apply_date;
      END IF;
      IF (x_adj_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.object_version_number := l_adj_rec.object_version_number;
      END IF;
      IF (x_adj_rec.gl_date = OKL_API.G_MISS_DATE)
      THEN
        x_adj_rec.gl_date := l_adj_rec.gl_date;
      END IF;
      IF (x_adj_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.request_id := l_adj_rec.request_id;
      END IF;
      IF (x_adj_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.program_application_id := l_adj_rec.program_application_id;
      END IF;
      IF (x_adj_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.program_id := l_adj_rec.program_id;
      END IF;
      IF (x_adj_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_adj_rec.program_update_date := l_adj_rec.program_update_date;
      END IF;
      IF (x_adj_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.org_id := l_adj_rec.org_id;
      END IF;
      IF (x_adj_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute_category := l_adj_rec.attribute_category;
      END IF;
      IF (x_adj_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute1 := l_adj_rec.attribute1;
      END IF;
      IF (x_adj_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute2 := l_adj_rec.attribute2;
      END IF;
      IF (x_adj_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute3 := l_adj_rec.attribute3;
      END IF;
      IF (x_adj_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute4 := l_adj_rec.attribute4;
      END IF;
      IF (x_adj_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute5 := l_adj_rec.attribute5;
      END IF;
      IF (x_adj_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute6 := l_adj_rec.attribute6;
      END IF;
      IF (x_adj_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute7 := l_adj_rec.attribute7;
      END IF;
      IF (x_adj_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute8 := l_adj_rec.attribute8;
      END IF;
      IF (x_adj_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute9 := l_adj_rec.attribute9;
      END IF;
      IF (x_adj_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute10 := l_adj_rec.attribute10;
      END IF;
      IF (x_adj_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute11 := l_adj_rec.attribute11;
      END IF;
      IF (x_adj_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute12 := l_adj_rec.attribute12;
      END IF;
      IF (x_adj_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute13 := l_adj_rec.attribute13;
      END IF;
      IF (x_adj_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute14 := l_adj_rec.attribute14;
      END IF;
      IF (x_adj_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.attribute15 := l_adj_rec.attribute15;
      END IF;
      IF (x_adj_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.created_by := l_adj_rec.created_by;
      END IF;
      IF (x_adj_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_adj_rec.creation_date := l_adj_rec.creation_date;
      END IF;
      IF (x_adj_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.last_updated_by := l_adj_rec.last_updated_by;
      END IF;
      IF (x_adj_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_adj_rec.last_update_date := l_adj_rec.last_update_date;
      END IF;
      IF (x_adj_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_adj_rec.last_update_login := l_adj_rec.last_update_login;
      END IF;
      IF (x_adj_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_adj_rec.trx_status_code := l_adj_rec.trx_status_code;
      END IF;
      --gkhuntet start 02-Nov-07
      IF (x_adj_rec.TRANSACTION_DATE  = Okl_Api.G_MISS_DATE) THEN
          x_adj_rec.TRANSACTION_DATE  := SYSDATE;
      END IF;
       --gkhuntet end 02-Nov-07
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_adj_rec IN  adj_rec_type,
      x_adj_rec OUT NOCOPY adj_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adj_rec := p_adj_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_adj_rec,                         -- IN
      l_adj_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_adj_rec, l_def_adj_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_AR_ADJSTS_B
    SET CCW_ID = l_def_adj_rec.ccw_id,
        TCN_ID = l_def_adj_rec.tcn_id,
        TRY_ID = l_def_adj_rec.try_id,
        ADJUSTMENT_REASON_CODE = l_def_adj_rec.adjustment_reason_code,
        APPLY_DATE = l_def_adj_rec.apply_date,
        OBJECT_VERSION_NUMBER = l_def_adj_rec.object_version_number,
        GL_DATE = l_def_adj_rec.gl_date,
        REQUEST_ID = l_def_adj_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_adj_rec.program_application_id,
        PROGRAM_ID = l_def_adj_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_adj_rec.program_update_date,
        ORG_ID = l_def_adj_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_adj_rec.attribute_category,
        ATTRIBUTE1 = l_def_adj_rec.attribute1,
        ATTRIBUTE2 = l_def_adj_rec.attribute2,
        ATTRIBUTE3 = l_def_adj_rec.attribute3,
        ATTRIBUTE4 = l_def_adj_rec.attribute4,
        ATTRIBUTE5 = l_def_adj_rec.attribute5,
        ATTRIBUTE6 = l_def_adj_rec.attribute6,
        ATTRIBUTE7 = l_def_adj_rec.attribute7,
        ATTRIBUTE8 = l_def_adj_rec.attribute8,
        ATTRIBUTE9 = l_def_adj_rec.attribute9,
        ATTRIBUTE10 = l_def_adj_rec.attribute10,
        ATTRIBUTE11 = l_def_adj_rec.attribute11,
        ATTRIBUTE12 = l_def_adj_rec.attribute12,
        ATTRIBUTE13 = l_def_adj_rec.attribute13,
        ATTRIBUTE14 = l_def_adj_rec.attribute14,
        ATTRIBUTE15 = l_def_adj_rec.attribute15,
        CREATED_BY = l_def_adj_rec.created_by,
        CREATION_DATE = l_def_adj_rec.creation_date,
        LAST_UPDATED_BY = l_def_adj_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_adj_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_adj_rec.last_update_login,
        TRX_STATUS_CODE = l_def_adj_rec.trx_status_code,
	--gkhuntet start 02-Nov-07
        TRANSACTION_DATE = l_def_adj_rec.transaction_date
        --gkhuntet  end 02-Nov-07


    WHERE ID = l_def_adj_rec.id;

    x_adj_rec := l_def_adj_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_AR_ADJSTS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type,
    x_okl_trx_ar_adjsts_tl_rec     OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type := p_okl_trx_ar_adjsts_tl_rec;
    ldefokltrxaradjststlrec        okl_trx_ar_adjsts_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_ar_adjsts_tl_rec	IN okl_trx_ar_adjsts_tl_rec_type,
      x_okl_trx_ar_adjsts_tl_rec	OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okl_trx_ar_adjsts_tl_rec := p_okl_trx_ar_adjsts_tl_rec;
      -- Get current database values
      l_okl_trx_ar_adjsts_tl_rec := get_rec(p_okl_trx_ar_adjsts_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.id := l_okl_trx_ar_adjsts_tl_rec.id;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.language := l_okl_trx_ar_adjsts_tl_rec.language;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.source_lang := l_okl_trx_ar_adjsts_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.sfwt_flag := l_okl_trx_ar_adjsts_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.comments = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.comments := l_okl_trx_ar_adjsts_tl_rec.comments;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.created_by := l_okl_trx_ar_adjsts_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.creation_date := l_okl_trx_ar_adjsts_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.last_updated_by := l_okl_trx_ar_adjsts_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.last_update_date := l_okl_trx_ar_adjsts_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_ar_adjsts_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ar_adjsts_tl_rec.last_update_login := l_okl_trx_ar_adjsts_tl_rec.last_update_login;
      END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_adjsts_tl_rec IN  okl_trx_ar_adjsts_tl_rec_type,
      x_okl_trx_ar_adjsts_tl_rec OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_adjsts_tl_rec := p_okl_trx_ar_adjsts_tl_rec;
      x_okl_trx_ar_adjsts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ar_adjsts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_ar_adjsts_tl_rec,        -- IN
      l_okl_trx_ar_adjsts_tl_rec);       -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_okl_trx_ar_adjsts_tl_rec, ldefokltrxaradjststlrec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_AR_ADJSTS_TL
    SET COMMENTS = ldefokltrxaradjststlrec.comments,
        CREATED_BY = ldefokltrxaradjststlrec.created_by,
        CREATION_DATE = ldefokltrxaradjststlrec.creation_date,
        LAST_UPDATED_BY = ldefokltrxaradjststlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltrxaradjststlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltrxaradjststlrec.last_update_login
    WHERE ID = ldefokltrxaradjststlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TRX_AR_ADJSTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltrxaradjststlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_trx_ar_adjsts_tl_rec := ldefokltrxaradjststlrec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_AR_ADJSTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type,
    x_adjv_rec                     OUT NOCOPY adjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adjv_rec                     adjv_rec_type := p_adjv_rec;
    l_def_adjv_rec                 adjv_rec_type;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
    lx_okl_trx_ar_adjsts_tl_rec    okl_trx_ar_adjsts_tl_rec_type;
    l_adj_rec                      adj_rec_type;
    lx_adj_rec                     adj_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_adjv_rec	IN adjv_rec_type
    ) RETURN adjv_rec_type IS
      l_adjv_rec	adjv_rec_type := p_adjv_rec;
    BEGIN
      l_adjv_rec.CREATION_DATE := SYSDATE;
      l_adjv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_adjv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_adjv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_adjv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_adjv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_adjv_rec	IN adjv_rec_type,
      x_adjv_rec	OUT NOCOPY adjv_rec_type
    ) RETURN VARCHAR2 IS
      l_adjv_rec                     adjv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adjv_rec := p_adjv_rec;
      -- Get current database values
      l_adjv_rec := get_rec(p_adjv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_adjv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.id := l_adjv_rec.id;
      END IF;
      IF (x_adjv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.object_version_number := l_adjv_rec.object_version_number;
      END IF;
      IF (x_adjv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.sfwt_flag := l_adjv_rec.sfwt_flag;
      END IF;
      IF (x_adjv_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.trx_status_code := l_adjv_rec.trx_status_code;
      END IF;
      IF (x_adjv_rec.ccw_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.ccw_id := l_adjv_rec.ccw_id;
      END IF;
      IF (x_adjv_rec.tcn_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.tcn_id := l_adjv_rec.tcn_id;
      END IF;
        IF (x_adjv_rec.try_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.try_id := l_adjv_rec.try_id;
      END IF;
      IF (x_adjv_rec.adjustment_reason_code = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.adjustment_reason_code := l_adjv_rec.adjustment_reason_code;
      END IF;
      IF (x_adjv_rec.apply_date = OKL_API.G_MISS_DATE)
      THEN
        x_adjv_rec.apply_date := l_adjv_rec.apply_date;
      END IF;
      IF (x_adjv_rec.gl_date = OKL_API.G_MISS_DATE)
      THEN
        x_adjv_rec.gl_date := l_adjv_rec.gl_date;
      END IF;
      IF (x_adjv_rec.comments = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.comments := l_adjv_rec.comments;
      END IF;
      IF (x_adjv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute_category := l_adjv_rec.attribute_category;
      END IF;
      IF (x_adjv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute1 := l_adjv_rec.attribute1;
      END IF;
      IF (x_adjv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute2 := l_adjv_rec.attribute2;
      END IF;
      IF (x_adjv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute3 := l_adjv_rec.attribute3;
      END IF;
      IF (x_adjv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute4 := l_adjv_rec.attribute4;
      END IF;
      IF (x_adjv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute5 := l_adjv_rec.attribute5;
      END IF;
      IF (x_adjv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute6 := l_adjv_rec.attribute6;
      END IF;
      IF (x_adjv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute7 := l_adjv_rec.attribute7;
      END IF;
      IF (x_adjv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute8 := l_adjv_rec.attribute8;
      END IF;
      IF (x_adjv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute9 := l_adjv_rec.attribute9;
      END IF;
      IF (x_adjv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute10 := l_adjv_rec.attribute10;
      END IF;
      IF (x_adjv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute11 := l_adjv_rec.attribute11;
      END IF;
      IF (x_adjv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute12 := l_adjv_rec.attribute12;
      END IF;
      IF (x_adjv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute13 := l_adjv_rec.attribute13;
      END IF;
      IF (x_adjv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute14 := l_adjv_rec.attribute14;
      END IF;
      IF (x_adjv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_adjv_rec.attribute15 := l_adjv_rec.attribute15;
      END IF;
      IF (x_adjv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.request_id := l_adjv_rec.request_id;
      END IF;
      IF (x_adjv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.program_application_id := l_adjv_rec.program_application_id;
      END IF;
      IF (x_adjv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.program_id := l_adjv_rec.program_id;
      END IF;
      IF (x_adjv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_adjv_rec.program_update_date := l_adjv_rec.program_update_date;
      END IF;
      IF (x_adjv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.org_id := l_adjv_rec.org_id;
      END IF;
      IF (x_adjv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.created_by := l_adjv_rec.created_by;
      END IF;
      IF (x_adjv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_adjv_rec.creation_date := l_adjv_rec.creation_date;
      END IF;
      IF (x_adjv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.last_updated_by := l_adjv_rec.last_updated_by;
      END IF;
      IF (x_adjv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_adjv_rec.last_update_date := l_adjv_rec.last_update_date;
      END IF;
      IF (x_adjv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_adjv_rec.last_update_login := l_adjv_rec.last_update_login;
      END IF;
        --gkhuntet start 02-Nov-07
      IF (x_adjv_rec.TRANSACTION_DATE  = Okl_Api.G_MISS_DATE OR x_adjv_rec.TRANSACTION_DATE IS NULL) THEN
          x_adjv_rec.TRANSACTION_DATE  := l_adjv_rec.TRANSACTION_DATE ;
      END IF;
     --gkhuntet end 02-Nov-07
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_adjv_rec IN  adjv_rec_type,
      x_adjv_rec OUT NOCOPY adjv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_adjv_rec := p_adjv_rec;
      x_adjv_rec.OBJECT_VERSION_NUMBER := NVL(x_adjv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_adjv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_adjv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_adjv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_adjv_rec.program_update_date,SYSDATE)
      INTO
        x_adjv_rec.request_id,
        x_adjv_rec.program_application_id,
        x_adjv_rec.program_id,
        x_adjv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_adjv_rec,                        -- IN
      l_adjv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_adjv_rec, l_def_adjv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_adjv_rec := fill_who_columns(l_def_adjv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_adjv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_adjv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_adjv_rec, l_okl_trx_ar_adjsts_tl_rec);
    migrate(l_def_adjv_rec, l_adj_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------

    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_adjsts_tl_rec,
      lx_okl_trx_ar_adjsts_tl_rec
    );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ar_adjsts_tl_rec, l_def_adjv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_adj_rec,
      lx_adj_rec
    );


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_adj_rec, l_def_adjv_rec);
    x_adjv_rec := l_def_adjv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:ADJV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type,
    x_adjv_tbl                     OUT NOCOPY adjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_adjv_tbl.COUNT > 0) THEN
      i := p_adjv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_adjv_rec                     => p_adjv_tbl(i),
          x_adjv_rec                     => x_adjv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_adjv_tbl.LAST);
        i := p_adjv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
     END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_AR_ADJSTS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adj_rec                      IN adj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adj_rec                      adj_rec_type:= p_adj_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_AR_ADJSTS_B
     WHERE ID = l_adj_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_AR_ADJSTS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ar_adjsts_tl_rec     IN okl_trx_ar_adjsts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type:= p_okl_trx_ar_adjsts_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TRX_AR_ADJSTS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ar_adjsts_tl_rec IN  okl_trx_ar_adjsts_tl_rec_type,
      x_okl_trx_ar_adjsts_tl_rec OUT NOCOPY okl_trx_ar_adjsts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ar_adjsts_tl_rec := p_okl_trx_ar_adjsts_tl_rec;
      x_okl_trx_ar_adjsts_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_trx_ar_adjsts_tl_rec,        -- IN
      l_okl_trx_ar_adjsts_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_AR_ADJSTS_TL
     WHERE ID = l_okl_trx_ar_adjsts_tl_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_AR_ADJSTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_rec                     IN adjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_adjv_rec                     adjv_rec_type := p_adjv_rec;
    l_okl_trx_ar_adjsts_tl_rec     okl_trx_ar_adjsts_tl_rec_type;
    l_adj_rec                      adj_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_adjv_rec, l_okl_trx_ar_adjsts_tl_rec);
    migrate(l_adjv_rec, l_adj_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ar_adjsts_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_adj_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:ADJV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adjv_tbl                     IN adjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_adjv_tbl.COUNT > 0) THEN
      i := p_adjv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_adjv_rec                     => p_adjv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_adjv_tbl.LAST);
        i := p_adjv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_ADJ_PVT;

/
